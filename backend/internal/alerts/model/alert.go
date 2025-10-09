package model

import (
	alertDTO "emergency-pulse/internal/alerts/dto"
	alertUtils "emergency-pulse/internal/alerts/utils"
	"emergency-pulse/internal/utils"

	"log/slog"
	"time"
)

type AlertModel struct {
	ID            int32      `db:"id"`
	Imei          string     `db:"imei"`
	Name          string     `db:"name"`
	Address       string     `db:"address"`
	ContactNo     string     `db:"contact_no"`
	Lat           string     `db:"lat"`
	Lng           string     `db:"lng"`
	DeviceModel   string     `db:"device_model"`
	DeviceBrand   string     `db:"device_brand"`
	DeviceVersion string     `db:"device_version"`
	DeviceName    string     `db:"device_name"`
	Notes         string     `db:"notes"`
	DoneRemarks   string     `db:"done_remarks"`
	DoneAt        *time.Time `db:"done_at"`
	CreatedAt     time.Time  `db:"created_at"`
}

func (m AlertModel) ToDTO() (*alertDTO.AlertDTO, error) {
	alertHashID, err := alertUtils.HashAlertID(int(m.ID))

	if err != nil {
		slog.Error("[AlertModel.ToDTO] [1] ERROR: " + err.Error())
		return nil, err
	}

	alertDTO := alertDTO.AlertDTO{
		HashID:        alertHashID,
		Imei:          m.Imei,
		Name:          m.Name,
		Address:       m.Address,
		ContactNo:     m.ContactNo,
		Lat:           m.Lat,
		Lng:           m.Lng,
		DeviceModel:   m.DeviceModel,
		DeviceBrand:   m.DeviceBrand,
		DeviceVersion: m.DeviceVersion,
		DeviceName:    m.DeviceName,
		DoneRemarks:   m.DoneRemarks,
		Notes:         m.Notes,
		CreatedAt:     utils.TimeToISO8601(m.CreatedAt),
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
