# Using the assistant

← [Back to the README](../README.md)

## Starting and stopping

```bash
docker compose run --rm pi-feynman
```

Type in plain English and press Enter. To leave, type `/exit` or press
**Ctrl+C** twice.

Closing the session throws the container away but keeps your settings, your
logins and everything in `workspace`.

---

## The `workspace` folder

`workspace` is shared between your computer and the assistant, and it is the
only shared folder.

- Put a PDF in it → the assistant can read it.
- The assistant writes a summary → it appears there as a normal file you can
  open in Word or Preview.

You can leave the folder open in Finder or Explorer and watch files appear.

---

## Research workflows

Type a slash command followed by your topic:

```
/lit protein folding prediction since AlphaFold3
```

| Command | What it does |
|---|---|
| `/lit <topic>` | Literature review on a topic, lab, or author |
| `/deepresearch <topic>` | Thorough investigation → research brief with citations |
| `/compare <topic>` | Compares sources into a matrix of agreements and disagreements |
| `/summarize <paper>` | Condenses a paper or document |
| `/review <paper>` | Critical review of a paper |
| `/audit <paper>` | Checks a paper's claims against its public code |
| `/replicate <paper>` | Works through reproducing a paper's results |
| `/recipe <task>` | Finds implementable ML training recipes backed by papers |
| `/draft <topic>` | Turns findings into a paper-style draft |
| `/autoresearch <idea>` | Bounded experiment loop — tries hypotheses, keeps what works |
| `/watch <topic>` | Tracks new work on a topic |
| `/log` | Records notes into the lab notebook |
| `/jobs` | Shows running background work |

> **Start small.** Name a specific question and a paper limit. A broad review
> can run for many minutes and cost real money — see
> [Models and costs](models-and-costs.md).

---

## Running one command without opening the prompt

Any workflow works as a single command. Note there is no leading slash:

```bash
docker compose run --rm --entrypoint feynman pi-feynman lit "sparse autoencoders in interpretability"
```

---

## Looking up papers

These use no AI model, so they cost nothing:

```bash
# Search for papers
docker compose run --rm --entrypoint feynman pi-feynman alpha search "graph neural networks for molecules"

# Fetch one paper by arXiv ID, DOI, PubMed ID or title
docker compose run --rm --entrypoint feynman pi-feynman paper 2409.14507
```
