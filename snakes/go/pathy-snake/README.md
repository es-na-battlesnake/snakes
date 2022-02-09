# ES Team Snake for Spring Leauge 2022 (Pathing Edition) (https://play.battlesnake.com/league/spring-league-2022/)

### This is a team snake. Use this README for anything that might be worth noting about the Snake or things to consider when developing it. 

## Customizing the Snake 

Locate the `info` function inside `logic.go`. Inside that function you should see a line that looks like this:

```go
return BattlesnakeInfoResponse{
		APIVersion: "1",
		Author:     "",        // TODO: Your Battlesnake username
		Color:      "#888888", // TODO: Personalize
		Head:       "default", // TODO: Personalize
		Tail:       "default", // TODO: Personalize
}
```

This function is called by the game engine periodically to make sure your Battlesnake is healthy, responding correctly, and to determine how your Battlesnake will appear on the game board. See [Battlesnake Personalization](https://docs.battlesnake.com/references/personalization) for how to customize your Battlesnake's appearance using these values.

Whenever you update these values, go to the team page for the Battlesnake and select 'Refresh Metadata' from the option menu. This will update the Battlesnake to use your latest configuration and those changes should be reflected in the UI as well as any new games created.

## Changing Behavior

This snakes logic lives in `logic.go` and `pathing.go`. Possible moves are "up", "down", "left", or "right".  The board data is available in the `GameState` struct found in `main.go`. 

## Development (Codespaces)

The following assumes you are developing in Codespaces. The development environment for codespaces has been setup to use [cosmtrek/Air](https://github.com/cosmtrek/air). Air will live reload your code as you make changes. This can save you a lot of time starting and stopping the Battlesnake via `go run`.

To use Air, all you need to do is navigate to the directory where the snake code lives (`/workspaces/starter-snake-ruby/snakes/go/spring-league-2022`) and run the following command:

```shell
air
```

If you'd like more control over the `air` configuration. For example if you only want to live reload specific files you can initialize the `.air.toml` configuration file to the current directory with the default settings running the following command.

```shell
air init
```

After this make any changes you wish to the `.air.toml` file. You can then just run the `air` command without additional arguments and it will use the `.air.toml` file for configuration.

## (Optional) Running without Supervisord

You might want to run this without supervisord for faster testing and debugging. You can do this by running:

```shell
go run main.go logic.go helpers.go paths.go pathing.go
```

This will build and run your most recently edited version of the code without supervisord.

## Running Tests 

//To-Do get these setup globally to run on Actions.

Located in `logic_test.go`

For now you can run the test by navigating into the `/snakes/go/pathy-snake` directory and running:

```shell
go test
```

When doing test driven developement you may only want to run a single test. You may do so by adding your new test case to `logic_test.go` and then running:

```shell
go test -run <NameOfTest>
```

For example:

```shell
go test -run TestNeckAvoidance
```