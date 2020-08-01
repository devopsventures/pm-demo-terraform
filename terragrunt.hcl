remote_state {
    backend     = "gcs"

    generate = {
        path        = "backend.tf"
        if_exists   = "overwrite_terragrunt"
    }

    config = {
        bucket  = "pm_demo_terraform_state"
        prefix  = "${ path_relative_to_include() }"
    }
}