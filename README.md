# Terraform-aws-eks

# AWS Infrastructure Provisioning with Terraform

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [License](#license)

## Introduction
This module is basically combination of Terraform open source and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.
## Usage
To use this module, you can include it in your Terraform configuration. Here's an example of how to use it:

## Example

```hcl
module "eks" {
  source  = "git::https://github.com/opz0/terraform-aws-eks.git?ref=v1.0.0"
  enabled = true

  name        = local.name
  environment = local.environment

  # EKS
  kubernetes_version     = "1.27"
  endpoint_public_access = true
  # Networking
  vpc_id                            = module.vpc.id
  subnet_ids                        = module.subnets.private_subnet_id
  allowed_security_groups           = [module.ssh.security_group_id]
  eks_additional_security_group_ids = ["${module.ssh.security_group_id}", "${module.http_https.security_group_id}"]
  allowed_cidr_blocks               = [local.vpc_cidr_block]

  managed_node_group_defaults = {
    subnet_ids                          = module.subnets.private_subnet_id
    nodes_additional_security_group_ids = [module.ssh.security_group_id]
    tags = {
      "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
      "k8s.io/cluster/${module.eks.cluster_name}"        = "shared"
    }
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
          iops        = 3000
          throughput  = 150
          encrypted   = true
          kms_key_id  = module.kms.key_arn
        }
      }
    }
  }
  managed_node_group = {
    critical = {
      name           = "${module.eks.cluster_name}-critical-node"
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 2
      desired_size   = 2
      instance_types = ["t3.medium"]
    }

    application = {
      name                 = "${module.eks.cluster_name}-application"
      capacity_type        = "SPOT"
      min_size             = 1
      max_size             = 2
      desired_size         = 1
      force_update_version = true
      instance_types       = ["t3.medium"]
    }
  }

  apply_config_map_aws_auth = true
  map_additional_iam_users = [
    {
      userarn  = "arn:aws:iam::123456789:user/Opz0"
      username = "test"
      groups   = ["system:masters"]
    }
  ]
}
```

## Module Inputs
- `name`: A name for your application.
- `environment`: Name of the cluster.
- `vpc_id`: The VPC associated with your cluster.
For security group settings, you can configure the ingress and egress rules using variables like:

## Module Outputs
- `id` : The name of the cluster.
- `endpoint`: The endpoint for your Kubernetes API server.
- `vpc_id` : The VPC associated with your cluster.
- `cluster_security_group_id`: The cluster security group that was created by Amazon
- Other relevant security group outputs (modify as needed).

## Example
For detailed examples on how to use this module, please refer to the 'example' directory within this repository.

## Author
Your Name Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/opz0/terraform-aws-eks/blob/master/LICENSE) file for details.
