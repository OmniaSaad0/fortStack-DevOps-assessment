# Control Plane Instance
resource "aws_instance" "control_plane" {
  count         = var.control_plane_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_ids[0]

  vpc_security_group_ids = [var.control_plane_sg_id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname k8s-control-plane-${count.index + 1}
              echo "k8s-control-plane-${count.index + 1}" > /etc/hostname
              EOF

  tags = {
    Name        = "${var.environment}-control-plane-${count.index + 1}"
    Environment = var.environment
    Role        = "control-plane"
  }
}

# Worker Node Instances
resource "aws_instance" "worker_node" {
  count         = var.worker_node_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]

  vpc_security_group_ids = [var.worker_node_sg_id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname k8s-worker-${count.index + 1}
              echo "k8s-worker-${count.index + 1}" > /etc/hostname
              EOF

  tags = {
    Name        = "${var.environment}-worker-node-${count.index + 1}"
    Environment = var.environment
    Role        = "worker-node"
  }
} 