# zsh/term-title.plugin.zsh

Vendored copy of [pawel-slowik/zsh-term-title](https://github.com/pawel-slowik/zsh-term-title)
(MIT license, see `LICENSE-zsh-term-title`), commit-pinned as of the date
vendored rather than tracked as a submodule, since it's a single ~50-line
file with no dependencies.

Sets the pane/terminal title to the running command + cwd via a standard
`preexec`/`precmd` OSC 0 title escape — the same primitive tmux/iTerm2/
oh-my-zsh's `termsupport.zsh` all use. Not custom-written — bare zsh (no
oh-my-zsh/Prezto/etc.) just doesn't ship this by default the way
framework-based setups do, so a from-scratch `.zshrc` needs it explicitly.

Primary target here is **Zellij** pane titles (confirmed working via the
plain OSC 0 sequence). The plugin also emits an extra tmux-specific title
escape when `$TMUX` is set, but that's just inert upstream behavior we're
not tuning for — tmux isn't the focus.

Symlinked into `~/.zsh/plugins/zsh-term-title/term-title.plugin.zsh` by
`install.sh`, sourced from `~/.zshrc`.
