# studies-aws-cicd


## TODO

1. preparar usuario de shell para executar comandos de criação de ecs
  - IAM
  - script de criação
2. baseado em 1, criar o TF das políticas e acrescentar o script ao buildspec
10. migrar state backend para remoto


## Initializing project with remote backend
```shell
terraform init -backend-config=backend.conf
```

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd
2. https://medium.com/@olayinkasamuel44/using-terraform-and-fargate-to-create-amazons-ecs-e3308c1b9166
3. https://github.com/Samuelking011/Fargate-ecs-terraform
4. https://www.mycodingpains.com/step-by-step-ecs-fargate-setup-from-scratch-using-aws-cli/
5. https://stackoverflow.com/questions/46018883/best-practice-for-updating-aws-ecs-service-tasks
6. https://developer.hashicorp.com/terraform/language/functions/templatefile#generating-json-or-yaml-from-a-template


## Scrap section

Para mapear usuário vou precisar de setar na IAM:
- [] write/update - taskDefinition
- [] write/update - service

Também vou precisar de
- [x] task definition, talvez substituindo o valor da Imagem via sed, de modo dinamico
- []comando `aws ecs update-task-protection` baseado no register abaixo:
  ```shell
aws ecs register-task-definition \
--family yevi-test-java-appserver \
--cli-input-json file://yevi-test-java-app-taskdefinition.json \
--region us-east-1 \
--profile yevi-test \
--query taskDefinition.taskDefinitionArn \
--output text
arn:aws:ecs:us-east-1:xxxx:task-definition/yevi-test-java-appserver:1
```
- [] comando de `aws ecs update-service` configurado. Ver https://docs.aws.amazon.com/cli/latest/reference/ecs/update-service.html com parâmetros `[--task-definition,--desired-count, --capacity-provider-strategy FARGATE_SPOT]

