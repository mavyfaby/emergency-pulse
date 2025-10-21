package request

type AlertGetRequest struct {
	Center          Coordinate
	Radius          int // In meters
	Bounds          []Coordinate
	ExcludeResolved bool
}

type Coordinate struct {
	Lat float64
	Lng float64
}
