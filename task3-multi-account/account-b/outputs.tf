output "role_c_arn" {
  value = module.role_c.arn
}
output "bucket_name" {
  value = data.aws_s3_bucket.target.bucket
}
