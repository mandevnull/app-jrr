# S3 driver

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks_cluster_jrr.name
}

# IRSA
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url            = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]

  depends_on = [aws_eks_cluster.eks_cluster_jrr]
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy-jrr"
  description = "IAM policy for S3 access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "MountpointFullBucketAccess",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.app-s3-bucket-name}"
        ],
      },
      {
        Sid    = "MountpointFullObjectAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
        ],
        Resource = [
          "arn:aws:s3:::${var.app-s3-bucket-name}/*"
        ],
      },
    ],
  })
}

resource "aws_iam_role" "s3_role" {
  name = "s3-role-jrr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:s3-csi-*",
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com",
          },
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "s3_role_attachment" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.s3_role.name
}

# S3 ADDON EKS
resource "aws_eks_addon" "s3_csi" {
  cluster_name                = data.aws_eks_cluster.eks.id
  addon_name                  = "aws-mountpoint-s3-csi-driver"
  addon_version               = var.s3-addon-version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = aws_iam_role.s3_role.arn
}

# S3 BUCKET APP
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.app-s3-bucket-name

  tags = {
    Name = var.app-s3-bucket-name
  }
}
