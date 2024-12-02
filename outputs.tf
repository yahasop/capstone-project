output "loadbalancer-dns" {
  description = "Accessing the Load Balancer"
  value = "Access load balancer with: http://${module.alb.alb-dns}"
}

output "instances-ip" {
  description = "ASG Instances Public IP's"
  value = data.aws_instances.asg_instances[*].public_ips
}

output "private-instances-ip" {
  description = "ASG Instances Private IP's"
  value = data.aws_instances.asg_instances[*].private_ips
}