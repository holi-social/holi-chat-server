locals {
  # effectively, this is chat.holi.social
  chat_server_environments_zone_dns_name = "chat.${data.terraform_remote_state.holi_infra_state.outputs.dns_sld_zone_domain}."
}

# chat environments zone
resource "google_dns_managed_zone" "chat_server_environments_zone" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name     = "chat-server-holi-social-environments-zone"
  dns_name = local.chat_server_environments_zone_dns_name
}

resource "google_dns_record_set" "chat_server_environments_zone_entry" {
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name    = local.chat_server_environments_zone_dns_name
  type    = "NS"
  ttl     = 300

  managed_zone = data.terraform_remote_state.holi_infra_state.outputs.dns_sld_zone_name

  rrdatas = google_dns_managed_zone.chat_server_environments_zone.name_servers
}

output "dns_chat_server_domain" {
  value = trim(google_dns_managed_zone.chat_server_environments_zone.dns_name, ".")
}

output "dns_chat_server_domain_name" {
  value = google_dns_managed_zone.chat_server_environments_zone.name
}
