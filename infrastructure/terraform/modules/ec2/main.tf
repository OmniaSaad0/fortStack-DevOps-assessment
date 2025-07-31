# Security Group
resource "aws_security_group" "todo_app" {
  name_prefix = "${var.environment}-todo-app-sg"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application port
  ingress {
    description = "Todo App"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-todo-app-sg"
  }
}


resource "aws_instance" "todo_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.todo_app.id]
  key_name               = var.key_name

  tags = {
    Name = "todo-app"
  }

}


# # EC2 Instance
# resource "aws_instance" "todo_app" {
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   key_name              = var.key_name
#   vpc_security_group_ids = [aws_security_group.todo_app.id]
#   subnet_id              = var.public_subnet_ids[0]

#   root_block_device {
#     volume_size = 30
#     volume_type = "gp3"
#     encrypted   = true

#     tags = {
#       Name        = "${var.environment}-todo-app-root"
#     }
#   }

 

#   tags = {
#     Name        = "${var.environment}-todo-app-instance"
#   }

# } 