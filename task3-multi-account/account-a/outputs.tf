output "role_b_arn" {
  description = "Pass this exact ARN to Account B's role_b_arn variable."
  value       = module.role_b.arn
}
output "role_a_arn" {
  value = module.role_a.arn
}
