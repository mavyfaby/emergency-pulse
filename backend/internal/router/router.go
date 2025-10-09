package router

import (
	"pulse/internal/alerts/repository"
	"pulse/internal/alerts/router"
	"pulse/internal/config"
	"pulse/pkg/response"

	"errors"

	"github.com/jmoiron/sqlx"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/redis/go-redis/v9"
	"golang.org/x/time/rate"
)

func Setup(e *echo.Echo, db *sqlx.DB, redisClient *redis.Client) {
	// Custom error handler
	e.HTTPErrorHandler = func(err error, c echo.Context) {
		// If the requested resource is not found
		if errors.Is(err, echo.ErrNotFound) {
			_ = response.Error(c, 404, "Resource not found!")
			return
		}

		if errors.Is(err, echo.ErrMethodNotAllowed) {
			_ = response.Error(c, 405, "Method not allowed!")
			return
		}

		// Default error handler
		e.DefaultHTTPErrorHandler(err, c)
	}

	// Use CORS
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowMethods: []string{echo.GET, echo.POST, echo.PUT, echo.DELETE},
	}))

	// Use rate limiter
	e.Use(middleware.RateLimiterWithConfig(middleware.RateLimiterConfig{
		Skipper: middleware.DefaultSkipper,
		Store: middleware.NewRateLimiterMemoryStoreWithConfig(
			middleware.RateLimiterMemoryStoreConfig{
				Rate:      rate.Limit(config.App.RateLimitRefillPerSec),
				Burst:     config.App.RateLimitMaxBurst,
				ExpiresIn: config.App.RateLimitExpires,
			},
		),
		IdentifierExtractor: func(c echo.Context) (string, error) {
			return c.RealIP(), nil
		},
		ErrorHandler: func(c echo.Context, err error) error {
			return response.Error(c, 403, "Cannot identify your request! Please try again later.")
		},
		DenyHandler: func(c echo.Context, identifier string, err error) error {
			return response.Error(c, 429, "Too many requests! Please try again later.")
		},
	}))

	// The API endpoint group
	api := e.Group("/api")

	// Init repositories
	alertRepo := repository.NewAlertRepository(db)

	// Init modules
	alertModule := router.InitAlertModule(alertRepo)

	// Setup alerts router
	router.Setup(api, alertModule)
}
