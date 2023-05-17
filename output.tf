# Output VPC and subnet IDs
output "vpc_id" {
  value = var.environment == "nonprod" ? aws_vpc.vpc-non-prod[0].id : aws_vpc.vpc-prod[0].id
}

output "private_subnet_ids" {
  value = var.environment == "nonprod" ? aws_subnet.private.*.id : aws_subnet.prod_private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_route_table" {
  value = aws_route_table.public.*.id
}

output "private_route_table" {
  value = aws_route_table.private.*.id
}