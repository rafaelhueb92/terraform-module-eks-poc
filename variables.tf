variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-poc"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones. Defaults to the first 2 available in the region."
  type        = list(string)
  default     = []
}

# Cheapest viable instance type for EKS worker nodes
variable "node_instance_type" {
  description = "EC2 instance type for worker nodes (t3.small is the cheapest viable option for PoC)"
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Root disk size in GB for worker nodes"
  type        = number
  default     = 20
}

variable "additional_admin_arns" {
  description = "Additional IAM user or role ARNs to grant EKS cluster admin access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
