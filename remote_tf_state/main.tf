terraform {

  required_version = "~> 1.2.8"

  required_providers {
    aws  = "~> 3.74.1"
  }
}

provider "aws" {
  region = "eu-west-2"
}

# resource "aws_s3_bucket" "state-file" {
#   bucket = "souher-remote-tf-state"
  
#   versioning {
#     enabled = true
#   }

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# resource "aws_dynamodb_table" "lock-state" {
#   name         = "souher-remote-tf-state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }


terraform {
  backend "s3" {
    bucket         = "souher-remote-tf-state"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    
    dynamodb_table = "souher-remote-tf-state-lock"
    encrypt        = true
  }
}