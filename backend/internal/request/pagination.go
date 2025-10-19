package request

import (
	"fmt"
	"pulse/internal/security"
	"slices"
	"strings"
)

type PaginationRequest struct {
	Page     int     `json:"page"`
	Limit    int     `json:"limit"`
	Search   *string `json:"search"`
	SearchBy *string `json:"searchBy"`
	SortBy   *string `json:"sortBy"`
	SortDir  *string `json:"sortDir"`
	Offset   int
}

func (p *PaginationRequest) Validate(searchColumns []string, sortColumns []string) error {
	if p.Page < 1 {
		p.Page = 1
	}

	if p.Limit < 0 {
		p.Limit = 10
	}

	if p.Limit > 100 {
		p.Limit = 100
	}

	if p.SearchBy != nil && p.Search != nil && *p.Search != "" && *p.SearchBy != "" && !slices.Contains(searchColumns, *p.SearchBy) {
		return fmt.Errorf("Invalid search column: %s", *p.SearchBy)
	}

	if p.SortDir != nil && *p.SortDir != "" {
		*p.SortDir = strings.ToLower(*p.SortDir)
	}

	if p.SortBy != nil && *p.SortBy != "" && !slices.Contains(sortColumns, *p.SortBy) {
		return fmt.Errorf("Invalid sort by column %s", *p.SortBy)
	}

	if p.SortDir != nil && *p.SortDir != "" && (*p.SortDir != "asc" && *p.SortDir != "desc") {
		return fmt.Errorf("Invalid sort direction %s", *p.SortDir)
	}

	if p.SearchBy != nil {
		*p.SearchBy = security.CamelToSnake(*p.SearchBy)
	}

	if p.SortBy != nil {
		*p.SortBy = security.CamelToSnake(*p.SortBy)
	}

	p.Offset = (p.Page - 1) * p.Limit

	return nil
}
