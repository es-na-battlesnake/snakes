package main

import (
	"testing"
	"log"
	"io/ioutil"
	"os"
)

// Ignore log output when testing.
// Comment this function out to see log output when testing.
func TestMain(m *testing.M) {
		log.SetOutput(ioutil.Discard)
		os.Exit(m.Run())
}

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
		Body: []Coord{{X: 2, Y: 1}, {X: 2, Y: 0}, {X: 3, Y: 0}, {X: 3, Y: 1}, {X: 3, Y: 2}},
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

// Test that we go towards the closest food not next to large snake.
func TestFoodEating3(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head:   Coord{X: 5, Y: 5},
		Body:   []Coord{{X: 5, Y: 5}, {X: 5, Y: 4}, {X: 5, Y: 3}},
		Health: 20,
		Length: 3,
		ID:    "me",
	}
	other := Battlesnake{
		Head: Coord{X: 8, Y: 5},
		Body: []Coord{{X: 8, Y: 5}, {X: 8, Y: 4}, {X: 8, Y: 3}, {X: 8, Y: 2}},
		Length: 4,
		ID:    "other",
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me, other},
			Food:   []Coord{{X: 7, Y: 5}, {X: 5, Y: 9}},
			Height: 11,
			Width:  11,
		},
		You: me,
	}
	// Act 1000x (this isn't a great way to test, but it's okay for starting out)
	for i := 0; i < 1000; i++ {
		nextMove := move(state)
		// Assert never move left
		if nextMove.Move != "up" {
			t.Errorf("snake moved to a food next to bigger snake, %s", nextMove.Move)
		}
	}
}

// Test that we do not trap ourselves going after food.
func TestFoodEating4(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head:   Coord{X: 3, Y: 2},
		Body:   []Coord{{X: 3, Y: 2}, {X: 3, Y: 1}, {X: 2, Y: 1}, {X: 1, Y: 1}, {X: 1, Y: 2}, {X: 1, Y: 3}, {X: 2, Y: 3}, {X: 2, Y: 4}},
		Health: 20,
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me},
			Food:   []Coord{{X: 2, Y: 2}, {X: 0, Y: 10}, {X: 10, Y: 10}},
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
			t.Errorf("snake trapped itself trying to eat food, %s", nextMove.Move)
		}
	}
}

// Test that we go towards the closest food not next to large snake.
func TestFoodEating5(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head:   Coord{X: 2, Y: 0},
		Body:   []Coord{{X: 2, Y: 0}, {X: 1, Y: 0}, {X: 0, Y: 0}},
		Health: 20,
		Length: 3,
		ID:    "me",
	}
	other := Battlesnake{
		Head: Coord{X: 4, Y: 10},
		Body: []Coord{{X: 4, Y: 10}, {X: 5, Y: 10}, {X: 6, Y: 10}, {X: 7, Y: 10}},
		Length: 4,
		ID:    "other",
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me, other},
			Food:   []Coord{{X: 4, Y: 0}, {X: 2, Y: 7}},
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
		// Assert never move left
		if nextMove.Move == "right" {
			t.Errorf("snake moved to a food next to bigger snake, %s", nextMove.Move)
		}
	}
}

// Test that we go towards the closest food not next to large snake.
func TestFoodEating6(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head:   Coord{X: 2, Y: 0},
		Body:   []Coord{{X: 2, Y: 0}, {X: 3, Y: 0}, {X: 4, Y: 0}},
		Health: 20,
		Length: 3,
		ID:    "me",
	}
	other := Battlesnake{
		Head: Coord{X: 10, Y: 0},
		Body: []Coord{{X: 10, Y: 0}, {X: 10, Y: 1}, {X: 10, Y: 2}, {X: 10, Y: 3}},
		Length: 4,
		ID:    "other",
	}
	state := GameState{
		Board: Board{
			Snakes: []Battlesnake{me, other},
			Food:   []Coord{{X: 0, Y: 0}, {X: 2, Y: 7}},
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
		// Assert never move left
		if nextMove.Move == "left" {
			t.Errorf("snake moved to a food next to bigger snake, %s", nextMove.Move)
		}
	}
}
		
// Test that we do not wrap around into our own body.
func TestBodyWrap1(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 10, Y: 5},
		Body: []Coord{{X: 10, Y: 5}, {X: 9, Y: 5}, {X: 8, Y: 5}, {X: 0, Y: 5}, {X: 1, Y: 5}},
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

// Test that will force a snake to wrap around the board. It is basically testing that wrapping works.
func TestBodyWrap3(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 10, Y: 5},
		Body: []Coord{{X: 10, Y: 5}, {X: 10, Y: 6}, {X: 9, Y: 6}, {X: 9, Y: 5}, {X: 9, Y: 4}, {X: 10, Y: 4}, {X: 10, Y: 3}},
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
	for i := 0; i < 1000; i++ {
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

// Test that we avoid traping ourselves in a corner when we wrap.
func TestCornerTrap3(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 0, Y: 0},
		Body: []Coord{{X: 0, Y: 0}, {X: 1, Y: 0}, {X: 2, Y: 0}, {X: 3, Y: 0}, {X: 9, Y: 0}, {X: 9, Y: 1}, {X: 10, Y: 1}, {X: 10, Y: 2}},
		Health: 100,
	}
	other := Battlesnake{
		Head: Coord{X: 10, Y: 10},
		Body: []Coord{{X: 10, Y: 10}, {X: 9, Y: 10}, {X: 8, Y: 10}, {X: 7, Y: 10}},
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
		// Assert never move left
		if nextMove.Move == "left" {
			t.Errorf("snake trapped in corner while wrapping, %s", nextMove.Move)
		}
	}
}

// Test that we avoid traping ourselves in a corner when we wrap.
// Same test as previous test, but testing that we don't trap in another snake.
func TestCornerTrap4(t *testing.T) {
	// Arrange
	me := Battlesnake{
		Head: Coord{X: 0, Y: 0},
		Body: []Coord{{X: 0, Y: 0}, {X: 1, Y: 0}, {X: 2, Y: 0}, {X: 3, Y: 0}},
	}
	other := Battlesnake{
		Head: Coord{X: 8, Y: 0},
		Body: []Coord{{X: 8, Y: 0}, {X: 9, Y: 0}, {X: 9, Y: 1}, {X: 10, Y: 1}, {X: 10, Y: 2}, {X: 10, Y: 10}},
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
		// Assert never move left
		if nextMove.Move == "left" {
			t.Errorf("snake trapped in corner while wrapping, %s", nextMove.Move)
		}
	}
}

// Test that we are setting our own tail as walkable.
func TestTailWalkable1(t *testing.T) {
	for i := 0; i < 1000; i++ {
		for i := 0; i < 1; i++ {
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 4, Y: 4},
				Body: []Coord{{X: 4, Y: 4}, {X: 4, Y: 5}, {X: 3, Y: 5}, {X: 3, Y: 4}, {X: 3, Y: 3}, {X: 4, Y: 3}},
				Health: 100,
				ID: "me",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 3, Y: 10}},
				},
				Turn: 0,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move == "down" {
				t.Errorf("Walked on tail to early, %s", nextMove.Move)
			}
		}
		for i := 0; i < 1; i++ {
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 4, Y: 4},
				Body: []Coord{{X: 4, Y: 4}, {X: 4, Y: 5}, {X: 3, Y: 5}, {X: 3, Y: 4}, {X: 3, Y: 3}, {X: 4, Y: 3}},
				Health: 20,
				ID: "me",
			}
			other := Battlesnake{
				Head: Coord{X: 5, Y: 4},
				Body: []Coord{{X: 5, Y: 4}, {X: 5, Y: 3}, {X: 5, Y: 2}},
				ID: "other",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me, other},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 3, Y: 10}},
				},
				Turn: 9999999,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move != "down" {
				t.Errorf("Tail is not getting set as walkable, %s", nextMove.Move)
			}	
		}
	}
}

// Test that we are setting a neighboring snake tail as walkable.
// Multi turn test to make sure we are setting snake tails as walkable correctly.
func TestTailWalkable2(t *testing.T) {
	for i := 0; i < 1000; i++ {
		for i := 0; i < 1; i++ {	
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 4, Y: 4},
				Body: []Coord{{X: 4, Y: 4}, {X: 4, Y: 5}, {X: 3, Y: 5}, {X: 3, Y: 4}, {X: 3, Y: 3}, {X: 4, Y: 3}, {X: 5, Y: 3}},
				Health: 100,
				ID: "me",
			}
			other := Battlesnake{
				Head: Coord{X: 5, Y: 8},
				Body: []Coord{{X: 5, Y: 8},{X: 6, Y: 8}, {X: 6, Y: 7}, {X: 6, Y: 6}},
				Health: 100,
				ID: "other",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me, other},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 3, Y: 10}},
				},
				Turn: 0,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move != "right" {
				t.Errorf("Tail is not getting set as walkable, %s", nextMove.Move)
			}
		}
		for i := 0; i < 1; i++ {	
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 5, Y: 4},
				Body: []Coord{{X: 5, Y: 4},{X: 4, Y: 4}, {X: 4, Y: 5}, {X: 3, Y: 5}, {X: 3, Y: 4}, {X: 3, Y: 3}, {X: 4, Y: 3}, {X: 5, Y: 3}},
				Health: 20,
				ID: "me",
			}
			other := Battlesnake{
				Head: Coord{X: 5, Y: 8},
				Body: []Coord{{X: 5, Y: 8},{X: 6, Y: 8}, {X: 6, Y: 7}, {X: 6, Y: 6}},
				Health: 20,
				ID: "other",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me, other},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 3, Y: 10}},
				},
				Turn: 9999999,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move != "up" {
				t.Errorf("Tail is not getting set as walkable, %s", nextMove.Move)
			}
		}
	}
}

// Test that we don't set a tail next to a head as walkable.
// Multi turn test to make sure we are setting snake tails as walkable correctly.
func TestTailWalkable3(t *testing.T) {
	for i := 0; i < 1000; i++ {
		for i := 0; i < 1; i++ {	
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 4, Y: 4},
				Body: []Coord{{X: 4, Y: 4}, {X: 4, Y: 5}, {X: 5, Y: 5}},
				Health: 100,
				ID: "me",
			}
			other := Battlesnake{
				Head: Coord{X: 5, Y: 3},
				Body: []Coord{{X: 5, Y: 3},{X: 6, Y: 3}, {X: 6, Y: 4}, {X: 7, Y: 4}, {X: 7, Y: 3}, {X: 7, Y: 2}, {X: 6, Y: 2}, {X: 5, Y: 2}, {X: 4, Y: 2}, {X: 4, Y: 3}},
				Health: 100,
				ID: "other",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me, other},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 3, Y: 10}},
				},
				Turn: 0,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move == "down" {
				t.Errorf("Tail incorrectly set as walkable, %s", nextMove.Move)
			}
		}
		for i := 0; i < 1; i++ {
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 4, Y: 4},
				Body: []Coord{{X: 4, Y: 4}, {X: 4, Y: 5}, {X: 5, Y: 5}},
				Health: 90,
				ID: "me",
			}
			other := Battlesnake{
				Head: Coord{X: 5, Y: 3},
				Body: []Coord{{X: 5, Y: 3},{X: 6, Y: 3}, {X: 6, Y: 4}, {X: 7, Y: 4}, {X: 7, Y: 3}, {X: 7, Y: 2}, {X: 6, Y: 2}, {X: 5, Y: 2}, {X: 4, Y: 2}, {X: 4, Y: 3}},
				Health: 90,
				ID: "other",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me, other},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 5, Y: 4}},
				},
				Turn: 9999999,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move == "down" {
				t.Errorf("Tail incorrectly set as walkable, %s", nextMove.Move)
			}
		}
	}
}

// Test that we don't walk on a tail if snake eats twice in a row. 
// Multi turn test to make sure we are setting snake tails as walkable correctly.
func TestTailWalkable4(t *testing.T) {
	for i := 0; i < 1000; i++ {
		for i := 0; i < 1; i++ {	
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 7, Y: 1},
				Body: []Coord{{X: 7, Y: 1}, {X: 6, Y: 1}, {X: 5, Y: 1}, {X: 4, Y: 1}, {X: 3, Y: 1}},
				Health: 100,
				ID: "me",
			}
			other := Battlesnake{
				Head: Coord{X: 10, Y: 3},
				Body: []Coord{{X: 10, Y: 3},{X: 9, Y: 3}, {X: 8, Y: 3}, {X: 7, Y: 3}, {X: 8, Y: 0}, {X: 8, Y: 1}, {X: 8, Y: 2}, {X: 7, Y: 2}},
				Health: 100,
				ID: "other",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me, other},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 5, Y: 4}},
				},
				Turn: 0,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move != "down" {
				t.Errorf("Tail incorrectly set as walkable, %s", nextMove.Move)
			}
		}
		for i := 0; i < 1; i++ {	
			// Arrange
			me := Battlesnake{
				Head: Coord{X: 7, Y: 1},
				Body: []Coord{{X: 7, Y: 1}, {X: 6, Y: 1}, {X: 5, Y: 1}, {X: 4, Y: 1}, {X: 3, Y: 1}},
				Health: 100,
				ID: "me",
			}
			other := Battlesnake{
				Head: Coord{X: 10, Y: 3},
				Body: []Coord{{X: 10, Y: 3},{X: 9, Y: 3}, {X: 8, Y: 3}, {X: 7, Y: 3}, {X: 8, Y: 0}, {X: 8, Y: 1}, {X: 8, Y: 2}, {X: 7, Y: 2}},
				Health: 100,
				ID: "other",
			}
			state := GameState{
				Board: Board{
					Snakes: []Battlesnake{me, other},
					Height: 11,
					Width:  11,
					Food:   []Coord{{X: 5, Y: 4}},
				},
				Turn: 9999999,
				You: me,
			}
			nextMove := move(state)
			// Assert never move up
			if nextMove.Move != "down" {
				t.Errorf("Tail incorrectly set as walkable, %s", nextMove.Move)
			}
		}
	}
}
