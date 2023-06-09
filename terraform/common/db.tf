# Development database configuratrion

resource "google_sql_database" "holi_chat_db_development" {
  name      = "holi-chat-development"
  project   = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  instance  = data.terraform_remote_state.holi_infra_state.outputs.database_name_development
}

# Production database configuratrion

resource "google_sql_database" "holi_chat_db_production" {
  name     = "holi-chat-production"
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  instance = data.terraform_remote_state.holi_infra_state.outputs.database_name_production
}
