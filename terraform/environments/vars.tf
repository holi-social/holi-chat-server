locals {
  # predefined environment names are staging, production, and <branchname>
  environment      = terraform.workspace
  environment_name = trim(substr(local.environment, 0, 22), ".-") # limits the length of the name that it fits constraints google imposes for some resources, e.g. project ids

  # the dns name can be at most 64 chars in total
  # e.g. staging.chat.holi.social and chat.holi.social
  dns_name = local.environment == "production" ? data.terraform_remote_state.holi_chat_server_common_state.outputs.dns_chat_server_domain : "${trimsuffix(substr(local.environment, 0, 34), ".-")}.${data.terraform_remote_state.holi_chat_server_common_state.outputs.dns_chat_server_domain}"
  # e.g. staging-push.chat.holi.social and production-push.chat.holi.social
  chat_push_gateway_dns_name = "${trimsuffix(substr(local.environment, 0, 29), ".-")}-push.${data.terraform_remote_state.holi_chat_server_common_state.outputs.dns_chat_server_domain}"
}
