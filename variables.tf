variable "AWS_REGION" {
  default = "eu-west-2"
}

variable "AZ" {
  description = "Availability Zone"
  type        = list
  default     = ["eu-west-2a","eu-west-2b","eu-west-2c"] 
}

variable "environment" {
  description = "environment"
  default     = "test"
}

variable "VPC_CIDR" {
  description = "CIDR block of the vpc"
}

variable "PUB_CIDR" {
  type        = list
  description = "CIDR block of the public subnet"
}

variable "PRIV_CIDR" {
  type        = list
  description = "CIDR block of the private subnet"
}

variable "ami_type" {
  description = "AMI to create EC2 instance"
  default     = ""
}

variable "instance_types" {
  description = "Type of EC2 instance"
  default     = ""
}