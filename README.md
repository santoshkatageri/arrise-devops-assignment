# Arrise DevOps Assignment

Terraform work for the five assignment tasks. The task answers, design choices, and corrected policy example are in [NOTES.md](NOTES.md).

| Task | Where to look |
| --- | --- |
| 1. EC2 fleet | `task1-ec2-fleet/` |
| 2. Remote state and locking | `task2-remote-state-setup/` |
| 3. Cross-account IAM | `task3-multi-account/account-a/` and `account-b/` |
| 4. Policy for the `ci` user | [`ci-policy.json`](task3-multi-account/account-a/ci-policy.json) |
| 5. Trust and S3 policy fix | [NOTES.md](NOTES.md#task-5--fix-rolecs-trust-and-s3-permissions) |

Reusable Terraform modules are in `shared_modules/`.

## Validate the code

From the repository root, with Terraform 1.5 or newer and Python 3 installed:

```bash
terraform fmt -check -recursive
for dir in task1-ec2-fleet task2-remote-state-setup task3-multi-account/account-a task3-multi-account/account-b; do
  terraform -chdir="$dir" init -backend=false
  terraform -chdir="$dir" validate
done
python3 -m json.tool task3-multi-account/account-a/ci-policy.json >/dev/null
```

These checks do not create AWS resources. Terraform needs network access to download its provider. A live plan requires AWS credentials and the existing remote-state bucket.

## Review notes

- Task 1 includes the requested `io1`/`io2` settings in `terraform.tfvars.example`. The separate `terraform.free-tier.tfvars` uses lower-cost volumes and does not meet that part of the assignment.
- Account B uses the existing `testbucket-builder-santosh` bucket in `ap-southeast-2`; its Terraform creates the access role, not the bucket.
- Task 4 names ECR, ECS, and artifacts resources that have not been created. Its policy is ready to review but cannot be exercised against those resources yet.
