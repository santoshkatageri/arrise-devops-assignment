resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = var.trust_policy
}

resource "aws_iam_role_policy" "permissions" {
  name   = "${var.name}-permissions"
  role   = aws_iam_role.this.id
  policy = var.permissions_policy
}
