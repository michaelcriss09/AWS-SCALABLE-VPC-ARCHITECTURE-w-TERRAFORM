locals{
    Region = var.region
    bastion_instance_name = "bastion-host-instance"
    bastion_sg   = "bastion-host-sg"
    app01_instance_name = "app01-server-instance"
    app02_instance_name   = "app02-server-instance"
    app01_sg = "app01-sg"
    app2_sg = "app02-sg"
    alb_name = "alb-server"
    alb_sg_name = "alb-sg"
    nat_name = "Nat-server"

}