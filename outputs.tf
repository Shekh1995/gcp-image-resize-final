output "source_bucket_name" {
  description = "Upload images to this Cloud Storage bucket."
  value       = google_storage_bucket.source.name
}

output "resized_bucket_name" {
  description = "Resized JPEG and PNG images are written to this bucket."
  value       = google_storage_bucket.resized.name
}

output "function_source_bucket_name" {
  description = "Bucket containing the generated Cloud Function source archive."
  value       = google_storage_bucket.function_source.name
}

output "cloud_function_name" {
  description = "Name of the event-driven Cloud Function."
  value       = google_cloudfunctions_function.image_resize.name
}

output "service_account_email" {
  description = "Runtime service account used by the Cloud Function."
  value       = google_service_account.function.email
}

output "pubsub_topic_name" {
  description = "Topic that receives successful resize notifications."
  value       = google_pubsub_topic.image_resize.name
}

output "pubsub_subscription_name" {
  description = "Subscription attached to the resize notification topic."
  value       = google_pubsub_subscription.image_resize.name
}
