package response

type AlertResponse struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	ContactNo string `json:"contactNo"`
	Lat       string `json:"lat"`
	Lng       string `json:"lng"`
}
