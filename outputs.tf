output "loadbalancer-dns" {
  description = "Accessing the Load Balancer"
  value = "Access load balancer with: http://${module.alb.alb-dns}"
}