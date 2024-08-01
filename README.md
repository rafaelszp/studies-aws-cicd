# studies-aws-cicd


## TODO

1. build de imagem docker do frontend
2.  deploy da imagem no ECR
3. Criar novo projeto java + quarkus + codeartifact  + ecr

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd