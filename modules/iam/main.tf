resource "aws_iam_role" "lambda_exec_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.lambda_role_name}-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${var.input_bucket_name}/*",
            "arn:aws:s3:::${var.output_bucket_name}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "textract:*"
          ]
          Resource = "*"
        }
      ],
      var.dynamodb_table_arn != "" ? [
        {
          Effect = "Allow"
          Action = ["dynamodb:PutItem"]
          Resource = [var.dynamodb_table_arn]
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"  
}

