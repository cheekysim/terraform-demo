variable "instance_name" {
  description = "Value of the EC2 instance name"
  type = string
  default = "terraform-demo"
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type = string
  default = "t3.micro"
}

variable "private_key_path" {
  description = "Path to the private key file for the SSH key pair to use for the EC2 instance"
  type        = string
  default = "~/.ssh/aws"
}