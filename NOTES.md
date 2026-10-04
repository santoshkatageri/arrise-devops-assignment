# DevOps assignment notes

## Task 1 — EC2 instances with instance types and protected lifecycle ec2.

As per the assignment, instruction to create five instances from one `instances` map with distinct instance types, root sizes, and root volume types (`standard`, `gp2`, `gp3`, `io1`, `io2`). `arrise-dev-04` uses `io1` with 1,000 IOPS; `arrise-dev-05` uses `io2` with 100 IOPS.

I have a Free account trial AWS accounts,  I tried `io1` and `io2` but as they were not available and those volume types are not Free Tier eligible so I replaced them with `gp3`. This trial does not meet the assignment's distinct-volume requirement.

I chose `m7i-flex.large` for `arrise-dev-05` as a likely database host as per my assumption to choose io1 or io2: it is Free Tier eligible in `ap-south-1`, supports the x86-64 AMI, and has 2 vCPUs and 8 GiB of memory. Its `gp3` root volume specifies the included 3,000 IOPS baseline. `lifecycle { prevent_destroy = true }` protects this potentially important node from accidental Terraform deletion or replacement. I created new tfvars for free-tier i.e `terraform.free-tier.tfvars`

The module uses two generic EC2 resource blocks from the same input map because Terraform lifecycle settings require literal values; `protect_from_deletion` selects the protected node.

## Task 2 — Remote state and locking

The backend resources are created by Terraform in `task2-remote-state-setup` through separate S3 bucket and DynamoDB lock table modules in `shared_modules`. remote-state-setup keeps local state so it can create these resources first. Task 1's state was migrated to S3; the shared state and lock prevent separate checkouts from applying against independent local state copies.

With local state, two people working from separate copies of the repository each have their own state file. They can run terraform apply at the same time, potentially creating duplicate resources or leaving their state files inconsistent.

The S3 backend remote state with lock gives both people one shared state file. Terraform’s backend locking allows only one apply to change it at a time; the second apply waits or fails until the lock is released.

## Task 3 — Multi-account IAM and cross-account access

1. **Would I give `engine` and `ci` IAM users with access keys in production?** No. If the CI job runs on EC2, I would attach an IAM role through an EC2 instance profile. If it runs in an ECS container, I would give the ECS task its own IAM role. For GitHub Actions, I would let the workflow assume an AWS role using its GitHub identity; for AWS CodeBuild or CodePipeline, I would use a service role. These options give the job temporary credentials instead of a long-lived access key. For a person using the CLI in production, I would use IAM Identity Center. For this assignment, IAM user access keys work for CLI access; they are just less suitable for long-term production use.

2. **Why trust roleB's ARN rather than Account A root in roleC?** In a trust policy, `arn:aws:iam::329231175590:root` means Account A as a whole, not just its root user. An Account A administrator could grant another user or role permission to assume roleC directly. Trusting `arn:aws:iam::329231175590:role/roleB` means roleC accepts only roleB: `engine` must first assume roleB, then roleB can assume roleC and use its S3 permissions.


## Task 4 — CI least-privilege policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AuthenticateToEcrInCiregion",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "ap-south-1"
        }
      }
    },
    {
      "Sid": "PushOnlyCiImage",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "arn:aws:ecr:ap-south-1:329231175590:repository/arrise-ci-app"
    },
    {
      "Sid": "RegisterOnlyCiTaskFamily",
      "Effect": "Allow",
      "Action": "ecs:RegisterTaskDefinition",
      "Resource": "arn:aws:ecs:ap-south-1:329231175590:task-definition/arrise-ci-task:*"
    },
    {
      "Sid": "DeployOnlyCiTaskToCiService",
      "Effect": "Allow",
      "Action": "ecs:UpdateService",
      "Resource": "arn:aws:ecs:ap-south-1:329231175590:service/arrise-ci-cluster/arrise-ci-service",
      "Condition": {
        "ArnLike": {
          "ecs:task-definition": "arn:aws:ecs:ap-south-1:329231175590:task-definition/arrise-ci-task:*"
        }
      }
    },
    {
      "Sid": "PassOnlyCiTaskRolesToEcs",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "arn:aws:iam::329231175590:role/arrise-ci-task-execution-role",
        "arn:aws:iam::329231175590:role/arrise-ci-task-role"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "ecs-tasks.amazonaws.com"
        }
      }
    },
    {
      "Sid": "ListOnlyCiArtifactsBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::arrise-ci-build-artifacts-329231175590"
    },
    {
      "Sid": "ReadOnlyCiArtifacts",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::arrise-ci-build-artifacts-329231175590/*"
    }
  ]
}
```

- **Policy:** `task3-multi-account/account-a/ci-policy.json` is a custom inline policy that Terraform will attach only to `ci`.
- **ECR:** `ci` can push images only to `arrise-ci-app`. ECR login requires `Resource: "*"`, but the push actions are limited to that repository. [AWS ECR push permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-push-iam.html).
- **ECS:** `ci` can register revisions of `arrise-ci-task` and deploy them only to `arrise-ci-cluster/arrise-ci-service`. `ecs:UpdateService` can also change other settings of that one service; IAM cannot limit it to only changing the task definition. [AWS ECS authorization reference](https://docs.aws.amazon.com/service-authorization/latest/reference/list_ecs.html).
- **Task roles:** `ci` can pass only `arrise-ci-task-execution-role` and `arrise-ci-task-role` to ECS.
- **S3:** `ci` can list and read `arrise-ci-build-artifacts-329231175590`, but cannot write or delete its objects.
- **Left out:** No ECR repository creation/deletion or image deletion, ECS cluster/service creation/deletion or direct task execution, broad IAM access, unrestricted role passing, or access to other S3 buckets. The pipeline does not need these for the three requested jobs.
- **Other access:** The Task 4 Terraform plan removes `ci`'s inherited permission to assume roleB; `engine` keeps the Task 3 path.
- **Current status:** The named ECR, ECS, task-role, and artifacts-bucket resources do not exist yet. Update the names in the policy if the real resources use different names. A live deployment cannot run until they are created.

## Task 5 — Fix roleC's trust and S3 permissions

**Broken trust policy from the question:**

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Principal": {
      "AWS": "arn:aws:iam::000000000000:user/roleB"
    }
  }]
}
```

**Broken permissions policy from the question:**

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "s3:*",
    "Resource": "*"
  }]
}
```

**Answer:**

The trust policy names `arn:aws:iam::000000000000:user/roleB`. That is the wrong principal type: roleB is an IAM **role**, not a user. It also uses the assignment's placeholder account ID. STS cannot match the real roleB to that principal, so the assume-role request is denied. The corrected principal is `arn:aws:iam::329231175590:role/roleB`.

The permissions policy uses `Resource = "*"` with `s3:*`, which grants roleC S3 access to every bucket it can reach. This is a separate over-permission bug; it does not itself stop role assumption. Scope it to both the named bucket ARN (bucket operations) and its object ARN (object operations). The Account B configuration in `task3-multi-account/account-b/main.tf` implements these two fixes using `var.role_b_arn` and `var.bucket_name`. The equivalent corrected snippet is:

```hcl
data "aws_iam_policy_document" "roleC_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::329231175590:role/roleB"]
    }
  }
}

resource "aws_iam_role" "roleC" {
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
}

resource "aws_iam_role_policy" "roleC_s3" {
  name = "roleC-s3-access"
  role = aws_iam_role.roleC.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "s3:*"
      Resource = [
        "arn:aws:s3:::testbucket-builder-santosh",
        "arn:aws:s3:::testbucket-builder-santosh/*"
      ]
    }]
  })
}
```
