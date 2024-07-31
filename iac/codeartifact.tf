data "aws_kms_key" "codeartifact_kms_key" {
  key_id = "alias/aws/codeartifact"
}

resource "aws_codeartifact_domain" "nodejs_artifact_domain" {
  domain = "${var.department}-nodejs"
  tags = {
    TFName     = "nodejs_artifact_domain"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
}

resource "aws_codeartifact_repository" "node_artifact_repo" {
  domain = aws_codeartifact_domain.nodejs_artifact_domain.domain
  repository = "nodejs"
  upstream {
   repository_name = aws_codeartifact_repository.npm_store.repository
  }
  tags = {
    TFName     = "node_artifact_repo"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
}


resource "aws_codeartifact_repository" "npm_store" {
  domain = aws_codeartifact_domain.nodejs_artifact_domain.domain
  repository = "npm-store"
  external_connections {
    external_connection_name = "public:npmjs"
  }
  tags = {
    TFName     = "npm_store"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
}
