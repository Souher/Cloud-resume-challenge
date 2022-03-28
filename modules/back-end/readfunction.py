from email import message
import json
from urllib import response

import boto3

dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table('visitor-count')
def lambda_handler(event, context):
  response = table.get_item(
    Key={
      "viewcount": "0"
    }
  )
  return {
    "isBase64Encoded": False,
    "statusCode": response['ResponseMetadata']['HTTPStatusCode'],
    "headers": {'Content-Type': 'application/json'},
    "multiValueHeaders": {},
    "body": json.dumps(response['Item'])
   }

