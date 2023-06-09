/**
 * The resource ids of resources must be unique. Since we might create resources for a branch multiple times
 * (after destroying the ones created before maybe failed, e.g. on environment cleanup, reopening a branch), we ensure uniqueness
 * by appending some random data to resource ids in order to avoid collisions.
 */
resource "random_id" "main" {
  byte_length = 2
  prefix      = "chat-host-${local.environment_name}-"
}

resource "google_project_service" "service" {
  for_each = toset([
    "run.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicemanagement.googleapis.com",
  ])

  service = each.key

  project            = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  disable_on_destroy = false
}

# in CI, this is set via scripts/create-or-update-env.sh 
variable "image_tag" {
  type     = string
  nullable = false
}

resource "google_cloud_run_service" "chat_server" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name     = random_id.main.hex
  location = "europe-north1" # finland, low CO2 emissions
  # https://github.com/hashicorp/terraform-provider-google/issues/5898
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = data.terraform_remote_state.holi_chat_server_common_state.outputs.cloud_run_service_account_email
      containers {
        image = "${data.terraform_remote_state.holi_infra_state.outputs.gcr_location}/docker/holi-chat-server:${var.image_tag}"
        ports {
          container_port = 8008
        }
        env {
          name  = "ENVIRONMENT"
          value = local.environment
        }
        env {
          name  = "HOLI_CHAT_SERVER_NAME"
          value = local.environment_name == "production" ? "https://production.chat.holi.social" : "https://development.chat.holi.social"
        }
        env {
          name  = "ORY_BASE_URL"
          value = local.environment_name == "production" ? "https://auth.holi.social" : "https://dev-auth.holi.social"
        }
        env {
          name = "HOLI_CHAT_DB_HOST"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? data.terraform_remote_state.holi_infra_state.outputs.database_name_production : data.terraform_remote_state.holi_infra_state.outputs.database_name_development
            }
          }
        }
        env {
          name = "HOLI_CHAT_DB_NAME"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_DB_NAME_PRODUCTION" : "HOLI_CHAT_DB_NAME_DEVELOPMENT"
            }
          }
        }
        env {
          name = "HOLI_CHAT_DB_USER"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_DB_USER_PRODUCTION" : "HOLI_CHAT_DB_USER_DEVELOPMENT"
            }
          }
        }
        env {
          name = "HOLI_CHAT_DB_PASSWORD"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_DB_PASSWORD_PRODUCTION" : "HOLI_CHAT_DB_PASSWORD_DEVELOPMENT"
            }
          }
        }
        env {
          name = "HOLI_CHAT_ORY_CLIENT_ID"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_ORY_CLIENT_ID_PRODUCTION" : "HOLI_CHAT_ORY_CLIENT_ID_DEVELOPMENT"
            }
          }
        }
        env {
          name = "HOLI_CHAT_ORY_CLIENT_SECRET"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_ORY_CLIENT_SECRET_PRODUCTION" : "HOLI_CHAT_ORY_CLIENT_SECRET_DEVELOPMENT"
            }
          }
        }
        env {
          name = "HOLI_CHAT_REGISTRATION_SHARED_SECRET"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_REGISTRATION_SHARED_SECRET_PRODUCTION" : "HOLI_CHAT_REGISTRATION_SHARED_SECRET_DEVELOPMENT"
            }
          }
        }
        env {
          name = "HOLI_CHAT_MACAROON_SECRET_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_MACAROON_SECRET_KEY_PRODUCTION" : "HOLI_CHAT_MACAROON_SECRET_KEY_DEVELOPMENT"
            }
          }
        }
        env {
          name = "HOLI_CHAT_FORM_SECRET"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_FORM_SECRET_PRODUCTION" : "HOLI_CHAT_FORM_SECRET_DEVELOPMENT"
            }
          }
        }
        resources {
          limits = {
            # cpu can only be scaled down to 1000m as long as container_concurrency is set to != 1
            cpu    = local.environment == "production" ? "1000m" : "1000m"
            memory = local.environment == "production" ? "512Mi" : "256Mi"
          }
          requests = {
            cpu    = local.environment == "production" ? "1000m" : "10m"
            memory = local.environment == "production" ? "512Mi" : "256Mi"
          }
        }
      }
      container_concurrency = 0 # 0 means thread safe, no restriction on max concurrency
    }
    # template annotations: https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = local.environment == "production" ? "1" : "0"
        "autoscaling.knative.dev/maxScale" = local.environment == "production" ? "10" : "1"
        # Use the VPC Connector
        "run.googleapis.com/vpc-access-connector" = data.terraform_remote_state.holi_infra_state.outputs.vpc_access_connector_name
        # possible values: all-traffic/private-ranges-only(default) https://cloud.google.com/sdk/gcloud/reference/run/services/update#--vpc-egress
        "run.googleapis.com/vpc-access-egress" = "private-ranges-only"
      }
    }
  }

  # only accept traffic from the internal network, not from the internet
  metadata {
    annotations = {
      # possible values: all/internal/internal-and-cloud-load-balancing https://cloud.google.com/sdk/gcloud/reference/run/services/update#--ingress
      "run.googleapis.com/ingress" = "internal"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.service]
}

resource "google_cloud_run_domain_mapping" "holi_social_chat_server" {
  project = google_cloud_run_service.chat_server.project
  # location needs to be the same as the service's
  location = google_cloud_run_service.chat_server.location
  name     = local.dns_name

  metadata {
    namespace = google_cloud_run_service.chat_server.project
  }

  spec {
    route_name = google_cloud_run_service.chat_server.name
  }
}

# TODO security: Can we restrict this to a specific service account (of the API proxy) some day?
data "google_iam_policy" "chat_server" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "chat_server" {
  location = google_cloud_run_service.chat_server.location
  project  = google_cloud_run_service.chat_server.project
  service  = google_cloud_run_service.chat_server.name

  policy_data = data.google_iam_policy.chat_server.policy_data
}
