# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-goit-devops-project-olegsl"
#     key            = "goit-devops-project/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
