import os
import time
import redis

# Connect to Redis
redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", 6379))
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

print("Worker service started... waiting for jobs.")

while True:
    task = r.lpop("tasks")  # get a task from Redis
    if task:
        print(f"Processing task: {task}")
        # simulate work
        time.sleep(2)
        print(f"Completed task: {task}")
    else:
        time.sleep(1)
