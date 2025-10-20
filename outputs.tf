output "api_base_url" {
  value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.dev.name}"
}
output "table_name" { value = aws_dynamodb_table.dynamo-table.name }
output "lambda_name" { value = aws_lambda_function.api.function_name }
