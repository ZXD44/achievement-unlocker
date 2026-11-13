<div align="center">

# 🏆 GitHub Achievement Unlocker

**Automated tools, workflows, and guides to earn and upgrade GitHub profile badges.**

[![GitHub license](https://img.shields.io/github/license/ZXD44/achievement-unlocker?style=flat-square)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/ZXD44/achievement-unlocker?style=flat-square)](https://github.com/ZXD44/achievement-unlocker/stargazers)
[![Pull Shark Workflow](https://img.shields.io/badge/Workflow-Pull%20Shark-blue?style=flat-square&logo=githubactions)](.github/workflows/pull-shark.yml)
[![Galaxy Brain Workflow](https://img.shields.io/badge/Workflow-Galaxy%20Brain-purple?style=flat-square&logo=githubactions)](.github/workflows/galaxy-brain.yml)

</div>

---

## 🎯 Badges Matrix

| Badge | Status | Target / Criteria | Tier Progression |
| :--- | :---: | :--- | :--- |
| **Pull Shark** | 🟢 Ready | Opened PR merged into target branch | 🥉 2 PRs · 🥈 16 PRs · 🥇 128 PRs |
| **Pair Extraordinaire** | 🟢 Complete | Co-authored commits in merged PR | Default |
| **Quickdraw** | 🟢 Complete | Closed an issue / PR within 5 mins | Default |
| **YOLO** | 🟢 Complete | Merged PR without code review | Default |
| **Galaxy Brain** | ⚡ Automated | Accepted answers on GitHub Discussions | 🥉 2 · 🥈 8 · 🥇 16 · 💎 32 Answers |
| **Public Sponsor** | 🟢 Complete | Sponsor an open source maintainer | Default |
| **Starstruck** | 🌟 Target | Reach 16+ stars on public repository | 🥉 16 · 🥈 128 · 🥇 512 · 💎 4096 Stars |

---

## 🚀 Quickstart & Workflows

### 1. 🦈 Pull Shark Multiplier
Run `.github/workflows/pull-shark.yml` directly from GitHub Actions:
- Go to **Actions** -> **Pull Shark Multiplier** -> **Run workflow**.
- Set input `prs_to_create` (e.g. `16` or `32`).
- The runner automatically spins feature branches, commits, opens PRs, and auto-merges them instantly.

### 2. 🧠 Galaxy Brain Discussion Automator
Run `.github/workflows/galaxy-brain.yml`:
1. Enable **Discussions** in repo `Settings -> General -> Features -> Discussions`.
2. Ensure the **Q&A** category exists.
3. Trigger the workflow under **Actions** tab with custom questions and answers.
4. The workflow creates the discussion topic, replies, and marks the answer automatically via GraphQL API.

### 3. ⭐ Starstruck
Help star this repository to achieve the **Starstruck** milestone! If you find this toolkit helpful, drop a star ⭐ at the top right of the page.

---

## 🛠 Local CLI Utility

Run local scripts in PowerShell or Bash:
```bash
# Example local co-author commit for Pair Extraordinaire
git commit -m "feat: achievement progression milestone

Co-authored-by: sahaphumx-lab <sahaphumx@gmail.com>"
```

---

<div align="center">
Maintained by <a href="https://github.com/ZXD44">ZXD44 (ZirconX)</a>
</div>
