# studies-aws-cicd


## TODO

1. Fazer o buildspec de deploy (no forno)
2. Criar projeto no codebuild para deploy (no forno)
3. Associar projeto codebuild na pipeline
4. utilizar code artifact

5. build de imagem docker

6.  deploy da imagem no ECR

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd