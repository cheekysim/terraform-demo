provider "aws" {
  region = "eu-west-2"
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-aws-key"
  public_key = file("${var.private_key_path}.pub") # or path to your public key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]

  tags = {
    Name = var.instance_name
  }
}

resource "null_resource" "ansible_provisioner" {
  # Trigger re-execution if the EC2 instance ID changes
  triggers = {
    ec2_id = aws_instance.app_server.id
    playbook_hash = filemd5("${path.module}/install_docker.yml")
  }

  # 1. Wait for SSH to be ready on the instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.app_server.public_ip
  }

  provisioner "remote-exec" {
    inline = ["echo 'SSH is ready!'"]
  }

  # 2. Run Ansible playbook locally using the public IP
  provisioner "local-exec" {
    command = <<EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -u ubuntu \
        --private-key ${var.private_key_path} \
        -i '${aws_instance.app_server.public_ip},' \
        install_docker.yml
    EOT
  }

  depends_on = [aws_instance.app_server]
}