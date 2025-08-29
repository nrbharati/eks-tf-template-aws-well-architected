# Monitoring Module

This module sets up a comprehensive monitoring stack for the EKS cluster using Prometheus and Grafana.

## Overview

The monitoring module is responsible for:
- Deploying Prometheus for metrics collection
- Setting up Grafana for visualization
- Configuring AWS CloudWatch integration
- Setting up alerting and notifications
- Managing monitoring dashboards
- Configuring log aggregation

## Features

1. **Prometheus Stack**
   - Metrics collection
   - Service discovery
   - Alert management
   - Rule configuration

2. **Grafana Integration**
   - Dashboard management
   - Data source configuration
   - User management
   - Alert notifications

3. **CloudWatch Integration**
   - Container insights
   - Log aggregation
   - Metric collection
   - Alarm configuration

4. **Alerting System**
   - Alert rules
   - Notification channels
   - Alert routing
   - Alert management

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  cluster_name = "my-cluster"
  cluster_endpoint = "https://my-cluster.region.eks.amazonaws.com"
  cluster_certificate_authority = "base64-encoded-ca-cert"

  # Prometheus Configuration
  prometheus_config = {
    version = "45.7.1"
    retention = "15d"
    storage_class = "gp3"
  }

  # Grafana Configuration
  grafana_config = {
    version = "6.55.3"
    admin_password = "secure-password"
    ingress_enabled = true
    ingress_hostname = "grafana.example.com"
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| cluster_endpoint | Endpoint for the EKS cluster | `string` | n/a | yes |
| cluster_certificate_authority | Base64 encoded certificate authority data | `string` | n/a | yes |
| prometheus_config | Prometheus configuration | `map(any)` | `{}` | no |
| grafana_config | Grafana configuration | `map(any)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| prometheus_endpoint | Endpoint for Prometheus |
| grafana_endpoint | Endpoint for Grafana |
| alertmanager_endpoint | Endpoint for Alertmanager |

## Prometheus Configuration

Prometheus can be configured with the following options:

```hcl
prometheus_config = {
  version = "45.7.1"
  retention = "15d"
  storage_class = "gp3"
  resources = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "1000m"
      memory = "2Gi"
    }
  }
  alertmanager = {
    enabled = true
    config = {
      global = {
        resolve_timeout = "5m"
      }
      route = {
        group_by = ["alertname"]
        group_wait = "30s"
        group_interval = "5m"
        repeat_interval = "12h"
        receiver = "slack"
      }
    }
  }
}
```

## Grafana Configuration

Grafana can be configured with the following options:

```hcl
grafana_config = {
  version = "6.55.3"
  admin_password = "secure-password"
  ingress_enabled = true
  ingress_hostname = "grafana.example.com"
  persistence = {
    enabled = true
    storage_class = "gp3"
    size = "10Gi"
  }
  datasources = {
    prometheus = {
      url = "http://prometheus-server"
      type = "prometheus"
    }
    cloudwatch = {
      type = "cloudwatch"
      jsonData = {
        authType = "default"
        defaultRegion = "us-west-2"
      }
    }
  }
}
```

## Security Features

1. **Access Control**
   - Grafana authentication
   - Prometheus authentication
   - Role-based access

2. **Data Protection**
   - TLS encryption
   - Secret management
   - Data encryption

3. **Network Security**
   - Ingress configuration
   - Network policies
   - Service isolation

## Best Practices

1. **Resource Management**
   - Resource limits
   - Storage configuration
   - Backup strategy

2. **Alerting**
   - Alert thresholds
   - Notification channels
   - Alert routing

3. **Monitoring**
   - Dashboard organization
   - Metric collection
   - Log aggregation

## Maintenance

1. **Version Updates**
   - Prometheus updates
   - Grafana updates
   - Dashboard updates

2. **Resource Management**
   - Storage cleanup
   - Log rotation
   - Metric retention

3. **Backup and Recovery**
   - Configuration backup
   - Dashboard backup
   - Data recovery

## Troubleshooting

1. **Prometheus Issues**
   - Metric collection
   - Storage problems
   - Alert configuration

2. **Grafana Issues**
   - Dashboard access
   - Data source problems
   - User management

3. **Alerting Issues**
   - Alert delivery
   - Notification problems
   - Rule configuration 