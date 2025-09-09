resource "aws_lambda_function" "process_card_request" {
  function_name    = "inferno-bank-transactions-process"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "nodejs20.x"
  handler          = "index.processCardRequest"
  filename         = "${path.module}/app.zip"
  source_code_hash = filebase64sha256("${path.module}/app.zip")

  environment {
    variables = { TX_TABLE = aws_dynamodb_table.transactions.name }
  }
}

resource "aws_lambda_function" "list_transactions" {
  function_name    = "inferno-bank-transactions-list"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "nodejs20.x"
  handler          = "index.listTransactions"
  filename         = "${path.module}/app.zip"
  source_code_hash = filebase64sha256("${path.module}/app.zip")

  environment {
    variables = { TX_TABLE = aws_dynamodb_table.transactions.name }
  }
}
