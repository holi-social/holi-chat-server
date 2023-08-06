resource "google_dns_record_set" "holi_social_chat_server_domain_record_set" {
  project      = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  managed_zone = data.terraform_remote_state.holi_chat_server_common_state.outputs.dns_chat_server_domain_name
  name         = "${google_cloud_run_domain_mapping.holi_social_chat_server.name}."
  type         = google_cloud_run_domain_mapping.holi_social_chat_server.status[0].resource_records[0].type
  ttl          = 300
  rrdatas      = [google_cloud_run_domain_mapping.holi_social_chat_server.status[0].resource_records[0].rrdata]
}

resource "google_dns_record_set" "holi_social_chat_push_gateway_domain_record_set" {
  project      = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  managed_zone = data.terraform_remote_state.holi_chat_server_common_state.outputs.dns_chat_server_domain
  name         = "${google_cloud_run_domain_mapping.holi_social_chat_push_gateway.name}."
  type         = google_cloud_run_domain_mapping.holi_social_chat_push_gateway.status[0].resource_records[0].type
  ttl          = 300
  rrdatas      = [google_cloud_run_domain_mapping.holi_social_chat_push_gateway.status[0].resource_records[0].rrdata]
}

output "api_domain" {
  value       = trimsuffix(google_dns_record_set.holi_social_chat_server_domain_record_set.name, ".")
  description = "Domain where the api resides"
}

output "chat_push_gateway_domain" {
  value       = trimsuffix(google_dns_record_set.holi_social_chat_server_domain_record_set.name, ".")
  description = "Domain where the api resides"
}
