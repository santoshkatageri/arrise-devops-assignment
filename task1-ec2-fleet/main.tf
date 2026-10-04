module "ec2_fleet" {
  source    = "./modules/ec2_fleet"
  instances = var.instances
}
