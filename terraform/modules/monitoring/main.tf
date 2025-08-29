# monitoring/main.tf

resource "kubernetes_namespace" "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  count = var.enable_monitoring ? 1 : 0

  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring[0].metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_helm_chart_version

  create_namespace = true

  values = [yamlencode({
    grafana = {
      adminUser     = var.grafana_admin_user
      adminPassword = var.grafana_admin_password

      ingress = {
        enabled           = true
        ingressClassName  = var.grafana_ingress_class
        annotations = {
          "kubernetes.io/ingress.class"                 = var.grafana_ingress_class
          "alb.ingress.kubernetes.io/scheme"            = "internal"
          "alb.ingress.kubernetes.io/target-type"       = "ip"
          "alb.ingress.kubernetes.io/backend-protocol"  = "HTTP"
          "alb.ingress.kubernetes.io/group.name"        = var.alb_group_name != null ? var.alb_group_name : "eks-frontend-cluster-alb-group"
          "alb.ingress.kubernetes.io/subnets"           = var.alb_subnets != null ? var.alb_subnets : "subnet-XXXXXXXXX,subnet-XXXXXXXXX,subnet-XXXXXXXXX"
          "alb.ingress.kubernetes.io/healthcheck-path"  = "/api/health"
          "alb.ingress.kubernetes.io/healthcheck-port"  = "traffic-port"
          "alb.ingress.kubernetes.io/success-codes"     = "200"
          "alb.ingress.kubernetes.io/certificate-arn"   = var.alb_certificate_arn != null ? var.alb_certificate_arn : "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
          "alb.ingress.kubernetes.io/ssl-policy"        = "ELBSecurityPolicy-TLS-1-2-2017-01"
          "external-dns.alpha.kubernetes.io/hostname"   = var.grafana_hostname != null ? var.grafana_hostname : "grafana-${var.cluster_name}.${var.domain_name}"
        }
        hosts = [var.grafana_hostname != null ? var.grafana_hostname : "grafana-${var.cluster_name}.${var.domain_name}"]
        paths = [{
          path     = "/frontend"
          pathType = "Prefix"
        }]
      }

      service = {
        type = "ClusterIP"
        port = 443
        targetPort = 3000
      }

      containerPorts = {
        http = 3000
      }
    }
  })]
}


##fluentbit
resource "helm_release" "fluentbit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "monitoring"
  create_namespace = true
  version    = var.fluentbit_helm_chart_version

  values = [
    yamlencode({
      cloudWatch = {
        enabled = true
        region  = var.aws_region
        logGroupName = "/aws/eks/${var.cluster_name}/fluentbit"
        logStreamPrefix = "fluentbit-"
        logRetentionDays = 30
      }

      serviceAccount = {
        create = false
        name   = kubernetes_service_account.fluentbit.metadata[0].name
      }

      # Add node affinity to schedule on nodes with role=general
      nodeSelector = {
        "role" = "general"
      }

      # Add resource requests and limits
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }

      # Add tolerations for common node taints
      tolerations = [
        {
          key    = "CriticalAddonsOnly"
          operator = "Exists"
        },
        {
          key    = "node.kubernetes.io/not-ready"
          operator = "Exists"
          effect = "NoExecute"
          tolerationSeconds = 300
        },
        {
          key    = "node.kubernetes.io/unreachable"
          operator = "Exists"
          effect = "NoExecute"
          tolerationSeconds = 300
        }
      ]

      # Configure daemonset to run on all nodes
      daemonset = {
        enabled = true
      }

      # Add update strategy for smoother updates
      updateStrategy = {
        type = "RollingUpdate"
        rollingUpdate = {
          maxUnavailable = 1
        }
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.fluentbit_attach,
    kubernetes_service_account.fluentbit,
  ]
}

resource "aws_iam_role" "fluentbit" {
  name = "${var.cluster_name}-fluentbit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.openid_connect_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.openid_connect_provider_url, "https://", "")}:sub" = "system:serviceaccount:monitoring:fluentbit"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fluentbit_attach" {
  role       = aws_iam_role.fluentbit.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "kubernetes_service_account" "fluentbit" {
  metadata {
    name      = "fluentbit"
    namespace = "monitoring"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.fluentbit.arn
    }
  }
}

