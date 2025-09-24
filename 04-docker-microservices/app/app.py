import os
import redis
from flask import Flask

app = Flask(__name__)

# Connect to Redis service (default host = redis container name)
redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", 6379))
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

@app.route("/")
def hello():
    # Track number of visits in Redis
    count = r.incr("hits")
    return f"Hello from Flask Microservice! 🚀 This page has been visited {count} times."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
