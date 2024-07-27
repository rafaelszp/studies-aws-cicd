data "aws_kms_key" "codeartifact_kms_key" {
  key_id = "alias/aws/codeartifact"
}

resource "aws_codeartifact_domain" "nodejs_artifact_domain" {
  domain = "${var.prefix}-nodejs"
  encryption_key = data.aws_kms_key.s3_kms_key.arn
}

resource "aws_codeartifact_repository" "node_artifact_repo" {
  domain = aws_codeartifact_domain.nodejs_artifact_domain.domain
  repository = "nodejs"
}