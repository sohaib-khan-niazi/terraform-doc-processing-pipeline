resource "aws_dynamodb_table" "doc_metadata" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "filename"

  attribute {
    name = "filename"
    type = "S"
  }

  tags = var.tags
}
