# GCP Image Resize Pipeline

Terraform provisions an event-driven image resize pipeline on Google Cloud:

1. An image is uploaded to the source Cloud Storage bucket.
2. A Python Cloud Function resizes it to a maximum of 800×800 pixels.
3. The resized JPEG or PNG is written under `resized/` in the destination bucket.
4. A JSON notification is published to Pub/Sub.

The source and destination buckets are separate, so resized objects never retrigger the function.

## Prerequisites

- Terraform 1.5 or newer
- Google Cloud CLI authenticated to an **existing** Google Cloud project
- Permissions to enable services and create Cloud Functions, Cloud Storage, Pub/Sub, service accounts, and IAM bindings. Project Owner is sufficient for a development project.

Authenticate with Application Default Credentials:

```bash
gcloud auth application-default login
gcloud config set project YOUR_GCP_PROJECT_ID
```

## Deploy

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set `project_id` to your existing project ID. Then run:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform enables the required Google APIs, packages `function_src/` into a ZIP, uploads that ZIP, and deploys the Cloud Function. The generated ZIP is intentionally ignored by Git.

## Test

After apply completes, upload a JPEG or PNG to the output value `source_bucket_name`:

```bash
gsutil cp ./photo.jpg gs://SOURCE_BUCKET/photo.jpg
```

The resized result appears at:

```text
gs://RESIZED_BUCKET/resized/photo.jpg
```

Use Cloud Logging to inspect function executions:

```bash
gcloud functions logs read image-resize-function --region=us-central1 --limit=50
```

Adjust the function name and region in `terraform.tfvars` if you changed their defaults.

## Optional: remote Terraform state

The default setup uses local state so `terraform init` works immediately. To use a GCS state bucket, create the bucket first, then:

```bash
cp backend.tf.example backend.tf
cp backend.tfvars.example backend.tfvars
# Edit backend.tfvars with the existing state bucket name.
terraform init -backend-config=backend.tfvars
```

Do not commit `terraform.tfvars`, `backend.tfvars`, or Terraform state files.
