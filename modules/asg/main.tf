# 1. EC2 App Security Group (Zero Trust: Only accepts Port 5000 from ALB)
resource "aws_security_group" "app_sg" {
  name        = "EC2-App-Security-Group"
  description = "Allows incoming traffic strictly from the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Flask traffic from ALB"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-App-Security-Group"
  }
}

# 2. IAM Role for Systems Manager (SSM) - Secure shell access without public IPs
resource "aws_iam_role" "ssm_role" {
  name = "EC2-SSM-Instance-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2-SSM-Instance-Profile"
  role = aws_iam_role.ssm_role.name
}

# 3. Dynamic Amazon Linux 2023 AMI Lookup
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 4. Launch Template with systemd auto-start (Prevents ASG termination loop)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "de-project-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.ssm_profile.arn
  }

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install python3-pip git -y
              pip3 install mysql-connector-python flask pymysql

              cd /home/ec2-user
              git clone https://github.com/AyeMinKhant023/DE-Project-App.git
              chown -R ec2-user:ec2-user /home/ec2-user/DE-Project-App

              # Create a systemd service to start Flask automatically and keep it alive
              cat << 'SERVICE' > /etc/systemd/system/flask-app.service
              [Unit]
              Description=Flask Application
              After=network.target

              [Service]
              User=ec2-user
              WorkingDirectory=/home/ec2-user/DE-Project-App
              Environment="PYTHONUNBUFFERED=1"
              ExecStart=/usr/bin/python3 /home/ec2-user/DE-Project-App/app.py
              Restart=always
              RestartSec=5

              [Install]
              WantedBy=multi-user.target
              SERVICE

              systemctl daemon-reload
              systemctl enable flask-app.service
              systemctl start flask-app.service
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASG-Web-Worker"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 5. Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "de-project-asg-"
  min_size            = 2
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = var.private_app_subnet_ids
  target_group_arns   = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ASG-Worker-Node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
