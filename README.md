## Contents

- [Usage](#usage)
- [Life cycle](#life-cycle)
- [Contributing](#contributing)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [License](#license)

**Note:** Like HashiCorp Boundary, this module is relatively new and may contain some issues. If you do experience an issue, please create a [new issue](https://github.com/jasonwalsh/terraform-aws-boundary/issues) in the repository. Pull requests are also welcome!

## Usage

This module uses Terraform to install [HashiCorp Boundary](https://www.boundaryproject.io/) in an Amazon Web Services (AWS) account.

This module uses the [official documentation](https://www.boundaryproject.io/docs/installing/high-availability) to install a highly available service.

![high-availability-service](https://www.boundaryproject.io/img/production.png)

This module creates the following resources:

- A virtual private cloud with all associated networking resources (e.g., public and private subnets, route tables, internet gateways, NAT gateways, etc)
- A PostgreSQL RDS instance used by the [Boundary controllers](https://www.boundaryproject.io/docs/installing/postgres)
- Two [AWS KMS](https://www.boundaryproject.io/docs/configuration/kms/awskms) keys, one for `root` and the other for `worker-auth`
- An application load balancer (ALB) that serves as a gateway to the Boundary UI/API
- Two auto scaling groups, one for controller instances and the other for worker instances

For more information on Boundary, please visit the [official documentation](https://www.boundaryproject.io/docs) or the [tutorials](https://learn.hashicorp.com/boundary) on HashiCorp Learn.

To use this module, the following environment variables are required:

| Name |
|------|
| `AWS_ACCESS_KEY_ID` |
| `AWS_SECRET_ACCESS_KEY` |
| `AWS_DEFAULT_REGION` |

After exporting the environment variables, simply run the following command:

```
$ terraform apply
```

## Life cycle

This module creates the controller instances *before* the worker instances. This implicit dependency ensures that the controller and worker instances share the same `worker-auth` KMS key.

The [controller](modules/controller) module also initializes the PostgreSQL database using the following command:

```
$ boundary database init -config /etc/boundary/configuration.hcl
```

After initializing the database, Boundary outputs information required to authenticate as defined [here](https://learn.hashicorp.com/tutorials/boundary/getting-started-dev?in=boundary/getting-started). Notably, the Auth Method ID, Login Name, and Password are generated.

Since initializing the database is a one-time operation, this module writes the output of the command to an S3 bucket so that the user always has access to this information.

In order to retrieve the information, you can invoke the following command:

```
$ $(terraform output s3command)
```

**Note:** The `$` before the `(` is required to run this command.

The result of running the command displays the contents of the [`cloud-init-output.log`](https://cloudinit.readthedocs.io/en/latest/topics/logging.html), which contains the output of the `boundary database init` command.

After you run this command, you can visit the Boundary UI using the `dns_name` output.

To authenticate to Boundary, you can reference [this](https://learn.hashicorp.com/tutorials/boundary/getting-started-connect?in=boundary/getting-started) guide.

**Note:** If you attempt to run the `authenticate` command and are met with this error `Error trying to perform authentication: dial tcp 127.0.0.1:9200: connect: connection refused`, you can export the `BOUNDARY_ADDR` environment variable to the value of the DNS name of the ALB. For example:

```
export BOUNDARY_ADDR="http://$(terraform output dns_name)"
```

## Contributing

As mentioned in the beginning of the README, this module is relatively new and may have issues. If you do discover an issue, please create a [new issue](https://github.com/jasonwalsh/terraform-aws-boundary/issues) or a [pull request](https://github.com/jasonwalsh/terraform-aws-boundary/pulls).

As always, thanks for using this module!

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

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
| s3command | The S3 cp command used to display the contents of the cloud-init-output.log |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

[MIT License](LICENSE)
