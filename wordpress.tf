provider "aws" {
  region                  = "ap-south-1"
  profile                  = "EKS"
}


resource "aws_iam_role" "eks_cluster" {
  name = "ViRocluster"

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
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}


# cluster creation 
resource "aws_eks_cluster" "aws_eks" {
  name     = "ViRocluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = ["subnet-0d599dd199f636f92","subnet-0b2d7f33ad355e327","subnet-0c6e0383cef9452f6"]
  }

  tags = {
    Name = "myeks"
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks_ng_gp"

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
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "node1" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "ng-1"
  instance_types   =["t2.micro"]
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["subnet-0d599dd199f636f92", "subnet-0b2d7f33ad355e327","subnet-0c6e0383cef9452f6"]
  disk_size       = 40
  remote_access {
   ec2_ssh_key = "vishal-eks"
   source_security_group_ids = ["sg-043f6cd749693e8c1"]
  }
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
resource "aws_eks_node_group" "node2" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "ng-2"
  instance_types   =["t2.micro"]
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["subnet-0d599dd199f636f92", "subnet-0b2d7f33ad355e327","subnet-0c6e0383cef9452f6"]
  disk_size       = 40
  remote_access {
   ec2_ssh_key = "vishal-eks"
   source_security_group_ids = ["sg-043f6cd749693e8c1"]
  }
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
resource "aws_eks_node_group" "node3" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "ng-3"
  instance_types   =["t2.micro"]
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["subnet-0d599dd199f636f92", "subnet-0b2d7f33ad355e327","subnet-0c6e0383cef9452f6"]
  disk_size       = 40
  remote_access {
   ec2_ssh_key = "vishal-eks"
   source_security_group_ids = ["sg-043f6cd749693e8c1"]
  }
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_efs_file_system" "efs" {
  creation_token = "efs-token"

  tags = {
    Name = "EKS"
  }
}

resource "aws_efs_mount_target" "subnet1" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = "subnet-0d599dd199f636f92"
  security_groups = ["sg-043f6cd749693e8c1"]
}

resource "aws_efs_mount_target" "subnet2" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = "subnet-0b2d7f33ad355e327"
  security_groups = ["sg-043f6cd749693e8c1"]
}

resource "aws_efs_mount_target" "subnet3" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = "subnet-0c6e0383cef9452f6"
  security_groups = ["sg-043f6cd749693e8c1"]
}

resource "aws_efs_access_point" "efs_ap" {
  file_system_id = aws_efs_file_system.efs.id
}