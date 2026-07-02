---
name: github-copilot-kb
description: Knowledge base on GitHub Copilot - prompt engineering, MCP (basics, in Copilot, custom servers), agentic workflows, rules, plan vs agent mode, code reviews, issue flow, TDD, skills/subagents, VSCode hooks, context management, browser use, security/compliance/ethics, prompt injection attacks, DevOps, Terraform on Azure, Windows PowerShell, n8n automation. Use whenever user asks about GitHub Copilot features, configuration, best practices, or references letsboot agent-lab workshop material.
---

# GitHub Copilot Knowledge Base

Sourced from letsboot agent-lab workshop.

**Base path:** `/mnt/c/users/aeidl/git/personal/letsboot_agent-lab/`

Each topic is a subdirectory containing a `README.md` (main content) and often a `solution/` dir + `solution.sh` script.

## Index

| Topic | Subdir |
|---|---|
| Intro | `0000-intro/` |
| Agenda | `0100-agenda/` |
| Setup | `0200-setup/` |
| Quick start | `0210-quick_start/` |
| Hello Copilot | `1110-hello_copilot/` |
| Agentic idea | `1210-agentic_idea/` |
| Tooling choice | `1310-tooling_choice/` |
| Plan vs agent mode | `1410-plan_vs_agent/` |
| Rules | `1420-rules/` |
| MCP basics | `1430-mcp_basics/` |
| MCP in Copilot | `1435-mcp_in_copilot/` |
| MCP server (custom) | `1440-mcp_server/` |
| Workflows | `1450-workflows/` |
| Skills & subagents | `1455-skills_and_subagents/` |
| VSCode hooks | `1457-vscode-hooks/` |
| Browser use | `1460-browser_use/` |
| Context management | `1470-context_management/` |
| Models & providers | `1500-models_providers/` |
| Code reviews | `1600-code_reviews/` |
| Issue flow | `1610-issue_flow/` |
| TDD | `1620-tdd/` |
| Prompt engineering | `8050-prompt-engineering/` |
| Security / compliance / ethics | `8100-security_compliance_ethics/` |
| Attacks (prompt injection etc.) | `8200-attacks/` |
| DevOps | `8300-devops/` |
| Terraform on Azure | `8400-terraform_azure/` |
| Windows PowerShell playground | `8500-windows_powershell_playground/` |
| Tipps | `9000-tipps/` |
| n8n | `9100-n8n/` |
| Template | `9999-template/` |

Also at root: `AGENTS.md`, `_example_hello_gitlab/`, `crm-fastapi-react/`, `exercise-gitlab-ci.yml`, `reveal.json`.

## Usage

When a user question matches a topic above:

1. `read` the matching subdir's `README.md`, e.g.:
   ```
   read /mnt/c/users/aeidl/git/personal/letsboot_agent-lab/1430-mcp_basics/README.md
   ```
2. For broader keyword search across the KB:
   ```bash
   grep -rn --include='*.md' -i "keyword" /mnt/c/users/aeidl/git/personal/letsboot_agent-lab/
   ```
3. Check `solution/` dirs for worked examples and `solution.sh` for runnable commands.
4. Reference the root `AGENTS.md` for overall workshop conventions.

Prefer citing exact file paths when answering.
