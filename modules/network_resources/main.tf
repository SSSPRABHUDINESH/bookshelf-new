# VPC network with Custom Subnet

resource "google_compute_network" "vpc-network" {
  name                    = var.vpc-network-name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet" {
  name          = var.bookshelf-subnet-name
  ip_cidr_range = var.bookshelf-subnet-ip-range
  region        = var.region
  network       = google_compute_network.vpc-network.id
  secondary_ip_range {
    range_name    = var.secondary_ip_range_name
    ip_cidr_range = var.secondary_ip_range
  }
}

# Firewall rules starts from here

resource "google_compute_firewall" "rules" {
  project = var.project_id
  name    = "allow-health-check"
  network = google_compute_network.vpc-network.id


  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["health-check"]
}
resource "google_compute_firewall" "allow-ssh" {
  project = var.project_id
  name    = "allow-ssh"
  network = google_compute_network.vpc-network.id


  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-ssh"]
}

# Router for Cloud Nat 
resource "google_compute_router" "router" {
  name    = var.router-name
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc-network.id

  bgp {
    asn = 64514
  }
}

# Cloud Nat 
resource "google_compute_router_nat" "nat" {
  name                               = var.nat-name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Private IP address for the SQL 

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = google_compute_network.vpc-network.self_link
}


#Load Balancer 
resource "google_compute_global_address" "default" {
  name     = var.static-ip-name
}


resource "google_compute_global_forwarding_rule" "default" {
  name                  = var.forwarding-rule-name
  provider              = google
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.address
}


resource "google_compute_target_http_proxy" "default" {
  name     = var.target-http-proxy-name
  
  url_map  = google_compute_url_map.default.id
}


resource "google_compute_url_map" "default" {
  name            = var.url-map-name
 
  default_service = google_compute_backend_service.default.id
}


resource "google_compute_backend_service" "default" {
  name                  = var.backend-service-name
  
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [var.health_check_id]
  backend {
    group           = var.mig_id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
