data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "${path.module}/function_src"
  output_path = "${path.module}/build/image-resize-function.zip"
}

resource "google_storage_bucket_object" "function_source" {
  name           = "image-resize-function-${data.archive_file.function_source.output_md5}.zip"
  bucket         = google_storage_bucket.function_source.name
  source         = data.archive_file.function_source.output_path
  detect_md5hash = data.archive_file.function_source.output_md5
}

resource "google_cloudfunctions_function" "image_resize" {
  name        = var.function_name
  description = "Resizes images uploaded to the source Cloud Storage bucket."
  project     = var.project_id
  region      = var.region
  runtime     = var.function_runtime

  available_memory_mb   = var.function_memory_mb
  timeout               = var.function_timeout_seconds
  max_instances         = var.function_max_instances
  entry_point           = "resize_image"
  source_archive_bucket = google_storage_bucket.function_source.name
  source_archive_object = google_storage_bucket_object.function_source.name
  service_account_email = google_service_account.function.email

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.source.name
  }

  environment_variables = {
    DESTINATION_BUCKET = google_storage_bucket.resized.name
    PUBSUB_TOPIC       = google_pubsub_topic.image_resize.name
    PROJECT_ID         = var.project_id
  }

  depends_on = [
    google_project_service.required["cloudfunctions.googleapis.com"],
    google_project_service.required["cloudbuild.googleapis.com"],
    google_storage_bucket_iam_member.source_reader,
    google_storage_bucket_iam_member.destination_writer,
    google_pubsub_topic_iam_member.function_publisher,
  ]
}
