resource "azuread_group" "breakglass" {
  display_name     = "CA-Exclude-BreakGlass"
  description      = "Emergency access accounts excluded from every Conditional Access policy. Managed by Terraform."
  security_enabled = true
  members          = var.breakglass_user_ids
}
