##########################################
# EKS Cluster Role
##########################################
resource "aws_iam_role" "eks_cluster" {
  name = "${var.env}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

##########################################
# EKS Node Group Role
##########################################
resource "aws_iam_role" "eks_node" {
  name = "${var.env}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

##########################################
# EKS Cluster Security Group 
##########################################
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.env}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  # Egress rules (không phụ thuộc)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.env}-cluster-sg"
    },
    var.common_tags
  )
}

##########################################
# EKS Cluster
##########################################
resource "aws_eks_cluster" "main" {
  name     = var.env
  role_arn = aws_iam_role.eks_cluster.arn
  version  = local.kubernetes_version

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Enable EKS add-ons
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(
    {
      Name = "${var.env}"
    },
    var.common_tags,
  )
}

##########################################
# EKS Node Group - Standard Nodes
##########################################
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.env}-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = var.ami_type
  instance_types = var.instance_types
  capacity_type  = var.capacity_type
  disk_size      = var.disk_size

  scaling_config {
    desired_size = var.capacity
    min_size     = var.capacity
    max_size     = var.capacity
  }

  update_config {
    max_unavailable = 1
  }

  node_repair_config {
    enabled = true
  }

  labels = {
    role = "standard"
  }

  tags = merge(
    {
      Name = "${var.env}-node-group"
    },
    var.common_tags
  )

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

##########################################
# OpenID Connect (OIDC) Provider for EKS
##########################################
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}