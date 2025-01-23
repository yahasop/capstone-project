#Prints the ALB DNS to the console, to access it easily
output "loadbalancer-dns" {
  description = "Accessing the Load Balancer"
  value       = "Access the application load balancer with: http://${module.alb.alb-dns}"
}

output "webloadbalancer-dns" {
  description = "Accessing the Web Load Balancer"
  value       = "Access the web load balancer with: http://${module.alb.alb-web-dns}"
}

#Prints Instances' public IPs
output "instances-ip" {
  description = "ASG Instances Public IP's"
  value       = data.aws_instances.asg_instances[*].public_ips #Referencing the ASG data source
}

#Prints Instances' private IPs
output "private-instances-ip" {
  description = "ASG Instances Private IP's"
  value       = data.aws_instances.asg_instances[*].private_ips #Referencing the ASG data source
}