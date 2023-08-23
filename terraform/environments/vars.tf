locals {
  # predefined environment names are staging, production, and <branchname>
  environment      = terraform.workspace
  environment_name = trim(substr(local.environment, 0, 22), ".-") # limits the length of the name that it fits constraints google imposes for some resources, e.g. project ids

  # the dns name can be at most 64 chars in total
  # e.g. development-chat.holi.social and chat.holi.social
  dns_name = local.environment == "production" ? "chat.${data.terraform_remote_state.holi_infra_state.outputs.dns_sld_zone_domain}" : "development-chat.${data.terraform_remote_state.holi_infra_state.outputs.dns_sld_zone_domain}"
  # e.g. development-chat-push.holi.social and chat-push.holi.social
  chat_push_gateway_dns_name = local.environment == "production" ? "chat-push.${data.terraform_remote_state.holi_infra_state.outputs.dns_sld_zone_domain}" : "development-chat-push.${data.terraform_remote_state.holi_infra_state.outputs.dns_sld_zone_domain}"
}

# in CI, this is set via scripts/create-or-update-env.sh 
variable "image_tag" {
  type     = string
  nullable = false
}
