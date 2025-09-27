terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "pipeline_secret" {
  type        = map(any)
  default     = {}
  sensitive   = true
}

locals {
  pipeline_json = jsonencode(var.pipeline_secret)
}

resource "aws_secretsmanager_secret" "pipeline_secret" {
  name        = "pipeline_secret"
  description = "Secret for a test"
}

resource "aws_secretsmanager_secret_version" "pipeline_secretversion" {
  secret_id     = aws_secretsmanager_secret.pipeline_secret.id
  secret_string = local.pipeline_json
}
