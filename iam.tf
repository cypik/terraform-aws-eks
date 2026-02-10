
data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count = var.enabled ? 1 : 0

  name                 = module.labels.id
  assume_role_policy   = join("", data.aws_iam_policy_document.assume_role[*].json)
  permissions_boundary = var.permissions_boundary

  tags = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", join("", data.aws_partition.current[*].partition))
  role       = join("", aws_iam_role.default[*].name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSServicePolicy", join("", data.aws_partition.current[*].partition))
  role       = join("", aws_iam_role.default[*].name)
}

data "aws_iam_policy_document" "service_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInternetGateways",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSubnets",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "service_role" {
  count  = var.enabled ? 1 : 0
  role   = join("", aws_iam_role.default[*].name)
  policy = join("", data.aws_iam_policy_document.service_role[*].json)

  name = module.labels.id

}


#-------------------------------------------------------IAM FOR node Group----------------------------------------------

resource "aws_iam_role" "node_groups" {
  count              = var.enabled ? 1 : 0
  name               = "${module.labels.id}-node_group"
  assume_role_policy = join("", data.aws_iam_policy_document.node_group[*].json)
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.node_groups[*].name)
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if var.enabled }

  policy_arn = each.value
  role       = join("", aws_iam_role.node_groups[*].name)
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = join("", aws_iam_role.node_groups[*].name)
}

resource "aws_iam_policy" "amazon_eks_node_group_autoscaler_policy" {
  count  = var.enabled ? 1 : 0
  name   = format("%s-node-group-policy", module.labels.id)
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy[*].json)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_node_group_autoscaler_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_node_group_autoscaler_policy[*].arn)
  role       = join("", aws_iam_role.node_groups[*].name)
}

resource "aws_iam_policy" "amazon_eks_worker_node_autoscaler_policy" {
  count  = var.enabled ? 1 : 0
  name   = "${module.labels.id}-autoscaler"
  path   = "/"
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy[*].json)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_autoscaler_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_worker_node_autoscaler_policy[*].arn)
  role       = join("", aws_iam_role.node_groups[*].name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonEKSWorkerNodePolicy")
  role       = join("", aws_iam_role.node_groups[*].name)
}

data "aws_iam_policy_document" "node_group" {
  count = var.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Autoscaler policy for node group
data "aws_iam_policy_document" "amazon_eks_node_group_autoscaler_policy" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ecr:*",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:AttachVolume",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:ModifyVolume",
      "ec2:DetachVolume",
      "ec2:CreateTags",

    ]
    resources = ["*"]
  }
}

resource "aws_iam_instance_profile" "default" {
  count = var.enabled ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = join("", aws_iam_role.node_groups[*].name)
}




#  IAM role for CloudWatch logs for Fluent Bit
# -------------------------------------------
# Added for cloudwatch logging from EKS nodes

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  count = var.enabled && var.cloudwatch_observability_enabled ? 1 : 0

  name = "eks-fluentbit-cloudwatch-logs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "fluentbit_irsa_role" {
  count = var.enabled && var.oidc_provider_enabled && var.cloudwatch_observability_enabled ? 1 : 0

  name               = "eks-fluentbit-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.fluentbit_irsa_assume_role[0].json
  tags               = module.labels.tags
}

data "aws_iam_policy_document" "fluentbit_irsa_assume_role" {
  count = var.enabled && var.oidc_provider_enabled && var.cloudwatch_observability_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.default[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "fluentbit_logs_policy_attach" {
  count      = var.enabled && var.oidc_provider_enabled && var.cloudwatch_observability_enabled ? 1 : 0
  policy_arn = aws_iam_policy.cloudwatch_logs_policy[0].arn
  role       = aws_iam_role.fluentbit_irsa_role[0].name
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  count = var.enabled && var.oidc_provider_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.default[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_irsa_role" {
  count = var.enabled && var.oidc_provider_enabled ? 1 : 0

  name               = "${module.labels.id}-ebs-csi-irsa"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role[0].json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  count      = var.enabled && var.oidc_provider_enabled ? 1 : 0
  role       = aws_iam_role.ebs_csi_irsa_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy" "ebs_csi_extra" {
  count = var.enabled && var.oidc_provider_enabled ? 1 : 0

  role = aws_iam_role.ebs_csi_irsa_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
      }
    ]
  })
}