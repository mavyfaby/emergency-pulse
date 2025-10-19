package security

import (
	"regexp"
	"strings"
)

var whitespaces = regexp.MustCompile(`\s+`)
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

func CamelToSnake(s string) string {
	var result string = ""

	for _, char := range s {
		if char >= 'A' && char <= 'Z' {
			result += "_" + string(char)
		} else {
			result += string(char)
		}
	}

	return result
}
