
output "healthcheck_id" {
  value = module.compute_resources.health_check_id
}
output "mig_id" {
  value = module.compute_resources.mig_id
}
output "network_name" {
  value = module.network_resources.vpc_network_id
}
output "subnetwork_name" {
  value = module.network_resources.vpc_subnetwork_id
}
output "private-ip-address-id" {
  value = module.network_resources.private_ip_address_id
}
output "private-ip-address-name" {
  value = module.network_resources.private_ip_address_name
}