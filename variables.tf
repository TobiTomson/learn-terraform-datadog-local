variable "application_name" {
  type        = string
  description = "Application Name"
  default     = "beacon"
}

variable "tfc_org" {
  type        = string
  default = "lennart-org"
  description = "TFC Organization"
}

variable "tfc_workspace" {
  type        = string
  description = "TFC Workspace"
  default     = "DD-Demo1"
}

variable "datadog_site" {
  type        = string
  description = "Datadog Site Parameter"
  default     = "datadoghq.com"
}

variable "datadog_api_url" {
  type        = string
  description = "Datadog API URL"
  default     = "https://api.datadoghq.com"

}