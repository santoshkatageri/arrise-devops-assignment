module "iam_principals" {
  source        = "./modules/iam_principals"
  cli_users     = ["engine", "ci"]
  console_users = ["santosh", "kiran"]
}

data "aws_iam_policy_document" "role_a_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [module.iam_principals.user_arns["santosh"], module.iam_principals.user_arns["kiran"]]
    }
  }
}
data "aws_iam_policy_document" "role_a_permissions" {
  statement {
    effect      = "Allow"
    not_actions = ["iam:*"]
    resources   = ["*"]
  }
  statement {
    effect    = "Deny"
    actions   = ["iam:*"]
    resources = ["*"]
  }
}
module "role_a" {
  source             = "./modules/iam_role"
  name               = "roleA"
  trust_policy       = data.aws_iam_policy_document.role_a_trust.json
  permissions_policy = data.aws_iam_policy_document.role_a_permissions.json
}

data "aws_iam_policy_document" "role_b_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [module.iam_principals.user_arns["engine"]]
    }
  }
}
data "aws_iam_policy_document" "role_b_permissions" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.account_b_id}:role/roleC"]
  }
}
module "role_b" {
  source             = "./modules/iam_role"
  name               = "roleB"
  trust_policy       = data.aws_iam_policy_document.role_b_trust.json
  permissions_policy = data.aws_iam_policy_document.role_b_permissions.json
}

data "aws_iam_policy_document" "engine_assume_role_b" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [module.role_b.arn]
  }
}

module "engine_assume_role_b" {
  source      = "./modules/iam_user_policy"
  name        = "assume-roleB"
  user_name   = "engine"
  policy_json = data.aws_iam_policy_document.engine_assume_role_b.json
  depends_on  = [module.iam_principals]
}

module "ci_policy" {
  source      = "./modules/iam_user_policy"
  name        = "ci-pipeline-least-privilege"
  user_name   = "ci"
  policy_json = file("${path.module}/ci-policy.json")
  depends_on  = [module.iam_principals]
}
module "group2_assume_role" {
  source     = "./modules/iam_group_assume_role"
  group_name = module.iam_principals.group2_name
  role_arn   = module.role_a.arn
}
