output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded certificate authority data for the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_oidc" {
  description = "Issuer for OIDC connections"
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer,"https://","")
}

output "eks_oidc_url" {
   value      = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = aws_eks_cluster.main.version
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "cluster_sg" {
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN of the IAM role attached to worker nodes"
  value       = aws_iam_role.node.arn
}

output "configure_kubectl" {
  description = "Run this command to configure kubectl for the cluster"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${aws_eks_cluster.main.name}"
}

output "caller_identity_arn" {
  description = "ARN of the IAM identity that ran terraform apply (has cluster admin access)"
  value       = data.aws_caller_identity.current.arn
}
