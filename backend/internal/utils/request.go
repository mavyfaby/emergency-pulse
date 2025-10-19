package utils

import (
	"log/slog"
	"pulse/internal/request"
	"pulse/internal/security"
	"strconv"

	"github.com/labstack/echo/v4"
)

func ExtractPagination(e echo.Context) *request.PaginationRequest {
	var paramPage = security.SanitizeAndRemoveWhitespaces(e.QueryParam("page"))
	var paramLimit = security.SanitizeAndRemoveWhitespaces(e.QueryParam("limit"))
	var paramSearch = security.Sanitize(e.QueryParam("search"))
	var paramSearchBy = security.SanitizeAndRemoveWhitespaces(e.QueryParam("searchBy"))
	var paramSortBy = security.SanitizeAndRemoveWhitespaces(e.QueryParam("sortBy"))
	var paramSortDir = security.SanitizeAndRemoveWhitespaces(e.QueryParam("sortDir"))

	var page = 1
	var limit = 10

	if paramPage != "" {
		result, err := strconv.Atoi(paramPage)

		if err != nil {
			slog.Error("[utils.ExtractPagination] [1] ERROR: " + err.Error())
		} else {
			page = result
		}

	}

	if paramLimit != "" {
		result, err := strconv.Atoi(paramLimit)

		if err != nil {
			slog.Error("[utils.ExtractPagination] [2] ERROR: " + err.Error())
		} else {
			limit = result
		}
	}

	return &request.PaginationRequest{
		Page:     page,
		Limit:    limit,
		Search:   &paramSearch,
		SearchBy: &paramSearchBy,
		SortBy:   &paramSortBy,
		SortDir:  &paramSortDir,
	}
}
