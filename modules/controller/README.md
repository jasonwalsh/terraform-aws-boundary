<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| boundary\_release | The version of Boundary to install | `string` | `"0.1.0"` | no |
| bucket\_name | The name of the bucket to upload the contents of the<br>cloud-init-output.log file | `string` | n/a | yes |
| desired\_capacity | The desired capacity is the initial capacity of the Auto Scaling group<br>at the time of its creation and the capacity it attempts to maintain. | `number` | `3` | no |
| image\_id | The ID of the Amazon Machine Image (AMI) that was assigned during registration | `string` | n/a | yes |
| instance\_type | Specifies the instance type of the EC2 instance | `string` | `"t3.small"` | no |
| key\_name | The name of the key pair | `string` | `""` | no |
| max\_size | The maximum size of the group | `number` | `3` | no |
| min\_size | The minimum size of the group | `number` | `3` | no |
| private\_subnets | List of private subnets | `list(string)` | n/a | yes |
| public\_subnets | List of public subnets | `list(string)` | n/a | yes |
| tags | One or more tags. You can tag your Auto Scaling group and propagate the tags to<br>the Amazon EC2 instances it launches. | `map(string)` | `{}` | no |
| vpc\_id | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_security\_group | The ID of the bastion security group |
| dns\_name | The public DNS name of the load balancer |
| ip\_addresses | One or more private IPv4 addresses associated with the controllers |
| kms\_key\_id | The unique identifier for the worker-auth key |
| security\_group\_id | The ID of the controller security group |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
