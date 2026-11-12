resource "aws_ecr_repository" "orders" {
  name                 = "orders-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "orders-api"
  }
}

resource "aws_ecr_repository" "inventory" {
  name                 = "inventory-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "inventory-service"
  }
}
