import os
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    color = os.getenv("APP_COLOR", "blue")
    return f"Hello from {color.upper()} version of Flask App 🚀"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
