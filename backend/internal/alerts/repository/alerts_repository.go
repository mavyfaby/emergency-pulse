package repository

import (
	"emergency-pulse/internal/alerts/model"

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
		return nil, err
	}

	return alerts, nil
}
