locals {
  all_users = setunion(var.cli_users, var.console_users)
}

resource "aws_iam_group" "group1" {
  name = "group1"
}

resource "aws_iam_group" "group2" {
  name = "group2"
}

resource "aws_iam_user" "users" {
  for_each      = local.all_users
  name          = each.key
  force_destroy = false
}

resource "aws_iam_group_membership" "group1" {
  name  = "group1-membership"
  group = aws_iam_group.group1.name
  users = [for name in var.cli_users : aws_iam_user.users[name].name]
}

resource "aws_iam_group_membership" "group2" {
  name  = "group2-membership"
  group = aws_iam_group.group2.name
  users = [for name in var.console_users : aws_iam_user.users[name].name]
}
