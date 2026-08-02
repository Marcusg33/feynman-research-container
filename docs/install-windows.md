# Installing Docker on Windows

You only ever do this once. Budget about 20 minutes, most of which is waiting
for downloads and one restart.

Docker is the program that runs the research container. You will never need to
understand how it works — you just need it installed and running.

---

## Before you start

Check your Windows version. Press the **Windows key**, type `winver`, press
**Enter**. A small window appears.

You need **Windows 10 version 2004 or later**, or **Windows 11**. Almost any
computer bought or updated in the last few years qualifies. If yours is older,
Windows Update will bring it up to date.

Close the `winver` window.

---

## Step 1 — Install Docker Desktop

1. Go to <https://www.docker.com/products/docker-desktop/>
2. Click **Download for Windows**. You will get a file called
   `Docker Desktop Installer.exe`, usually in your `Downloads` folder.
3. Double-click that file.
4. When it asks about configuration, leave **"Use WSL 2 instead of Hyper-V"**
   ticked. This is the default and it is the one you want.
5. Click **OK** and wait. This takes several minutes.
6. When it finishes, it will ask you to **restart your computer**. Do that now
   — Docker will not work properly until you do.

> **"WSL 2" — what is that?**
> A piece of Windows that lets it run Linux programs. Docker needs it. The
> installer sets it up for you. You do not need to do anything with it.

---

## Step 2 — Start Docker Desktop

After the restart:

1. Press the **Windows key**, type `Docker Desktop`, press **Enter**.
2. The first launch takes a minute or two. Accept the service agreement.
3. It may offer to sign in or create a Docker account. **You can skip this** —
   click *Continue without signing in* if offered. An account is not needed.
4. Wait until the whale icon in the bottom-left of the Docker Desktop window
   is **green** and says **Engine running**.

> **Important:** Docker Desktop must be running whenever you use the research
> container. If you restart your computer, start Docker Desktop again first.
> You can set it to start automatically in Docker Desktop's
> **Settings → General → Start Docker Desktop when you sign in**.

---

## Step 3 — Check it worked

You need a terminal. On Windows this is called **PowerShell**.

1. Press the **Windows key**, type `PowerShell`, press **Enter**.
2. A blue or black window opens with a text prompt. This is where you type
   commands.
3. Type this and press **Enter**:

```powershell
docker --version
```

You should see something like:

```
Docker version 29.6.2, build dfc4efb1e2
```

The exact numbers will differ — that is fine. Now type:

```powershell
docker compose version
```

You should see something like:

```
Docker Compose version 5.3.1
```

**If both commands printed a version, Docker is installed correctly.**

If you instead see `docker : The term 'docker' is not recognized...`, Docker
Desktop is either not installed or not running. Go back to Step 2, make sure
the engine is green, then **close and reopen PowerShell** and try again.

---

## Step 4 — Choose where the container's folder lives

The research container gives you one shared folder called `workspace`. Files
you put there are visible to the agent, and files the agent creates appear
there for you.

Pick somewhere easy to find, for example `Documents`. In PowerShell:

```powershell
cd ~\Documents
```

This is where you will put the container files in the next step.

> **Performance note:** On Windows, keep the project inside your normal user
> folders (`Documents`, `Desktop`). Do not put it on a network drive or an
> external USB disk — Docker gets very slow.

---

## Common problems

**"Docker Desktop requires a newer WSL kernel version"**
Open PowerShell and run:
```powershell
wsl --update
```
Then restart Docker Desktop.

**"Hardware assisted virtualization is not enabled"**
Virtualisation is switched off in your computer's BIOS. This is a setting on
the computer itself, not in Windows. Restart, press the key shown at startup
to enter BIOS/UEFI setup (often `F2`, `F10`, or `Delete`), and enable
*Virtualization*, *Intel VT-x*, or *AMD-V*. If you are unsure, this is a
reasonable point to ask your IT support — it is a common, routine request.

**Docker Desktop won't start / hangs on "Starting..."**
Quit Docker Desktop entirely (right-click the whale icon in the system tray →
*Quit Docker Desktop*), then start it again. If it still hangs, restart the
computer.

**Company laptop, no administrator rights**
Docker Desktop needs administrator rights to install. You will need your IT
department to install it. Send them this page.

---

## Next step

Docker is ready. Return to the [main README](../README.md) and continue from
**Step 2 — Get the container files**.
