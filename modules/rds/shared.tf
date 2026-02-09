resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "DB access"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_cidr" {
  for_each          = toset(var.allowed_cidr_blocks)
  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
}

resource "aws_security_group_rule" "ingress_sg" {
  for_each                 = toset(var.allowed_security_group_ids)
  type                     = "ingress"
  security_group_id        = aws_security_group.this.id
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = each.value
}

locals {
  default_port = contains(["postgres", "aurora-postgresql"], var.engine) ? 5432 : 3306
  port         = coalesce(var.port, local.default_port)
}