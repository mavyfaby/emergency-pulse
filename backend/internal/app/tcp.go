package app

import (
	"emergency-pulse/internal/config"
	"encoding/binary"
	"io"
	"log/slog"
	"net"
	"os"
	"strconv"

	"github.com/fxamacker/cbor/v2"
)

// EmergencyAlert represents minimal CBOR payload
type EmergencyAlert struct {
	UUID      string `cbor:"uuid"`
	Name      string `cbor:"name"`
	Address   string `cbor:"address"`
	ContactNo string `cbor:"contactNo"`
	Lat       string `cbor:"lat"`
	Lng       string `cbor:"lng"`
	Picture   []byte `cbor:"picture"`
}

func StartTCP() {
	// 1. Listen for incoming connections
	tcp, err := net.Listen("tcp", ":"+strconv.Itoa(config.App.TcpPort))

	if err != nil {
		slog.Error("Error listening for incoming connections: " + err.Error())
		os.Exit(1)
		return
	}

	defer tcp.Close()

	slog.Info("TCP server started on port " + strconv.Itoa(config.App.TcpPort))

	for {
		conn, err := tcp.Accept() // Accept a new connection

		if err != nil {
			slog.Error("Error accepting connection: " + err.Error())
			continue // Continue listening for other connections
		}

		slog.Info("Client connected: " + conn.RemoteAddr().String())

		// 3. Handle each connection in a separate goroutine
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	for {
		// 1. Read 4-byte length header
		lenBuf := make([]byte, 4)

		_, err := io.ReadFull(conn, lenBuf)

		if err != nil {
			slog.Info("Client closed: " + err.Error())
			return
		}

		msgLen := binary.BigEndian.Uint32(lenBuf)

		// 2. Read the full payload
		data := make([]byte, msgLen)

		_, err = io.ReadFull(conn, data)

		if err != nil {
			slog.Info("Failed to read payload: " + err.Error())
			return
		}

		// 3. Decode CBOR
		var alert EmergencyAlert

		if err := cbor.Unmarshal(data, &alert); err != nil {
			slog.Error("Invalid CBOR: " + err.Error())
			continue
		}

		slog.Info(
			"🚨 ALERT 🚨",
			slog.String("uuid", alert.UUID),
			slog.String("name", alert.Name),
			slog.String("address", alert.Address),
			slog.String("contact", alert.ContactNo),
			slog.String("lat", alert.Lat),
			slog.String("lng", alert.Lng),
			slog.Int("pic_bytes", len(alert.Picture)),
		)
	}
}
