
variable "subnet_cidr_block"{
    description = "Name for subnets vpc on aws"
}

variable "subnet_name"{
    description = "Name for subnets vpc on aws"
    type = string
}

variable "az"{
    description = "avaliable zone for aws "
    type = string
}

variable "vpc_id"{
    description = "Vpc for subnets vpc on aws"
    type = string
}

variable "map_public_ip"{
    description = "Vpc for subnets vpc on aws"
    type = bool
}


