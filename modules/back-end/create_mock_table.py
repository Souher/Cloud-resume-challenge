from pprint import pprint
import boto3

def create_table(dynamodb):
    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.create_table(
        TableName='visitor-count',
        KeySchema=[
            {
                'AttributeName': 'viewcount',
                'KeyType': 'HASH'
            }
        ],
        AttributeDefinitions=[
            {
                'AttributeName': 'viewcount',
                'AttributeType': 'S'
            }
        ],
        BillingMode='PAY_PER_REQUEST'
    )

    table.meta.client.get_waiter('table_exists').wait(TableName='visitor-count')
    assert table.table_status == 'ACTIVE'

    return table

if __name__ == '__main__':
    table = create_table()
    print("Table status:", table.table_status)