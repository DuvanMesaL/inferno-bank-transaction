# parametrizable por si cambias stage/proyecto
variable "card_requests_queue_name" {
  type    = string
  default = "inferno-bank-users-dev-card-requests"
}

data "aws_sqs_queue" "card_requests" {
  name = var.card_requests_queue_name
}

resource "aws_lambda_event_source_mapping" "from_card_requests" {
  event_source_arn = data.aws_sqs_queue.card_requests.arn
  function_name    = aws_lambda_function.process_card_request.arn
  batch_size       = 5
}