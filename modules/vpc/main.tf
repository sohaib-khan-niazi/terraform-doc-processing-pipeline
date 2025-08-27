resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = merge(var.tags, { Name = "${var.name}-vpc"}) 
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnet_cidrs[count.index] 
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, { Name = "${var.name}-private-${count.index}" })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "${var.name}-private-rt" })
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs) 
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id 
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [for assoc in aws_route_table_association.private : assoc.route_table_id]

  tags = merge(var.tags, { Name = "${var.name}-s3-endpoint" })
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [for assoc in aws_route_table_association.private : assoc.route_table_id]

  tags = merge(var.tags, { Name = "${var.name}-dynamodb-endpoint" })
}

resource "aws_security_group" "lambda_sg" {
  name = "${var.name}-lambda-sg"
  vpc_id = aws_vpc.this.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 443
  #   to_port = 443
  #   protocol = "tcp"
  #   security_groups = [aws_security_group.lambda_sg.id]
  # }
    
  tags = merge(var.tags, {Name = "${var.name}-lambda-sg"})  
}

resource "aws_security_group_rule" "lambda_https_self" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

resource "aws_vpc_endpoint" "textract" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.textract"
  vpc_endpoint_type  = "Interface"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
  tags = merge(var.tags, { Name = "${var.name}-textract-endpoint" })
}