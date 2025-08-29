output "aws_load_balancer_controller" {
  description = "The AWS Load Balancer Controller Helm release"
  value       = helm_release.aws_load_balancer_controller
} 