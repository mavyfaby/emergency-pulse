package service

import (
	"emergency-pulse/internal/alerts/dto"
	"emergency-pulse/internal/alerts/model"
	"emergency-pulse/internal/alerts/repository"
)

type AlertService struct {
	Repo *repository.AlertRepository
}

func NewAlertService(repo *repository.AlertRepository) *AlertService {
	return &AlertService{Repo: repo}
}

func (s *AlertService) GetAlerts() ([]*dto.AlertDTO, error) {
	alerts, err := s.Repo.GetAlerts()

	if err != nil {
		return nil, err
	}

	return model.AlertsToDTOs(alerts)
}
