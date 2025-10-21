package repository

import (
	"context"
	"errors"
	"log/slog"
	"pulse/internal/config"
	"pulse/internal/model"
	"pulse/internal/request"

	"github.com/jmoiron/sqlx"
)

type AlertRepository struct {
	DB *sqlx.DB
}

func NewAlertRepository(db *sqlx.DB) *AlertRepository {
	return &AlertRepository{DB: db}
}

func (r *AlertRepository) GetAlertsFromResponder(pagination *request.PaginationRequest, request request.AlertGetRequest) ([]model.AlertModel, int, error) {
	var query = `
		SELECT
			a.*, ? * 2 * ASIN(
				SQRT(
					POWER(SIN(RADIANS(? - a.lat) / 2), 2) +
					COS(RADIANS(a.lat)) * COS(RADIANS(?)) *
					POWER(SIN(RADIANS(? - a.lng) / 2), 2)
				)
			) AS distance,
			(SELECT COUNT(*) FROM alert_audits aa3 WHERE aa3.alert_id = a.alert_id AND aa3.action = 'responding') AS responder_count,
			aa.action,
			CAST(
				GREATEST(
					COALESCE(aa.created_at, '1000-01-01 00:00:00'),
					COALESCE(aa.responding_at, '1000-01-01 00:00:00'),
					COALESCE(aa.resolved_at, '1000-01-01 00:00:00')
				) AS DATETIME
			) AS action_at
		FROM
			alerts a
		INNER JOIN
			alert_audits aa ON aa.alert_audit_id = (
				SELECT
					aa2.alert_audit_id
				FROM
					alert_audits aa2
				WHERE
					aa2.alert_id = a.alert_id
				ORDER BY
					GREATEST(
						COALESCE(aa2.created_at, '1000-01-01 00:00:00'),
						COALESCE(aa2.responding_at, '1000-01-01 00:00:00'),
						COALESCE(aa2.resolved_at, '1000-01-01 00:00:00')
					)
				DESC LIMIT 1
			)

		WHERE a.lat BETWEEN ? AND ? AND a.lng BETWEEN ? AND ?
	`

	var values = []any{
		config.App.EarthRadius,
		request.Center.Lat,
		request.Center.Lat,
		request.Center.Lng,
		request.Bounds[2].Lat,
		request.Bounds[0].Lat,
		request.Bounds[0].Lng,
		request.Bounds[2].Lng,
	}

	if pagination.SearchBy != nil && pagination.Search != nil && *pagination.SearchBy != "" && *pagination.Search != "" {
		query += " AND a." + *pagination.SearchBy + " LIKE ?"
		values = append(values, "%"+*pagination.Search+"%")
	}

	var countQuery = "SELECT COUNT(*) AS count FROM (" + query + ") AS t"
	var count int

	err := r.DB.Get(&count, countQuery, values...)

	if err != nil {
		slog.Error("[AlertRepository.GetAlerts] [1] ERROR: " + err.Error())
		return nil, 0, err
	}

	query += " HAVING distance <= ?"
	values = append(values, request.Radius)

	if pagination.SortBy != nil && pagination.SortDir != nil && *pagination.SortBy != "" && *pagination.SortDir != "" {
		query += " ORDER BY a." + *pagination.SortBy + " " + *pagination.SortDir
	}

	query += " LIMIT ?"

	if pagination.Offset != 0 {
		query += ", ?"
	}

	var result []model.AlertModel = []model.AlertModel{}

	if pagination.Offset != 0 {
		err = r.DB.Select(&result, query, append(values, pagination.Limit, pagination.Offset)...)
	} else {
		err = r.DB.Select(&result, query, append(values, pagination.Limit)...)
	}

	if err != nil {
		slog.Error("[AlertRepository.GetAlerts] [2] ERROR: " + err.Error())
		return nil, 0, err
	}

	return result, count, nil
}

func (r *AlertRepository) CreateAlert(alert *request.AlertRequest) error {
	var query = `
		INSERT INTO alerts
			(alert_type, imei, name, address, contact_no, lat, lng, device_model, device_brand, device_version, device_name, device_battery_level, notes, created_at)
		VALUES
			(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
	`

	tx, err := r.DB.BeginTx(context.Background(), nil)

	if err != nil {
		slog.Error("[AlertRepository.CreateAlert] [1] ERROR: " + err.Error())
		return err
	}

	result, err := tx.Exec(query,
		alert.AlertType,
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
		alert.DeviceBatteryLevel,
		alert.Notes,
	)

	if err != nil {
		slog.Error("[AlertRepository.CreateAlert] [2] ERROR: " + err.Error())
		return err
	}

	if rowsAffected, err := result.RowsAffected(); err != nil {
		slog.Error("[AlertRepository.CreateAlert] [3] ERROR: " + err.Error())
		return err
	} else if rowsAffected == 0 {
		slog.Error("[AlertRepository.CreateAlert] [4] ERROR: No rows affected")
		return errors.New("no rows affected")
	}

	alertId, err := result.LastInsertId()

	if err != nil {
		slog.Error("[AlertRepository.CreateAlert] [5] ERROR: " + err.Error())

		if err := tx.Rollback(); err != nil {
			slog.Error("[AlertRepository.CreateAlert] [6] ERROR: " + err.Error())
		}

		return err
	}

	// Insert to alert_audits table
	var auditQuery = `
		INSERT INTO alert_audits
			(alert_id, action, created_imei, created_at)
		VALUES
			(?, ?, ?, NOW())
	`

	result, err = tx.Exec(auditQuery, alertId, "created", alert.Imei)

	if err != nil {
		slog.Error("[AlertRepository.CreateAlert] [7] ERROR: " + err.Error())

		if err := tx.Rollback(); err != nil {
			slog.Error("[AlertRepository.CreateAlert] [8] ERROR: " + err.Error())
		}

		return err
	}

	if rowsAffected, err := result.RowsAffected(); err != nil {
		slog.Error("[AlertRepository.CreateAlert] [9] ERROR: " + err.Error())

		if err := tx.Rollback(); err != nil {
			slog.Error("[AlertRepository.CreateAlert] [10] ERROR: " + err.Error())
		}

		return err
	} else if rowsAffected == 0 {
		slog.Error("[AlertRepository.CreateAlert] [11] ERROR: No rows affected")

		if err := tx.Rollback(); err != nil {
			slog.Error("[AlertRepository.CreateAlert] [12] ERROR: " + err.Error())
		}

		return errors.New("no rows affected")
	}

	if err := tx.Commit(); err != nil {
		slog.Error("[AlertRepository.CreateAlert] [13] ERROR: " + err.Error())
		return err
	}

	return nil
}
