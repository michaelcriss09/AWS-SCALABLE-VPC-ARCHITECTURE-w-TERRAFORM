resource "aws_ec2_transit_gateway" "tgw" {
    description = "tgw for vpc"

    tags = {
        name = "tgw-vpc"
    }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment" {
    for_each = var.tgw_vpc_attachment
    subnet_ids = each.value.subnet_ids
    transit_gateway_id = aws_ec2_transit_gateway.main.id 
    vpc_id = each.value.vpc_id
}