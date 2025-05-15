
resource "aws_security_group" "public-sg" {
  name = var.sg_name
  description = "EC2 security groups"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.ssh_cidr

  }

    ingress {
    description = "Allow HTTP traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

    egress {
    description = "allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]     
    }

    tags = {
      Name = "${var.instance_name}-public-sg"
    }
}

resource "aws_instance" "public-instance" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.ec2_subnet_id
    vpc_security_group_ids = [aws_security_group.public-sg.id]
    key_name = var.key_name
    tags={
        Name = var.instance_name
    }
    associate_public_ip_address = true
}