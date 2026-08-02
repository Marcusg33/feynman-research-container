# Installing Docker on Linux

You only ever do this once. Budget about 15 minutes.

Docker is the program that runs the research container. You will never need to
understand how it works — you just need it installed and running.

> **Which instructions do I follow?**
> This page covers **Ubuntu / Debian / Linux Mint / Pop!_OS** (the most common
> choices in academia) and **Fedora**. If you use Arch, openSUSE or something
> else, use your distribution's own Docker packages — the checks in Step 3 are
> the same everywhere.

---

## Important: do not install `docker.io` from your distribution

Many Linux distributions ship an old, repackaged Docker under names like
`docker.io` or `docker`. Those versions are usually too old to include
`docker compose`, which this container needs. Follow the steps below instead —
they install Docker's own current packages.

If you already installed `docker.io`, remove it first:

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

(Fedora: `sudo dnf remove docker docker-common docker-engine`)

---

## Step 1 — Install Docker Engine

Open a terminal. On most desktops: **Ctrl + Alt + T**.

### Ubuntu / Debian / Mint / Pop!_OS

Copy and paste this whole block, press **Enter**, and type your password if
asked. It adds Docker's official software source:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

> On **Debian** (not Ubuntu/Mint/Pop!_OS), replace both occurrences of
> `linux/ubuntu` above with `linux/debian`.

Then install Docker itself:

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

### Fedora

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

---

## Step 2 — Let yourself run Docker without `sudo`

By default only the administrator can use Docker. Add yourself to the `docker`
group so you don't have to type `sudo` every time:

```bash
sudo usermod -aG docker $USER
```

**You must now log out and log back in** for this to take effect. A full
restart also works. Nothing below will work until you do.

> **Is this safe?** Being in the `docker` group is equivalent to administrator
> access on the machine. On your own workstation this is normal and expected.
> On a shared or institutionally managed server, check with whoever
> administers it first.

---

## Step 3 — Check it worked

After logging back in, open a terminal and type:

```bash
docker --version
```

You should see something like:

```
Docker version 29.6.2, build dfc4efb1e2
```

The exact numbers will differ — that is fine. Now type:

```bash
docker compose version
```

You should see something like:

```
Docker Compose version 5.3.1
```

Finally, confirm you can actually run something:

```bash
docker run --rm hello-world
```

This downloads a tiny test image and prints
`Hello from Docker!`. **If you see that message, Docker is installed
correctly.**

---

## Step 4 — Choose where the container's folder lives

The research container gives you one shared folder called `workspace`. Files
you put there are visible to the agent, and files the agent creates appear
there for you.

Pick somewhere easy to find:

```bash
mkdir -p ~/research && cd ~/research
```

This is where you will put the container files in the next step.

---

## A note about file ownership

This is the one Linux-specific detail that matters.

The container runs as a user with ID `1000`, and the shared `workspace` folder
has to be owned by a matching ID on your machine — otherwise the agent cannot
save files. On a normal single-user Linux install you are already ID `1000` and
there is nothing to do.

Check yours:

```bash
id -u
```

**If this printed `1000`, you are done — ignore the rest of this section.**

If it printed anything else (common on multi-user or institutional machines),
open `compose.yml` in a text editor after downloading the container files, find
these two lines:

```yaml
        USER_UID: "1000"
        USER_GID: "1000"
```

and change them to the numbers from `id -u` and `id -g`. Then build as normal.
The [main README](../README.md) explains where `compose.yml` lives.

---

## Common problems

**`permission denied while trying to connect to the Docker daemon socket`**
You skipped Step 2, or have not logged out and back in since. Do both.

**`Cannot connect to the Docker daemon. Is the docker daemon running?`**
Start it:
```bash
sudo systemctl enable --now docker
```

**`docker: 'compose' is not a docker command`**
You have an old Docker (probably `docker.io`). Remove it and follow Step 1
properly — see the warning at the top of this page.

**Running inside WSL on Windows**
Don't follow this page. Install Docker Desktop for Windows instead — see
[install-windows.md](install-windows.md).

---

## Next step

Docker is ready. Return to the [main README](../README.md) and continue from
**Step 2 — Get the container files**.
