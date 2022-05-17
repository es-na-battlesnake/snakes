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
 
if __name__ == "__main__":
    unittest.main()