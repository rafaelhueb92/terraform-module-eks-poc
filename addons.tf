data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false
}

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name]
      command     = "aws"
    }
  }
}

resource "aws_iam_openid_connect_provider" "eks" {
  count           = var.install_irsa ? 1 : 0
  url             = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd9e120"]
  tags            = local.common_tags
}

resource "helm_release" "argocd" {
  count            = var.install_argocd ? 1 : 0
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      server = {
        ingress = {
          enabled = false
        }
      }
    })
  ]

  depends_on = [aws_eks_cluster.main]
}

resource "helm_release" "karpenter" {
  count            = var.install_karpenter ? 1 : 0
  name             = "karpenter"
  repository       = "https://charts.karpenter.sh"
  chart            = "karpenter"
  namespace        = "karpenter"
  create_namespace = true

  values = [
    yamlencode({
      clusterName     = aws_eks_cluster.main.name
      clusterEndpoint = aws_eks_cluster.main.endpoint
    })
  ]

  depends_on = [aws_eks_cluster.main]
}
