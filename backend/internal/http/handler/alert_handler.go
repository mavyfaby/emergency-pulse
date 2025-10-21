package handler

import (
	"log/slog"
	"net/http"
	"pulse/internal/request"
	"pulse/internal/security"
	"pulse/internal/service"
	"pulse/internal/utils"
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
	centerParam := security.SanitizeAndRemoveWhitespaces(c.QueryParam("center"))                   // "lat,lng"
	radiusParam := security.SanitizeAndRemoveWhitespaces(c.QueryParam("radius"))                   // "km"
	boundsParam := security.SanitizeAndRemoveWhitespaces(c.QueryParam("bounds"))                   // "TL1,TL2,TR1,TR2,BR1,BR2,BL1,BL2"
	excludeResolvedParam := security.SanitizeAndRemoveWhitespaces(c.QueryParam("excludeResolved")) // "true" for true and any for false

	if centerParam == "" || radiusParam == "" || boundsParam == "" {
		return response.Error(c, http.StatusBadRequest, "Missing parameters.")
	}

	// Will be true if excludeResolvedParam is "true" or any other value
	excludeResolved := excludeResolvedParam == "true"

	// Validate center coordinates
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

	// Validate radius
	radiusParsed, err := strconv.Atoi(radiusParam)

	if err != nil {
		return response.Error(c, http.StatusBadRequest, "Invalid radius parameter. Format: km")
	}

	// Validate bounds coordinates
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

	// Extract pagination parameters
	pagination := utils.ExtractPagination(c)

	// Fetch alerts
	alerts, status, count, err := h.AlertService.GetAlerts(pagination, request.AlertGetRequest{
		Center: request.Coordinate{
			Lat: centerParsed[0],
			Lng: centerParsed[1],
		},
		Radius:          radiusParsed,
		ExcludeResolved: excludeResolved,
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
		return response.Error(c, status, err.Error())
	}

	return response.SuccessData(c, status, "Alerts retrieved successfully!", alerts, &count)
}
