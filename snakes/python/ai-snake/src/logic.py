import random
from typing import List, Dict

from pathfinding.core.diagonal_movement import DiagonalMovement
from pathfinding.core.grid import Grid
from pathfinding.finder.a_star import AStarFinder
from pathfinding.finder.dijkstra import DijkstraFinder

def get_info() -> dict:
    return {
        "apiversion": "1",
        "author": "es-na-battlesnake",
        "color": "#C5B358",
        "head": "silly",
        "tail": "bolt",
    }

def build_board(board: dict) -> List[List[int]]:
    board_map = []
    for row in range(board["height"]):
        board_map.append([])
        for col in range(board["width"]):
            board_map[row].append(2)
    return board_map

def add_snakes_to_board(board: List[List[int]], snakes: List[dict]) -> List[List[int]]:
    for snake in snakes:
        for segment in snake["body"]:
            board[segment["y"]][segment["x"]] = 0
    board[snakes[0]["body"][0]["y"]][snakes[0]["body"][0]["x"]] = 1
    return board

def add_hazards_to_board(board: List[List[int]], hazards: List[dict]) -> List[List[int]]:
    for hazard in hazards:
        board[hazard["y"]][hazard["x"]] = -1
    return board

def add_food_to_board(board: List[List[int]], food: List[dict]) -> List[List[int]]:
    for food_item in food:
        board[food_item["y"]][food_item["x"]] = 1
    return board

def build_grid(board: dict) -> Grid:
    grid = Grid(matrix=board)
    return grid

def get_target(data: dict, board: dict) -> dict:
    if data["you"]["head"]["y"] <= 5:
        while True:
            y = random.randint(5, data["board"]["width"]-2)
            x = random.randint(0, data["board"]["height"]-2)
            if board[x][y] >= 1:
                break
        return y, x
    else:
        while True:
            y = random.randint(0, data["board"]["width"]//2)
            x = random.randint(0, data["board"]["height"]-2)
            if board[x][y] >= 1:
                break
        return y, x

def target_closest_food(data: dict) -> str:
    head = data["you"]["head"]
    food = data["board"]["food"]
    for f in food:
        distance = abs(f["x"] - head["x"]) + abs(f["y"] - head["y"])
        closest_distance = 0
        closestFoodCell = 0,0
        if distance < closest_distance or closest_distance == 0:
            closest_distance = distance
            closestFoodCell = f["x"], f["y"]
    return closestFoodCell

def get_direction(path: List[str]) -> str:
    if len(path) < 2:
        return random.choice(["up", "down", "left", "right"])
    current = path[0]
    next_move = path[1]
    if next_move[0] == current[0]:
        if next_move[1] > current[1]:
            return "up"
        else:
            return "down"
    elif next_move[1] == current[1]:
        if next_move[0] > current[0]:
            return "right"
        else:
            return "left"
    else:
        return random.choice(["up", "down", "left", "right"])

def choose_move(data: dict) -> str:
    snakes = data["board"]["snakes"]
    hazards = data["board"]["hazards"]
    food = data["board"]["food"]
    board = build_board(data["board"])
    board = add_snakes_to_board(board, snakes)
    board = add_hazards_to_board(board, hazards)
    board = add_food_to_board(board, data["board"]["food"])
    grid = build_grid(board)
    if data["you"]["health"] < 80:
        target = target_closest_food(data)
    else:
        target = get_target(data, board)
    start = grid.node(data["you"]["head"]["x"], data["you"]["head"]["y"])
    end = grid.node(target[0], target[1])
    finder = DijkstraFinder(diagonal_movement=DiagonalMovement.never)
    path, runs = finder.find_path(start, end, grid)
    return get_direction(path)
