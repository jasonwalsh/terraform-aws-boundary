variable "boundary_release" {
  default     = "0.1.0"
  description = ""
  type        = string
}

variable "desired_capacity" {
  default = 3

  description = <<EOF
The desired capacity is the initial capacity of the Auto Scaling group
at the time of its creation and the capacity it attempts to maintain.
EOF

  type = number
}

variable "iam_instance_profile" {
  default = ""

  description = <<EOF
The name or the Amazon Resource Name (ARN) of the instance profile
associated with the IAM role for the instance. The instance profile
contains the IAM role.
EOF

  type = string
}

variable "image_id" {
  description = <<EOF
The ID of the Amazon Machine Image (AMI) that was assigned during registration
EOF

  type = string
}

variable "instance_type" {
  default     = "t3.small"
  description = "Specifies the instance type of the EC2 instance"
  type        = string
}

variable "key_name" {
  default     = ""
  description = "The name of the key pair"
  type        = string
}

variable "max_size" {
  default     = 3
  description = "The maximum size of the group"
  type        = number
}

variable "min_size" {
  default     = 3
  description = "The minimum size of the group"
  type        = number
}

variable "subnets" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "tags" {
  default = {}

  description = <<EOF
One or more tags. You can tag your Auto Scaling group and propagate the tags to
the Amazon EC2 instances it launches.
EOF

  type = map(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_zone_identifier" {
  description = <<EOF
A comma-separated list of subnet IDs for your virtual private cloud
EOF

  type = list(string)
}
