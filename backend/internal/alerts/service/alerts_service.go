package service

import (
	"emergency-pulse/internal/alerts/dto"
	"emergency-pulse/internal/alerts/model"
	"emergency-pulse/internal/alerts/repository"
	"emergency-pulse/internal/utils"
	"errors"
	"log/slog"
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
		slog.Error("Failed to fetch alerts!: " + err.Error())
		return nil, err
	}

	return model.AlertsToDTOs(alerts)
}

// func (s *AlertService) GetAlertImage(alertId int) (*model.AlertImage, error) {
// 	image, err := s.Repo.GetAlertImage(alertId)

// 	if err != nil {
// 		slog.Error("Failed to fetch alert image!: " + err.Error())
// 		return nil, err
// 	}

// 	return image, nil
// }

func (s *AlertService) GetAlertDoneImage(alertId int) (*model.AlertDoneImage, error) {
	image, err := s.Repo.GetAlertDoneImage(alertId)

	if err != nil {
		slog.Error("Failed to fetch alert done image!: " + err.Error())
		return nil, err
	}

	return image, nil
}

func (s *AlertService) MarkAlertDone(alertId int, donePicture []byte, doneRemarks string) error {
	alert, err := s.Repo.GetAlertByID(alertId)

	if err != nil {
		slog.Error("Failed to fetch alert!: " + err.Error())
		return err
	}

	if alert.DoneAt != nil {
		slog.Error("Alert is already marked as done!")
		return errors.New("already done")
	}

	if donePicture == nil {
		slog.Error("Done picture is required!")
		return errors.New("done picture is required")
	}

	remarks := utils.Sanitize(doneRemarks)

	return s.Repo.MarkAlertDone(alertId, donePicture, remarks)
}
