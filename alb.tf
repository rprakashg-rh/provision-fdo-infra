module "alb" {
    source  = "terraform-aws-modules/alb/aws"
    version = "9.11.2"

    name                = "${local.stack_name}-alb"
    vpc_id              = module.vpc.vpc_id
    subnets             = module.vpc.public_subnets
    load_balancer_type  = "application"

    create_security_group = false
    security_groups = [module.public_subnet_sg.security_group_id]
        
    access_logs = {
        bucket = module.log_bucket.s3_bucket_id
        prefix = "access-logs"
    }
    connection_logs = {
        bucket  = module.log_bucket.s3_bucket_id
        enabled = true
        prefix  = "connection-logs"
    }
    client_keep_alive = 7200

    listeners = {
        fdo = {
            port        = 8080
            protocol    = "HTTP"
            forward = {
                target_group_key = "manufacturing"    
            }
            conditions = [{
                host_header = {
                    values = ["manufacturing.${var.base_domain}"]
                }
            }]
        }
        rendezvous = {
            port        = 8082
            protocol    = "HTTP"
            forward = {
                target_group_key = "rendezvous"    
            }
            conditions = [{
                host_header = {
                    values = ["rendezvous.${var.base_domain}"]
                }
            }]
        }
        owneronboarding = {
            port        = 8081
            protocol    = "HTTP"
            forward = {
                target_group_key = "owneronboarding"    
            }
            conditions = [{
                host_header = {
                    values = ["owneronboarding.${var.base_domain}"]
                }
            }]
        }
        serviceinfo = {
            port        = 8083
            protocol    = "HTTP"
            forward = {
                target_group_key = "serviceinfo"    
            }
            conditions = [{
                host_header = {
                    values = ["serviceinfo.${var.base_domain}"]
                }
            }]
        }
    }

    target_groups = {
        manufacturing = {
            protocol        = "HTTP"
            port           = 8080
            target_type     = "instance"
            
            load_balancer_cross_zone_enabled = true
            target_id = module.ec2.id[0]
            healthcheck = {
                enabled             = true
                interval            = 30
                path                = "/"
                port                = "80"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"    
            }
        }
        rendezvous = {
            protocol        = "HTTP"
            port           = 8082
            target_type     = "instance"
            
            load_balancer_cross_zone_enabled = true
            target_id = module.ec2.id[0]

            healthcheck = {
                enabled             = true
                interval            = 30
                path                = "/"
                port                = "80"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"    
            }
        }
        owneronboarding = {
            protocol        = "HTTP"
            port           = 8081
            target_type     = "instance"
            
            load_balancer_cross_zone_enabled = true
            target_id = module.ec2.id[0]

            healthcheck = {
                enabled             = true
                interval            = 30
                path                = "/"
                port                = "80"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"    
            }
        }
        serviceinfo = {
            protocol        = "HTTP"
            port           = 8083
            target_type     = "instance"
            
            load_balancer_cross_zone_enabled = true
            target_id = module.ec2.id[0]

            healthcheck = {
                enabled             = true
                interval            = 30
                path                = "/"
                port                = "80"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"    
            }
        }
    }

    route53_records = {
        manufacturingA = {
            name    = "manufacturing"
            type    = "A"
            zone_id = data.aws_route53_zone.this.id
        }
        manufacturingAAAA = {
            name    = "manufacturing"
            type    = "AAAA"
            zone_id = data.aws_route53_zone.this.id
        }
        rendezvousA = {
            name    = "rendezvous"
            type    = "A"
            zone_id = data.aws_route53_zone.this.id
        }
        rendezvousAAAA = {
            name    = "rendezvous"
            type    = "AAAA"
            zone_id = data.aws_route53_zone.this.id
        }
        owneronboardingA = {
            name    = "owner"
            type    = "A"
            zone_id = data.aws_route53_zone.this.id
        }
        owneronboardingAAAA = {
            name    = "owneronboarding"
            type    = "AAAA"
            zone_id = data.aws_route53_zone.this.id
        }
        serviceinfoA = {
            name    = "serviceinfo"
            type    = "A"
            zone_id = data.aws_route53_zone.this.id
        }
        serviceinfoAAAA = {
            name    = "serviceinfo"
            type    = "AAAA"
            zone_id = data.aws_route53_zone.this.id
        }
    }
    
    tags = local.tags
}