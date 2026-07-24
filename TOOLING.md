# Development Tooling

Tools and utilities installed on this machine for Java/AI development workflow.

## Package Managers

| Tool | Install | Purpose |
|------|---------|---------|
| [Homebrew](https://brew.sh) | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | macOS package manager |
| [SDKMAN](https://sdkman.io) | `curl -s "https://get.sdkman.io" \| bash` | Java/Gradle/Kotlin version manager |
| [uv](https://docs.astral.sh/uv/) | `brew install uv` | Fast Python package/tool manager |

## Java (via SDKMAN)

```bash
sdk install java 11.0.28-zulu
sdk install java 17.0.16-amzn
sdk install java 21.0.8-tem
sdk install java 24.0.2-amzn    # default
```

## CLI Tools

| Tool | Install | Purpose |
|------|---------|---------|
| [Neovim](https://neovim.io) 0.12+ | `brew install neovim` | Editor |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `brew install ripgrep` | Fast grep (used by Telescope) |
| [lazygit](https://github.com/jesseduffield/lazygit) | `brew install lazygit` | Terminal Git UI |
| [Starship](https://starship.rs) | `brew install starship` | Shell prompt |
| [GitHub CLI](https://cli.github.com) | `brew install gh` | GitHub from terminal |

## AI / LLM Tools

| Tool | Install | Purpose |
|------|---------|---------|
| [LiteLLM](https://docs.litellm.ai) | `uv tool install --force 'litellm[proxy]' --with prometheus_client==0.20.0` | Unified LLM API proxy (OpenAI-compatible) |
| [pi](https://pi.dev) | — | AI coding agent |

### LiteLLM Setup

LiteLLM provides an OpenAI-compatible proxy for unified LLM access, load balancing, and observability (Langfuse).

**Config (`~/litellm_config.yaml`):**
```yaml
model_list:
  - model_name: opus-4-6
    litellm_params:
      model: bedrock/us.anthropic.claude-opus-4-6-v1
      aws_profile_name: saml
      aws_region_name: us-east-1

litellm_settings:
  drop_params: true
  modify_params: true
  success_callback: ["prometheus"]
  failure_callback: ["prometheus"]
  require_auth_for_metrics_endpoint: false

general_settings:
  master_key: sk-1234
```

**Start:**
```bash
litellm --config ~/litellm_config.yaml
```

**Pi integration (via extension):**
```bash
pi install npm:pi-provider-litellm
```

The extension auto-discovers models from LiteLLM. Configure via env vars:
```bash
export LITELLM_BASE_URL=http://localhost:4000
export LITELLM_API_KEY=sk-1234
```

Then use: `pi --provider litellm --model opus-4-6`

> **Note:** Do NOT use `models.json` for LiteLLM — use the extension instead.
> It auto-detects context windows, capabilities, and supports `/litellm-refresh`.

### Pi Launch Scripts

**Direct Bedrock (`my-pi.sh`):**
```bash
export AWS_PROFILE=saml && \
export GITHUB_PERSONAL_ACCESS_TOKEN=<your-gh-token> && \
pi --no-themes --provider amazon-bedrock --model us.anthropic.claude-opus-4-6-v1 $1
```

**Via LiteLLM proxy (`my-pi-litellm.sh`):**
```bash
export AWS_PROFILE=saml && \
export GITHUB_PERSONAL_ACCESS_TOKEN=<your-gh-token> && \
export LITELLM_BASE_URL=http://localhost:4000 && \
export LITELLM_API_KEY=sk-1234 && \
pi --no-themes --provider litellm --model opus-4-6 $1
```

Usage:
```bash
# Normal start
./my-pi-litellm.sh

# Continue last session
./my-pi-litellm.sh --continue
```

> **Note:** LiteLLM proxy must be running first: `litellm --config ~/litellm_config.yaml`

### Pi Extensions

Installed via `pi install npm:<package>`. Check what's installed: `pi list`.

| Extension | Purpose |
|---|---|
| `pi-mcp-adapter` | Bridges pi to MCP servers (Atlassian, GitHub, etc.) via `~/.config/mcp/mcp.json` |
| `pi-web-access` | Web search / fetch_content / get_search_content tools |
| `pi-subagents` | Subagent orchestration (single/chain/parallel delegation) |
| `pi-clear` | Context/session clearing utility |
| `pi-provider-litellm` | LiteLLM proxy provider integration (auto-discovers models) |
| `@petechu/pi-extension-toggle` | Enable/disable installed extensions, skills, prompts, and themes from an interactive picker inside pi — `/extension-toggle` or `Ctrl+Shift+E` |
| `pi-footer` | Configurable multi-line footer/statusline — model, provider, context usage (bar + %), tokens, cost, git state, session activity, extension statuses. Compact, plain, or powerline styles. Replaced `pi-context-footer` (removed — less configurable). |

### Custom Extensions

Global, auto-discovered extensions live in `~/.pi/agent/extensions/*.ts` (`/reload` picks up changes without a full restart). Unlike the npm-installed ones above, these are local files, not installed via `pi install`.

As of this writing there are no purely-personal local extensions left here —
the one that used to live in this repo (`compaction-progress.ts`, a cosmetic
progress bar during pi's native session compaction) has been moved into the
team-shared package **[integralads/ias-pi-extensions](https://github.com/integralads/ias-pi-extensions)**
and is installed via `pi install git:github.com/integralads/ias-pi-extensions`
instead of a loose file here. See that repo's own README for what's in it
and how to install/filter individual extensions/skills/prompts.

### Local Models (Ollama + LM Studio)

Both run OpenAI-compatible local servers and are wired into pi via `~/.pi/agent/models.json` (not the litellm extension, since these are direct local servers).

**Ollama** — `http://localhost:11434/v1`
```bash
brew install ollama
ollama serve
ollama pull hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q5_K_M
```

**LM Studio** — `http://localhost:1234/v1`
- Install the LM Studio app, load a model, then in the **Developer/Local Server** tab click **Start Server**
- Confirm the exact model id being served: `curl -s http://localhost:1234/v1/models`

**`~/.pi/agent/models.json`:**
```json
{
  "providers": {
    "lmstudio": {
      "baseUrl": "http://localhost:1234/v1",
      "api": "openai-completions",
      "apiKey": "lm-studio",
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        {
          "id": "qwen/qwen3.6-27b",
          "name": "Qwen3.6 27B (LM Studio)",
          "reasoning": true,
          "input": ["text"],
          "contextWindow": 128000,
          "maxTokens": 32768,
          "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 }
        }
      ]
    },
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        {
          "id": "hf.co/bartowski/Qwen2.5-Coder-32B-Instruct-GGUF:Q6_K",
          "name": "Qwen2.5 Coder 32B (Local)",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 32768,
          "maxTokens": 8192,
          "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 }
        },
        {
          "id": "hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q5_K_M",
          "name": "Qwen3 30B A3B (Local)",
          "reasoning": true,
          "input": ["text"],
          "contextWindow": 40960,
          "maxTokens": 32768,
          "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
          "compat": {
            "thinkingFormat": "qwen-chat-template",
            "chatTemplateKwargs": {
              "enable_thinking": { "$var": "thinking.enabled" }
            }
          }
        }
      ]
    }
  }
}
```

Usage:
```bash
pi --provider ollama --model "hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q5_K_M"
pi --provider lmstudio --model "qwen/qwen3.6-27b"
```
Or pick from `/model` inside a running pi session (requires a fresh session/restart to pick up new local servers — there's no live provider-refresh command for these, unlike LiteLLM's `/litellm-refresh`).

> **Note:** LM Studio's served model `id` changes whenever a different model is loaded in the app — re-check with `curl http://localhost:1234/v1/models` and update `models.json` if you swap models.
>
> **Note:** If you change the context size for a loaded model in LM Studio's UI, `contextWindow` in `models.json` won't auto-update. Check the actual loaded value and sync it:
> ```bash
> curl -s http://localhost:1234/api/v0/models | grep -A2 loaded_context_length
> ```

## Shell Configuration

- **Shell:** zsh
- **Prompt:** Starship (`~/.config/starship.toml`)
- **AWS:** `~/.aws/credentials` with profiles: `default`, `ias-dev`, `saml`, `ias-prod`
- **AWS default profile:** `saml` (set in `~/.zshrc`)
- **Helper:** `awsp <profile>` to switch AWS profiles

## Neovim Plugins (managed by lazy.nvim)

See `init.lua` for the full config. Key plugins:
- **LSP:** nvim-lspconfig, nvim-jdtls (Java + Lombok), Mason
- **Completion:** nvim-cmp
- **Debug:** nvim-dap + java-debug-adapter + java-test
- **DB:** vim-dadbod-ui (requires native DB CLIs like `mysql`/`psql` on `PATH`
  for `vim-dadbod-completion` to work — e.g. `brew install mysql-client`)
- **Git:** gitsigns, lazygit (via toggleterm)
- **UI:** jb.nvim (JetBrains dark theme), lualine, neo-tree, telescope

