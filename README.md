# studies-aws-cicd


## TODO

- [] execução da infrastructure(network)
- [] construir terraform do frontend com modulo devops

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
- [x] write/update - taskDefinition
- [x] write/update - service

Também vou precisar de
- [x] task definition, talvez substituindo o valor da Imagem via sed, de modo dinamico
- []comando `aws ecs update-task-definition` baseado no register abaixo:
  ```shell
aws ecs register-task-definition --cli-input-json file://taskdefinition.json  --output text


#capturando ultima task definition
aws ecs list-task-definitions --family-prefix sample-fargate  --query 'taskDefinitionArns[-1]'
```
- [] comando de `aws ecs update-service` configurado. Ver https://docs.aws.amazon.com/cli/latest/reference/ecs/update-service.html com parâmetros `[--task-definition,--desired-count, --capacity-provider-strategy FARGATE_SPOT]
```
aws ecs update-service --desired-count 1 --capacity-provider-strategy FARGATE_SPOT --service <SERVICENAME> --task-definition <FAMILY>
```
