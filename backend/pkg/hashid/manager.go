package hashid

import (
	"errors"

	"github.com/speps/go-hashids/v2"
)

func NewHasher(salt string) (*hashids.HashID, error) {
	if salt == "" {
		return nil, errors.New("invalid salt")
	}

	hd := hashids.NewData()
	hd.Salt = salt
	hd.MinLength = 8

	return hashids.NewWithData(hd)
}

func NewHasherEncode(salt string, value int) (string, error) {
	hasher, err := NewHasher(salt)

	if err != nil {
		return "", err
	}

	return hasher.Encode([]int{value})
}

func NewHasherDecode(salt string, value string) (int, error) {
	hasher, err := NewHasher(salt)

	if err != nil {
		return 0, err
	}

	encoded, err := hasher.DecodeWithError(value)

	if err != nil {
		return 0, err
	}

	return encoded[0], nil
}
