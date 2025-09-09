###############################################################################
# Helm provider configuration (v3 syntax)
# - In Helm provider v3, `kubernetes` is an argument (map), not a nested block.
# - Points to your kubeconfig so Helm knows how to connect to the cluster.
###############################################################################
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config" # Path to kubeconfig file for cluster access
  }
}

###############################################################################
# Helm release resource for the Datadog Agent
# - Installs the official Datadog Helm chart into the cluster.
# - Configures both secret values (via ephemerals) and non-secret settings.
###############################################################################
resource "helm_release" "datadog_agent" {
  # Helm release name (will appear in Helm list)
  name       = "datadog-agent"

  # Helm repository and chart information
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  version    = "3.132.1"

  # Target namespace (assumes kubernetes_namespace.beacon is defined elsewhere)
  namespace  = kubernetes_namespace.beacon.id

  # Write-only values (new in Helm provider v3)
  # - Accepts ephemerals from Vault.
  # - Not stored in Terraform state (safer for secrets).
  set_wo = [
    {
      name  = "datadog.apiKey"
      value = ephemeral.vault_kv_secret_v2.dd_demo.data["APIKey"] # API key from Vault
    }
    # You can add more entries here, e.g. for datadog.appKey
  ]

  # Revision number to force redeployment when secrets rotate
  # - Increment this integer after API/App keys are rotated in Vault.
  set_wo_revision = 1

  # Regular (non-secret) values are passed here as a list of objects
  # - These *will* be persisted in state because they are non-sensitive.
  set = [
    { name = "datadog.site",                     value = var.datadog_site }, # Datadog site (e.g. datadoghq.eu)
    { name = "datadog.logs.enabled",             value = true },             # Enable logs collection
    { name = "datadog.logs.containerCollectAll", value = true },             # Collect all container logs
    { name = "datadog.leaderElection",           value = true },             # Leader election for cluster checks
    { name = "datadog.collectEvents",            value = true },             # Collect Kubernetes events
    { name = "clusterAgent.enabled",             value = true },             # Enable Datadog Cluster Agent
    { name = "clusterAgent.metricsProvider.enabled", value = true },         # Expose metrics for HPA/autoscaling
    { name = "networkMonitoring.enabled",        value = true },             # Enable network monitoring
    { name = "systemProbe.enableTCPQueueLength", value = true },             # Collect TCP queue length
    { name = "systemProbe.enableOOMKill",        value = true },             # Monitor OOM kill events
    { name = "securityAgent.runtime.enabled",    value = true },             # Enable runtime security agent
    { name = "datadog.hostVolumeMountPropagation", value = "HostToContainer" }, # Required volume propagation mode
    { name = "processAgent.enabled",                value = true },
    { name = "orchestratorExplorer.enabled",        value = true },
    { name = "kubeStateMetricsCore.enabled",     value = true },             # REQUIRED for Pod/Deployment health metrics
    { name = "datadog.kubernetesLabelsAsTags.app", value = "app" },
    { name = "datadog.kubernetesLabelsAsTags.env", value = "env" }

  ]
}
