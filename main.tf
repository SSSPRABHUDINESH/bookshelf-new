terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
  }
}
provider "google" {
  credentials = file("bookshelf-credentials.json")

  project = var.project_id
  region  = var.region
  zone    = var.zone
}
provider "google-beta" {
  credentials = file("bookshelf-credentials.json")

  project = var.project_id
  region  = var.region
  zone    = var.zone
}
data "terraform_remote_state" "remote_state" {
  backend = "gcs"

  config = {
    bucket      = var.remote_bucket_name
    prefix      = var.prefix_project
    credentials = file("bookshelf-credentials.json")
  }
}



module "network_resources" {
  source = "./modules/network_resources"

  vpc-network-name          = var.vpc_network_name
  bookshelf-subnet-name     = var.bookshelf_subnet_name
  bookshelf-subnet-ip-range = var.bookshelf_subnet_ip_range
  secondary_ip_range_name   = var.secondary-ip-range-name
  secondary_ip_range        = var.secondary-ip-range

  # Router and Nat inputs starts from here
  router-name = var.router_name
  nat-name    = var.nat_name


  # loadbalancer inputs starts from here
  health_check_id        = module.compute_resources.health_check_id
  mig_id                 = module.compute_resources.mig_id
  static-ip-name         = var.static_ip_name
  forwarding-rule-name   = var.forwarding_rule_name
  target-http-proxy-name = var.target_http_proxy_name
  url-map-name           = var.url_map_name
  backend-service-name   = var.backend_service_name
}

module "compute_resources" {
  source = "./modules/compute_resources"

  project_id    = var.project_id
  template-name = var.template_name
  # Autoscaler inputs starts from here
  zone            = var.zone
  autoscaler_name = var.autoscaler-name
  max_replicas    = var.max-replicas
  min_replicas    = var.min-replicas
  cooldown_period = var.cooldown-period
  # Healthcheck inputs starts from here
  health_check_name   = var.health-check-name
  check_interval_sec  = var.check-interval-sec
  timeout_sec         = var.timeout-sec
  healthy_threshold   = var.healthy-threshold
  unhealthy_threshold = var.unhealthy-threshold
  port                = var.port_num
  # Instance group manager inputs starts from here
  instance_group_manager_name  = var.instance-group-manager-name
  bookshelf_base_instance_name = var.bookshelf-base-instance-name
  network_id                   = module.network_resources.vpc_network_id
  subnetwork_id                = module.network_resources.vpc_subnetwork_id
  service_account_display_name = var.service-account-display-name
  service_account_id           = var.service-account-id
}

module "storage_resources" {
  source = "./modules/storage_resources"

  image_bucket_name       = var.image-bucket-name
  sql-instance-name       = var.sql_instance_name
  vpc_network_id          = module.network_resources.vpc_network_id
  region                  = var.region
  private_ip_address_id   = module.network_resources.private_ip_address_id
  private_ip_address_name = module.network_resources.private_ip_address_name
  # SQL-Database
  sql-database-name = var.sql_database_name
  # User
  sql-username = var.sql_username
  sql-password = var.password
}

module "jump_server" {
  source = "./modules/jump_server"

  instance_name = var.instance-name
  network_id = module.network_resources.vpc_network_id
  subnetwork_id = module.network_resources.vpc_subnetwork_id
  sa_email = module.compute_resources.sa_email_instance

}

