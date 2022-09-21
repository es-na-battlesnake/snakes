package main

import (
	"log"
)

// This function is called when you register the Battlesnake on play.battlesnake.com
// See https://docs.battlesnake.com/guides/getting-started#step-4-register-your-battlesnake
// It controls your Battlesnake appearance and author permissions.
// For customization options, see https://docs.battlesnake.com/references/personalization
// TIP: If you open the Battlesnake URL in browser you should see this data.
func info() BattlesnakeInfoResponse {
	log.Println("INFO")
	return BattlesnakeInfoResponse{
		APIVersion: "1",
		Author:     "ES Team", // TODO: Your Battlesnake username
		Color:      "#77EBF7", // TODO: Personalize
		Head:       "bendr",   // TODO: Personalize
		Tail:       "offroad", // TODO: Personalize
	}
}

// This function is called everytime the Battlesnake is entered into a game.
// The provided GameState contains information about the game that's about to be played.
// It's purely for informational purposes, we don't have to make any decisions here.
func start(state GameState) {
	log.Printf("%s START\n", sanatizeInput(state.Game.ID))
}

// This function is called when a game the Battlesnake was in has ended.
// It's purely for informational purposes, we don't have to make any decisions here.
func end(state GameState) {
	log.Printf("%s END\n\n", sanatizeInput(state.Game.ID))
	log.Printf("%s After %d turns\n", sanatizeInput(state.Game.ID), isNumber(state.Turn))
	log.Printf("%s WINNER: %s\n", sanatizeInput(state.Game.ID), sanatizeInput(state.Board.Snakes[0].Name))
}

func move(state GameState) BattlesnakeMoveResponse {
	nextMove := createSnakeMap(state).Move
	log.Printf("%s MOVE %d: %s\n", sanatizeInput(state.Game.ID), isNumber(state.Turn), nextMove)

	return BattlesnakeMoveResponse{Move: nextMove}
}
