{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowUpdateServiceAndTaskDefinition0",
            "Effect": "Allow",
            "Action": [
                "ecs:UpdateService",
                "ecs:RegisterTaskDefinition"
            ],
            "Resource": "arn:aws:ecs:${region}:${account_id}:task-definition/*"
        },
        {
            "Sid": "AllowListTaskDefinition0",
            "Effect": "Allow",
            "Action": [
                "ecs:ListTaskDefinitions",
                "ecs:ListTaskDefinitionFamilies"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowAssignTaskExecutionRole0",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::${region}:role/ecsTaskExecutionRole"
            ]
        }
    ]
}