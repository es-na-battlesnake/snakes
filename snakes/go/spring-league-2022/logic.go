package main

// This file can be a nice home for your Battlesnake logic and related helper functions.
//
// We have started this for you, with a function to help remove the 'neck' direction
// from the list of possible moves!

import (
	"log"
	"math/rand"
	"sort"
)

// This function is called when you register your Battlesnake on play.battlesnake.com
// See https://docs.battlesnake.com/guides/getting-started#step-4-register-your-battlesnake
// It controls your Battlesnake appearance and author permissions.
// For customization options, see https://docs.battlesnake.com/references/personalization
// TIP: If you open your Battlesnake URL in browser you should see this data.
func info() BattlesnakeInfoResponse {
	log.Println("INFO")
	return BattlesnakeInfoResponse{
		APIVersion: "1",
		Author:     "ES Team", // TODO: Your Battlesnake username
		Color:      "#888887", // TODO: Personalize
		Head:       "gamer",   // TODO: Personalize
		Tail:       "gamer", // TODO: Personalize
	}
}

// This function is called everytime your Battlesnake is entered into a game.
// The provided GameState contains information about the game that's about to be played.
// It's purely for informational purposes, you don't have to make any decisions here.
func start(state GameState) {
	log.Printf("%s START\n", sanatizeInput(state.Game.ID))
}

// This function is called when a game your Battlesnake was in has ended.
// It's purely for informational purposes, you don't have to make any decisions here.
func end(state GameState) {
	log.Printf("%s END\n\n", sanatizeInput(state.Game.ID))
}

// This function is used to check if a coordinate is in hazards.
func isHazard(x int, y int, hazards []Coord) bool {
	for _, hazard := range hazards {
		if hazard.X == x && hazard.Y == y {
			return true
		}
	}
	return false
}

//This function is used to check if a coordinate is in your snake body.
func isBody(x int, y int, body []Coord) bool {
	for _, coord := range body {
		if coord.X == x && coord.Y == y {
			return true
		}
	}
	return false
}

// This function is used to check if another snake is in the coordiantes.
func isSnake(x int, y int, snakes []Battlesnake) bool {
	for _, snake := range snakes {
		for _, coord := range snake.Body {
			if coord.X == x && coord.Y == y {
				return true
			}
		}
	}
	return false
}

// This function is used to check if our head x,y coord is on the edge of the board.
func onEdge(x int, y int, width int, height int) bool {
	if x == 0 || x == width-1 || y == 0 || y == height-1 {
		return true
	}
	return false
}

// Function that takes in possibleMoves and tells us the currently available safe moves.
func safeMoves(possibleMoves map[string]bool) []string {
	var moves []string
	for move, isSafe := range possibleMoves {
		if isSafe {
			moves = append(moves, move)
		}
	}
	return moves
}

// create abs to use with sort.
func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// Sort the food coordinates by manhattan distance from the head.
func sortFood(state GameState) []Coord {
	var food []Coord
	for _, f := range state.Board.Food {
		food = append(food, f)
	}
	sort.Slice(food, func(i, j int) bool {
		dist1 := abs(food[i].X-state.You.Body[0].X) + abs(food[i].Y-state.You.Body[0].Y)
		dist2 := abs(food[j].X-state.You.Body[0].X) + abs(food[j].Y-state.You.Body[0].Y)
		return dist1 < dist2
	})
	return food
}

// This function is called on every turn of a game. Use the provided GameState to decide
// where to move -- valid moves are "up", "down", "left", or "right".
// We've provided some code and comments to get you started.
func move(state GameState) BattlesnakeMoveResponse {
	possibleMoves := map[string]bool{
		"up":    true,
		"down":  true,
		"left":  true,
		"right": true,
	}

	// Don't move back on our own neck
	myHead := state.You.Body[0] // Coordinates of your head
	myNeck := state.You.Body[1] // Coordinates of body piece directly behind your head (your "neck")
	if myNeck.X < myHead.X {
		possibleMoves["left"] = false
	} else if myNeck.X > myHead.X {
		possibleMoves["right"] = false
	} else if myNeck.Y < myHead.Y {
		possibleMoves["down"] = false
	} else if myNeck.Y > myHead.Y {
		possibleMoves["up"] = false
	}

	// Avoid walls if we are in a game mode that doesn't allow wrapping.
	boardWidth := state.Board.Width
	boardHeight := state.Board.Height
	gameMode := state.Game.Ruleset.Name
	// Move away from edge of board if we are not in wrapped game mode.
	if gameMode != "wrapped" {
		if myHead.X == 0 {
			log.Println("We are at the left edge of the board")
			possibleMoves["left"] = false
		}
		if myHead.X == boardWidth-1 {
			log.Println("We are at the right edge of the board")
			possibleMoves["right"] = false
		}
		if myHead.Y == 0 {
			log.Println("We are at the top edge of the board")
			possibleMoves["down"] = false
		}
		if myHead.Y == boardHeight-1 {
			log.Println("We are at the bottom edge of the board")
			possibleMoves["up"] = false
		}
	}

	// Don't hit yourself.
	mybody := state.You.Body
	// If a body part is immediately to the right or left of your head, you can't move right or left.
	// Check if a body part is to the right of head. If it is, then we can't move right.
	if isBody(myHead.X+1, myHead.Y, mybody) {
		possibleMoves["right"] = false
	}
	// Check to see if body part is to the left of head. If it is, then we can't move left.
	if isBody(myHead.X-1, myHead.Y, mybody) {
		possibleMoves["left"] = false
	}
	// If a body part is immediately above or below your head, you can't move up or down.
	// Check to see if body part is above head. If it is, then we can't move up.
	if isBody(myHead.X, myHead.Y+1, mybody) {
		possibleMoves["up"] = false
	}
	// Check to see if body part is below head. If it is, then we can't move down.
	if isBody(myHead.X, myHead.Y-1, mybody) {
		possibleMoves["down"] = false
	}
	// If we are in the wrapped game mode and we are on the edge of the board, we need to avoid wrapping into our own body.
	if gameMode == "wrapped" && onEdge(myHead.X, myHead.Y, boardWidth, boardHeight) {
		// Print that we are in this section of the code for debugging purposes.
		log.Println("We are in wrapped game mode and don't want to wrap into our own body")
		// If our head is at x = boardWidth - 1 then check if isBody(0, y) is true.
		if myHead.X == boardWidth-1 && isBody(0, myHead.Y, mybody) {
			possibleMoves["right"] = false
		}
		// If our head is at x = 0 then check if isBody(boardWidth-1, y) is true.
		if myHead.X == 0 && isBody(boardWidth-1, myHead.Y, mybody) {
			possibleMoves["left"] = false
		}
		// If our head is at y = boardHeight - 1 then check if isBody(x, 0) is true.
		if myHead.Y == boardHeight-1 && isBody(myHead.X, 0, mybody) {
			possibleMoves["up"] = false
		}
		// If our head is at y = 0 then check if isBody(x, boardHeight-1) is true.
		if myHead.Y == 0 && isBody(myHead.X, boardHeight-1, mybody) {
			possibleMoves["down"] = false
		}
	}

	// TODO: Look ahead further than one cell to help with avoiding snakes.
	// Don't collide with others snakes.
	// If another snake is immediately to the right or left of your head, you can't move right or left.
	// Check to see if other snake is to the right of head.
	if isSnake(myHead.X+1, myHead.Y, state.Board.Snakes) {
		possibleMoves["right"] = false
	}
	// Check to see if other snake is to the left of head.
	if isSnake(myHead.X-1, myHead.Y, state.Board.Snakes) {
		possibleMoves["left"] = false
	}
	// If another snake is immediately above or below your head, you can't move up or down.
	// Check to see if other snake is above head.
	if isSnake(myHead.X, myHead.Y+1, state.Board.Snakes) {
		possibleMoves["up"] = false
	}
	// Check to see if other snake is below head.
	if isSnake(myHead.X, myHead.Y-1, state.Board.Snakes) {
		possibleMoves["down"] = false
	}
	// If we are in the wrapped game mode and we are on the edge of the board, we need to avoid wrapping into another snake.
	if gameMode == "wrapped" && onEdge(myHead.X, myHead.Y, state.Board.Width, state.Board.Height) {
		// Print that we are in this section of the code for debugging purposes.
		log.Println("We are in wrapped game mode and don't want to wrap into another snake")
		// If our head is at x = boardWidth - 1 then check if isSnake(0, y) is true.
		if myHead.X == boardWidth-1 && isSnake(0, myHead.Y, state.Board.Snakes) {
			possibleMoves["right"] = false
		}
		// If our head is at x = 0 then check if isSnake(boardWidth-1, y) is true.
		if myHead.X == 0 && isSnake(boardWidth-1, myHead.Y, state.Board.Snakes) {
			possibleMoves["left"] = false
		}
		// If our head is at y = boardHeight - 1 then check if isSnake(x, 0) is true.
		if myHead.Y == boardHeight-1 && isSnake(myHead.X, 0, state.Board.Snakes) {
			possibleMoves["up"] = false
		}
		// If our head is at y = 0 then check if isSnake(x, boardHeight-1) is true.
		if myHead.Y == 0 && isSnake(myHead.X, boardHeight-1, state.Board.Snakes) {
			possibleMoves["down"] = false
		}
	}


	// Avoid Hazards if possible. If the only move is into a hazard, then we will take it.
	// Hazards are represented as a list of coordinates.
	hazards := state.Board.Hazards
	// Only run this code if we are in royale game mode.
	if gameMode == "royale" {
		// Check if neighboring cells are in the list of hazards.
		// If so, you can't move in that direction.
		// Check to see if a hazard is to the left of our head.
		if myHead.X-1 >= 0 {
			if isHazard(myHead.X-1, myHead.Y, hazards) {
				log.Printf("Going to hit a hazard to the left")
				// If two or more safe moves are available, then set left to false.
				if len(safeMoves(possibleMoves)) > 1 {	
					possibleMoves["left"] = false
				}
			}
		}
		// Check to see if hazard is to the right of our head.
		if myHead.X+1 <= state.Board.Width-1 {
			if isHazard(myHead.X+1, myHead.Y, hazards) {
				log.Printf("Going to hit a hazard to the right")
				// If two or more safe moves are available, then set right to false.
				if len(safeMoves(possibleMoves)) > 1 {
					possibleMoves["right"] = false
				}
			}
		}
		// Check to see if hazard is to below our head.
		if myHead.Y-1 >= 0 {
			if isHazard(myHead.X, myHead.Y-1, hazards) {
				log.Printf("Going to hit a hazard below")
				// If two or more safe moves are available, then set down to false.
				if len(safeMoves(possibleMoves)) > 1 {
					possibleMoves["down"] = false
				}
			}
		}
		// Check to see if hazard is above our head.
		if myHead.Y+1 < state.Board.Height-1 {
			if isHazard(myHead.X, myHead.Y+1, hazards) {
				log.Printf("Going to hit a hazard above")
				// If two or more safe moves are available, then set up to false.
				if len(safeMoves(possibleMoves)) > 1 {
					possibleMoves["up"] = false
				}
			}
		}
	}

	// Find food if we are low on health
	// If we are low on health, we want to find food.
	// log the sorted food list
	sortedFood := sortFood(state)
	// If we are low on health, we want to find food.
	if state.Board.Snakes[0].Health < 40 {
	// Go through the sorted food list if we can move there then move there.
		for _, food := range sortedFood {
			if food.X < myHead.X && possibleMoves["left"] {
				log.Printf("Going to eat food to the left")
				// set other moves to false
				possibleMoves["right"] = false
				possibleMoves["up"] = false
				possibleMoves["down"] = false
				break
			} else if food.X > myHead.X && possibleMoves["right"] {
				log.Printf("Going to eat food to the right")
				// set other moves to false
				possibleMoves["left"] = false
				possibleMoves["up"] = false
				possibleMoves["down"] = false
				break
			} else if food.Y < myHead.Y && possibleMoves["down"] {
				log.Printf("Going to eat food below")
				// set other moves to false
				possibleMoves["left"] = false
				possibleMoves["right"] = false
				possibleMoves["up"] = false
				break
			} else if food.Y > myHead.Y && possibleMoves["up"] {
				log.Printf("Going to eat food above")
				// set other moves to false
				possibleMoves["left"] = false
				possibleMoves["right"] = false
				possibleMoves["down"] = false
				break
			}
		}
	}

	// Finally, choose a move from the available safe moves.
	// TODO: Select a move to make based on strategy, rather than random.
	var nextMove string

	if len(safeMoves(possibleMoves)) == 0 {
		nextMove = "down"
		log.Printf("%s MOVE %d: No safe moves detected! Moving %s\n", sanatizeInput(state.Game.ID), isNumber(state.Turn), nextMove)
	} else {
		nextMove = safeMoves(possibleMoves)[rand.Intn(len(safeMoves(possibleMoves)))]
		log.Printf("%s MOVE %d: %s\n", sanatizeInput(state.Game.ID), isNumber(state.Turn), nextMove)
	}
	return BattlesnakeMoveResponse{
		Move: nextMove,
	}
}
