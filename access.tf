# ─────────────────────────────────────────────
# Extra admin access for additional IAM principals
# ─────────────────────────────────────────────

resource "aws_eks_access_entry" "additional_admins" {
  for_each = toset(var.additional_admin_arns)

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
  type          = "STANDARD"

  tags = local.common_tags
}

resource "aws_eks_access_policy_association" "additional_admins" {
  for_each = toset(var.additional_admin_arns)

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.additional_admins]
}
