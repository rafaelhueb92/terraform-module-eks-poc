# 🚀 Terraform module for EKS POC

<div align="center">

[Terraform+EKS](./images/image.png)

</div>

Terraform module to quickly provision an EKS cluster for **proofs of concept**.

Includes: VPC, public/private subnets, single NAT Gateway, EKS cluster, and a managed node group.

**Defaults are tuned for lowest cost** (`t3.small`, 1 node, single NAT GW).

---

## ✨ Features

- 🌐 VPC with public + private subnets across 2 AZs
- 🔀 Single NAT Gateway (cheapest option)
- 🖥️ EKS managed node group on private subnets
- 🔑 **Whoever runs `terraform apply` automatically gets cluster admin access** (`bootstrap_cluster_creator_admin_permissions = true`)
- 👥 Optional: grant admin access to additional IAM users/roles via `additional_admin_arns`

---

## 📦 How to Use in Your Project

### 1. Add the module to your Terraform root

Create a `main.tf` (or any `.tf` file) in your project and reference this module:

```hcl
module "eks_poc" {
  source = "git::https://github.com/<your-org>/terraform-eks-poc.git?ref=main"

  cluster_name = "my-poc"
}

provider "aws" {
  region = "us-east-1"
}
```

### 2. Expose the kubectl output (optional but recommended)

```hcl
output "configure_kubectl" {
  value = module.eks_poc.configure_kubectl
}
```

### 3. Initialize and apply

```bash
terraform init
terraform apply
```

### 4. Connect to the cluster

After apply completes, run:

```bash
terraform output -raw configure_kubectl | bash
kubectl get nodes
```

### Pin to a specific tag

```hcl
source = "git::https://github.com/<your-org>/terraform-eks-poc.git?ref=v1.0.0"
```

### Full example with all options

```hcl
module "eks_poc" {
  source = "git::https://github.com/<your-org>/terraform-eks-poc.git?ref=main"

  cluster_name       = "my-poc"
  kubernetes_version = "1.31"
  vpc_cidr           = "10.0.0.0/16"

  node_instance_type = "t3.medium"
  node_desired_size  = 2
  node_min_size      = 1
  node_max_size      = 4
  node_disk_size     = 20

  additional_admin_arns = [
    "arn:aws:iam::123456789012:user/alice",
    "arn:aws:iam::123456789012:role/DevRole",
  ]

  tags = {
    Environment = "poc"
    Team        = "platform"
  }
}

provider "aws" {
  region = "us-east-1"
}

output "configure_kubectl" {
  value = module.eks_poc.configure_kubectl
}
```

---

## ⚙️ Inputs

| Name                    | Description                           | Type           | Default         |
| ----------------------- | ------------------------------------- | -------------- | --------------- |
| `cluster_name`          | EKS cluster name                      | `string`       | `"eks-poc"`     |
| `kubernetes_version`    | Kubernetes version                    | `string`       | `"1.31"`        |
| `vpc_cidr`              | VPC CIDR block                        | `string`       | `"10.0.0.0/16"` |
| `availability_zones`    | AZs to use (auto-detected if empty)   | `list(string)` | `[]`            |
| `node_instance_type`    | EC2 instance type for nodes           | `string`       | `"t3.small"`    |
| `node_desired_size`     | Desired node count                    | `number`       | `1`             |
| `node_min_size`         | Minimum node count                    | `number`       | `1`             |
| `node_max_size`         | Maximum node count                    | `number`       | `3`             |
| `node_disk_size`        | Node root disk size (GB)              | `number`       | `20`            |
| `additional_admin_arns` | Extra IAM ARNs to grant cluster admin | `list(string)` | `[]`            |
| `tags`                  | Extra tags for all resources          | `map(string)`  | `{}`            |

---

## 📤 Outputs

| Name                     | Description                         |
| ------------------------ | ----------------------------------- |
| `cluster_name`           | EKS cluster name                    |
| `cluster_endpoint`       | EKS API server endpoint             |
| `cluster_ca_certificate` | Cluster CA certificate (base64)     |
| `cluster_version`        | Kubernetes version                  |
| `vpc_id`                 | VPC ID                              |
| `public_subnet_ids`      | Public subnet IDs                   |
| `private_subnet_ids`     | Private subnet IDs                  |
| `node_role_arn`          | Node IAM role ARN                   |
| `configure_kubectl`      | `aws eks update-kubeconfig` command |
| `caller_identity_arn`    | ARN of the identity that ran apply  |

---

## 🔐 Admin Access

The IAM identity (user or role) that runs `terraform apply` is **automatically granted cluster admin access** via `bootstrap_cluster_creator_admin_permissions = true`.

To grant additional identities admin access:

```hcl
module "eks_poc" {
  source = "git::https://github.com/<your-org>/terraform-eks-poc.git?ref=main"

  additional_admin_arns = [
    "arn:aws:iam::123456789012:user/alice",
    "arn:aws:iam::123456789012:role/DevRole",
  ]
}
```

---

## 💰 Cost Considerations

| Component           | PoC default         | Notes                       |
| ------------------- | ------------------- | --------------------------- |
| EKS Control Plane   | ~$0.10/hr           | Fixed per cluster           |
| Node: `t3.small` x1 | ~$0.021/hr          | Cheapest viable for k8s     |
| NAT Gateway         | ~$0.045/hr + data   | Single GW shared across AZs |
| EIP                 | Free while attached | -                           |

> ⚠️ **Destroy when not in use** to avoid charges:
>
> ```bash
> terraform destroy
> ```

---

## 📋 Requirements

| Name         | Version  |
| ------------ | -------- |
| terraform    | >= 1.5.0 |
| aws provider | >= 5.0   |
