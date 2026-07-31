# Neovim Java Dev Cheat Sheet

## Modes

| Key | Mode | Description |
|-----|------|-------------|
| `i` | Insert | Type text |
| `Esc` | Normal | Navigate and command |
| `v` | Visual | Select text |
| `V` | Visual Line | Select entire lines |
| `<C-v>` | Visual Block | Column selection |
| `:` | Command | Enter Ex commands |

## Navigation

| Key | Action |
|-----|--------|
| `h/j/k/l` | Left/Down/Up/Right |
| `w` / `b` | Next/previous word |
| `e` | End of word |
| `0` / `$` | Start/end of line |
| `gg` / `G` | Top/bottom of file |
| `{` / `}` | Previous/next paragraph |
| `<C-d>` / `<C-u>` | Half page down/up |
| `<C-o>` / `<C-i>` | Jump back/forward (jump list) |
| `%` | Jump to matching bracket |
| `zz` | Center cursor on screen |

## Editing

| Key | Action |
|-----|--------|
| `dd` | Delete line |
| `yy` | Yank (copy) line |
| `p` / `P` | Paste after/before |
| `u` / `<C-r>` | Undo/redo |
| `ciw` | Change inner word |
| `ci"` | Change inside quotes |
| `di(` | Delete inside parens |
| `da{` | Delete around braces |
| `o` / `O` | New line below/above |
| `A` | Append at end of line |
| `>>` / `<<` | Indent/dedent line |
| `.` | Repeat last change |
| `J` | Join line below |
| `~` | Toggle case |

## Window Management

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between windows |
| `:vs` | Vertical split |
| `:sp` | Horizontal split |
| `<C-w>=` | Equal size windows |
| `<C-w>o` | Close all other windows |

## Leader Key Bindings (`<Space>`)

### File & Search (Telescope)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search text) |
| `<leader>fb` | Open buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` | Document symbols |
| `<leader>fw` | Workspace symbols |
| `<leader>fd` | All diagnostics |
| `<leader>fh` | Help tags |

### LSP (Code Intelligence)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code action (quick fix, refactor) |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format file |
| `[d` / `]d` | Previous/next diagnostic |
| `<leader>d` | Show diagnostic details |

### Java Testing

| Key | Action |
|-----|--------|
| `<leader>tm` | Run test method (cursor on `@Test`) |
| `<leader>tc` | Run all tests in class |
| `<leader>dm` | Debug main class |

### Rust (rustaceanvim)

| Key | Action |
|-----|--------|
| `<leader>tm` | Run testable under cursor (`RustLsp testables`) |
| `<leader>dm` | Debug runnable under cursor (`RustLsp debuggables`) |
| `<leader>dT` | Debug last runnable again |
| `<leader>ca` | Code action (rust-analyzer grouped menu) |
| `K` | Hover + hover actions |
| `<leader>rM` | Expand macro |
| `<leader>rb` / `rr` / `rt` | `cargo build` / `run` / `test` |
| `<leader>rc` / `rk` / `rf` | `cargo clean` / `clippy` / `fmt` |
| `<leader>ct` / `cr` | crates.nvim: toggle info / reload |
| `<leader>cv` / `cf` | crates.nvim: show versions / features popup |
| `<leader>cu` / `cU` / `cA` | crates.nvim: update crate / upgrade crate / upgrade all |

### Debugging (DAP)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` / `F5` | Continue / start debug |
| `<leader>do` / `F10` | Step over |
| `<leader>di` / `F11` | Step into |
| `<leader>dO` / `F12` | Step out |
| `<leader>dt` | Terminate session |
| `<leader>du` | Toggle DAP UI |
| `<leader>dr` | Debug REPL |
| `<leader>dl` | Re-run last config |

### Git (Gitsigns)

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next/prev git hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line (full popup) |
| `<leader>hB` | Toggle inline blame (persistent) |

### General

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>x` | Close buffer |
| `<leader>e` | Toggle file explorer |
| `<Esc>` | Clear search highlight |
| `V` then `J`/`K` | Move selected lines |

## Useful Commands

| Command | Action |
|---------|--------|
| `:Mason` | Manage LSP servers/tools |
| `:Lazy` | Plugin manager UI |
| `:LspInfo` | Show active LSP clients |
| `:LspLog` | View LSP log |
| `:TSUpdate` | Update Treesitter parsers |
| `:checkhealth` | Diagnose issues |
| `:e <file>` | Open a file |
| `:bd` | Close current buffer |
| `:%s/old/new/g` | Find & replace in file |
| `:noh` | Clear search highlight |
| `:JdtUpdateConfig` | Refresh jdtls after editing `build.gradle` (new deps, etc.) |
| `:JdtWipeDataAndRestart` | Full jdtls reset — use if `:JdtUpdateConfig` doesn't pick up changes |

## Java Development Workflow

### Quick Edit Cycle
1. Open project: `nvim .` (from project root)
2. Find file: `<leader>ff`
3. Edit code — completion is automatic
4. Save: `<leader>w`
5. Fix errors: `[d`/`]d` to navigate, `<leader>ca` to fix

### Running Tests
1. Open test file
2. Cursor on a `@Test` method
3. `<leader>tm` to run that test
4. `<leader>tc` to run all tests in the class

### Debugging
1. Set breakpoint: `<leader>db` on the line
2. Start debug: `<leader>dm` (main) or `<leader>tm` (test)
3. Step through: `F10` (over), `F11` (into), `F12` (out)
4. Inspect variables in DAP UI (auto-opens)
5. Continue: `F5`
6. Stop: `<leader>dt`

### Refactoring
1. Rename: cursor on symbol → `<leader>rn`
2. Extract/inline: select code → `<leader>ca` → pick refactoring
3. Organize imports: `<leader>ca` → "Organize imports"
4. Generate: `<leader>ca` → toString, equals, constructor, etc.

## Tips

- **Repeat anything:** `.` repeats your last change
- **Search in file:** `/pattern` then `n`/`N` for next/prev
- **Search project-wide:** `<leader>fg` (live grep)
- **Jump back:** `<C-o>` after `gd` to go back where you were
- **Multi-cursor-ish:** `cgn` — change next search match, then `.` to repeat
- **Quick fix all:** `<leader>ca` often offers "fix all in file"
- **Which-key:** press `<leader>` and wait — shows all available bindings

## Terminal & Build

| Key | Action |
|-----|--------|
| `` <C-`> `` | Toggle terminal (bottom split) |
| `<Esc><Esc>` | Exit terminal mode back to Normal |
| `<leader>gg` | Open Lazygit (floating) |
| `<leader>bb` | Gradle build |
| `<leader>br` | Gradle bootRun |
| `<leader>rb` | Cargo build |
| `<leader>rr` | Cargo run |
| `<leader>bt` | Gradle test |
| `<leader>bc` | Gradle clean |

### Terminal Tips
- Toggle terminal is persistent — your shell session stays alive when hidden
- You can open multiple terminals: `:2ToggleTerm` opens terminal #2
- Send current line to terminal: `:ToggleTermSendCurrentLine`
- The terminal opens at the bottom (15 lines). Resize with `<C-w>+` / `<C-w>-`

## Interactive Debugging Workflows

### Debug a Test Method
1. Open test file, cursor on `@Test` method
2. Set breakpoint(s): `<leader>db` on lines you want to stop at
3. Start debugging: `<leader>dT` (debug test method)
4. DAP UI opens automatically — shows variables, call stack, watches
5. Step through: `F10` (over), `F11` (into), `F12` (out)
6. Inspect variable under cursor: hover with `K` in DAP UI
7. Continue to next breakpoint: `F5`
8. Stop: `<leader>dt`

### Debug Main Class (direct launch)
1. Set breakpoint(s) in your code
2. `<leader>dm` — finds and launches your `main()` with debugger
3. Step through as above

### Debug Spring Boot App (remote attach)
1. Launch app with debug port: `<leader>bR` (runs `./gradlew bootRun --debug-jvm`)
2. Wait for "Listening for transport dt_socket at address: 5005"
3. Set breakpoint(s) in your code
4. Attach debugger: `<leader>da`
5. Trigger your code (hit an endpoint, etc.)
6. Debugger stops at breakpoint — step through as above

### While Debugging

| Key | Action |
|-----|--------|
| `F5` | Continue (run to next breakpoint) |
| `F10` | Step over (next line) |
| `F11` | Step into (enter method) |
| `F12` | Step out (exit current method) |
| `<leader>du` | Toggle DAP UI (variables/stack/watches) |
| `<leader>dr` | Open REPL (evaluate expressions) |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dt` | Terminate debug session |
| `<leader>dl` | Re-run last debug config |

### DAP UI Panels
When debugging, the UI shows:
- **Scopes** (top-left): local variables and their values
- **Breakpoints** (bottom-left): all your breakpoints
- **Stacks** (top-right): call stack — click to jump to frame
- **Watches** (bottom-right): add expressions to watch

To add a watch: go to the watches panel, press `i`, type expression (e.g., `user.getName()`).

## Run/Debug with Parameters

### Option 1: `launch.json` (define configs per project)

Create `.vscode/launch.json` in your project root:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Run App (dev)",
      "request": "launch",
      "mainClass": "com.example.Application",
      "args": "--spring.profiles.active=dev",
      "vmArgs": "-Xmx512m -Dserver.port=8080",
      "env": { "MY_VAR": "value" }
    }
  ]
}
```

Then `<leader>dc` / `F5` will show a picker with your named configs.

### Option 2: Prompted input

| Key | Action |
|-----|--------|
| `<leader>dA` | Debug main class — prompts for program args and VM args |

### Available launch.json fields

| Field | Example | Description |
|-------|---------|-------------|
| `mainClass` | `com.example.App` | Fully qualified main class |
| `args` | `--port 8080 --env dev` | Program arguments |
| `vmArgs` | `-Xmx1g -Dfoo=bar` | JVM arguments |
| `env` | `{"KEY": "val"}` | Environment variables |
| `cwd` | `${workspaceFolder}` | Working directory |
| `request` | `launch` or `attach` | Launch new or attach to running |
| `port` | `5005` | Port for attach mode |

## Database (vim-dadbod-ui)

| Key | Action |
|-----|--------|
| `<leader>Dt` | Toggle DB UI sidebar |
| `<leader>Da` | Add a new DB connection |
| `<leader>Df` | Find DB buffer |

### Usage
1. `<leader>Dt` — opens the DB UI sidebar (left panel)
2. Navigate connections/tables with `j`/`k`, expand with `<CR>`
3. Press `<CR>` on a table to see its contents
4. Open a new query buffer: select connection → `<CR>` on "New Query"
5. Write SQL, then execute:
   - Visual select your query → `<leader>S` (or the whole buffer with `<leader>S` in normal mode)
   - Results appear in a split below

### Connection URL Format
```
mysql://user:password@host:port/database
postgresql://user:password@host:port/database
sqlite:///path/to/file.db
```

### Adding Connections
- Via command: `:DBUIAddConnection` → paste URL
- Via file: edit `~/.local/share/db_ui/connections.json` (this repo's `init.lua`
  now pins `vim.g.db_ui_save_location` explicitly to this path, so it no
  longer depends on the plugin's implicit default)
- SQL completion works automatically in query buffers

### Tips
- Saved queries persist between sessions
- You can have multiple connections open simultaneously
- Table contents auto-refresh when you re-select them
- Use `:DB mysql://...` for one-off queries without the UI

### Gotchas
- **Connections not showing up / re-prompted for connection info**: double
  check `connections.json` actually lives at `g:db_ui_save_location`
  (default `~/.local/share/db_ui/connections.json` — note: *not*
  `stdpath('data')/db_ui`, easy to assume wrong). Fully quit/reopen Neovim
  after moving the file; a running session won't pick up a relocated file.
- **`DB: 'mysql' executable not found` from `vim-dadbod-completion`**:
  `vim-dadbod`/`vim-dadbod-completion` shell out to the real native CLI
  (`mysql`, `psql`, etc.) for schema lookups and connections — this is a
  separate dependency from the Neovim plugin. Install it and put it on
  `PATH`:
  ```bash
  brew install mysql-client   # keg-only, needs explicit PATH
  echo 'export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"' >> ~/.zshrc
  ```
  Open a **new** terminal (or `source ~/.zshrc`) before relaunching Neovim —
  an already-running Neovim won't see the updated `PATH`.
- **Result rows show as `+-- N lines: +---...` instead of a table**: that's a
  closed Vim fold (`dbout` filetype auto-folds results), not missing data.
  `zo`/`zR` opens it manually, or `:messages` confirms with `DB: Query ...
  finished` (vs. `(no window?)` if the preview window genuinely closed
  before the async query finished). `init.lua` now force-opens dbout folds
  on every load/reload (`BufWinEnter`/`BufReadPost`), including repeat
  queries reloaded in the same buffer, so this shouldn't recur.
- **`E21: Cannot make changes, 'modifiable' is off`**: expected — dbout result
  buffers are intentionally readonly. It means a keystroke landed in the
  results window, not a bug. Use `yh`/`vic` to yank header/cell values
  instead of editing.

## tmux

Config lives at `~/.tmux.conf`. Key settings:

| Setting | Value | Why |
|---|---|---|
| `extended-keys on` | on | Required for pi to correctly receive modified Enter/other extended key combos |
| `extended-keys-format` | `csi-u` | pi works best with `csi-u` encoding (not the default `xterm`) instead of xterm-style |
| `mouse` | on | Mouse support (pane selection, scroll, resize) |
| `history-limit` | 10000 | Bigger scrollback |
| `base-index` / `pane-base-index` | 1 | Windows/panes start numbering at 1, not 0 |

### Common commands
| Command | Action |
|---|---|
| `tmux new -s <name>` | Start a new named session |
| `tmux ls` | List sessions |
| `tmux attach -t <name>` | Reattach to a session |
| `tmux kill-session -t <name>` | Kill one session |
| `tmux kill-server` | Kill all sessions (needed after editing `.tmux.conf`, since options are read once at server start) |
| `prefix` (`C-b`) then `d` | Detach from session |

### Troubleshooting
- **"Warning: tmux extended-keys is off"** or **"extended-keys-format is xterm"** (seen when running pi inside tmux) → add both `set -g extended-keys on` and `set -g extended-keys-format csi-u` to `~/.tmux.conf`, then fully restart the tmux server (`tmux kill-server`, not just detach) since these are server-level options only read at startup.

## Zellij

Alternative multiplexer, kept **alongside** tmux (not a replacement) — used
on-demand in whichever WezTerm tab wants it, not as WezTerm's default
program (`config.default_prog` is intentionally left unset in
`~/.config/wezterm/wezterm.lua` so every new WezTerm tab still opens a
plain shell, same as before). Config lives at `~/.config/zellij/config.kdl`.

### Gotcha: default keybindings collide with nvim/pi
Zellij's out-of-the-box Normal-mode bindings intercept `Ctrl+h` (→ Move
mode), `Ctrl+n` (→ Resize mode), `Ctrl+p` (→ Pane mode), `Ctrl+b` (→
Tmux-compat mode), and `Ctrl+o` (→ Session mode) **before** they reach an
app running inside a pane. Confirmed this breaks nvim-cmp's `<C-n>`/`<C-p>`
completion navigation, nvim's `<C-h>` window-nav, and nvim's native
`<C-o>` jump-back. Fixed by rebinding Zellij's own mode-switch triggers
to `Alt+p/n/s/o/t/h/b` in `config.kdl`, freeing `Ctrl+letter` entirely for
the app inside the pane. Verified live (nvim inside Zellij inside tmux):
`Ctrl+n`/`Ctrl+p` correctly move the cmp completion selection, `Ctrl+h`
passes through as a no-op, and Zellij's status bar never switches mode.
- Alternative if you don't want to touch config: `Ctrl+g` toggles Zellij's
  built-in **Locked** mode, where *all* keys pass straight through
  untouched (Zellij's own hotkeys go dormant until `Ctrl+g` again).

### Theme / fonts
- Fonts/icons/Nerd Font glyphs are inherited automatically from WezTerm
  (`config.font` in `wezterm.lua`) — no separate config needed, Zellij just
  renders text/Unicode like any other terminal app.
- Colors are **not** inherited automatically — Zellij has its own separate
  theming system. Set to the built-in `tokyo-night` theme to match
  WezTerm's `color_scheme = "Tokyo Night"`.

### Common commands
| Command | Action |
|---|---|
| `zellij` / `zellij -s <name>` | Start a new (optionally named) session |
| `zellij list-sessions` (`zellij ls`) | List sessions |
| `zellij attach <name>` | Reattach to a session |
| `zellij kill-session <name>` | Kill one session |
| `zellij kill-all-sessions` | Kill all sessions |
| `Ctrl+q` | Quit/detach from session |
| `Ctrl+g` | Toggle Locked mode (full passthrough to the app in the pane) |
| `Alt+p` / `Alt+t` / `Alt+n` / `Alt+h` / `Alt+s` / `Alt+o` | Pane / Tab / Resize / Move / Search / Session mode (remapped off `Ctrl+*`, see gotcha above) |

### Gotcha: pane title doesn't show the running process by default
Unlike tmux's *window* auto-rename (which inspects the pty's foreground
process directly), Zellij's pane title only updates via a standard OSC 0
title escape sequence sent by the shell — it does no process inspection
of its own. Confirmed empirically: `printf '\033]0;test\007'` instantly
changes the title, but nothing fires automatically without a shell hook.
Starship (the prompt) does not set this either — it's a separate concern.

Bare zsh (no oh-my-zsh/Prezto/etc.) doesn't ship this hook by default;
framework-based setups do (oh-my-zsh's `lib/termsupport.zsh`), which is
why this is easy to not know about. Fixed by vendoring
[pawel-slowik/zsh-term-title](https://github.com/pawel-slowik/zsh-term-title)
(MIT, see `zsh/README.md` in this repo) rather than hand-rolling a
`preexec`/`precmd` hook — it already handles job-control edge cases
(`fg`, `fg %1`) that a naive first-word-of-command-line hook gets wrong on
chained commands (`cd x && nvim y` would show `cd`, not `nvim`).

