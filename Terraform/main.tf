# Retrieve the default VPC
data "aws_vpc" "default" {
  default = true
}

# Retrieve the public subnet in the default VPC
data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }

  filter {
    name   = "cidr-block"
    values = ["172.31.0.0/20"]  
  }
}

# Retrieve the default security group in the default VPC
data "aws_security_group" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# Create a new key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "assi1"  
  public_key = file("assi1.pub")
 }

# Create an EC2 instance in the public subnet of the default VPC
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0277155c3f0ab2930"  # Specify the AMI ID
  instance_type = "t2.micro"  # Specify your instance type

  # Use the public subnet in the default VPC
  subnet_id     = data.aws_subnet.public.id

  # Reference the default security group in the default VPC
  vpc_security_group_ids = [data.aws_security_group.default.id]
  key_name      = "assi1"  
}


# Create ECR repositories
resource "aws_ecr_repository" "webapp_repo" {
  name = "webapp"  
}

resource "aws_ecr_repository" "mysql_repo" {
  name = "mysql"  
}

output "public_ip_address" {
  value = aws_instance.my_ec2_instance.public_ip
}

output "webapp_repo_url" {
  value = aws_ecr_repository.webapp_repo.repository_url
}

output "mysql_repo_url" {
  value = aws_ecr_repository.mysql_repo.repository_url
}
