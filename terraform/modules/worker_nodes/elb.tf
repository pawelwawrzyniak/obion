data "http" "worker_policy" {
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json"

    request_headers = {
      Accept = "application/json"
    }
}

#role for ec2 nodes to be able to manage ALB creation
resource "aws_iam_policy" "node_policy_alb" {
    name        = "eks_alb_node_policy"
    path        = "/"
    description = "role for workers to be able to manage ALB creation"

    policy = data.http.worker_policy.body
}
resource "aws_iam_role_policy_attachment" "tf-attach-eks-nodegroup-alb" {
    # role       = aws_iam_role_policy" "ec2_iam_role_policy.id
    role       = aws_iam_role.ec2_iam_role.id
    # role       = aws_iam_role.tf-role-eks-nodegroup-worker-role.id
    policy_arn = aws_iam_policy.node_policy_alb.arn
    depends_on = [aws_iam_policy.node_policy_alb]
}