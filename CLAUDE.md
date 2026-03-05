# CLAUDE.md — EKS PoC Terraform Module

This is a Terraform module to provision an EKS cluster for proofs of concept.
Use this file to understand how to work with this project.

---

## Project Structure

```
terraform-eks-poc/
├── versions.tf       # Terraform + provider version constraints
├── variables.tf      # All inputs (cheapest defaults for PoC)
├── main.tf           # VPC, subnets, NAT GW, EKS cluster, node group, IAM roles
├── outputs.tf        # Cluster name, endpoint, kubectl command, etc.
└── README.md         # Usage and cost reference
```

---

## Prerequisites

Before running any Terraform commands, ensure:

- AWS CLI is configured: `aws sts get-caller-identity` should return your identity
- Terraform >= 1.5.0 is installed: `terraform version`
- kubectl is installed: `kubectl version --client`
- The AWS credentials in use have sufficient permissions (EKS, EC2, VPC, IAM)

---

## Workflow

### 1. Initialize

```bash
terraform init
```

### 2. Review the plan

```bash
terraform plan
```

Look for the expected resources:

- `aws_vpc.main`
- `aws_subnet.public` (x2)
- `aws_subnet.private` (x2)
- `aws_nat_gateway.main`
- `aws_eks_cluster.main`
- `aws_eks_node_group.main`
- IAM roles for cluster and nodes

### 3. Apply

```bash
terraform apply
```

Type `yes` when prompted. Provisioning takes **10–15 minutes** (EKS control plane is the bottleneck).

The IAM identity running `terraform apply` is **automatically granted cluster admin access** via
`bootstrap_cluster_creator_admin_permissions = true` — no extra steps needed.

### 4. Configure kubectl

After apply completes, run the command from the output:

```bash
terraform output -raw configure_kubectl | bash
```

Or manually:

```bash
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

Verify access:

```bash
kubectl get nodes
kubectl get pods -A
```

### 5. Destroy when done

```bash
terraform destroy
```

Always destroy PoC clusters when not in use to avoid charges (~$0.17/hr minimum).

---

## Common Tasks

### Change cluster name or region

```bash
terraform apply -var="cluster_name=my-cluster"
```

The AWS provider region is set outside this module (in the root provider block).

### Scale nodes

```bash
terraform apply -var="node_desired_size=2" -var="node_max_size=4"
```

### Grant admin access to another IAM identity

```bash
terraform apply -var='additional_admin_arns=["arn:aws:iam::123456789012:user/alice"]'
```

### Use a larger instance type

```bash
terraform apply -var="node_instance_type=t3.medium"
```

---

## Outputs Reference

| Output                      | How to get it                               |
| --------------------------- | ------------------------------------------- |
| kubectl config command      | `terraform output -raw configure_kubectl`   |
| Cluster endpoint            | `terraform output -raw cluster_endpoint`    |
| Cluster name                | `terraform output -raw cluster_name`        |
| VPC ID                      | `terraform output -raw vpc_id`              |
| Caller ARN (admin identity) | `terraform output -raw caller_identity_arn` |

---

## Troubleshooting

**Nodes not joining the cluster**

- Check node IAM role policies are attached: `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`
- Run: `kubectl describe nodes`

**kubectl returns Unauthorized**

- Confirm you're using the same AWS identity that ran `terraform apply`
- Re-run: `terraform output -raw configure_kubectl | bash`
- Check: `aws sts get-caller-identity`

**Terraform plan shows unexpected diff on re-run**

- Common with `availability_zones = []` — it resolves at apply time. Safe to ignore if AZs haven't changed.

**NAT Gateway charges accumulating**

- A single NAT GW costs ~$0.045/hr even with no traffic. Run `terraform destroy` when the cluster is not needed.

---

## Security Notes

- The EKS API is publicly accessible (`endpoint_public_access = true`) for PoC convenience.
  Set `endpoint_public_access = false` for production.
- Admin access uses EKS Access Entries (API mode), not the legacy `aws-auth` ConfigMap.
- Node groups run on **private subnets** — they are not directly reachable from the internet.

---

## Using This Module from GitHub

```hcl
module "eks_poc" {
  source = "git::https://github.com/rafaelhueb92/terraform-module-eks-poc.git?ref=main"

  cluster_name = "my-poc"
}

provider "aws" {
  region = "us-east-1"
}
```
