variable "boundary_release" {
  default     = "0.1.0"
  description = "The version of Boundary to install"
  type        = string
}

variable "bucket_name" {
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

variable "ip_addresses" {
  default     = []
  description = ""
  type        = list(string)
}

variable "key_name" {
  default     = ""
  description = "The name of the key pair"
  type        = string
}

variable "kms_key_id" {
  description = ""
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

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "security_group_id" {
  description = ""
  type        = string
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
