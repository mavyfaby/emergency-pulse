package main

import (
	"pulse/internal/app"
	"pulse/internal/config"
	"pulse/internal/db"
	"pulse/internal/redis"

	"log/slog"
	"strconv"

	"os"
	"os/signal"
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

	// Init logger
	config.InitLogger()

	// Init the database connection
	conn, err := db.Init()

	if err != nil {
		slog.Error("[DB] " + err.Error())
		os.Exit(1)
		return
	}

	// Create the Redis Client
	redisClient, err := redis.Init(
		config.App.RedisHost+":"+strconv.Itoa(config.App.RedisPort),
		config.App.RedisUsername,
		config.App.RedisPassword,
		config.App.RedisDatabase,
	)

	if err != nil {
		slog.Error("[Redis] " + err.Error())
		os.Exit(1)
	}

	slog.Info("[Client] Redis client initialized and connected!")

	// Start application
	go app.Start(conn, redisClient)
	go app.StartTCP(conn)

	// Create a channel to listen for an OS signal
	sigterm := make(chan os.Signal, 1)

	// Notify the channel on SIGTERM or SIGINT
	signal.Notify(sigterm, os.Interrupt, syscall.SIGTERM)

	// Block until a signal is received
	<-sigterm
}
