package main

// TODO: #121 Make it so we don't pick a destination cell that is in a hazard.
// TODO: #122 Add some aggressive snake logic. i.e. adjust the cost of cells next to snake heads differently if they are smaller than us.

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
	// Get the path from the head to a destination cell.
	path := getPath(state, grid)
	// Return the next move (left, right, up, down) based on the path previously calculated.
	return getNextDirection(state, path)
}

func addSnakesToGrid(state GameState, grid *Grid) {
	// Iterate over all the snakes in the game state.
	for _, snake := range state.Board.Snakes {
		// Iterate over all the body parts of the snake.
		for _, bodyPart := range snake.Body {
			// Set the body part to not be walkable.
			grid.Get(bodyPart.X, bodyPart.Y).Walkable = false
		}
	}

	// Clear any snake health map that might exist between games.
	clearSnakeHealths(state)
	// If a snake did not eat food on the previous turn, we can make their tail walkable.
	if state.Turn > 3 {
		for _, otherSnake := range state.Board.Snakes {
			if !didSnakeEatFood(otherSnake, state) {
				// Make sure their tail is walkable.
				grid.Get(otherSnake.Body[len(otherSnake.Body)-1].X, otherSnake.Body[len(otherSnake.Body)-1].Y).Walkable = true
			}
		}
		// Update each snakes health with the health from this turn.
		updateSnakeHealth(state)
	}

	// Iterrate over all the the other snakes heads.
	for _, otherSnake := range state.Board.Snakes {
		if otherSnake.ID != state.You.ID {
			left := otherSnake.Head.cellLeft(state)
			right := otherSnake.Head.cellRight(state)
			above := otherSnake.Head.cellAbove(state)
			below := otherSnake.Head.cellBelow(state)
			if otherSnake.isLargerThanUs(state) {
				grid.Get(left.X, left.Y).Cost = 5
				grid.Get(right.X, right.Y).Cost = 5
				grid.Get(above.X, above.Y).Cost = 5
				grid.Get(below.X, below.Y).Cost = 5
				continue
			}
			// If the other snake is smaller than us, we want to make the cells next to their head walkable.
			grid.Get(left.X, left.Y).Cost = 1
			grid.Get(right.X, right.Y).Cost = 1
			grid.Get(above.X, above.Y).Cost = 1
			grid.Get(below.X, below.Y).Cost = 1
		}
	}
	// Make sure our own head is walkable. We need to do this because the getPath function
	// would not find a path if our head was not walkable.
	grid.Get(state.You.Head.X, state.You.Head.Y).Walkable = true

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
		if state.isArcadeMaze() || state.isRiversBridges() || state.isRiversBridges() {
			grid.Get(hazard.X, hazard.Y).Walkable = false
			continue
		}
		grid.Get(hazard.X, hazard.Y).Cost = 5
	}
}

func getPath(state GameState, grid *Grid) *Path {
	targetCell := getTargetCell(state, grid)

	return grid.GetPathFromCells(grid.Get(state.You.Head.X, state.You.Head.Y), grid.Get(targetCell.X, targetCell.Y), false, false, state.isWrapped())

	// Print the path and related points to the console. Useful for debugging.
	// To use this you'll need change the above line to declare a variable called path.
	// i.e. path := grid.GetPathFromCells....
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
		return path
	*/
}

func getTargetCell(state GameState, grid *Grid) *Cell {
	var targetCell *Cell
	// If our health is less than 85 we want to set our target cell to be the coordinates of the closest food.
	if state.You.Health < 85 && len(state.Board.Food) > 0 {
		targetCell = chooseNearestFood(grid, state)
	}

	walkableCells := grid.CellsByWalkable(true)
	if targetCell == nil {
		targetCell = chooseTargetCell(state, grid, walkableCells)
	}

	return targetCell
}

// Check if the cell is in a hazard.
func isCellInHazard(state GameState, cell *Cell) bool {
    for _, hazard := range state.Board.Hazards {
        if hazard.X == cell.X && hazard.Y == cell.Y {
            return true
        }
    }
    return false
}

// Flood fill function
func floodFill(state GameState, grid *Grid, cell *Cell, visited map[*Cell]bool, depth, maxDepth int) int {
    if _, ok := visited[cell]; ok || depth > maxDepth {
        return 0
    }

    visited[cell] = true

    adjacentCells := []*Cell{
        grid.Get(cell.X, (cell.Y+1)%state.Board.Height),
        grid.Get(cell.X, (cell.Y-1+state.Board.Height)%state.Board.Height),
        grid.Get((cell.X+1)%state.Board.Width, cell.Y),
        grid.Get((cell.X-1+state.Board.Width)%state.Board.Width, cell.Y),
    }

    count := 1
    for _, adjCell := range adjacentCells {
        if adjCell.Walkable && !isCellInHazard(state, adjCell) {
            count += floodFill(state, grid, adjCell, visited, depth+1, maxDepth)
        }
    }

    return count
}


// Function that returns the next direction to move based on the path we get from getPath.
func getNextDirection(state GameState, path *Path) BattlesnakeMoveResponse {
	if path.Current().Y == path.Next().Y && (path.Current().X < path.Next().X || path.Current().X > path.Next().X) {
		if path.Current().X == 0 && path.Next().X == state.Board.Width-1 {
			return BattlesnakeMoveResponse{Move: "left"}
		}
		if path.Current().X == state.Board.Width-1 && path.Next().X == 0 {
			return BattlesnakeMoveResponse{Move: "right"}
		}
		if path.Current().X < path.Next().X {
			return BattlesnakeMoveResponse{Move: "right"}
		}
		return BattlesnakeMoveResponse{Move: "left"}
	}

	if path.Current().X == path.Next().X && (path.Current().Y < path.Next().Y || path.Current().Y > path.Next().Y) {
		if path.Current().Y == 0 && path.Next().Y == state.Board.Height-1 {
			return BattlesnakeMoveResponse{Move: "down"}
		}
		if path.Current().Y == state.Board.Height-1 && path.Next().Y == 0 {
			return BattlesnakeMoveResponse{Move: "up"}
		}
		if path.Current().Y < path.Next().Y {
			return BattlesnakeMoveResponse{Move: "up"}
		}
		return BattlesnakeMoveResponse{Move: "down"}
	}
	return BattlesnakeMoveResponse{Move: "up"}
}
