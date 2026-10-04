variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "account_a_id" {
  type        = string
  description = "Actual 12-digit Account A ID; provider refuses a different account."
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_a_id))
    error_message = "Enter a 12-digit AWS account ID."
  }
}
variable "account_b_id" {
  type        = string
  description = "Actual 12-digit Account B ID for roleC."
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_b_id)) && var.account_b_id != "111111111111"
    error_message = "Enter the real 12-digit Account B ID, not the assignment placeholder."
  }
}
