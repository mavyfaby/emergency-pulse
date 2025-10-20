package tcp

import (
	"encoding/binary"
	"errors"
	"io"
	"log/slog"
	"net"
	"os"
	"strconv"

	"pulse/internal/config"
	"pulse/internal/http"
	"pulse/internal/request"
	"pulse/internal/security"

	"github.com/fxamacker/cbor/v2"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
)

func Start(modules *http.Modules, mariadb *sqlx.DB, redis *redis.Client, stop <-chan struct{}) {
	server, err := net.Listen("tcp", ":"+strconv.Itoa(config.App.TcpPort))

	if err != nil {
		slog.Error("Error listening for incoming connections: " + err.Error())
		os.Exit(1)
	}

	defer server.Close()

	slog.Info("[TCP] Alert is listening on port " + strconv.Itoa(config.App.TcpPort))

	for {
		client, err := server.Accept()

		if err != nil {
			slog.Error("Error accepting connection: " + err.Error())
			continue
		}

		go onConnect(client, modules)
	}
}

func onConnect(client net.Conn, modules *http.Modules) {
	defer client.Close()

	slog.Info("[TCP] Client connected: " + client.RemoteAddr().String())

	for {
		// Reserve 4 bytes to store the message length
		lenBuf := make([]byte, 4)

		_, err := io.ReadFull(client, lenBuf)

		if err != nil {
			if errors.Is(io.EOF, err) {
				slog.Info("Client disconnected!")
				return
			}

			slog.Info("Client closed: " + err.Error())
			return
		}

		dataLength := binary.BigEndian.Uint32(lenBuf)

		// Make a buffer memory for the data exactly the size of the data
		data := make([]byte, dataLength)

		_, err = io.ReadFull(client, data)

		if err != nil {
			slog.Info("Client closed: " + err.Error())
			return
		}

		var alert request.AlertRequest

		// Unmarshal the data into the alert struct
		if err := cbor.Unmarshal(data, &alert); err != nil {
			slog.Error("Invalid CBOR: " + err.Error())
			continue
		}

		alert.AlertType = security.SanitizeAndRemoveWhitespaces(alert.AlertType)
		alert.Notes = security.Sanitize(alert.Notes)
		alert.Name = security.Sanitize(alert.Name)
		alert.Address = security.Sanitize(alert.Address)
		alert.ContactNo = security.SanitizeAndRemoveWhitespaces(alert.ContactNo)
		alert.Lat = security.SanitizeAndRemoveWhitespaces(alert.Lat)
		alert.Lng = security.SanitizeAndRemoveWhitespaces(alert.Lng)
		alert.DeviceModel = security.Sanitize(alert.DeviceModel)
		alert.DeviceBrand = security.Sanitize(alert.DeviceBrand)
		alert.DeviceVersion = security.Sanitize(alert.DeviceVersion)
		alert.DeviceName = security.Sanitize(alert.DeviceName)
		alert.DeviceBatteryLevel = security.SanitizeAndRemoveWhitespaces(alert.DeviceBatteryLevel)
		alert.Notes = security.Sanitize(alert.Notes)

		slog.Info(
			"🚨 ALERT 🚨",
			slog.String("alert_type", alert.AlertType),
			slog.String("imei", alert.Imei),
			slog.String("name", alert.Name),
			slog.String("address", alert.Address),
			slog.String("contact_no", alert.ContactNo),
			slog.String("lat", alert.Lat),
			slog.String("lng", alert.Lng),
			slog.String("device_model", alert.DeviceModel),
			slog.String("device_brand", alert.DeviceBrand),
			slog.String("device_version", alert.DeviceVersion),
			slog.String("device_name", alert.DeviceName),
			slog.String("device_battery_level", alert.DeviceBatteryLevel),
			slog.String("notes", alert.Notes),
		)

		modules.AlertHandler.AlertService.CreateAlert(&alert)
	}
}
