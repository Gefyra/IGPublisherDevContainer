# FHIR IG Publisher Dev Container

[![License](https://img.shields.io/github/license/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/blob/main/LICENSE)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/Gefyra/igpublisher-devcontainer-image/pkgs/container/igpublisher-devcontainer-image)
[![GitHub issues](https://img.shields.io/github/issues/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/issues)
[![Dev Container](https://img.shields.io/badge/Dev%20Container-Ready-green)](https://code.visualstudio.com/docs/devcontainers/containers)
[![Codespaces](https://img.shields.io/badge/Codespaces-Ready-brightgreen)](https://github.com/features/codespaces)

A ready-to-use development container for building FHIR Implementation Guides (IGs) with SUSHI and the IG Publisher.

## 🚀 Features

- **Pre-configured Environment**: Comes with SUSHI (FSH compiler) and IG Publisher pre-installed
- **Multi-Platform Support**: Works on both AMD64 and ARM64 architectures (including Apple Silicon)
- **VS Code Integration**: Optimized for Visual Studio Code with Dev Containers
- **GitHub Codespaces Ready**: Start developing in seconds directly in your browser
- **Automated Tasks**: Pre-configured VS Code tasks for common IG development workflows

## 📋 Prerequisites

Choose one of the following options:

### Option 1: Local Development
- [Docker](https://www.docker.com/get-started) installed on your machine
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Option 2: GitHub Codespaces
- A GitHub account (no local installation required!)

## 🏃 Getting Started

### Using Dev Containers (Local)

1. Clone this repository:
   ```bash
   git clone https://github.com/Gefyra/IGPublisherDevContainer.git
   cd IGPublisherDevContainer
   ```

2. Open the project in VS Code:
   ```bash
   code .
   ```

3. When prompted, click **"Reopen in Container"** or run the command:
   - Press `F1` or `Cmd+Shift+P` (Mac) / `Ctrl+Shift+P` (Windows/Linux)
   - Type: `Dev Containers: Reopen in Container`

4. Wait for the container to build and start (first time may take a few minutes)

### Using GitHub Codespaces

1. **Fork this repository** to your GitHub account (click the "Fork" button at the top right)
2. Navigate to your forked repository on GitHub
3. Click the green **"Code"** button
4. Select the **"Codespaces"** tab
5. Click **"Create codespace on main"**
6. Wait for your Codespace to start (automatic setup)

## 🛠️ Available VS Code Tasks

This project includes pre-configured tasks to streamline your IG development workflow. Access them via:
- Press `F1` or `Cmd+Shift+P` (Mac) / `Ctrl+Shift+P` (Windows/Linux)
- Type: `Tasks: Run Task`

### Available Tasks:

| Task | Description |
|------|-------------|
| **SUSHI: Build FSH** | Compiles FSH files to FHIR resources using SUSHI |
| **FHIR Package: Snapshot Dependencies** | Downloads and snapshots SUSHI dependencies defined in `sushi-config.yaml` |
| **IG Publisher: Full Build** | Runs the complete IG build process (depends on SUSHI build) |
| **Update IG Publisher** | Fetches the current IG Publisher release into `input-cache/` |
| **Serve IG Locally** | Starts a local HTTP server to preview the generated IG at `http://localhost:8080` |
| **Git: Commit Changes** | Stages everything and commits with a message you are prompted for |
| **Download: IG Package** | Points at `output/full-ig.zip` for download |
| **Download: JSON Resources** | Packs `fsh-generated/resources/*.json` into a ZIP for download |

Die Tasks rufen Kommandos auf, die das Container-Image mitbringt (`ig-update-publisher`, `ig-commit`, `ig-package`, `ig-json-resources`). Dadurch bleibt `tasks.json` stabil: ändert sich die Logik dahinter, kommt das mit dem nächsten Image, ohne dass diese Datei angefasst werden muss.

### Quick Build

The default build task is **"IG Publisher: Full Build"**. You can run it with:
- `Cmd+Shift+B` (Mac) / `Ctrl+Shift+B` (Windows/Linux)

## 📁 Project Structure

```
.
├── .devcontainer/          # Dev container configuration
│   └── devcontainer.json   # Points at the prebuilt image; settings come from it
├── input/                  # IG input files
│   ├── fsh/               # FSH (FHIR Shorthand) source files
│   └── pagecontent/       # Markdown content for IG pages
├── fsh-generated/         # Auto-generated FHIR resources (from SUSHI)
├── output/                # Generated IG output (HTML, JSON, etc.)
├── ig.ini                 # IG Publisher configuration
├── sushi-config.yaml      # SUSHI configuration
└── _genonce.sh           # Build script for IG generation
```

## 🔧 Tools Included

### SUSHI (FSH Compiler)
[SUSHI](https://fshschool.org/docs/sushi/) is the reference implementation for compiling FHIR Shorthand (FSH) into FHIR resources.

**Usage:**
```bash
sushi                    # Compile FSH files in current directory
sushi --version          # Check SUSHI version
sushi --help             # Show help
```

### IG Publisher
The [FHIR IG Publisher](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation) generates complete Implementation Guides from FHIR resources.

**Usage:**
```bash
./_genonce.sh            # Run full IG build
./_updatePublisher.sh    # Update IG Publisher
```

## 🎨 VS Code Extensions

The following extensions are automatically installed in the container:

- **FHIR Development**:
  - `gematikde.codfsh` - FSH language support
  - `fhir-shorthand.vscode-fsh` - FSH syntax highlighting
  - `yannick-lagger.vscode-fhir-tools` - FHIR development tools

- **General Development**:
  - `redhat.vscode-yaml` - YAML language support
  - `esbenp.prettier-vscode` - Code formatter
  - `yzhang.markdown-all-in-one` - Markdown support
  - `streetsidesoftware.code-spell-checker` - Spell checker
  - `mhutchie.git-graph` - Git visualization
  - `peakchen90.open-html-in-browser` - HTML preview

## 🔄 Container und Publisher aktualisieren

Beim Start meldet der Container, womit du baust:

```
IG Publisher 2.3.2 (aus dem Image, 14.08.2026)
```

Ist das Jar älter als 14 Tage, kommt ein Hinweis dazu. Zum Aktualisieren gibt es zwei Wege — welcher der richtige ist, hängt davon ab, was du brauchst.

### Nur den IG Publisher

Task **„Update IG Publisher"** ausführen. Holt sofort das aktuelle HL7-Release, unabhängig vom Alter des Images, ohne Rebuild. Der richtige Weg, wenn du auf einen frischen Publisher-Fix wartest.

### Das ganze Image

Bringt neben dem Publisher auch SUSHI, `fhir-pkg-tool`, Extensions und die Container-Logik auf Stand. Das Image wird automatisch neu gebaut, sobald HL7 ein neues Publisher-Release veröffentlicht (in der Regel innerhalb von 24 Stunden).

**Dein Container holt das nicht von allein.** `latest` ist ein bewegliches Tag: Docker verwendet weiter das lokal zwischengespeicherte Image, bis du es explizit neu ziehst.

| Umgebung | Vorgehen |
|---|---|
| VS Code lokal | `Dev Containers: Rebuild Container`; wenn sich nichts tut, **Rebuild Without Cache** |
| GitHub Codespaces | `Codespaces: Full Rebuild Container` |
| Kommandozeile | `docker pull ghcr.io/gefyra/igpublisher-devcontainer-image:latest`, danach neu bauen |

> [!IMPORTANT]
> **Stoppen und Starten reicht nicht.** Ein angehaltener und wieder gestarteter Container — oder Codespace — ist derselbe Container: `postCreateCommand` läuft dabei nicht, das Image wird nicht neu gezogen. Wer seinen Codespace monatelang nur stoppt und startet, arbeitet monatelang mit demselben Publisher. Nach einem Rebuild bist du automatisch wieder aktuell.

### Wo das Publisher-Jar liegt

`input-cache/publisher.jar` ist normalerweise ein **Symlink** auf das Jar im Image (`/opt/ig/publisher.jar`). Dadurch existiert es einmal statt zweimal, und ein Rebuild bringt dich automatisch auf die Version des neuen Images.

Der Task „Update IG Publisher" ersetzt den Link durch eine echte Datei — nötig, weil in das Image hinein nicht geschrieben werden kann. Danach belegst du vorübergehend ~440 MB statt ~220 MB. Sobald das Image aufgeholt hat, tauscht der nächste Rebuild die Kopie automatisch gegen den Link zurück und gibt den Platz wieder frei.

## 📖 Writing Your First IG

1. Edit FSH files in `input/fsh/`:
   ```fsh
   Profile: MyPatient
   Parent: Patient
   * name 1..* MS
   ```

2. Run SUSHI to compile:
   - Use task: **"SUSHI: Build FSH"**
   - Or run: `sushi`

3. Edit dependencies in `sushi-config.yaml` as needed.

4. Snapshot dependencies:
   - Use task: **"FHIR Package: Snapshot Dependencies"**
   - Or run: `fhir-pkg-tool --sushi-deps-file sushi-config.yaml`

5. Build the complete IG:
   - Use task: **"IG Publisher: Full Build"**
   - Or run: `./_genonce.sh`

6. Preview your IG:
   - Use task: **"Serve IG Locally"**
   - Open `http://localhost:8080` in your browser

## 🐛 Troubleshooting

### Container fails to start
- Ensure Docker is running
- Try rebuilding: `Dev Containers: Rebuild Container`
- Check Docker logs for errors

### Build errors
- Update IG Publisher: Run **"Update IG Publisher"** task
- Check `input/ignoreWarnings.txt` for known issues
- Review `output/qa.html` for validation issues

### Port 8080 ist belegt
Dev Containers veröffentlicht Ports nicht auf Docker-Ebene, sondern leitet sie weiter. Deshalb hängt es davon ab, wo der Konflikt sitzt:

- **Auf dem Host**: Hält dort schon eine andere Anwendung den Port, **meldet VS Code das nicht**. Der Browser zeigt dann unter `localhost:8080` stillschweigend die andere Anwendung statt des IG. Deshalb den IG immer über das **PORTS**-Panel öffnen (Rechtsklick → „Open in Browser"), nicht durch Eintippen von `localhost:8080` — dort steht die tatsächliche „Local Address". Wer nachsehen will, wem der Port gehört:

  ```bash
  lsof -nP -iTCP:8080 -sTCP:LISTEN     # macOS/Linux
  ```

  Steht dort `Code Helper`, ist es der Forward des Dev Containers und alles ist in Ordnung.
- **Im Container**: Belegt dort bereits etwas den Port, bricht der Task mit `Address already in use` ab. Dann in `.vscode/tasks.json` beim Task „Serve IG Locally" einen anderen Port setzen, z. B. `python3 -m http.server 8081`.

In Codespaces stellt sich die Frage nicht — die Weiterleitung läuft über den Codespaces-Proxy, nicht über lokale Ports.

### „Update IG Publisher" schlägt mit `curl: (23)` fehl
Das Projekt ruft `_updatePublisher.sh` noch direkt auf, statt den Task auf `ig-update-publisher` zeigen zu lassen. `curl` schreibt dann durch den Symlink in das schreibgeschützte Image. Es geht nichts verloren; in `.vscode/tasks.json` beim Task „Update IG Publisher" setzen:

```json
"command": "ig-update-publisher"
```

### Der Publisher ist trotz Rebuild alt
Ein einfacher Rebuild kann das zwischengespeicherte Image weiterverwenden. **Rebuild Without Cache** bzw. in Codespaces **Full Rebuild Container** verwenden — oder für einen sofort aktuellen Publisher den Task „Update IG Publisher".

### `input-cache/publisher.jar` ist auf dem Host ein toter Link
Erwartet: der Link zeigt auf einen Pfad im Container. Innerhalb des Dev Containers ist er gültig, und `input-cache/` ist ohnehin in `.gitignore`.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is open source and available under the [Apache License 2.0](LICENSE).

## 🔗 Useful Links

- [FHIR Shorthand Documentation](https://fshschool.org/)
- [IG Publisher Documentation](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation)
- [FHIR Specification](https://hl7.org/fhir/)
- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [GitHub Codespaces](https://github.com/features/codespaces)

## 💬 Support

For questions or issues:
- Open an [issue](https://github.com/Gefyra/IGPublisherDevContainer/issues)
- Check the [FHIR Chat](https://chat.fhir.org/)
- Visit [HL7 FHIR](https://www.hl7.org/fhir/)
