<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| boundary\_release | The version of Boundary to install | `string` | `"0.1.0"` | no |
| cidr\_block | The IPv4 network range for the VPC, in CIDR notation. For example, 10.0.0.0/16. | `string` | `"10.0.0.0/16"` | no |
| controller\_desired\_capacity | The capacity the controller Auto Scaling group attempts to maintain | `number` | `3` | no |
| controller\_instance\_type | Specifies the instance type of the controller EC2 instance | `string` | `"t3.small"` | no |
| controller\_max\_size | The maximum size of the controller group | `number` | `3` | no |
| controller\_min\_size | The minimum size of the controller group | `number` | `3` | no |
| private\_subnets | List of private subnets | `list(string)` | `[]` | no |
| public\_subnets | List of public subnets | `list(string)` | `[]` | no |
| tags | One or more tags | `map(string)` | `{}` | no |
| vpc\_id | The ID of the VPC | `string` | `""` | no |
| worker\_desired\_capacity | The capacity the worker Auto Scaling group attempts to maintain | `number` | `3` | no |
| worker\_instance\_type | Specifies the instance type of the worker EC2 instance | `string` | `"t3.small"` | no |
| worker\_max\_size | The maximum size of the worker group | `number` | `3` | no |
| worker\_min\_size | The minimum size of the worker group | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| dns\_name | The public DNS name of the controller load balancer |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
