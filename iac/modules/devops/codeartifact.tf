locals {
  repository-name = "${aws_codeartifact_domain.artifact-domain.domain}-${aws_codeartifact_domain.artifact-domain.owner}.d.codeartifact.${data.aws_region.region.name}.amazonaws.com/${var.repository-type}/${aws_codeartifact_repository.artifact-repo.repository}"
}

data "aws_kms_key" "codeartifact-kms-key" {
  key_id = "alias/aws/codeartifact"
}

resource "aws_codeartifact_domain" "artifact-domain" {
  domain = "${local.name}-${var.repository-type}"
  tags = {
    TFName     = "${local.name}-${var.repository-type}"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
}

resource "aws_codeartifact_repository" "artifact-repo" {
  domain = aws_codeartifact_domain.artifact-domain.domain
  repository = "${var.repository-type}"

  upstream {
   repository_name = aws_codeartifact_repository.artifact-store.repository
  }

  tags = {
    TFName     = "node_artifact_repo"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
}

resource "aws_codeartifact_repository" "artifact-store" {
  domain = aws_codeartifact_domain.artifact-domain.domain
  repository = "${var.repository-type}-store"
  external_connections {
    external_connection_name = "${var.repository-external-connection-name}"
  }
  tags = {
    TFName     = "${var.repository-type}-store"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
}