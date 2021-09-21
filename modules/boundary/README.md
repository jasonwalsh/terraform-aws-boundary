<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| after\_start | Run arbitrary commands after starting the Boundary service | `list(string)` | `[]` | no |
| auto\_scaling\_group\_name | The name of the Auto Scaling group | `string` | n/a | yes |
| before\_start | Run arbitrary commands before starting the Boundary service | `list(string)` | `[]` | no |
| boundary\_release | The version of Boundary to install | `string` | n/a | yes |
| bucket\_name | The name of the bucket to upload the contents of the<br>cloud-init-output.log file | `string` | n/a | yes |
| desired\_capacity | The desired capacity is the initial capacity of the Auto Scaling group<br>at the time of its creation and the capacity it attempts to maintain. | `number` | `0` | no |
| iam\_instance\_profile | The name or the Amazon Resource Name (ARN) of the instance profile associated<br>with the IAM role for the instance | `string` | `""` | no |
| image\_id | The ID of the Amazon Machine Image (AMI) that was assigned during registration | `string` | n/a | yes |
| instance\_type | Specifies the instance type of the EC2 instance | `string` | n/a | yes |
| key\_name | The name of the key pair | `string` | `""` | no |
| max\_size | The maximum size of the group | `number` | n/a | yes |
| min\_size | The minimum size of the group | `number` | n/a | yes |
| security\_groups | A list that contains the security groups to assign to the instances in the Auto<br>Scaling group | `list(string)` | `[]` | no |
| tags | One or more tags. You can tag your Auto Scaling group and propagate the tags to<br>the Amazon EC2 instances it launches. | `map(string)` | `{}` | no |
| target\_group\_arns | The Amazon Resource Names (ARN) of the target groups to associate with the Auto<br>Scaling group | `list(string)` | `[]` | no |
| vpc\_zone\_identifier | A comma-separated list of subnet IDs for your virtual private cloud | `list(string)` | n/a | yes |
| write\_files | Write out arbitrary content to files, optionally setting permissions | <pre>list(object({<br>    content     = string<br>    owner       = string<br>    path        = string<br>    permissions = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| auto\_scaling\_group\_name | The name of the controller Auto Scaling group |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
