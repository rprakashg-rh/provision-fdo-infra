module "ec2" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "2.8.0"

    name            = "${local.stack_name}-aio-node"
    instance_type   = var.instance_type
    ami             = data.aws_ami.latest_rhel9_ami.id

    subnet_id                     = tolist(module.vpc.private_subnets)[0]
    key_name                      = var.ssh_key
    vpc_security_group_ids        = [module.private_subnet_sg.security_group_id]
    associate_public_ip_address   = false
    
    ipv6_addresses = null
    
    private_ips = [cidrhost(module.vpc.private_subnets_cidr_blocks[0], 10)]

    root_block_device = [
        {
        volume_type = "gp2"
        volume_size = 100
        },
    ]

    ebs_block_device = [
        {
        device_name = "/dev/sdf"
        volume_type = "gp2"
        volume_size = 50
        encrypted   = false
        }
    ]

    user_data = <<-EOF
        #!/bin/bash
        sudo yum -y update
        sudo dnf -y install ansible-core httpd

        sudo systemctl start httpd.service
        
    EOF
    
    tags = local.tags
}