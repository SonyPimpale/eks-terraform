// EKS Cluster Role
resource "aws_iam_role" "eks-cluster" {
  name = "EKS-${var.environment}-Cluster-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

# EKS Cluster
resource "aws_eks_cluster" "eks-cluster" {
  name     = "EKS-${var.environment}-Cluster"
  role_arn = aws_iam_role.eks-cluster.arn
  version  = "1.21"

  vpc_config {
    # security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    subnet_ids              = flatten([aws_subnet.public-subnet[*].id, aws_subnet.private-subnet[*].id])
    # endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EKS-${var.environment}-Cluster"
}

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}



// EKS Managed Node Role
resource "aws_iam_role" "eks-node" {
  name = "EKS-${var.environment}-Node-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node.name
}

resource "aws_eks_node_group" "eks-node" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "EKS-${var.environment}-Node"
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = aws_subnet.private-subnet[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  ami_type       = var.ami_type # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type  = "ON_DEMAND"  # ON_DEMAND, SPOT
  disk_size      = 20
  instance_types = var.instance_types

  tags = {
    Name = "EKS-${var.environment}-Node"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}