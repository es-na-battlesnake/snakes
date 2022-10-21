package main

// This file contains helper functions for the starter-snake project.

import (
	"log"
	"strings"
	"strconv"
)

// This function helps ensure that user input is clearly marked in log entries, and that
// a malicious user cannot cause confusion in other ways. Intended to be used with log.Printf.
func sanatizeInput(s string) string {
	escapedInput := strings.Replace(s, "\n", "", -1)
	escapedInput = strings.Replace(escapedInput, "\r", "", -1)
	return escapedInput
}

// This function helps ensure that user input is clearly marked in log entries, and that
// a malicious user cannot cause confusion in other ways. Intended to be used with log.Printf.
// Should log an int only any where we log `state.Turn`. 
// Added to try and clear up a codeql security flag. Its seems redundant but will leave it for now. 
func isNumber(i int) int {
	// convert i to string and then sanatize it with the sanatizeInput function.
	s := strconv.Itoa(i)
	s = sanatizeInput(s)
	// convert the sanatized string back to an int.
	i, err := strconv.Atoi(s)
	if err != nil {
		log.Println("Error converting to int")
	}
	// if i divded by 1 is equal to i, then i is a number and return that.
	if i/1 == i {
		return i
	} else {
		// 0000 is meant to represent and error. Meaning we received a turn that was not a number.
		return 0000
	}
}

// This function returns the absolute value of an int.
func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// This function is used to check if a snake head x,y coord is on the edge of the board.
func onEdge(x int, y int, width int, height int) bool {
	if x == 0 || x == width-1 || y == 0 || y == height-1 {
		return true
	}
	return false
}

// Function that looks to see if a coord is in the snake.Body
func snakeContains(body []Coord, coord Coord) bool {
	for _, bodyCoord := range body {
		if bodyCoord == coord {
			return true
		}
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

func (c Coord) onBottomEdge() bool {
	if c.Y == 0 {
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

func (g GameState) wrapped() bool {
	if g.Game.Ruleset.Name == "wrapped" {
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

func isNextToSnakeHead(coord Coord, state GameState) bool {
	// get the four cells around us.
	above := Coord{X: coord.X, Y: coord.Y + 1}
	below := Coord{X: coord.X, Y: coord.Y - 1}
	left := Coord{X: coord.X - 1, Y: coord.Y}
	right := Coord{X: coord.X + 1, Y: coord.Y}
	// check if above, below, left, or right is occupied by a snake.
	for _, snake := range state.Board.Snakes {
		// skip if the snake is us.
		if snake.ownSnake(state) || snake.Length < state.You.Length {
			continue
		}
		// check if the snake is above, below, left, or right of us.
		if snake.Head == above || snake.Head == below || snake.Head == left || snake.Head == right {
			return true
		}
		if state.wrapped() && onEdge(coord.X, coord.Y, state.Board.Width, state.Board.Height) {
			if coord.onLeftEdge() && snake.onRightEdge(state.Board.Width) && snake.Head.Y == coord.Y {
				return true
			}
			if coord.onRightEdge(state.Board.Width) && snake.onLeftEdge() && snake.Head.Y == coord.Y {
				return true
			}
			if coord.onTopEdge(state.Board.Height) && snake.onBottomEdge() && snake.Head.X == coord.X{
				return true
			}
			if coord.onBottomEdge() && snake.onTopEdge(state.Board.Height) && snake.Head.X == coord.X {
				return true
			}
			if coord.inBottomLeft() && (snake.inBottomRight(state.Board.Width) || snake.inTopLeft(state.Board.Height)) {
				return true
			}
			if coord.inBottomRight(state.Board.Width) && (snake.inBottomLeft() || snake.inTopRight(state.Board.Width, state.Board.Height)) {
				return true
			}
			if coord.inTopLeft(state.Board.Height) && (snake.inTopRight(state.Board.Width, state.Board.Height) || snake.inBottomLeft()) {
				return true
			}
			if coord.inTopRight(state.Board.Width, state.Board.Height) && (snake.inTopLeft(state.Board.Height) || snake.inBottomRight(state.Board.Width)) {
				return true
			}
		}
	}
	return false
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

// function to imulate contains for an array  of coords.
func containsCoord(array []Coord, coord Coord) bool {
	for _, c := range array {
		if c == coord {
			return true
		}
	}
	return false
}

// This function takes in an coord and tells returns true if the cell is surrounded by snake body parts. 
func isSurrounded(coord Coord, state GameState) bool {
	surroundingCells := []Coord{coord.cellAbove(state.Board.Height), coord.cellBelow(state.Board.Height), coord.cellLeft(state.Board.Width), coord.cellRight(state.Board.Width)}
	// print the surrounding cells.
	var snakeBodyParts []Coord
	for _, snake := range state.Board.Snakes {
		for _, bodyPart := range snake.Body {
			snakeBodyParts = append(snakeBodyParts, bodyPart)
		}
	}
	for _, cell := range surroundingCells {
		if !containsCoord(snakeBodyParts, cell) {
			return false		
		}
	}
	return true
}
