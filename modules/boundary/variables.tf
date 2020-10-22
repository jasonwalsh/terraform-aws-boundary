variable "auto_scaling_group_name" {
  description = "The name of the Auto Scaling group"
  type        = string
}

variable "boundary_release" {
  description = ""
  type        = string
}

variable "desired_capacity" {
  default = 0

  description = <<EOF
The desired capacity is the initial capacity of the Auto Scaling group
at the time of its creation and the capacity it attempts to maintain.
EOF

  type = number
}

variable "iam_instance_profile" {
  default = ""

  description = <<EOF
The name or the Amazon Resource Name (ARN) of the instance profile associated
with the IAM role for the instance
EOF
  type        = string
}

variable "image_id" {
  description = ""
  type        = string
}

variable "instance_type" {
  description = "Specifies the instance type of the EC2 instance"
  type        = string
}

variable "key_name" {
  default     = ""
  description = "The name of the key pair"
  type        = string
}

variable "max_size" {
  description = "The maximum size of the group"
  type        = number
}

variable "min_size" {
  description = "The minimum size of the group"
  type        = number
}

variable "runcmd" {
  default     = []
  description = ""
  type        = list(string)
}

variable "security_groups" {
  default = []

  description = <<EOF
A list that contains the security groups to assign to the instances in the Auto
Scaling group
EOF

  type = list(string)
}

variable "tags" {
  default = {}

  description = <<EOF
One or more tags. You can tag your Auto Scaling group and propagate the tags to
the Amazon EC2 instances it launches.
EOF

  type = map(string)
}

variable "target_group_arns" {
  default = []

  description = <<EOF
The Amazon Resource Names (ARN) of the target groups to associate with the Auto
Scaling group
EOF

  type = list(string)
}

variable "vpc_zone_identifier" {
  description = <<EOF
A comma-separated list of subnet IDs for your virtual private cloud
EOF

  type = list(string)
}

variable "write_files" {
  default     = []
  description = ""

  type = list(object({
    content     = string
    encoding    = string
    owner       = string
    path        = string
    permissions = string
  }))
}
