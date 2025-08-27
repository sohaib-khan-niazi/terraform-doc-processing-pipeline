variable "lambda_role_name" {
  type = string  
}

variable "input_bucket_name" {
  type = string
}

variable "output_bucket_name" {
  type = string  
}

variable "dynamodb_table_arn" {
  type = string
  default = ""  
}
