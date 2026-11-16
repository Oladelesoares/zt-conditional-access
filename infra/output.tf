output "tenant" {
  value = var.tenant_name
}

output "policy_state" {
  value = var.policy_state
}

output "breakglass_group_id" {
  value = azuread_group.breakglass.object_id
}

output "policies" {
  value = concat(
    [
      azuread_conditional_access_policy.block_legacy_auth.display_name,
      azuread_conditional_access_policy.mfa_admins.display_name,
      azuread_conditional_access_policy.mfa_all_users.display_name,
      azuread_conditional_access_policy.mfa_azure_management.display_name,
    ],
    azuread_conditional_access_policy.mfa_risky_signins[*].display_name
  )
}
