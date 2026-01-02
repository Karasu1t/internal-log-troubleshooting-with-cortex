import json

def lambda_handler(event, context):
    # サンプルイベントのログ出力
    print("Received event: " + json.dumps(event, indent=2))
    
    # レスポンスの作成
    response = {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
    
    return response