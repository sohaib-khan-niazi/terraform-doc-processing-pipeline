# VPC
module "vpc" {
  source               = "../../modules/vpc"
  name                 = local.name
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24"]
  azs                  = ["us-east-1a"]
  region               = var.aws_region
  tags                 = local.tags
}

# S3 Module

module "s3" {
  source = "../../modules/s3"
  input_bucket_name = "${local.name}-input"
  output_bucket_name = "${local.name}-output"
  tags = local.tags
}

# DynamoDB
module "dynamodb" {
  source     = "../../modules/dynamodb"
  table_name = "${local.name}-metadata"
  tags       = local.tags
}

# IAM
module "iam" {
  source = "../../modules/iam"
  lambda_role_name = "${local.name}-lambda-role"
  input_bucket_name = module.s3.input_bucket_id 
  output_bucket_name = module.s3.output_bucket_id
  dynamodb_table_arn = module.dynamodb.table_arn  
}

# Lambda
module "lambda" {
  source              = "../../modules/lambda"
  lambda_name         = "${local.name}-lambda"
  lambda_role_arn     = module.iam.lambda_role_arn
  lambda_handler      = "lambda_function.lambda_handler"
  lambda_runtime      = "python3.9"
  memory_size         = 512
  timeout             = 30
  lambda_package      = "${path.root}/lambda_src/lambda_function.zip"

  input_bucket_name   = module.s3.input_bucket_id
  output_bucket_name  = module.s3.output_bucket_id
  dynamodb_table_name = module.dynamodb.table_name

  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.vpc.lambda_sg_id
  tags                = local.tags
}