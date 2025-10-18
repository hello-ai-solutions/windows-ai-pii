# Security Guidelines

## ⚠️ NEVER COMMIT THESE FILES:

- `terraform.tfstate*` - Contains AWS resource IDs
- `*.tfvars` - May contain secrets
- `.env*` - Environment variables with credentials
- `*.pem`, `*.key` - Private keys
- Compiled binaries that may embed credentials

## Before Every Commit:

1. Run `git status` to review files
2. Check for sensitive patterns: `grep -r "aws_access" .`
3. Use environment variables for credentials
4. Test with: `git diff --cached`

## Safe Practices:

- Use AWS profiles: `aws configure --profile myproject`
- Environment variables: `export AWS_PROFILE=myproject`
- Local config: Create `.env.local` (gitignored)
- Terraform: Use `terraform.tfvars.local` (gitignored)

## If You Accidentally Commit Secrets:

1. **STOP** - Don't push to remote
2. Remove from history: `git filter-branch`
3. Rotate all exposed credentials immediately
4. Force push: `git push --force`
