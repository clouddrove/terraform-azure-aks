##----------------------------------------------------------------------------- 
## Locals
##-----------------------------------------------------------------------------
locals {
  name = var.custom_name != null ? var.custom_name : module.labels.id
  user_aks_roles_flat = var.user_aks_roles != null ? flatten([
    for key, role in var.user_aks_roles : [
      for principal_id in role.principal_ids : {
        role_definition = role.role_definition
        principal_id    = principal_id
      }
    ]
  ]) : null
}