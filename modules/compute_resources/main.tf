resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}
data "google_iam_policy" "admin" {
  binding {
    role = "roles/owner"

    members = [
      "serviceAccount:${google_service_account.service_account.email}",
    ]
  }
}

resource "google_project_iam_member" "iam_user_secretAccessor_user" {
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "iam_user_loggingadmin_user" {
  role   = "roles/logging.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}
resource "google_project_iam_member" "iam_user_cloudsql_instance_user" {
  role   = "roles/cloudsql.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}
resource "google_project_iam_member" "iam_user_computeadmin_user" {
  role   = "roles/compute.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}
resource "google_project_iam_member" "iam_user_sourcereader_user" {
  role   = "roles/source.reader"
  member = "serviceAccount:${google_service_account.service_account.email}"
}
resource "google_project_iam_member" "iam_user_storagea_user" {
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "iam_owner_user" {
  role   = "roles/owner"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_service_account_iam_policy" "project" {
  service_account_id = google_service_account.service_account.name
  policy_data        = data.google_iam_policy.admin.policy_data
}


data "google_compute_image" "debian9-image" {
  family  = "debian-9"
  project = "debian-cloud"
}

resource "google_compute_instance_template" "bookshelf-instance-template" {
  name         = var.template-name
  machine_type = "e2-medium"
  tags         = ["health-check", "allow-ssh"]

  disk {
    source_image = data.google_compute_image.debian9-image.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id
  }

  metadata_startup_script = file("modules/compute_resources/startup_script.sh")
  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }


}


resource "google_compute_autoscaler" "default" {
  provider = google-beta

  name   = var.autoscaler_name
  zone   = var.zone
  target = google_compute_instance_group_manager.appserver.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period


  }
}


resource "google_compute_health_check" "autohealing" {
  name                = var.health_check_name
  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  tcp_health_check {
    port = var.port
  }
}

resource "google_compute_instance_group_manager" "appserver" {
  name = var.instance_group_manager_name

  base_instance_name = var.bookshelf_base_instance_name
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.bookshelf-instance-template.id
  }

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }
}
