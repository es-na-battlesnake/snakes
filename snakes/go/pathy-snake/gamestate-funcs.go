package main

func (g GameState) wrapped() bool {
	if g.Game.Ruleset.Name == "wrapped" {
		return true
	}
	return false
}