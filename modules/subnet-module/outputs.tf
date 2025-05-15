output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "subnet_vpc_id" {
  value = aws_subnet.subnet.vpc_id
}

output "subnet_name" {
    value = aws_subnet.subnet.tags["Name"]
}
