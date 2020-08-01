terraform {
  experiments = [variable_validation]

  required_providers {
    google = ">=3.32"
  }
}

variable "gcp_project" {
    type                = string
    description         = "The GCP Project"
    default             = "storied-box-285108"
}

variable "gcp_region" {
    type                = string
    description         = "The GCP region to deploy the bookstore"
    default             = "europe-west1"

    validation {
        condition       = contains(["europe-west1", "us-central1"], var.gcp_region)
        error_message   = "The GCP Region for Cloud Run must be one of the approved choices."
    }
}

variable "gcp_application_name" {
    type                = string
    description         = "The GCP Application Name"
    default             = "pm-demo-terraform"
}


variable "gcr_hostname" {
    type                = string
    description         = "The GCR hostname"
    default             = "eu.gcr.io"

    validation {
        condition       = contains(["eu.gcr.io", "gcr.io", "us.gcr.io"], var.gcr_hostname)
        error_message   = "The GCR hostname must be one of the approved choices."
    }
}

variable "gcr_image" {
    type                = string
    description         = "The GCR container image name"
    default             = "pm-demo"
}

variable "gcr_image_tag" {
    type                = string
    description         = "The GCR container image tag to deploy"
    default             = "1.0.0-72714369"
}


data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}


resource "google_cloud_run_service" "bookstore" {
  name                  = var.gcp_application_name
  location              = var.gcp_region
  project               = var.gcp_project

  template {
    spec {
      containers {
        image = "${var.gcr_hostname}/${var.gcp_project}/${var.gcr_image}:${var.gcr_image_tag}"
      }
    }
  }

  traffic {
    percent             = 100
    latest_revision     = true
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location              = google_cloud_run_service.bookstore.location
  project               = google_cloud_run_service.bookstore.project
  service               = google_cloud_run_service.bookstore.name
  policy_data           = data.google_iam_policy.noauth.policy_data
}


output "url" {
  value = "${google_cloud_run_service.bookstore.status[0].url}"
}