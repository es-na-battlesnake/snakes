# Dependabot Auto-Merge Setup

This repository is configured with automatic merging for Dependabot PRs that pass all required CI checks.

## How It Works

### 1. Dependabot Configuration (`.github/dependabot.yml`)
- Monitors `bundler`, `docker`, and `github-actions` dependencies
- Runs monthly dependency update checks
- Limited to 5 open PRs per ecosystem to avoid spam

### 2. Auto-Approve Workflow (`.github/workflows/dependabot-auto-approve.yml`)
- Automatically approves PRs created by `dependabot[bot]`
- Required for auto-merge to work since GitHub requires PR approval

### 3. Auto-Merge Workflow (`.github/workflows/dependabot-auto-merge.yml`)
- Monitors PR status changes and check completions
- Only processes PRs from `dependabot[bot]`
- Waits for critical CI checks to pass:
  - **Build checks**: Docker build and test (from `pr-build.yml`)
  - **Security scans**: Hadolint Docker linting, CodeQL analysis
  - **Overall status**: Must not be in failure state

### 4. Safety Features
- **Conservative approach**: Only merges when ALL critical checks pass
- **Security first**: CodeQL analysis must complete successfully
- **Squash merge**: Maintains clean commit history
- **Audit trail**: Adds comments to PRs explaining auto-merge actions
- **Failure handling**: Reports merge failures with details

## Triggering Events

The auto-merge workflow triggers on:
- `pull_request_target`: When PRs are opened/updated
- `check_suite`: When CI check suites complete
- `status`: When commit status changes

## Required Permissions

The workflows use these GitHub permissions:
- `contents: write` - To merge PRs
- `pull-requests: write` - To approve and comment on PRs
- `checks: read` - To read CI check status

## Manual Override

To prevent auto-merge of a specific dependabot PR:
1. Add the label `nocombine` to the PR, or
2. Convert to draft, or
3. Close and reopen the PR (resets approval)

## Monitoring

Check the Actions tab to monitor auto-merge activity:
- Look for "Dependabot Auto Merge" and "Dependabot Auto Approve" workflows
- Review PR comments for merge success/failure details
- Check workflow logs for detailed status check information

## Troubleshooting

### Auto-merge not working?
1. Verify the PR author is `dependabot[bot]`
2. Check that all required CI checks are passing
3. Ensure the PR is approved (auto-approve should handle this)
4. Review workflow logs for specific failure reasons

### Too many auto-merges?
- Adjust `open-pull-requests-limit` in `dependabot.yml`
- Consider changing update frequency from `monthly` to less frequent

### Security concerns?
- All PRs go through the same CI checks as manual PRs
- CodeQL security analysis is required to pass
- Only dependency updates are auto-merged, no code changes
- Squash merge preserves audit trail with commit messages