terraform {
  backend "s3" {
    bucket = "bagisto-terraform-state-bucket"
    key    = "environments/staging/terraform.tfstate"
    region = "ap-southeast-2"
  }
}
