variable "enable_ha" {
  description = "Enable High Availability"
  type        = bool
}

variable "istio_autoscale_enabled" {
  description = "Enable or disable autoscaling for Istio components"
  type        = bool
  default     = true
}