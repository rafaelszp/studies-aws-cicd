# studies-aws-cicd


## TODO
1. Integrar o parameter na imagem ECR como exemplo
2. migrar state backend para remoto

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd
2. https://medium.com/@olayinkasamuel44/using-terraform-and-fargate-to-create-amazons-ecs-e3308c1b9166
2.1. https://github.com/Samuelking011/Fargate-ecs-terraform