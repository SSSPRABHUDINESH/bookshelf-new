variable "network_id" {
  type = string
}
variable "subnetwork_id" {
  type = string
}
variable "service_account_id" {
  type = string
}
variable "service_account_display_name" {
  type = string
}
variable "project_id" {
  type = string
}
variable "template-name" {
  type = string
}
variable "autoscaler_name" {
  type = string
}
variable "zone" {
  type = string
}
variable "max_replicas" {
  type = number
}
variable "min_replicas" {
  type = number
}
variable "cooldown_period" {
  type = number
}
variable "health_check_name" {
  type = string
}
variable "check_interval_sec" {
  type = number
}
variable "timeout_sec" {
  type = number
}
variable "healthy_threshold" {
  type = number
}
variable "unhealthy_threshold" {
  type = number
}
variable "port" {
  type = number
}
variable "instance_group_manager_name" {
  type = string
}
variable "bookshelf_base_instance_name" {
  type = string
}