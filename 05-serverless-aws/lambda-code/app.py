import json
import boto3
import os
from boto3.dynamodb.conditions import Key

# DynamoDB table name from environment variable
TABLE_NAME = os.getenv("DYNAMODB_TABLE", "TasksTable")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    """Main Lambda entry point for API Gateway"""
    http_method = event.get("httpMethod")
    path = event.get("path", "")
    
    try:
        if http_method == "POST" and path == "/task":
            body = json.loads(event.get("body", "{}"))
            task_id = body.get("taskId")
            description = body.get("description", "")
            
            if not task_id:
                return _response(400, {"error": "taskId is required"})
            
            table.put_item(Item={
                "taskId": task_id,
                "description": description
            })
            return _response(201, {"message": "Task created", "taskId": task_id})
        
        elif http_method == "GET" and path.startswith("/task/"):
            task_id = path.split("/")[-1]
            result = table.get_item(Key={"taskId": task_id})
            if "Item" in result:
                return _response(200, result["Item"])
            else:
                return _response(404, {"error": "Task not found"})
        
        elif http_method == "DELETE" and path.startswith("/task/"):
            task_id = path.split("/")[-1]
            table.delete_item(Key={"taskId": task_id})
            return _response(200, {"message": f"Task {task_id} deleted"})
        
        else:
            return _response(400, {"error": "Invalid request"})
    
    except Exception as e:
        return _response(500, {"error": str(e)})


def _response(status_code, body):
    """Helper to format Lambda Proxy response"""
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }
