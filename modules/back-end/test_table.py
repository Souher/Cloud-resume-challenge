from pprint import pprint
import unittest
import boto3 
from botocore.exceptions import ClientError
from moto import mock_dynamodb2 

@mock_dynamodb2
class TestDatabaseFunctions(unittest.TestCase):

    def setUp(self):
        self.dynamodb = boto3.resource('dynamodb', region_name='eu-west-2')
        
        from create_mock_table import create_table
        self.table = create_table(self.dynamodb) 

    def tearDown(self):
        self.table.delete()
        self.dynamodb=None
    
    def test_table_exists(self):
      self.assertIn('visitor-count', self.table.name)
      pprint(self.table)

    def test_put_movie(self):
        from test_put_item import put_viewer_count

        result = put_viewer_count("0", "0", self.dynamodb)
        
        self.assertEqual(200, result['ResponseMetadata']['HTTPStatusCode'])
    
    def test_get_movie(self):
        from test_put_item import put_viewer_count
        from test_get_item import get_viewer_count

        put_viewer_count("0", "0", self.dynamodb)
        result = get_viewer_count("0", "0", self.dynamodb)

        self.assertEqual("0", result['viewcount'])
        self.assertEqual("0", result['views'])
        pprint(result)

if __name__ == '__main__':
    unittest.main()
    