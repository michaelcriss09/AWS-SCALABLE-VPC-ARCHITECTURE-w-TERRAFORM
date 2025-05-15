variable "tgw_name" {
    description = "Name for tgw on aws"
    type = string
}
 
variable "tgw_vpc_attachment" {
  description = "Map of VPC attachments"
  type = map(object({
    vpc_id         = string
    subnet_ids     = list(string)
    attachment_name = string
  }))
}


