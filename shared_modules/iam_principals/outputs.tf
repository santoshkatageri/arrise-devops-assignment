output "user_arns" {
  value = { for name, user in aws_iam_user.users : name => user.arn }
}

output "group1_name" {
  value = aws_iam_group.group1.name
}

output "group2_name" {
  value = aws_iam_group.group2.name
}
