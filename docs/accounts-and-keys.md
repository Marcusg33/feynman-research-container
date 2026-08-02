# Accounts and keys

The container needs two accounts. One costs money (a few pounds/dollars goes a
long way); the other is free.

| Account | Cost | What it does | Required? |
|---|---|---|---|
| **OpenRouter** | Pay-as-you-go | Provides the AI models that do the reading and writing | **Yes** |
| **alphaXiv** | Free | Paper search, full-text access, annotations | Strongly recommended |

---

## OpenRouter — the AI models

### Why this and not ChatGPT/Claude directly?

OpenRouter is a single account that gives access to models from many companies
(Anthropic, OpenAI, Google, Meta and others). You pay per use rather than a
monthly subscription, and you can switch models without new accounts. For
research work where you might want a cheap model for searching and an expensive
one for writing, this is much simpler.

### Step 1 — Create the account

1. Go to <https://openrouter.ai>
2. Click **Sign In** (top right), then create an account. You can sign in with
   Google, GitHub, or an email address.

### Step 2 — Add credit

**Nothing works until you add credit.** OpenRouter is pay-as-you-go — there is
no free allowance for the models this container uses by default.

1. Click your avatar (top right) → **Credits**
2. Click **Add Credits**
3. **$10 is a sensible starting amount.** See
   [What things cost](#what-things-cost) below.

### Step 3 — Create an API key

An "API key" is a long password that lets the container use your account. It
looks like `sk-or-v1-` followed by a lot of random characters.

1. Click your avatar (top right) → **Keys**
2. Click **Create Key**
3. Give it a name you'll recognise, e.g. `feynman-container`
4. **Optional but recommended:** set a *credit limit* on the key, e.g. `10`.
   This caps what this key can ever spend, no matter what goes wrong. You can
   raise it later.
5. Click **Create**
6. **Copy the key now.** OpenRouter shows it exactly once. If you lose it, you
   cannot look it up — you just create a new one and delete the old.

Paste it somewhere safe temporarily (a password manager, or just leave the tab
open) — you will put it into a file in the next step of the
[main README](../README.md).

### Keeping the key safe

- The key is **as sensitive as a credit card number**. Anyone who has it can
  spend your credit.
- It goes in a file called `.env`, which is deliberately excluded from version
  control and should never be emailed, pasted into a chat, or committed.
- If you think it has leaked: go to **Keys**, delete it, and create a new one.
  This takes ten seconds and costs nothing.
- Never put the key in `compose.yml`, in the `Dockerfile`, or in any file you
  share.

### What things cost

| Action | Cost |
|---|---|
| A one-line test question | less than $0.001 |
| Searching alphaXiv for papers | $0 (no AI model involved) |
| Narrow literature review, on a **good-value** model | **~$0.01** |
| Narrow literature review, on a **premium** model | **~$0.40–0.80** |
| A full `deepresearch` across dozens of sources | dollars, not cents |

Note the gap between the middle two rows: **that is the same piece of work.**
The only difference is which model ran it.

Real costs are usually lower than published per-token prices suggest, because
repeated content is cached at a large discount. One long session is cheaper
than several short ones covering the same ground.

Always check what you are actually spending at
<https://openrouter.ai/activity>.

The big cost driver is the **model**, not the container — the choice can change
your bill by 50x. Before running anything substantial, read
**[Models and costs](models-and-costs.md)**. The container already defaults to
a good-value model, so usually there is nothing to do — but it is the
difference between $10 lasting a week and lasting most of a year.

Check your spending any time at <https://openrouter.ai/activity>.

---

## alphaXiv — paper search and access

alphaXiv is a free service layered on arXiv that provides paper search,
full-text retrieval, and annotations. Feynman uses it for the literature
workflows.

### Create the account

1. Go to <https://www.alphaxiv.org>
2. Sign up — free, no payment details required.

That is all you do on the website. You connect it to the container with a
single command (`docker compose run --rm alphaxiv-login`), which is covered in
**Step 5** of the [main README](../README.md).

### What if I skip it?

Feynman still runs, and the AI models still work. But the paper search, paper
retrieval, and annotation features will be unavailable, which is most of the
point of the tool. It is free and takes two minutes — do it.

---

## Optional: web search

Feynman can also search the general web (not just papers), but this needs a
third-party key from Exa, Perplexity, or Google Gemini. It is **off by default
and entirely optional** — the paper workflows do not need it.

If you want it, see the **Configuration** section of the
[main README](../README.md#optional-enable-general-web-search).

---

## Next step

Return to the [main README](../README.md).
