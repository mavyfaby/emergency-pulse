package utils

import "time"

func TimeToISO8601(t time.Time) string {
	return t.Format("2006-01-02 15:04:05")
}

func ISO8601ToTime(s string) (time.Time, error) {
	return time.Parse("2006-01-02 15:04:05", s)
}

func TimeToReadable(t time.Time) string {
	return t.Format("January 2, 2006 at 3:04 PM")
}
