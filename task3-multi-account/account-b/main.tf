data "aws_s3_bucket" "target" {
  bucket = var.bucket_name
}

data "aws_iam_policy_document" "role_c_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.role_b_arn]
    }
  }
}
data "aws_iam_policy_document" "role_c_permissions" {
  statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
  }
}
module "role_c" {
  source             = "./modules/iam_role"
  name               = "roleC"
  trust_policy       = data.aws_iam_policy_document.role_c_trust.json
  permissions_policy = data.aws_iam_policy_document.role_c_permissions.json
}
