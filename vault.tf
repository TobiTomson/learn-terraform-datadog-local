###############################################################################
# Vault provider configuration
# - Connects Terraform to your HCP Vault Dedicated cluster.
# - Requires VAULT_TOKEN to be exported in your environment (not hardcoded here).
# - Namespace "admin" is the default namespace for HCP Vault.
###############################################################################
provider "vault" {
  # Public endpoint of your HCP Vault cluster
  address   = "https://vault-cluster-lennart-public-vault-1c34382a.ad4ca349.z1.hashicorp.cloud:8200"

  # HCP Vault requires namespace scoping
  namespace = "admin"
}

###############################################################################
# Ephemeral block: fetch Datadog keys from Vault KV v2
# - Uses Terraform 1.11+ ephemeral values (not stored in state).
# - mount = "kv" → the secrets engine name (top-level in Vault).
# - name  = "DD-Demo" → path relative to the mount.
# - Assumes this secret contains fields "APIKey" and "APPKey".
# - Example:
#     vault kv put kv/DD-Demo APIKey=12345 APPKey=abcdef
###############################################################################
ephemeral "vault_kv_secret_v2" "dd_demo" {
  mount = "kv"       # KV v2 engine name
  name  = "DD-Demo"  # Secret path relative to the mount
}
