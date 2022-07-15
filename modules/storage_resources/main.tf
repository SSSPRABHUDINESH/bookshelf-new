resource "google_storage_bucket" "image-bucket" {
  name          = var.image_bucket_name
  location      = "US"
  force_destroy = true
}

resource "google_storage_default_object_access_control" "public_rule" {
  bucket = google_storage_bucket.image-bucket.name
  role   = "READER"
  entity = "allUsers"
}


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [var.private_ip_address_name]
}

resource "google_sql_database_instance" "sql-instance" {
  name             = var.sql-instance-name
  region           = var.region
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = var.vpc_network_id
    }
  }

}
resource "google_sql_database" "database" {
  name     = var.sql-database-name
  instance = google_sql_database_instance.sql-instance.name
}

resource "google_sql_user" "users" {
  name     = var.sql-username
  instance = google_sql_database_instance.sql-instance.name
  password = var.sql-password

}