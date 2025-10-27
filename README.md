# FHIR IG Publisher Dev Container

[![License](https://img.shields.io/github/license/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/blob/main/LICENSE)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/Gefyra/IGPublisherDevContainer/pkgs/container/igpublisher-devcontainer)
[![GitHub issues](https://img.shields.io/github/issues/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/issues)
[![GitHub stars](https://img.shields.io/github/stars/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/stargazers)
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
| **Update IG Publisher** | Updates the IG Publisher to the latest version |
| **Serve IG Locally** | Starts a local HTTP server to preview the generated IG at `http://localhost:8080` |

### Quick Build

The default build task is **"IG Publisher: Full Build"**. You can run it with:
- `Cmd+Shift+B` (Mac) / `Ctrl+Shift+B` (Windows/Linux)

## 📁 Project Structure

```
.
├── .devcontainer/          # Dev container configuration
│   ├── devcontainer.json   # Container settings and VS Code customizations
│   └── Dockerfile          # Container image definition
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

## 🔄 Updating the Container Image

The container image is automatically built and published to GitHub Container Registry when changes are pushed to the `.devcontainer/` directory.

**Image Tags:**
- `latest` - Latest version
- `sushi-X.Y.Z` - Tagged with specific SUSHI version

**Pull the latest image:**
```bash
docker pull ghcr.io/gefyra/igpublisher-devcontainer:latest
```

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

### Port conflicts
- If port 8080 is in use, modify the port in `.vscode/tasks.json`

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
