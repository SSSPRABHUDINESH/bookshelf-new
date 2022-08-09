resource "google_compute_instance" "jump_server" {
  name         = var.instance_name
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id
  }

  metadata_startup_script = file("modules/jump_server/startup_script.sh")

  service_account {
    email  = var.sa_email
    scopes = ["cloud-platform"]
  }
}