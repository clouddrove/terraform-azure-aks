# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2023-02-10
### :sparkles: New Features
- [`7e8197b`](https://github.com/clouddrove/terraform-azure-vnet-peering/commit/7e8197b09f507634f043afe97e8bf2379f9bb00d) - Added Terraform Azure Ec2 Module.
- [`2a696ee`](https://github.com/clouddrove/terraform-azure-aks/commit/2a696eecafb0128f784cc2bd4eadda6b49e07926) - Added diagnostic setting resource

### :bug: Bug Fixes
- [`3cf2657`](https://github.com/clouddrove/terraform-azure-aks/commit/3cf265763b07c510525bb9304c7cdea7c4b1a49e) - Removed enable_pod_security_policy variable
- [`94fd849`](https://github.com/clouddrove/terraform-azure-aks/commit/94fd849fcef761fbdb1d3fffd9f09180d69471e3) - Added count and tags in data of azurerm_resources
- [`32b3eb6`](https://github.com/clouddrove/terraform-azure-aks/commit/32b3eb600ac5e3c1bbaa312f3dcc6c831b3d5ebc) - Added msi_auth_for_monitoring_enabled variable
- [`793eb20`](https://github.com/clouddrove/terraform-azure-aks/commit/793eb206853d15fd7769a0e9444802f140a3edbf) - fix- sonar bug fixed and default variable moved from example


[1.0.1]: https://github.com/clouddrove/terraform-azure-aks/compare/1.0.1...master
