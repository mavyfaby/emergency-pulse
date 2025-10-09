package model

type AlertDoneImage struct {
	Image       *[]byte `db:"done_picture"`
	ContentType string  `db:"done_picture_type"`
}
