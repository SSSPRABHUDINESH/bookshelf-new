variable "region" {
  type    = string
  default = "us-central1"
}
variable "bookshelf-subnet-name" {
  type = string
}
variable "bookshelf-subnet-ip-range" {
  type = string
}
variable "secondary_ip_range_name" {
  type = string
}
variable "secondary_ip_range" {
  type = string
}
variable "vpc-network-name" {
  type = string
}

variable "project_id" {
  type    = string
  default = "gcp-2021-2-bookshelf-satya"
}
variable "health_check_id" {
  type = string
}
variable "mig_id" {
  type = string
}
variable "static-ip-name" {
  type = string
}
variable "forwarding-rule-name" {
  type = string
}
variable "target-http-proxy-name" {
  type = string
}
variable "url-map-name" {
  type = string
}
variable "backend-service-name" {
  type = string
}
variable "router-name" {
  type = string
}
variable "nat-name" {
  type = string
}