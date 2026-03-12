variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "name" {
  type        = string
  description = "Project name prefix"
  default     = "talos"
}

variable "role_name" {
  type        = string
  description = "IAM Role name for GitHub Actions"
  default     = "GitHubActionsServiceRole"
}

variable "github_org" {
  type        = string
  description = "GitHub Organization or Username"
}

variable "github_repo_pattern" {
  type        = string
  description = "GitHub repository pattern (e.g., 'talos-aws-landing-zone' or '*')"
  default     = "*"
}

variable "tags" {
  type    = map(string)
  default = {}
}
