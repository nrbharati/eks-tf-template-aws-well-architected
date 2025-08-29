data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "private" {
  count = length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}

data "aws_subnet" "public" {
  count = length(var.public_subnet_ids)
  id    = var.public_subnet_ids[count.index]
}

# Tag private subnets for Karpenter discovery
resource "aws_ec2_tag" "karpenter_discovery" {
  count = length(var.private_subnet_ids)
  
  resource_id = var.private_subnet_ids[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}