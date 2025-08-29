# Horizontal Pod Autoscaling (HPA)
resource "kubectl_manifest" "hpa_config" {
  yaml_body = <<-YAML
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: default-hpa
      namespace: default
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: default-deployment
      minReplicas: ${var.hpa_min_replicas}
      maxReplicas: ${var.hpa_max_replicas}
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: ${var.hpa_cpu_target_utilization}
      - type: Resource
        resource:
          name: memory
          target:
            type: Utilization
            averageUtilization: ${var.hpa_memory_target_utilization}
  YAML

  depends_on = [helm_release.metrics_server]
}

# Vertical Pod Autoscaler (VPA) via Helm
resource "helm_release" "vpa" {
  name             = "vpa"
  namespace        = "kube-system"
  create_namespace = false
  repository       = "https://charts.fairwinds.com/stable"
  chart            = "vpa"
  version          = var.vpa_helm_chart_version

  values = [
    yamlencode({
      recommender = {
        enabled = true
      }
      updater = {
        enabled = true
      }
      admissionController = {
        enabled = true
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.this
  ]
}

# VPA Config
resource "kubectl_manifest" "vpa_config" {
  yaml_body = <<-YAML
    apiVersion: autoscaling.k8s.io/v1
    kind: VerticalPodAutoscaler
    metadata:
      name: default-vpa
      namespace: default
    spec:
      targetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: default-deployment
      updatePolicy:
        updateMode: "Auto"
      resourcePolicy:
        containerPolicies:
        - containerName: '*'
          minAllowed:
            cpu: ${var.vpa_min_cpu}
            memory: ${var.vpa_min_memory}
          maxAllowed:
            cpu: ${var.vpa_max_cpu}
            memory: ${var.vpa_max_memory}
          controlledResources: ["cpu", "memory"]
  YAML

  depends_on = [helm_release.vpa]
}
