package handler

import (
	"pulse/internal/service"
)

type AlertHandler struct {
	AlertService *service.AlertService
}

func NewAlertHandler(s *service.AlertService) *AlertHandler {
	return &AlertHandler{AlertService: s}
}
