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
			Height: 11,
			Width:  11,
		},
		You: me,
	}

	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
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
			Height: 11,
			Width:  11,
		},
		You: me,
	}

	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move == "right" {
			t.Errorf("snake moved onto its own body, %s", nextMove.Move)
		}
	}
}

// Test that we go towards nearest food.
func TestFoodEating1(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head:   Coord{X: 2, Y: 1},
		Body:   []Coord{{X: 2, Y: 1}, {X: 2, Y: 0}, {X: 3, Y: 0}, {X: 4, Y: 0}},
		Health: 20,
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Food:   []Coord{{X: 4, Y: 3}, {X: 4, Y: 1}, {X: 3, Y: 3}, {X: 1, Y: 1}},
			Height: 11,
			Width:  11,
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move left
		if nextMove.Move != "left" {
			t.Errorf("snake didn't move towards closest food, %s", nextMove.Move)
		}
	}
}

// Test that we go towards second closest food.
func TestFoodEating2(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head:   Coord{X: 2, Y: 1},
		Body:   []Coord{{X: 2, Y: 1}, {X: 2, Y: 0}, {X: 3, Y: 0}, {X: 4, Y: 0}},
		Health: 20,
	}
	other := Battlesnake{
		Head: Coord{X: 1, Y: 1},
		Body: []Coord{{X: 1, Y: 2}, {X: 1, Y: 3}, {X: 1, Y: 4}, {X: 1, Y: 5}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me, other},
			Food:   []Coord{{X: 4, Y: 3}, {X: 4, Y: 1}, {X: 3, Y: 3}, {X: 0, Y: 1}},
			Height: 11,
			Width:  11,
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move left
		if nextMove.Move == "left" {
			t.Errorf("snake didn't move towards second closest food, %s", nextMove.Move)
		}
	}
}

// The Pathing Snake does not yet know how to wrap around the board. So this test shouldn't ever fail (yet).
// Test that we do not wrap around into our own body.
func TestBodyWrap1(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 10, Y: 5},
		Body: []Coord{{X: 10, Y: 5}, {X: 9, Y: 5}, {X: 8, Y: 5}, {X: 0, Y: 5}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Height: 11,
			Width:  11,
		},
		You: me,
		Game: Game{
			Ruleset: Ruleset{
				Name: "wrapped",
			},
		},
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move == "right" {
			t.Errorf("snake wrapped into its own body, %s", nextMove.Move)
		}
	}
}

// The Pathing Snake does not yet know how to wrap around the board. So this test shouldn't ever fail (yet).
// Test that we do not wrap around the board into another snake.
func TestBodyWrap2(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 10, Y: 5},
		Body: []Coord{{X: 10, Y: 5}, {X: 9, Y: 5}, {X: 8, Y: 5}, {X: 7, Y: 5}},
	}
	other := Battlesnake{
		Head: Coord{X: 0, Y: 5},
		Body: []Coord{{X: 0, Y: 5}, {X: 0, Y: 6}, {X: 0, Y: 7}, {X: 0, Y: 8}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me, other},
			Height: 11,
			Width:  11,
		},
		You: me,
		Game: Game{
			Ruleset: Ruleset{
				Name: "wrapped",
			},
		},
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move == "right" {
			t.Errorf("snake wrapped into another snake, %s", nextMove.Move)
		}
	}
}

// Test that will force a snake to wrap around the board.
func TestBodyWrap3(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 10, Y: 5},
		Body: []Coord{{X: 10, Y: 5}, {X: 10, Y: 6}, {X: 9, Y: 6}, {X: 9, Y: 5}, {X: 9, Y: 4}, {X: 10, Y: 4}},
		Health: 100,
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Height: 11,
			Width:  11,
		},
		You: me,
		Game: Game{
			Ruleset: Ruleset{
				Name: "wrapped",
			},
		},
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move != "right" {
			t.Errorf("snake wrapped into another snake, %s", nextMove.Move)
		}
	}
}


// Test that we avoid walls when not in wrapped mode.
func TestWallAvoidance(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 10, Y: 5},
		Body: []Coord{{X: 10, Y: 5}, {X: 9, Y: 5}, {X: 8, Y: 5}, {X: 7, Y: 5}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Height: 11,
			Width:  11,
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move == "right" {
			t.Errorf("snake moved into wall, %s", nextMove.Move)
		}
	}
}

// Test that we avoid traping ourselves in our own body.
func TestBodyTrap1(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 2, Y: 1},
		Body: []Coord{{X: 2, Y: 1}, {X: 2, Y: 0}, {X: 1, Y: 0}, {X: 0, Y: 0},
			{X: 0, Y: 1}, {X: 0, Y: 2}, {X: 1, Y: 2}, {X: 2, Y: 2}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Height: 11,
			Width:  11,
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move left
		if nextMove.Move == "left" {
			t.Errorf("snake trapped in own body, %s", nextMove.Move)
		}
	}
}

// Test that we avoid traping ourselves in another snakes body.
func TestBodyTrap2(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 0, Y: 2},
		Body: []Coord{{X: 0, Y: 2}, {X: 0, Y: 1}, {X: 0, Y: 0}},
	}
	other := Battlesnake{
		Head: Coord{X: 1, Y: 0},
		Body: []Coord{{X: 1, Y: 0}, {X: 1, Y: 1}, {X: 2, Y: 1}, {X: 2, Y: 2}, {X: 2, Y: 3}, {X: 1, Y: 3}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me, other},
			Height: 11,
			Width:  11,
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move right
		if nextMove.Move == "right" {
			t.Errorf("snake trapped in another snake body, %s", nextMove.Move)
		}
	}
}

// Test that we avoid traping ourselves in a corner.
func TestCornerTrap1(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 0, Y: 1},
		Body: []Coord{{X: 0, Y: 1}, {X: 1, Y: 1}, {X: 1, Y: 0}, {X: 2, Y: 0}, {X: 3, Y: 0}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Height: 11,
			Width:  11,
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move down
		if nextMove.Move == "down" {
			t.Errorf("snake trapped in corner, %s", nextMove.Move)
		}
	}
}

// Test that we avoid traping ourselves in a corner. Just another variation of the previous test.
func TestCornerTrap2(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 0, Y: 9},
		Body: []Coord{{X: 0, Y: 9}, {X: 1, Y: 9}, {X: 1, Y: 10}, {X: 2, Y: 10}, {X: 3, Y: 10}},
		Health: 100,
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Height: 11,
			Width:  11,
			Food:   []Coord{{X: 3, Y: 10}},
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move up
		if nextMove.Move == "up" {
			t.Errorf("snake trapped in corner, %s", nextMove.Move)
		}
	}
}

// Test that we avoid traping ourselves in a corner. Just another variation of the previous test.
func TestCornerTrap3(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 0, Y: 9},
		Body: []Coord{{X: 0, Y: 9}},
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Height: 11,
			Width:  11,
			Food:   []Coord{{X: 3, Y: 10}},
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move up
		if nextMove.Move == "up" {
			t.Errorf("snake trapped in corner, %s", nextMove.Move)
		}
	}
}
