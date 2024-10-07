# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2023-06-27
### :sparkles: New Features
- [`011d6c2`](https://github.com/clouddrove/terraform-azure-aks/commit/011d6c2e49efdd19b6605a02401c33810d252e6a) - auto changelog action added *(commit by [@themaheshyadav](https://github.com/themaheshyadav))*
- [`f6812cd`](https://github.com/clouddrove/terraform-azure-aks/commit/f6812cd4ec3001d5c0825f54f2771b29a0d01375) - added dependabot.yml file *(commit by [@themaheshyadav](https://github.com/themaheshyadav))*

### :bug: Bug Fixes
- [`e173fba`](https://github.com/clouddrove/terraform-azure-aks/commit/e173fbaaa9b4d707798e46db661f991903e7de04) - changed aks module source to local *(commit by [@nileshgadgi](https://github.com/nileshgadgi))*
- [`e8cc9b3`](https://github.com/clouddrove/terraform-azure-aks/commit/e8cc9b347dceb1b4305a4ddf1c58373ff56a7f37) - Updated loadbalancer diagnostic setting *(commit by [@13archit](https://github.com/13archit))*
- [`f65ecda`](https://github.com/clouddrove/terraform-azure-aks/commit/f65ecda5bd631f2cc214fbe108caf07ada91fd5a) - Ran terraform fmt *(commit by [@13archit](https://github.com/13archit))*

### :construction_worker: Build System
- [`331ef6d`](https://github.com/clouddrove/terraform-azure-aks/commit/331ef6d50cd7ef255f86dc136bdc746b79308e4b) - Add tfsec workflow *(commit by [@nileshgadgi](https://github.com/nileshgadgi))*
- [`e25428c`](https://github.com/clouddrove/terraform-azure-aks/commit/e25428ca3b572b2b4dc10f73177407e476e7bf48) - Add .deepsource.toml *(commit by [@deepsource-io[bot]](https://github.com/apps/deepsource-io))*


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

[1.0.2]: https://github.com/clouddrove/terraform-azure-aks/compare/1.0.1...1.0.2
