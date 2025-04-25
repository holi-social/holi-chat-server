/** Development **/
data "google_secret_manager_secret_version_access" "db_user_development" {
  secret  = "HOLI_CHAT_DB_USER_DEVELOPMENT"
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
}

data "google_secret_manager_secret_version_access" "db_password_development" {
  secret  = "HOLI_CHAT_DB_PASSWORD_DEVELOPMENT"
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
}

resource "google_sql_user" "development" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  instance = data.terraform_remote_state.holi_infra_state.outputs.database_name_development
  name     = data.google_secret_manager_secret_version_access.db_user_development.secret_data
  password = data.google_secret_manager_secret_version_access.db_password_development.secret_data
}

/** Production **/
data "google_secret_manager_secret_version_access" "db_user_production" {
  secret  = "HOLI_CHAT_DB_USER_PRODUCTION"
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
}

data "google_secret_manager_secret_version_access" "db_password_production" {
  secret  = "HOLI_CHAT_DB_PASSWORD_PRODUCTION"
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
}

resource "google_sql_user" "production" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  instance = data.terraform_remote_state.holi_infra_state.outputs.database_name_production
  name     = data.google_secret_manager_secret_version_access.db_user_production.secret_data
  password = data.google_secret_manager_secret_version_access.db_password_production.secret_data
}
