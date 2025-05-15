variable "rt_vpc"{
    description = "VPC origin route table"
}

variable "name" { 
    type = string 
}

variable "subnet_ids" { 
  description = "Map of subnet associations (key=label, value=subnet_id)"
  type        = map(string)
  default     = {}
}

variable "routes" {
  type = list(object({
    destination_cidr_block = string
    transit_gateway_id     = optional(string)
    nat_gateway_id         = optional(string)
    gateway_id             = optional(string)
  }))
}