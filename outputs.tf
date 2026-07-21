output "source_bucket_name" {
  description = "Name of the source Cloud Storage bucket"
  value       = google_storage_bucket.image-source.name
}

output "resized_bucket_name" {
  description = "Name of the destination Cloud Storage bucket for resized images"
  value       = google_storage_bucket.image-resized.name
}

output "cloud_function_name" {
  description = "Name of the Cloud Function"
  value       = google_cloudfunctions_function.image-resize-function.name
}

output "service_account_email" {
  description = "Email of the service account used by Cloud Function"
  value       = google_service_account.cloud-function-sa.email
}

output "pubsub_topic_name" {
  description = "Name of the Pub/Sub topic for notifications"
  value       = google_pubsub_topic.image-resize-topic.name
}

output "pubsub_subscription_name" {
  description = "Name of the Pub/Sub subscription"
  value       = google_pubsub_subscription.image-resize-subscription.name
}

output "cloud_function_region" {
  description = "Region of the Cloud Function"
  value       = google_cloudfunctions_function.image-resize-function.region
}

output "gcp_project_id" {
  description = "Google Cloud Project ID"
  value       = var.project_id
}

output "region" {
  description = "Google Cloud Region"
  value       = var.region
}
