## these dns changes are done in the infra shared project (https://gitlab.holi.team/app/holi-infra)
## because the zone apis.project-holi.org is managed in that project.

locals {
  # effectively, this is chat.host.project-holi.org
  chat_host_environments_zone_dns_name = "chat.host.${data.terraform_remote_state.holi_infra_state.outputs.dns_apis_zone_domain}."
}

# chat host environments zone
resource "google_dns_managed_zone" "chat_host_environments_zone" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name     = "chat-host-environments-zone"
  dns_name = local.chat_host_environments_zone_dns_name
}

resource "google_dns_record_set" "chat_host_environments_zone_entry" {
  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name    = local.chat_host_environments_zone_dns_name
  type    = "NS"
  ttl     = 300

  managed_zone = data.terraform_remote_state.holi_infra_state.outputs.dns_apis_zone_name

  rrdatas = google_dns_managed_zone.chat_host_environments_zone.name_servers
}

output "dns_chat_host_domain" {
  value = trim(google_dns_managed_zone.chat_host_environments_zone.dns_name, ".")
}

output "dns_chat_host_domain_name" {
  value = google_dns_managed_zone.chat_host_environments_zone.name
}
