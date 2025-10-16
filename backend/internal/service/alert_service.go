package service

import (
	"log/slog"
	"pulse/internal/config"
	"pulse/internal/repository"
	"pulse/internal/request"
	"strconv"
)

type AlertService struct {
	Repo *repository.AlertRepository
}

func NewAlertService(repo *repository.AlertRepository) *AlertService {
	return &AlertService{Repo: repo}
}

func (s *AlertService) CreateAlert(alert *request.AlertRequest) error {
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
