# IAM Role EKS Cluster
resource "aws_iam_role" "eks_cluster_role_jrr" {
  name = "eks-cluster-role-jrr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role_jrr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS CLUSTER
resource "aws_eks_cluster" "eks_cluster_jrr" {
  name     = "eks-cluster-jrr"
  role_arn = aws_iam_role.eks_cluster_role_jrr.arn
  version  = "1.30"

  vpc_config {
    subnet_ids              = [aws_subnet.public_1_jrr.id, aws_subnet.public_2_jrr.id, aws_subnet.private_1_jrr.id, aws_subnet.private_2_jrr.id]
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["37.133.74.61/32"] # MY IP
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy
  ]
}

# EKS NODE GROUP
resource "aws_eks_node_group" "eks_node_group_jrr" {
  cluster_name    = aws_eks_cluster.eks_cluster_jrr.name
  node_group_name = "eks-node-group-jrr"
  node_role_arn   = aws_iam_role.eks_node_role_jrr.arn
  subnet_ids      = [aws_subnet.private_1_jrr.id, aws_subnet.private_2_jrr.id]
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKS_CNI_Policy
  ]
}


# IAM ROLE EKS NODES
resource "aws_iam_role" "eks_node_role_jrr" {
  name = "eks-node-role-jrr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role_jrr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role_jrr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role_jrr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
