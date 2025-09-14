terraform {
  backend "s3" {
    bucket = "bagisto-terraform-state-bucket"
    key    = "environments/dev/terraform.tfstate"
    region = "ap-southeast-2"
  }
}
