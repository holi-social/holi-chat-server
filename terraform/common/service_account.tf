resource "google_service_account" "holi_chat" {
  project      = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  account_id   = "cloudrun-service-chat-server"
  display_name = "Chat service account for Cloud Run"
}

resource "google_project_iam_member" "holi_chat" {
    for_each = toset([
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
  ])
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  member  = "serviceAccount:${google_service_account.holi_chat.email}"
  role    = each.key
}

output "cloud_run_service_account_email" {
  value = google_service_account.holi_chat.email
}
