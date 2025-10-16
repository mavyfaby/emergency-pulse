package response

import "github.com/labstack/echo/v4"

type Response struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

func SuccessData(c echo.Context, status int, message string, data any) error {
	return c.JSON(status, Response{
		Success: true,
		Message: message,
		Data:    data,
	})
}

func ErrorData(c echo.Context, status int, message string, data any) error {
	return c.JSON(status, Response{
		Success: false,
		Message: message,
		Data:    data,
	})
}

func Success(c echo.Context, status int, message string) error {
	return c.JSON(status, Response{
		Success: true,
		Message: message,
	})
}

func Error(c echo.Context, status int, message string) error {
	return c.JSON(status, Response{
		Success: false,
		Message: message,
	})
}
