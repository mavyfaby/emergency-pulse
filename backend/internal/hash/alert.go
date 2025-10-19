package hash

import (
	"pulse/internal/config"
	"pulse/internal/security"
)

func HashAlertID(alertId int) (string, error) {
	return security.HashID(alertId, config.App.HashSaltAlerts)
}

func UnhashAlertID(hash string) (int, error) {
	return security.UnhashID(hash, config.App.HashSaltAlerts)
}
