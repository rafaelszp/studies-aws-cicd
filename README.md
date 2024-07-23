# studies-aws-cicd


##

```
 Warning: The CodePipeline GitHub version 1 action provider is deprecated.
│ 
│   with aws_codepipeline.pipeline_vite_example,
│   on codepipeline.tf line 18, in resource "aws_codepipeline" "pipeline_vite_example":
│   18:       provider = "GitHub"
│ 
│ Use a GitHub version 2 action (with a CodeStar Connection `aws_codestarconnections_connection`) instead. See
│ https://docs.aws.amazon.com/codepipeline/latest/userguide/update-github-action-connections.html
```

## Destroying

```shell
aws s3 rm s3://$(terraform output -raw bucket_cicd_name) --recursive 
terraform destroy -auto-approve
```

## References
1. https://github.com/Abdel-Raouf/terraform-aws-codepipeline-ci-cd