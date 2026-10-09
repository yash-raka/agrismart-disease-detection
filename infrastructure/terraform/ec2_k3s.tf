data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "tls_private_key" "k3s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k3s_keypair" {
  key_name   = "agrismart-k3s-key"
  public_key = tls_private_key.k3s_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.k3s_key.private_key_pem
  filename        = "${path.module}/agrismart-k3s-key.pem"
  file_permission = "0400"
}

resource "aws_security_group" "k3s_sg" {
  name        = "agrismart-k3s-sg"
  description = "Allow SSH, HTTP, and API traffic for k3s"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.k3s_keypair.key_name
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              # Install Docker
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              
              # Install k3s
              curl -sfL https://get.k3s.io | sh -
              
              # Make kubeconfig readable
              chmod 644 /etc/rancher/k3s/k3s.yaml
              EOF

  tags = {
    Name = "AgriSmart-K3s-Node"
  }
}

output "k3s_public_ip" {
  value = aws_instance.k3s_node.public_ip
}
