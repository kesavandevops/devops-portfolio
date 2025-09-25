import os
import time
import redis

# Connect to Redis
redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", 6379))
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

print("Worker service started... waiting for jobs.", flush=True)

while True:
    try:
        queue, task = r.brpop("tasks", timeout=0)  # block until task arrives
        print(f"Processing task: {task}", flush=True)
        time.sleep(2)  # simulate work
        print(f"Completed task: {task}", flush=True)
    except Exception as e:
        print(f"Error: {e}", flush=True)
        time.sleep(1)
