# FHIR IG Publisher Dev Container

**English** · [Deutsch](README.de.md)

[![Published IG](https://img.shields.io/badge/IG-published-blue)](https://gefyra.github.io/IGPublisherDevContainer/branches/main/)
[![License](https://img.shields.io/github/license/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/blob/main/LICENSE)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/Gefyra/igpublisher-devcontainer-image/pkgs/container/igpublisher-devcontainer-image)
[![GitHub issues](https://img.shields.io/github/issues/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/issues)
[![Dev Container](https://img.shields.io/badge/Dev%20Container-Ready-green)](https://code.visualstudio.com/docs/devcontainers/containers)
[![Codespaces](https://img.shields.io/badge/Codespaces-Ready-brightgreen)](https://github.com/features/codespaces)

A starting point for FHIR Implementation Guides. Create a repository from this template and you get an IG that builds, previews and publishes itself — with no Java, Ruby, Node or IG Publisher on your machine. SUSHI, the IG Publisher, Jekyll and `fhir-pkg-tool` live in a container that runs on Intel and Apple Silicon, in VS Code or entirely in the browser via Codespaces.

**New here?** [Quick start](#quick-start), then [Your first profile](#your-first-profile).
**Know your way around?** [Everyday workflow](#everyday-workflow) · [Publishing](#publishing) · [Reference](#reference)

---

## Quick start

### 1. Create your repository

This repository is a **GitHub template**. Click **"Use this template" → "Create a new repository"** ([direct link](https://github.com/Gefyra/IGPublisherDevContainer/generate)), pick a name, and you are done. Use the template rather than a fork.

### 2. Open it

**In the browser (nothing to install):** press the green **"Code"** button → **Codespaces** tab → **"Create codespace on main"**.

**Locally:** you need [Docker](https://www.docker.com/get-started), [VS Code](https://code.visualstudio.com/) and the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

```bash
git clone https://github.com/<owner>/<your-ig>.git
cd <your-ig>
code .
```

Then click **"Reopen in Container"**, or press `F1` and run `Dev Containers: Reopen in Container`. The first start downloads the image once.

### 3. Build and look at it

Press `F1` → `Tasks: Run Task` → **"IG Publisher: Full Build"** (or just `Cmd/Ctrl+Shift+B`). When it finishes, run the **"Serve IG Locally"** task; VS Code offers **"Open in Browser"** for the forwarded port.

### 4. Turn on publishing

In your new repository, go to **Settings → Pages** and set the source to the `gh-pages` branch. From then on every push publishes a preview — see [Publishing](#publishing).

## Your first profile

1. **Write FSH** in `input/fsh/`:

   ```fsh
   Profile: MyPatient
   Parent: Patient
   * name 1..* MS
   ```

2. **Compile it** — task **"SUSHI: Build FSH"**, or run `sushi`. The result lands in `fsh-generated/`.

3. **Declare dependencies** in `sushi-config.yaml` when you build on other IGs.

4. **Fetch and snapshot them** — task **"FHIR Package: Download and Snapshot Dependencies"**. This resolves the packages your profiles derive from.

5. **Build the IG** — task **"IG Publisher: Full Build"**. This takes a few minutes on the first run.

6. **Read the report.** `output/qa.html` lists every validation message. It is the file to check before sharing anything.

New to FHIR Shorthand? [FSH School](https://fshschool.org/) is the place to learn it.

## Everyday workflow

Run tasks with `F1` → `Tasks: Run Task`. The default build task is **"IG Publisher: Full Build"** on `Cmd/Ctrl+Shift+B`.

| Task | What it does |
|---|---|
| **SUSHI: Build FSH** | Compiles FSH into FHIR resources |
| **IG Publisher: Full Build** | Full IG build; runs SUSHI first |
| **FHIR Package: Download and Snapshot Dependencies** | Resolves the dependencies from `sushi-config.yaml` |
| **Update IG Publisher** | Fetches the current IG Publisher release |
| **Serve IG Locally** | Serves `output/` for preview |
| **Git: Commit & Push** | Stages everything, commits, and pushes the branch |
| **Download: IG Package** | Points at `output/full-ig.zip` |
| **Download: JSON Resources** | Packs `fsh-generated/resources/*.json` into a ZIP |

The tasks call commands the container image ships (`ig-update-publisher`, `ig-commit`, `ig-package`, `ig-json-resources`). That keeps `tasks.json` stable: when the logic behind them changes, it arrives with the next image and this file stays untouched.

**Git: Commit & Push** stages everything in one go, which is what makes it a single button. To pick individual files or read a diff before committing, use VS Code's **Source Control** panel instead — the task lists what it staged, but does not let you change it.

Prefer the terminal? `sushi`, `./_genonce.sh`, `fhir-pkg-tool --sushi-deps-file sushi-config.yaml` and `python3 -m http.server 8080` do the same jobs.

## Publishing

GitHub Actions builds the IG and publishes it to GitHub Pages. The site has three levels:

```
https://<owner>.github.io/<repo>/                    newest release
https://<owner>.github.io/<repo>/<version>/          archived releases
https://<owner>.github.io/<repo>/branches/<name>/    one preview per branch
```

**Branch previews** appear on every push to a branch, which lets you share work in progress or compare it against `main` without anyone building it themselves. The pipeline writes the URL into the run summary and comments it on the matching pull request.

**Releases** happen when you publish a GitHub release. The build then lands both at the site root, as the current version, and in the archive under its version number. The tag has to match the `version` in `sushi-config.yaml` — otherwise the run fails rather than publishing a build under a number it does not carry.

Worth knowing:

- Publishing happens on **push** and **release** only, not for pull requests from forks.
- The branch name is used verbatim as a path: `feature/x` becomes `branches/feature/x/`.
- Deleting a branch removes its preview, immediately and again in a weekly sweep. The "Clean up branch previews" workflow can also be started by hand via "Run workflow".
- **`full-ig.zip` is not published.** It changes wholesale on every build and nothing on the site links to it. The package tarballs (`package*.tgz`) do stay, so a consuming IG can point at a branch build or a released version.
- `gh-pages` is rewritten as a single root commit on every publish. Pages serves only the current tree, and keeping history would retain every past build's binaries forever.
- Pages needs a few minutes after the build before a change is visible.

## Staying up to date

On every start the container reports what you are building with:

```
IG Publisher 2.3.2 (from the image, 2026-08-14)
```

Once the jar is older than 14 days it adds a hint. There are two ways to update, and which one is right depends on what you need.

### Just the IG Publisher

Run the **"Update IG Publisher"** task. It fetches the current HL7 release immediately, no matter how old the image is and without a rebuild. This is the way when you are waiting on a fresh publisher fix.

### The whole image

This also brings SUSHI, `fhir-pkg-tool`, the extensions and the container logic up to date. The image is rebuilt automatically whenever HL7 publishes a new IG Publisher release, usually within 24 hours.

**Your container does not pick that up on its own.** `latest` is a moving tag: Docker keeps using the locally cached image until you explicitly pull it again.

| Environment | What to do |
|---|---|
| VS Code, local | `Dev Containers: Rebuild Container`; if nothing changes, **Rebuild Without Cache** |
| GitHub Codespaces | `Codespaces: Full Rebuild Container` |
| Command line | `docker pull ghcr.io/gefyra/igpublisher-devcontainer-image:latest`, then rebuild |

> [!IMPORTANT]
> **Stopping and starting is not enough.** A container — or Codespace — that was stopped and started again is the same container: `postCreateCommand` does not run and no image is pulled. Anyone who only ever stops and starts their Codespace works with the same publisher for months. A rebuild puts you back on the current one.

### Where the publisher jar lives

`input-cache/publisher.jar` is normally a **symlink** to the jar inside the image (`/opt/ig/publisher.jar`). That way it exists once instead of twice, and a rebuild moves you to the new image's version automatically.

The "Update IG Publisher" task replaces the link with a real file, which it has to: the image itself cannot be written to. You then use roughly 440 MB instead of 220 MB for a while. Once the image has caught up, the next rebuild swaps the copy back for the link and frees the space again.

## Reference

### What is in the container

| Tool | Purpose |
|---|---|
| [IG Publisher](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation) | Builds the Implementation Guide |
| [SUSHI](https://fshschool.org/docs/sushi/) | Compiles FHIR Shorthand into resources |
| `fhir-pkg-tool` | Downloads and snapshots dependencies |
| Java 21, Node 20, Ruby + Jekyll | Runtimes the publisher needs |
| `python3` | Local preview server |
| `zip` / `unzip`, `git`, `curl`, `sudo` | Everyday tools |

The image lives in [Gefyra/igpublisher-devcontainer-image](https://github.com/Gefyra/igpublisher-devcontainer-image). It carries not only the toolchain but also the devcontainer configuration itself — user, forwarded ports, lifecycle commands and the VS Code extensions all come from its `devcontainer.metadata` label, which is why `.devcontainer/devcontainer.json` here is only a few lines long.

### Project structure

```
.
├── .devcontainer/
│   └── devcontainer.json   # points at the prebuilt image; settings come from it
├── .github/workflows/      # build, publish, clean up previews
├── scripts/gh-pages.sh     # maintains the gh-pages branch
├── input/
│   ├── fsh/                # your FSH sources
│   └── pagecontent/        # narrative pages, Markdown
├── fsh-generated/          # SUSHI output (generated)
├── output/                 # IG Publisher output (generated)
├── input-cache/            # publisher jar and packages (generated)
├── ig.ini                  # IG Publisher configuration
└── sushi-config.yaml       # SUSHI configuration, dependencies, version
```

### VS Code extensions

Installed automatically, delivered by the image:

- **FHIR:** `gematikde.codfsh`, `fhir-shorthand.vscode-fsh`, `yannick-lagger.vscode-fhir-tools`
- **General:** `redhat.vscode-yaml`, `esbenp.prettier-vscode`, `yzhang.markdown-all-in-one`, `streetsidesoftware.code-spell-checker`, `mhutchie.git-graph`, `peakchen90.open-html-in-browser`

## Troubleshooting

### The container will not start

Make sure Docker is running, then try `Dev Containers: Rebuild Container`. The Docker logs usually say what went wrong.

### The build fails

`output/qa.html` holds the validation report and is the first place to look. Known, accepted messages belong in `input/ignoreWarnings.txt`. If the publisher itself looks like the problem, run the **"Update IG Publisher"** task.

### Port 8080 is taken

Dev Containers forwards ports rather than publishing them to Docker, so it depends on where the conflict is.

**On the host:** the container port stays 8080 while the local port may differ. If 8080 is taken locally, VS Code **silently** maps to a free port, because `requireLocalPort` defaults to `false`. Typing `localhost:8080` then reaches whatever else owns that port, making the IG look like it is missing.

When the server starts, VS Code shows a notification with the forwarded address and an **"Open in Browser"** button — the image asks for it by setting `onAutoForward: notify`. Use that button rather than typing the URL. Afterwards the address stays available in the **PORTS** panel under "Local Address". To find out who owns 8080:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN     # macOS/Linux
```

`Code Helper` means it is the dev container's own forward and all is well.

The silent remap is the devcontainer spec's default, not a setting of this project, and it is convenient: several IG containers can run at once without fighting over the port. To be told instead, add this to your `devcontainer.json`:

```json
"portsAttributes": { "8080": { "requireLocalPort": true } }
```

VS Code then reports when 8080 cannot be used locally. The option cannot free the port; it only makes sure you hear about it.

**Inside the container:** if something already holds the port there, the task stops with `Address already in use`. Point the "Serve IG Locally" task at another port in `.vscode/tasks.json`, for example `python3 -m http.server 8081`.

In Codespaces the question does not arise — forwarding goes through the Codespaces proxy, not through local ports.

### "Update IG Publisher" fails with `curl: (23)`

The task still calls `_updatePublisher.sh` directly instead of `ig-update-publisher`. `curl` then writes through the symlink into the read-only image. Nothing is lost; set the task's command in `.vscode/tasks.json` to:

```json
"command": "ig-update-publisher"
```

### The publisher is old even after a rebuild

A plain rebuild may reuse the cached image. Use **Rebuild Without Cache**, or **Full Rebuild Container** in Codespaces — or run the **"Update IG Publisher"** task for an immediately current publisher.

### `input-cache/publisher.jar` is a dead link on the host

Expected: the link points at a path inside the container. It resolves inside the dev container, and `input-cache/` is in `.gitignore` anyway.

## Contributing

Issues and pull requests are welcome.

## License

[Apache License 2.0](LICENSE)

## Links

- [FSH School](https://fshschool.org/) — learning FHIR Shorthand
- [SUSHI documentation](https://fshschool.org/docs/sushi/)
- [IG Publisher documentation](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation)
- [FHIR specification](https://hl7.org/fhir/)
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) · [GitHub Codespaces](https://github.com/features/codespaces)
- [FHIR Chat](https://chat.fhir.org/) — where to ask FHIR questions
