package main

func (s Battlesnake) onLeftEdge() bool {
	if s.Head.X == 0 {
		return true
	}
	return false
}

func (s Battlesnake) onRightEdge(state GameState) bool {
	if s.Head.X == state.Board.Width-1 {
		return true
	}
	return false
}

func (s Battlesnake) onTopEdge(state GameState) bool {
	if s.Head.Y == state.Board.Height-1 {
		return true
	}
	return false
}

func (s Battlesnake) onBottomEdge() bool {
	if s.Head.Y == 0 {
		return true
	}
	return false
}

func (s Battlesnake) onEdge(state GameState) bool {
	if s.onLeftEdge() || s.onRightEdge(state) || s.onTopEdge(state) || s.onBottomEdge() {
		return true
	}
	return false
}

func (s Battlesnake) inBottomLeft() bool {
	if s.Head.X == 0 && s.Head.Y == 0 {
		return true
	}
	return false
}

func (s Battlesnake) inBottomRight(state GameState) bool {
	if s.Head.X == state.Board.Width-1 && s.Head.Y == 0 {
		return true
	}
	return false
}

func (s Battlesnake) inTopLeft(state GameState) bool {
	if s.Head.X == 0 && s.Head.Y == state.Board.Height-1 {
		return true
	}
	return false
}

func (s Battlesnake) inTopRight(state GameState) bool {
	if s.Head.X == state.Board.Width-1 && s.Head.Y == state.Board.Height-1 {
		return true
	}
	return false
}

func (s Battlesnake) ownSnake(state GameState) bool {
	if s.ID == state.You.ID {
		return true
	}
	return false
}

// is not us
func (s Battlesnake) isEnemySnake(state GameState) bool {
	if s.ID != state.You.ID {
		return true
	}
	return false
}

//func to check if a snake is on the opposite side of the board to coord
func (s Battlesnake) onOppositeSide(coord Coord, state GameState) bool {
	if coord.onLeftEdge() && s.onRightEdge(state) && coord.Y == s.Head.Y {
		return true
	}
	if coord.onRightEdge(state) && s.onLeftEdge() && coord.Y == s.Head.Y {
		return true
	}
	if coord.onTopEdge(state) && s.onBottomEdge() && coord.X == s.Head.X {
		return true
	}
	if coord.onBottomEdge() && s.onTopEdge(state) && coord.X == s.Head.X {
		return true
	}
	if coord.inBottomLeft() && (s.inBottomRight(state) || s.inTopLeft(state)) {
		return true
	}
	if coord.inBottomRight(state) && (s.inBottomLeft() || s.inTopRight(state)) {
		return true
	}
	if coord.inTopLeft(state) && (s.inBottomLeft() || s.inTopRight(state)) {
		return true
	}
	if coord.inTopRight(state) && (s.inBottomRight(state) || s.inTopLeft(state)) {
		return true
	}
	return false
}

//func to check if a snake is larger than our own snake
func (s Battlesnake) isLargerThanUs(state GameState) bool {
	if s.Length >= state.You.Length {
		return true
	}
	return false
}

// Keep track of each snake's length between turns. 
// We use this to determine if a snake ate food or not.
var snakeHealths = make(map[string]int)

// Function that takes in a state and clears the snakeHealths map.
func clearSnakeHealths(state GameState) {
	if state.Turn <= 3 {
		snakeHealths = make(map[string]int)
		updateSnakeHealth(state)
	}
}

// Function to check if a snake ate food on the previous turn. 
func didSnakeEatFood(snake Battlesnake, state GameState) bool {
	// If the snakes health is greater than the previous turn, they ate food.
	if int(snake.Health) >= snakeHealths[snake.ID] && state.Turn != 0 {
		return true
	} 

	return false
}

// Function to loop through all snakes and update their health.
func updateSnakeHealth(state GameState) {
	for _, snake := range state.Board.Snakes {
		snakeHealths[snake.ID] = int(snake.Health)
	}
}
