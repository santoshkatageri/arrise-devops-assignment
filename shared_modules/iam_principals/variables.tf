variable "cli_users" {
  type        = set(string)
  description = "IAM users with CLI access only."
}

variable "console_users" {
  type        = set(string)
  description = "IAM users with console and CLI access."
}
