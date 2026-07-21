terraform {
  backend "gcs" {
    # Use terraform init -backend-config=backend.tfvars to supply the bucket and prefix.
  }
}