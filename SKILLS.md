# Custom Pi Skills

Custom skills registered in `~/.pi/agent/skills/`. Skills are auto-discovered by pi and give it specialized instructions/scripts for specific tasks — see [pi's skills docs](https://pi.dev) for how discovery works.

> Skills are loaded at **session startup**. After adding/editing a skill, restart the pi session to pick up changes.

> This doc covers custom-authored skills in `~/.pi/agent/skills/`. Vendored
> third-party skills (e.g. the official Databricks agent skills) live in the
> separate `~/.agents/skills/` location instead — see the **Databricks**
> section of [TOOLING.md](TOOLING.md) for that one.

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

**Gotcha (caused a real silent-failure bug once):** the 3rd positional
arg means something different per mode — `banner`/`sticky` treat it as a
**title**, but `imessage` treats it as a **recipient override**. Passing
a title-shaped string (e.g. `"pi agent"`) as the 3rd arg to `imessage`
silently tries to message a nonexistent buddy with that literal name and
typically fails with no visible error/nonzero exit code. For the normal
case, call `imessage` with only 2 args (mode + message) and let it fall
back to the env var. `notify.sh` now warns to stderr if the recipient
doesn't look like a phone number or email, but exit code alone still
can't be trusted to confirm delivery — confirm with the user if unsure.

First `imessage` use requires granting Automation permission in System Settings → Privacy & Security → Automation.

## Notes

- Skill files live under `~/.pi/agent/skills/<name>/SKILL.md` (+ optional `scripts/`)
- Never commit secrets/tokens/personal contact info into skill files themselves — use env vars instead, referenced by name only
- Project-specific skills can also live in a repo's own `.pi/skills/` — check `AGENTS.md`/`CLAUDE.md` conventions per repo
