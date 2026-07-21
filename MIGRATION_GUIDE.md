# Migration Guide: AWS to Google Cloud

This document outlines the changes made to convert the image resizing project from AWS to Google Cloud Platform (GCP).

## Service Mapping

| AWS Service | Google Cloud Service | File |
|-------------|---------------------|------|
| AWS Lambda | Cloud Functions | `cloud_function.tf` |
| Amazon S3 | Cloud Storage (GCS) | `storage.tf` |
| Amazon SNS | Cloud Pub/Sub | `pub.tf` |
| AWS IAM | Google Cloud IAM | `iam-role.tf` |
| AWS Access Keys | Service Account | `iam-role.tf` |

## Key Changes

### 1. Provider Configuration (`providers.tf`)
- **Before**: AWS provider with access key/secret
- **After**: Google Cloud provider with project ID and region

### 2. Variables (`variables.tf`)
- **Removed**: `aws_access_key`, `aws_secret_key`, `aws_region`
- **Added**: `project_id`, `region` (for GCP)
- **Renamed**: 
  - `s3-bucket-lambda-code` → `gcs-bucket-source`
  - `s3-bucket-dest` → `gcs-bucket-dest`
  - `sns-name` → `pubsub-topic-name`
  - `mail-id` → `notification-email`

### 3. Storage (`storage.tf`)
- **Before**: `aws_s3_bucket` resources
- **After**: `google_storage_bucket` resources
- Bucket names now use project ID as prefix for uniqueness

### 4. Cloud Functions (`cloud_function.tf`)
- **Before**: `aws_lambda_function` with:
  - Zip file upload
  - Lambda layers for dependencies
  - S3 trigger configuration
- **After**: `google_cloudfunctions_function` with:
  - Source repository deployment
  - Built-in Python packages
  - GCS trigger configuration
  - Service account-based authentication

### 5. Notifications (`pub.tf`)
- **Before**: AWS SNS topic with email subscription
- **After**: Google Cloud Pub/Sub topic with subscription configuration
- Includes dead letter queue for reliability

### 6. IAM & Security (`iam-role.tf`)
- **Before**: AWS IAM role with JSON policy file
- **After**: Google Service Account with granular IAM member bindings:
  - `roles/storage.objectCreator` - Write to destination bucket
  - `roles/pubsub.publisher` - Publish to Pub/Sub topic
  - `roles/logging.logWriter` - Cloud Logging access

### 7. Local Values (`locals.tf`)
- **Before**: Extract AWS account ID from `aws_caller_identity`
- **After**: Simple local with project ID

### 8. Backend (`backend.tf`)
- **Before**: Local backend
- **After**: GCS backend (configurable via init flags)

## Deployment Steps

### 1. Setup Google Cloud Project
```bash
gcloud projects create image-resize-project
gcloud config set project image-resize-project
gcloud auth application-default login
```

### 2. Enable Required APIs
```bash
gcloud services enable \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  storage-api.googleapis.com \
  pubsub.googleapis.com \
  iam.googleapis.com \
  logging.googleapis.com
```

### 3. Create Terraform State Bucket (Optional)
```bash
gsutil mb gs://your-terraform-state-bucket/
cp backend.tfvars.example backend.tfvars
```

Edit `backend.tfvars` and replace `your-terraform-state-bucket` with your actual bucket name.

### 4. Configure Terraform
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project details
```

### 5. Initialize and Deploy
```bash
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply
```

## Important Notes

### Cloud Function Code
Unlike AWS Lambda which packages code as ZIP files, Google Cloud Functions typically use:
- Cloud Source Repository
- Cloud Build
- Inline code (for small functions)

You'll need to deploy your Python function separately using:
```bash
gcloud functions deploy image-resize-function \
  --runtime python310 \
  --trigger-resource <SOURCE_BUCKET> \
  --trigger-event google.storage.object.finalize \
  --entry-point resize_image \
  --service-account-email image-resize-function-sa@project-id.iam.gserviceaccount.com
```

### Bucket Naming
- GCS bucket names must be globally unique
- The Terraform configuration uses `${project_id}-${bucket_name}` convention

### Dependencies
- Pillow library is available in Cloud Functions Python 3.9 runtime
- No need for layers like in AWS Lambda

### Permissions
- Ensure your user account has sufficient IAM permissions
- Recommended: `Project Editor` or custom role with necessary permissions

### Cost Differences
- Google Cloud Functions: First 2M invocations free per month
- Cloud Storage: Similar to S3 pricing but region-specific
- Pub/Sub: Pay-per-message model

## Troubleshooting

### Cloud Function Not Triggering
- Check service account has `roles/storage.objectViewer` on source bucket
- Verify function status: `gcloud functions describe image-resize-function`
- Check logs: `gcloud functions logs read image-resize-function --limit 50`

### Permission Denied Errors
- Verify service account email is correct
- Check IAM bindings: `gcloud projects get-iam-policy PROJECT_ID`
- Ensure APIs are enabled for the project

### Pub/Sub Messages Not Received
- Verify subscription push endpoint is configured
- Check dead letter topic for failed messages
- Review Pub/Sub logs in Cloud Logging

## Rollback

If you need the previous AWS implementation, it's available in the Git history; this repository is now GCP-focused.

## Additional Resources

- [Google Cloud Functions Documentation](https://cloud.google.com/functions/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Cloud Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
