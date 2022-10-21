package main

func (s Battlesnake) onLeftEdge() bool {
	if s.Head.X == 0 {
		return true
	}
	return false
}

func (s Battlesnake) onRightEdge(width int) bool {
	if s.Head.X == width-1 {
		return true
	}
	return false
}

func (s Battlesnake) onTopEdge(height int) bool {
	if s.Head.Y == height-1 {
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

func (s Battlesnake) inBottomLeft() bool {
	if s.Head.X == 0 && s.Head.Y == 0 {
		return true
	}
	return false
}

func (s Battlesnake) inBottomRight(width int) bool {
	if s.Head.X == width-1 && s.Head.Y == 0 {
		return true
	}
	return false
}

func (s Battlesnake) inTopLeft(height int) bool {
	if s.Head.X == 0 && s.Head.Y == height-1 {
		return true
	}
	return false
}

func (s Battlesnake) inTopRight(width int, height int) bool {
	if s.Head.X == width-1 && s.Head.Y == height-1 {
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