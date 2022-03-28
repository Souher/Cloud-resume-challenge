import json
import boto3


table = boto3.resource('dynamodb').Table('visitor-count')

def lambda_handler(event, context):
  views = json.loads(event['body'])['views']
  response = table.put_item(
    Item={
        "viewcount": "0",
        'views': views
    }
  )
  
  return {
    "isBase64Encoded": False,
    "statusCode": response['ResponseMetadata']['HTTPStatusCode'],
    "headers": {'Content-Type': 'application/json'},
    "multiValueHeaders": {},
    "body": views
  }