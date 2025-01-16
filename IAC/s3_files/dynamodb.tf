resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Chat-Messages"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ConversationId"
  range_key      = "Timestamp"

  attribute {
    name = "ConversationId"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "table2" {
  name           = "Chat-Conversations"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ConversationId"
  range_key      = "Username"

  attribute {
    name = "ConversationId"
    type = "S"
  }

  attribute {
    name = "Username"
    type = "S"
  }


  global_secondary_index {
    name            = "Username-ConversationId-index"
    hash_key        = "Username"
    range_key       = "ConversationId"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }

  tags = {
    Name        = "dynamodb-table-2"
    Environment = "production"
  }
}
