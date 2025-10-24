package tcp

import (
	"log/slog"
	"net"
	"pulse/internal/hash"
	"pulse/internal/http"
	"pulse/internal/request"
	"pulse/internal/security"
	"strconv"
)

func HandleResolveTCP(client net.Conn, modules *http.Modules, request request.ResolveRequest) {
	// Sanitize request data
	request.AlertHashID = security.SanitizeAndRemoveWhitespaces(request.AlertHashID)
	request.Imei = security.SanitizeAndRemoveWhitespaces(request.Imei)
	request.Lat = security.SanitizeAndRemoveWhitespaces(request.Lat)
	request.Lng = security.SanitizeAndRemoveWhitespaces(request.Lng)
	request.AccuracyMeters = security.SanitizeAndRemoveWhitespaces(request.AccuracyMeters)
	request.DeviceModel = security.Sanitize(request.DeviceModel)
	request.DeviceBrand = security.Sanitize(request.DeviceBrand)
	request.DeviceVersion = security.Sanitize(request.DeviceVersion)
	request.DeviceName = security.Sanitize(request.DeviceName)
	request.DeviceBatteryLevel = security.SanitizeAndRemoveWhitespaces(request.DeviceBatteryLevel)

	// Unhash the alert hash ID
	alertID, err := hash.UnhashAlertID(request.AlertHashID)

	if err != nil {
		slog.Error("[HandleResolveTCP] [1] ERROR: " + err.Error())
		return
	}

	// Log the resolve
	slog.Info(
		"📢 RESOLVE 📢",
		slog.String("alert_hash_id", request.AlertHashID),
		slog.String("alert_id", strconv.Itoa(alertID)),
		slog.String("imei", request.Imei),
		slog.String("lat", request.Lat),
		slog.String("lng", request.Lng),
		slog.String("accuracy_meters", request.AccuracyMeters),
		slog.String("device_model", request.DeviceModel),
		slog.String("device_brand", request.DeviceBrand),
		slog.String("device_version", request.DeviceVersion),
		slog.String("device_name", request.DeviceName),
		slog.String("device_battery_level", request.DeviceBatteryLevel),
	)

	// Create the resolve
	modules.AlertHandler.AlertService.CreateResolve(alertID, request)
}
