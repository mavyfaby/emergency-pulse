package request

type ResolveRequest struct {
	AlertHashID        string `cbor:"alert_hash_id"`
	Imei               string `cbor:"imei"`
	Lat                string `cbor:"lat"`
	Lng                string `cbor:"lng"`
	AccuracyMeters     string `cbor:"accuracy_meters"`
	DeviceModel        string `cbor:"device_model"`
	DeviceBrand        string `cbor:"device_brand"`
	DeviceVersion      string `cbor:"device_version"`
	DeviceName         string `cbor:"device_name"`
	DeviceBatteryLevel string `cbor:"device_battery_level"`
}
