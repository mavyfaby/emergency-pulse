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
	"pulse/internal/model"
	"pulse/internal/request"

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
		// Accept the client connection
		client, err := server.Accept()

		if err != nil {
			slog.Error("Error accepting connection: " + err.Error())
			continue
		}

		// Handle the client connection
		go onConnect(client, modules)
	}
}

// / onConnect Handles the client connection
func onConnect(client net.Conn, modules *http.Modules) {
	// Close client connection when function ends
	defer client.Close()

	// Show client connected
	slog.Info("[TCP] Client connected: " + client.RemoteAddr().String())

	for {
		// Reserve 4 bytes to store the message length
		lengthBuffer := make([]byte, 4)

		// Read the length of the data from the client
		_, err := io.ReadFull(client, lengthBuffer)

		if err != nil {
			if errors.Is(io.EOF, err) {
				slog.Info("Client disconnected!")
				return
			}

			slog.Info("Client closed: " + err.Error())
			return
		}

		// Get the data length from length bytes
		dataLength := binary.BigEndian.Uint32(lengthBuffer)

		// Make a buffer memory for the data exactly the size of the data
		data := make([]byte, dataLength)

		// Read the data from the client
		_, err = io.ReadFull(client, data)

		if err != nil {
			slog.Info("Client closed: " + err.Error())
			return
		}

		var env model.Envelope

		// Unmarshal metadata
		if err := cbor.Unmarshal(data, &env); err != nil {
			slog.Error("Invalid Envelope CBOR: " + err.Error())
			continue
		}

		// Handle the envelope
		switch env.Type {
		case "alert":
			// Create an alert request
			var alert request.AlertRequest

			// Unmarshal the data into the alert struct
			if err := cbor.Unmarshal(env.Payload, &alert); err != nil {
				slog.Error("Invalid CBOR: " + err.Error())
				continue
			}

			// Handle the alert
			HandleAlertTCP(client, modules, alert)
		case "respond":
			// Create a respond request
			var respond request.RespondRequest

			// Unmarshal the data into the respond struct
			if err := cbor.Unmarshal(env.Payload, &respond); err != nil {
				slog.Error("Invalid CBOR: " + err.Error())
				continue
			}

			// Handle the respond
			HandleRespondTCP(client, modules, respond)
		default:
			// TODO: Send an error response
			slog.Error("Invalid Envelope Type: " + env.Type)
		}
	}
}
