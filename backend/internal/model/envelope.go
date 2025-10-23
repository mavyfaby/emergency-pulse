package model

import "github.com/fxamacker/cbor/v2"

type Envelope struct {
	Type    string          `cbor:"type"`
	Payload cbor.RawMessage `cbor:"payload"`
}
