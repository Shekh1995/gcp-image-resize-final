resource "google_storage_bucket" "source" {
  name                        = "${var.project_id}-${var.source_bucket_suffix}"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  depends_on = [google_project_service.required["storage.googleapis.com"]]
}

resource "google_storage_bucket" "resized" {
  name                        = "${var.project_id}-${var.destination_bucket_suffix}"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  depends_on = [google_project_service.required["storage.googleapis.com"]]
}

resource "google_storage_bucket" "function_source" {
  name                        = "${var.project_id}-${var.function_source_bucket_suffix}"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  depends_on = [google_project_service.required["storage.googleapis.com"]]
}
