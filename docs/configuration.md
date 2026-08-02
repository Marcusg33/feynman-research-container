# Configuration

← [Back to the README](../README.md)

Most people never need this page. The container works as shipped.

---

## Changing the model

See **[Models and costs](models-and-costs.md)**.

---

## Where your things are kept

| What | Where |
|---|---|
| Your files | `workspace/` — in this folder, on your computer |
| Your OpenRouter key | `.env` — in this folder, on your computer |
| Model choice, history, notes | Docker storage (`feynman-config`) |
| alphaXiv login | Docker storage (`ahub-config`) |

Settings and logins survive rebuilding the container. You do not need to manage
them.

---

## Enabling general web search

By default the assistant searches papers, not the general web. Adding web
search needs a key from Exa, Perplexity or Google Gemini:

```bash
docker compose run --rm --entrypoint feynman pi-feynman search set exa YOUR-EXA-API-KEY
```

Swap `exa` for `perplexity` or `gemini` as appropriate. Check with:

```bash
docker compose run --rm --entrypoint feynman pi-feynman search status
```

This is optional — the paper workflows do not need it.

---

## Updating

Fetch the latest published container:

```bash
docker compose pull
```

Or rebuild it yourself using the versions pinned in `compose.yml`:

```bash
docker compose build --no-cache
```

Either way your settings, logins and `workspace` files are untouched.

### Prebuilt vs building it yourself

The container is published to the GitHub Container Registry for both Intel and
Apple Silicon:

```
ghcr.io/marcusg33/feynman-research-container:latest
```

`docker compose pull` fetches it — faster, and it cannot fail partway through a
build. `docker compose build` builds locally and reuses the same tag, which is
what you want if you have edited the `Dockerfile` or changed the pinned
versions below.

To pin to a specific published version rather than `latest`, change the
`image:` line at the top of `compose.yml`, e.g.
`ghcr.io/marcusg33/feynman-research-container:1.0`.

---

## Changing versions

`compose.yml` pins exact versions so the container behaves the same every time:

```yaml
        FEYNMAN_VERSION: "0.3.10"
        PI_VERSION: "0.83.0"
        DEFAULT_MODEL: "openrouter/deepseek/deepseek-v4-flash"
```

Edit and rebuild to move to a newer release. If it misbehaves, put the old
numbers back — this is why they are pinned.

`DEFAULT_MODEL` only applies to **new** installs. An existing setup keeps its
current model; change that with `feynman model set` instead.

The Node.js version is pinned separately in the `Dockerfile`. **Do not lower
it** — Feynman requires Node 22.19.0 or newer.

---

## File ownership on Linux

Only relevant if `id -u` returns something other than `1000`. See
[install-linux.md](install-linux.md#a-note-about-file-ownership).

---

## Uninstalling

```bash
docker compose down -v
docker image rm pi-feynman:local
```

Then delete this folder. Copy anything you want to keep out of `workspace`
first.
