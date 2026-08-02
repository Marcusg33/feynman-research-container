# Installing Docker on macOS

You only ever do this once. Budget about 15 minutes, most of which is waiting
for a download.

Docker is the program that runs the research container. You will never need to
understand how it works — you just need it installed and running.

---

## Before you start

You need to know whether your Mac has an **Apple Silicon** chip (M1, M2, M3,
M4...) or an **Intel** chip. Docker has a different download for each.

1. Click the  **Apple menu** in the top-left corner of the screen.
2. Click **About This Mac**.
3. Look at the line labelled **Chip** or **Processor**:
   - **Chip: Apple M1/M2/M3/M4...** → you have **Apple Silicon**
   - **Processor: Intel Core...** → you have **Intel**

Remember which one. Close the window.

You also need **macOS 13 (Ventura) or later**. The same *About This Mac* window
shows your macOS version. If yours is older, update via
**System Settings → General → Software Update**.

---

## Step 1 — Install Docker Desktop

1. Go to <https://www.docker.com/products/docker-desktop/>
2. Click the download button matching what you found above:
   - **Download for Mac – Apple Silicon**, or
   - **Download for Mac – Intel Chip**

   Getting this wrong is the single most common mistake. Double-check.
3. Open the downloaded `Docker.dmg` file (usually in `Downloads`).
4. A window appears showing a Docker whale icon and an Applications folder.
   **Drag the whale onto the Applications folder.**
5. Wait for the copy to finish, then eject the disk image (click the ⏏ next to
   *Docker* in a Finder sidebar).

---

## Step 2 — Start Docker Desktop

1. Open **Applications** and double-click **Docker**.
2. macOS will warn that Docker was downloaded from the internet. Click **Open**.
3. Docker will ask for your **Mac password** to install a helper tool. This is
   expected — type your normal login password.
4. Accept the service agreement.
5. It may offer to sign in or create a Docker account. **You can skip this** —
   click *Continue without signing in* if offered. An account is not needed.
6. Wait until the whale icon in the bottom-left of the Docker Desktop window is
   **green** and says **Engine running**.

> **Important:** Docker Desktop must be running whenever you use the research
> container. You will see a small whale icon in the menu bar at the top of the
> screen when it is. If you restart your Mac, start Docker Desktop again first.
> To have it start automatically, tick
> **Settings → General → Start Docker Desktop when you sign in**.

---

## Step 3 — Check it worked

You need a terminal. On macOS this is called **Terminal**.

1. Press **Command (⌘) + Space** to open Spotlight.
2. Type `Terminal` and press **Enter**.
3. A window opens with a text prompt. This is where you type commands.
4. Type this and press **Enter**:

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

**If both commands printed a version, Docker is installed correctly.**

If you instead see `command not found: docker`, Docker Desktop is either not
installed or not running. Go back to Step 2, make sure the engine is green,
then **close and reopen Terminal** and try again.

---

## Step 4 — Choose where the container's folder lives

The research container gives you one shared folder called `workspace`. Files
you put there are visible to the agent, and files the agent creates appear
there for you.

Pick somewhere easy to find, for example `Documents`. In Terminal:

```bash
cd ~/Documents
```

This is where you will put the container files in the next step.

> **Note on iCloud:** If your `Documents` folder is synced to iCloud Drive,
> consider using a different location such as `~/research` instead. iCloud can
> move files out from under running programs, which confuses the agent. Create
> one with:
> ```bash
> mkdir -p ~/research && cd ~/research
> ```

---

## Common problems

**"Docker Desktop is damaged and can't be opened"**
You almost certainly downloaded the wrong chip version. Delete Docker from
Applications, recheck Apple Silicon vs Intel in *About This Mac*, and download
again.

**Docker Desktop won't start / hangs on "Starting..."**
Click the whale icon in the menu bar → *Quit Docker Desktop*, then reopen it
from Applications. If it still hangs, restart the Mac.

**"You need to grant permission"**
macOS sometimes asks for permission to access `Documents` or `Desktop` the
first time the container reads them. Click **OK** / **Allow**.

**Managed university Mac, no administrator rights**
Docker Desktop needs your Mac password to install a helper tool. If you do not
have administrator rights, your IT department will need to install it. Send
them this page.

---

## Next step

Docker is ready. Return to the [main README](../README.md) and continue from
**Step 2 — Get the container files**.
