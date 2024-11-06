resource "google_monitoring_alert_policy" "chat_server_cpu_utilization" {
  count                 = local.environment == "production" ? 1 : 0
  display_name          = "COMO: Production chat server CPU utilization exceeded"
  notification_channels = [data.terraform_remote_state.holi_infra_monitoring_state.outputs.monitoring_notification_channel_rocket_chat_production_id]
  severity              = "WARNING"
  alert_strategy {
    auto_close = "86400s" # 1 day
  }
  combiner = "OR"
  conditions {
    display_name = "Chat Server Container CPU Utilization (${local.environment})"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration   = "0s"
      filter = templatefile("./monitoring_chat_server_cpu_utilization.tftpl", {
        environment_pattern = local.environment
      })
      threshold_value = 0.8

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MAX"
        group_by_fields = [
          "resource.label.service_name",
        ]
      }
      trigger {
        count   = 1
        percent = 0
      }

    }
  }
  documentation {
    content   = "Chat server CPU utilization exceeded"
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_alert_policy" "chat_server_memory_utilization" {
  count                 = local.environment == "production" ? 1 : 0
  display_name          = "COMO: ${local.environment} chat server memory utilization exceeded"
  notification_channels = [data.terraform_remote_state.holi_infra_monitoring_state.outputs.monitoring_notification_channel_rocket_chat_production_id]
  severity              = "WARNING"
  alert_strategy {
    auto_close = "86400s" # 1 day
  }
  combiner = "OR"
  conditions {
    display_name = "Chat Server Container memory Utilization (${local.environment})"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration   = "0s"
      filter = templatefile("./monitoring_chat_server_memory_utilization.tftpl", {
        environment_pattern = local.environment
      })
      threshold_value = 0.8

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MAX"
        group_by_fields = [
          "resource.label.service_name",
        ]
      }
      trigger {
        count   = 1
        percent = 0
      }

    }
  }
  documentation {
    content   = "Chat server memory utilization exceeded"
    mime_type = "text/markdown"
  }
}
