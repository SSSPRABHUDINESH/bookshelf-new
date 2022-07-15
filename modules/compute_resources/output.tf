output "health_check_id" {
  value = google_compute_health_check.autohealing.id
}
output "mig_id" {
  value = google_compute_instance_group_manager.appserver.instance_group
}