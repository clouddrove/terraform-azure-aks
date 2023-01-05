<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AZURE KUBERNETES SERVICE
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create Azure kubernetes service resource on AZURE.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v1.1.7-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-azure-aks'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AZURE+KUBERNETES+SERVICE&url=https://github.com/clouddrove/terraform-azure-aks'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AZURE+KUBERNETES+SERVICE&url=https://github.com/clouddrove/terraform-azure-aks'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 1.x.x](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-azure-aks/releases).


Here are some examples of how you can use this module in your inventory structure:
### azure aks
```hcl
  # Basic
  module "aks" {
source      = ""clouddrove/vnet/aks""
name                 = "app"
environment          = "test"
label_order          = ["name", "environment"]

resource_group_name = module.resource_group.resource_group_name
location            = module.resource_group.resource_group_location

#networking
service_cidr            = "10.0.0.0/16"
docker_bridge_cidr      = "172.17.0.1/16"
kubernetes_version      = "1.24.3"
vnet_id                 = join("", module.vnet.vnet_id)
nodes_subnet_id         = module.subnet.default_subnet_id[0]
private_cluster_enabled = true
enable_azure_policy     = false

#azurerm_disk_encryption_set = false   ## Default Encryption at-rest with a platform-managed key
#key_vault_id      = module.vault.id   

default_node_pool = {
max_pods              = 200
os_disk_size_gb       = 64
vm_size               = "Standard_B2s"
count                 = 1
enable_node_public_ip = false
}
}
  ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aks\_sku\_tier | aks sku tier. Possible values are Free ou Paid | `string` | `"Free"` | no |
| api\_server\_authorized\_ip\_ranges | Ip ranges allowed to interract with Kubernetes API. Default no restrictions | `list(string)` | `[]` | no |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| azurerm\_disk\_encryption\_set | The enable the Disk Encryption Set which should be used for the Nodes and Volumes. M | `bool` | `false` | no |
| default\_node\_pool | Default node pool configuration:<pre>map(object({<br>    name                  = string<br>    count                 = number<br>    vm_size               = string<br>    os_type               = string<br>    availability_zones    = list(number)<br>    enable_auto_scaling   = bool<br>    min_count             = number<br>    max_count             = number<br>    type                  = string<br>    node_taints           = list(string)<br>    vnet_subnet_id        = string<br>    max_pods              = number<br>    os_disk_type          = string<br>    os_disk_size_gb       = number<br>    enable_node_public_ip = bool<br>}))</pre> | `map(any)` | `{}` | no |
| delimiter | Delimiter to be used between `organization`, `environment`, `name` and `attributes`. | `string` | `"-"` | no |
| docker\_bridge\_cidr | IP address for docker with Network CIDR. | `string` | `"172.16.0.1/16"` | no |
| enable\_azure\_policy | Enable Azure Policy Addon. | `bool` | `false` | no |
| enable\_http\_application\_routing | Enable HTTP Application Routing Addon (forces recreation). | `bool` | `false` | no |
| enable\_ingress\_application\_gateway | Whether to deploy the Application Gateway ingress controller to this Kubernetes Cluster? | `bool` | `null` | no |
| enable\_kube\_dashboard | Enable Kubernetes Dashboard. | `bool` | `false` | no |
| enable\_pod\_security\_policy | Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| ingress\_application\_gateway\_id | The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster. | `string` | `null` | no |
| ingress\_application\_gateway\_name | The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. | `string` | `null` | no |
| ingress\_application\_gateway\_subnet\_cidr | The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. | `string` | `null` | no |
| ingress\_application\_gateway\_subnet\_id | The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. | `string` | `null` | no |
| key\_vault\_id | Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret | `string` | `""` | no |
| kubernetes\_version | Version of Kubernetes to deploy | `string` | `"1..24.3"` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| linux\_profile | Username and ssh key for accessing AKS Linux nodes with ssh. | <pre>object({<br>    username = string,<br>    ssh_key  = string<br>  })</pre> | `null` | no |
| location | Location where resource should be created. | `string` | `""` | no |
| log\_analytics\_workspace\_enabled | Enable log\_analytics\_workspace\_enabled(oms agent) Addon. | `bool` | `false` | no |
| log\_analytics\_workspace\_id | The ID of log analytics | `string` | `""` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| microsoft\_defender\_enabled | Enable microsoft\_defender\_enabled Addon. | `bool` | `false` | no |
| microsoft\_defender\_workspace\_id | The default ID of log analytics | `string` | `""` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_plugin | Network plugin to use for networking. | `string` | `"azure"` | no |
| network\_policy | (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created. | `string` | `null` | no |
| node\_resource\_group | Name of the resource group in which to put AKS nodes. If null default to MC\_<AKS RG Name> | `string` | `null` | no |
| nodes\_pools | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | `[]` | no |
| nodes\_subnet\_id | Id of the subnet used for nodes | `string` | n/a | yes |
| outbound\_type | The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`. | `string` | `"loadBalancer"` | no |
| private\_cluster\_enabled | Configure AKS as a Private Cluster : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled | `bool` | `false` | no |
| private\_dns\_zone\_id | Id of the private DNS Zone when <private\_dns\_zone\_type> is custom | `string` | `null` | no |
| private\_dns\_zone\_type | Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)<br>- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private\_dns\_zone\_id> variable<br>If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"<br>and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone<br>- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group<br>- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.<br>https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id | `string` | `"System"` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-azure-subnet.git"` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| role\_based\_access\_control | n/a | <pre>list(object({<br>    managed                = bool<br>    tenant_id              = string<br>    admin_group_object_ids = list(string)<br>    azure_rbac_enabled     = bool<br>  }))</pre> | `null` | no |
| service\_cidr | CIDR used by kubernetes services (kubectl get svc). | `string` | n/a | yes |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(any)` | `{}` | no |
| vnet\_id | Vnet id that Aks MSI should be network contributor in a private cluster | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| aks\_system\_identity\_principal\_id | Content aks system identity's object id |
| id | Specifies the resource id of the AKS cluster. |
| kube\_config\_raw | Contains the Kubernetes config to be used by kubectl and other compatible tools. |
| name | Specifies the name of the AKS cluster. |
| node\_resource\_group | Specifies the resource id of the auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-azure-aks/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-azure-aks)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
