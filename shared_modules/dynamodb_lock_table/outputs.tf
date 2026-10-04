output "table_name" {
  description = "Name of the DynamoDB lock table."
  value       = aws_dynamodb_table.terraform_locks.name
}
