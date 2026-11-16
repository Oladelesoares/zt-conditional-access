locals {
  excluded_groups = [azuread_group.breakglass.object_id]

  # Built-in role template IDs: identical in every tenant
  admin_roles = [
    "62e90394-69f5-4237-9190-012177145e10", # Global Administrator
    "e8611ab8-c189-46e8-94e1-60213ab1f814", # Privileged Role Administrator
    "194ae4cb-b126-40b2-bd5b-6091b380977d", # Security Administrator
    "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9", # Conditional Access Administrator
    "fe930be7-5e62-47db-91af-98c3a49a38b1", # User Administrator
    "29232cdf-9323-42fd-ade2-1d097af3e4de", # Exchange Administrator
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c", # SharePoint Administrator
    "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3", # Application Administrator
  ]

  # Windows Azure Service Management API: portal, CLI, PowerShell
  azure_management_app_id = "797f4846-ba00-4fd7-ba43-dac1f8f63013"
}

# CA001: Microsoft's "Block legacy authentication" policy, as code
resource "azuread_conditional_access_policy" "block_legacy_auth" {
  display_name = "CA001-AllUsers-AllApps-Block-LegacyAuth"
  state        = var.policy_state

  conditions {
    client_app_types = ["exchangeActiveSync", "other"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_users  = ["All"]
      excluded_groups = local.excluded_groups
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# CA002: privileged roles always need MFA
resource "azuread_conditional_access_policy" "mfa_admins" {
  display_name = "CA002-Admins-AllApps-Require-MFA"
  state        = var.policy_state

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_roles  = local.admin_roles
      excluded_groups = local.excluded_groups
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# CA003: every user, every app
resource "azuread_conditional_access_policy" "mfa_all_users" {
  display_name = "CA003-AllUsers-AllApps-Require-MFA"
  state        = var.policy_state

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_users  = ["All"]
      excluded_groups = local.excluded_groups
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# CA004: anything that can change Azure resources
resource "azuread_conditional_access_policy" "mfa_azure_management" {
  display_name = "CA004-AllUsers-AzureManagement-Require-MFA"
  state        = var.policy_state

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = [local.azure_management_app_id]
    }

    users {
      included_users  = ["All"]
      excluded_groups = local.excluded_groups
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# CA005 (optional, P2): step up when Entra ID Protection flags the sign-in
resource "azuread_conditional_access_policy" "mfa_risky_signins" {
  count        = var.enable_risk_policies ? 1 : 0
  display_name = "CA005-AllUsers-AllApps-MFA-MediumHighSignInRisk"
  state        = var.policy_state

  conditions {
    client_app_types    = ["all"]
    sign_in_risk_levels = ["medium", "high"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_users  = ["All"]
      excluded_groups = local.excluded_groups
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}
