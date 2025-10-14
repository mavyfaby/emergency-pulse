package service

import "pulse/internal/repository"

type AlertService struct {
	repo repository.AlertRepository
}

func NewAlertService(repo repository.AlertRepository) *AlertService {
	return &AlertService{repo: repo}
}
