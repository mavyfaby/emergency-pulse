package model

import "time"

type AlertModel struct {
	AlertID       int32     `db:"alert_id"`
	AlertTypeID   int32     `db:"alert_type_id"`
	Imei          string    `db:"imei"`
	Name          *string   `db:"name"`
	Address       *string   `db:"address"`
	ContactNo     *string   `db:"contact_no"`
	Notes         *string   `db:"notes"`
	DeviceBrand   string    `db:"device_brand"`
	DeviceModel   string    `db:"device_model"`
	DeviceVersion string    `db:"device_version"`
	DeviceName    string    `db:"device_name"`
	Lat           string    `db:"lat"`
	Lng           string    `db:"lng"`
	CreatedAt     time.Time `db:"created_at"`
}
