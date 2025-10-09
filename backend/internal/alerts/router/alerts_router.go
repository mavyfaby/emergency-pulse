package router

import (
	"pulse/internal/alerts/handler"
	"pulse/internal/alerts/repository"
	"pulse/internal/alerts/service"

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

	api.GET("", module.AlertHandler.GetAlerts)
	api.POST("/:hashId/done", module.AlertHandler.MarkAlertDone)
	api.GET("/:hashId/done-image", module.AlertHandler.GetAlertDoneImage)
	// api.GET("/:hashId/image", module.AlertHandler.GetAlertImage)
}
