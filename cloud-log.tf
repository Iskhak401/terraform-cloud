resource "aws_flow_log" "flow-role" {
  iam_role_arn    = aws_iam_role.flow-role.arn
  log_destination = aws_cloudwatch_log_group.vpc-logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.some_custom_vpc.id

  depends_on = [
    aws.iam_role.flow-role,
    aws_cloudwatch_log_group,vpc-logs,
    aws_vpc.some_custom_vpc
  ]
}


resource "aws_cloudwatch_log_group" "vpc-logs" {
  name = "vpc-logs"

  tags = {
    Environment = "dev"
  }
}


resource "aws_iam_role" "flow-role" {
  name = "example-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = [
            "logs.amazonaws.com",
            "vpc-flow-logs.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_policy" "my-policy" {
  name = "example-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_policy_attachment" {
  policy_arn = aws_iam_policy.my-policy.arn
  role       = aws_iam_role.flow-role.name
}
