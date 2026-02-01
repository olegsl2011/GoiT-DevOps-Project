terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "terraform-state-bucket-goit-devops-project-olegsl"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.s3_bucket_name
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "goit-devops-project-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "goit-devops-project-ecr"
  scan_on_push = true
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name        = "goit-devops-project-eks-cluster"
  cluster_version     = "1.28"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  private_subnet_ids  = module.vpc.private_subnet_ids
  
  node_group_name     = "goit-devops-project-worker-nodes"
  node_instance_types = ["t3.small"]
  node_desired_size   = 4
  node_max_size       = 12
  node_min_size       = 2
  node_disk_size      = 20
  
  enable_irsa = true
  
  tags = {
    Environment = "goit-devops-project"
    Project     = "goit-devops-project"
    ManagedBy   = "terraform"
  }
}

# Jenkins and Argo CD modules will be deployed in a second step
# after the EKS cluster is created to avoid circular dependencies

# module "jenkins" {
#   source = "./modules/jenkins"
#   
#   cluster_name          = module.eks.cluster_name
#   namespace            = "jenkins"
#   jenkins_admin_password = "admin123!"
#   ecr_repository_url   = module.ecr.repository_url
#   aws_region           = var.aws_region
#   
#   tags = {
#     Environment = "goit-devops-project"
#     Project     = "goit-devops-project"
#     ManagedBy   = "terraform"
#   }
# }

# module "argo_cd" {
#   source = "./modules/argo_cd"
#   
#   cluster_name = module.eks.cluster_name
#   namespace    = "argocd"
#   
#   repositories = [
#     {
#       name = "goit-devops-project"
#       url  = "https://github.com/olegsl2011/GoiT-DevOps-Project.git"
#       type = "git"
#     }
#   ]
#   
#   applications = [
#     {
#       name           = "django-app"
#       namespace      = "argocd"
#       source_repo    = "https://github.com/olegsl2011/GoiT-DevOps-Project.git"
#       source_path    = "charts/django-app"
#       dest_server    = "https://kubernetes.default.svc"
#       dest_namespace = "default"
#     }
#   ]
#   
#   tags = {
#     Environment = "goit-devops-project"
#     Project     = "goit-devops-project"
#     ManagedBy   = "terraform"
#   }
# }

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}


