terraform { 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  } 
}

provider "aws" {
  region = "eu-west-2"
}

module "website" {
  source = "../modules/front-end"

  bucket-name = "cloud-resume-website-souher"
  cloudfront-origin-id = "s3-cloudfront-website"
  domain-name = "souhercloudresume.com"
}

module "Dynamodb-lambda-gatewayv2" {
  source = "../modules/back-end"

  staging-name = "pass-counter-stage"
  lambda-bucket-name = "hold-lambdas-zip-files"
  api-gatewayv2-name = "Pass-counter"
  read-function-name = "read_function"
  write-function-name = "write_function"
}



output "website_endpoint" {
  value = module.website.website_endpoint
} 
