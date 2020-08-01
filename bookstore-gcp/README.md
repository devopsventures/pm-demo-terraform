# bookstore-gcp

A Terraform module that can deploy the bookstore application to Google Cloud Platform Cloud Run Service.

## Parameters

* `gcp_project`: The GCP Project that we are working inside
* `gcp_region`: The primary region we are interacting with
* `gcp_application_name`: The name of the Cloud Run application
* `gcr_hostname`: The hostname of the Google Container Repository
* `gcr_image`: The name of the container image in the repository
* `gcr_image_tag`: The tag of the container image to deploy to Cloud Run


## Requirements

You need to have configured a `google` provider before invoking this module as it will use this to access GCP.


## Usage

```hcl
module "bookstore-gcp" {
    source                  = "<path_to_module_installation>"
    gcp_project             = "storied-box-123455"
    gcp_region              = "europe-west1"
    gcp_application_name    = "my_bookstore_app"
    gcr_hostname            = "eu.gcr.io"
    gcr_image               = "bookstore"
    gcr_image_tag           = "latest"
}
``` 