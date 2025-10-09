package dto

type AlertDTO struct {
	HashID        string  `json:"hashId"`
	Imei          string  `json:"imei"`
	Name          string  `json:"name"`
	Address       string  `json:"address"`
	ContactNo     string  `json:"contactNo"`
	Lat           string  `json:"lat"`
	Lng           string  `json:"lng"`
	Notes         string  `json:"notes"`
	DeviceModel   string  `json:"deviceModel"`
	DeviceBrand   string  `json:"deviceBrand"`
	DeviceVersion string  `json:"deviceVersion"`
	DeviceName    string  `json:"deviceName"`
	DoneRemarks   string  `json:"doneRemarks"`
	DoneAt        *string `json:"doneAt"`
	CreatedAt     string  `json:"createdAt"`
}
