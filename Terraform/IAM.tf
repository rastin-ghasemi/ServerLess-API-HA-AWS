###########################################
# Primary Region IAM Role & Policies      #
###########################################

# Create IAM Role in PRIMARY region
resource "aws_iam_role" "lambda_dynamodb_role_primary" {
  provider = aws.primary
  name     = "LambdaDynamoDBRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonDynamoDBFullAccess policy to PRIMARY role
resource "aws_iam_role_policy_attachment" "dynamodb_full_access_primary" {
  provider   = aws.primary
  role       = aws_iam_role.lambda_dynamodb_role_primary.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Attach AWSLambdaBasicExecutionRole policy to PRIMARY role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_primary" {
  provider   = aws.primary
  role       = aws_iam_role.lambda_dynamodb_role_primary.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###########################################
# Secondary Region IAM Role & Policies    #
###########################################

# Create IAM Role in SECONDARY region
resource "aws_iam_role" "lambda_dynamodb_role_secondary" {
  provider = aws.secondary
  name     = "LambdaDynamoDBRole-secondry"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonDynamoDBFullAccess policy to SECONDARY role
resource "aws_iam_role_policy_attachment" "dynamodb_full_access_secondary" {
  provider   = aws.secondary
  role       = aws_iam_role.lambda_dynamodb_role_secondary.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Attach AWSLambdaBasicExecutionRole policy to SECONDARY role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_secondary" {
  provider   = aws.secondary
  role       = aws_iam_role.lambda_dynamodb_role_secondary.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


##############################################
# Give API Gateway Permission to Call Lambda #
##############################################
resource "aws_lambda_permission" "read_function_permission_primary" {
  provider      = aws.primary
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_function_primary.function_name
  principal     = "apigateway.amazonaws.com"  # Who gets permission
  source_arn    = "${aws_api_gateway_rest_api.primary_api.execution_arn}/*/GET/read"  # Which API method
}
resource "aws_lambda_permission" "write_function_permission_primary" {
  provider      = aws.primary
  statement_id  = "AllowAPIGatewayInvokeWrite"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.write_function_primary.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.primary_api.execution_arn}/*/POST/write"
}


# Lambda permissions for secondary region
resource "aws_lambda_permission" "secondary_read" {
  provider      = aws.secondary
  statement_id  = "AllowAPIGatewayInvokeRead"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_function_secondary.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.secondary_api.execution_arn}/*/GET/read"
}

resource "aws_lambda_permission" "secondary_write" {
  provider      = aws.secondary
  statement_id  = "AllowAPIGatewayInvokeWrite"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.write_function_secondary.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.secondary_api.execution_arn}/*/POST/write"
}

