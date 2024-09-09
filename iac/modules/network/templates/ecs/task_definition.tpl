[
  {
    "name": "${app_name}",
    "image": "${app_image}",
    "cpu": ${app_cpu},
    "memory": ${app_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/aws/ecs/${app_department}/${app_project_name}-${app_name}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:${app_port}${app_health_check_path}"
        ],
        "interval": 5,
        "timeout": 3,
        "retries": 3,
        "startPeriod": ${app_start_delay}
    },
    "restartPolicy": {
      "enabled": true,
      "restartAttemptPeriod": ${app_restart_delay}
    }
    
  }
  
]