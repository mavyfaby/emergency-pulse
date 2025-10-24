package repository

import (
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
			) AS distance
		FROM
			alerts a
		LEFT JOIN
			alert_audits aa ON aa.alert_audit_id = (
				SELECT
					aa2.alert_audit_id
				FROM
					alert_audits aa2
				WHERE
					aa2.alert_id = a.alert_id
				ORDER BY
					aa2.created_at DESC
				LIMIT 1
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

	if request.ExcludeResolved {
		query += " AND aa.alert_audit_id IS NULL"
	}

	query += " HAVING distance <= ?"
	values = append(values, request.Radius)

	var countQuery = "SELECT COUNT(*) AS count FROM (" + query + ") AS t"
	var count int

	err := r.DB.Get(&count, countQuery, values...)

	if err != nil {
		slog.Error("[AlertRepository.GetAlerts] [1] ERROR: " + err.Error())
		return nil, 0, err
	}

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
			(alert_type, imei, name, address, contact_no, lat, lng, accuracy_meters, device_model, device_brand, device_version, device_name, device_battery_level, notes, created_at)
		VALUES
			(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
	`

	result, err := r.DB.Exec(query,
		alert.AlertType,
		alert.Imei,
		alert.Name,
		alert.Address,
		alert.ContactNo,
		alert.Lat,
		alert.Lng,
		alert.AccuracyMeters,
		alert.DeviceModel,
		alert.DeviceBrand,
		alert.DeviceVersion,
		alert.DeviceName,
		alert.DeviceBatteryLevel,
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

func (r *AlertRepository) CreateResolve(alertID int, request request.ResolveRequest) error {
	var query = `
		INSERT INTO alert_audits
			(alert_id, imei, lat, lng, accuracy_meters, device_model, device_brand, device_version, device_name, device_battery_level, created_at)
		VALUES
			(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
	`

	result, err := r.DB.Exec(query,
		alertID,
		request.Imei,
		request.Lat,
		request.Lng,
		request.AccuracyMeters,
		request.DeviceModel,
		request.DeviceBrand,
		request.DeviceVersion,
		request.DeviceName,
		request.DeviceBatteryLevel,
	)

	if err != nil {
		slog.Error("[AlertRepository.CreateResolve] [1] ERROR: " + err.Error())
		return err
	}

	if rowsAffected, err := result.RowsAffected(); err != nil {
		slog.Error("[AlertRepository.CreateResolve] [2] ERROR: " + err.Error())
		return err
	} else if rowsAffected == 0 {
		slog.Error("[AlertRepository.CreateResolve] [3] ERROR: No rows affected")
		return errors.New("no rows affected")
	}

	return nil
}
