# Create ClusterRole for admin
resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "eks-admin"
    labels = {
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

# Create ClusterRole for view
resource "kubernetes_cluster_role" "view" {
  metadata {
    name = "eks-view"
    labels = {
      "rbac.authorization.k8s.io/aggregate-to-view" = "true"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "namespaces", "nodes", "pods", "services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create ClusterRole for edit
resource "kubernetes_cluster_role" "edit" {
  metadata {
    name = "eks-edit"
    labels = {
      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "namespaces", "nodes", "pods", "services"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
}

# Create ClusterRoleBinding for admin
resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "eks-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Create ClusterRoleBinding for view
resource "kubernetes_cluster_role_binding" "view" {
  metadata {
    name = "eks-view-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.view.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "system:authenticated"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Create ClusterRoleBinding for edit
resource "kubernetes_cluster_role_binding" "edit" {
  metadata {
    name = "eks-edit-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.edit.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "system:authenticated"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Create ServiceAccount for cluster admin
resource "kubernetes_service_account" "cluster_admin" {
  metadata {
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

# Create ClusterRoleBinding for cluster admin ServiceAccount
resource "kubernetes_cluster_role_binding" "cluster_admin_sa" {
  metadata {
    name = "eks-admin-sa-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_admin.metadata[0].name
    namespace = kubernetes_service_account.cluster_admin.metadata[0].namespace
  }
}

# IAM Access Entries for SSO Roles
resource "aws_eks_access_entry" "global_admin" {
  count         = var.sso_roles.global_admin != null ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = var.sso_roles.global_admin
  type          = "STANDARD"

  tags = var.tags
}

resource "aws_eks_access_entry" "administrator" {
  count         = var.sso_roles.administrator != null ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = var.sso_roles.administrator
  type          = "STANDARD"

  tags = var.tags
}

resource "aws_eks_access_entry" "developer" {
  count         = var.sso_roles.developer != null ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = var.sso_roles.developer
  type          = "STANDARD"

  tags = var.tags
}

resource "aws_eks_access_entry" "viewer" {
  count         = var.sso_roles.viewer != null ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = var.sso_roles.viewer
  type          = "STANDARD"

  tags = var.tags
}

# Associate Access Policies with Access Entries
resource "aws_eks_access_policy_association" "global_admin" {
  count        = var.sso_roles.global_admin != null ? 1 : 0
  cluster_name = var.cluster_name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.global_admin[0].principal_arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "administrator" {
  count        = var.sso_roles.administrator != null ? 1 : 0
  cluster_name = var.cluster_name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.administrator[0].principal_arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "developer" {
  count        = var.sso_roles.developer != null ? 1 : 0
  cluster_name = var.cluster_name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = aws_eks_access_entry.developer[0].principal_arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "viewer" {
  count        = var.sso_roles.viewer != null ? 1 : 0
  cluster_name = var.cluster_name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_eks_access_entry.viewer[0].principal_arn
  access_scope {
    type = "cluster"
  }
} 