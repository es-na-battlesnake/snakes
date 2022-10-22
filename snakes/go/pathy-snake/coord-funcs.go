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

func (c Coord) onRightEdge(state GameState) bool {
	if c.X == state.Board.Width-1 {
		return true
	}
	return false
}

func (c Coord) onTopEdge(state GameState) bool {
	if c.Y == state.Board.Height-1 {
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
	above := Coord{X: c.X, Y: c.Y + 1}
	below := Coord{X: c.X, Y: c.Y - 1}
	left := Coord{X: c.X - 1, Y: c.Y}
	right := Coord{X: c.X + 1, Y: c.Y}
	// check if above, below, left, or right is occupied by a snake.
	for _, snake := range state.Board.Snakes {
		// skip if the snake is us.
		if snake.ownSnake(state) || snake.Length < state.You.Length {
			continue
		}
		if above == snake.Head || below == snake.Head || left == snake.Head || right == snake.Head {
			return true
		}
		if state.isWrapped() && snake.onOppositeSide(c, state) {
			return true
		}
	}
	return false
}

func (c Coord) Surrounded(state GameState) bool {
	surroundingCells := []Coord{c.cellAbove(state), c.cellBelow(state), c.cellLeft(state), c.cellRight(state)}
	// print the surrounding cells.
	var snakeBodyParts []Coord
	for _, snake := range state.Board.Snakes {
		snakeBodyParts = append(snakeBodyParts, snake.Body...)	
	}
	for _, cell := range surroundingCells {
		if !containsCoord(snakeBodyParts, cell) {
			return false
		}
	}
	return true
}

func (c Coord) cellAbove(state GameState) Coord {
	// assumes that every game is wrapped.
	if c.onTopEdge(state) {
		return Coord{X: c.X, Y: 0}
	}
	return Coord{X: c.X, Y: c.Y + 1}
}

func (c Coord) cellBelow(state GameState) Coord {
	// assumes that every game is wrapped.
	if c.onBottomEdge() {
		return Coord{X: c.X, Y: state.Board.Height - 1}
	}
	return Coord{X: c.X, Y: c.Y - 1}
}

func (c Coord) cellLeft(state GameState) Coord {
	// assumes that every game is wrapped.
	if c.onLeftEdge() {
		return Coord{X: state.Board.Width - 1, Y: c.Y}
	}
	return Coord{X: c.X - 1, Y: c.Y}
}

func (c Coord) cellRight(state GameState) Coord {
	// assumes that every game is wrapped.
	if c.onRightEdge(state) {
		return Coord{X: 0, Y: c.Y}
	}
	return Coord{X: c.X + 1, Y: c.Y}
}

func (c Coord) onEdge(state GameState) bool {
	return c.onBottomEdge() || c.onLeftEdge() || c.onRightEdge(state) || c.onTopEdge(state)
}