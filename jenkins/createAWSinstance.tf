provider "aws" {
  access_key = "AKIAJJR6FROIY4RDJNXQ"
  secret_key = "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"
  region     = "ap-south-1"
}

resource "aws_instance" "appserver" {
  ami           = "ami-04ea996e7a3e7ad6b"
  instance_type = "t2.micro"
  security_groups = ["default","launch-wizard-1"]
  key_name = "arun-devops"
}