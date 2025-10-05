package model

import (
	alertDTO "emergency-pulse/internal/alerts/dto"
	alertUtils "emergency-pulse/internal/alerts/utils"
	"emergency-pulse/internal/utils"

	"log/slog"
	"time"
)

type AlertModel struct {
	ID        int32      `db:"id"`
	IMEI      string     `db:"imei"`
	Name      string     `db:"name"`
	Address   string     `db:"address"`
	ContactNo string     `db:"contact_no"`
	Lat       string     `db:"lat"`
	Lng       string     `db:"lng"`
	Notes     string     `db:"notes"`
	DoneAt    *time.Time `db:"done_at"`
	HasImage  bool       `db:"has_image"`
	CreatedAt time.Time  `db:"created_at"`
}

func (m AlertModel) ToDTO() (*alertDTO.AlertDTO, error) {
	alertHashID, err := alertUtils.HashAlertID(int(m.ID))

	if err != nil {
		slog.Error("[AlertModel.ToDTO] [1] ERROR: " + err.Error())
		return nil, err
	}

	alertDTO := alertDTO.AlertDTO{
		HashID:    alertHashID,
		IMEI:      m.IMEI,
		Name:      m.Name,
		Address:   m.Address,
		ContactNo: m.ContactNo,
		Lat:       m.Lat,
		Lng:       m.Lng,
		Notes:     m.Notes,
		HasImage:  m.HasImage,
		CreatedAt: utils.TimeToISO8601(m.CreatedAt),
	}

	if m.DoneAt != nil {
		doneAt := utils.TimeToISO8601(*m.DoneAt)
		alertDTO.DoneAt = &doneAt
	}

	return &alertDTO, nil
}

func AlertsToDTOs(alerts []*AlertModel) ([]*alertDTO.AlertDTO, error) {
	alertDTOs := make([]*alertDTO.AlertDTO, len(alerts))

	for i, alertDB := range alerts {
		alertDTO, err := alertDB.ToDTO()

		if err != nil {
			slog.Error("[AlertsToDTOs] [1] ERROR: " + err.Error())
			return nil, err
		}

		alertDTOs[i] = alertDTO
	}

	return alertDTOs, nil
}
