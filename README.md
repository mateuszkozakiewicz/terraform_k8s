# Project setup

## Requirements

- Terraform
- gcloud-cli
- Helm

## Create a service account for terraform

https://console.cloud.google.com/iam-admin/serviceaccounts?project=*project-name*

## Initialize gcloud-cli

```
gcloud init
```

## Create account.json

```
gcloud iam service-accounts keys create ./account.json --iam-account _service-account-name_@_project-name_.iam.gserviceaccount.com
```

## Create Google Storage for Terraform state

```
gsutil mb -p *project_name* gs://*unique-storage-name*
```

## Download Terraform dependencies and configure variables

```
terraform init
```

See: [terraform.tfvars](./terraform.tfvars)

## Create cluster

```
terraform apply
```

## Configure kubectl

Terraform automatically configures kubectl to the cluster instance when creating it,  
to configure it again later use:

```
gcloud container clusters get-credentials $(terraform output cluster_name) --zone $(terraform output cluster_zone)
```
