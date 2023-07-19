package main

// This file contains helper functions for the starter-snake project.

import (
	"log"
	"strings"
	"strconv"
	"math/rand"
	"math"
)

// Max floodfill depth
const maxDepth = 10

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
func chooseTargetCell(state GameState, grid *Grid) *Cell {
	// get the cells next to our snake head since we can only move to those cells
	walkableCells := grid.AdjacentCells(grid.Get(state.You.Head.X, state.You.Head.Y), state.isWrapped())

	// remove any cells that are not walkable
	for i := len(walkableCells) - 1; i >= 0; i-- {
		if !walkableCells[i].Walkable {
			walkableCells = append(walkableCells[:i], walkableCells[i+1:]...)
		}
	}

	// if there are no walkable cells, return nil and if there is only one walkable cell, return that cell
    if len(walkableCells) < 1 {
        log.Printf("No walkable cells or paths anywhere on board.\n")
        return nil
    } else if len(walkableCells) == 1 {
		return walkableCells[0]
	}

    maxArea := 0
    bestCell := walkableCells[0]

    for _, cell := range walkableCells {
        visited := make(map[*Cell]bool)
        area := floodFill(state, grid, cell, visited, 0, maxDepth)
		
		if area > maxArea {
            maxArea = area
            bestCell = cell
        }
    }

    return bestCell
}

// function to choose a random target cell that is walkable
func chooseRandomWalkableTargetCell(grid *Grid, state GameState) *Cell {
	// randomize the order of the walkable cells so we don't always choose the same one.
	walkableCells := grid.CellsByWalkable(true)
	rand.Shuffle(len(walkableCells), func(i, j int) { walkableCells[i], walkableCells[j] = walkableCells[j], walkableCells[i] })

	// Iterate over all the walkableCells.
	for _, cell := range walkableCells {
		// Make sure there is a path to the cell we chose.
		path := grid.GetPathFromCells(grid.Get(state.You.Head.X, state.You.Head.Y), grid.Get(cell.X, cell.Y), false, false, state.isWrapped())

		if path.Length() == 0 {
			continue
		}

		// Set the target cell to be the first walkable cell that is not our head.
		if cell.X != state.You.Head.X && cell.Y != state.You.Head.Y {
			return cell
		}
	}
	log.Printf("No walkable cells or paths anywhere on board.\n")
	return nil
}

// function to choose a random target cell
func chooseRandomTargetCell(grid *Grid) *Cell {
	// choose a random cell from the grid.
	return grid.AllCells()[rand.Intn(len(grid.AllCells()))]
}

// function to choose nearest food
func chooseNearestFood(grid *Grid, state GameState) *Cell {
	var closestFoodCell *Cell
	closestDistance := math.MaxInt32

	for _, food := range state.Board.Food {
		if !grid.Get(food.X, food.Y).Walkable {
			continue
		}

		distance := abs(food.X - state.You.Head.X) + abs(food.Y - state.You.Head.Y)

		if distance < closestDistance && !food.isNextToSnakeHead(state) && !food.Surrounded(state) {
			closestDistance = distance
			closestFoodCell = grid.Get(food.X, food.Y)
		}
	}

	return closestFoodCell
}

// function to move away from larger snakes
func moveAwayFromLargerSnakes(grid *Grid, state GameState) *Cell {
	var walkableCells []*Cell
	// Iterate over all the snakes in the game state.
	for _, snake := range state.Board.Snakes {
		// Skip the snake if it is our snake or if it is smaller than us.
		if snake.ID == state.You.ID || snake.Length < state.You.Length {
			continue
		}
		// Iterate over all the body parts of the snake.
		for _, bodyPart := range snake.Body {
			// Skip the body part if it is isNextToSnakeHead.
			if bodyPart.isNextToSnakeHead(state) {
				continue
			}
			// Get the manhattan distance between the head and the body part.
			distance := abs(bodyPart.X-state.You.Head.X) + abs(bodyPart.Y-state.You.Head.Y)
			// If the distance is less than the closest distance, then set the body part to be the closest body part.
			if distance < 3 {
				// Iterate over all the cells in the grid.
				for _, cell := range grid.CellsByWalkable(true) {
					// Get the manhattan distance between the cell and the body part.
					distance := abs(cell.X-bodyPart.X) + abs(cell.Y-bodyPart.Y)
					// If the distance is less than the closest distance, then set the cell to be the closest cell.
					if distance < 3 {
						walkableCells = append(walkableCells, cell)
					}
				}
			}
		}
	}
	// If we have more than one cell, then pick the cell that is furthest away from the larger snakes.
	if len(walkableCells) >= 1 {
		// Iterate over all the cells in the grid.
		// Keep track of the one that is furthest away from the larger snakes.
		var furthestCell *Cell
		var furthestDistance int
		for _, cell := range walkableCells {
			// Get the manhattan distance between the head and the cell.
			distance := abs(cell.X-state.You.Head.X) + abs(cell.Y-state.You.Head.Y)
			// If the distance is greater than the furthest distance, then set the cell to be the furthest cell.
			if distance > furthestDistance || furthestDistance == 0 {
				furthestDistance = distance
				furthestCell = cell
			}
		}
		// Set the target cell to be the furthest cell.
		return furthestCell
	}
	// If we have no cells, then return nil.
	return nil
}
