output "health_check_id" {
  value = google_compute_health_check.autohealing.id
}
output "mig_id" {
  value = google_compute_instance_group_manager.appserver.instance_group
}
output "sa_email_instance" {
  value = google_service_account.service_account.email
}