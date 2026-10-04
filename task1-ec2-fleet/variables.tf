variable "aws_region" {
  description = "AWS Region in which to create the instances."
  type        = string
}

variable "instances" {
  description = "The five EC2 instances, keyed by the value to use for each Name tag."
  type = map(object({
    ami_id                = string
    instance_type         = string
    subnet_id             = string
    security_group_ids    = list(string)
    key_name              = string
    root_volume_type      = string
    root_volume_size_gib  = number
    root_volume_iops      = optional(number)
    protect_from_deletion = optional(bool, false)
    environment           = string
    owner                 = string
  }))
}
