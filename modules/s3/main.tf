resource "aws_s3_bucket" "input" {
  bucket = var.input_bucket_name
  force_destroy = true
  tags = var.tags  
}

resource "aws_s3_bucket" "output" {
  bucket = var.output_bucket_name
  force_destroy = true
  tags = var.tags  
}

resource "aws_s3_bucket_versioning" "input" {
  bucket = aws_s3_bucket.input.id
  
  versioning_configuration {
    status = "Enabled"
  }  
}

resource "aws_s3_bucket_versioning" "output" {
  bucket = aws_s3_bucket.output.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "input_policy" {
  bucket = aws_s3_bucket.input.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "textract.amazonaws.com"
        },
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::${var.input_bucket_name}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket.input]
}
