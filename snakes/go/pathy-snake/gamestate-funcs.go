package main

func (g GameState) isWrapped() bool {
	return g.Game.Ruleset.Name == "wrapped"
}

func (g GameState) isArcadeMaze() bool {
	return g.Game.Ruleset.Name == "arcade-maze"
}

func (g GameState) isRiversBridges() bool {
	return g.Game.Map == "hz_rivers_bridges"
}

func (g GameState) isIslandsBridges() bool {
	return g.Game.Map == "hz_islands_bridges"
}
