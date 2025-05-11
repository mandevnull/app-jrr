# ECR REPO
resource "aws_ecr_repository" "app_repo" {
  name                 = var.app-name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.app-name
  }
}

