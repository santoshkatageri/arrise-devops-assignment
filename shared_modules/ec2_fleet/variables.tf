variable "instances" {
  description = "Exactly five EC2 definitions, keyed by instance name."
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

  validation {
    condition     = length(var.instances) == 5
    error_message = "Provide exactly five instances."
  }

  validation {
    condition = (
      length(distinct([for instance in values(var.instances) : instance.instance_type])) == 5 &&
      length(distinct([for instance in values(var.instances) : instance.root_volume_size_gib])) == 5
    )
    error_message = "Instance types and root volume sizes must each be distinct."
  }

  validation {
    condition = (
      alltrue([for instance in values(var.instances) : contains(["standard", "gp2", "gp3", "io1", "io2"], instance.root_volume_type)])
    )
    error_message = "Use supported EBS root volume types."
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      contains(["io1", "io2"], instance.root_volume_type) ? instance.root_volume_iops != null : (instance.root_volume_type == "gp3" ? (instance.root_volume_iops == null || instance.root_volume_iops >= 3000) : instance.root_volume_iops == null)
    ])
    error_message = "Set root_volume_iops for io1/io2; gp3 may specify 3000 or more; omit it for standard/gp2."
  }

  validation {
    condition     = length([for instance in values(var.instances) : instance if instance.protect_from_deletion]) == 1
    error_message = "Mark exactly one instance with protect_from_deletion so it receives lifecycle deletion protection."
  }
}
