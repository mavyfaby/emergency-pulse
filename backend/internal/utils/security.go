package utils

import (
	"regexp"
	"strings"
)

// Remove all whitespaces
var whitespaces = regexp.MustCompile(`\s+`)

// Remove all special characters except space and dash (-)
var specialChars = regexp.MustCompile(`[^a-zA-Z0-9 -]+`)

func Sanitize(input string) string {
	input = whitespaces.ReplaceAllString(input, " ")
	input = strings.TrimSpace(input)

	return input
}

func SanitizeAndRemoveWhitespaces(input string) string {
	return Sanitize(strings.ReplaceAll(input, " ", ""))
}

func RemoveSpecialChars(input string) string {
	return Sanitize(specialChars.ReplaceAllString(input, ""))
}
