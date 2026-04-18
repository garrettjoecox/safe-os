# safe-os-2

Locked-down Ubuntu 24.04 kiosk for kids. Target hardware: Beelink Intel mini-PC, bare-metal install. Single-screen, single-user, no terminal access.

## What this project is

A set of idempotent shell scripts that take a fresh Ubuntu 24.04 desktop install and turn it into a kiosk that:

- Autologins a `kid` user into a stripped Openbox session
- Shows a tint2 dock with five launcher buttons: PBS Kids, Minecraft, Scratch, Notepad (gedit), Paint (KolourPaint)
- Strips every system keybinding — no Alt+Tab, no Ctrl+Alt+Del, no VT switching, no Magic SysRq, no desktop right-click menu
- Has a single escape hatch (Ctrl+Alt+Shift+P → password prompt → switch-to-greeter / reboot / shutdown)

Two users on the box:
- **Parent** — the sudo user created during Ubuntu install. Has GNOME, Prism Launcher cached MS-account auth, full access. Reachable via the escape hatch (switch-to-greeter).
- **`kid`** — created by `01-create-kiosk-user.sh`. Locked password (autologin only), no sudo (denied by `10-no-kid` sudoers file), only re-permitted to invoke `/usr/local/sbin/safe-os-priv` (by `20-safe-os-priv`).

## Run order

`install.sh` runs `scripts/[0-9]*.sh` lexicographically. Order matters — `02` installs packages others depend on; `10` references the sudoers file from `01`; `11` references binaries from `02`.

## Repo is source of truth

Every config file in `config/` is `install`-copied into place. Manual edits to deployed files (`/etc/chromium/policies/managed/pbskids.json`, `~kid/.config/openbox/rc.xml`, etc.) get reverted on next run. To change behavior, edit the file under `config/` or `launchers/` and re-run `install.sh`.

## Architecture choices and why

- **X11, not Wayland.** Lockdown tooling (DontVTSwitch, Openbox keybinding monopoly, xset/xsetroot) is mature on X11; Wayland kiosk story is fragmented in 24.04.
- **Openbox over GNOME Kiosk / LXQt.** Single `rc.xml` owns 100% of keybindings. Nothing fires unless explicitly bound. No app drawer, no Super-key launcher, no settings panel to escape into.
- **tint2 over plank.** Static launcher buttons defined in one config file. No app drawer, no recent-apps surface.
- **LightDM over GDM3.** Simpler `[Seat:*]` autologin config; `dm-tool switch-to-greeter` is the clean escape-to-parent path.
- **Per-app firejail.** Hard `--net=none` on Minecraft is the linchpin of "offline mode." UNIX X sockets pass through firejail's namespace, so no `--x11` flag needed.

## The privilege model

`kid` is sudo-denied by `/etc/sudoers.d/10-no-kid`. Then `/etc/sudoers.d/20-safe-os-priv` re-permits exactly:

```
kid ALL=(root) NOPASSWD: /usr/local/sbin/safe-os-priv
```

`safe-os-priv` accepts only four subcommands (`verify-password`, `set-lockout`, `reboot`, `poweroff`) and validates argv before any side effect. Sudoers uses last-match semantics and `/etc/sudoers.d/` is read in lexical order, so the more-specific `20-` allow wins over the `10-` deny.

The parent password hash lives at `/etc/safe-os/parent.hash` (mode 0600 root:root — kid can't read it directly). Verification only happens inside `safe-os-priv`.

## Iteration loop

- **Re-running `install.sh` is safe and expected.** All operations are idempotent: `useradd` guarded by `id`, `gpasswd --delete` swallows missing-membership errors, `install` overwrites, apt/flatpak idempotent, `systemctl mask`/`enable` idempotent, `groupadd -f`, `flatpak install --or-update`.
- **Run from the parent account, not from the kid session.** Openbox/tint2 read their config at session start. After re-running, log out kid and log back in (or `openbox --reconfigure && killall -HUP tint2`) to apply WM/dock changes mid-session.
- **`set-parent-password` is never called from `install.sh`.** Iterating won't blow away a set password.

## Known caveats

- **Prism keyring download isn't atomic.** `07-minecraft-prism.sh` skips re-downloading if the file exists. A failed mid-download leaves a corrupt file. If trust chain breaks, `rm /etc/apt/keyrings/prismlauncher-archive-keyring.gpg /etc/apt/sources.list.d/prismlauncher.sources` and re-run.
- **Minecraft auth requires one online launch as parent.** Prism caches MS account tokens to `~parent/.local/share/PrismLauncher/`. The kid launcher uses `firejail --net=none` so token refresh never happens — eventually tokens expire (usually weeks). When kid mode stops launching MC, parent re-auths in their own session.
- **Java version coupling.** We install `openjdk-21-jre`. Newer Minecraft (1.20.5+) wants Java 21; 1.20.4 and older want Java 17. Install `openjdk-17-jre` if you target older versions; Prism picks per-instance.
- **PBS Kids CDN allowlist is partial.** `pbskids-policy.json` lists pbskids/pbs/akamai/cloudfront. Real videos may pull from other hosts — open devtools in the parent session, watch the network tab on a failing video, add the host to `URLAllowlist`, re-run `install.sh`.
- **`dconf-no-automount` applies to all users, not just kid.** The profile is named `user` (the dconf default), so the parent's GNOME also gets automount disabled. Acceptable for this box; if you ever need parent automount back, switch to a `kid` profile + `DCONF_PROFILE=kid` env var in the kid session.
- **Right-click is disabled at the desktop and Openbox-window level only.** Right-click inside apps (Scratch, KolourPaint, gedit, GIMP if added) still works — those apps need it for normal use.
- **Two Chromium policy directories.** We write to both `/etc/chromium/policies/managed/` and `/etc/chromium-browser/policies/managed/` because the apt-installed binary varies by Ubuntu version on which path it reads. Both copies stay in sync via `install.sh`.

## File layout

```
install.sh                     # entrypoint, root, runs scripts/ in order
scripts/01..11-*.sh            # numbered install steps, idempotent
config/
  lightdm/                     # autologin + xsession definition
  xorg/                        # DontVTSwitch / DontZap
  openbox/                     # rc.xml (keybinds), menu.xml (empty), autostart, session script, dconf
  tint2/                       # dock with launcher_item_app entries
  chromium/                    # managed policy JSON (URL allow/blocklist + lockdowns)
  sysctl/                      # kernel.sysrq=0
launchers/
  safe-*.sh                    # firejail / kiosk-flag wrappers, deployed to /usr/local/bin/
  safe-*.desktop               # icons for tint2, deployed to /usr/local/share/applications/
bin/
  parent-mode                  # kid-runnable, prompts password, calls safe-os-priv
  safe-os-priv                 # root, allowlisted subcommands only
  set-parent-password          # interactive, writes /etc/safe-os/parent.hash
```

## When asked to add an app to the dock

1. Add `launchers/safe-<app>.sh` (use firejail with `--net=none` if it shouldn't talk to the internet).
2. Add `launchers/safe-<app>.desktop`.
3. Add `launcher_item_app = /usr/local/share/applications/safe-<app>.desktop` to `config/tint2/tint2rc`.
4. If the app needs apt or flatpak install, add a step to `02-install-packages.sh` or a new `scripts/NN-*.sh`.
5. Re-run `install.sh`.

## When asked to relax the URL allowlist

Edit `config/chromium/pbskids-policy.json`, re-run `install.sh`, restart Chromium (kid logout/login). Don't edit `/etc/chromium*/policies/managed/pbskids.json` directly — it's overwritten on next install.
