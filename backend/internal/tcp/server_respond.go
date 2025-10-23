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

func HandleRespondTCP(client net.Conn, modules *http.Modules, respond request.RespondRequest) {
	// Sanitize request data
	respond.AlertHashID = security.SanitizeAndRemoveWhitespaces(respond.AlertHashID)
	respond.Imei = security.SanitizeAndRemoveWhitespaces(respond.Imei)

	// Unhash the alert hash ID
	alertID, err := hash.UnhashAlertID(respond.AlertHashID)

	if err != nil {
		slog.Error("[HandleRespondTCP] [1] ERROR: " + err.Error())
		return
	}

	// Log the respond
	slog.Info(
		"📢 RESPOND 📢",
		slog.String("alert_hash_id", respond.AlertHashID),
		slog.String("alert_id", strconv.Itoa(alertID)),
		slog.String("imei", respond.Imei),
	)

	// Create the respond
	modules.AlertHandler.AlertService.CreateRespond(alertID, respond.Imei)
}
