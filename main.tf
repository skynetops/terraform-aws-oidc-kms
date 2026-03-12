terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = var.tags }
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c5847440291a1829e7b2314352697841315668d"] # GitHub G2 & G3 CA thumbprints
}

resource "aws_iam_role" "github_actions" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_org}/${var.github_repo_pattern}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Add AdministratorAccess for bootstrap (since it manages state and core infra)
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# KMS Key for shared infrastructure
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.name} infrastructure"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = merge(var.tags, { Name = "${var.name}-kms-key" })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name}-infrastructure"
  target_key_id = aws_kms_key.main.key_id
}
