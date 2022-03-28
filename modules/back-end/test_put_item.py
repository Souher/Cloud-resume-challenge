from pprint import pprint
from urllib import response
import boto3
from botocore.exceptions import ClientError

def put_viewer_count(viewcount, views, dynamodb):
    table = dynamodb.Table('visitor-count')
    response = table.put_item(
       Item={
            'viewcount': viewcount,
            'views': views,
        }
    )
    return response

if __name__ == '__main__':
    response = put_viewer_count("0", "0")
    print("Put count succeeded:")
    pprint(response, sort_dicts=False)