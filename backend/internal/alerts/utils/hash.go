package utils

import (
	"emergency-pulse/internal/config"
	"emergency-pulse/pkg/hashid"
)

func HashAlertID(id int) (string, error) {
	return hashid.NewHasherEncode(config.App.HashSaltAlerts, id)
}

func UnhashAlertID(hashId string) (int, error) {
	return hashid.NewHasherDecode(config.App.HashSaltAlerts, hashId)
}
