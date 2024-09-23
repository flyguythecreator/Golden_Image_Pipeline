resource "aws_ssm_parameter" "secret" {
  name        = "/production/database/password/master"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.database_master_password

  tags = {
    environment = "production"
  }
}

resource "aws_ssm_association" "example" {
  name = "AmazonCloudWatch-ManageAgent"

  targets {
    key    = "tag:Environment"
    values = ["Development"]
  }
}


resource "aws_ssm_document" "example" {
  name          = "test_document"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "1.2",
    "description": "Check ip configuration of a Linux instance.",
    "parameters": {

    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": ["ifconfig"]
          }
        ]
      }
    }
  }
DOC
}

resource "aws_ssm_default_patch_baseline" "production" {
  baseline_id      = aws_ssm_patch_baseline.production.id
  operating_system = aws_ssm_patch_baseline.production.operating_system
}

resource "aws_ssm_patch_baseline" "production" {
  name             = "production-patch-baseline"
  approved_patches = ["KB123456"]
}

resource "aws_ssm_patch_group" "production_patch_group" {
  baseline_id = aws_ssm_patch_baseline.production.id
  patch_group = "production-patch-group-name"
}

resource "aws_ssm_default_patch_baseline" "development" {
  baseline_id      = aws_ssm_patch_baseline.development.id
  operating_system = aws_ssm_patch_baseline.development.operating_system
}

resource "aws_ssm_patch_baseline" "development" {
  name             = "development-patch-baseline"
  approved_patches = ["KB123456"]
}

resource "aws_ssm_patch_group" "development_patchg_roup" {
  baseline_id = aws_ssm_patch_baseline.development.id
  patch_group = "development-patch-group-name"
}