import random
from typing import List, Dict

from pathfinding.core.diagonal_movement import DiagonalMovement
from pathfinding.core.grid import Grid
from pathfinding.finder.a_star import AStarFinder
from pathfinding.finder.dijkstra import DijkstraFinder

"""
This file can be a nice home for your Battlesnake's logic and helper functions.
We have started this for you, and included some logic to remove your Battlesnake's 'neck'
from the list of possible moves!
"""

def get_info() -> dict:
    """
    This controls your Battlesnake appearance and author permissions.
    For customization options, see https://docs.battlesnake.com/references/personalization
    TIP: If you open your Battlesnake URL in browser you should see this data.
    """
    return {
        "apiversion": "1",
        "author": "es-na-battlesnake",
        "color": "#C5B358",
        "head": "silly",
        "tail": "bolt",
    }

def build_board(board: dict) -> List[List[int]]:
    """
    Create a 2d array the size of the board to represent the board.
    """
    board_map = []
    for row in range(board["height"]):
        board_map.append([])
        for col in range(board["width"]):
            board_map[row].append(2)

    return board_map

def add_snakes_to_board(board: List[List[int]], snakes: List[dict]) -> List[List[int]]:
    """
    board: A 2d array representing the board.
    snakes: A list of dictionaries containing the bodies of the other snakes on the board.
    return: A 2d array representing the board with the other snakes added.
    """
    for snake in snakes:
        for segment in snake["body"]:
            board[segment["y"]][segment["x"]] = 0

    #make our own tail walkable
    board[snakes[0]["body"][0]["y"]][snakes[0]["body"][0]["x"]] = 1
    
    return board

def add_hazards_to_board(board: List[List[int]], hazards: List[dict]) -> List[List[int]]:
    """
    board: A 2d array representing the board.
    hazards: A list of dictionaries containing the bodies of the other snakes on the board.
    return: A 2d array representing the board with the other snakes added.
    """
    for hazard in hazards:
        board[hazard["y"]][hazard["x"]] = -1
    
    return board

def build_grid(board: dict) -> Grid:
    """
    board: A dictionary containing the board information.
    return: A Grid object representing the board.
    """
    grid = Grid(matrix=board)
    return grid

def get_target(data: dict, board: dict) -> dict:
    """
    data: A dictionary containing information about the game.
    return: A dictionary containing the x/y coordinates of the target.
    """
    #print("Head is located at: ", data["you"]["head"]["x"], data["you"]["head"]["y"])
    if data["you"]["head"]["y"] <= 5:
        # print("head is less than 5")

        while True:
            y = random.randint(5, data["board"]["width"]-2)
            x = random.randint(0, data["board"]["height"]-2)

            #print("Target is located at: ", x, y)
            if board[x][y] >= 1:
                break

        return y, x
    else:
        # print("head is greater than 5")

        while True:
            y = random.randint(0, data["board"]["width"]//2)
            x = random.randint(0, data["board"]["height"]-2)

            #print("Target is located at: ", x, y)
            if board[x][y] >= 1:
                break
        
        return y, x

def add_food_to_board(board: List[List[int]], food: List[dict]) -> List[List[int]]:
    """
    board: A 2d array representing the board.
    food: A list of dictionaries containing the bodies of the other snakes on the board.
    return: A 2d array representing the board with the other snakes added.
    """
    for food_item in food:
        board[food_item["y"]][food_item["x"]] = 1
    
    return board

def target_closest_food(data: dict) -> str:
    """
    data: A dictionary containing information about the game.
    return: A string representing the direction to move.
    """
    head = data["you"]["head"]
    food = data["board"]["food"]
    # Find food closest to head
    """
    distance := abs(food.X-state.You.Head.X) + abs(food.Y-state.You.Head.Y)
        // If the distance is less than the closest distance, then set the food to be the closest food.
        if distance < closestDistance || closestDistance == 0 {
            closestDistance = distance
            closestFoodCell = grid.Get(food.X, food.Y)
        }
    """
    for f in food:
        distance = abs(f["x"] - head["x"]) + abs(f["y"] - head["y"])
        closest_distance = 0
        closestFoodCell = 0,0
        if distance < closest_distance or closest_distance == 0:
            closest_distance = distance
            closestFoodCell = f["x"], f["y"]
    
    return closestFoodCell

def get_direction(path: List[GridNode]) -> str:
    """
    path: A list of GridNode objects representing the path to the target.
    return: A string representing the direction to move.
    """

    if len(path) < 2:
        # return random move
        print("Random move")
        return random.choice(["up", "down", "left", "right"])

    current = path[0]
    next_move = path[1]

    if next_move.x == current.x:
        if next_move.y > current.y:
            return "up"
        else:
            return "down"
    elif next_move.y == current.y:
        if next_move.x > current.x:
            return "right"
        else:
            return "left"
    else:
        print("error: no move available")
        return random.choice(["up", "down", "left", "right"])

def choose_move(data: dict) -> str:
    """
    data: Dictionary of all Game Board data as received from the Battlesnake Engine.
    For a full example of 'data', see https://docs.battlesnake.com/references/api/sample-move-request
    return: A String, the single move to make. One of "up", "down", "left" or "right".
    Use the information in 'data' to decide your next move. The 'data' variable can be interacted
    with as a Python Dictionary, and contains all of the information about the Battlesnake board
    for each move of the game.
    """

    snakes = data["board"]["snakes"]
    hazards = data["board"]["hazards"]
    food = data["board"]["food"]
    # Print the move
    print("Move: ", data["turn"])
    board = build_board(data["board"])
    # Add snakes to board
    board = add_snakes_to_board(board, snakes)
    # Add hazards to board
    board = add_hazards_to_board(board, hazards)
    # Add food to board
    board = add_food_to_board(board, data["board"]["food"])
    grid = build_grid(board)

    # if our health is low then target food. Otherwise random target
    if data["you"]["health"] < 80:
        target = target_closest_food(data)   
    else:
        target = get_target(data, board)
    # check if target is walkable. If not get new target

   
    #Set starting point to your head
    start = grid.node(data["you"]["head"]["x"], data["you"]["head"]["y"])
    end = grid.node(target[0], target[1])
    #print("Got a target" , target)
    finder = DijkstraFinder(diagonal_movement=DiagonalMovement.never)
    path, runs = finder.find_path(start, end, grid)

    #print('operations:', runs, 'path length:', len(path))
    #print(grid.grid_str(path=path, start=start, end=end))
    #print(path)

    return get_direction(path)

'''
The functions below this point are only used by the tests. 
They can be removed and tests can be cleaned up.
'''

def _avoid_my_neck(my_body: dict, possible_moves: List[str]) -> List[str]:
    """
    my_body: List of dictionaries of x/y coordinates for every segment of a Battlesnake.
            e.g. [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}]
    possible_moves: List of strings. Moves to pick from.
            e.g. ["up", "down", "left", "right"]
    return: The list of remaining possible_moves, with the 'neck' direction removed
    """

    my_head = my_body[0]  # The first body coordinate is always the head
    my_neck = my_body[1]  # The segment of body right after the head is the 'neck'


    if my_neck["x"] < my_head["x"]:  # my neck is left of my head
        possible_moves.remove("left")
    elif my_neck["x"] > my_head["x"]:  # my neck is right of my head
        possible_moves.remove("right")
    elif my_neck["y"] < my_head["y"]:  # my neck is below my head
        possible_moves.remove("down")
    elif my_neck["y"] > my_head["y"]:  # my neck is above my head
        possible_moves.remove("up")

    return possible_moves

# function to prevent the snake from colliding with itself.
def _avoid_my_body(my_body: dict, possible_moves: List[str]) -> List[str]:

    my_head = my_body[0]

    for segment in my_body:
        if segment["x"] == my_head["x"] and segment["y"] == my_head["y"]:
            continue
        if segment["x"] < my_head["x"]:
            if "left" in possible_moves:
                possible_moves.remove("left")
        elif segment["x"] > my_head["x"]:
            if "right" in possible_moves:
                possible_moves.remove("right")
        elif segment["y"] < my_head["y"]:
            if "down" in possible_moves:
                possible_moves.remove("down")
        elif segment["y"] > my_head["y"]:
            if "up" in possible_moves:
                possible_moves.remove("up")

    return possible_moves

# function to prevent the snake from colliding with walls.
def _avoid_walls(my_body: dict, possible_moves: List[str], board: dict) -> List[str]:

    board_height = board["height"]
    board_width =  board["width"]

    my_head = my_body[0]

    if my_head["x"] + 1 > board_width:
        possible_moves.remove("right")
    if my_head["x"] - 1 < 0:
        possible_moves.remove("left")
    if my_head["y"] + 1 > board_height:
        possible_moves.remove("up")
    if my_head["y"] - 1 < 0:
        possible_moves.remove("down")

    return possible_moves

def _avoid_snake(my_body: dict, other_body: dict, possible_moves: List[str]) -> List[str]:

    my_head = my_body[0]

    # check if head is in the other snake's body. If so, remove the move that would cause collision.
    to_right = {'x': my_head["x"] + 1, 'y': my_head["y"]}
    to_left = {'x': my_head["x"] - 1, 'y': my_head["y"]}
    to_up = {'x': my_head["x"], 'y': my_head["y"] + 1}
    to_down = {'x': my_head["x"], 'y': my_head["y"] - 1}

    for body in other_body:
        if to_right in body:
           possible_moves.remove("right")
        if to_left in body:
            possible_moves.remove("left")
        if to_up in body:
            possible_moves.remove("up")
        if to_down in body:
            possible_moves.remove("down")

    return possible_moves

def _get_other_snakes(data: dict) -> List[dict]:

    """
    data: A dictionary containing information about the game.
    return: A list of dictionaries containing the bodies of the other snakes on the board.
    """
    other_snakes = []
    for snake in data["board"]["snakes"]:
        if snake["id"] != data["you"]["id"]: 
            other_snakes.append([snake])
    return other_snakes
