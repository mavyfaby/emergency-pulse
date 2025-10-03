package handler

import (
	"emergency-pulse/internal/alerts/service"
	"emergency-pulse/pkg/response"
	"log/slog"

	"github.com/labstack/echo/v4"
)

type AlertHandler struct {
	Service *service.AlertService
}

func NewAlertHandler(service *service.AlertService) *AlertHandler {
	return &AlertHandler{Service: service}
}

func (h *AlertHandler) GetAlerts(c echo.Context) error {
	alerts, err := h.Service.GetAlerts()

	if err != nil {
		slog.Error("Failed to fetch alerts!: " + err.Error())
		response.ErrorData(c, 500, "Failed to fetch alerts!", err)
		return err
	}

	response.SuccessData(c, 200, "Alerts fetched successfully!", alerts)
	return nil
}
