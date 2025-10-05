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

	err := r.DB.Select(&alerts, "SELECT id, uuid, name, address, contact_no, lat, lng, done_at created_at FROM alerts")

	if err != nil {
		slog.Error("[AlertRepository.GetAlerts] [1] ERROR: " + err.Error())
		return nil, err
	}

	return alerts, nil
}

func (r *AlertRepository) GetAlertByID(alertId int) (*model.AlertModel, error) {
	var alert model.AlertModel

	err := r.DB.Get(&alert, "SELECT id, uuid, name, address, contact_no, lat, lng, done_at, created_at FROM alerts WHERE id = ?", alertId)

	if err != nil {
		slog.Error("[AlertRepository.GetAlertByID] [1] ERROR: " + err.Error())
		return nil, err
	}

	return &alert, nil
}

// func (r *AlertRepository) GetAlertImage(alertId int) (*model.AlertImage, error) {
// 	var image model.AlertImage

// 	err := r.DB.Get(&image, "SELECT picture, picture_type FROM alerts WHERE id = ?", alertId)

// 	if err != nil {
// 		slog.Error("[AlertRepository.GetAlertImage] [1] ERROR: " + err.Error())
// 		return nil, err
// 	}

// 	return &image, nil
// }

func (r *AlertRepository) CreateAlert(alert *request.EmergencyAlert) error {
	var query = "INSERT INTO alerts (uuid, name, address, contact_no, lat, lng, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())"

	result, err := r.DB.Exec(query, alert.UUID, alert.Name, alert.Address, alert.ContactNo, alert.Lat, alert.Lng)

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

func (r *AlertRepository) GetAlertDoneImage(alertId int) (*model.AlertDoneImage, error) {
	var image model.AlertDoneImage

	err := r.DB.Get(&image, "SELECT done_picture, done_picture_type FROM alerts WHERE id = ?", alertId)

	if err != nil {
		slog.Error("[AlertRepository.GetAlertDoneImage] [1] ERROR: " + err.Error())
		return nil, err
	}

	return &image, nil
}

func (r *AlertRepository) MarkAlertDone(alertId int, donePicture []byte, doneRemarks string) error {
	var query = "UPDATE alerts SET done_picture = ?, done_picture_type = ?, done_remarks = ?, done_at = NOW() WHERE id = ?"

	contentType := http.DetectContentType(donePicture)
	var remarks *string

	if doneRemarks == "" {
		remarks = nil
	} else {
		remarks = &doneRemarks
	}

	result, err := r.DB.Exec(query, donePicture, contentType, remarks, alertId)

	if err != nil {
		slog.Error("[AlertRepository.MarkAlertDone] [1] ERROR: " + err.Error())
		return err
	}

	if rowsAffected, err := result.RowsAffected(); err != nil {
		slog.Error("[AlertRepository.MarkAlertDone] [2] ERROR: " + err.Error())
		return err
	} else if rowsAffected == 0 {
		slog.Error("[AlertRepository.MarkAlertDone] [3] ERROR: No rows affected")
		return errors.New("no rows affected")
	}

	return nil
}
