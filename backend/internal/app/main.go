package app

import (
	"pulse/internal/config"
	"pulse/internal/router"
	"pulse/internal/validator"

	"log/slog"
	"strconv"

	"github.com/jmoiron/sqlx"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/redis/go-redis/v9"
)

func Start(conn *sqlx.DB, redisClient *redis.Client) {
	// Create a new Echo instance
	e := echo.New()

	// Hide the banner
	e.HideBanner = true
	// Remove trailing slashes from URLs
	e.Pre(middleware.RemoveTrailingSlash())

	// Register validators
	validator.Register(e)
	// Setup the router
	router.Setup(e, conn, redisClient)

	// Handle error if the server fails to start
	if err := e.Start(":" + strconv.Itoa(config.App.Port)); err != nil {
		slog.Error("Failed to start server: " + err.Error())
	}
}
