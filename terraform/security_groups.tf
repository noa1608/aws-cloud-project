resource "aws_security_group" "alb" {
  name        = "devops-lab-alb-sg"
  description = "Security group for public ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "devops-lab-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP from the internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_orders" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.orders.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"

  description = "Allow ALB to reach Orders API"
}

resource "aws_security_group" "orders" {
  name        = "devops-lab-orders-sg"
  description = "Security group for Orders API"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "devops-lab-orders-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "orders_from_alb" {
  security_group_id = aws_security_group.orders.id

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"

  description = "Allow Orders API traffic from ALB"
}

resource "aws_security_group" "inventory" {
  name        = "devops-lab-inventory-sg"
  description = "Security group for Inventory Service"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "devops-lab-inventory-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inventory_from_orders" {
  security_group_id = aws_security_group.inventory.id

  referenced_security_group_id = aws_security_group.orders.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"

  description = "Allow Inventory traffic from Orders API"
}

