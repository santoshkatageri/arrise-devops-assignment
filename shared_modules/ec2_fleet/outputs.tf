output "instance_ids" {
  description = "Map of instance name to EC2 instance ID."
  value = merge(
    { for name, instance in aws_instance.protected : name => instance.id },
    { for name, instance in aws_instance.regular : name => instance.id }
  )
}

output "private_ips" {
  description = "Map of instance name to private IP address."
  value = merge(
    { for name, instance in aws_instance.protected : name => instance.private_ip },
    { for name, instance in aws_instance.regular : name => instance.private_ip }
  )
}
