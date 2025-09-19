import os
from flask import Flask, Response
from prometheus_client import generate_latest, Counter, CollectorRegistry, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Create a Counter metric to track total HTTP requests
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'http_status'])

@app.route('/')
def hello():
    color = os.getenv("APP_COLOR", "blue")
    REQUEST_COUNT.labels(method='GET', endpoint='/', http_status='200').inc()
    return f"Hello from {color.upper()} version of Flask App 🚀"

@app.route('/metrics')
def metrics():
    # Return Prometheus metrics
    data = generate_latest()
    return Response(data, mimetype=CONTENT_TYPE_LATEST)

@app.route('/debug-routes')
def debug_routes():
    return str(app.url_map)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

