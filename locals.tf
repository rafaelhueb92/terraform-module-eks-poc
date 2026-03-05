locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = merge(
    {
      ManagedBy   = "terraform"
      ClusterName = var.cluster_name
      Purpose     = "eks-poc"
    },
    var.tags
  )
}
