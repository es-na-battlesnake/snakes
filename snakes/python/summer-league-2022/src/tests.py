"""
Starter Unit Tests using the built-in Python unittest library.
See https://docs.python.org/3/library/unittest.html
You can expand these to cover more cases!
To run the unit tests, use the following command in your terminal,
in the folder where this file exists:
    python src/tests.py -v
"""
import unittest

import logic


class AvoidNeckTest(unittest.TestCase):
    def test_avoid_neck_all(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 5}, {"x": 5, "y": 5}]
        possible_moves = ["up", "down", "left", "right"]

        # Act
        result_moves = logic._avoid_my_neck(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 4)
        self.assertEqual(possible_moves, result_moves)

    def test_avoid_neck_left(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 4, "y": 5}, {"x": 3, "y": 5}]
        possible_moves = ["up", "down", "left", "right"]
        expected = ["up", "down", "right"]

        # Act
        result_moves = logic._avoid_my_neck(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 3)
        self.assertEqual(expected, result_moves)

    def test_avoid_neck_right(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 6, "y": 5}, {"x": 7, "y": 5}]
        possible_moves = ["up", "down", "left", "right"]
        expected = ["up", "down", "left"]

        # Act
        result_moves = logic._avoid_my_neck(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 3)
        self.assertEqual(expected, result_moves)

    def test_avoid_neck_up(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 6}, {"x": 5, "y": 7}]
        possible_moves = ["up", "down", "left", "right"]
        expected = ["down", "left", "right"]

        # Act
        result_moves = logic._avoid_my_neck(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 3)
        self.assertEqual(expected, result_moves)

    def test_avoid_neck_down(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 4}, {"x": 5, "y": 3}]
        possible_moves = ["up", "down", "left", "right"]
        expected = ["up", "left", "right"]

        # Act
        result_moves = logic._avoid_my_neck(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 3)
        self.assertEqual(expected, result_moves)

class AvoidBodyTest(unittest.TestCase):

    def test_avoid_self_right(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 4}, {"x": 6, "y": 4}, {"x": 6, "y": 5}]   
        possible_moves = ["up", "down", "left", "right"] 
        expected = ["up", "left"]

        # Act
        result_moves = logic._avoid_my_body(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)

    def test_avoid_self_left(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 4}, {"x": 4, "y": 4}, {"x": 4, "y": 5}]
        possible_moves = ["up", "down", "left", "right"] 
        expected = ["up", "right"]

        # Act
        result_moves = logic._avoid_my_body(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)

    def test_avoid_self_up(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 4, "y": 5}, {"x": 4, "y": 6}, {"x": 5, "y": 6}]
        possible_moves = ["up", "down", "left", "right"]
        expected = ["down", "right"]

        # Act
        result_moves = logic._avoid_my_body(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)

    def test_avoid_self_down(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 4, "y": 5}, {"x": 4, "y": 4}, {"x": 5, "y": 4}]
        possible_moves = ["up", "down", "left", "right"]
        expected = ["up", "right"]

        # Act
        result_moves = logic._avoid_my_body(test_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)


class AvoidSnakeTest(unittest.TestCase):

    def test_avoid_snake_right(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 4, "y": 5}, {"x": 3, "y": 5}, {"x": 2, "y": 5}]
        other_snakes_body = ([ {"x": 5, "y": 3}, {"x": 6, "y": 3}, {"x": 6, "y": 2} ], 
            [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], 
            [ {"x": 6, "y": 5}, {"x": 6, "y": 4}, {"x": 6, "y": 3} ])

        possible_moves = ["up", "down", "right"]
        expected = ["up", "down"]

        # Act
        result_moves = logic._avoid_snake(test_body, other_snakes_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)


    def test_avoid_snake_left(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 6, "y": 5}, {"x": 7, "y": 5}, {"x": 8, "y": 5}]
        other_snakes_body = ([ {"x": 5, "y": 3}, {"x": 6, "y": 3}, {"x": 6, "y": 2} ], 
            [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], 
            [ {"x": 4, "y": 5}, {"x": 4, "y": 4}, {"x": 4, "y": 3} ])

        possible_moves = ["up", "down", "left"]
        expected = ["up", "down"]

        # Act
        result_moves = logic._avoid_snake(test_body, other_snakes_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)

    def test_avoid_snake_down(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 6}, {"x": 5, "y": 7}, {"x": 5, "y": 8}]
        other_snakes_body = ([ {"x": 3, "y": 5}, {"x": 2, "y": 5} ], 
            [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], 
            [ {"x": 5, "y": 4}, {"x": 6, "y": 4}, {"x": 6, "y": 3} ])

        possible_moves = ["right", "down", "left"]
        expected = ["right", "left"]

        # Act
        result_moves = logic._avoid_snake(test_body, other_snakes_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)    

    def test_avoid_snake_up(self):
        # Arrange
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 4}, {"x": 5, "y": 3}, {"x": 5, "y": 2}]
        other_snakes_body = ([ {"x": 3, "y": 5}, {"x": 2, "y": 5} ], 
            [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], 
            [ {"x": 5, "y": 6}, {"x": 6, "y": 6}, {"x": 6, "y": 7} ])

        possible_moves = ["up", "left", "right"]
        expected = ["left", "right"]

        # Act
        result_moves = logic._avoid_snake(test_body, other_snakes_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)

    def test_avoid_single_snake(self):
        test_body = [{"x": 5, "y": 5}, {"x": 5, "y": 4}, {"x": 5, "y": 3}, {"x": 5, "y": 2}]
        other_snakes_body = []
        other_snakes_body.append([{"x": 5, "y": 6}, {"x": 6, "y": 6}, {"x": 6, "y": 7}])

        possible_moves = ["up", "left", "right"]
        expected = ["left", "right"]

        # Act
        result_moves = logic._avoid_snake(test_body, other_snakes_body, possible_moves)

        # Assert
        self.assertEqual(len(result_moves), 2)
        self.assertEqual(expected, result_moves)

class AvoidWallTest(unittest.TestCase):
    
    def test_avoid_wall_top_right(self):
        # Arrange
        test_body = [{"x": 10, "y": 10}, {"x": 9, "y": 10}, {"x": 8, "y": 10}, {"x": 7, "y": 10}]
        # Setup board object with width and height nested objects
        board = { "width": 10, "height": 10 }

        possible_moves = ["up", "right", "down"]
        expected = ["down"]

        # Act
        result_moves = logic._avoid_walls(test_body, possible_moves, board)

        # Assert
        self.assertEqual(len(result_moves), 1)
        self.assertEqual(expected, result_moves)

class BuildMap(unittest.TestCase):

    def test_map_is_built(self):
        # Arrange
        board = { "width": 10, "height": 10 }
        
        # Act
        result_map = logic.build_board(board)

        # Assert
        self.assertEqual(len(result_map), 11)

    def test_map_build_from_data(self):
        # Arrange
        data = { "game": { "id": "game-00fe20da-94ad-11ea-bb37", "ruleset": { "name": "standard", "version": "v.1.2.3", "settings": { "foodSpawnChance": 25, "minimumFood": 1, "hazardDamagePerTurn": 14, "royale": { "shrinkEveryNTurns": 5 }, "squad": { "allowBodyCollisions": "true", "sharedElimination": "true", "sharedHealth": "true", "sharedLength": "true" } } }, "map": "standard", "source": "league", "timeout": 500 }, "turn": 14, "board": { "height": 11, "width": 11, "food": [ {"x": 5, "y": 5}, {"x": 9, "y": 0}, {"x": 2, "y": 6} ], "hazards": [ {"x": 3, "y": 2} ], "snakes": [ { "id": "snake-508e96ac-94ad-11ea-bb37", "name": "My Snake", "health": 54, "body": [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], "latency": "111", "head": {"x": 0, "y": 0}, "length": 3, "shout": "why are we shouting??", "squad": "", "customizations":{ "color":"#FF0000", "head":"pixel", "tail":"pixel" } }, { "id": "snake-b67f4906-94ae-11ea-bb37", "name": "Another Snake", "health": 16, "body": [ {"x": 5, "y": 4}, {"x": 5, "y": 3}, {"x": 6, "y": 3}, {"x": 6, "y": 2} ], "latency": "222", "head": {"x": 5, "y": 4}, "length": 4, "shout": "Im not really sure...", "squad": "", "customizations":{ "color":"#26CF04", "head":"silly", "tail":"curled" } } ] }, "you": { "id": "snake-508e96ac-94ad-11ea-bb37", "name": "My Snake", "health": 54, "body": [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], "latency": "111", "head": {"x": 0, "y": 0}, "length": 3, "shout": "why are we shouting??", "squad": "", "customizations": { "color":"#FF0000", "head":"pixel", "tail":"pixel" } } }

        # Act
        result_move = logic.choose_move(data)

        # Assert
        self.assertEqual(result_move, "up")

    def test_closest_food(self):
        # Arrange
        data = { "game": { "id": "game-00fe20da-94ad-11ea-bb37", "ruleset": { "name": "standard", "version": "v.1.2.3", "settings": { "foodSpawnChance": 25, "minimumFood": 1, "hazardDamagePerTurn": 14, "royale": { "shrinkEveryNTurns": 5 }, "squad": { "allowBodyCollisions": "true", "sharedElimination": "true", "sharedHealth": "true", "sharedLength": "true" } } }, "map": "standard", "source": "league", "timeout": 500 }, "turn": 14, "board": { "height": 11, "width": 11, "food": [ {"x": 5, "y": 5}, {"x": 9, "y": 0}, {"x": 2, "y": 6} ], "hazards": [ {"x": 3, "y": 2} ], "snakes": [ { "id": "snake-508e96ac-94ad-11ea-bb37", "name": "My Snake", "health": 54, "body": [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], "latency": "111", "head": {"x": 0, "y": 0}, "length": 3, "shout": "why are we shouting??", "squad": "", "customizations":{ "color":"#FF0000", "head":"pixel", "tail":"pixel" } }, { "id": "snake-b67f4906-94ae-11ea-bb37", "name": "Another Snake", "health": 16, "body": [ {"x": 5, "y": 4}, {"x": 5, "y": 3}, {"x": 6, "y": 3}, {"x": 6, "y": 2} ], "latency": "222", "head": {"x": 5, "y": 4}, "length": 4, "shout": "Im not really sure...", "squad": "", "customizations":{ "color":"#26CF04", "head":"silly", "tail":"curled" } } ] }, "you": { "id": "snake-508e96ac-94ad-11ea-bb37", "name": "My Snake", "health": 54, "body": [ {"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0} ], "latency": "111", "head": {"x": 0, "y": 0}, "length": 3, "shout": "why are we shouting??", "squad": "", "customizations": { "color":"#FF0000", "head":"pixel", "tail":"pixel" } } }

        # Act
        result_move = logic.target_closest_food(data)

        # Assert
        print(result_move)
        self.assertEqual(result_move,(2,6))

if __name__ == "__main__":
    unittest.main()