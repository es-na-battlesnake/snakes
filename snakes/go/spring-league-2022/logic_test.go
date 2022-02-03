package main

import (
	"testing"
)

func TestNeckAvoidance(t *testing.T) {
	// Arrange
	me := Battlesnake{
		// Length 3, facing right
		Head: Coord{X: 2, Y: 0},
		Body: []Coord{{X: 2, Y: 0}, {X: 1, Y: 0}, {X: 0, Y: 0}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
		},
		You: me,
	}

	// Act 1,000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 100; i++ {
		nextMove := move(state)
		// Assert never move left
		if nextMove.Move == "left" {
			t.Errorf("snake moved onto its own neck, %s", nextMove.Move)
		}
	}
}

// Test body avoidance.
func TestBodyAvoidance(t *testing.T) {
	// Arrange
	me := Battlesnake{
		// Length 4, facing up (U shapped)
		Head: Coord{X: 2, Y: 1},
		Body: []Coord{{X: 2, Y: 1}, {X: 2, Y: 0}, {X: 3, Y: 0}, {X: 3, Y: 1}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
		},
		You: me,
	}

	// Act 1,000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 100; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move == "right" {
			t.Errorf("snake moved onto its own body, %s", nextMove.Move)
		}
	}
}

// Test that we go towards nearest food.
func TestFoodEating(t *testing.T) {
	// Arrange
	me := Battlesnake{
		// Length 4
		Head: Coord{X: 2, Y: 1},
		Body: []Coord{{X: 2, Y: 1}, {X: 2, Y: 0}, {X: 3, Y: 0}, {X: 4, Y: 0}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Food:   []Coord{{X: 4, Y: 3}, {X: 4, Y: 1}, {X: 3, Y: 3}, {X: 1, Y: 1}},
		},
		You: me,
	}
	// Act 1,000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 5; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move != "left" {
			t.Errorf("snake didn't move towards closest food, %s", nextMove.Move)
		}
	}
}

// Test that we go towards second closest food.
func TestFoodEating2(t *testing.T) {
	// Arrange
	me := Battlesnake{
		// Length 4
		Head: Coord{X: 2, Y: 1},
		Body: []Coord{{X: 2, Y: 1}, {X: 2, Y: 0}, {X: 3, Y: 0}, {X: 4, Y: 0}},
	}
	other := Battlesnake{
		// Length 4
		Head: Coord{X: 1, Y: 1},
		Body: []Coord{{X: 1, Y: 2}, {X: 1, Y: 3}, {X: 1, Y: 4}, {X: 1, Y: 5}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me, other},
			Food:   []Coord{{X: 4, Y: 3}, {X: 4, Y: 1}, {X: 3, Y: 3}, {X: 0, Y: 1}},
		},
		You: me,
	}
	// Act 1,000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 5; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move == "left" {
			t.Errorf("snake didn't move towards second closest food, %s", nextMove.Move)
		}
	}
}

// TODO: More GameState test cases!
