package request

type RespondRequest struct {
	AlertHashID string `cbor:"alert_hash_id"`
	Imei        string `cbor:"imei"`
}
