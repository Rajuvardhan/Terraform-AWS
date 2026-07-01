terraform {
  backend "s3" {
    bucket = "terraform-prod-raju419"
    key    = "terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
    
  }
}
