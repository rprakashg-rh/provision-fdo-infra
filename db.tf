module "rds" {
    source  = "terraform-aws-modules/rds/aws"
    version = "6.3.1"

    for_each = {for i, instance in var.databases: instance.name => instance}

    identifier = "${local.stack_name}-${each.value.name}-pg-instance"
    
    engine                  = "postgres"
    engine_version          = "15"
    family                  = "postgres15"
    major_engine_version    = "15"
    instance_class          = each.value.instance_type

    allocated_storage = 20
    max_allocated_storage = 200
    publicly_accessible = false

    db_name                 = each.value.name
    username                = each.value.user
    port                    = 5432
    multi_az                = false
    db_subnet_group_name    = module.vpc.database_subnet_group
    vpc_security_group_ids  = [module.db_subnet_sg.security_group_id]

    maintenance_window              = "Mon:00:00-Mon:03:00"
    backup_window                   = "03:00-06:00"
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
    create_cloudwatch_log_group     = true

    backup_retention_period = 1
    skip_final_snapshot     = true
    deletion_protection     = false

    performance_insights_enabled            = true
    performance_insights_retention_period   = 7
    
    create_monitoring_role                  = true 
    monitoring_interval                     = 60
    monitoring_role_name                    = "${each.value.name}-monitoring"
    monitoring_role_description             = "Monitoring role for ${each.value.name} AWS RDS database"
    monitoring_role_use_name_prefix         = true

    db_option_group_tags = {
        "Sensitive" = "low"
    }
  
    db_parameter_group_tags = {
        "Sensitive" = "low"
    }

    tags = local.tags
}