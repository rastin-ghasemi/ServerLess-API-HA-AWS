    # Read Function in Primary Region
    resource "aws_lambda_function" "read_function_primary" {
    provider      = aws.primary
    filename      = "read_function.zip"
    function_name = "ReadFunction"
    role          = aws_iam_role.lambda_dynamodb_role_primary.arn # Direct reference!
    handler       = "read_function.lambda_handler"
    runtime       = "python3.9"

    environment {
        variables = {
        TABLE_NAME = "HighAvailabilityTable"
        }
    }
    }

    # Write Function in Primary Region
    resource "aws_lambda_function" "write_function_primary" {
    provider      = aws.primary
    filename      = "write_function.zip"
    function_name = "WriteFunction"
    role          = aws_iam_role.lambda_dynamodb_role_primary.arn  # Direct reference!
    handler       = "write_function.lambda_handler"
    runtime       = "python3.9"

    environment {
        variables = {
        TABLE_NAME = "HighAvailabilityTable"
        }
    }
    }

    # Read Function in Secondary Region
    resource "aws_lambda_function" "read_function_secondary" {
    provider      = aws.secondary
    filename      = "read_function.zip"
    function_name = "ReadFunction"
    role          = aws_iam_role.lambda_dynamodb_role_secondary.arn
    handler       = "read_function.lambda_handler"
    runtime       = "python3.9"

    environment {
        variables = {
        TABLE_NAME = "HighAvailabilityTable"
        }
    }
    }

    # Write Function in Secondary Region
    resource "aws_lambda_function" "write_function_secondary" {
    provider      = aws.secondary
    filename      = "write_function.zip"
    function_name = "WriteFunction"
    role          = aws_iam_role.lambda_dynamodb_role_secondary.arn # Direct reference!
    handler       = "write_function.lambda_handler"
    runtime       = "python3.9"

    environment {
        variables = {
        TABLE_NAME = "HighAvailabilityTable"
        }
    }
    }