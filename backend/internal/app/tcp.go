package app

import (
	"emergency-pulse/internal/alerts/repository"
	"emergency-pulse/internal/alerts/request"
	"emergency-pulse/internal/config"
	"emergency-pulse/internal/utils"

	"encoding/binary"
	"errors"
	"io"
	"log/slog"
	"net"
	"os"
	"strconv"

	"github.com/fxamacker/cbor/v2"
	"github.com/jmoiron/sqlx"
)

func StartTCP(dbx *sqlx.DB) {
	// 1. Listen for incoming connections
	tcp, err := net.Listen("tcp", ":"+strconv.Itoa(config.App.TcpPort))

	if err != nil {
		slog.Error("Error listening for incoming connections: " + err.Error())
		os.Exit(1)
		return
	}

	defer tcp.Close()

	slog.Info("TCP server started on port " + strconv.Itoa(config.App.TcpPort))

	// Init repositories
	alertRepo := repository.NewAlertRepository(dbx)

	for {
		client, err := tcp.Accept() // Accept a new connection

		if err != nil {
			slog.Error("Error accepting connection: " + err.Error())
			continue // Continue listening for other connections
		}

		slog.Info("Client connected: " + client.RemoteAddr().String())

		// 3. Handle each connection in a separate goroutine
		go handleConnection(alertRepo, client)
	}
}

func handleConnection(alertRepo *repository.AlertRepository, client net.Conn) {
	defer client.Close()

	for {
		// 1. Read 4-byte length header
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

		msgLen := binary.BigEndian.Uint32(lenBuf)

		// 2. Read the full payload
		data := make([]byte, msgLen)

		_, err = io.ReadFull(client, data)

		if err != nil {
			slog.Info("Failed to read payload: " + err.Error())
			return
		}

		// 3. Decode CBOR
		var alert request.EmergencyAlert

		if err := cbor.Unmarshal(data, &alert); err != nil {
			slog.Error("Invalid CBOR: " + err.Error())
			continue
		}

		alert.Notes = utils.Sanitize(alert.Notes)
		alert.Name = utils.Sanitize(alert.Name)
		alert.Address = utils.Sanitize(alert.Address)
		alert.ContactNo = utils.SanitizeAndRemoveWhitespaces(alert.ContactNo)
		alert.Lat = utils.SanitizeAndRemoveWhitespaces(alert.Lat)
		alert.Lng = utils.SanitizeAndRemoveWhitespaces(alert.Lng)
		alert.Notes = utils.Sanitize(alert.Notes)

		slog.Info(
			"🚨 ALERT 🚨",
			slog.String("imei", alert.IMEI),
			slog.String("name", alert.Name),
			slog.String("address", alert.Address),
			slog.String("contact", alert.ContactNo),
			slog.String("lat", alert.Lat),
			slog.String("lng", alert.Lng),
			slog.String("notes", alert.Notes),
			// slog.Int("pic_bytes", len(alert.Picture)),
		)

		// 4. Save the alert
		if err := alertRepo.CreateAlert(&alert); err != nil {
			slog.Error("Failed to save alert: " + err.Error())
			continue
		}

		// 5. Send response
		if _, err := client.Write([]byte("ACK")); err != nil {
			slog.Error("Failed to send response: " + err.Error())
			return
		}

		slog.Info("Alert saved successfully!")
	}
}
