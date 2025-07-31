output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "control_plane_public_ips" {
  description = "Public IPs of control plane instances"
  value       = module.ec2.control_plane_public_ips
}

output "control_plane_private_ips" {
  description = "Private IPs of control plane instances"
  value       = module.ec2.control_plane_private_ips
}

output "worker_node_public_ips" {
  description = "Public IPs of worker node instances"
  value       = module.ec2.worker_node_public_ips
}

output "worker_node_private_ips" {
  description = "Private IPs of worker node instances"
  value       = module.ec2.worker_node_private_ips
}

output "control_plane_sg_id" {
  description = "ID of the control plane security group"
  value       = module.security.control_plane_sg_id
}

output "worker_node_sg_id" {
  description = "ID of the worker node security group"
  value       = module.security.worker_node_sg_id
} 