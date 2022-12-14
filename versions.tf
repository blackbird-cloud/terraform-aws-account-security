terraform {
  required_version = ">=1.0.9"
  required_providers {
    aws = {
      version = "~> 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}
