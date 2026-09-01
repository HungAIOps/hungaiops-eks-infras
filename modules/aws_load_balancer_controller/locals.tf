locals {
    aws_lb_controller_image_version = "1.30.3"
    aws_lb_controller_chart_version = "1.24.0"
    aws_lb_controller_iam_role_name = "${var.env}-load_balancer_controller"
    aws_lb_controller_sa_name = "aws-load_balancer_controller"
}