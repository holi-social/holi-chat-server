resource "google_sql_database" "database_development" {
  name      = "holi-chat-development"
  project   = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  instance  = data.terraform_remote_state.holi_infra_state.outputs.database_name_development
  collation = "C"
  charset   = "C"
}
