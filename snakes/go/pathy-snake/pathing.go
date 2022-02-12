package main

import (
	"log"
	"math/rand"
)

// TODO: #121 Make it so we don't pick a destination cell that is in a hazard.
// TODO: #122 Add some aggressive snake logic. i.e. adjust the cost of cells next to snake heads differently if they are smaller than us.
// TODO: Move the targetCell logic into its own function.
// TODO: I notice errors/panics sometimes when we can't decide on a targetCell. We need to account for those cases.

// function that creates a new grid from that contains all the snakes body parts as not walkable.
func createSnakeMap(state GameState) BattlesnakeMoveResponse {
	// Create a new grid with the size of the game board.
	//log.Printf("Creating Snake Map")
	grid := NewGrid(state.Board.Width, state.Board.Height, 0, 0)
	// Add snakes to the grid.
	addSnakesToGrid(state, grid)
	// Add food to the grid.
	addFoodToGrid(state, grid)
	// Change the hazards cost to a higher value.
	changeHazardsCost(state, grid)
	// Print the grid to the console. Useful for debugging.
	// printGrid(state, grid)
	// Get the path from the head to a destination cell. Destination cell is determined in the getPath function.
	path := getPath(state, grid)
	// Return the next move (left, right, up, down) based on the path previously calculated.
	return getNextDirection(state, path)
}

// Add snakes to the grid as not walkable.
func addSnakesToGrid(state GameState, grid *Grid) {
	// Iterate over all the snakes in the game state.
	for _, snake := range state.Board.Snakes {
		// Iterate over all the body parts of the snake.
		for _, bodyPart := range snake.Body {
			// Set the body part to not be walkable.
			grid.Get(bodyPart.X, bodyPart.Y).Walkable = false
		}
	}
	// Iterrate over all the the other snakes heads.
	for _, otherSnake := range state.Board.Snakes {
		if otherSnake.ID != state.You.ID {
			// Check that other snake is on the edge of the board.
			// Added to avoid panics (out of bounds) when the head is at the edge of the board.
			// Then set the cost of the cells next to the head to higher cost.
			if otherSnake.Head.X-1 >= 0 {
				// If the snake is longer than us, then we want to avoid walking on cells next to their heads.
				if otherSnake.Length >= state.You.Length {
					grid.Get(otherSnake.Head.X-1, otherSnake.Head.Y).Walkable = false
				} else {
					grid.Get(otherSnake.Head.X-1, otherSnake.Head.Y).Cost = 1.5
				}
			}
			if otherSnake.Head.X+1 <= state.Board.Width-1 {
				if otherSnake.Length >= state.You.Length {
					grid.Get(otherSnake.Head.X+1, otherSnake.Head.Y).Walkable = false
				} else {
					grid.Get(otherSnake.Head.X+1, otherSnake.Head.Y).Cost = 1.5
				}
			}
			if otherSnake.Head.Y-1 >= 0 {
				if otherSnake.Length >= state.You.Length {
					grid.Get(otherSnake.Head.X, otherSnake.Head.Y-1).Walkable = false
				} else {
					grid.Get(otherSnake.Head.X, otherSnake.Head.Y-1).Cost = 1.5
				}
			}
			if otherSnake.Head.Y+1 <= state.Board.Height-1 {
				if otherSnake.Length >= state.You.Length {
					grid.Get(otherSnake.Head.X, otherSnake.Head.Y+1).Walkable = false
				} else {
					grid.Get(otherSnake.Head.X, otherSnake.Head.Y+1).Cost = 1.5
				}
			}
			// If the snakes head is on the edge of the board.
			// We want to set the cells opposite to the head to not be walkable.
			if onEdge(otherSnake.Head.X, otherSnake.Head.Y, state.Board.Width, state.Board.Height) {
				if otherSnake.Head.X == 0 {
					if otherSnake.Length >= state.You.Length {
						grid.Get(state.Board.Width-1, otherSnake.Head.Y).Walkable = false
					} else {
						grid.Get(state.Board.Width-1, otherSnake.Head.Y).Cost = 1.5
					}
				}
				if otherSnake.Head.X == state.Board.Width-1 {
					if otherSnake.Length >= state.You.Length {
						grid.Get(0, otherSnake.Head.Y).Walkable = false
					} else {
						grid.Get(0, otherSnake.Head.Y).Cost = 1.5
					}
				}
				if otherSnake.Head.Y == 0 {
					if otherSnake.Length >= state.You.Length {
						grid.Get(otherSnake.Head.X, state.Board.Height-1).Walkable = false
					} else {
						grid.Get(otherSnake.Head.X, state.Board.Height-1).Cost = 1.5
					}
				}
				if otherSnake.Head.Y == state.Board.Height-1 {
					if otherSnake.Length >= state.You.Length {
						grid.Get(otherSnake.Head.X, 0).Walkable = false
					} else {
						grid.Get(otherSnake.Head.X, 0).Cost = 1.5
					}
				}
			}
		}
	}
	// Make sure our own head is walkable. We need to do this because the getPath function
	// would not find a path if our head was not walkable.
	grid.Get(state.You.Head.X, state.You.Head.Y).Walkable = true

	// If we did not eat food on the previous turn, we can make our tail walkable.
	if state.Turn > 3 {
		if !checkIfAteFood(state) {
			// Make sure our tail is walkable.
			grid.Get(state.You.Body[len(state.You.Body)-1].X, state.You.Body[len(state.You.Body)-1].Y).Walkable = true
		}
	}
}

// Add food to the grid as walkable but with lower cost.
func addFoodToGrid(state GameState, grid *Grid) {
	// Iterate over all the food in the game state.
	for _, food := range state.Board.Food {
		// Set the food cell to a lower cost.
		grid.Get(food.X, food.Y).Cost = .5
	}
}

//Function to change the hazards from GameState cost to a higher value.
func changeHazardsCost(state GameState, grid *Grid) {
	// Iterate over all the hazards in the game state.
	for _, hazard := range state.Board.Hazards {
		// Set the hazard cell cost to a higher value.
		grid.Get(hazard.X, hazard.Y).Cost = 5
	}
}

// Function to print the grid to the console.
func printGrid(state GameState, grid *Grid) {
	// Print the grid to the console.
	log.Println(grid)
}

// Function used to GetPath the best path from Head.
// There is or may be quite a lot of logic in this function that we use to determine the best path.
// In most cases we pick a destination cell that is walkable and reachable.
// If we are low on health we want to move towards food.
// If we are in the center of the board we want to move towards the bottom left corner.
// The tragetCell logic should probably be moved to a different function.
func getPath(state GameState, grid *Grid) *Path {
	// Get the path from the grid using the GetPath function.
	// If game mode is wrapped set a bool to true else set it to false.
	var wrapped bool
	if state.Game.Ruleset.Name == "wrapped" {
		wrapped = true
	} else {
		wrapped = false
	}
	var targetCell *Cell
	if state.You.Head.Y < (state.Board.Height / 2) {
		// Create a list of walkable cells in the top half of the board.
		// Iterate over all the cells in the top half of the board.
		var walkableCells []*Cell
		for x := 0; x < state.Board.Width; x++ {
			for y := state.Board.Height / 2; y < state.Board.Height; y++ {
				if grid.Get(x, y).Walkable {
					// If we can create a path to the cell, add it to the list.
					// If GetPathFromCells returns an error, then don't add the cell to the list.
					if grid.GetPathFromCells(grid.Get(state.You.Head.X, state.You.Head.Y), grid.Get(x, y), false, false, wrapped).Next() != nil {
						walkableCells = append(walkableCells, grid.Get(x, y))
					}
				}
			}
			if len(walkableCells) > 0 {
				targetCell = walkableCells[rand.Intn(len(walkableCells))]
			} else {
				log.Printf("No walkable cells in top half of board.\n")
			}
		}
	} else {
		// Create a list of walkable cells in the bottom half of the board.
		// Iterate over all the cells in the bottom half of the board.
		var walkableCells []*Cell
		for x := 0; x < state.Board.Width; x++ {
			for y := 0; y < state.Board.Height/2; y++ {
				if grid.Get(x, y).Walkable {
					// If we can create a path to the cell, add it to the list.
					// If GetPathFromCells returns an error, then don't add the cell to the list.
					if grid.GetPathFromCells(grid.Get(state.You.Head.X, state.You.Head.Y), grid.Get(x, y), false, false, wrapped).Next() != nil {
						walkableCells = append(walkableCells, grid.Get(x, y))
					}
				}
			}
		}
		if len(walkableCells) > 0 {
			targetCell = walkableCells[rand.Intn(len(walkableCells))]
		} else {
			log.Printf("No walkable cells in bottom half of board.\n")
		}
	}

	// If we are in the middle of the grid then pick a target cell that is not the opposite of the head.
	if state.You.Head.X == state.Board.Height/2 && state.You.Head.Y == state.Board.Width/2 {
		// Set targetCell X and Y to be the bottom left corner of the grid.
		targetCell.X = state.Board.Height - 1
		targetCell.Y = state.Board.Width - 1
	}

	// If our health is less than 85 we want to set our target cell to be the coordinates of the closest food.
	if state.You.Health < 85 && len(state.Board.Food) > 0 {
		// Iterate over all the food in the game state.
		var targetFoodCell []*Cell
		for _, food := range state.Board.Food {
			// Continue if food not walkable.
			if !grid.Get(food.X, food.Y).Walkable {
				continue
			}
			// Find the cell closest to our head and set it to targetCell.
			if grid.GetPathFromCells(grid.Get(state.You.Head.X, state.You.Head.Y), grid.Get(food.X, food.Y), false, false, wrapped).Next() != nil {
				targetFoodCell = append(targetFoodCell, grid.Get(food.X, food.Y))
			}
		}
		// If we have more than one food, then pick the closest food to our head via manhattan distance.
		if len(targetFoodCell) >= 1 {
			// Iterate over all the food in the game state.
			// Keep track of the one that is closest to our head.
			var closestFoodCell *Cell
			var closestDistance int
			for _, food := range state.Board.Food {
				// Skip the food if it is isNextToLarger.
				if isNextToLarger(food.X, food.Y, state) || isSurrounded(food.X, food.Y, state) {
					continue
				}
				// Get the manhattan distance between the head and the food.
				distance := abs(food.X-state.You.Head.X) + abs(food.Y-state.You.Head.Y)
				// If the distance is less than the closest distance, then set the food to be the closest food.
				if distance < closestDistance || closestDistance == 0 {
					closestDistance = distance
					closestFoodCell = grid.Get(food.X, food.Y)
				}
			}
			// Set the target cell to be the closest food cell.
			targetCell = closestFoodCell
		}
	}

	// If we don't have a target cell, we can't get a path.
	// Attempt to get a targetCell from anywhere on the board.
	var walkableCells []*Cell
	if targetCell == nil {
		for x := 0; x < state.Board.Width; x++ {
			for y := 0; y < state.Board.Height; y++ {
				if grid.Get(x, y).Walkable {
					// If we can create a path to the cell, add it to the list.
					// If GetPathFromCells returns an error, then don't add the cell to the list.
					if grid.GetPathFromCells(grid.Get(state.You.Head.X, state.You.Head.Y), grid.Get(x, y), false, false, wrapped).Next() != nil {
						walkableCells = append(walkableCells, grid.Get(x, y))
					}
				}
			}
		}
		if len(walkableCells) > 0 {
			targetCell = walkableCells[rand.Intn(len(walkableCells))]
		} else {
			log.Printf("No walkable cells or paths anywhere on board.\n")
		}
	}

	path := grid.GetPathFromCells(grid.Get(state.You.Head.X, state.You.Head.Y), grid.Get(targetCell.X, targetCell.Y), false, false, wrapped)

	// Print the path and related points to the console. Useful for debugging.
	/*
		log.Printf("Target Cell: %v", targetCell)
		log.Printf("Head Coordinates")
		log.Println(state.You.Head.X, state.You.Head.Y)
		log.Printf("Target Coordinates")
		log.Println(targetCell.X, targetCell.Y)
		log.Printf("This is the path")
		log.Println(path)
		log.Println(path.Current())
		log.Println(path.Next().X, path.Next().Y)
		log.Println(getNextDirection(state, path))
	*/

	return path
}

// Function that returns the next direction to move based on the path we get from getPath.
func getNextDirection(state GameState, path *Path) BattlesnakeMoveResponse {
	var nextMove string
	// Return left if the next cell is to the left of the head.
	if path.Current().X < path.Next().X && path.Current().Y == path.Next().Y {
		// If we are wrapping around the grid, then we want to move left.
		if path.Current().X == 0 && path.Next().X == state.Board.Width-1 {
			nextMove = "left"
		} else {
			nextMove = "right"
		}
	}
	// Return right if the next cell is to the right of the head.
	if path.Current().X > path.Next().X && path.Current().Y == path.Next().Y {
		// If we are wrapping around the grid, then we want to move right.
		if path.Current().X == state.Board.Width-1 && path.Next().X == 0 {
			nextMove = "right"
		} else {
			nextMove = "left"
		}
	}
	// Return up if the next cell is above the head.
	if path.Current().X == path.Next().X && path.Current().Y < path.Next().Y {
		// If we are wrapping around the grid, then we want to move up.
		if path.Current().Y == 0 && path.Next().Y == state.Board.Height-1 {
			nextMove = "down"
		} else {
			nextMove = "up"
		}
	}
	// Return down if the next cell is below the head.
	if path.Current().X == path.Next().X && path.Current().Y > path.Next().Y {
		// If we are wrapping around the grid, then we want to move down.
		if path.Current().Y == state.Board.Height-1 && path.Next().Y == 0 {
			nextMove = "up"
		} else {
			nextMove = "down"
		}
	}
	return BattlesnakeMoveResponse{
		Move: nextMove,
	}
}

// Keep track of our size between turns. We want to use this to determine if we ate food or not.
var prevLength int

// Function that determines if we ate food on the previous turn.
func checkIfAteFood(state GameState) bool {
	// If the snakes body size is greater than the previous turn size, we ate food.
	var ate bool
	if len(state.You.Body) > prevLength && state.Turn != 0 {
		ate = true
	} else {
		ate = false
	}
	
	// This is used for tests of this function only. 
	// We shouldn't ever see a Turn of 999999 in a real game.
	if state.Turn == 9999999 {
		ate = false
	}
	
	// Set prevLength to current snakes body size for use in next turn.
	prevLength = len(state.You.Body)
	return ate
}
