provider "aws" {
  region = "ap-south-1"  # Replace with your desired region
}

# Reference the existing security group by its name or ID
data "aws_security_group" "existing_sg" {
  name = "anamika-volume"  # Replace with the name of the existing security group
  # Alternatively, you can use the security group ID
  # id = "sg-0eb02c844fd47c3ce"  # Replace with the security group ID
}

# Reference your custom VPC and subnet
data "aws_vpc" "custom-vpc" {
  filter {
    name   = "tag:Name"
    values = ["anamikavpc-vpc"]  # Replace with the name of your custom VPC
  }
}

# Reference your custom subnets within the custom VPC
data "aws_subnets" "custom_subnets" {
 filter {
    name   = "vpc-id"
    values = [data.aws_vpc.custom-vpc.id]
  }
}

# EC2 Instance with Ubuntu and Docker installation via user data
resource "aws_instance" "docker_instance" {
  ami           = "ami-07b69f62c1d38b012"  # Replace with the Ubuntu AMI ID in your region
  instance_type = "t2.micro"      # Replace with the instance type you need
  key_name      = "anamika-aws-key"        # Replace with your SSH key name

  # Use the existing security group from the data source
	vpc_security_group_ids = [data.aws_security_group.existing_sg.id]


# Specify the subnet to use (first one from the list of custom subnets)
  subnet_id = data.aws_subnets.custom_subnets.ids[0]

  # User data script to install Docker on the EC2 instance
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable docker
              yum install docker -y
              service docker start
              usermod -a -G docker ec2-user
              EOF


  tags = {
    Name = "Devops-Project-Instance"
  }

  associate_public_ip_address = true  # Assign a public IP to the instance
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.docker_instance.public_ip
}

