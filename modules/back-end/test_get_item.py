
from pprint import pprint
import boto3
from botocore.exceptions import ClientError


def get_viewer_count(count, views, dynamodb):
    table = dynamodb.Table('visitor-count')

    try:
        response = table.get_item(Key={'viewcount': count, 'views': views})
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return response['Item']


if __name__ == '__main__':
    amount_of_views = get_viewer_count("0", "0")
    if amount_of_views:
        print("Get count succeeded:")
        pprint(amount_of_views, sort_dicts=False)