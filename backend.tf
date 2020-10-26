terraform {
  backend "gcs" {
    bucket      = "k8s-free-tf-state"
    prefix      = "terraform/state"
    credentials = "account.json"
  }
}
