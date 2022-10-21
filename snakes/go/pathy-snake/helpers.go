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

// Function that looks to see if a coord is in the snake.Body
func snakeContains(body []Coord, coord Coord) bool {
	for _, bodyCoord := range body {
		if bodyCoord == coord {
			return true
		}
	}
	return false
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
