# Free Tier trial: standard, gp2, and gp3 root volumes only.
# This variant does not meet the assignment io1/io2 requirement.
aws_region = "ap-south-1"

instances = {
  "arrise-dev-01" = {
    ami_id               = "ami-08e3b3155fc937a94"
    instance_type        = "t3.micro"
    subnet_id            = "subnet-007a49ec1b0927c1d"
    security_group_ids   = ["sg-0de8065680f713505"]
    key_name             = "arrise-ssh-key"
    root_volume_type     = "standard"
    root_volume_size_gib = 8
    environment          = "dev"
    owner                = "devops"
  }

  "arrise-dev-02" = {
    ami_id               = "ami-08e3b3155fc937a94"
    instance_type        = "t3.small"
    subnet_id            = "subnet-007a49ec1b0927c1d"
    security_group_ids   = ["sg-0de8065680f713505"]
    key_name             = "arrise-ssh-key"
    root_volume_type     = "gp2"
    root_volume_size_gib = 16
    environment          = "dev"
    owner                = "devops"
  }

  "arrise-dev-03" = {
    ami_id               = "ami-08e3b3155fc937a94"
    instance_type        = "t8i.micro"
    subnet_id            = "subnet-007a49ec1b0927c1d"
    security_group_ids   = ["sg-0de8065680f713505"]
    key_name             = "arrise-ssh-key"
    root_volume_type     = "gp3"
    root_volume_size_gib = 24
    environment          = "dev"
    owner                = "devops"
  }

  "arrise-dev-04" = {
    ami_id               = "ami-08e3b3155fc937a94"
    instance_type        = "c7i-flex.large"
    subnet_id            = "subnet-007a49ec1b0927c1d"
    security_group_ids   = ["sg-0de8065680f713505"]
    key_name             = "arrise-ssh-key"
    root_volume_type     = "gp3"
    root_volume_size_gib = 32
    environment          = "dev"
    owner                = "devops"
  }

  "arrise-dev-05" = {
    ami_id                = "ami-08e3b3155fc937a94"
    instance_type         = "m7i-flex.large"
    subnet_id             = "subnet-007a49ec1b0927c1d"
    security_group_ids    = ["sg-0de8065680f713505"]
    key_name              = "arrise-ssh-key"
    root_volume_type      = "gp3"
    root_volume_size_gib  = 40
    root_volume_iops      = 3000
    environment           = "dev"
    owner                 = "devops"
    protect_from_deletion = true
  }
}
