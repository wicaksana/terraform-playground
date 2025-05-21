output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "igw" {
  value = aws_internet_gateway.main_igw.id
}

output "server_ip_addr" {
  value = aws_instance.server.public_ip
}