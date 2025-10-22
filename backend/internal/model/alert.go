package model

import (
	"log/slog"
	"pulse/internal/dto"
	"pulse/internal/hash"
	"pulse/internal/utils"
	"time"
)

type AlertModel struct {
	AlertID            int32     `db:"alert_id"`
	AlertType          string    `db:"alert_type"`
	Imei               string    `db:"imei"`
	Name               *string   `db:"name"`
	Address            *string   `db:"address"`
	ContactNo          *string   `db:"contact_no"`
	Lat                string    `db:"lat"`
	Lng                string    `db:"lng"`
	AccuracyMeters     string    `db:"accuracy_meters"`
	DeviceBrand        string    `db:"device_brand"`
	DeviceModel        string    `db:"device_model"`
	DeviceVersion      string    `db:"device_version"`
	DeviceName         string    `db:"device_name"`
	DeviceBatteryLevel string    `db:"device_battery_level"`
	Notes              *string   `db:"notes"`
	Distance           float64   `db:"distance"`
	ResponderCount     int       `db:"responder_count"`
	Action             string    `db:"action"`
	ActionAt           time.Time `db:"action_at"`
	CreatedAt          time.Time `db:"created_at"`
}

func (a AlertModel) ToDTO() (dto.AlertDTO, error) {
	hashID, err := hash.HashAlertID(int(a.AlertID))

	if err != nil {
		slog.Error("[AlertModel.ToDTO] [1] ERROR: " + err.Error())
		return dto.AlertDTO{}, err
	}

	return dto.AlertDTO{
		AlertHashID:        hashID,
		AlertType:          a.AlertType,
		Imei:               a.Imei,
		Name:               a.Name,
		Address:            a.Address,
		ContactNo:          a.ContactNo,
		Lat:                a.Lat,
		Lng:                a.Lng,
		AccuracyMeters:     a.AccuracyMeters,
		Distance:           a.Distance,
		DeviceBrand:        a.DeviceBrand,
		DeviceModel:        a.DeviceModel,
		DeviceVersion:      a.DeviceVersion,
		DeviceName:         a.DeviceName,
		DeviceBatteryLevel: a.DeviceBatteryLevel,
		Notes:              a.Notes,
		ResponderCount:     a.ResponderCount,
		Action:             a.Action,
		ActionAt:           utils.TimeToISO8601(a.ActionAt),
		CreatedAt:          utils.TimeToISO8601(a.CreatedAt),
	}, nil
}
