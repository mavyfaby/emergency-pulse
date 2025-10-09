package request

// EmergencyAlert represents minimal CBOR payload
type EmergencyAlert struct {
	Imei          string `cbor:"imei"`
	Name          string `cbor:"name"`
	Address       string `cbor:"address"`
	ContactNo     string `cbor:"contactNo"`
	Lat           string `cbor:"lat"`
	Lng           string `cbor:"lng"`
	DeviceModel   string `cbor:"device_model"`
	DeviceBrand   string `cbor:"device_brand"`
	DeviceVersion string `cbor:"device_version"`
	DeviceName    string `cbor:"device_name"`
	Notes         string `cbor:"notes"`
}
