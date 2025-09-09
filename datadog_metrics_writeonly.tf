###############################################################################
# Datadog provider configuration
# Uses ephemeral secrets from Vault (never persisted to state).
# - api_key and app_key come directly from Vault KV v2 secret "DD-Demo"
# - api_url can be set per Datadog site (e.g. https://api.datadoghq.eu)
###############################################################################
provider "datadog" {
  api_key = ephemeral.vault_kv_secret_v2.dd_demo.data["APIKey"] # Datadog API key from Vault
  app_key = ephemeral.vault_kv_secret_v2.dd_demo.data["APPKey"] # Datadog App key from Vault
  api_url = var.datadog_api_url                                 # API endpoint (site-specific)
}

###############################################################################
# Datadog monitor resource
# Chatty demo alert for Kubernetes deployment health of "beacon".
###############################################################################
resource "datadog_monitor" "beacon" {
  name               = "Kubernetes Deployment Health (Demo)"
  type               = "metric alert"
  message            = "beacon deployment below expected availability. @operator"
  escalation_message = "Please investigate the beacon deployment. @operator"

  # Fire if available replicas < 3 in the last 1 minute (chatty for demos)
  # NOTE: deployment metric tags are kube_namespace and kube_deployment by default.
  query = "min(last_1m):sum:kube_deployment.status_replicas_available{kube_namespace:beacon,kube_deployment:beacon} < 3"

  monitor_thresholds {
    critical = 3  # MUST match the number in the query comparator
  }

  require_full_window = false  # alert fast within the minute
  notify_no_data      = true
  no_data_timeframe   = 5       # minutes
  renotify_interval   = 10      # minutes

  # Monitor tags (metadata only; they don't filter the metric)
  tags = ["app:beacon", "env:demo"]
}
