resource "google_service_account" "function" {
  account_id   = "image-resize-function"
  display_name = "Image Resize Cloud Function"

  depends_on = [google_project_service.required["iam.googleapis.com"]]
}

resource "google_storage_bucket_iam_member" "source_reader" {
  bucket = google_storage_bucket.source.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.function.email}"
}

resource "google_storage_bucket_iam_member" "destination_writer" {
  bucket = google_storage_bucket.resized.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.function.email}"
}

resource "google_pubsub_topic_iam_member" "function_publisher" {
  topic  = google_pubsub_topic.image_resize.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.function.email}"
}

resource "google_project_iam_member" "function_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.function.email}"
}
