package security

import (
	"github.com/speps/go-hashids/v2"
)

var hasher = hashids.NewData()

func HashID(id int, salt string) (string, error) {
	hasher.Salt = salt
	hasher.MinLength = 8

	h, err := hashids.NewWithData(hasher)

	if err != nil {
		return "", err
	}

	return h.Encode([]int{id})
}

func UnhashID(hash string, salt string) (int, error) {
	hasher.Salt = salt
	hasher.MinLength = 8

	h, err := hashids.NewWithData(hasher)

	if err != nil {
		return 0, err
	}

	ids, err := h.DecodeWithError(hash)

	if err != nil {
		return 0, err
	}

	return ids[0], nil
}
