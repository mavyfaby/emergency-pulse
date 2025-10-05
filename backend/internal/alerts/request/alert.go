package request

// EmergencyAlert represents minimal CBOR payload
type EmergencyAlert struct {
	IMEI      string `cbor:"imei"`
	Name      string `cbor:"name"`
	Address   string `cbor:"address"`
	ContactNo string `cbor:"contactNo"`
	Lat       string `cbor:"lat"`
	Lng       string `cbor:"lng"`
	Notes     string `cbor:"notes"`
	// Picture   []byte `cbor:"picture"`
}
