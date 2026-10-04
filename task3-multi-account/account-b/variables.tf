variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "account_b_id" {
  type        = string
  description = "Actual Account B ID; provider refuses a different account."
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_b_id)) && var.account_b_id != "111111111111"
    error_message = "Enter the real 12-digit Account B ID, not the assignment placeholder."
  }
}
variable "role_b_arn" {
  type        = string
  description = "Exact roleB ARN output by Account A Terraform."
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/roleB$", var.role_b_arn))
    error_message = "Enter Account A's exact roleB ARN."
  }
}
variable "bucket_name" {
  type        = string
  description = "Globally unique name of the single bucket roleC can access."
}
