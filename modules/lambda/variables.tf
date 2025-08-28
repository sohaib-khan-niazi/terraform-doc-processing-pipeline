variable "lambda_name" {
  type = string  
}

variable "lambda_role_arn" {
  type = string
}

variable "lambda_handler" {
  type = string
  default = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  type = string  
}

variable "memory_size" {
  type = string  
}

variable "timeout" {
  type = string  
}

variable "lambda_package" {
  type = string  
}

variable "input_bucket_name" {
  type = string
}

variable "output_bucket_name" {
  type = string  
}

variable "dynamodb_table_name" {
  type = string
}

variable "tags" {
  type = map(string)  
}
