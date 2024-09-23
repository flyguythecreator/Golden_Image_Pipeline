# SSO Admin Resources
data "aws_ssoadmin_instances" "example" {}

resource "aws_ssoadmin_application" "example" {
  name                     = "example"
  application_provider_arn = "arn:aws:sso::aws:applicationProvider/custom"
  instance_arn             = tolist(data.aws_ssoadmin_instances.example.arns)[0]
}

resource "aws_ssoadmin_application_assignment_configuration" "example" {
  application_arn     = aws_ssoadmin_application.example.application_arn
  assignment_required = true
}

resource "aws_ssoadmin_permission_set" "example" {
  name         = "Example"
  instance_arn = tolist(data.aws_ssoadmin_instances.example.arns)[0]
}

data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "example" {
  inline_policy      = data.aws_iam_policy_document.example.json
  instance_arn       = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.example.arn
}

resource "aws_identitystore_group" "Admin" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  display_name      = "Admin"
  description       = "Admin Group"
}

resource "aws_ssoadmin_account_assignment" "account_assignment" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.example.arn

  principal_id   = aws_identitystore_group.example.group_id
  principal_type = "GROUP"

  target_id   = "123456789012"
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_managed_policy_attachment" "example" {
  # Adding an explicit dependency on the account assignment resource will
  # allow the managed attachment to be safely destroyed prior to the removal
  # of the account assignment.
  depends_on = [aws_ssoadmin_account_assignment.example]

  instance_arn       = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AlexaForBusinessDeviceSetup"
  permission_set_arn = aws_ssoadmin_permission_set.example.arn
}




#### SSO Identity Users
resource "aws_identitystore_user" "example" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]

  display_name = "John Doe"
  user_name    = "johndoe"

  name {
    given_name  = "John"
    family_name = "Doe"
  }

  emails {
    value = "john@example.com"
  }
}



resource "aws_identitystore_group" "this" {
  display_name      = "Example group"
  description       = "Example description"
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "example" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  group_id          = aws_identitystore_group.example.group_id
  member_id         = aws_identitystore_user.example.user_id
}