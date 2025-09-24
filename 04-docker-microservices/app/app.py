from flask import Flask, request, jsonify
import redis
import os

app = Flask(__name__)

# Redis connection settings
redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", 6379))

r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

@app.route("/")
def home():
    return jsonify({"message": "Flask API is running with Redis task queue"}), 200

@app.route("/add/<task>", methods=["POST"])
def add_task(task):
    """Add a task to the Redis queue"""
    r.rpush("tasks", task)  # push task to Redis list
    return jsonify({"status": "queued", "task": task}), 201

@app.route("/metrics")
def metrics():
    """Expose simple app metrics (demo)"""
    task_count = r.llen("tasks")
    return jsonify({
        "queued_tasks": task_count
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
