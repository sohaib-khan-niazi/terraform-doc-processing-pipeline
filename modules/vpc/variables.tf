variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string  
}

variable "private_subnet_cidrs" {
  type = list(string)  
}

variable "azs" {
  type = list(string)  
}

variable "region" {
  type = string 
}

variable "tags" {
  type = map(string)
}
