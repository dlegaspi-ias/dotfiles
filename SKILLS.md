# Custom Pi Skills

Custom skills registered in `~/.pi/agent/skills/`. Skills are auto-discovered by pi and give it specialized instructions/scripts for specific tasks — see [pi's skills docs](https://pi.dev) for how discovery works.

> Skills are loaded at **session startup**. After adding/editing a skill, restart the pi session to pick up changes.

## Installed Skills

| Skill | Purpose |
|---|---|
| `macos-notify` | Send macOS notifications — Notification Center banner, sticky modal dialog, or **iMessage via Messages.app** (reaches your iPhone). Used for CI/build alerts, long-running task completion, "notify me" requests. |
| `atlassian-rest-api` | Direct Confluence/Jira Cloud REST API calls (via curl + stored API token) for anything the Atlassian MCP connector can't do — e.g. uploading page attachments/images. |
| `jenkins-help` | IAS `jenkins-pipeline-scripts` library help — Jenkinsfile, `.jervis.yml`, `.ci/**` edits, pipeline step questions. |
| `jenkins-logs` | Fetch and inspect Jenkins build logs from `jenkins.303net.net` — diagnosing failed builds, console output. |
| `jira-ai-cost-comment` | Add an AI-assisted development comment to a Jira ticket with model info, estimated token usage/cost, PR links, and a summary of changes. |

## macos-notify Details

Three notification modes via `./scripts/notify.sh`:

```bash
./scripts/notify.sh banner "<message>" ["<title>"] ["<subtitle>"]
./scripts/notify.sh sticky "<message>" ["<title>"] ["<button label>"]
./scripts/notify.sh imessage "<message>" ["<recipient>"]
```

- **banner** — Notification Center banner, non-blocking, auto-dismisses
- **sticky** — modal dialog, blocks until dismissed, for things that must not be missed
- **imessage** — sends via Messages.app so it reaches your iPhone. Recipient defaults to `$MACOS_NOTIFY_IMESSAGE_TO` env var (set in `~/.zshrc`, **never hardcoded into the skill file or committed anywhere shared**)

First `imessage` use requires granting Automation permission in System Settings → Privacy & Security → Automation.

## Notes

- Skill files live under `~/.pi/agent/skills/<name>/SKILL.md` (+ optional `scripts/`)
- Never commit secrets/tokens/personal contact info into skill files themselves — use env vars instead, referenced by name only
- Project-specific skills can also live in a repo's own `.pi/skills/` — check `AGENTS.md`/`CLAUDE.md` conventions per repo
