terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.6"
    }
  }
  required_version = ">= 1.3, <= 5.0"
}
