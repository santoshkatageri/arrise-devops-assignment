data "aws_iam_policy_document" "assume_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [var.role_arn]
  }
}

resource "aws_iam_group_policy" "assume_role" {
  name   = "assume-assigned-role"
  group  = var.group_name
  policy = data.aws_iam_policy_document.assume_role.json
}
