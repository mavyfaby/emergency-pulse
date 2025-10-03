package config

// Source: https://chatgpt.com/s/t_68c05390f1dc8191ad250b46b3dc98e9

import (
	"context"
	"log/slog"
	"os"

	"gopkg.in/natefinch/lumberjack.v2"
)

//
// ─── MULTI HANDLER ─────────────────────────────────────────────────────────────
//

// MultiHandler fans out records to multiple handlers.
type MultiHandler struct {
	handlers []slog.Handler
}

func NewMultiHandler(handlers ...slog.Handler) *MultiHandler {
	return &MultiHandler{handlers: handlers}
}

func (m *MultiHandler) Enabled(ctx context.Context, level slog.Level) bool {
	for _, h := range m.handlers {
		if h.Enabled(ctx, level) {
			return true
		}
	}
	return false
}

func (m *MultiHandler) Handle(ctx context.Context, r slog.Record) error {
	var firstErr error
	for _, h := range m.handlers {
		if h.Enabled(ctx, r.Level) {
			// clone to avoid reuse issues
			err := h.Handle(ctx, r.Clone())
			if err != nil && firstErr == nil {
				firstErr = err
			}
		}
	}
	return firstErr
}

func (m *MultiHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	newHandlers := make([]slog.Handler, len(m.handlers))
	for i, h := range m.handlers {
		newHandlers[i] = h.WithAttrs(attrs)
	}
	return &MultiHandler{handlers: newHandlers}
}

func (m *MultiHandler) WithGroup(name string) slog.Handler {
	newHandlers := make([]slog.Handler, len(m.handlers))
	for i, h := range m.handlers {
		newHandlers[i] = h.WithGroup(name)
	}
	return &MultiHandler{handlers: newHandlers}
}

//
// ─── ASYNC HANDLER ─────────────────────────────────────────────────────────────
//

// AsyncHandler wraps another slog.Handler and logs asynchronously.
type AsyncHandler struct {
	ch      chan slog.Record
	handler slog.Handler
	done    chan struct{}
}

func NewAsyncHandler(h slog.Handler, bufferSize int) *AsyncHandler {
	ah := &AsyncHandler{
		ch:      make(chan slog.Record, bufferSize),
		handler: h,
		done:    make(chan struct{}),
	}

	go func() {
		for rec := range ah.ch {
			_ = ah.handler.Handle(context.Background(), rec)
		}
		close(ah.done)
	}()

	return ah
}

func (ah *AsyncHandler) Enabled(ctx context.Context, level slog.Level) bool {
	return ah.handler.Enabled(ctx, level)
}

func (ah *AsyncHandler) Handle(ctx context.Context, r slog.Record) error {
	r2 := r.Clone() // clone because slog reuses Record
	select {
	case ah.ch <- r2:
	default:
		// drop if buffer is full (non-blocking)
	}
	return nil
}

func (ah *AsyncHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return NewAsyncHandler(ah.handler.WithAttrs(attrs), cap(ah.ch))
}

func (ah *AsyncHandler) WithGroup(name string) slog.Handler {
	return NewAsyncHandler(ah.handler.WithGroup(name), cap(ah.ch))
}

// Close flushes and stops the async handler.
func (ah *AsyncHandler) Close() {
	close(ah.ch)
	<-ah.done
}

func InitLogger() {
	// lumberjack handles rotation
	rotator := &lumberjack.Logger{
		Filename:   "emergency_pulse.log",
		MaxSize:    10, // megabytes
		MaxBackups: 100,
		MaxAge:     28, // days
	}

	// file handler with JSON format
	fileHandler := slog.NewJSONHandler(rotator, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	})

	// wrap file handler with async
	asyncFileHandler := NewAsyncHandler(fileHandler, 1000)

	// console handler with text format
	consoleHandler := slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelDebug,
	})

	// combine both handlers
	multiHandler := NewMultiHandler(consoleHandler, asyncFileHandler)

	// set as global
	logger := slog.New(multiHandler)
	slog.SetDefault(logger)
}
