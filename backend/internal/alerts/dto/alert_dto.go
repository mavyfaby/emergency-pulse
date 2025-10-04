package dto

type AlertDTO struct {
	HashID    string  `json:"hashId"`
	UUID      string  `json:"uuid"`
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	ContactNo string  `json:"contactNo"`
	Lat       string  `json:"lat"`
	Lng       string  `json:"lng"`
	DoneAt    *string `json:"doneAt"`
	HasImage  bool    `json:"hasImage"`
	CreatedAt string  `json:"createdAt"`
}
