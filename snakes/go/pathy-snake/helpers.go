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

// This function takes and x,y coord and tells us if there is a snake next to it larger than us. 
func isNextToLarger(x int, y int, state GameState) bool {
	// check if there is a snake next to us that is larger than us.
	for _, snake := range state.Board.Snakes {
		// if the snake is us, skip it.
		if snake.ID == state.You.ID {
			continue
		}
		// if the snake is smaller than us, skip it.
		if snake.Length < state.You.Length {
			continue
		}
		// Check if the snake is to the left, right, above, or below us.
		if snake.Head.X == x-1 && snake.Head.Y == y {
			return true
		}
		if snake.Head.X == x+1 && snake.Head.Y == y {
			return true
		}
		if snake.Head.X == x && snake.Head.Y == y-1 {
			return true
		}
		if snake.Head.X == x && snake.Head.Y == y+1 {
			return true
		}		
		if state.Game.Ruleset.Name == "wrapped" {
			if onEdge(x, y, state.Board.Width, state.Board.Height) {
				if x == 0 && snake.Head.X == state.Board.Width-1 && snake.Head.Y == y {
					return true
				}
				if x == state.Board.Width-1 && snake.Head.X == 0 && snake.Head.Y == y {
					return true
				}
				if y == 0 && snake.Head.X == x && snake.Head.Y == state.Board.Height-1 {
					return true
				}
				if y == state.Board.Height-1 && snake.Head.X == x && snake.Head.Y == 0 {
					return true
				}
				// Do the same but check the corners.
				if x == 0 && y == 0 {
					if snake.Head.X == state.Board.Width-1 && snake.Head.Y == y {
						return true
					}
					if snake.Head.X == x && snake.Head.Y == state.Board.Height-1 {
						return true
					}
				}
				if x == state.Board.Width-1 && y == 0 {
					if snake.Head.X == 0 && snake.Head.Y == y {
						return true
					}
					if snake.Head.X == x && snake.Head.Y == state.Board.Height-1 {
						return true
					}
				}
				if x == 0 && y == state.Board.Height-1 {
					if snake.Head.X == state.Board.Width-1 && snake.Head.Y == y {
						return true
					}
					if snake.Head.X == x && snake.Head.Y == 0 {
						return true
					}
				}
				if x == state.Board.Width-1 && y == state.Board.Height-1 {
					if snake.Head.X == 0 && snake.Head.Y == y {
						return true
					}
					if snake.Head.X == x && snake.Head.Y == 0 {
						return true
					}
				}
			}
		}	
	}
	return false
}

// This function takes in an x,y coord and tells us if the cell is surrounded by snake body parts. 
func isSurrounded(x int, y int, state GameState) bool {
	// Get the x and y of each neighboring cell as a coord
	// If the coord is not on the edge of the board.
	var left, right, up, down Coord
	if onEdge(x, y, state.Board.Width, state.Board.Height) {
		// Set x and y based on where we are on the board.
		if x == 0 {
			left = Coord{X: state.Board.Width - 1, Y: y}
			right = Coord{X: x + 1, Y: y}
			up = Coord{X: x, Y: y + 1}
			down = Coord{X: x, Y: y - 1}
		}
		if x == state.Board.Width-1 {
			left = Coord{X: x - 1, Y: y}
			right = Coord{X: 0, Y: y}
			up = Coord{X: x, Y: y + 1}
			down = Coord{X: x, Y: y - 1}
		}
		if y == 0 {
			left = Coord{X: x - 1, Y: y}
			right = Coord{X: x + 1, Y: y}
			up = Coord{X: x, Y: y + 1}
			down = Coord{X: x, Y: state.Board.Height - 1}
		}
		if y == state.Board.Height-1 {
			left = Coord{X: x - 1, Y: y}
			right = Coord{X: x + 1, Y: y}
			up = Coord{X: x, Y: y - 1}
			down = Coord{X: x, Y: 0}
		}
		// Add statements for each of the four corners.
		if x == 0 && y == 0 {
			left = Coord{X: state.Board.Width - 1, Y: y}
			right = Coord{X: x + 1, Y: y}
			up = Coord{X: x, Y: y + 1}
			down = Coord{X: x, Y: state.Board.Height - 1}
		}
		if x == 0 && y == state.Board.Height-1 {
			left = Coord{X: state.Board.Width - 1, Y: y}
			right = Coord{X: x + 1, Y: y}
			up = Coord{X: 0, Y: 0}
			down = Coord{X: x, Y: y - 1}
		}
		if x == state.Board.Width-1 && y == 0 {
			left = Coord{X: x - 1, Y: y}
			right = Coord{X: 0, Y: y}
			up = Coord{X: x, Y: y + 1}
			down = Coord{X: x, Y: state.Board.Height - 1}
		}
		if x == state.Board.Width-1 && y == state.Board.Height-1 {
			left = Coord{X: x - 1, Y: y}
			right = Coord{X: 0, Y: y}
			up = Coord{X: x, Y: 0}
			down = Coord{X: x, Y: y - 1}
		}
	} else {
		left = Coord{x - 1, y}
		right = Coord{x + 1, y}
		up = Coord{x, y + 1}
		down = Coord{x, y - 1}
	}
	// Check if each neighboring cell is a snake body part.
	for _, snake := range state.Board.Snakes {
		// Check if the snake.Body object contains the left, right, up, and down coords.
		if snakeContains(snake.Body, left) && snakeContains(snake.Body, right) && snakeContains(snake.Body, up) && snakeContains(snake.Body, down) {
			return true
		}
	}
	return false
}




