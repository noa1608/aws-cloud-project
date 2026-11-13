resource "aws_eks_cluster" "main" {
  name     = "devops-lab-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.34"

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["80.230.255.114/32"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "devops-lab-eks"
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "devops-lab-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy
  ]

  tags = {
    Name = "devops-lab-node-group"
  }
}

