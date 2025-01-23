output "alb-id" {
  value = aws_lb.my-alb.id
}

output "alb-tg-arn" {
  value = aws_lb_target_group.my-alb-tg.arn
}

output "alb-dns" {
  value = aws_lb.my-alb.dns_name
}

output "alb-web-dns" {
  value = aws_lb.my-alb-webserver.dns_name
}

output "alb-tg-webserver-arn" {
  value = aws_lb_target_group.my-alb-tg-webserver.arn
}