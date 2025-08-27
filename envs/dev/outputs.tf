output "s3_input_bucket" {
  value = module.s3.input_bucket_id
}

output "s3_output_bucket" {
  value = module.s3.output_bucket_id  
}

output "lambda_role_arn" {
  value = module.iam.lambda_role_arn  
}
