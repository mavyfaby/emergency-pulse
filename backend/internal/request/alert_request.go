package request

type AlertRequest struct {
	AlertType          string `cbor:"alert_type"`
	Imei               string `cbor:"imei"`
	Name               string `cbor:"name"`
	Address            string `cbor:"address"`
	ContactNo          string `cbor:"contact_no"`
	Notes              string `cbor:"notes"`
	Lat                string `cbor:"lat"`
	Lng                string `cbor:"lng"`
	AccuracyMeters     string `cbor:"accuracy_meters"`
	DeviceModel        string `cbor:"device_model"`
	DeviceBrand        string `cbor:"device_brand"`
	DeviceVersion      string `cbor:"device_version"`
	DeviceName         string `cbor:"device_name"`
	DeviceBatteryLevel string `cbor:"device_battery_level"`
}
