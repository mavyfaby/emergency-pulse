package dto

type AlertDTO struct {
	AlertHashID        string  `json:"alertHashId"`
	AlertType          string  `json:"alertType"`
	Imei               string  `json:"imei"`
	Name               *string `json:"name"`
	Address            *string `json:"address"`
	ContactNo          *string `json:"contactNo"`
	Notes              *string `json:"notes"`
	DeviceBrand        string  `json:"deviceBrand"`
	DeviceModel        string  `json:"deviceModel"`
	DeviceVersion      string  `json:"deviceVersion"`
	DeviceName         string  `json:"deviceName"`
	DeviceBatteryLevel string  `json:"deviceBatteryLevel"`
	Lat                string  `json:"lat"`
	Lng                string  `json:"lng"`
	Distance           float64 `json:"distance"`
	ResponderCount     int     `json:"responderCount"`
	Action             string  `json:"action"`
	ActionAt           string  `json:"actionAt"`
	CreatedAt          string  `json:"createdAt"`
}
