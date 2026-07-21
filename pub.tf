data "google_project" "current" {
  project_id = var.project_id
}

locals {
  pubsub_service_agent = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "image_resize" {
  name       = var.pubsub_topic_name
  depends_on = [google_project_service.required["pubsub.googleapis.com"]]
}

resource "google_pubsub_topic" "image_resize_dlq" {
  name       = "${var.pubsub_topic_name}-dlq"
  depends_on = [google_project_service.required["pubsub.googleapis.com"]]
}

resource "google_pubsub_subscription" "image_resize" {
  name  = "${var.pubsub_topic_name}-subscription"
  topic = google_pubsub_topic.image_resize.id

  ack_deadline_seconds = 60

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.image_resize_dlq.id
    max_delivery_attempts = 5
  }
}

# Pub/Sub needs these permissions before it can forward failed messages to the DLQ.
resource "google_pubsub_topic_iam_member" "dlq_publisher" {
  topic  = google_pubsub_topic.image_resize_dlq.name
  role   = "roles/pubsub.publisher"
  member = local.pubsub_service_agent
}

resource "google_pubsub_subscription_iam_member" "subscription_acknowledger" {
  subscription = google_pubsub_subscription.image_resize.name
  role         = "roles/pubsub.subscriber"
  member       = local.pubsub_service_agent
}
