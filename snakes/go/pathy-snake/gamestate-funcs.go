package main

func (g GameState) isWrapped() bool {
	if g.Game.Ruleset.Name == "wrapped" {
		return true
	}
	return false
}

func (g GameState) isArcadeMaze() bool {
	if g.Game.Ruleset.Name == "arcade-maze" {
		return true
	}
	return false
}

func (g GameState) isRiversBridges() bool {
	if g.Game.Map == "hz_rivers_bridges" {
		return true
	}
	return false
}

func (g GameState) isIslandsBridges() bool {
	if g.Game.Map == "hz_islands_bridges" {
		return true
	}
	return false
}