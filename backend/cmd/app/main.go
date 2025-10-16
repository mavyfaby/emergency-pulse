package main

import (
	"log/slog"
	"os"
	"os/signal"
	"pulse/internal/config"
	"pulse/internal/db"
	"pulse/internal/http"
	"pulse/internal/http/handler"
	"pulse/internal/repository"
	"pulse/internal/service"
	"pulse/internal/tcp"
	"syscall"

	"github.com/joho/godotenv"
)

func main() {
	// Load env variables
	if err := godotenv.Load(); err != nil {
		slog.Error("Error loading .env file")
		os.Exit(1)
	}

	// Check environment variables
	if err := config.App.Load(); err != nil {
		slog.Error("[ENV] " + err.Error())
		os.Exit(1)
	}

	// Init database
	mariadb, err := db.NewMariaDB()

	if err != nil {
		slog.Error("[DB] " + err.Error())
		os.Exit(1)
	}

	// Init Redis
	redis, err := db.NewRedis()

	if err != nil {
		slog.Error("[Redis] " + err.Error())
		os.Exit(1)
	}

	// Init repositories
	alertRepository := repository.NewAlertRepository(mariadb)

	// Init services
	alertService := service.NewAlertService(alertRepository)

	// Init handlers
	alertHandler := handler.NewAlertHandler(alertService)

	// Create modules
	modules := &http.Modules{
		AlertHandler: alertHandler,
	}

	// Init stop channel
	stop := make(chan struct{})

	// Start services
	go http.Start(modules, mariadb, redis, stop)
	go tcp.Start(modules, mariadb, redis, stop)

	// Wait for SIGINT or SIGTERM
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	<-sig

	close(stop)
	slog.Info("[APP] Graceful shutdown complete!")
}
