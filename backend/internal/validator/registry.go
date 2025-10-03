package validator

import (
	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
)

type EchoValidator struct {
	v *validator.Validate
}

func (ev *EchoValidator) Validate(i interface{}) error {
	return ev.v.Struct(i)
}

func Register(echo *echo.Echo) {
	echo.Validator = &EchoValidator{v: validator.New()}
}
