resource "aws_codecommit_repository" "test" {
  repository_name = "MyTestRepository"
  description     = "This is the Sample App Repository"
  kms_key_id      = aws_kms_key.test.arn
}

resource "aws_codecommit_trigger" "test" {
  repository_name = aws_codecommit_repository.test.repository_name

  trigger {
    name            = "all"
    events          = ["all"]
    destination_arn = aws_sns_topic.test.arn
  }
}

resource "aws_codecommit_approval_rule_template" "example" {
  name        = "MyExampleApprovalRuleTemplate"
  description = "This is an example approval rule template"

  content = jsonencode({
    Version               = "2018-11-08"
    DestinationReferences = ["refs/heads/master"]
    Statements = [{
      Type                    = "Approvers"
      NumberOfApprovalsNeeded = 2
      ApprovalPoolMembers     = ["arn:aws:sts::123456789012:assumed-role/CodeCommitReview/*"]
    }]
  })
}

resource "aws_codecommit_approval_rule_template_association" "example" {
  approval_rule_template_name = aws_codecommit_approval_rule_template.example.name
  repository_name             = aws_codecommit_repository.test.repository_name
}