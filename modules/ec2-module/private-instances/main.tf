
resource "aws_security_group" "private-sg" {
  name = var.sg_name
  description = "EC2 security groups"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = var.ssh_cidr

  }

    ingress {
    description = "Allow alb trafic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [var.alb_sg]
  }

    egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]     
    }

    tags = {
      Name = "${var.instance_name}-private-sg"
    }
}

resource "aws_instance" "private-instance" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.ec2_subnet_id
    vpc_security_group_ids = [aws_security_group.private-sg.id]
    key_name = var.key_name
    tags={
        Name = var.instance_name
    }

    associate_public_ip_address = false
}