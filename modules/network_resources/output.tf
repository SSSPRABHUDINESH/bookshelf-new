output "vpc_network_id" {
  value = google_compute_network.vpc-network.id
}
output "vpc_subnetwork_id" {
  value = google_compute_subnetwork.subnet.id
}
output "private_ip_address_name" {
  value = google_compute_global_address.private_ip_address.name
}
output "private_ip_address_id" {
  value = google_compute_global_address.private_ip_address.id
}
output "vpc-network-selflink" {
  value = google_compute_network.vpc-network.self_link
}
output "vpc-network" {
  value = google_compute_network.vpc-network
}