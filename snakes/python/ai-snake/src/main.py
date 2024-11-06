import logging
import os

from flask import Flask
from flask import request

import logic

app = Flask(__name__)

@app.get("/")
def handle_info():
    return logic.get_info()

@app.post("/start")
def handle_start():
    data = request.get_json()
    print(f"{data['game']['id']} START")
    return "ok"

@app.post("/move")
def handle_move():
    data = request.get_json()
    move = logic.choose_move(data)
    return {"move": move}

@app.post("/end")
def handle_end():
    data = request.get_json()
    print(f"{data['game']['id']} END")
    return "ok"

@app.after_request
def identify_server(response):
    response.headers["Server"] = "BattlesnakeOfficial/ai-snake-python"
    return response

if __name__ == "__main__":
    logging.getLogger("werkzeug").setLevel(logging.ERROR)
    host = "0.0.0.0"
    port = int(os.environ.get("PORT", "8082"))
    print(f"\nRunning Battlesnake server at http://{host}:{port}")
    app.env = 'development'
    app.run(host=host, port=port)
