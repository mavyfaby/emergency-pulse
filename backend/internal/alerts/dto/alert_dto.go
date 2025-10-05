package dto

type AlertDTO struct {
	HashID    string  `json:"hashId"`
	IMEI      string  `json:"imei"`
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	ContactNo string  `json:"contactNo"`
	Lat       string  `json:"lat"`
	Lng       string  `json:"lng"`
	Notes     string  `json:"notes"`
	DoneAt    *string `json:"doneAt"`
	HasImage  bool    `json:"hasImage"`
	CreatedAt string  `json:"createdAt"`
}
