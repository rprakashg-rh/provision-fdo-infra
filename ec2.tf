module "manufacturing" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "2.8.0"

    name            = "${local.stack_name}-${var.config.manufacturing.name}"
    instance_type   = var.config.manufacturing.instance_type
    ami             = data.aws_ami.latest_rhel9_ami.id

    subnet_id                     = tolist(module.vpc.private_subnets)[0]
    key_name                      = var.config.ssh_key
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
        sudo dnf -y install ansible-core
        
    EOF
    
    tags = local.tags
}

module "rendezvous" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "2.8.0"

    name            = "${local.stack_name}-${var.config.rendezvous.name}"
    instance_type   = var.config.rendezvous.instance_type
    ami             = data.aws_ami.latest_rhel9_ami.id

    subnet_id                     = tolist(module.vpc.private_subnets)[0]
    key_name                      = var.config.ssh_key
    vpc_security_group_ids        = [module.private_subnet_sg.security_group_id]
    associate_public_ip_address   = false
    
    ipv6_addresses = null
    
    private_ips = [cidrhost(module.vpc.private_subnets_cidr_blocks[0], 10 + var.config.manufacturing.replicas)]

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
        sudo dnf -y install ansible-core
        
    EOF
    
    tags = local.tags
}

module "owneronboarding" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "2.8.0"

    name            = "${local.stack_name}-${var.config.owneronboarding.name}"
    instance_type   = var.config.owneronboarding.instance_type
    ami             = data.aws_ami.latest_rhel9_ami.id

    subnet_id                     = tolist(module.vpc.private_subnets)[0]
    key_name                      = var.config.ssh_key
    vpc_security_group_ids        = [module.private_subnet_sg.security_group_id]
    associate_public_ip_address   = false
    
    ipv6_addresses = null
    
    private_ips = [cidrhost(module.vpc.private_subnets_cidr_blocks[0], 10 + var.config.manufacturing.replicas + var.config.rendezvous.replicas)]

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
        sudo dnf -y install ansible-core
        
    EOF
    
    tags = local.tags
}
