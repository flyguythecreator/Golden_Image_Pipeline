########################################
###  Terraform Backend State Bucket
########################################
resource "aws_s3_bucket" "terraform_backend_state_management_bucket" {
  bucket = "terraform-backend-state-management-bucket"
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name        = "Terraform Backend State Bucket"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_s3_versioning" {
    bucket = aws_s3_bucket.terraform_backend_state_management_bucket.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_s3_object" "tfstate" {
  bucket = aws_s3_bucket.terraform_backend_state_management_bucket.bucket
  key    = "terraform.tfstate"
  source = "./terraform.tfstate"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("./assetZips/test.txt"))}"
  # etag = filemd5("${path.module}/assetZips/test.txt")
  etag = filemd5("./terraform.tfstate")
}
