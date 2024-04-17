/**
 * The resource ids of resources must be unique. Since we might create resources for a branch multiple times
 * (after destroying the ones created before maybe failed, e.g. on environment cleanup, reopening a branch), we ensure uniqueness
 * by appending some random data to resource ids in order to avoid collisions.
 */
resource "random_id" "chat-push-gateway" {
  byte_length = 2
  prefix      = "chat-push-gateway-${local.environment_name}-"
}

resource "google_cloud_run_service" "chat_push_gateway" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name     = random_id.chat-push-gateway.hex
  location = "europe-north1" # finland, low CO2 emissions
  # https://github.com/hashicorp/terraform-provider-google/issues/5898
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = data.terraform_remote_state.holi_chat_server_common_state.outputs.cloud_run_service_account_email
      volumes {
        name = "apns_keyfile"
        secret {
          secret_name = local.environment_name == "production" ? "APNS_KEYFILE_PRODUCTION" : "APNS_KEYFILE_STAGING"
          items {
            key  = "latest"
            path = "apns-keyfile.p8" # relative to mount_path in volume_mounts
          }
        }
      }
      containers {
        image = "${data.terraform_remote_state.holi_infra_state.outputs.artifact_registry_location}/holi-chat-push-gateway:${var.image_tag}"
        ports {
          container_port = 5000
        }
        volume_mounts {
          mount_path = "/apns"
          name       = "apns_keyfile"
        }
        # TODO consider adding resource limits
        env {
          name = "HOLI_CHAT_PUSH_GATEWAY_FCM_API_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "HOLI_CHAT_PUSH_GATEWAY_FCM_API_KEY_PRODUCTION" : "HOLI_CHAT_PUSH_GATEWAY_FCM_API_KEY_STAGING"
            }
          }
        }
        env {
          name  = "APNS_KEYFILE"
          value = "/apns/apns-keyfile.p8" # see volume_mounts and volumes
        }
        env {
          name = "APNS_KEY_ID"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "APNS_KEY_ID_PRODUCTION" : "APNS_KEY_ID_STAGING"
            }
          }
        }
        env {
          name = "APNS_TEAM_ID"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment_name == "production" ? "APNS_TEAM_ID_PRODUCTION" : "APNS_TEAM_ID_STAGING"
            }
          }
        }
        env {
          name = "APNS_TOPIC"
          value_from {
            secret_key_ref {
              key = "latest"
              # must be identical to app ID
              # could have a suffix based on the type of push notification
              # see https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns
              name = local.environment_name == "production" ? "APNS_TOPIC_PRODUCTION" : "APNS_TOPIC_STAGING"
            }
          }
        }
        liveness_probe {
          http_get {
            path = "/health"
          }
        }
      }
      container_concurrency = 0 # 0 means thread safe, no restriction on max concurrency
    }
    # template annotations: https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = local.environment == "production" ? "1" : "0"
        "autoscaling.knative.dev/maxScale" = local.environment == "production" ? "1" : "1"
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

resource "google_cloud_run_domain_mapping" "holi_social_chat_push_gateway" {
  project = google_cloud_run_service.chat_server.project
  # location needs to be the same as the service's
  location = google_cloud_run_service.chat_push_gateway.location
  name     = local.chat_push_gateway_dns_name

  metadata {
    namespace = google_cloud_run_service.chat_push_gateway.project
  }

  spec {
    route_name = google_cloud_run_service.chat_push_gateway.name
  }
}

data "google_iam_policy" "chat_push_gateway" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "chat_push_gateway" {
  location = google_cloud_run_service.chat_push_gateway.location
  project  = google_cloud_run_service.chat_push_gateway.project
  service  = google_cloud_run_service.chat_push_gateway.name

  policy_data = data.google_iam_policy.chat_push_gateway.policy_data
}
