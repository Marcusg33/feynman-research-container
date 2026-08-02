# Getting the files

← [Back to the README](../README.md)

You need a copy of this project on your computer. There are two ways.

|  | Download a ZIP | Install Git |
|---|---|---|
| Extra software needed | None | Git |
| Time | 2 minutes | 10 minutes |
| Getting updates later | Download again | One command |

**If you are not sure, download the ZIP.** It is the simpler option and nothing
about the container needs Git.

---

## Option 1 — Download a ZIP (recommended)

### Step 1: Download

Go to the project page:

<https://github.com/Marcusg33/feynman-research-container>

Click the green **Code** button, then **Download ZIP**.

The file lands in your `Downloads` folder as
`feynman-research-container-main.zip`.

> Prefer a numbered, stable version? Use the
> [Releases page](https://github.com/Marcusg33/feynman-research-container/releases)
> and download the **Source code (zip)** from the most recent release instead.
> Releases do not change once published, so you always get the same thing.

### Step 2: Unzip it somewhere sensible

Put it where you can find it again — `Documents` is a good choice.

**Windows**
1. Open your `Downloads` folder.
2. Right-click the ZIP → **Extract All...**
3. Change the destination to `C:\Users\<your name>\Documents`
4. Click **Extract**.

**macOS**
1. Open your `Downloads` folder.
2. Double-click the ZIP — it unzips beside itself.
3. Drag the resulting folder into `Documents`.

**Linux**
1. Open your `Downloads` folder in the file manager.
2. Right-click the ZIP → **Extract Here**.
3. Move the resulting folder to your home folder.

Or, in a terminal:

```bash
cd ~
unzip ~/Downloads/feynman-research-container-main.zip
```

### Step 3: Check you have the right folder

You will end up with a folder named something like
`feynman-research-container-main`. Open it — it should contain `Dockerfile`,
`compose.yml` and a `docs` folder.

> **Watch out for the double folder.** Unzipping sometimes produces
> `feynman-research-container-main` containing another
> `feynman-research-container-main`. The one you want is whichever directly
> contains `Dockerfile`.

### Updating later

Download the ZIP again and replace the folder. **Copy your `.env` file and your
`workspace` folder across first** — those hold your key and your research.

---

## Option 2 — Install Git (optional)

Git makes updates a single command and is worth it if you expect to update
often. It is not required.

### Windows

1. Go to <https://git-scm.com/download/win> — the download starts automatically.
2. Run the installer. **Accept every default** by clicking *Next* throughout;
   the defaults are fine.
3. Close and reopen PowerShell, then check it worked:

```powershell
git --version
```

You should see something like `git version 2.51.0.windows.1`.

### macOS

Open Terminal and type:

```bash
git --version
```

If Git is already installed you will see a version. If not, macOS offers to
install the developer command line tools — click **Install** and wait. That is
all you need.

### Linux

**Ubuntu / Debian / Mint / Pop!_OS**
```bash
sudo apt update && sudo apt install -y git
```

**Fedora**
```bash
sudo dnf install -y git
```

Check it worked:

```bash
git --version
```

### Get the files

Navigate to where you want the folder, then clone:

```bash
cd ~/Documents
git clone https://github.com/Marcusg33/feynman-research-container.git
cd feynman-research-container
```

### Updating later

From inside the folder:

```bash
git pull
```

Your `.env` and `workspace` are left alone — both are excluded from version
control, so updating never overwrites your key or your research.

---

## Next step

Return to the [README](../README.md) and continue from **step 3, Set up your
accounts**.
