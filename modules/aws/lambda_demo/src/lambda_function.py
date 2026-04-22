import json


def _parse_json_body(event):
    """
    Returns (parsed_dict, None) or (None, raw_body_str) on invalid JSON.
    raw_body is only for logging when returning 400.
    """
    raw = event.get("body")
    if raw is None:
        return {}, None
    if isinstance(raw, dict):
        return raw, None
    if not isinstance(raw, str):
        return {}, None
    if raw.strip() == "":
        return {}, None
    try:
        return json.loads(raw), None
    except json.JSONDecodeError:
        return None, raw


def _resolve_http_status(body):
    """Business rules first; optional explicit status/http_status (400–599) overrides last."""
    if not isinstance(body, dict):
        return 200

    if body.get("rejected") is True:
        return 422

    for key in ("status", "http_status"):
        val = body.get(key)
        if val is None:
            continue
        try:
            code = int(val)
        except (TypeError, ValueError):
            continue
        if 400 <= code <= 599:
            return code
    return 200


def lambda_handler(event, context):
    body, bad_raw = _parse_json_body(event)

    if bad_raw is not None:
        http_status = 400
        log = {
            "ts": context.aws_request_id,
            "source": "api_gateway",
            "path": event.get("rawPath"),
            "method": event.get("requestContext", {})
            .get("http", {})
            .get("method"),
            "body": bad_raw,
            "status": http_status,
            "error": "invalid_json",
        }
        print(json.dumps(log))
        return {
            "statusCode": http_status,
            "body": json.dumps({"message": "invalid_json"}),
        }

    http_status = _resolve_http_status(body)

    log = {
        "ts": context.aws_request_id,
        "source": "api_gateway",
        "path": event.get("rawPath"),
        "method": event.get("requestContext", {})
        .get("http", {})
        .get("method"),
        "body": event.get("body"),
        "status": http_status,
    }

    print(json.dumps(log))

    if http_status < 400:
        payload = {"message": "ok", "status": http_status}
    elif http_status == 422:
        payload = {"message": "rejected", "status": http_status}
    else:
        payload = {"message": "error", "status": http_status}

    return {
        "statusCode": http_status,
        "body": json.dumps(payload),
    }
