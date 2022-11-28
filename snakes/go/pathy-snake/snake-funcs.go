package main

func (s Battlesnake) onLeftEdge() bool {
	return s.Head.X == 0
}

func (s Battlesnake) onRightEdge(state GameState) bool {
	return s.Head.X == state.Board.Width-1
}

func (s Battlesnake) onTopEdge(state GameState) bool {
	return s.Head.Y == state.Board.Height-1
}

func (s Battlesnake) onBottomEdge() bool {
	return s.Head.Y == 0
}

func (s Battlesnake) onEdge(state GameState) bool {
	return s.onLeftEdge() || s.onRightEdge(state) || s.onTopEdge(state) || s.onBottomEdge()
}

func (s Battlesnake) inBottomLeft() bool {
	return s.Head.X == 0 && s.Head.Y == 0
}

func (s Battlesnake) inBottomRight(state GameState) bool {
	return s.Head.X == state.Board.Width-1 && s.Head.Y == 0
}

func (s Battlesnake) inTopLeft(state GameState) bool {
	return s.Head.X == 0 && s.Head.Y == state.Board.Height-1
}

func (s Battlesnake) inTopRight(state GameState) bool {
	return s.Head.X == state.Board.Width-1 && s.Head.Y == state.Board.Height-1
}

func (s Battlesnake) ownSnake(state GameState) bool {
	return s.ID == state.You.ID
}

// is not us
func (s Battlesnake) isEnemySnake(state GameState) bool {
	return s.ID != state.You.ID
}

//func to check if a snake is on the opposite side of the board to coord
func (s Battlesnake) onOppositeSide(coord Coord, state GameState) bool {
	if coord.Y == s.Head.Y && (coord.onLeftEdge() && s.onRightEdge(state) || coord.onRightEdge(state) && s.onLeftEdge()) {
		return true
	}
	if coord.X == s.Head.X && (coord.onTopEdge(state) && s.onBottomEdge() || coord.onBottomEdge() && s.onTopEdge(state)) {
		return true
	}
	if (coord.inBottomLeft() || coord.inTopRight(state)) && (s.inBottomRight(state) || s.inTopLeft(state)) {
		return true
	}
	if (coord.inBottomRight(state) || coord.inTopLeft(state)) && (s.inBottomLeft() || s.inTopRight(state)) {
		return true
	}
	return false
}

//func to check if a snake is larger than our own snake
func (s Battlesnake) isLargerThanUs(state GameState) bool {
	return s.Length >= state.You.Length
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
	return int(snake.Health) >= snakeHealths[snake.ID] && state.Turn != 0
}

// Function to loop through all snakes and update their health.
func updateSnakeHealth(state GameState) {
	for _, snake := range state.Board.Snakes {
		snakeHealths[snake.ID] = int(snake.Health)
	}
}
