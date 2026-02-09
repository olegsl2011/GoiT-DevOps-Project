variable "name" {
  description = "Base name/identifier for DB resources"
  type        = string
}

variable "use_aurora" {
  description = "true = Aurora Cluster, false = single RDS instance"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access DB port"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "allowed_security_group_ids" {
  description = "List of Security Group IDs allowed to access the DB (in addition to CIDR rules)."
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "DB engine. For RDS: postgres/mysql. For Aurora: aurora-postgresql/aurora-mysql"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Multi-AZ for RDS instance (ignored for Aurora)"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "master_username" {
  description = "Master username"
  type        = string
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "DB port"
  type        = number
  default     = 5432
}

variable "parameter_group_family" {
  description = "RDS parameter group family (e.g., postgres15, mysql8.0)"
  type        = string
  default     = "postgres15"
}

variable "aurora_parameter_group_family" {
  description = "Aurora cluster parameter group family (e.g., aurora-postgresql15)"
  type        = string
  default     = "aurora-postgresql15"
}

variable "max_connections" {
  description = "max_connections parameter"
  type        = number
  default     = 200
}

variable "log_statement" {
  description = "log_statement parameter (Postgres)"
  type        = string
  default     = "none"
}

variable "work_mem" {
  description = "work_mem parameter (Postgres)"
  type        = string
  default     = "4096"
}

variable "allocated_storage" {
  description = "Allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type for RDS instance"
  type        = string
  default     = "gp3"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}