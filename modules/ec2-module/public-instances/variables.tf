variable "sg_name" {
    description = "Security group name"
    type = string
}

variable "vpc_id" {
    description = "Security group name"
}

variable "ssh_cidr" {
    description = "Security group name"
    type = list(string)
}



variable "instance_type"{
    description = "Instance type for AWS EC2"
    type = string
}
variable "instance_name" {
    description = "Instance name for AWS EC2"
    type = string
}

variable "ami_id" {
    description = "Instance AMI ID for AWS EC2"
    type = string
}

variable "ec2_subnet_id" {
    description = "subnet for each instances"
}

variable "key_name" {
    description = "SSH key from instance"
}