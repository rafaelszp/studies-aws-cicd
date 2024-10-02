# studies-aws-cicd


## Restrições

1. Estou utilizando a VPC existente padrão, além disto criei uma private sub com tag `Tier=private`
2. Preciso ter subnets e route tables com tag Tier = [private,public]
3. Ao criar ECS, o serviço está sendo associado a uma Task Definition padrão, isso é ruim pois ao fazer apply, os serviços em execução serão substituídos.

## TODO

- [] Verificar no learn.cantrill conceitos de ASG
  - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html
  - Ec2 docs: https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html
- [] Autoscaling groups
- [] ajustar o deploy do backend, com uso de parameter store
- [] fazer frontend comunicar com backend
- [] Usar ACM para SSL em vez de 80
- [] Utilizar service discovery para que a configuração seja dinâmica, em vez de parametrizada direto na aplicação
- [] executar tfsec para fazer validação e correção de segurança

## Done

- [x] Verificar possibilidade de criar ECS Service somente se não existir - consegui :D 
- [x] construir terraform do frontend com modulo devops
- [x] testar e corrigir erros do frontend+devops
- [x] VPC Endpoints e rotas da rede privada
- [x] correção das target ports do ALB
- [x] Correção da porta do nginx no container frontend, deve escutar na 3000
- [x] execução da infrastructure(network)
- [x] Verificar porque CW não está registrando log de execução das Tasks



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
7. https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html#ecr-setting-up-s3-gateway
8. https://github.com/Raketemensch/terraform-aws-fargate/blob/main/vpc_endpoints.tf
9. https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/AutoScaling/Types/StepAdjustment.html
10. https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html


## Scrap section

- [x] corrigir portas nginx
- [] corrigir portas ALB




Para mapear usuário vou precisar de setar na IAM:
- [x] write/update - taskDefinition
- [x] write/update - service

Também vou precisar de
- [x] task definition, talvez substituindo o valor da Imagem via sed, de modo dinamico
- [x]comando `aws ecs update-task-definition` baseado no register abaixo:
```shell
aws ecs register-task-definition --cli-input-json file://taskdefinition.json  --output text
```


#capturando ultima task definition
aws ecs list-task-definitions --family-prefix sample-fargate  --query 'taskDefinitionArns[-1]'
```
- [] comando de `aws ecs update-service` configurado. Ver https://docs.aws.amazon.com/cli/latest/reference/ecs/update-service.html com parâmetros `[--task-definition,--desired-count, --capacity-provider-strategy FARGATE_SPOT]
```
aws ecs update-service --desired-count 1 --capacity-provider-strategy FARGATE_SPOT --service <SERVICENAME> --task-definition <FAMILY>
```
