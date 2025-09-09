# Quién soy (para armar ARNs)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Rol que asumen las Lambdas
resource "aws_iam_role" "lambda_role" {
  name = "inferno-bank-transactions-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Permisos mínimos: logs + DynamoDB + SQS
resource "aws_iam_role_policy" "lambda_inline" {
  name = "inferno-bank-transactions-inline"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logs
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      # DynamoDB (tabla de transacciones)
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:GetItem"
        ],
        Resource = aws_dynamodb_table.transactions.arn
      },
      # SQS (leer y borrar mensajes de la cola de users)
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = data.aws_sqs_queue.card_requests.arn
      }
    ]
  })
}
