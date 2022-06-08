import random
from typing import List, Dict

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
        "color": "#40de09a",
        "head": "silly",
        "tail": "bolt",
    }


def choose_move(data: dict) -> str:
    """
    data: Dictionary of all Game Board data as received from the Battlesnake Engine.
    For a full example of 'data', see https://docs.battlesnake.com/references/api/sample-move-request
    return: A String, the single move to make. One of "up", "down", "left" or "right".
    Use the information in 'data' to decide your next move. The 'data' variable can be interacted
    with as a Python Dictionary, and contains all of the information about the Battlesnake board
    for each move of the game.
    """
    my_snake = data["you"]      # A dictionary describing your snake's position on the board
    my_head = my_snake["head"]  # A dictionary of coordinates like {"x": 0, "y": 0}
    my_body = my_snake["body"]  # A list of coordinate dictionaries like [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}]
    
    #create an array of arrays to store other snakes' body
    other_snakes = _get_other_snakes(data)

    # Uncomment the lines below to see what this data looks like in your output!
    # print(f"~~~ Turn: {data['turn']}  Game Mode: {data['game']['ruleset']['name']} ~~~")
    # print(f"All board data this turn: {data}")
    # print(f"My Battlesnake this turn is: {my_snake}")
    # print(f"My Battlesnakes head this turn is: {my_head}")
    # print(f"My Battlesnakes body this turn is: {my_body}")

    possible_moves = ["up", "down", "left", "right"]

    # Step 0: Don't allow your Battlesnake to move back on it's own neck.
    possible_moves = _avoid_my_neck(my_body, possible_moves)

    # TODO: Step 1 - Don't hit walls.
    # Use information from `data` and `my_head` to not move beyond the game board.
    board = data["board"]
    possible_moves = _avoid_walls(my_body, possible_moves, board)

    # Use information from `my_body` to avoid moves that would collide with yourself.
    possible_moves = _avoid_my_body(my_body, possible_moves)

    # Step 3 - Don't collide with others.
    possible_moves = _avoid_snake(my_body, other_snakes, possible_moves)

    # TODO: Step 4 - Find food.
    # Use information in `data` to seek out and find food.
    # food = data['board']['food']

    # Choose a random direction from the remaining possible_moves to move in, and then return that move
    move = random.choice(possible_moves)
    # TODO: Explore new strategies for picking a move that are better than random

    print(f"{data['game']['id']} MOVE {data['turn']}: {move} picked from all valid options in {possible_moves}")

    return move


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