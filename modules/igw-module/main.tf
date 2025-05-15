resource "aws_internet_gateway"  "igw-vpc"{
    vpc_id = var.igw_vpc_id

    tags = {
        Name = var.igw_name
    }
}