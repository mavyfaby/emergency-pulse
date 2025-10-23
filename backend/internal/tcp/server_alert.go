package tcp

import (
	"log/slog"
	"net"
	"pulse/internal/http"
	"pulse/internal/request"
	"pulse/internal/security"
)

func HandleAlertTCP(client net.Conn, modules *http.Modules, alert request.AlertRequest) {
	// Sanitize request data
	alert.AlertType = security.SanitizeAndRemoveWhitespaces(alert.AlertType)
	alert.Notes = security.Sanitize(alert.Notes)
	alert.Name = security.Sanitize(alert.Name)
	alert.Address = security.Sanitize(alert.Address)
	alert.ContactNo = security.SanitizeAndRemoveWhitespaces(alert.ContactNo)
	alert.Lat = security.SanitizeAndRemoveWhitespaces(alert.Lat)
	alert.Lng = security.SanitizeAndRemoveWhitespaces(alert.Lng)
	alert.AccuracyMeters = security.SanitizeAndRemoveWhitespaces(alert.AccuracyMeters)
	alert.DeviceModel = security.Sanitize(alert.DeviceModel)
	alert.DeviceBrand = security.Sanitize(alert.DeviceBrand)
	alert.DeviceVersion = security.Sanitize(alert.DeviceVersion)
	alert.DeviceName = security.Sanitize(alert.DeviceName)
	alert.DeviceBatteryLevel = security.SanitizeAndRemoveWhitespaces(alert.DeviceBatteryLevel)
	alert.Notes = security.Sanitize(alert.Notes)

	// Log the alert
	slog.Info(
		"🚨 ALERT 🚨",
		slog.String("alert_type", alert.AlertType),
		slog.String("imei", alert.Imei),
		slog.String("name", alert.Name),
		slog.String("address", alert.Address),
		slog.String("contact_no", alert.ContactNo),
		slog.String("lat", alert.Lat),
		slog.String("lng", alert.Lng),
		slog.String("accuracy_meters", alert.AccuracyMeters),
		slog.String("device_model", alert.DeviceModel),
		slog.String("device_brand", alert.DeviceBrand),
		slog.String("device_version", alert.DeviceVersion),
		slog.String("device_name", alert.DeviceName),
		slog.String("device_battery_level", alert.DeviceBatteryLevel),
		slog.String("notes", alert.Notes),
	)

	// Create the alert
	modules.AlertHandler.AlertService.CreateAlert(&alert)
}
