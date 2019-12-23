# Terraform VPC Module

## Usage
    module "vpc" {
        source = "git::git@github.com:kedwards/tf-vpc.git[?ref=vx.x.x]"

        azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
        cidr                 = "10.0.0.0/16"
        enable_dns_hostnames = true
        enable_nat_gateway   = true
        name                 = "keca"
        private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
        public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

        tags = {
            Environment = "dev"
            Owner       = "Kevin Edwards"
            Terraform   = true
        }
    }

### Outputs

    output "security_group_id" {
        description = "The ID of the security group"
    }
