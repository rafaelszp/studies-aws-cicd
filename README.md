# studies-aws-cicd


## TODO
1. Definir IAM para poder fazer deploy no ECR
2.  deploy da imagem no ECR
3. Criar novo projeto java + quarkus + codeartifact  + ecr + parallel actions

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd