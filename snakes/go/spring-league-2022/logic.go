package main

// This file can be a nice home for your Battlesnake logic and related helper functions.
//
// We have started this for you, with a function to help remove the 'neck' direction
// from the list of possible moves!

import (
	"log"
	"math/rand"
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
		Author:     "ES",      // TODO: Your Battlesnake username
		Color:      "#888888", // TODO: Personalize
		Head:       "default", // TODO: Personalize
		Tail:       "default", // TODO: Personalize
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

	// Step 0: Don't let your Battlesnake move back in on it's own neck
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

	// TODO: Step 1 - Wrap through walls.
	// Use information in GameState to prevent your Battlesnake from wrapping through a wall and hitting another snake.
	// We essentially need to look ahead here if we are going to be moving through a wall.
	// boardWidth := state.Board.Width
	// boardHeight := state.Board.Height

	// TODO: Step 2 - Don't hit yourself.
	// Use information in GameState to prevent your Battlesnake from colliding with itself.
	mybody := state.You.Body
	// If a body part is immediately to the right or left of your head, you can't move right or left.
	// Check to see if body part is to the right of head.
	for i := 0; i < len(mybody); i++ {
		if mybody[i].X == myHead.X+1 && mybody[i].Y == myHead.Y {
			log.Printf("Going to hit right body part")
			possibleMoves["right"] = false
		}
		if mybody[i].X == myHead.X-1 && mybody[i].Y == myHead.Y {
			log.Printf("Going to hit left body part")
			possibleMoves["left"] = false
		}
		if mybody[i].Y == myHead.Y+1 && mybody[i].X == myHead.X {
			log.Printf("Going to hit up body part")
			possibleMoves["up"] = false
		}
		if mybody[i].Y == myHead.Y-1 && mybody[i].X == myHead.X {
			log.Printf("Going to hit down body part")
			possibleMoves["down"] = false
		}
		// Avoid body parts on opposite side of the board after wrapping through a wall.
		// If body part is at x = 0, and head is at x = boardWidth - 1, and same y you can't move right.
		if mybody[i].X == 0 && myHead.X == state.Board.Width-1 && mybody[i].Y == myHead.Y {
			log.Printf("Going to hit right body part by wrapping")
			possibleMoves["right"] = false
		}
		// If body part is at x = boardWidth - 1, and head is at x = 0, and same y you can't move left.
		if mybody[i].X == state.Board.Width-1 && myHead.X == 0 && mybody[i].Y == myHead.Y {
			log.Printf("Going to hit left body part by wrapping")
			possibleMoves["left"] = false
		}
		// If body part is at y = 0, and head is at y = boardHeight - 1, and same x you can't move down.
		if mybody[i].Y == 0 && myHead.Y == state.Board.Height-1 && mybody[i].X == myHead.X {
			log.Printf("Going to hit up body part by wrapping")
			possibleMoves["up"] = false
		}
		// If body part is at y = boardHeight - 1, and head is at y = 0, and same x you can't move up.
		if mybody[i].Y == state.Board.Height-1 && myHead.Y == 0 && mybody[i].X == myHead.X {
			log.Printf("Going to hit down body part by wrapping")
			possibleMoves["down"] = false
		}
	}
	// TODO: Step 3 - Don't collide with others.
	// Use information in GameState to prevent your Battlesnake from colliding with others.
	// If another snake is immediately to the right or left of your head, you can't move right or left.
	// Check to see if other snake is to the right of head.
	for i := 0; i < len(state.Board.Snakes); i++ {
		otherSnake := state.Board.Snakes[i]
		if otherSnake.ID != state.You.ID {
			for j := 0; j < len(otherSnake.Body); j++ {
				if otherSnake.Body[j].X == myHead.X+1 && otherSnake.Body[j].Y == myHead.Y {
					log.Printf("Going to hit a snake to the right")
					possibleMoves["right"] = false
				}
				if otherSnake.Body[j].X == myHead.X-1 && otherSnake.Body[j].Y == myHead.Y {
					log.Printf("Going to hit a snake to the left")
					possibleMoves["left"] = false
				}
				if otherSnake.Body[j].Y == myHead.Y+1 && otherSnake.Body[j].X == myHead.X {
					log.Printf("Going to hit a snake above")
					possibleMoves["up"] = false
				}
				if otherSnake.Body[j].Y == myHead.Y-1 && otherSnake.Body[j].X == myHead.X {
					log.Printf("Going to hit a snake below")
					possibleMoves["down"] = false
				}
				// Avoid body parts on opposite side of the board after wrapping through a wall.
				// If body part is at x = 0, and head is at x = boardWidth - 1, and same y you can't move right.
				if otherSnake.Body[j].X == 0 && myHead.X == state.Board.Width-1 && otherSnake.Body[j].Y == myHead.Y {
					log.Printf("Going to hit a snake to the right by wrapping")
					possibleMoves["right"] = false
				}
				// If body part is at x = boardWidth - 1, and head is at x = 0, and same y you can't move left.
				if otherSnake.Body[j].X == state.Board.Width-1 && myHead.X == 0 && otherSnake.Body[j].Y == myHead.Y {
					log.Printf("Going to hit a snake to the left by wrapping")
					possibleMoves["left"] = false
				}
				// If body part is at y = 0, and head is at y = boardHeight - 1, and same x you can't move down.
				if otherSnake.Body[j].Y == 0 && myHead.Y == state.Board.Height-1 && otherSnake.Body[j].X == myHead.X {
					log.Printf("Going to hit a snake above by wrapping")
					possibleMoves["up"] = false
				}
				// If body part is at y = boardHeight - 1, and head is at y = 0, and same x you can't move up.
				if otherSnake.Body[j].Y == state.Board.Height-1 && myHead.Y == 0 && otherSnake.Body[j].X == myHead.X {
					log.Printf("Going to hit a snake below by wrapping")
					possibleMoves["down"] = false
				}
			}
		}
	}

	// TODO: Step 4 - Find food.
	// Use information in GameState to seek out and find food.

	// Finally, choose a move from the available safe moves.
	// TODO: Step 5 - Select a move to make based on strategy, rather than random.
	var nextMove string

	safeMoves := []string{}
	for move, isSafe := range possibleMoves {
		if isSafe {
			safeMoves = append(safeMoves, move)
		}
	}

	if len(safeMoves) == 0 {
		nextMove = "down"
		log.Printf("%s MOVE %d: No safe moves detected! Moving %s\n", sanatizeInput(state.Game.ID), isNumber(state.Turn), nextMove)
	} else {
		nextMove = safeMoves[rand.Intn(len(safeMoves))]
		log.Printf("%s MOVE %d: %s\n", sanatizeInput(state.Game.ID), isNumber(state.Turn), nextMove)
	}
	return BattlesnakeMoveResponse{
		Move: nextMove,
	}
}
