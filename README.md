<div align="center">

# GitOps Workflow Lab

**Automated GitHub Actions, REST & GraphQL API orchestration for CI/CD pipelines, pull request lifecycle testing, and discussion automation.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?style=flat-square&logo=powershell&logoColor=white)](scripts/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=flat-square&logo=githubactions&logoColor=white)](.github/workflows/)
[![GraphQL](https://img.shields.io/badge/GitHub-GraphQL%20%26%20REST-E10098?style=flat-square&logo=graphql&logoColor=white)](scripts/discussion-qa-bot.ps1)

</div>

---

## Overview

`gitops-workflow-lab` is a lightweight automation sandbox for testing and benchmarking GitHub API workflows:

- **PR Lifecycle Runner (`scripts/pr-lifecycle-runner.ps1`)** — Rate-limit-resilient REST API runner for branch creation, atomic file updates, pull request opening, auto-merge, and branch cleanup with exponential backoff.
- **Co-Author Sync (`scripts/coauthor-sync.ps1`)** — Verifies `Co-authored-by` git trailers across automated pull requests and validates GraphQL `authors` attribution.
- **Discussion Q&A Bot (`scripts/discussion-qa-bot.ps1`)** — GraphQL orchestration for creating, answering, and resolving Q&A threads in GitHub Discussions.
- **GitHub Actions Workflows (`.github/workflows/`)** — Manual `workflow_dispatch` pipelines for CI/CD and repository automation checks.

---

## Repository Structure

```text
gitops-workflow-lab/
├── .github/
│   └── workflows/
│       ├── discussion-qa.yml       # GraphQL Q&A discussion workflow
│       └── pr-lifecycle.yml        # Automated PR lifecycle workflow
├── logs/
│   ├── coauthor-sync.md            # Co-authored commit verification log
│   ├── pr-runs.log                 # Historical PR runner checkpoints
│   └── runner-tick.txt             # Atomic state tick file for REST runner
├── scripts/
│   ├── coauthor-sync.ps1           # Co-author attribution PR runner
│   ├── discussion-qa-bot.ps1       # GraphQL Discussions Q&A automation
│   └── pr-lifecycle-runner.ps1     # REST API PR lifecycle runner
├── .gitignore
├── LICENSE
└── README.md
```

---

## Usage

### Prerequisites
- [GitHub CLI (`gh`)](https://cli.github.com/) authenticated (`gh auth status`)
- PowerShell 7+ (or Windows PowerShell 5.1+)

### 1. PR Lifecycle Runner
```powershell
./scripts/pr-lifecycle-runner.ps1 -Count 10 -DelayMs 1500
```

### 2. Co-Author Verification Runner
```powershell
./scripts/coauthor-sync.ps1 -Count 5
```

### 3. Discussion Q&A Automation
```powershell
$env:ALT_GH_TOKEN = "<secondary-pat>"
./scripts/discussion-qa-bot.ps1 -Count 4
Remove-Item Env:ALT_GH_TOKEN
```

---

<div align="center">
Maintained by <a href="https://github.com/ZXD44">ZXD44 (ZirconX)</a>
</div>
