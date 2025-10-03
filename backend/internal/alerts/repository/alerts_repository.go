package repository

import (
	"emergency-pulse/internal/alerts/model"
	"emergency-pulse/internal/alerts/request"
	"errors"
	"log/slog"
	"net/http"

	"github.com/jmoiron/sqlx"
)

type AlertRepository struct {
	DB *sqlx.DB
}

func NewAlertRepository(db *sqlx.DB) *AlertRepository {
	return &AlertRepository{DB: db}
}

func (r *AlertRepository) GetAlerts() ([]*model.AlertModel, error) {
	var alerts []*model.AlertModel

	err := r.DB.Select(&alerts, "SELECT id, uuid, name, address, contact_no, lat, lng, done_at, created_at FROM alerts")

	if err != nil {
		slog.Error("[AlertRepository.GetAlerts] [1] ERROR: " + err.Error())
		return nil, err
	}

	return alerts, nil
}

func (r *AlertRepository) CreateAlert(alert *request.EmergencyAlert) error {
	// Detect the content type
	contentType := http.DetectContentType(alert.Picture)

	var query = "INSERT INTO alerts (uuid, picture, picture_type, name, address, contact_no, lat, lng, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())"

	result, err := r.DB.Exec(query, alert.UUID, alert.Picture, contentType, alert.Name, alert.Address, alert.ContactNo, alert.Lat, alert.Lng)

	if err != nil {
		slog.Error("[AlertRepository.CreateAlert] [1] ERROR: " + err.Error())
		return err
	}

	if rowsAffected, err := result.RowsAffected(); err != nil {
		slog.Error("[AlertRepository.CreateAlert] [2] ERROR: " + err.Error())
		return err
	} else if rowsAffected == 0 {
		slog.Error("[AlertRepository.CreateAlert] [3] ERROR: No rows affected")
		return errors.New("no rows affected")
	}

	return nil
}
