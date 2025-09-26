# lambda/app.py
import json
import boto3
import os

TABLE_NAME = os.getenv("DYNAMODB_TABLE", "TasksTable")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def _get_http_method(event):
    return event.get("httpMethod") or event.get("requestContext", {}).get("http", {}).get("method")

def _get_path(event):
    # v1: path, v2: rawPath
    return event.get("path") or event.get("rawPath") or event.get("requestContext", {}).get("http", {}).get("path", "")

def _get_path_param(event, name):
    # both v1 and v2 can include pathParameters
    params = event.get("pathParameters") or event.get("pathParams") or {}
    return params.get(name)

def lambda_handler(event, context):
    http_method = _get_http_method(event)
    path = _get_path(event) or ""

    try:
        if http_method == "POST" and path == "/task":
            body = json.loads(event.get("body") or "{}")
            task_id = body.get("taskId")
            description = body.get("description", "")
            if not task_id:
                return _response(400, {"error": "taskId is required"})
            table.put_item(Item={"taskId": task_id, "description": description})
            return _response(201, {"message": "Task created", "taskId": task_id})

        elif http_method == "GET" and (path.startswith("/task/") or _get_path_param(event, "id")):
            task_id = _get_path_param(event, "id") or path.split("/")[-1]
            result = table.get_item(Key={"taskId": task_id})
            if "Item" in result:
                return _response(200, result["Item"])
            else:
                return _response(404, {"error": "Task not found"})

        elif http_method == "DELETE" and (path.startswith("/task/") or _get_path_param(event, "id")):
            task_id = _get_path_param(event, "id") or path.split("/")[-1]
            table.delete_item(Key={"taskId": task_id})
            return _response(200, {"message": f"Task {task_id} deleted"})

        else:
            return _response(400, {"error": "Invalid request"})

    except Exception as e:
        return _response(500, {"error": str(e)})

def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }
