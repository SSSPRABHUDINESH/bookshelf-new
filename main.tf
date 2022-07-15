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

  vpc-network-name          = "bookshelf-vpc"
  bookshelf-subnet-name     = "bookshelf-subnet"
  bookshelf-subnet-ip-range = "10.0.0.0/20"
  secondary_ip_range_name   = "bookshelf-subnet-secondary-ip"
  secondary_ip_range        = "192.168.10.0/24"

  # Router and Nat inputs starts from here
  router-name = "bookshelf-router"
  nat-name    = "bookshelf-nat"


  # loadbalancer inputs starts from here
  health_check_id        = module.compute_resources.health_check_id
  mig_id                 = module.compute_resources.mig_id
  static-ip-name         = "lb-static-ip"
  forwarding-rule-name   = "lb-forwarding-rule"
  target-http-proxy-name = "lb-target-http-proxy"
  url-map-name           = "lb-url-map"
  backend-service-name   = "lb-backend-service"
}

module "compute_resources" {
  source = "./modules/compute_resources"

  project_id    = var.project_id
  template-name = "bookshelf-template-terraform"
  # Autoscaler inputs starts from here
  zone            = var.zone
  autoscaler_name = "bookshelf-autoscaler"
  max_replicas    = 2
  min_replicas    = 1
  cooldown_period = 300
  # Healthcheck inputs starts from here
  health_check_name   = "bookshelf-healthcheck"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  port                = 8080
  # Instance group manager inputs starts from here
  instance_group_manager_name  = "bookshelf-instancegroup-manager"
  bookshelf_base_instance_name = "bookshelf-base-instance"
  network_id                   = module.network_resources.vpc_network_id
  subnetwork_id                = module.network_resources.vpc_subnetwork_id
  service_account_display_name = "bookshelf-terraform-sa"
  service_account_id           = "bookshelf-terraform-sa"
}

module "storage_resources" {
  source = "./modules/storage_resources"

  image_bucket_name       = "image-sql-bookshelf-bucket"
  sql-instance-name       = "bookshelf-sql-instance-10"
  vpc_network_id          = module.network_resources.vpc_network_id
  region                  = var.region
  private_ip_address_id   = module.network_resources.private_ip_address_id
  private_ip_address_name = module.network_resources.private_ip_address_name
  # SQL-Database
  sql-database-name = "bookshelf-db"
  # User
  sql-username = "root"
  sql-password = var.password
}