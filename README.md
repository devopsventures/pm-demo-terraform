# pm-demo-terraform

An example project for deploying the pm-demo bookstore application in GCP Cloud Run.

This project uses Terragrunt to configure a GCS storage backend.

## Purpose
The purpose of this repository and GitHub Actions workflows is the showcase the following:

* Using Terraform and Terragrunt under GitHub Actions
* Injecting a GCS backend into Terraform (using Terragrunt), providing the credentials at run time
* Providing a split between Terraform `plan` and `apply` for some validation approval activities

This repository is somewhat hard coded to the GCP service that it was built around and will only run there in its current form. The workflows are present from various runs/invocations and you are free to delve into these to see the outputs from these runs.

__The secrets associated with the repository have been populated with dummy data, so no further invocations are currently possible.__


## Requirements

The repository (or hosting Organization) needs to have the following secrets defined:
* `GCP_PROJECT`: The GCP project ID that will be modified
* `GCP_TERRAFORM_SERVICE_ACCOUNT_KEY`: The GCP service account key (in plain JSON or base64 encoded value of the JSON file), this user must be permissioned so that whatever is in the terraform modules can be created/destroyed.

__Note: Storing the JSON keys for GCP as base64 encoded values is safer as GitHub Actions can properly mask it better than a JSON object.__

## Terraform and Terragrunt
This is a very simple Terraform example that at the top level takes a GCP Project and a Version (i.e. container tag) and configures a Google Cloud Platform provider to set up and deploy a Cloud Run container as a Web application exposed to the internet.

Terragrunt is used here just to show that you can utilize it and is providing the plumbing for GCS backend storage for the Terraform state file. It can do so much more, but provides a hint at how it can be used in practice.

### Cloud Run module - bookstore-gcp
This is a simple module that will deploy a container to the GCP Cloud Run service. Consult the [README.md](bookstore-gcp) for more details.


## GitHub Actions
There are two sets of coupled workflows present in this project. Both sets follow the same split between `plan` and `apply`, but do it in a subtly different way.

The principle of splitting the `plan` and `apply` phases here are to provide a means of adding some external process of review and approve mechanism between generating the plan and then later applying it.

__Note: The Terraform plans can contain sensitive secrets depending upon your modules and how you structure your Terraform files. Terragrunt can greatly help in this regard, and you can leverage GCP default authentication mechanisms to elimintate your cloud credentials ending up inside your plan files. Your milage here may vary.__

You can use any desired mechaism you want for securing and storing the plan files, like uploading to Artifactory, storing in a cloud backed bucket (GCS, S3, etc...), this example is just showing you one possible way to achieve that.


### Terraform Plan and Apply
The workflows (Terraform Generate Plan)[.github/workflows/terraform_plan.yml] and (Terraform Apply Plan)[.github/workflows/terraform_apply.yml] are a coupled pair of workflows.

By running the `Terraform Generate Plan` workflow, it takes in a version tag for the container to be deployed to GCP Cloud Run. This will run Terraform against the GCS backend and compare the desired changes against the known state and then save the Terraform plan as an artifact on the Actions run.

A user/approver can then access the artifact, by downloading it and review the contained plan. If they decide that the plan is good, they can then apply the plan using the `Terraform Apply Plan` workflow. This workflow will request a Commit SHA for the repository that the plan was generated from (you can find this in the `actions.json` file in the artifact bundle that contains some metadata from the plan actions run).

In this scenario it uses the commit SHA to download the `plan.zip` artifact from the `Terraform Generate Plan` workflow which contains the plan that needs to be applied. This uses the `dawidd6/action-download-artifact@v2` communit provided action to do this, but you can customize this or roll your own implmentation fairly easily if you have other requirements for sharing the plan.


### Terraform Plan and Apply using GitHub Issue
The workflows (Terraform Generate Plan with Issue)[.github/workflows/terraform_plan_issue.yml] and (Terraform Apply Plan from Issue)[.github/workflows/terraform_apply_issue.yml] are a coupled pair of workflows.

By running the `Terraform Generate Plan with Issue` workflow, you will be prompted for a version tag for the container to be deployed to GCP Cloud Run. This will run Terraform against the GCP backend and compare the desired state to the known state stored there, saving the plan outputs and some metadata in a `plan.zip` artifact on the Actions workflow run. It will also open a new GitHub Issue for the run and place some metadata and the contents of the plan in the issue body (along with applying an Issue label to mark it out as a terraform plan).

A user/approver can then review the issue ticket and decide whether or not to apply it. Which they can to by taking the Commit SHA provided in the issue and pass that in to a manual invocation of the `Terraform Apply Plan from Issue`.

The `Terraform Apply Plan from Issue` works just like that of the `Terraform Apply Plan` detailed above execpt that it sources the plan from the workflow that generated the issue.

__Note: In this very simple proof of concept, a plan Issue is always created, even if there are no changes to apply. You can check the output of the plan step to see if there are changes and gate the creation of the Issue ticket to only open one if there are actual changes to apply.__

__Note: There are a number of improvements that couple be made here to further connect the workflows and introduce more levels of automation, like for example adding a workflow that triggers in issues comments to apply the plan (validating the user has the correct privileges to approve by checking membership in a team for instance).__

