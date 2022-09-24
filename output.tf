output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "eks_node_group_resources" {
  value = aws_eks_node_group.eks-node.resources
}