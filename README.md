# Feynman Research Container

An AI research assistant for academic work. It searches papers, runs literature
reviews, compares sources and drafts write-ups — inside a sandbox that can only
see one folder on your computer.

**No coding experience needed.** You copy and paste a few commands.

> **What it can and cannot see.** The assistant can only read and write the
> `workspace` folder. It cannot see your Desktop, email, or other documents. It
> *can* access the internet, so treat anything you put in `workspace` as
> material you are happy to send to AI providers and paper databases.
>
> It can also misread papers and cite things inaccurately. **Check its
> citations before relying on them.**

---

## Setup

Six steps, done once. Takes about 30 minutes, mostly waiting for downloads.

### 1. Install Docker

Docker is the sandbox. Pick your system:

- 🪟 **[Windows](docs/install-windows.md)**
- 🍎 **[macOS](docs/install-macos.md)**
- 🐧 **[Linux](docs/install-linux.md)**

Don't continue until Docker is installed and running.

### 2. Get the files

Put this folder somewhere easy to find, like `Documents`. Then open a terminal
**in that folder**:

- **Windows:** open the folder, click the address bar, type `powershell`, Enter
- **macOS:** right-click the folder → *Services* → *New Terminal at Folder*
- **Linux:** right-click inside the folder → *Open in Terminal*

Type `ls` — you should see `Dockerfile`, `compose.yml` and `docs`.
**Every command below is typed here.**

### 3. Set up your accounts

Follow **[Accounts and keys](docs/accounts-and-keys.md)** — you need a paid
OpenRouter account (start with $10) and a free alphaXiv account.

Come back with your OpenRouter key, starting `sk-or-v1-`.

### 4. Add your key

**Windows:** `Copy-Item .env.example .env` then `notepad .env`
**macOS / Linux:** `cp .env.example .env` then `nano .env`

Replace `sk-or-v1-replace-me` with your real key. Keep the
`OPENROUTER_API_KEY=` part, no quotes or spaces. Save and close (in `nano`:
**Ctrl+O**, Enter, **Ctrl+X**).

Never share this file.

### 5. Build and sign in

```bash
docker compose build
```

Takes 2–5 minutes the first time. Then connect alphaXiv:

```bash
docker compose run --rm alphaxiv-login
```

Copy the printed web address into your browser, sign in, and the command
finishes. Done once only.

### 6. Check it works

```bash
docker compose run --rm --entrypoint feynman pi-feynman doctor
```

You want to see `alphaXiv auth: ok`, `default model valid: yes` and
`pi runtime: ok`. (`pandoc: missing` is expected and harmless.)

---

## Using it

Start the assistant:

```bash
docker compose run --rm pi-feynman
```

Type in plain English and press Enter. Type `/exit` to leave.

**The `workspace` folder is shared with your computer.** Put a PDF there and
the assistant can read it; anything it writes appears there as a normal file.
Nothing else is shared.

Type a slash command followed by a topic to run a research workflow:

```
/lit protein folding prediction since AlphaFold3
```

| Command | What it does |
|---|---|
| `/lit` | Literature review on a topic, lab or author |
| `/deepresearch` | Thorough investigation → research brief with citations |
| `/compare` | Compares sources, showing agreements and disagreements |
| `/summarize` | Condenses a paper |
| `/review` | Critical review of a paper |
| `/draft` | Turns findings into a paper-style draft |

**[All workflows and more usage →](docs/usage.md)**

> **Start small.** Name a specific question and a paper limit. A narrow review
> costs a penny or two on the default model; a sprawling one costs real money.

---

## Cost

The container defaults to a good-value model, so typical use is cheap — a
narrow literature review costs **around $0.01–0.03**.

Choosing an expensive model instead can multiply that by 50x or more, so this
is the one setting worth understanding.

**Check what you are actually spending at <https://openrouter.ai/activity>.**
Real costs are usually lower than published per-token prices suggest, because
repeated content is cached at a large discount.

**[Which model to use, and what each costs →](docs/models-and-costs.md)**

---

## More

- **[Usage in depth](docs/usage.md)** — all workflows, running single commands
- **[Models and costs](docs/models-and-costs.md)** — best value models, pricing
- **[Configuration](docs/configuration.md)** — changing models, web search, versions
- **[Troubleshooting](docs/troubleshooting.md)** — when something goes wrong
- **[Accounts and keys](docs/accounts-and-keys.md)** — OpenRouter and alphaXiv setup
- **[Technical notes](README-container.md)** — how the image is built (for developers)
