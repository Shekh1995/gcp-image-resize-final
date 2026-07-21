resource "google_pubsub_topic" "image-resize-topic" {
  name = var.pubsub_topic_name
}

resource "google_pubsub_subscription" "image-resize-subscription" {
  name  = "${var.pubsub_topic_name}-subscription"
  topic = google_pubsub_topic.image-resize-topic.name
  
  ack_deadline_seconds = 60
  
  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.image-resize-dlq.id
    max_delivery_attempts = 5
  }
}

resource "google_pubsub_topic" "image-resize-dlq" {
  name = "${var.pubsub_topic_name}-dlq"
}
