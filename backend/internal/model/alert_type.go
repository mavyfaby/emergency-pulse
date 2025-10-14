package model

import "time"

type AlertTypeModel struct {
	AlertTypeID int32     `db:"alert_type_id"`
	Name        string    `db:"name"`
	Slug        string    `db:"slug"`
	Description string    `db:"description"`
	CreatedAt   time.Time `db:"created_at"`
}
