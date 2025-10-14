package repository

import (
	"errors"
	"log/slog"
	"pulse/internal/request"

	"github.com/jmoiron/sqlx"
)

type AlertRepository struct {
	DB *sqlx.DB
}

func NewAlertRepository(db *sqlx.DB) *AlertRepository {
	return &AlertRepository{DB: db}
}

func (r *AlertRepository) CreateAlert(alert *request.AlertRequest) error {
	var query = `
		INSERT INTO alerts
			(imei, name, address, contact_no, lat, lng, device_model, device_brand, device_version, device_name, notes, created_at)
		VALUES
			(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
	`

	result, err := r.DB.Exec(query,
		alert.Imei,
		alert.Name,
		alert.Address,
		alert.ContactNo,
		alert.Lat,
		alert.Lng,
		alert.DeviceModel,
		alert.DeviceBrand,
		alert.DeviceVersion,
		alert.DeviceName,
		alert.Notes,
	)

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
