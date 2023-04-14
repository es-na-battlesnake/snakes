package main

// This file contains helper functions for the starter-snake project.

import (
	"log"
	"strings"
	"strconv"
	"math/rand"
)

// This function helps ensure that user input is clearly marked in log entries, and that
// a malicious user cannot cause confusion in other ways. Intended to be used with log.Printf.
func sanatizeInput(s string) string {
	escapedInput := strings.Replace(s, "\n", "", -1)
	escapedInput = strings.Replace(escapedInput, "\r", "", -1)
	return escapedInput
}

// Function to print the grid to the console.
func printGrid(state GameState, grid *Grid) {
	// Print the grid to the console.
	log.Println(grid)
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
	} 

	return 0000
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

// function to choose a target cell from an array of grid cells
func chooseTargetCell(state GameState, grid *Grid, walkableCells []*Cell) *Cell {
    if len(walkableCells) == 0 {
        log.Printf("No walkable cells or paths anywhere on board.\n")
        return nil
    }

    maxArea := 0
    bestCell := walkableCells[0]

    for _, cell := range walkableCells {
        visited := make(map[*Cell]bool)
        area := floodFill(state, grid, cell, visited)

        if area > maxArea {
            maxArea = area
            bestCell = cell
        }
    }

    return bestCell
}
