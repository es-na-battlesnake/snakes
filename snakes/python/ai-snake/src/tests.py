import unittest
import logic

class TestAISnake(unittest.TestCase):
    def setUp(self):
        self.data = {
            "game": {
                "id": "game-id",
                "ruleset": {"name": "standard", "version": "1.2.3"},
                "timeout": 500,
            },
            "turn": 10,
            "board": {
                "height": 11,
                "width": 11,
                "food": [{"x": 5, "y": 5}],
                "hazards": [{"x": 2, "y": 2}],
                "snakes": [
                    {
                        "id": "snake-id",
                        "name": "Test Snake",
                        "health": 90,
                        "body": [{"x": 1, "y": 1}, {"x": 1, "y": 2}, {"x": 1, "y": 3}],
                        "head": {"x": 1, "y": 1},
                        "length": 3,
                    }
                ],
            },
            "you": {
                "id": "snake-id",
                "name": "Test Snake",
                "health": 90,
                "body": [{"x": 1, "y": 1}, {"x": 1, "y": 2}, {"x": 1, "y": 3}],
                "head": {"x": 1, "y": 1},
                "length": 3,
            },
        }

    def test_get_info(self):
        info = logic.get_info()
        self.assertEqual(info["apiversion"], "1")
        self.assertEqual(info["author"], "es-na-battlesnake")
        self.assertEqual(info["color"], "#C5B358")
        self.assertEqual(info["head"], "silly")
        self.assertEqual(info["tail"], "bolt")

    def test_build_board(self):
        board = logic.build_board(self.data["board"])
        self.assertEqual(len(board), 11)
        self.assertEqual(len(board[0]), 11)
        self.assertEqual(board[0][0], 2)

    def test_add_snakes_to_board(self):
        board = logic.build_board(self.data["board"])
        board = logic.add_snakes_to_board(board, self.data["board"]["snakes"])
        self.assertEqual(board[1][1], 1)
        self.assertEqual(board[1][2], 0)
        self.assertEqual(board[1][3], 0)

    def test_add_hazards_to_board(self):
        board = logic.build_board(self.data["board"])
        board = logic.add_hazards_to_board(board, self.data["board"]["hazards"])
        self.assertEqual(board[2][2], -1)

    def test_add_food_to_board(self):
        board = logic.build_board(self.data["board"])
        board = logic.add_food_to_board(board, self.data["board"]["food"])
        self.assertEqual(board[5][5], 1)

    def test_build_grid(self):
        board = logic.build_board(self.data["board"])
        grid = logic.build_grid(board)
        self.assertEqual(grid.width, 11)
        self.assertEqual(grid.height, 11)

    def test_get_target(self):
        board = logic.build_board(self.data["board"])
        target = logic.get_target(self.data, board)
        self.assertTrue(0 <= target[0] < 11)
        self.assertTrue(0 <= target[1] < 11)

    def test_target_closest_food(self):
        closest_food = logic.target_closest_food(self.data)
        self.assertEqual(closest_food, (5, 5))

    def test_get_direction(self):
        path = [(1, 1), (1, 2)]
        direction = logic.get_direction(path)
        self.assertEqual(direction, "up")

    def test_choose_move(self):
        move = logic.choose_move(self.data)
        self.assertIn(move, ["up", "down", "left", "right"])

if __name__ == "__main__":
    unittest.main()
