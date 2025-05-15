output "nat_id" {
  value = aws_nat_gateway.gw.id
}

output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}

output "alb_id" {
  value = aws_lb.alb_server.id
}