package handler

import (
	"io"
	"log/slog"
	"net/http"
	"pulse/internal/alerts/service"
	"pulse/internal/utils"
	"pulse/pkg/response"

	alertUtils "pulse/internal/alerts/utils"

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

func (h *AlertHandler) MarkAlertDone(c echo.Context) error {
	hashId := utils.SanitizeAndRemoveWhitespaces(c.Param("hashId"))

	alertId, err := alertUtils.UnhashAlertID(hashId)

	if err != nil {
		slog.Error("Failed to unhash alert ID!: " + err.Error())
		response.Error(c, 500, "Invalid Request!")
		return err
	}

	// Get other form fields
	remarks := c.FormValue("remarks")
	picture, err := c.FormFile("picture")

	if err != nil {
		slog.Error("Failed to fetch picture!: " + err.Error())
		response.Error(c, 500, "Failed to fetch picture!")
		return err
	}

	file, err := picture.Open()

	if err != nil {
		slog.Error("Failed to open picture!: " + err.Error())
		response.Error(c, 500, "Failed to open picture!")
		return err
	}

	defer file.Close()

	fileBytes, err := io.ReadAll(file)

	if err != nil {
		slog.Error("Failed to read picture!: " + err.Error())
		response.Error(c, 500, "Failed to read picture!")
		return err
	}

	err = h.Service.MarkAlertDone(alertId, fileBytes, remarks)

	if err != nil {
		if err.Error() == "already done" {
			response.Error(c, 409, "Alert is already marked as done!")
			return nil
		}

		if err.Error() == "done picture is required" {
			response.Error(c, 400, "Done picture is required!")
			return nil
		}

		slog.Error("Failed to mark alert as done!: " + err.Error())
		response.Error(c, 500, "Failed to mark alert as done!")
		return err
	}

	response.Success(c, 200, "Alert marked as done successfully!")
	return nil
}

func (h *AlertHandler) GetAlertDoneImage(c echo.Context) error {
	hashId := utils.SanitizeAndRemoveWhitespaces(c.Param("hashId"))

	alertId, err := alertUtils.UnhashAlertID(hashId)

	if err != nil {
		slog.Error("Failed to unhash alert ID!: " + err.Error())
		response.Error(c, 500, "Invalid Request!")
		return err
	}

	image, err := h.Service.GetAlertDoneImage(alertId)

	if err != nil {
		slog.Error("Failed to fetch alert done image!: " + err.Error())
		response.Error(c, 500, "Failed to fetch alert done image!")
		return err
	}

	return c.Blob(http.StatusOK, image.ContentType, *image.Image)
}
