output "vpc_id" {
  value = aws_vpc.this.id  
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id  
}

output "dynamodb_vpc_endpoint_id" {
  value = aws_vpc_endpoint.dynamodb.id  
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id  
}
