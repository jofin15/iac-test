terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = "payments-dev-478615"
  region  = "us-central1"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# This bucket stores the access logs for the main bucket
resource "google_storage_bucket" "log_bucket" {
  name                        = "vault-demo-logs-${random_id.bucket_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket" "secure_bucket" {
  name                        = "vault-demo-bucket-${random_id.bucket_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  # Fix for CKV_GCP_62 - enable access logging
  logging {
    log_bucket        = google_storage_bucket.log_bucket.name
    log_object_prefix = "access-logs/"
  }
}
