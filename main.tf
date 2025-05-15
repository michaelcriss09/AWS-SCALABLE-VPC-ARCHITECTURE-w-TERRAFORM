# Bastion and Server VPC

module "vpc_deployment"{
    for_each = {
        Bastion_host_vpc = {
           cidr = "10.0.0.0/16"
           name = "Bastion_host_vpc"
        }
        Server_vpc = {
           cidr = "11.0.0.0/16"
           name = "Server_vpc"
        }
    }
    source = "./modules/vpc-module"
    vpc_cidr_block = each.value.cidr
    vpc_name = each.value.name
} 


# Bastion VPC -> Bastion_public_subnet
# Server VPC ->  app01_private_subnet, app02_private_subnet, nat_public_subnet, alb_public_subnet

module "subnet_deployment"{
    for_each = {
        app01_private_subnet={
            vpc_key   = "Server_vpc" 
            cidr      = "11.0.6.0/24"
            name      = "app01_private_subnet"
            public_ip = false
            av-zone   = "us-east-2b"
        } 
        
          app02_private_subnet={
            vpc_key   = "Server_vpc" 
            cidr      = "11.0.3.0/24"
            name      = "app02_private_subnet"
            public_ip = false
            av-zone   = "us-east-2c"
        } 
        nat_public_subnet={
            vpc_key   = "Server_vpc" 
            cidr      = "11.0.4.0/24"
            name      = "nat_public_subnet"
            public_ip = true
            av-zone   = "us-east-2a"
        }  
        alb01_public_subnet={
            vpc_key   = "Server_vpc" 
            cidr      = "11.0.12.0/24"
            name      = "alb01_public_subnet"
            av-zone   = "us-east-2b"
            public_ip = true
        }  
        alb02_public_subnet={
            vpc_key   = "Server_vpc" 
            cidr      = "11.0.10.0/24"
            name      = "alb02_public_subnet"
            av-zone   = "us-east-2c"
            public_ip = true
        }  
       
          Bastion_public_subnet={
            vpc_key   = "Bastion_host_vpc" 
            cidr      = "10.0.1.0/24"
            name      = "Bastion_public_subnet"
            av-zone   = "us-east-2a"
            public_ip = true
        }        

    }
    source = "./modules/subnet-module"
    vpc_id = module.vpc_deployment[each.value.vpc_key].vpc_id
    subnet_cidr_block = each.value.cidr
    subnet_name = each.value.name
    az = each.value.av-zone
    map_public_ip = each.value.public_ip
} 


module igw_vpc { # Internet Gateway
    for_each = {
        igw_bastion_host = {
            vpc_key = "Bastion_host_vpc"
            name    = "igw_bastion_host"
        }

        igw_server = {
            vpc_key = "Server_vpc"
            name    = "igw_server"
        }
    }
    source     = "./modules/igw-module"
    igw_vpc_id = module.vpc_deployment[each.value.vpc_key].vpc_id
    igw_name   = each.value.name
}


resource "aws_ec2_transit_gateway" "transit_gateway"{
    description                     = "Transit Gateway for each vpc"
    default_route_table_association = "disable"
    default_route_table_propagation = "disable"
}


module "tga_deployment" { # Transit Gateway Attachment
    for_each = {
      tga_server = {
        subnet_keys = ["app01_private_subnet", "app02_private_subnet"] # Target
        vpc_key     = ["Server_vpc"]
        tg          = aws_ec2_transit_gateway.transit_gateway.id
        name        = "tga_server"
      }

      tga_bastion = {
        subnet_keys = ["Bastion_public_subnet"] # Target
        vpc_key     = ["Bastion_host_vpc"]
        tg          = aws_ec2_transit_gateway.transit_gateway.id
        name        = "tga_bastion"
      }
    }
    source = "./modules/tgw-attachment-module"
    tgw_subnets = [for key in each.value.subnet_keys : module.subnet_deployment[key].subnet_id]
    tgw = each.value.tg
    tgw_vpc_id = module.vpc_deployment[each.value.vpc_key[0]].vpc_id
    tgw_name = each.value.name
}

resource "aws_ec2_transit_gateway_route_table" "tgw_route" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id

  tags = {
    Name = "tgw-main-route-table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "attach_to_rt" {
  for_each = module.tga_deployment

  transit_gateway_attachment_id  = each.value.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route.id
}

resource "aws_ec2_transit_gateway_route" "bastion_to_server" {
  destination_cidr_block         = "11.0.0.0/16"  
  transit_gateway_attachment_id  = module.tga_deployment["tga_server"].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route.id
}

resource "aws_ec2_transit_gateway_route" "server_to_bastion" {
  destination_cidr_block         = "10.0.0.0/16"  
  transit_gateway_attachment_id  = module.tga_deployment["tga_bastion"].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route.id
}

resource "aws_eip" "eip_nat"{
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = module.subnet_deployment["nat_public_subnet"].subnet_id

  tags = {
    Name = local.nat_name
  }
}

module "bastion_route_table" {
  routes = [
    {
      destination_cidr_block = "11.0.0.0/16" 
      transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
    },
    {
      destination_cidr_block = "0.0.0.0/0"
      gateway_id             = module.igw_vpc["igw_bastion_host"].igw_id
    }
  ]
  subnet_ids = {
  bastion_public_subnet = module.subnet_deployment["Bastion_public_subnet"].subnet_id
    }

    
  source = "./modules/route-tables-module"
  rt_vpc = module.vpc_deployment["Bastion_host_vpc"].vpc_id
  name   = "bastion-subnet-route-table"  
}

module "Server_route_table" {
  routes = [
    {
      destination_cidr_block = "10.0.0.0/16" 
      transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
    },
    {
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id         = aws_nat_gateway.gw.id
    }
  ]
  subnet_ids = {
  app01-server = module.subnet_deployment["app01_private_subnet"].subnet_id
  app02-server = module.subnet_deployment["app02_private_subnet"].subnet_id
    }

    
  source = "./modules/route-tables-module"
  rt_vpc = module.vpc_deployment["Server_vpc"].vpc_id
  name   = "app01-subnet-route-table"  
}

resource "aws_route_table" "nat-alb-rt-subnet" {
  vpc_id = module.vpc_deployment["Server_vpc"].vpc_id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.nat-alb-rt-subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.igw_vpc["igw_server"].igw_id
}

resource "aws_route_table_association" "alb01_subnet_assoc" {
  subnet_id      = module.subnet_deployment["alb01_public_subnet"].subnet_id
  route_table_id = aws_route_table.nat-alb-rt-subnet.id
}

resource "aws_route_table_association" "alb101_subnet_assoc" {
  subnet_id      = module.subnet_deployment["alb02_public_subnet"].subnet_id
  route_table_id = aws_route_table.nat-alb-rt-subnet.id
}

resource "aws_route_table_association" "nat_subnet_assoc" {
  subnet_id      = module.subnet_deployment["nat_public_subnet"].subnet_id
  route_table_id = aws_route_table.nat-alb-rt-subnet.id
}

resource "aws_lb_target_group" "server_target_group" {
  name     = var.Target_group_name                         #Target group -> app01-server-instances & app02-sever-instance
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_deployment["Server_vpc"].vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "app01_tg_attachment" {
  target_group_arn = aws_lb_target_group.server_target_group.arn
  target_id        = module.app01_server_instance.private_instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app02_tg_attachment" {
  target_group_arn = aws_lb_target_group.server_target_group.arn
  target_id        = module.app02_server_instance.private_instance_id
  port             = 80
}

resource "aws_security_group" "alb-sg" {   
  name        = local.alb_sg_name
  description = "Application Load Balancer security groups"
  vpc_id      = module.vpc_deployment["Server_vpc"].vpc_id

    ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr
  }

    egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = var.ssh_cidr   
    }

    tags = {
      Name = "alb-sg"
    }
}

resource "aws_lb" "alb_server" {    # Aplication Load Balancer for Target Group
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [
    module.subnet_deployment.alb01_public_subnet.subnet_id,
    module.subnet_deployment.alb02_public_subnet.subnet_id
  ]


  enable_deletion_protection = false
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb_server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server_target_group.arn
  }
}

module bastion_instance {
  vpc_id         = module.vpc_deployment["Bastion_host_vpc"].vpc_id
  ec2_subnet_id  = module.subnet_deployment["Bastion_public_subnet"].subnet_id
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  ssh_cidr       = var.ssh_cidr
  instance_name  = local.bastion_instance_name
  sg_name        = local.bastion_sg
  source         = "./modules/ec2-module/public-instances"
}

module app01_server_instance {
  vpc_id = module.vpc_deployment["Server_vpc"].vpc_id
  ec2_subnet_id = module.subnet_deployment["app01_private_subnet"].subnet_id
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  instance_name  = local.app01_instance_name
  sg_name        = local.app01_sg
  ssh_cidr       = var.ssh_cidr
  alb_sg         = aws_security_group.alb-sg.id
  source         = "./modules/ec2-module/private-instances"
}

module app02_server_instance {
  vpc_id = module.vpc_deployment["Server_vpc"].vpc_id
  ec2_subnet_id  = module.subnet_deployment["app02_private_subnet"].subnet_id
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  instance_name  = local.app02_instance_name
  sg_name        = local.app2_sg
  ssh_cidr       = var.ssh_cidr
  alb_sg         = aws_security_group.alb-sg.id
  source         = "./modules/ec2-module/private-instances"
}
