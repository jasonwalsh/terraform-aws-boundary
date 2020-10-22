variable "boundary_release" {
  default     = "0.1.0"
  description = ""
  type        = string
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  description = ""
  type        = string
}

variable "controller_desired_capacity" {
  default     = 3
  description = ""
  type        = number
}

variable "controller_instance_type" {
  default     = "t3.small"
  description = ""
  type        = string
}

variable "controller_max_size" {
  default     = 3
  description = ""
  type        = number
}

variable "controller_min_size" {
  default     = 3
  description = ""
  type        = number
}

variable "subnets" {
  default     = []
  description = ""
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = ""
  type        = map(string)
}

variable "vpc_id" {
  default     = ""
  description = ""
  type        = string
}

variable "vpc_zone_identifier" {
  default     = []
  description = ""
  type        = list(string)
}

variable "worker_desired_capacity" {
  default     = 3
  description = ""
  type        = number
}

variable "worker_instance_type" {
  default     = "t3.small"
  description = ""
  type        = string
}

variable "worker_max_size" {
  default     = 3
  description = ""
  type        = number
}

variable "worker_min_size" {
  default     = 3
  description = ""
  type        = number
}
