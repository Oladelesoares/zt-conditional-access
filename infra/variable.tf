variable "tenant_name" {
  description = "Short label for the tenant: dev, test or prod"
  type        = string
}

variable "tenant_id" {
  description = "Entra tenant ID (GUID)"
  type        = string
}

variable "client_id" {
  description = "App ID the pipeline signs in as. Leave null locally."
  type        = string
  default     = null
}

variable "use_oidc" {
  description = "true in GitHub Actions, false on your Mac"
  type        = bool
  default     = false
}

variable "policy_state" {
  description = "enabledForReportingButNotEnforced (report-only), enabled, or disabled"
  type        = string
  default     = "enabledForReportingButNotEnforced"

  validation {
    condition     = contains(["enabledForReportingButNotEnforced", "enabled", "disabled"], var.policy_state)
    error_message = "policy_state must be enabledForReportingButNotEnforced, enabled or disabled."
  }
}

variable "breakglass_user_ids" {
  description = "Object IDs of emergency access accounts, excluded from every policy"
  type        = list(string)

  validation {
    condition     = length(var.breakglass_user_ids) >= 1
    error_message = "At least one break-glass account is required to prevent lockout."
  }
}

variable "enable_risk_policies" {
  description = "Deploy CA005 (sign-in risk). Needs Entra ID P2."
  type        = bool
  default     = false
}
