# Troubleshooting

← [Back to the README](../README.md)

## `docker: command not found` / `'docker' is not recognized`

Docker is not installed, or Docker Desktop is not running. Open Docker Desktop,
wait for the whale icon to turn green, then **close and reopen your terminal**.

## `Cannot connect to the Docker daemon`

Docker Desktop is not running. Start it. On Linux: `sudo systemctl start docker`.

## `set OPENROUTER_API_KEY in .env`

You have not created `.env`, or it still contains the placeholder. Redo step 4
of the [README](../README.md).

The file must be named exactly `.env` — not `.env.txt`. Windows Notepad adds
`.txt` silently. Check with `ls`, and rename if needed:

```powershell
Rename-Item .env.txt .env
```

## `no such file or directory`

You are in the wrong folder. Go back to the folder containing `compose.yml`
and check with `ls`.

## No models available / `authenticated providers: 0`

Your key is missing, wrong, or out of credit. Check your credit at
<https://openrouter.ai/credits>, then test the key itself:

```bash
docker compose run --rm --entrypoint bash pi-feynman -c 'curl -s https://openrouter.ai/api/v1/key -H "Authorization: Bearer $OPENROUTER_API_KEY"'
```

A working key returns your usage as JSON. An error means the key is wrong —
create a new one and update `.env`.

## alphaXiv login hangs at `Waiting for login...`

Open the printed address in a browser **on the same computer** running the
container. The sign-in redirects back to that machine, so opening it on your
phone or another computer will not complete.

If it is genuinely stuck, press **Ctrl+C** and run
`docker compose run --rm alphaxiv-login` again for a fresh address.

## The assistant can't see a file I put in `workspace`

Check the file is in the `workspace` folder *inside the container folder*, not
somewhere else with the same name. Confirm what it can see:

```bash
docker compose run --rm --entrypoint bash pi-feynman -c 'ls ~/workspace'
```

## It is spending more than expected

Set a hard credit limit on your key at <https://openrouter.ai/keys> — that caps
spending whatever happens. Then check you are on a good-value model, see
[Models and costs](models-and-costs.md), and keep queries narrow.

## Start over completely

This deletes **all** settings, logins and history — but not your `workspace`
files:

```bash
docker compose down -v
docker compose build --no-cache
```

Then redo the alphaXiv login (step 5 of the README).
