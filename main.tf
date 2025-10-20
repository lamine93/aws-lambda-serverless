# ---- DynamoDB table ----
resource "aws_dynamodb_table" "dynamo-table" {
  name         = "${var.project}-users-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"

  attribute { 
    name = "UserId"
    type = "S" 
  }
}

# ---- Lambda packaging ----
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# ---- IAM role pour Lambda ----
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { 
        type = "Service"
        identifiers = ["lambda.amazonaws.com"] 
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-lambda-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

# Policy minimaliste: logs + accès à la table
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid     = "Logs"
    actions = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
    resources = ["*"]
  }
  statement {
    sid     = "DdbAccess"
    actions = ["dynamodb:PutItem","dynamodb:Scan"]
    resources = [aws_dynamodb_table.dynamo-table.arn]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.project}-lambda-policy-${var.env}"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# ---- Lambda ----
resource "aws_lambda_function" "api" {
  function_name = "${var.project}-api-${var.env}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.dynamo-table.name
      ALLOWED_ORIGIN = var.allowed_origin  # CORS front (Amplify)
    }
  }
}

# ---- API Gateway HTTP API ----
resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project}-http-${var.env}"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins     = [var.allowed_origin]
    allow_methods     = ["GET","POST","OPTIONS"]
    allow_headers     = ["authorization","content-type"] # ⚠️ minuscules
    allow_credentials = false
    max_age           = 3600
  }
}

# Intégration Lambda
resource "aws_apigatewayv2_integration" "lambda_integ" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "get_users" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /users"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integ.id}"
}

resource "aws_apigatewayv2_route" "post_users" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /users"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integ.id}"
}

# Stage auto-deploy
resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = var.env
  auto_deploy = true
}

# Permission pour que l'API appelle la Lambda
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowInvokeByApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
