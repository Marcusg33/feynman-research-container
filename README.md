# Feynman Research Container

A self-contained AI research assistant for academic work. It reads papers,
runs literature reviews, compares sources, checks claims against code, and
drafts write-ups — and it does all of that inside a sealed box that can only
see one folder on your computer.

**You do not need to know how to code to use this.** These instructions assume
no programming background. You will type a handful of commands, copied and
pasted exactly as written.

---

## Contents

- [What this actually is](#what-this-actually-is)
- [Installation and setup](#installation-and-setup)
- [Usage](#usage)
- [Configuration](#configuration)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)
- [Uninstalling](#uninstalling)

---

## What this actually is

Three things are bundled together:

- **[Feynman](https://feynman.is)** — a research assistant with built-in
  workflows for literature reviews, source comparison, paper auditing and
  drafting.
- **[Pi](https://pi.dev)** — the underlying agent engine Feynman runs on. You
  will rarely interact with it directly.
- **Docker** — a sandbox. Everything above runs inside it, isolated from the
  rest of your computer.

### Why the sandbox matters

The assistant can create, edit and delete files. Inside this container it can
only do that in **one folder — `workspace`**. It cannot see your Desktop, your
email, your other documents, or anything else on your machine. That was
verified, not assumed:

| Attempted from inside the container | Result |
|---|---|
| Read your home folder | Not found |
| Read your other project folders | Not found |
| Write outside its own folders | Permission denied |
| Gain administrator rights | `sudo` not installed |

The one thing it **can** do freely is access the internet — that is how it
fetches papers. So treat what you put in `workspace` as material you are
comfortable sending to AI model providers and paper databases. Do not put
unpublished sensitive data, personal data, or anything under a confidentiality
agreement in there.

### A realistic expectation

This is a capable research assistant, not an oracle. It can misread papers,
overstate confidence, and occasionally cite things inaccurately. **Check its
citations before you rely on them.** Used well it is a very fast research
assistant; used unquestioningly it will eventually embarrass you.

---

## Installation and setup

Five steps. The first three are one-time only.

### Step 1 — Install Docker

Pick your operating system:

- 🪟 **[Installing Docker on Windows](docs/install-windows.md)**
- 🍎 **[Installing Docker on macOS](docs/install-macos.md)**
- 🐧 **[Installing Docker on Linux](docs/install-linux.md)**

Each guide ends by returning you here. **Do not continue until Docker is
installed and running.**

### Step 2 — Get the container files

Put the container folder somewhere you can find again — `Documents` is fine.

If you were given a `.zip` file, unzip it there. If you were given a link to a
code repository, download it as a ZIP and unzip it, or use `git clone` if you
know how.

You should end up with a folder containing at least these:

```
Dockerfile
compose.yml
.env.example
README.md
docs/
workspace/
```

Now open a terminal **in that folder**:

- **Windows:** open the folder in File Explorer, click the address bar, type
  `powershell`, press **Enter**.
- **macOS:** right-click the folder → *Services* → *New Terminal at Folder*.
  (If that option is missing, enable it in
  **System Settings → Keyboard → Keyboard Shortcuts → Services → Files and Folders**.)
- **Linux:** right-click inside the folder → *Open in Terminal*.

Check you are in the right place — this should list the files above:

```bash
ls
```

*(On Windows PowerShell, `ls` works too.)*

**Every command from here on is typed in this terminal, in this folder.**

### Step 3 — Set up your accounts

Read **[Accounts and keys](docs/accounts-and-keys.md)**. It walks through
creating an OpenRouter account, adding credit, and generating an API key, plus
creating a free alphaXiv account.

Come back with your OpenRouter key — a long string starting `sk-or-v1-`.

### Step 4 — Put your key into the container

There is a template file called `.env.example`. Make a copy of it called
`.env`:

**Windows (PowerShell):**
```powershell
Copy-Item .env.example .env
notepad .env
```

**macOS / Linux:**
```bash
cp .env.example .env
nano .env
```

The file contains one line:

```
OPENROUTER_API_KEY=sk-or-v1-replace-me
```

Replace `sk-or-v1-replace-me` with your real key, so it looks like:

```
OPENROUTER_API_KEY=sk-or-v1-a1b2c3d4e5f6...
```

Keep the `OPENROUTER_API_KEY=` part. Do not add quotes or spaces.

Save and close:
- **Notepad:** *File → Save*, then close the window.
- **nano:** press **Ctrl+O**, **Enter**, then **Ctrl+X**.

> `.env` stays on your computer and is excluded from version control. Never
> share it.

### Step 5 — Build the container and sign in

Build it. **This takes 2–5 minutes the first time** and downloads a few hundred
megabytes. It is a one-time cost — later builds take seconds.

```bash
docker compose build
```

You will see a lot of scrolling text. That is normal. It has worked when you
see something ending in `naming to docker.io/library/pi-feynman:local`.

Now connect your free alphaXiv account:

```bash
docker compose run --rm alphaxiv-login
```

This prints a long web address starting `https://api.alphaxiv.org/...`, and
waits.

1. **Copy that entire address** and paste it into your web browser.
2. Sign in to alphaXiv and approve the request.
3. Return to the terminal — it will print
   `Logged in to alphaXiv as <your name>` and finish.

You only ever do this once. The login is remembered.

> It may also print `xdg-open: not found`. That is expected and harmless —
> there is no browser inside the container, which is why it gives you the
> address to open yourself.

### Step 6 — Check everything works

```bash
docker compose run --rm --entrypoint feynman pi-feynman doctor
```

Look for these lines:

```
alphaXiv auth: ok
default model valid: yes
authenticated providers: 1
pi runtime: ok
```

**If you see those, you are ready.** (It will also report `pandoc: missing` and
`browser preview runtime: missing` — both are expected and neither is needed
for normal use.)

---

## Usage

### Starting the assistant

```bash
docker compose run --rm pi-feynman
```

This drops you into the Feynman prompt. Type in plain English and press
**Enter**. To leave, type `/exit` or press **Ctrl+C** twice.

### The `workspace` folder

The `workspace` folder inside the container folder is **shared with your
computer**. This is the only place files move between the two.

- Put a PDF in `workspace` on your computer → the assistant can read it.
- The assistant writes a summary → it appears in `workspace` on your computer,
  as a normal file you can open in Word, Preview, or anything else.

You can have the folder open in Finder/Explorer while the assistant runs and
watch files appear.

### Research workflows

Feynman ships with purpose-built workflows. Inside the prompt, type a slash
command followed by your topic:

| Command | What it does |
|---|---|
| `/lit <topic>` | Literature review on a topic, lab, or author |
| `/deepresearch <topic>` | Thorough, source-heavy investigation → research brief with citations |
| `/compare <topic>` | Compares sources, producing a matrix of agreements and disagreements |
| `/summarize <paper>` | Condenses a paper or document |
| `/review <paper>` | Critical review of a paper |
| `/audit <paper>` | Checks a paper's claims against its public codebase |
| `/replicate <paper>` | Works through reproducing a paper's results |
| `/recipe <task>` | Finds implementable ML training recipes backed by papers |
| `/draft <topic>` | Turns findings into a paper-style draft with sections and claims |
| `/autoresearch <idea>` | Bounded experiment loop — tries hypotheses, keeps what works |
| `/watch <topic>` | Tracks new work on a topic |
| `/log` | Records notes into the lab notebook |
| `/jobs` | Shows running background work |

For example:

```
/lit protein folding prediction since AlphaFold3
```

> **Keep the first one small.** A broad review can run for many minutes and
> cost several dollars. Start narrow — name a specific question and a paper
> limit — and see what you get. A narrow 3-paper review measured **~$0.80**.

### Running a workflow without opening the prompt

Any workflow can be run directly as a single command:

```bash
docker compose run --rm --entrypoint feynman pi-feynman lit "sparse autoencoders in interpretability"
```

Note it is `lit` here, with no leading slash.

### Working with specific papers

These do not use AI models, so they cost nothing:

```bash
# Search for papers
docker compose run --rm --entrypoint feynman pi-feynman alpha search "graph neural networks for molecules"

# Fetch a specific paper by arXiv ID, DOI, PubMed ID or title
docker compose run --rm --entrypoint feynman pi-feynman paper 2409.14507
```

### Ending a session

Type `/exit`, or press **Ctrl+C** twice. Because of the `--rm` in the command,
the container is discarded — but your settings, your logins and everything in
`workspace` are kept.

---

## Configuration

### Choosing a model (the main cost lever)

The model does the actual thinking, and **which model you pick changes your bill
by 50x or more** for identical work. This is the single most important setting.

Set one like this:

```bash
docker compose run --rm --entrypoint feynman pi-feynman model set openrouter/deepseek/deepseek-v4-flash
```

The setting persists across restarts. Check the current one with
`... pi-feynman doctor`.

> `feynman model list` shows Feynman's own curated catalogue. It is not the
> full list — any model ID that OpenRouter supports can be set, whether or not
> it appears there.

### Best value models — as of 2 August 2026

Ranked by **capability per pound spent**, not by raw capability.

*"Cost per review"* below is one narrow literature review — roughly 200,000
tokens read and 20,000 written. It is calculated from OpenRouter's published
per-token prices. The Claude Sonnet 4.5 figure is validated against a real
measured run of this container, which came to $0.80 against a $0.90 estimate.

*"Index"* is the [Artificial Analysis Intelligence Index](https://artificialanalysis.ai/leaderboards/models),
a composite benchmark score. Blank means not separately published.

Every ID below is verified to be accepted by `feynman model set`.

| # | Model | Index | Cost per review | Why |
|---|---|---|---|---|
| **1** | `deepseek/deepseek-v4-flash` | **50** | **~$0.03** | The standout, and this container's default. Near-top-tier benchmark scores at roughly 1/30th the cost of Claude Sonnet, with a 1M-token context window. Hard to justify anything else as a daily driver. |
| **2** | `z-ai/glm-5.2` | **51** | ~$0.11 | Highest-scoring open-weight model on the index. Still under a fifth of frontier pricing, 1M context. Pick this when Flash struggles. |
| **3** | `moonshotai/kimi-k2.5` | 47 | ~$0.17 | Strong reasoning; the Kimi family leads published *research*-specific benchmarks. |
| **4** | `z-ai/glm-4.7` | — | ~$0.12 | Solid mid-tier all-rounder. |
| **5** | `google/gemini-3.1-flash-lite` | — | ~$0.08 | 1M context, very fast, from a major vendor. Good for bulk searching and triage. |
| **6** | `qwen/qwen3.7-flash` | — | ~$0.01 | The cheapest thing here that is still genuinely usable. For high-volume, low-stakes summarising. |
| **7** | `x-ai/grok-4.3` | — | ~$0.30 | 1M context. A reasonable step up when you want more headroom but not frontier pricing. |

**This container already defaults to `deepseek/deepseek-v4-flash`** — you do not
need to do anything to get it. If a particular task comes out weak, move up the
list rather than jumping straight to the premium tier.

> **Some real OpenRouter model IDs will be rejected.** Pi ships a curated
> catalogue that lags OpenRouter's live list, so IDs such as
> `deepseek-v4-pro`, `deepseek-v4-flash-0731` and `gemini-3.1-pro-preview`
> fail with *"Model not available in Pi auth storage"* even though OpenRouter
> serves them. Run `feynman model list` to see what is actually accepted.
> Note that DeepSeek V4 Flash scores **higher** than V4 Pro on the intelligence
> index (50 vs 44) and costs less, so this is rarely a real loss.

### The premium tier — and why it usually isn't worth it

These are genuinely the most capable models available. They are also **15–80x
more expensive** than the top of the list above, for work that is often
indistinguishable on research tasks.

| Model | Index | Cost per review |
|---|---|---|
| `anthropic/claude-sonnet-4.5` | — | ~$0.90 |
| `anthropic/claude-opus-5` | 60.7 | ~$1.50 |
| `openai/gpt-5.5` | — | ~$1.60 |

Claude Opus 5 does top the overall intelligence index — but at ~$1.50 per
review against ~$0.03, you can run **fifty** DeepSeek V4 Flash reviews for the
price of one. For literature searching, summarising and comparison,
that trade is very rarely worth making. Reserve the premium tier for final
drafting of something that matters, if at all.

> **A practical strategy:** use a cheap model for searching, triage and
> summarising — which is most of the work — and switch up only for final
> synthesis. Switching takes one command.

### Prices change — check them yourself

These figures were accurate on **2 August 2026**. Model prices move often, and
new models appear constantly. Current prices for every model are always at
<https://openrouter.ai/models>, sortable by price.

Sources for the rankings above:
[Artificial Analysis leaderboard](https://artificialanalysis.ai/leaderboards/models) ·
[Intelligence Index, Aug 2026](https://benchlm.ai/benchmarks/artificialanalysis) ·
[DeepSeek V4 analysis](https://artificialanalysis.ai/models/deepseek-v4-pro) ·
[Research-task leaderboard](https://llm-stats.com/leaderboards/best-ai-for-research) ·
[Long-context leaderboard](https://llm-stats.com/leaderboards/best-ai-for-long-context) ·
[GLM-5.2 / DeepSeek V4 / Kimi comparison](https://tech-insider.org/glm-5-2-vs-deepseek-v4-vs-kimi-k2-2026/)

### Checking what you have spent

<https://openrouter.ai/activity>, or from the terminal:

```bash
docker compose run --rm --entrypoint bash pi-feynman -c 'curl -s https://openrouter.ai/api/v1/key -H "Authorization: Bearer $OPENROUTER_API_KEY"'
```

Look for `usage` (spent so far) and `limit_remaining` (left on the key).

### Where your settings live

Settings, logins and session history are kept in **Docker named volumes** —
storage that survives the container being deleted and rebuilt. You do not need
to manage them.

| What | Where |
|---|---|
| Your files | `workspace/` — in the container folder, on your computer |
| Your OpenRouter key | `.env` — in the container folder, on your computer |
| Model choice, session history, notes | Docker volume `feynman-config` |
| alphaXiv login | Docker volume `ahub-config` |

Verified: settings and the alphaXiv login both survive a full
`docker compose down` and rebuild.

### Optional: enable general web search

By default Feynman searches papers, not the general web. To add web search you
need a key from one of three providers, then:

```bash
docker compose run --rm --entrypoint feynman pi-feynman search set exa YOUR-EXA-API-KEY
```

Replace `exa` with `perplexity` or `gemini` as appropriate. Check with:

```bash
docker compose run --rm --entrypoint feynman pi-feynman search status
```

This is entirely optional — the paper workflows do not need it.

### Changing which versions are installed

`compose.yml` pins exact versions so the container behaves identically every
time it is rebuilt:

```yaml
        FEYNMAN_VERSION: "0.3.10"
        PI_VERSION: "0.83.0"
```

To move to a newer release, edit those numbers and run `docker compose build`
again. If a new version misbehaves, put the old numbers back and rebuild —
this is why they are pinned.

The Node.js version is pinned separately in the `Dockerfile`
(`FROM node:22.23.2-bookworm-slim`). **Do not lower it** — Pi requires Node
22.19.0 or newer.

### Advanced: file ownership on Linux

Covered in [install-linux.md](docs/install-linux.md#a-note-about-file-ownership).
Only relevant if `id -u` gives something other than `1000`.

---

## Updating

```bash
docker compose build --no-cache
```

This rebuilds from scratch using the versions pinned in `compose.yml`. Your
settings, logins and `workspace` files are untouched.

---

## Troubleshooting

### `docker: command not found` / `'docker' is not recognized`

Docker is not installed, or Docker Desktop is not running. Open Docker Desktop
and wait for the whale to turn green, then **close and reopen your terminal**.

### `Cannot connect to the Docker daemon`

Docker Desktop is not running. Start it. On Linux: `sudo systemctl start docker`.

### `set OPENROUTER_API_KEY in .env`

You have not created `.env`, or it still contains the placeholder. Redo
[Step 4](#step-4--put-your-key-into-the-container). The file must be named
exactly `.env` — not `.env.txt`. On Windows, Notepad adds `.txt` silently;
check with `ls` and rename if needed:

```powershell
Rename-Item .env.txt .env
```

### `no such file or directory` when running a command

You are in the wrong folder. Navigate back to the folder containing
`compose.yml` and check with `ls`.

### The assistant says it has no models / `authenticated providers: 0`

Your key is missing, wrong, or out of credit. Check credit at
<https://openrouter.ai/credits>, then verify the key itself:

```bash
docker compose run --rm --entrypoint bash pi-feynman -c 'curl -s https://openrouter.ai/api/v1/key -H "Authorization: Bearer $OPENROUTER_API_KEY"'
```

A working key returns JSON with your usage. An error means the key is wrong —
create a new one and update `.env`.

### alphaXiv login hangs at `Waiting for login...`

You must open the printed address in a browser **on the same computer** the
container is running on. The sign-in redirects back to that machine; opening it
on your phone or another computer will not complete.

If it is genuinely stuck, press **Ctrl+C** and run
`docker compose run --rm alphaxiv-login` again for a fresh address.

### The assistant can't see a file I put in `workspace`

Check the file is in the `workspace` folder *inside the container folder*, not
somewhere else with the same name. Confirm:

```bash
docker compose run --rm --entrypoint bash pi-feynman -c 'ls ~/workspace'
```

Whatever that lists is exactly what the assistant can see.

### It is spending more than expected

Set a hard credit limit on the key at <https://openrouter.ai/keys> — that caps
spending no matter what. Then switch to a cheaper model, and keep queries
narrow and specific.

### Something is deeply broken and I want to start over

This deletes **all** settings, logins and session history — but not your
`workspace` files:

```bash
docker compose down -v
docker compose build --no-cache
```

Then redo the alphaXiv login (Step 5).

---

## Uninstalling

```bash
docker compose down -v
docker image rm pi-feynman:local
```

Then delete the container folder. Your `workspace` files are inside it — copy
anything you want to keep out first.

---

## For developers and system administrators

**[README-container.md](README-container.md)** documents the build itself: how
the image is constructed, exactly what was verified and how, every deviation
from the original design, and the known issues and their evidence.
