# GITHUB TOKEN (only first time)
resource "aws_ssm_parameter" "github_token" {
  name        = "/app-jrr/github-token"
  description = "GitHub token for app-jrr"
  type        = "SecureString"
  value       = var.github-token
  key_id      = "arn:aws:kms:eu-west-1:<AWS_ID>:key/88ee8a8b-7b0d-4685-9406-7efdd42eb490"

  lifecycle {
    ignore_changes = [value]
  }
}

# CODEBUILD ROLE
resource "aws_iam_role" "codebuild_jrr" {
  name = "codebuild-jrr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "codebuild_jrr_policy" {
  name   = "codebuild-jrr-policy"
  policy = file("codebuild-policy.json")
}

resource "aws_iam_role_policy_attachment" "codebuild_jrr_attach" {
  role       = aws_iam_role.codebuild_jrr.name
  policy_arn = aws_iam_policy.codebuild_jrr_policy.arn
}

# CODEBUILD PROJECT
resource "aws_codebuild_project" "app_jrr" {
  name          = var.app-name
  description   = "Build project for ${var.app-name}"
  service_role  = aws_iam_role.codebuild_jrr.arn
  build_timeout = 10

  source {
    type      = "GITHUB"
    location  = var.github-repo
    buildspec = "buildspec.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.app-name}"
      stream_name = "${var.app-name}-stream"
      status      = "ENABLED"
    }
  }

  tags = {
    App = "app-jrr"
  }
}

