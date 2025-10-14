package http

import (
	"log/slog"
	"pulse/internal/config"
	"strconv"

	"github.com/jmoiron/sqlx"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/redis/go-redis/v9"
)

func Start(mariadb *sqlx.DB, redis *redis.Client, stop <-chan struct{}) {
	e := echo.New()

	e.HideBanner = true
	e.HidePort = true

	e.Pre(middleware.RemoveTrailingSlash())

	slog.Info("[HTTP] Pulse Backend Server started on port " + strconv.Itoa(config.App.Port))

	if err := e.Start(":" + strconv.Itoa(config.App.Port)); err != nil {
		slog.Error("Failed to start server: " + err.Error())
	}
}
