# Lambda function

resource "aws_lambda_function" "doc_processor" {
  function_name = var.lambda_name
  role = var.lambda_role_arn
  handler = var.lambda_handler
  runtime = var.lambda_runtime
  memory_size = var.memory_size
  timeout = var.timeout

  filename = "${path.root}/../../lambda_src/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.root}/../../lambda_src/lambda_function.zip")

  environment {
    variables = {
      INPUT_BUCKET = var.input_bucket_name
      OUTPUT_BUCKET = var.output_bucket_name
      DYNAMODB_TABLE = var.dynamodb_table_name 
    }
  }

  # vpc_config {
  #   subnet_ids = var.private_subnet_ids
  #   security_group_ids = [var.security_group_id]
  # }
  
  tags = var.tags   
}

# Lambda permissions

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.doc_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.input_bucket_name}"
}

# S3 Trigger -> Lambda

resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = var.input_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.doc_processor.arn
    events = ["s3:ObjectCreated:*"]
  }

  depends_on = [ aws_lambda_function.doc_processor, aws_lambda_permission.allow_s3 ]  
}
