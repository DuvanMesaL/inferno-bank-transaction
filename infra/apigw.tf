resource "aws_api_gateway_rest_api" "api" {
  name = "inferno-bank-transactions-api"
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "user_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{user_id}"
}

resource "aws_api_gateway_resource" "transactions" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.user_id.id
  path_part   = "transactions"
}

resource "aws_api_gateway_method" "get_transactions" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.transactions.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_transactions" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.transactions.id
  http_method             = aws_api_gateway_method.get_transactions.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.list_transactions.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke_list" {
  statement_id  = "AllowAPIGatewayInvokeList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_transactions.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.get_transactions.http_method}${aws_api_gateway_resource.transactions.path}"
}

resource "aws_api_gateway_deployment" "dep" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeploy = timestamp()
  }

  depends_on = [
    aws_api_gateway_integration.get_transactions
  ]
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.dep.id
  stage_name    = "dev"
}