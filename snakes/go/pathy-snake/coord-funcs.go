package main

func (c Coord) onBottomEdge() bool {
	if c.Y == 0 {
		return true
	}
	return false
}

func (c Coord) onLeftEdge() bool {
	if c.X == 0 {
		return true
	}
	return false
}

func (c Coord) onRightEdge(width int) bool {
	if c.X == width-1 {
		return true
	}
	return false
}

func (c Coord) onTopEdge(height int) bool {
	if c.Y == height-1 {
		return true
	}
	return false
}

func (c Coord) inBottomLeft() bool {
	if c.X == 0 && c.Y == 0 {
		return true
	}
	return false
}

func (coord Coord) inBottomRight(width int) bool {
	if coord.X == width-1 && coord.Y == 0 {
		return true
	}
	return false
}

func (c Coord) inTopLeft(height int) bool {
	if c.X == 0 && c.Y == height-1 {
		return true
	}
	return false
}

func (c Coord) inTopRight(width int, height int) bool {
	if c.X == width-1 && c.Y == height-1 {
		return true
	}
	return false
}

func (c Coord) isNextToSnakeHead(state GameState) bool {
	return isNextToSnakeHead(c, state)
}

func (c Coord) Surrounded(state GameState) bool {
	// log that we are checking if a coord is surrounded.
	return isSurrounded(c, state)
}

func (c Coord) cellAbove(height int) Coord {
	// assumes that every game is wrapped.
	if c.onTopEdge(height) {
		return Coord{X: c.X, Y: 0}
	}
	return Coord{X: c.X, Y: c.Y + 1}
}

func (c Coord) cellBelow(height int) Coord {
	// assumes that every game is wrapped.
	if c.onBottomEdge() {
		return Coord{X: c.X, Y: height - 1}
	}
	return Coord{X: c.X, Y: c.Y - 1}
}

func (c Coord) cellLeft(width int) Coord {
	// assumes that every game is wrapped.
	if c.onLeftEdge() {
		return Coord{X: width - 1, Y: c.Y}
	}
	return Coord{X: c.X - 1, Y: c.Y}
}

func (c Coord) cellRight(width int) Coord {
	// assumes that every game is wrapped.
	if c.onRightEdge(width) {
		return Coord{X: 0, Y: c.Y}
	}
	return Coord{X: c.X + 1, Y: c.Y}
}

func (c Coord) onEdge(state GameState) bool {
	return c.onBottomEdge() || c.onLeftEdge() || c.onRightEdge(state.Board.Width) || c.onTopEdge(state.Board.Height)
}