locals {
  name = "doc-pipeline-dev"

  tags = {
    Project = "doc-processing-pipeline"
    Environment = "dev"
    ManagedBy = "Terraform"
  }
}
