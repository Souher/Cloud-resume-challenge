resource "aws_apigatewayv2_api" "counter_gateway" {
  name        = var.api-gatewayv2-name
  description = "Receive count increase from front end and return count from dynamoDB"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["https://souhercloudresume.com"]
    allow_methods = ["POST", "GET"]
    allow_headers = ["content-type"]
    max_age = 300
  }
}

resource "aws_lambda_permission" "read_api_gw" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.read_function.arn
	principal     = "apigateway.amazonaws.com"

	source_arn = "${aws_apigatewayv2_api.counter_gateway.execution_arn}/*/*"
}

resource "aws_lambda_permission" "write_api_gw" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.write_function.arn
	principal     = "apigateway.amazonaws.com"

	source_arn = "${aws_apigatewayv2_api.counter_gateway.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "stage_gateway" {
  api_id = aws_apigatewayv2_api.counter_gateway.id
  name   = var.staging-name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_log.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "read_integration_gateway" {
  api_id           = aws_apigatewayv2_api.counter_gateway.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.read_function.invoke_arn
}

resource "aws_apigatewayv2_route" "read_route_gateway" {
  api_id    = aws_apigatewayv2_api.counter_gateway.id
  route_key = "GET /read"

  target = "integrations/${aws_apigatewayv2_integration.read_integration_gateway.id}"
}

resource "aws_apigatewayv2_integration" "write_integration_gateway" {
  api_id           = aws_apigatewayv2_api.counter_gateway.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.write_function.invoke_arn
}

resource "aws_apigatewayv2_route" "write_route_gateway" {
  api_id    = aws_apigatewayv2_api.counter_gateway.id
  route_key = "POST /write"

  target = "integrations/${aws_apigatewayv2_integration.write_integration_gateway.id}"
}

resource "aws_cloudwatch_log_group" "api_gw_log" {
  name = "${aws_apigatewayv2_api.counter_gateway.name}"

  retention_in_days = 1
}

resource "aws_iam_role" "lambda_assume_role" {
  name = "lambda-assume-role"

  assume_role_policy = file("${path.module}/assume_role_policy.json")
}

resource "aws_iam_role_policy" "lambda_dynamo_permissions_policy" {
  name = "lambda-dynamo-permissions-policy"
  role = aws_iam_role.lambda_assume_role.id

  policy = file("${path.module}/read_write_policy.json")
}

data "archive_file" "lambda_read_functions" {
  type        = "zip"
  source_file = "${path.module}/readfunction.py"
  output_path = "readfunction.zip"
}

data "archive_file" "lambda_write_functions" {
  type        = "zip"
  source_file = "${path.module}/writefunction.py"
  output_path = "writefunction.zip"
}

resource "aws_s3_bucket" "lambda_functions_bucket" {
  bucket = var.lambda-bucket-name
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "upload_read_function" {
  bucket = aws_s3_bucket.lambda_functions_bucket.id

  key    = "readfunction.zip"
  source = data.archive_file.lambda_read_functions.output_path

  etag = filemd5(data.archive_file.lambda_read_functions.output_path)
}

resource "aws_s3_bucket_object" "upload_write_function" {
  bucket = aws_s3_bucket.lambda_functions_bucket.id

  key    = "writefunction.zip"
  source = data.archive_file.lambda_write_functions.output_path

  etag = filemd5(data.archive_file.lambda_write_functions.output_path)
}

resource "aws_lambda_function" "write_function" {

  function_name = var.write-function-name
  s3_bucket     = aws_s3_bucket.lambda_functions_bucket.id
  s3_key        = "writefunction.zip"
  role          = aws_iam_role.lambda_assume_role.arn
  handler       = "writefunction.lambda_handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.lambda_write_functions.output_base64sha256
}

resource "aws_lambda_function" "read_function" {

  function_name = var.read-function-name
  s3_bucket     = aws_s3_bucket.lambda_functions_bucket.id
  s3_key        = "readfunction.zip"
  role          = aws_iam_role.lambda_assume_role.arn
  handler       = "readfunction.lambda_handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.lambda_read_functions.output_base64sha256

}

resource "aws_dynamodb_table" "ddb_table" {
  name           = "visitor-count"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "viewcount"

  attribute {
    name = "viewcount"
    type = "S"
  }
}