variable "table_name" {
  description = "Name of the DynamoDB table used for state locking."
  type        = string
}

variable "tags" {
  description = "Tags for the DynamoDB table."
  type        = map(string)
  default     = {}
}
