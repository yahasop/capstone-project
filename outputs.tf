#Prints the ALB DNS to the console, to access it easily
output "loadbalancer-dns" {
  description = "Accessing the Load Balancer"
  value = "Access load balancer with: http://${module.alb.alb-dns}"
}

#Prints Instances' public IPs
output "instances-ip" {
  description = "ASG Instances Public IP's"
  value = data.aws_instances.asg_instances[*].public_ips
}

#Prints Instances' private IPs
output "private-instances-ip" {
  description = "ASG Instances Private IP's"
  value = data.aws_instances.asg_instances[*].private_ips
}