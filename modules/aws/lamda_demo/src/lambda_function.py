import json
import datetime

def lambda_handler(event, context):
    log = {
        "ts": context.aws_request_id,
        "source": "api_gateway",
        "path": event.get("rawPath"),
        "method": event.get("requestContext", {})
                     .get("http", {})
                     .get("method"),
        "body": event.get("body"),
        "status": 200
    }

    print(json.dumps(log))

    return {
        "statusCode": 200,
        "body": json.dumps("Complited!")
    }
