package model

import "time"

type AlertStatusModel struct {
	AlertStatusID int32     `db:"alert_status_id"`
	Name          string    `db:"name"`
	Slug          string    `db:"slug"`
	Description   string    `db:"description"`
	CreatedAt     time.Time `db:"created_at"`
}
