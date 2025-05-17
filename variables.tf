variable "region" {
  description = "AWS REGION > US-EAST-2"
  default = "us-east-2"
}

variable "ami_id" {
  type    = string
  default = "ami-04f167a56786e4b09"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "key_name" {
  type    = string
}
variable "ssh_cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "Target_group_name" {
  type    = string
  default = "Server-Target-group"
}

