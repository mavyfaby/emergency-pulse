package handler

import (
	"log/slog"
	"net/http"
	"pulse/internal/request"
	"pulse/internal/security"
	"pulse/internal/service"
	"pulse/pkg/response"
	"strconv"
	"strings"

	"github.com/labstack/echo/v4"
)

type AlertHandler struct {
	AlertService *service.AlertService
}

func NewAlertHandler(s *service.AlertService) *AlertHandler {
	return &AlertHandler{AlertService: s}
}

func (h *AlertHandler) GetAlerts(c echo.Context) error {
	centerParam := security.SanitizeAndRemoveWhitespaces(c.QueryParam("center")) // "lat,lng"
	radiusParam := security.SanitizeAndRemoveWhitespaces(c.QueryParam("radius")) // "km"
	boundsParam := security.SanitizeAndRemoveWhitespaces(c.QueryParam("bounds")) // "TL1,TL2,TR1,TR2,BR1,BR2,BL1,BL2"

	if centerParam == "" || radiusParam == "" || boundsParam == "" {
		return response.Error(c, http.StatusBadRequest, "Missing parameters.")
	}

	centerParams := strings.Split(centerParam, ",")
	centerParsed := []float64{}

	if len(centerParams) != 2 {
		return response.Error(c, http.StatusBadRequest, "Invalid center parameter. Format: lat,lng")
	}

	for _, param := range centerParams {
		v, err := strconv.ParseFloat(param, 64)

		if err != nil {
			return response.Error(c, http.StatusBadRequest, "Invalid center parameter. Format: lat,lng")
		}

		centerParsed = append(centerParsed, v)
	}

	radiusParsed, err := strconv.Atoi(radiusParam)

	if err != nil {
		return response.Error(c, http.StatusBadRequest, "Invalid radius parameter. Format: km")
	}

	boundsParams := strings.Split(boundsParam, ",")
	boundsParsed := []float64{}

	if len(boundsParams) != 8 {
		return response.Error(c, http.StatusBadRequest, "Invalid bounds parameter. Format: TLX,TLY,TRX,TRY,BRX,BRY,BLX,BLY")
	}

	for _, param := range boundsParams {
		v, err := strconv.ParseFloat(param, 64)

		if err != nil {
			return response.Error(c, http.StatusBadRequest, "Invalid bounds parameter. Format: TLX,TLY,TRX,TRY,BRX,BRY,BLX,BLY")
		}

		boundsParsed = append(boundsParsed, v)
	}

	// TODO: Validate bounds coordinates (e.g TLX < TRY, BLX < BRX, TLY < BLY, TRY < BRY)

	alerts, err := h.AlertService.GetAlerts(&request.AlertGetRequest{
		Center: request.Coordinate{
			Lat: centerParsed[0],
			Lng: centerParsed[1],
		},
		Radius: radiusParsed,
		Bounds: []request.Coordinate{
			{
				Lat: boundsParsed[0],
				Lng: boundsParsed[1],
			},
			{
				Lat: boundsParsed[2],
				Lng: boundsParsed[3],
			},
			{
				Lat: boundsParsed[4],
				Lng: boundsParsed[5],
			},
			{
				Lat: boundsParsed[6],
				Lng: boundsParsed[7],
			},
		},
	})

	if err != nil {
		slog.Error("[AlertHandler.GetAlerts] Failed to get alerts: " + err.Error())
		return response.Error(c, http.StatusInternalServerError, "Failed to get alerts.")
	}

	return response.SuccessData(c, http.StatusOK, "Alerts retrieved successfully!", alerts)
}
