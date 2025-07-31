variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "control_plane_sg_id" {
  description = "ID of the control plane security group"
  type        = string
}

variable "worker_node_sg_id" {
  description = "ID of the worker node security group"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
} 

variable "ami_id" {
  description = "AMI ID"
  type        = string
}