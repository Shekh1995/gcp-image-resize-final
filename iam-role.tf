resource "google_service_account" "cloud-function-sa" {
  account_id   = "image-resize-function-sa"
  display_name = "Image Resize Cloud Function Service Account"
}

# Grant Cloud Functions service account permissions to write to destination bucket
resource "google_storage_bucket_iam_member" "function-dest-bucket" {
  bucket = google_storage_bucket.image-resized.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.cloud-function-sa.email}"
}

# Grant Cloud Functions service account permissions to publish to Pub/Sub
resource "google_pubsub_topic_iam_member" "function-pubsub-publisher" {
  topic  = google_pubsub_topic.image-resize-topic.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.cloud-function-sa.email}"
}
