output "launch_template_id" {
  value       = try(aws_launch_template.this[0].id, "")
  description = "The ID of the launch template"
}

output "launch_template_arn" {
  value       = try(aws_launch_template.this[0].arn, "")
  description = "The ARN of the launch template"
}

output "launch_template_latest_version" {
  value       = try(aws_launch_template.this[0].latest_version, "")
  description = "The latest version of the launch template"
}

output "node_group_arn" {
  value       = try(aws_eks_node_group.this[0].arn, "")
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
}

output "node_group_id" {
  description = "EKS Cluster name and EKS Node Group name separated by a colon (`:`)"
  value       = try(aws_eks_node_group.this[0].id, "")
}

output "node_group_resources" {
  value       = try(aws_eks_node_group.this[0].resources, "")
  description = "List of objects containing information about underlying resources"
}

output "node_group_status" {
  value       = try(aws_eks_node_group.this[0].arn, "")
  description = "Status of the EKS Node Group"
}
