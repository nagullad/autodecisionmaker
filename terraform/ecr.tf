# ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.default_tags, {
    Name = "${var.app_name}-ecr"
  })
}

# ECR Lifecycle Policy (keep last 5 images)
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["v"]
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app.name
}
