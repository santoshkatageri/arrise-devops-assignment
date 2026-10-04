resource "aws_iam_user_policy" "this" {
  name   = var.name
  user   = var.user_name
  policy = var.policy_json
}
