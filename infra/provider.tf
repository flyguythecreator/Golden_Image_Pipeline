terraform {
  required_providers {
    aws = {
      aws = {
        source  = "hashicorp/aws"
        version = "5.32.0" # "~> 4.16" #  
        }
    }
    required_version = ">= 1.2.0" # required_version = "1.5.2"
  }
}

provider "aws" {
    region = "<AWS_Region>"
}