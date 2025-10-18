variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
