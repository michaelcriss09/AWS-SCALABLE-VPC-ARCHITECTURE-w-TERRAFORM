resource "aws_ec2_transit_gateway_vpc_attachment" "tga" {
    subnet_ids = var.tgw_subnets
    transit_gateway_id = var.tgw
    vpc_id = var.tgw_vpc_id

    transit_gateway_default_route_table_association = false
    transit_gateway_default_route_table_propagation = false
    
    tags = {
        Name = var.tgw_name
    }
}