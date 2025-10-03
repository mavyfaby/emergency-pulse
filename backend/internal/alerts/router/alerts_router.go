package router

import (
	"emergency-pulse/internal/alerts/handler"
	"emergency-pulse/internal/alerts/repository"
	"emergency-pulse/internal/alerts/service"

	"github.com/labstack/echo/v4"
)

type AlertModule struct {
	AlertRepository repository.AlertRepository
	AlertService    service.AlertService
	AlertHandler    handler.AlertHandler
}

func InitAlertModule(alertRepository *repository.AlertRepository) AlertModule {
	// Register services
	alertService := service.NewAlertService(alertRepository)
	// Reigster handler
	alertHandler := handler.NewAlertHandler(alertService)

	return AlertModule{
		AlertRepository: *alertRepository,
		AlertService:    *alertService,
		AlertHandler:    *alertHandler,
	}
}

// Setup initializes the alerts router and registers the necessary handlers.
func Setup(e *echo.Group, module AlertModule) {
	api := e.Group("/alerts")

	// Setup public routes here
	api.GET("", module.AlertHandler.GetAlerts)
}
