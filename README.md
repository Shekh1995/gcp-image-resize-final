# Image Resizer — Google Cloud

This repository provisions a serverless image resizing pipeline on Google Cloud using Terraform and Cloud Functions.

What it does
- Watches a GCS source bucket for new images
- Resizes images with Pillow inside a Cloud Function
- Stores resized images in a destination GCS bucket
- Optionally publishes notifications to a Pub/Sub topic

Quick start
1. Copy example variables and edit:

```bash
cp terraform.tfvars.example terraform.tfvars
# set project_id, region, notification_email, etc.
```

2. (Optional) Create a remote state bucket and backend config:

```bash
gsutil mb gs://your-terraform-state-bucket
cp backend.tfvars.example backend.tfvars
terraform init -backend-config=backend.tfvars
```

3. Initialize and deploy:

```bash
terraform init
terraform plan
terraform apply
```

Packaging function code
- Function sources are in `function_src/`.
- Use `scripts/create_zip.py` to create `CreateThumbnail.zip` containing `main.py` and `requirements.txt` for Cloud Build.

Notes
- Ensure `project_id` is set and APIs (Cloud Functions, Cloud Build, Cloud Storage, Pub/Sub) are enabled.
- Bucket names must be globally unique.
- `DESTINATION_BUCKET` and `PUBSUB_TOPIC` environment variables are set via Terraform in `cloud_function.tf`.

If you need to inspect the function package, use `scripts/list_zip.py` or `scripts/show_zip_file.py`.

Support
- Google Cloud Functions docs: https://cloud.google.com/functions/docs
- Google Cloud Storage docs: https://cloud.google.com/storage/docs
