terraform {
  required_providers {
     aws = {
      source  = "hashicorp/aws"
      version = "5.63.0"
    }
    acme = {
      source = "vancluever/acme"
      version = "2.25.0"
    }
  }
}