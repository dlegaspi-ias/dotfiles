# dotfiles

Personal dev environment configs, reference docs, and setup notes. Public,
read-only for everyone else — only I push here.

## Layout

```
nvim/init.lua        Neovim 0.12+ config: Java/Gradle LSP (jdtls + Lombok),
                      nvim-dap debugging, vim-dadbod-ui, jb.nvim theme, etc.
tmux/tmux.conf        tmux config (extended-keys/csi-u fix for pi & nvim)
starship/starship.toml  Starship prompt (Nord palette, git, AWS profile, langs)
CHEAT_SHEET.md        Keybindings, commands, workflows, gotchas
TOOLING.md            Dev tooling reference: SDKMAN/Java, CLI tools, LiteLLM,
                      local LLM (Ollama/LM Studio), pi extensions
SKILLS.md             Custom pi.dev skills reference
install.sh            Symlinks the above into place (idempotent, backs up
                      existing files before replacing)
```

## Install

```bash
git clone https://github.com/dlegaspi-ias/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # symlink everything
./install.sh nvim     # or just one target: nvim | tmux | starship
```

Re-running is safe — it's idempotent and backs up any existing real file as
`<path>.bak-<timestamp>` before symlinking over it.

## Team-shared pi.dev extensions

Reusable/team pi.dev extensions, skills, and prompts (not personal-machine
config) live separately in
[integralads/ias-pi-extensions](https://github.com/integralads/ias-pi-extensions),
installed via `pi install git:github.com/integralads/ias-pi-extensions`. This
repo is for personal machine setup only.

## Security

No credentials, API keys, or personal contact info are committed here.
Anything requiring a secret (LiteLLM master key, GitHub tokens, iMessage
recipient, DB passwords, etc.) is referenced by env var name only — actual
values live outside version control (`~/.zshrc`, `~/.pi/agent/secrets/`,
password manager, etc.).
