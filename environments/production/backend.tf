terraform {
  backend "s3" {
    bucket = "bagisto-terraform-state-bucket"
    key    = "environments/production/terraform.tfstate"
    region = "ap-southeast-2"
  }
}
