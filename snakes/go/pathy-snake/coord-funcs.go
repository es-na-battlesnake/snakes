package main

func (c Coord) onBottomEdge() bool {
	return c.Y == 0
}

func (c Coord) onLeftEdge() bool {
	return c.X == 0
}

func (c Coord) onRightEdge(state GameState) bool {
	return c.X == state.Board.Width-1
}

func (c Coord) onTopEdge(state GameState) bool {
	return c.Y == state.Board.Height-1
}

func (c Coord) inBottomLeft() bool {
	return c.X == 0 && c.Y == 0
}

func (coord Coord) inBottomRight(state GameState) bool {
	return coord.X == state.Board.Width-1 && coord.Y == 0
}

func (c Coord) inTopLeft(state GameState) bool {
	return c.X == 0 && c.Y == state.Board.Height-1
}

func (c Coord) inTopRight(state GameState) bool {
	return c.X == state.Board.Width-1 && c.Y == state.Board.Height-1
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
	var snakeBodyParts []Coord
	for _, snake := range state.Board.Snakes {
		// skip the tail because it moves which would make the cell not surrounded.
		snakeBodyParts = append(snakeBodyParts, snake.Body[0:len(snake.Body)-1]...)
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
