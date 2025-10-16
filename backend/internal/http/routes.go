package http

import (
	"pulse/internal/http/handler"

	"github.com/labstack/echo/v4"
)

type Modules struct {
	AlertHandler *handler.AlertHandler
}

func NewRouter(e *echo.Echo, modules Modules) {
	// TODO
}
