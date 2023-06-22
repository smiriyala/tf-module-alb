# Session-46 - LoadBalancer
#STEP 1 - Create Load Balancer - DONE
resource "aws_lb" "main" {
  name               = "${var.name}-${var.env}"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnets
  security_groups = [aws_security_group.main.id]
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    var.tags,
    { Name = "${var.name}-${var.env}" }
  )
}

##Creating security group for ALB. Security Group requied once 
# you created TARGETGROUP and attached to PUBLIC LOAD BALANCER
# Currently linked to default SECGrp remove and attach this group.
resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-lb"
  description = "${var.name}-${var.env}-lb"
  vpc_id      = var.vpc_id

  #this port opening helps to connect with in APP Servers
  ingress {
    description      = "APP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}-${var.env}-lb" }
  )
}

#Session-46 - LoadBalancer
#Step2 : Create Listener with Fixed Response - DONE
# this being added to both private and public load balancer
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>503 - Invalid Request</h1>"
      status_code  = "200"
    }
  }
}