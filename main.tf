variable PROJECT {
    type    = string
}

variable VERSION {
    type    = string
}

provider "google" {
    version             = "=3.32"
    project             = var.PROJECT
}

module "bookstore-gcp" {
    source                  = "./bookstore-gcp"
    gcp_project             = var.PROJECT
    gcp_region              = "europe-west1"
    gcp_application_name    = "my-bookstore-app"
    gcr_hostname            = "gcr.io"
    gcr_image               = "pm-demo"
    gcr_image_tag           = var.VERSION
}