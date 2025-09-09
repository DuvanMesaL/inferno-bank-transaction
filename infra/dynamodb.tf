resource "aws_dynamodb_table" "transactions" {
  name         = "transactions-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "userId"
  range_key = "txId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "txId"
    type = "S"
  }

  tags = {
    Project = "inferno-bank-transactions"
    Stage   = "dev"
  }
}
