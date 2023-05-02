resource "google_service_account" "chat_host" {
  project      = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  account_id   = "cloudrun-service-chat-host"
  display_name = "chat host service account for Cloud Run"
}

resource "google_project_iam_member" "secretmanager_accessor" {
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  member  = "serviceAccount:${google_service_account.chat_host.email}"
  role    = "roles/secretmanager.secretAccessor"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  member  = "serviceAccount:${google_service_account.chat_host.email}"
  role    = "roles/cloudsql.client"
}

output "cloud_run_service_account_email" {
  value = google_service_account.chat_host.email
}
