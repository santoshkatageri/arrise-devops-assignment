locals {
  protected_instances = {
    for name, instance in var.instances : name => instance
    if instance.protect_from_deletion
  }

  regular_instances = {
    for name, instance in var.instances : name => instance
    if !instance.protect_from_deletion
  }
}

resource "aws_instance" "protected" {
  for_each = local.protected_instances

  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  key_name               = each.value.key_name

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size_gib
    iops        = each.value.root_volume_iops
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "regular" {
  for_each = local.regular_instances

  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  key_name               = each.value.key_name

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size_gib
    iops        = each.value.root_volume_iops
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
  }
}
