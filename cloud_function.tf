resource "google_cloudfunctions_function" "image-resize-function" {
  name        = "image-resize-function"
  runtime     = "python310"
  region      = var.region
  project     = var.project_id
  
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.image-source.name
  }
  
  available_memory_mb   = 256
  timeout              = 60
  entry_point          = "resize_image"
  
  # Deploy inline code - ensure this matches your actual function code
  source_archive_bucket = google_storage_bucket.function-source.name
  source_archive_object = google_storage_bucket_object.function_zip.name

  environment_variables = {
    DESTINATION_BUCKET = google_storage_bucket.image-resized.name
    PUBSUB_TOPIC       = google_pubsub_topic.image-resize-topic.name
  }

  service_account_email = google_service_account.cloud-function-sa.email

  depends_on = [
    google_storage_bucket.image-source,
    google_storage_bucket.image-resized,
    google_pubsub_topic_iam_member.function-pubsub-publisher
  ]
}

# Storage bucket for Cloud Function source code
resource "google_storage_bucket" "function-source" {
  name          = "${var.project_id}-function-source"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
}

# Upload function code to GCS
# Note: Upload your function code as a .zip file
resource "google_storage_bucket_object" "function_zip" {
  name   = "resize-function.zip"
  bucket = google_storage_bucket.function-source.name
  source = "./CreateThumbnail.zip"  # Update path to your function zip file
}

# Enable function to be triggered by GCS events
resource "google_storage_bucket_iam_member" "gcs-invoker" {
  bucket = google_storage_bucket.image-source.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud-function-sa.email}"
}