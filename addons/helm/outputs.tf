output "helm_release" {
  description = "Map of attributes of the Helm release created without sensitive outputs"
  value       = try({ for k, v in helm_release.addon : k => v if k != "repository_password" }, {})
}

output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = try(helm_release.addon[0].metadata, null)
}