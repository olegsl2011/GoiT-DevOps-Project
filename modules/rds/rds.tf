resource "aws_db_parameter_group" "this" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name}-pg"
  family = var.parameter_group_family

  parameter {
    name  = "max_connections"
    value = tostring(var.max_connections)
  }

  parameter {
    name  = "log_statement"
    value = var.log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.work_mem
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = var.name

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  multi_az       = var.multi_az

  db_name  = var.db_name
  username = var.master_username
  password = var.master_password

  port = var.port

  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this[0].name

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  skip_final_snapshot = true
  publicly_accessible = false
  deletion_protection = var.deletion_protection

  tags = var.tags
}