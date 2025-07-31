output "control_plane_sg_id" {
  description = "ID of the control plane security group"
  value       = aws_security_group.control_plane.id
}

output "worker_node_sg_id" {
  description = "ID of the worker node security group"
  value       = aws_security_group.worker_node.id
} 