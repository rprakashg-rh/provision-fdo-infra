variable region {
    description = "AWS Region"
    type = string
    default = "us-west-2"
}

variable instance_type {
    description = "AWS Instance type to use for EC2 instance running FDO services"
    type = string
    default = "m5.2xlarge"
}

variable "ami" {
    description = "AMI to use for EC2 instance running FDO services"
    type = string
    default = "ami-0f7197c592205b389"
}

variable "ssh_key" {
    description = "SSH key to ssh into EC2 instance"
    type = string
    default = "fdo_rsa"
}

variable "base_domain" {
    description = "Base domain name"
    default = "sandbox2519.opentlc.com"
    type = string
}

variable "my_ip" {
    description = "IP Address block of current local machine"
    type = string
    default = "136.27.40.26/32"    
}

variable "databases" {
    description = "AWS RDS Postgresql instances that need to be provisioned"
    type    = list(object({
      name = string
      instance_type = string
      user          = string 
    }))
    default = [
        {
            name            = "manufacturing"
            instance_type   = "db.t4g.micro"
            user            = "manufacturing_dbuser" 
        },
        {
            name            = "rendezvous"
            instance_type   = "db.t4g.micro"
            user            = "rendezvous_dbuser" 
        },
        {
            name            = "owneronboarding"
            instance_type   = "db.t4g.micro"
            user            = "owner_dbuser" 
        },
        {
            name            = "serviceinfo"
            instance_type   = "db.t4g.micro"
            user            = "serviceinfo_dbuser" 
        }
    ]
}