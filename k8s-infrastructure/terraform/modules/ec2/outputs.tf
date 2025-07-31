output "control_plane_public_ips" {
  description = "Public IPs of control plane instances"
  value       = aws_instance.control_plane[*].public_ip
}

output "control_plane_private_ips" {
  description = "Private IPs of control plane instances"
  value       = aws_instance.control_plane[*].private_ip
}

output "worker_node_public_ips" {
  description = "Public IPs of worker node instances"
  value       = aws_instance.worker_node[*].public_ip
}

output "worker_node_private_ips" {
  description = "Private IPs of worker node instances"
  value       = aws_instance.worker_node[*].private_ip
}

output "control_plane_instance_ids" {
  description = "Instance IDs of control plane instances"
  value       = aws_instance.control_plane[*].id
}

output "worker_node_instance_ids" {
  description = "Instance IDs of worker node instances"
  value       = aws_instance.worker_node[*].id
} 