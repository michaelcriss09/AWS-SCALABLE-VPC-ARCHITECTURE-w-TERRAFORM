# AWS SCALABLE VPC ARCHITECTURE WITH TERRAFORM

A few months ago, deployed a Scalable AWS VPC Architecture using manually resources on AWS | Watch here: [![Here](https://img.shields.io/badge/Project%20Here-blue.svg)](https://www.linkedin.com/posts/michael-d-cris%C3%B3stomo-10706423a_modular-and-scalable-vpc-architecture-on-activity-7257739483805093889-TIV-?utm_source=share&utm_medium=member_desktop&rcm=ACoAADtz4ZcBz7xHHAntAuuc4Zrt8XQue4DZZ5Q)

Same task, new objective! Implement the same project using Terraform IaC. 💻☁️

This project allow the following architecture:

![AWS VPC Architecture](https://i.postimg.cc/6qGDv5h4/Captura-de-pantalla-2025-05-13-215931.png)

# Description
This project implements a scalable network architecture on AWS using multiple VPCs connected through a Transit Gateway, enabling secure and centralized communication between environments. 

### AWS Architecture

The infrastructure is deployed using two VPCs `Bastion-Host-VPC` and `Server-VPC`, each with a specific purpose, allowing for a modular and maintainable design. A jump server, `Bastion-host-instance` is incorporated as a secure management point, an `Aplication load balancing` layer to handle external traffic through a `target group` and an internal network for application instances protected in private subnets `App01-server-instance` and `App01-server-instance`. 

The architecture also includes a `Transit Gateway`, which acts as the connectivity hub between the different VPCs. This simplifies route management and scale better than traditional VPC peering. Additionally, `NAT Gateways` are used to allow server  instances to exit the Internet without compromising their security with ingress traffic.

Since there is a constant deployment of the same AWS resources, this terraform project is based on `modules`, providing better organization and use of code in cases where it is essential.

# Pre-requisites

1) Create an AWS free tier account
2) Install terraform
3) Allow Terraform to interact with your AWS resources through an IAM User  
4) Get the access keys credentials from your IAM User  
5) Export your Access keys in your local terminal:  
   ```bash
   export AWS_ACCESS_KEY_ID="AKIAxxxxxxxxxxxx"
   export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/xxxxxxx"

  # Usage
1) Create a key pairs on aws and download it
2) Open `terraform.tfvars` file and paste key pairs name here:
   ```bash
   key_name = "PASTE-YOUR-KEY-NAME-HERE"
  
3) Open `script.sh` located in `/modules/ec2-module/public-instances` 
4) Paste key content there and modify the route with your key name:
   ```bash
   echo "PASTE YOUR .PEM CONTENT HERE"> /home/ubuntu/key_name.pem 

Finally Save!

5) Initialize the Terraform directory:  
   ```bash
   terraform init
6) Generate the execution plan and apply to run:  
   ```bash
   terraform plan 
   terraform apply

  AWS architecture is up!

7) Connect to `Bastion-host-Instance` on aws EC2 panel if you don't know how to SSH from your terminal
8) SSH to server `App01-server-instance` and `App02-server-instance` instances from `Bastion-host-Instance`
9) Test Internet access 
10) Finally check your `target group` Health from your server instances
11) Once finished, rember delete aws resources to avoid charges:
     ```bash
    terraform destroy

 # About this project
Be free to explore each scenario, keep improving! 🕵️
DON'T SHARE YOUR KEY PAIRS FILE OR CONTENT!!!! ⚠️
