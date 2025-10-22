package service

import (
	"fmt"
	"log/slog"
	"pulse/internal/config"
	"pulse/internal/dto"
	"pulse/internal/repository"
	"pulse/internal/request"
	"strconv"
)

type AlertService struct {
	Repo          *repository.AlertRepository
	SearchColumns []string
	SortColumns   []string
}

func NewAlertService(repo *repository.AlertRepository) *AlertService {
	return &AlertService{
		Repo: repo,
		SearchColumns: []string{
			"alertType", "imei", "name", "address", "contactNo", "lat", "lng",
			"deviceModel", "deviceBrand", "deviceVersion", "deviceName", "deviceBatteryLevel",
			"notes", "createdAt",
		},
		SortColumns: []string{
			"alertType", "imei", "name", "address", "accuracyMeters", "deviceModel", "deviceBrand", "deviceVersion",
			"deviceName", "deviceBatteryLevel", "createdAt", "action", "action_at", "responder_count",
		},
	}
}

// GetAlerts retrieves alerts filtered by the responder's spatial proximity.
// This also uses the Haversine formula to calculate the distance
// between the responder and the alert in a spherical object such as Earth.
func (s *AlertService) GetAlerts(pagination *request.PaginationRequest, request request.AlertGetRequest) ([]dto.AlertDTO, int, int, error) {
	tl, tr := request.Bounds[0], request.Bounds[1]
	bl, br := request.Bounds[3], request.Bounds[2]

	var lats = []float64{tl.Lat, tr.Lat, bl.Lat, br.Lat}
	var lngs = []float64{tl.Lng, tr.Lng, bl.Lng, br.Lng}

	// Latitude starts 0 at the equator and increases as you move north from 0 to 90,
	// ... decreases as you move south from 0 to -90
	// Longitude starts 0 at the Prime Meridian and increases as you move east from 0 to 180,
	// ... decreases as you move west from 0 to -180
	// So mathematicaly, latitude is Y axis and longitude is X axis

	if tl.Lat < bl.Lat || tr.Lat < br.Lat || tl.Lng > tr.Lng || bl.Lng > br.Lng {
		return nil, 422, 0, fmt.Errorf("Invalid bounds coordinates. [1]")
	}

	for _, lat := range lats {
		if lat < -90 || lat > 90 {
			return nil, 422, 0, fmt.Errorf("Invalid bounds coordinates. [2]")
		}
	}

	for _, lng := range lngs {
		if lng < -180 || lng > 180 {
			return nil, 422, 0, fmt.Errorf("Invalid bounds coordinates. [3]")
		}
	}

	if request.Radius > config.App.AlertMaxRadius {
		return nil, 422, 0, fmt.Errorf("The requested radius is too far. The maximum radius is %d km", config.App.AlertMaxRadius/1000)
	}

	if err := pagination.Validate(s.SearchColumns, s.SortColumns); err != nil {
		return nil, 422, 0, err
	}

	alerts, count, err := s.Repo.GetAlertsFromResponder(pagination, request)

	if err != nil {
		slog.Error("[AlertService.GetAlerts] [1] ERROR: " + err.Error())
		return nil, 500, 0, fmt.Errorf("Failed to get alerts. Please try again.")
	}

	var dtos = []dto.AlertDTO{}

	for _, alert := range alerts {
		dto, err := alert.ToDTO()

		if err != nil {
			slog.Error("[AlertService.GetAlerts] [2] ERROR: " + err.Error())
			return nil, 500, 0, fmt.Errorf("Failed to get alerts. Please try again.")
		}

		dtos = append(dtos, dto)
	}

	return dtos, 200, count, nil
}

func (s *AlertService) CreateAlert(alert *request.AlertRequest) error {
	if alert.AccuracyMeters == "" {
		alert.AccuracyMeters = "0"
	}

	for i := 0; i < config.App.AlertRetries; i++ {
		err := s.Repo.CreateAlert(alert)

		if err != nil {
			if i == config.App.AlertRetries-1 {
				slog.Error("[AlertService.CreateAlert] [1] ERROR INSERTING DATA INTO DATABASE. THIS SHOULD NOT HAPPEN!")
				return err
			}

			slog.Error("[AlertService.CreateAlert] [2] ERROR: " + err.Error() + " (attempt " + strconv.Itoa(i+1) + "/" + strconv.Itoa(config.App.AlertRetries) + ")")
			continue
		}

		break
	}

	// TODO: Propagate to notication services
	slog.Info("[AlertService.CreateAlert] [3] SUCCESS: Alert created successfully")
	return nil
}
