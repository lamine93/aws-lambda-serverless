import json
import boto3
import uuid
import base64
import os

dynamodb = boto3.resource('dynamodb')

TABLE_NAME = os.environ["TABLE_NAME"]
ALLOWED_ORIGIN = os.environ["ALLOWED_ORIGIN"]

table = dynamodb.Table(TABLE_NAME)


def _response(status, body):
    """Réponse HTTP standard avec CORS"""
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Vary": "Origin"
        },
        "body": json.dumps(body)
    }

def _get_method(event):
    # HTTP API v2
    rc = event.get("requestContext", {})
    http = rc.get("http", {})
    if "method" in http:
        return http["method"]
    # REST API v1
    if "httpMethod" in event:
        return event["httpMethod"]
    # Fallback
    return None

def _get_body(event):
    body = event.get("body")
    if body is None:
        return {}
    if event.get("isBase64Encoded"):
        body = base64.b64decode(body).decode("utf-8")
    try:
        return json.loads(body) if isinstance(body, str) else body
    except Exception:
        return {}

def lambda_handler(event, context):
    try:
        method = _get_method(event)
        if method == "OPTIONS":
            return _response(200, {"ok": True})

        if method == "POST":
            data = _get_body(event)
            if not data.get("name") or not data.get("email"):
                return _response(400, {"message": "name et email sont requis"})
            user_id = str(uuid.uuid4())
            item = {"UserId": user_id, "name": data["name"], "email": data["email"]}
            table.put_item(Item=item)
            return _response(201, {"message": "User created", "id": user_id})

        if method == "GET":
            resp = table.scan()
            return _response(200, resp.get("Items", []))

        return _response(405, {"message": "Méthode non supportée"})

    except Exception as e:
        # log complet côté CloudWatch
        print("ERROR EVENT:", json.dumps(event))
        print("ERROR EXC:", str(e))
        return _response(500, {"message": "Internal Server Error"})
