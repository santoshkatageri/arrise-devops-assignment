output "state_bucket" {
  description = "S3 bucket used by the Task 1 backend."
  value       = module.s3_bucket.bucket_name
}

output "lock_table" {
  description = "DynamoDB table used for Terraform state locking."
  value       = module.dynamodb_lock_table.table_name
}
