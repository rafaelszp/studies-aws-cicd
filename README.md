# studies-aws-cicd


## TODO
2. corrigir buildspec do deploy
2.1 acrescentar deploy pro ECR da imagem java que deve ser construída
3. Criar novo projeto java + quarkus + codeartifact  + ecr + parallel actions


## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd

