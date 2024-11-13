terraform {
  backend "gcs" {
    bucket = "holi-shared-terraform-state"
    prefix = "chat-server-environments"
  }
}

data "terraform_remote_state" "holi_infra_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "infra"
  }
}

data "terraform_remote_state" "holi_infra_monitoring_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "infra-monitoring"
  }
}

data "terraform_remote_state" "holi_chat_server_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "chat-server-common"
  }
}

# provider google including beta features
provider "google" {
  project = "holi-shared" # string, because referencing google_project.holi_shared would be a cycle
  region  = local.default_region
}

provider "google-beta" {
  project = "holi-shared" # string, because referencing google_project.holi_shared would be a cycle
  region  = local.default_region
}
