package request

type AlertGetRequest struct {
	Center Coordinate
	Radius int
	Bounds []Coordinate
}

type Coordinate struct {
	Lat float64
	Lng float64
}
