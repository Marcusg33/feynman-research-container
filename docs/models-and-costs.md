# Models and costs

← [Back to the README](../README.md)

The model is the part that does the thinking. **Which one you pick changes your
bill by 50x or more** for identical work — it is the single most important
setting.

You do not have to do anything: the container already defaults to
`deepseek/deepseek-v4-flash`, one of the best-value options available.

---

## Check your real spending

Published per-token prices overstate what you actually pay, because repeated
content (the system prompt, the paper you are discussing) is **cached** and
billed at roughly a tenth of the normal rate. This is automatic.

Two practical consequences:

- One long session is much cheaper than several short ones covering the same
  ground.
- The figures below are estimates. **Your actual spending is always at
  <https://openrouter.ai/activity>** — check there, not here.

---

## Best value models — as of 2 August 2026

Ranked by capability per pound, not by raw capability. Every ID listed is
verified to work with `feynman model set`.

*Cost* is one narrow literature review (roughly 200,000 tokens read, 20,000
written), assuming a warm cache. *Index* is the
[Artificial Analysis Intelligence Index](https://artificialanalysis.ai/leaderboards/models),
a composite benchmark score; blank means not separately published.

| # | Model | Index | Cost | Why |
|---|---|---|---|---|
| **1** | `deepseek/deepseek-v4-flash` | **50** | **~$0.01** | The default, and the standout. Near-top-tier scores at a fraction of frontier pricing, 1M-token context. |
| **2** | `z-ai/glm-5.2` | **51** | ~$0.04 | Highest-scoring open-weight model. Use when the default struggles. |
| **3** | `google/gemini-3.1-flash-lite` | — | ~$0.04 | Very fast, 1M context, major vendor. Good for bulk searching. |
| **4** | `z-ai/glm-4.7` | — | ~$0.05 | Solid mid-tier all-rounder. |
| **5** | `moonshotai/kimi-k2.5` | 47 | ~$0.08 | Strong reasoning; leads published research-specific benchmarks. |
| **6** | `x-ai/grok-4.3` | — | ~$0.10 | 1M context. More headroom without frontier pricing. |
| **7** | `qwen/qwen3.7-flash` | — | ~$0.004 | Cheapest still-usable option, for high-volume low-stakes work. |

If a task comes out weak, move **down** this list one step at a time rather
than jumping to the premium tier.

---

## The premium tier

The most capable models available — and 15–70x more expensive, for work that is
often indistinguishable on research tasks.

| Model | Index | Cost |
|---|---|---|
| `anthropic/claude-sonnet-4.5` | — | ~$0.41 |
| `anthropic/claude-opus-5` | 60.7 | ~$0.69 |
| `openai/gpt-5.5` | — | ~$0.79 |

Claude Opus 5 tops the intelligence index, but at ~$0.69 a review against
~$0.01 you could run seventy reviews on the default model for the same money.

Caching also helps this tier proportionally *less*: their high output prices
dominate the bill, and output is never cached.

Reserve these for final drafting of something that matters, if at all.

---

## Changing model

```bash
docker compose run --rm --entrypoint feynman pi-feynman model set openrouter/z-ai/glm-5.2
```

The setting persists. Check the current one with `... pi-feynman doctor`.

To see everything available:

```bash
docker compose run --rm --entrypoint feynman pi-feynman model list
```

> **Some real OpenRouter IDs are rejected.** Feynman ships a model list that
> lags OpenRouter's, so IDs like `deepseek-v4-pro` and `gemini-3.1-pro-preview`
> fail with *"Model not available in Pi auth storage"* even though OpenRouter
> serves them. Use `model list` to see what is accepted. (DeepSeek V4 Flash
> scores higher than V4 Pro anyway — 50 against 44 — and costs less.)

---

## Sources

Prices from [OpenRouter](https://openrouter.ai/models). Rankings from the
[Artificial Analysis leaderboard](https://artificialanalysis.ai/leaderboards/models),
[Intelligence Index, Aug 2026](https://benchlm.ai/benchmarks/artificialanalysis),
[DeepSeek V4 analysis](https://artificialanalysis.ai/models/deepseek-v4-pro),
[research-task leaderboard](https://llm-stats.com/leaderboards/best-ai-for-research) and
[long-context leaderboard](https://llm-stats.com/leaderboards/best-ai-for-long-context).

Prices change often — treat this page as a starting point, not gospel.
