# Pi + Feynman research container — technical notes

An isolated Docker setup running [Pi](https://pi.dev) and
[Feynman](https://feynman.is) against OpenRouter, with a single mounted
`./workspace` directory as the only host path the agent can touch.

> **Looking for setup instructions?** This is the engineering record. The
> user-facing guide is **[README.md](README.md)**, with per-platform Docker
> installation in [docs/](docs/).

This document records what was **actually verified**, not just what was
intended. Deviations from the original plan are called out in
[Deviations from the plan](#deviations-from-the-plan).

---

## Quick start

```bash
cp .env.example .env
$EDITOR .env                      # paste your real OpenRouter key

docker compose build
docker compose run --rm alphaxiv-login    # one-off; see "alphaXiv login" below
docker compose run --rm pi-feynman        # drops into the Feynman REPL
```

`docker compose run` reads `.env` from the project directory automatically —
no `--env-file` flag is needed, for either `run` or `up`.

---

## What is in the image

| Component | Version | Where it lands |
|---|---|---|
| Base image | `node:22.23.2-bookworm-slim` | — |
| Node.js | 22.23.2 | `/usr/local/bin/node` |
| Pi | 0.83.0 (`@earendil-works/pi-coding-agent`) | `~/.local/bin/pi` |
| Feynman | 0.3.10 | `~/.local/bin/feynman` → `~/.local/share/feynman/feynman-0.3.10-linux-x64/` |

All three are pinned. Bump them via the `build.args` block in `compose.yml`
(`FEYNMAN_VERSION`, `PI_VERSION`) and the `FROM` line in the `Dockerfile`.

**Node 22 is a hard floor.** Pi's installer preflight rejects anything below
`22.19.0`, and the npm package declares `engines: {"node": ">=22.19.0"}`.
The 20.x line will not work.

The container runs as non-root `agent` (uid/gid 1000).

---

## Layout and persistence

| Path in container | Volume | Contents |
|---|---|---|
| `/home/agent/workspace` | bind → `./workspace` | your research files |
| `/home/agent/.feynman` | `feynman-config` | Feynman's Pi config root: `agent/auth.json`, `agent/settings.json`, `agent/models.json`, `sessions/`, `memory/`, `orgs/`, `npm-global/` |
| `/home/agent/.ahub` | `ahub-config` | alphaXiv ("Alpha Hub") auth token |
| `/home/agent/.pi` | `pi-config` | only used if you run bare `pi` instead of `feynman` |

**`~/.local/share/feynman` is deliberately not a volume.** That is the
application install directory (versioned bundle dirs), not data. Mounting a
named volume there would shadow the freshly built bundle on rebuild, leaving
the `~/.local/bin/feynman` shim pointing at a bundle path that exists only in
the image.

Verified: setting a default model, then `docker compose down` (no `-v`), then a
fresh `docker compose run` — the setting and a marker file in `~/.ahub` both
survived.

---

## OpenRouter auth

**The `OPENROUTER_API_KEY` environment variable is sufficient on its own.**
You do not need to write an `auth.json`.

Verified by comparison:

```
# without the env var
$ feynman model list
⚠ No authenticated Pi models are currently available.

# with the env var
$ feynman doctor
authenticated providers: 1
authenticated models: 279
default model: openrouter/openai/gpt-5.5
default model valid: yes
```

A real non-interactive inference call through the container also succeeds:

```bash
docker compose run --rm --entrypoint bash pi-feynman -c \
  'pi -p --no-tools --model openrouter/openai/gpt-4.1-mini "Reply with exactly: PI_OK"'
# → PI_OK
```

To change the default model:

```bash
docker compose run --rm --entrypoint feynman pi-feynman model set openrouter/deepseek/deepseek-v4-flash
```

The default model is baked into the image at build time via the
`DEFAULT_MODEL` build arg (`openrouter/deepseek/deepseek-v4-flash`). Because
Docker seeds a named volume from the image only when that volume is empty, this
applies to **fresh installs only** — an existing `feynman-config` volume keeps
whatever it already had, and rebuilding will not change it. Use
`feynman model set` for those.

`model set` validates against the authenticated model list, which needs an
OpenRouter key present. There is none at build time, so the Dockerfile supplies
a throwaway placeholder for that one step; it is never used for a request.

**Pi's OpenRouter catalogue lags OpenRouter's live model list.** `feynman model
set` rejects IDs that are absent from it with *"Model not available in Pi auth
storage"*, even when OpenRouter serves them. Verified rejected at 0.3.10:
`deepseek/deepseek-v4-pro`, `deepseek/deepseek-v4-flash-0731`,
`google/gemini-3.1-pro-preview`. `deepseek/deepseek-v4-flash` is accepted.
`pi update --models` reports a timeout in-container and does not add them.

### Troubleshooting

- `echo $OPENROUTER_API_KEY` inside the container should print your key.
  Compose trims surrounding whitespace in `.env` values, so a stray space after
  the `=` is harmless.
- Check the key itself is live, independently of Pi/Feynman:
  ```bash
  docker compose run --rm --entrypoint bash pi-feynman -c \
    'curl -s https://openrouter.ai/api/v1/key -H "Authorization: Bearer $OPENROUTER_API_KEY"'
  ```
  A valid key returns your limit/usage as JSON.

---

## alphaXiv login

Use the dedicated one-off service:

```bash
docker compose run --rm alphaxiv-login
```

It prints an auth URL (there is no browser in the container, and `xdg-open` is
absent, so it falls back to printing). Open the URL on the host, complete the
OAuth flow, and the command returns.

Then verify:

```bash
docker compose run --rm --entrypoint feynman pi-feynman alpha status
```

### Why `alpha login` needs its own service

This is the least obvious part of the whole setup.

`feynman alpha login` starts an OAuth callback listener bound to
**`127.0.0.1:9876` inside the container**, and hands alphaXiv a `redirect_uri`
of `http://127.0.0.1:9876/callback`. Your host browser resolves that to the
*host's* loopback, where nothing is listening — so the flow hangs at
`Waiting for login...` forever.

Publishing the port does **not** fix it. `-p 9876:9876` forwards to the
container's `eth0` address; it never reaches the container's loopback
interface. Confirmed by reading `/proc/net/tcp` inside the container:
`0100007F:2694` — that is `127.0.0.1:9876`, loopback-bound.

The `alphaxiv-login` service therefore uses `network_mode: host`, which makes
the container's `127.0.0.1` and the host's `127.0.0.1` the same interface. Only
this one-off command needs it; the research container itself stays on the
default bridge network. The service sits behind a `login` compose profile so it
is excluded from `docker compose up`.

---

## End-to-end smoke test

A deliberately narrow `lit` query was run against the real stack:

```bash
docker compose run --rm -T --entrypoint feynman pi-feynman \
  lit "sparse autoencoder feature absorption - limit to 3 papers, write a short summary to ./sae-absorption-summary.md and stop"
```

Result:

- Completed with no auth or tool errors.
- Produced `workspace/sae-absorption-summary.md` (7.1 KB) plus `notes/`,
  `outputs/` and `papers/` subdirectories, **immediately visible on the host**
  and owned by the host user — the bind mount is bidirectional and uid-correct.
- Content was substantive and cited real arXiv IDs (e.g. 2409.14507,
  "A is for Absorption", which is a genuine paper on this topic).
- **Cost: $0.80**, measured as the delta in OpenRouter's `usage` field before
  and after. Note this was a *partial* run — it was stopped early once the
  output file proved the mount worked, so a completed narrow review would cost
  somewhat more.

`feynman alpha search` was also verified end-to-end against the persisted
alphaXiv credential, returning real arXiv results. It uses no LLM tokens.

---

## Isolation

Verified from inside a running container:

| Check | Result |
|---|---|
| `/home/marcus`, `/home/marcus/Projects` | not found |
| `/var/run/docker.sock` | not present |
| `touch /etc/should-fail` | `Permission denied` |
| `sudo` | not installed |
| host files reachable | only via `~/workspace` |

`/etc/passwd` is readable, but it is the *container's own* — normal container
filesystem isolation, exactly as the plan expected.

This is a sanity check that the mount scope is what was intended. It is **not**
a security boundary against a malicious model: the container has unrestricted
outbound network access, and anything written to `./workspace` is written to
the host.

### Bind-mount ownership

The Dockerfile renames the base image's `node` user to `agent` rather than
creating a second user, so the container user keeps uid/gid 1000. If your host
uid/gid differs from 1000, set `USER_UID`/`USER_GID` in `compose.yml`'s
`build.args` to match `id -u` / `id -g`, or `agent` will not be able to write
to `./workspace` despite the mount succeeding.

Verified: a file written from inside the container appears on the host owned by
the host user, and vice versa.

---

## Terminal rendering

`compose.yml` sets `TERM=xterm-256color`, `COLORTERM=truecolor` and
`LANG=C.UTF-8` in addition to `tty: true` / `stdin_open: true`. Without these,
Pi's TUI silently degrades — colors, cursor control and Unicode box-drawing
characters break, in ways that are easy not to notice because the UI stays
nominally usable.

`LANG=C.UTF-8` specifically drives Pi's `terminal_supports_unicode` check.

---

## Deviations from the plan

The original `plan.md` was written before the tools were inspected. Corrections:

1. **`README-container.md`, `Dockerfile` and `docker-compose.yml` did not
   exist.** Only `compose.yml` was present. They were written from scratch.

2. **Feynman's config root is `~/.feynman/agent/`, not `~/.pi/`.** The plan's
   Step 4 said to create `~/.pi/agent/auth.json`. Feynman runs Pi with its own
   isolated config root, so `~/.pi` is used only if you invoke bare `pi`.

3. **No `auth.json` is needed at all.** The plan proposed
   `"key": "!echo $OPENROUTER_API_KEY"`. Feynman reads `OPENROUTER_API_KEY`
   from the environment directly — verified by the presence/absence comparison
   above.

4. **Node floor is 22.19.0, not 20.19.0.** The plan quoted Feynman's older
   requirement. Pi's is higher and binding.

5. **`~/.ahub` needed a volume.** The plan's volume list covered `~/.pi` and
   `~/.feynman` only. alphaXiv stores its token in `~/.ahub`, so without the
   extra volume the login would not have survived a restart — the exact failure
   the plan's Step 6 was designed to catch.

6. **`~/.local/share/feynman` should *not* be a volume.** The starting
   `compose.yml` mounted `feynman-share` there. That is the application install
   directory; see [Layout and persistence](#layout-and-persistence).

7. **`alpha login` needs host networking.** Not anticipated by the plan. See
   [Why `alpha login` needs its own service](#why-alpha-login-needs-its-own-service).

8. **Pi is installed via `npm` rather than the `pi.dev/install.sh` installer.**
   The installer works fine non-interactively (it detects the absence of a TTY
   and defaults to install), but it always resolves "latest" and offers no
   version argument, which defeats the pinning required by Step 9. The
   Dockerfile reproduces exactly what the installer would run —
   `npm install -g --ignore-scripts --min-release-age=0 --prefix ~/.local` —
   with an explicit version. Feynman still uses its official installer, because
   that one *does* take a version argument and verifies the download's SHA-256
   against the release's `SHA256SUMS`.

9. **Feynman's latest release is 0.3.10, not the `0.2.35` mentioned in the
   plan.**

10. **Default `CMD` is `feynman`, not `pi`.** The plan's definition of done
    said `docker compose run --rm pi-feynman` should drop into "a working `pi`
    session". It drops into Feynman instead, which *is* a Pi session — Feynman
    is a research shell built on Pi and runs it with its own config root. Bare
    Pi remains available via `--entrypoint pi`.

11. **Documentation was split for a non-technical audience.** The container is
    intended for academics with no coding background, so the user-facing
    material lives in [README.md](README.md) plus per-platform Docker guides in
    [docs/](docs/). This file is the engineering record.

---

## Known issues

- **`feynman setup` is an interactive wizard** and is not run during the build.
  It is not required — `feynman doctor` reports a healthy runtime without it.

- **First launch on a fresh `feynman-config` volume is slower.** Feynman
  populates `~/.feynman/npm-global` with its core Pi packages
  (`alpha-hub`, `pi-subagents`, `pi-btw`, `pi-docparser`, `pi-web-access`,
  `pi-otel`). These are symlinked out of the version-pinned bundle rather than
  downloaded, so it is fast, but it does happen on first run rather than at
  build time.

- **Stale package symlinks after a version bump: self-healing, verified.**
  `~/.feynman/npm-global/lib/node_modules/*` are symlinks into the
  version-pinned bundle path (e.g. `feynman-0.3.10-linux-x64`). Because
  `~/.feynman` is a persistent volume, bumping `FEYNMAN_VERSION` would leave
  those symlinks pointing at a bundle the new image no longer contains. This
  was tested deliberately by repointing a symlink at a nonexistent bundle and
  by deleting `npm-global` outright — Feynman repaired both on the next run. No
  manual `docker compose down -v` is required after an upgrade.

- **`pandoc` and the browser preview runtime are missing** (`feynman doctor`
  reports both). They are not installed in the image. Anything depending on
  document conversion or `feynman serve`'s preview will not work until they are
  added. `feynman setup preview` installs them but needs a writable location
  and was not exercised here.

- **Web search is unconfigured.** `feynman doctor` reports no Exa, Perplexity or
  Gemini API key. Pi's web-access will try each in turn and find none.
  Configure with `feynman search set <auto|perplexity|exa|gemini> [api-key]` —
  the config lands in `~/.feynman/web-search.json`, inside the persistent
  volume.

- **`feynman serve` is not exposed.** No ports are published for the main
  service. Add a `ports:` entry if you want the local research workbench.

- **The `alphaxiv-login` service shares the host network namespace** for the
  duration of the login command. If that is unacceptable in your environment,
  the alternative is to complete the OAuth flow in a browser, copy the full
  `http://127.0.0.1:9876/callback?code=...` URL out of the address bar, and
  `curl` it from inside a normally-networked container.
