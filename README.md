A demo project for deploying an EC2 instance with Docker and Nginx using Terraform and Ansible.

## Prerequisites

- Terraform installed and configured
- Ansible installed and configured
- AWS CLI configured with appropriate credentials
- An SSH key pair available for accessing the EC2 instance

## Usage

1. Clone the repository
2. Navigate to the project directory
3. Update the `terraform/variables.tf` file with your desired values
4. Run `terraform init` to initialize the Terraform configuration
5. Run `terraform apply` to deploy the EC2 instance and provision it with Docker and Nginx


## Notes
- This is only a demo / proof of concept for me internally and should not be used in production environments.