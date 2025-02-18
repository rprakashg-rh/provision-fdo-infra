module "alb" {
    source  = "terraform-aws-modules/alb/aws"
    version = "9.11.2"

    name                = "${local.stack_name}-alb"
    vpc_id              = module.vpc.vpc_id
    subnets             = module.vpc.public_subnets
    load_balancer_type  = "application"
    
    enable_deletion_protection = false

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
        http80 = {
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
                fdo-rendezvous-app = {
                    priority = 300

                    conditions = [{
                        host_header = {
                            values = ["rendezvous.${var.base_domain}"]
                        }
                    }]

                    actions = [{
                        type = "forward"
                        target_group_key = "rendezvous"
                    }]
                }
                fdo-owner-app = {
                    priority = 400

                    conditions = [{
                        host_header = {
                            values = ["owneronboarding.${var.base_domain}"]
                        }
                    }]

                    actions = [{
                        type = "forward"
                        target_group_key = "owneronboarding"
                    }]
                }
                fdo-serviceinfo-app = {
                    priority = 500

                    conditions = [{
                        host_header = {
                            values = ["serviceinfo.${var.base_domain}"]
                        }
                    }]

                    actions = [{
                        type = "forward"
                        target_group_key = "serviceinfo"
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
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/ping?app=manufacturing"
                port                = "80"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"    
            }
        }
        rendezvous = {
            protocol            = "HTTP"
            protocol_version    = "HTTP1"
            port                = "8082"
            target_type         = "instance"

            load_balancing_cross_zone_enabled = false

            target_id = module.ec2.id[0]
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/ping?app=rendezvous"
                port                = "80"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"    
            }
        }
        owneronboarding = {
            protocol            = "HTTP"
            protocol_version    = "HTTP1"
            port                = "8081"
            target_type         = "instance"

            load_balancing_cross_zone_enabled = false

            target_id = module.ec2.id[0]
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/ping?app=owneronboarding"
                port                = "80"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"    
            }
        }
        serviceinfo = {
            protocol            = "HTTP"
            protocol_version    = "HTTP1"
            port                = "8083"
            target_type         = "instance"

            load_balancing_cross_zone_enabled = false

            target_id = module.ec2.id[0]
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/ping?app=serviceinfo"
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