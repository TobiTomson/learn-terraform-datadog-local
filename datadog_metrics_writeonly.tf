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
# Defines an alert for Kubernetes pod health of the "beacon" app.
###############################################################################
resource "datadog_monitor" "beacon" {
  # Human-readable name of the monitor
  name = "Kubernetes Pod Health"

  # Monitor type (metric alert: triggers on metric thresholds)
  type = "metric alert"

  # Message shown in the alert when triggered
  message = "Kubernetes Pods are not in an optimal health state. Notify: @operator"

  # Message shown when the issue escalates
  escalation_message = "Please investigate the Kubernetes Pods, @operator"

  # Datadog query:
  # Check the number of running containers with short_image:beacon over the last 1m.
  # Trigger alert if count <= 1.
  query = "max(last_1m):sum:kubernetes.containers.running{short_image:beacon} <= 1"

  # Thresholds for OK, warning, and critical states
  monitor_thresholds {
    ok       = 3  # OK if >= 3 pods running
    warning  = 2  # Warning if 2 pods running
    critical = 1  # Critical if 1 or fewer pods running
  }

  # Alert if no data is received
  notify_no_data = true

  # Tags to classify this monitor in Datadog
  tags = ["app:beacon", "env:demo"]
}
