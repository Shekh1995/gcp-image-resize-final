resource "google_storage_bucket" "image-source" {
  name          = "${var.project_id}-${var.gcs_bucket_source}"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_storage_bucket" "image-resized" {
  name          = "${var.project_id}-${var.gcs_bucket_dest}"
  location      = var.region
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}