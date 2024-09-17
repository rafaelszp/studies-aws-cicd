{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": ${ecr_arns}
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": ${ecs_log_group_arns}
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": ${ssm_secrets_arns}
        },
        {
            "Sid": "AccessToSpecificBucketOnly",
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": ["arn:aws:s3:::prod-${region}-starport-layer-bucket/*"]
        }
    ]
}