variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "project_id" {
  type = string
}

variable "prefix_project" {
  type = string
}

variable "remote_bucket_name" {
  type = string
}
variable "password" {
  type = string
}


# module network resources 

variable "vpc_network_name" {
  type = string
}
variable "bookshelf_subnet_name" {
  type = string
}
variable "bookshelf_subnet_ip_range" {
  type = string
}
variable "secondary-ip-range-name" {
  type = string
}
variable "secondary-ip-range" {
  type = string
}

# nat
variable "router_name" {
  type = string
}
variable "nat_name" {
  type = string
}

#loadbalancer

variable "static_ip_name" {
  type = string
}
variable "forwarding_rule_name" {
  type = string
}
variable "target_http_proxy_name" {
  type = string
}
variable "url_map_name" {
  type = string
}
variable "backend_service_name" {
  type = string
}

# module compute resources

variable "template_name" {
  type = string
}
variable "autoscaler-name" {
  type = string
}
variable "max-replicas" {
  type = number
}
variable "min-replicas" {
  type = number
}
variable "cooldown-period" {
  type = number
}
variable "health-check-name" {
  type = string
}
variable "check-interval-sec" {
  type = number
}
variable "timeout-sec" {
  type = number
}
variable "healthy-threshold" {
  type = number
}
variable "unhealthy-threshold" {
  type = number
}
variable "port_num" {
  type = number
}

variable "instance-group-manager-name" {
  type = string
}
variable "bookshelf-base-instance-name" {
  type = string
}
variable "service-account-display-name" {
  type = string
}
variable "service-account-id" {
  type = string
}

# module storage resources

variable "image-bucket-name" {
  type = string
}
variable "sql_instance_name" {
  type = string
}
variable "sql_database_name" {
  type = string
}
variable "sql_username" {
  type = string
}


variable "instance-name" {
  type = string
}


