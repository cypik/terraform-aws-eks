module "labels" {
  source      = "cypik/labels/aws"
  version     = "1.0.1"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  attributes  = compact(concat(var.attributes, ["fargate"]))
  label_order = var.label_order
}

resource "aws_iam_role" "fargate_role" {
  count              = var.enabled && var.fargate_enabled ? 1 : 0
  name               = format("%s-fargate-role", module.labels.id)
  assume_role_policy = join("", data.aws_iam_policy_document.aws_eks_fargate_policy[*].json)
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_pod_execution_role_policy" {
  count      = var.enabled && var.fargate_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = join("", aws_iam_role.fargate_role[*].name)
}


resource "aws_eks_fargate_profile" "default" {
  for_each               = var.enabled && var.fargate_enabled ? var.fargate_profiles : {}
  cluster_name           = var.cluster_name
  fargate_profile_name   = format("%s-%s", module.labels.id, each.value.profile_name)
  pod_execution_role_arn = aws_iam_role.fargate_role[0].arn
  subnet_ids             = var.subnet_ids
  tags                   = module.labels.tags
  selector {
    namespace = lookup(each.value, "namespace", "default")
    labels    = lookup(each.value, "labels", null)
  }
}

data "aws_iam_policy_document" "aws_eks_fargate_policy" {
  count = var.enabled && var.fargate_enabled ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}
