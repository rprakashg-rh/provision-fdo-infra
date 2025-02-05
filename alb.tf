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
        http = {
            port        = 80
            protocol    = "HTTP"
            
            fixed_response = {
                content_type = "text/plain"
                message_body = "Host Not Found"
                status_code  = "404"
            }

            rules = {
                fdo-manufacturing-app = {
                    priority = 100

                    conditions = [{
                        host_header = {
                            values = ["manufacturing.${var.base_domain}"]
                        }
                    }]

                    actions = [{
                        type = "forward"
                        target_group_key = "manufacturing"
                    }]
                    
                }    
            }
        }
    }

    target_groups = {
        manufacturing = {
            protocol            = "HTTP"
            protocol_version    = "HTTP1"
            port                = "8080"
            target_type         = "instance"

            load_balancing_cross_zone_enabled = false

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
            name    = "owneronboarding"
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