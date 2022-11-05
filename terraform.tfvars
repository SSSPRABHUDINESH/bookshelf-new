region             = "us-central1"
zone               = "us-central1-a"
project_id         = "gcp-2021-2-bookshelf-dineshs"
remote_bucket_name = "bucket-be-bookshelf-5"
prefix_project     = "bookshelf"
password           = "2001"

#Inputs for network resources

vpc_network_name          = "bookshelf-vpc"
bookshelf_subnet_name     = "bookshelf-subnet"
bookshelf_subnet_ip_range = "10.0.0.0/20"
secondary-ip-range-name   = "bookshelf-subnet-secondary-ip"
secondary-ip-range        = "192.168.10.0/24"

router_name = "bookshelf-router"
nat_name    = "bookshelf-nat"

static_ip_name         = "lb-static-ip"
forwarding_rule_name   = "lb-forwarding-rule"
target_http_proxy_name = "lb-target-http-proxy"
url_map_name           = "lb-url-map"
backend_service_name   = "lb-backend-service"

# inputs for compute resources
template_name       = "bookshelf-template-terraform"
autoscaler-name     = "bookshelf-autoscaler"
max-replicas        = 3
min-replicas        = 2
cooldown-period     = 300
health-check-name   = "bookshelf-healthcheck"
check-interval-sec  = 5
timeout-sec         = 5
healthy-threshold   = 2
unhealthy-threshold = 2
port_num            = 8080

instance-group-manager-name  = "bookshelf-instancegroup-manager"
bookshelf-base-instance-name = "bookshelf-base-instance"
service-account-display-name = "bookshelf-terraform-sa"
service-account-id           = "bookshelf-terraform-sa"

image-bucket-name = "image-sql-bookshelf-bucket-5"
sql_instance_name = "bookshelf-sql-instance-20"
sql_database_name = "bookshelf-db"
sql_username      = "root"

# inputs for jump_server

instance-name = "jump-server"