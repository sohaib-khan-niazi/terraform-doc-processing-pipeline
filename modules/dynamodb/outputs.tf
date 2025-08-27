output "table_name" {
  value = aws_dynamodb_table.doc_metadata.name  
}

output "table_arn" {
  value = aws_dynamodb_table.doc_metadata.arn  
}
