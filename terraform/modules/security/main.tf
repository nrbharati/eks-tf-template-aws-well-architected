# Security Module for EKS
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-sg"
    }
  )
}

resource "aws_security_group_rule" "cluster_egress" {
  security_group_id = aws_security_group.cluster.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-node-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "nodes_internal" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  description       = "Allow nodes to communicate with each other"
}

# Allow worker Kubelets and pods to receive communication from the cluster control plane
resource "aws_security_group_rule" "nodes_cluster_inbound" {
  security_group_id        = aws_security_group.nodes.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster.id
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
}

# Allow pods to communicate with the cluster API Server
resource "aws_security_group_rule" "cluster_nodes_inbound" {
  security_group_id        = aws_security_group.cluster.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.nodes.id
  description              = "Allow pods to communicate with the cluster API Server"
}

# Allow all outbound traffic from nodes
resource "aws_security_group_rule" "nodes_egress" {
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# Allow SSH access from specific CIDR blocks
resource "aws_security_group_rule" "nodes_additional_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [
    "10.60.0.0/16",
    "192.168.0.0/16", 
    "172.16.0.0/12",
    "10.57.96.26/32"
  ]
  description       = "allow ingress from specific CIDR blocks"
  security_group_id = aws_security_group.nodes.id
}

# CRITICAL: Allow EKS nodes to communicate with EKS control plane on port 443
resource "aws_security_group_rule" "nodes_eks_api" {
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow EKS nodes to communicate with EKS control plane"
}

# CRITICAL: Allow EKS nodes to communicate with EKS control plane on port 10250 (kubelet)
resource "aws_security_group_rule" "nodes_kubelet" {
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow EKS nodes kubelet communication"
}

# CRITICAL: Allow EKS nodes to communicate with EKS control plane on port 10255 (kubelet read)
resource "aws_security_group_rule" "nodes_kubelet_read" {
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  from_port         = 10255
  to_port           = 10255
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow EKS nodes kubelet read communication"
}

# CRITICAL: Allow EKS nodes to communicate with EKS control plane on port 30000-32767 (NodePort)
resource "aws_security_group_rule" "nodes_nodeport" {
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow EKS nodes NodePort communication"
}

# NFS Access Rules
# Allow NFS port 2049
resource "aws_security_group_rule" "nodes_nfs" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow NFS access (port 2049)"
}

# Allow NFS port 2049 (UDP)
resource "aws_security_group_rule" "nodes_nfs_udp" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow NFS access (port 2049 UDP)"
}

# Allow portmapper (port 111)
resource "aws_security_group_rule" "nodes_portmapper" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow portmapper access (port 111)"
}

# Allow portmapper (port 111 UDP)
resource "aws_security_group_rule" "nodes_portmapper_udp" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow portmapper access (port 111 UDP)"
}

# Allow dynamic NFS ports (32768-65535)
resource "aws_security_group_rule" "nodes_nfs_dynamic" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 32768
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow dynamic NFS ports (32768-65535)"
}

# Allow dynamic NFS ports (32768-65535 UDP)
resource "aws_security_group_rule" "nodes_nfs_dynamic_udp" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 32768
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow dynamic NFS ports (32768-65535 UDP)"
}

