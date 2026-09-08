resource "aws_eks_access_entry" "devops_lab" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::003636668731:user/devops-lab"
}

resource "aws_eks_access_policy_association" "devops_lab_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.devops_lab.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}