output "endpoint" {
  value = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "reader_endpoint" {
  value = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "port" {
  value = local.port
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "master_username" {
  value     = var.master_username
  sensitive = false
}

output "db_name" {
  value = var.db_name
}