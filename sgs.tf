# Security Groups
module "public_subnet_sg" {
    source  = "terraform-aws-modules/security-group/aws"
    version = "~> 5.3.0"

    name              = "${local.stack_name}-vpc-public-subnet-sg"
    description       = "Security group to allow HTTP/HTTPS, SSH access"
    vpc_id            = module.vpc.vpc_id

    # Ingress rules 1) allow SSH traffic from local machine 2) HTTP/HTTPS Traffic from any IP
    ingress_with_cidr_blocks = [
        {
            from_port = 22
            to_port   = 22
            protocol  = "tcp"
            description = "SSH Traffic from this machine"
            cidr_blocks = var.my_ip
        },
        {
            from_port = 80
            to_port   = 80
            protocol  = "tcp"
            description = "Health check"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            from_port = 8080
            to_port   = 8080
            protocol  = "tcp"
            description = "Manufacturing Server communications"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            from_port = 8081
            to_port   = 8081
            protocol  = "tcp"
            description = "Owner Onboarding Server communications"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            from_port = 8082
            to_port   = 8082
            protocol  = "tcp"
            description = "Rendezvous Server communications"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            from_port = 8083
            to_port   = 8083
            protocol  = "tcp"
            description = "ServiceInfo API traffic"
            cidr_blocks = "0.0.0.0/0"
        },

    ]

    #allow all outbound https traffic to internet
    egress_with_cidr_blocks = [{
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        description = "All outbound traffic"
        cidr_blocks = "0.0.0.0/0"
    }]
}

module "private_subnet_sg" {
    source  = "terraform-aws-modules/security-group/aws"
    version = "~> 5.3.0"

    name              = "${local.stack_name}-vpc-private-subnet-sg"
    description       = "Security group to allow HTTP/HTTPS, SSH access from only public subnet"
    vpc_id            = module.vpc.vpc_id
    
    # Ingress rules 1) allow SSH traffic from public subnet 2) HTTPS Traffic from public subnet
    ingress_with_source_security_group_id = [
        {
            from_port             = 22
            to_port               = 22
            protocol              = "tcp"
            description           = "SSH Traffic from public subnet"
            source_security_group_id = module.public_subnet_sg.security_group_id
        },
        {
            from_port             = 80
            to_port               = 80
            protocol              = "tcp"
            description           = "Health check Traffic from Public Subnet"
            source_security_group_id = module.public_subnet_sg.security_group_id
        },
        {
            from_port             = 8080
            to_port               = 8080
            protocol              = "tcp"
            description           = "Manufacturing Server Traffic from Public Subnet"
            source_security_group_id = module.public_subnet_sg.security_group_id
        },
        {
            from_port             = 8081
            to_port               = 8081
            protocol              = "tcp"
            description           = "Owner Onboarding Server traffic from Public Subnet"
            source_security_group_id = module.public_subnet_sg.security_group_id
        },
        {
            from_port             = 8082
            to_port               = 8082
            protocol              = "tcp"
            description           = "Rendezvous Server Traffic from Public Subnet"
            source_security_group_id = module.public_subnet_sg.security_group_id
        },
        {
            from_port             = 8083
            to_port               = 8083
            protocol              = "tcp"
            description           = "ServiceInfo API traffic from Public Subnet"
            source_security_group_id = module.public_subnet_sg.security_group_id
        },
    ]

    #allow all outbound https traffic to internet
    egress_with_cidr_blocks = [{
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
        description = "HTTPS Traffic to any IP"
        cidr_blocks = "0.0.0.0/0"
    }]
}

module "db_subnet_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name              = "${local.stack_name}-vpc-db-subnet-sg"
  description       = "Security group to allow connections from private subnet"
  vpc_id            = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from private subnets within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

# Create an outbound rule on public subnet security group to allow ssh, http and https traffic flowing to private subnet
resource "aws_security_group_rule" "allow_ssh_from_public_subnet" {
    type                      = "egress"
    security_group_id         = module.public_subnet_sg.security_group_id
    from_port                 = "22"
    to_port                   = "22"
    protocol                  = "tcp"
    cidr_blocks               = module.vpc.private_subnets_cidr_blocks
}
resource "aws_security_group_rule" "allow_healthcheck_from_public_subnet" {
    type                      = "egress"
    security_group_id         = module.public_subnet_sg.security_group_id
    from_port                 = "80"
    to_port                   = "80"
    protocol                  = "tcp"
    cidr_blocks               = module.vpc.private_subnets_cidr_blocks
}
resource "aws_security_group_rule" "allow_manufacturing_server_traffic_from_public_subnet" {
    type                      = "egress"
    security_group_id         = module.public_subnet_sg.security_group_id
    from_port                 = "8080"
    to_port                   = "8080"
    protocol                  = "tcp"
    cidr_blocks               = module.vpc.private_subnets_cidr_blocks
}

resource "aws_security_group_rule" "allow_oos_traffic_from_public_subnet" {
    type                      = "egress"
    security_group_id         = module.public_subnet_sg.security_group_id
    from_port                 = "8081"
    to_port                   = "8081"
    protocol                  = "tcp"
    cidr_blocks               = module.vpc.private_subnets_cidr_blocks
}

resource "aws_security_group_rule" "allow_rvs_traffic_from_public_subnet" {
    type                      = "egress"
    security_group_id         = module.public_subnet_sg.security_group_id
    from_port                 = "8082"
    to_port                   = "8082"
    protocol                  = "tcp"
    cidr_blocks               = module.vpc.private_subnets_cidr_blocks
}

resource "aws_security_group_rule" "allow_service_info_api_traffic_from_public_subnet" {
    type                      = "egress"
    security_group_id         = module.public_subnet_sg.security_group_id
    from_port                 = "8083"
    to_port                   = "8083"
    protocol                  = "tcp"
    cidr_blocks               = module.vpc.private_subnets_cidr_blocks
}

resource "aws_security_group_rule" "allow_5432_from_private_subnet" {
  type                      = "egress"
  security_group_id         = module.private_subnet_sg.security_group_id
  from_port                 = "5432"
  to_port                   = "5432"
  protocol                  = "tcp"
  cidr_blocks               = module.vpc.database_subnets_cidr_blocks
}