from flask import Flask, jsonify, request
import os
import socket
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from datetime import datetime

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter("http_requests_total", "Total HTTP Requests", ["method", "endpoint", "status"])

@app.route("/")
def home():
    REQUEST_COUNT.labels("GET", "/", 200).inc()
    return jsonify({
        "message": "Welcome to the Enterprise DevOps Workflow 🚀",
        "hostname": socket.gethostname(),
        "time": datetime.utcnow().isoformat() + "Z"
    }), 200

@app.route("/api/health")
def health():
    REQUEST_COUNT.labels("GET", "/api/health", 200).inc()
    return jsonify({"status": "healthy"}), 200

@app.route("/metrics")
def metrics():
    data = generate_latest()
    return data, 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
