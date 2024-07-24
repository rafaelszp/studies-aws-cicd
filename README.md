# studies-aws-cicd


## TODO

1. s3 lifecycle
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration

2. utilizar as chaves de encriptação padrão do kms

3. utilizar code artifact

4. build de imagem docker

5.  deploy da imagem no ECR

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd