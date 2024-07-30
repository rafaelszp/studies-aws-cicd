# studies-aws-cicd


## TODO

1. Tranformar repositorio nodejs em mirror para upstreams
2. testar build sem remover yarn.ock
3. adicionar novos upstreams
4. build de imagem docker
6.  deploy da imagem no ECR
7. Criar novo projeto java + quarkus + codeartifact  + ecr

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd