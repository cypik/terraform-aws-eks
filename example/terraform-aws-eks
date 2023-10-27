# AWS ECS Terraform Module

## Overview

This Terraform module allows you to create an Amazon Elastic Container Service (ECS) cluster and associated services. It provides a flexible and configurable way to manage your ECS infrastructure.

## Table of Contents

- [Prerequisites]
- [Usage]
- [Module Structure]
- [Input Variables]
- [Output Variables]
- [Example]
- [Contributing]
- [License]

## Prerequisites

Before using this module, make sure you have:

- [Terraform] installed.
- AWS credentials configured (e.g., AWS access key and secret key).

## Usage

1. Clone this repository or create your own Terraform project.

2. Define the necessary input variables as per your requirements. You can customize the ECS cluster, services, IAM roles, and more.

3. Initialize the working directory:

   ```sh
   terraform init
4. Review the execution plan:
   terraform plan
5. Apply the configuration to create the ECS cluster and services:
   terraform apply

Module Structure:

The Terraform module is organized into two primary components:

1.Cluster Configuration (modules/cluster): This section defines the AWS ECS cluster. 
You can configure settings such as the cluster name, CloudWatch log groups, capacity providers, and IAM roles related to task execution.

2.Service Configuration (modules/service): This section defines the services to run within the cluster. 
It includes settings for service specifics, launch type, load balancer, and more.


Input Variables:

This module accepts various input variables, allowing you to customize your ECS cluster and services. Here are some of the essential input variables:

1.cluster_name: The name of the ECS cluster.
2.services: A map of service configurations, allowing you to define multiple services within the cluster.
3.Additional input variables are documented within the module code.

Output Variables:
The module provides output variables to access information from the created resources. These output variables include:

cluster_arn: The ARN of the ECS cluster.
service_arns: A map of service ARNs.
