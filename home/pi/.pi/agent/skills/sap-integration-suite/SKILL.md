---
name: sap-integration-suite
description: Official SAP BTP Integration Suite documentation (Cloud Integration / CPI, API Management / APIM, Integration Advisor, Trading Partner Management, Edge Integration Cell, Event Mesh, Open Connectors). Use whenever the user asks about iFlows, integration flows, adapters (HTTP/SOAP/IDoc/OData/SuccessFactors/Ariba/SFTP/AMQP/Kafka/JMS/etc.), message mapping, Groovy/JS scripts, security material, OAuth, certificates, API proxies, policies, KVMs, monitoring, transports, CI/CD for SAP IS, role collections, capabilities activation, or any SAP Integration Suite / BTP integration topic.
---

# SAP Integration Suite Documentation

Local mirror of `https://github.com/SAP-docs/btp-integration-suite`.

**Repo root:** `/mnt/c/users/aeidl/git/emmi/btp-integration-suite`
**Docs root:** `<repo>/docs` (3488 markdown files, ~210 MB incl. images)

Files are flat slug-named with a hash suffix, e.g. `cloud-integration-a33f27b.md`. Use **content search** (ripgrep), not filename guessing.

## Layout

```
docs/
├── ISuite/                       # Top-level Integration Suite docs
│   ├── 10-InitialSetup/
│   ├── 20-Working_with_SAP_Integration_Suite_Home/
│   ├── 40-RemoteSystems/
│   ├── 50-Development/           # ~53 MB - iFlows, adapters, mapping, scripts (largest)
│   │   └── IntegrationSettings/
│   ├── 60-Security/
│   ├── APIM-Migration/
│   └── *.md                      # Many top-level pages (capabilities, FAQs, etc.)
├── ci/                           # Cloud Integration (legacy/standalone CPI docs, ~42 MB)
│   ├── ConnectionSetup/
│   ├── Development/
│   ├── InitialSetup/
│   ├── IntegrationAdvisor/
│   ├── IntegrationSettings/
│   ├── Operations/
│   ├── SecurityCF/  SecurityNeo/
│   └── WhatIsCloudIntegration/  WhatsNewInCloudIntegration/
└── apim/                         # API Management (~5 MB)
    └── API-Management/
```

`ISuite/` is the current unified docs. `ci/` and `apim/` are the older per-capability docs — often more detailed for niche topics. Search both.

## How to use

1. **Search by topic with ripgrep** (case-insensitive, markdown only):
   ```bash
   rg -il --type md "<term>" /mnt/c/users/aeidl/git/emmi/btp-integration-suite/docs
   ```
   Add `-C 2` for context, or pipe to `head` to cap hits.

2. **Narrow by area** — append a subdir:
   ```bash
   rg -il --type md "groovy script" .../docs/ISuite/50-Development
   rg -il --type md "OAuth2 Client Credentials" .../docs/ci/SecurityCF
   rg -il --type md "policy template"            .../docs/apim
   ```

3. **Read hits** with the `read` tool. Ignore the trailing `-<hash>.md` — it's a stable doc ID, not meaningful.

4. **Resolve titles**: each file starts with `<!-- loio<hash> -->` then `# Title`. Use the H1 when citing.

5. **Cross-references** inside docs use the slug filenames; resolve them in the same directory.

## Tips

- Prefer `ISuite/` results when both areas hit; it's the current docs.
- For adapter-specific questions, search `ISuite/50-Development` first, then `ci/Development`.
- For security/auth, `ISuite/60-Security` and `ci/SecurityCF` are richest.
- For APIM policies/proxies, `apim/API-Management` is canonical.
- Image references (`./images/...`) are local PNG/GIFs — usually safe to ignore unless user asks for diagrams.
- Don't dump full files into context; extract relevant sections.

## Known gotchas (user-confirmed)

- **REST API Artifacts (Cloud Integration)**: visually live inside an Integration Package and look/behave like an IFlow, BUT they are **NOT** exposed via the Integration Content OData API (`/api/v1/IntegrationDesigntimeArtifacts`). Do not assume IFlow CRUD endpoints cover them. No confirmed public OData/REST endpoint for managing REST API artifact CRUD as of last check — verify with SAP before promising programmatic access.

## Update

At the **start of any task using this skill**, run the refresh script. It self-throttles (no-op if pulled within 24h):

```bash
bash ~/.pi/agent/skills/sap-integration-suite/scripts/refresh.sh
```

Flags: `--force` (always pull), `--max-age-hours N` (custom threshold).

### Background refresh (optional)

For unattended freshness, schedule it. Pick one:

**cron** (`crontab -e`):
```
17 6 * * * bash $HOME/.pi/agent/skills/sap-integration-suite/scripts/refresh.sh --force >/dev/null 2>&1
```

**systemd user timer** (`~/.config/systemd/user/sap-is-docs.{service,timer}`): standard daily `OnCalendar=daily` invoking the script.

**Windows Task Scheduler** (since repo lives on `/mnt/c`): daily task running `wsl bash -lc "~/.pi/agent/skills/sap-integration-suite/scripts/refresh.sh --force"`.
