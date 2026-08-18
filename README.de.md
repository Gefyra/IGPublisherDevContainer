# FHIR IG Publisher Dev Container

[English](README.md) · **Deutsch**

[![Published IG](https://img.shields.io/badge/IG-published-blue)](https://gefyra.github.io/IGPublisherDevContainer/branches/main/)
[![License](https://img.shields.io/github/license/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/blob/main/LICENSE)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/Gefyra/igpublisher-devcontainer-image/pkgs/container/igpublisher-devcontainer-image)
[![GitHub issues](https://img.shields.io/github/issues/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/issues)
[![Dev Container](https://img.shields.io/badge/Dev%20Container-Ready-green)](https://code.visualstudio.com/docs/devcontainers/containers)
[![Codespaces](https://img.shields.io/badge/Codespaces-Ready-brightgreen)](https://github.com/features/codespaces)

Ausgangspunkt für FHIR Implementation Guides. Aus dieser Vorlage entsteht ein IG, der sich selbst baut, in der Vorschau anzeigt und veröffentlicht — ohne lokale Installation von Java, Ruby, Node oder IG Publisher. SUSHI, IG Publisher, Jekyll und `fhir-pkg-tool` liegen in einem Container, der auf Intel und Apple Silicon läuft, in VS Code oder vollständig im Browser über Codespaces.

**Erste Schritte:** [Schnellstart](#schnellstart), anschließend [Das erste Profil](#das-erste-profil).
**Bereits vertraut:** [Täglicher Ablauf](#täglicher-ablauf) · [Veröffentlichen](#veröffentlichen) · [Referenz](#referenz)

---

## Schnellstart

### 1. Repository anlegen

Dieses Repository ist eine **GitHub-Vorlage**. Über **„Use this template" → „Create a new repository"** ([direkter Link](https://github.com/Gefyra/IGPublisherDevContainer/generate)) ein eigenes Repository erzeugen. Die Vorlage verwenden, nicht forken.

### 2. Öffnen

**Im Browser, ohne Installation:** grüner **„Code"**-Button → Reiter **Codespaces** → **„Create codespace on main"**.

**Lokal:** erforderlich sind [Docker](https://www.docker.com/get-started), [VS Code](https://code.visualstudio.com/) und die [Dev-Containers-Erweiterung](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

```bash
git clone https://github.com/<owner>/<ig-repository>.git
cd <ig-repository>
code .
```

Anschließend **„Reopen in Container"** wählen oder `F1` → `Dev Containers: Reopen in Container`. Beim ersten Start wird das Image einmalig geladen.

### 3. Bauen und ansehen

`F1` → `Tasks: Run Task` → **„IG Publisher: Full Build"** (oder `Cmd/Ctrl+Shift+B`). Danach den Task **„Serve IG Locally"** starten; VS Code bietet für den weitergeleiteten Port **„Open in Browser"** an.

### 4. Veröffentlichung einschalten

Im neuen Repository unter **Settings → Pages** als Quelle den Branch `gh-pages` einstellen. Ab dann veröffentlicht jeder Push eine Vorschau — siehe [Veröffentlichen](#veröffentlichen).

## Das erste Profil

1. **FSH schreiben** in `input/fsh/`:

   ```fsh
   Profile: MyPatient
   Parent: Patient
   * name 1..* MS
   ```

2. **Übersetzen** — Task **„SUSHI: Build FSH"** oder `sushi`. Das Ergebnis liegt in `fsh-generated/`.

3. **Abhängigkeiten eintragen** in `sushi-config.yaml`, sofern der IG auf anderen aufbaut.

4. **Abhängigkeiten laden und snapshotten** — Task **„FHIR Package: Download and Snapshot Dependencies"**. Damit werden die Pakete aufgelöst, von denen die Profile ableiten.

5. **IG bauen** — Task **„IG Publisher: Full Build"**. Der erste Lauf dauert einige Minuten.

6. **Bericht prüfen.** `output/qa.html` enthält sämtliche Validierungsmeldungen und sollte vor jeder Weitergabe gelesen werden.

Einstieg in FHIR Shorthand: [FSH School](https://fshschool.org/).

## Täglicher Ablauf

Tasks werden über `F1` → `Tasks: Run Task` gestartet. Standard-Build-Task ist **„IG Publisher: Full Build"** auf `Cmd/Ctrl+Shift+B`.

| Task | Wirkung |
|---|---|
| **SUSHI: Build FSH** | Übersetzt FSH in FHIR-Ressourcen |
| **IG Publisher: Full Build** | Vollständiger IG-Build, führt vorher SUSHI aus |
| **FHIR Package: Download and Snapshot Dependencies** | Löst die Abhängigkeiten aus `sushi-config.yaml` auf |
| **Update IG Publisher** | Holt das aktuelle IG-Publisher-Release |
| **Serve IG Locally** | Stellt `output/` zur Vorschau bereit |
| **Git: Commit Changes** | Staged alles und committet mit abgefragter Nachricht |
| **Download: IG Package** | Weist auf `output/full-ig.zip` hin |
| **Download: JSON Resources** | Packt `fsh-generated/resources/*.json` als ZIP |

Die Tasks rufen Kommandos auf, die das Container-Image mitbringt (`ig-update-publisher`, `ig-commit`, `ig-package`, `ig-json-resources`). Dadurch bleibt `tasks.json` stabil: ändert sich die Logik dahinter, kommt sie mit dem nächsten Image, ohne dass diese Datei angepasst werden muss.

Im Terminal leisten `sushi`, `./_genonce.sh`, `fhir-pkg-tool --sushi-deps-file sushi-config.yaml` und `python3 -m http.server 8080` dasselbe.

## Veröffentlichen

GitHub Actions baut den IG und veröffentlicht ihn auf GitHub Pages. Die Seite hat drei Ebenen:

```
https://<owner>.github.io/<repo>/                    neuestes Release
https://<owner>.github.io/<repo>/<version>/          archivierte Releases
https://<owner>.github.io/<repo>/branches/<name>/    Vorschau je Branch
```

**Branch-Vorschauen** entstehen bei jedem Push auf einen Branch. Damit lässt sich ein Zwischenstand weitergeben oder mit `main` vergleichen, ohne dass der Empfänger selbst baut. Die Pipeline schreibt die URL in die Zusammenfassung des Laufs und kommentiert sie an den zugehörigen Pull Request.

**Releases** entstehen beim Veröffentlichen eines GitHub-Releases. Der Build landet dann zugleich im Wurzelverzeichnis als aktueller Stand und im Archiv unter seiner Versionsnummer. Der Tag muss zur `version` in `sushi-config.yaml` passen — andernfalls bricht der Lauf ab, statt einen Build unter einer falschen Nummer zu veröffentlichen.

Wissenswert:

- Veröffentlicht wird nur bei **Push** und **Release**, nicht für Pull Requests aus Forks.
- Der Branch-Name wird unverändert als Pfad verwendet: `feature/x` landet unter `branches/feature/x/`.
- Beim Löschen eines Branches verschwindet seine Vorschau — sofort und noch einmal in der wöchentlichen Nachlese. Der Workflow „Clean up branch previews" lässt sich über „Run workflow" auch manuell starten.
- **`full-ig.zip` wird nicht veröffentlicht.** Es ändert sich bei jedem Build vollständig und wird von der Seite nirgends verlinkt. Die Package-Tarballs (`package*.tgz`) bleiben erhalten, damit ein konsumierender IG auf einen Branch- oder Release-Stand verweisen kann.
- `gh-pages` wird bei jeder Veröffentlichung als einzelner Root-Commit neu geschrieben. Pages liefert ohnehin nur den aktuellen Stand aus; mit Historie lägen dort die Binärdateien jedes je gebauten Stands dauerhaft.
- Nach dem Build vergehen einige Minuten, bis Pages die Änderung ausliefert.

## Aktuell bleiben

Bei jedem Start meldet der Container die verwendete Version:

```
IG Publisher 2.3.2 (from the image, 2026-08-14)
```

Ist das Jar älter als 14 Tage, erscheint zusätzlich ein Hinweis. Zum Aktualisieren gibt es zwei Wege.

### Nur den IG Publisher

Task **„Update IG Publisher"** ausführen. Holt das aktuelle HL7-Release sofort, unabhängig vom Alter des Images und ohne Rebuild. Der passende Weg, wenn ein frischer Publisher-Fix benötigt wird.

### Das ganze Image

Bringt außerdem SUSHI, `fhir-pkg-tool`, die Extensions und die Container-Logik auf Stand. Das Image wird automatisch neu gebaut, sobald HL7 ein neues IG-Publisher-Release veröffentlicht, in der Regel innerhalb von 24 Stunden.

**Der Container holt das nicht von allein.** `latest` ist ein bewegliches Tag: Docker verwendet weiter das lokal zwischengespeicherte Image, bis es explizit neu gezogen wird.

| Umgebung | Vorgehen |
|---|---|
| VS Code lokal | `Dev Containers: Rebuild Container`; ohne Wirkung **Rebuild Without Cache** |
| GitHub Codespaces | `Codespaces: Full Rebuild Container` |
| Kommandozeile | `docker pull ghcr.io/gefyra/igpublisher-devcontainer-image:latest`, danach neu bauen |

> [!IMPORTANT]
> **Stoppen und Starten genügt nicht.** Ein angehaltener und wieder gestarteter Container — auch ein Codespace — ist derselbe Container: `postCreateCommand` läuft nicht, es wird kein Image gezogen. Wer den Codespace nur stoppt und startet, arbeitet monatelang mit demselben Publisher. Ein Rebuild stellt den aktuellen Stand her.

### Ablage des Publisher-Jars

`input-cache/publisher.jar` ist im Normalfall ein **Symlink** auf das Jar im Image (`/opt/ig/publisher.jar`). So existiert es einmal statt zweimal, und ein Rebuild führt automatisch auf die Version des neuen Images.

Der Task „Update IG Publisher" ersetzt den Link durch eine echte Datei — notwendig, weil in das Image nicht geschrieben werden kann. Der Platzbedarf steigt dadurch vorübergehend von rund 220 MB auf 440 MB. Sobald das Image aufgeholt hat, tauscht der nächste Rebuild die Kopie gegen den Link zurück und gibt den Platz wieder frei.

## Referenz

### Inhalt des Containers

| Werkzeug | Zweck |
|---|---|
| [IG Publisher](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation) | Baut den Implementation Guide |
| [SUSHI](https://fshschool.org/docs/sushi/) | Übersetzt FHIR Shorthand in Ressourcen |
| `fhir-pkg-tool` | Lädt Abhängigkeiten und erzeugt Snapshots |
| Java 21, Node 20, Ruby + Jekyll | Laufzeiten des Publishers |
| `python3` | Lokaler Vorschau-Server |
| `zip` / `unzip`, `git`, `curl`, `sudo` | Allgemeine Werkzeuge |

Das Image liegt in [Gefyra/igpublisher-devcontainer-image](https://github.com/Gefyra/igpublisher-devcontainer-image). Es enthält nicht nur die Toolchain, sondern auch die Devcontainer-Konfiguration: Benutzer, weitergeleitete Ports, Lifecycle-Kommandos und die VS-Code-Extensions stammen aus seinem `devcontainer.metadata`-Label. Deshalb umfasst die `.devcontainer/devcontainer.json` hier nur wenige Zeilen.

### Projektstruktur

```
.
├── .devcontainer/
│   └── devcontainer.json   # verweist auf das fertige Image; Einstellungen kommen von dort
├── .github/workflows/      # bauen, veröffentlichen, Vorschauen aufräumen
├── scripts/gh-pages.sh     # verwaltet den gh-pages-Branch
├── input/
│   ├── fsh/                # FSH-Quellen
│   └── pagecontent/        # erzählende Seiten, Markdown
├── fsh-generated/          # SUSHI-Ausgabe (generiert)
├── output/                 # IG-Publisher-Ausgabe (generiert)
├── input-cache/            # Publisher-Jar und Pakete (generiert)
├── ig.ini                  # IG-Publisher-Konfiguration
└── sushi-config.yaml       # SUSHI-Konfiguration, Abhängigkeiten, Version
```

### VS-Code-Extensions

Automatisch installiert, geliefert vom Image:

- **FHIR:** `gematikde.codfsh`, `fhir-shorthand.vscode-fsh`, `yannick-lagger.vscode-fhir-tools`
- **Allgemein:** `redhat.vscode-yaml`, `esbenp.prettier-vscode`, `yzhang.markdown-all-in-one`, `streetsidesoftware.code-spell-checker`, `mhutchie.git-graph`, `peakchen90.open-html-in-browser`

## Fehlersuche

### Der Container startet nicht

Prüfen, ob Docker läuft, anschließend `Dev Containers: Rebuild Container`. Die Docker-Logs nennen in der Regel die Ursache.

### Der Build schlägt fehl

`output/qa.html` enthält den Validierungsbericht und ist die erste Anlaufstelle. Bekannte, akzeptierte Meldungen gehören in `input/ignoreWarnings.txt`. Deutet das Problem auf den Publisher selbst, hilft der Task **„Update IG Publisher"**.

### Port 8080 ist belegt

Dev Containers veröffentlicht Ports nicht auf Docker-Ebene, sondern leitet sie weiter. Entscheidend ist daher, wo der Konflikt liegt.

**Auf dem Host:** Der Container-Port bleibt 8080, der lokale Port kann abweichen. Ist 8080 lokal belegt, mappt VS Code **still** auf einen freien Port, weil `requireLocalPort` standardmäßig `false` ist. Der Aufruf von `localhost:8080` erreicht dann die andere Anwendung, und der IG scheint zu fehlen.

Beim Start des Servers zeigt VS Code eine Benachrichtigung mit der weitergeleiteten Adresse und der Schaltfläche **„Open in Browser"** — das Image fordert sie über `onAutoForward: notify` an. Diese Schaltfläche verwenden, statt die URL einzutippen. Danach bleibt die Adresse im **PORTS**-Panel unter „Local Address" abrufbar. Wem 8080 gehört, zeigt:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN     # macOS/Linux
```

`Code Helper` bedeutet: der Forward des Dev Containers, alles in Ordnung.

Das stille Ausweichen ist der Standard der Devcontainer-Spec, keine Einstellung dieses Projekts, und durchaus praktisch — so laufen mehrere IG-Container gleichzeitig, ohne sich um den Port zu streiten. Wer stattdessen informiert werden möchte, ergänzt in der `devcontainer.json`:

```json
"portsAttributes": { "8080": { "requireLocalPort": true } }
```

VS Code meldet dann, wenn 8080 lokal nicht verwendbar ist. Den Port frei machen kann die Option nicht; sie sorgt lediglich für die Meldung.

**Im Container:** Belegt dort bereits ein Prozess den Port, bricht der Task mit `Address already in use` ab. In `.vscode/tasks.json` beim Task „Serve IG Locally" einen anderen Port setzen, etwa `python3 -m http.server 8081`.

In Codespaces stellt sich die Frage nicht — die Weiterleitung läuft über den Codespaces-Proxy, nicht über lokale Ports.

### „Update IG Publisher" schlägt mit `curl: (23)` fehl

Der Task ruft noch direkt `_updatePublisher.sh` auf statt `ig-update-publisher`. `curl` schreibt dann durch den Symlink in das schreibgeschützte Image. Es geht nichts verloren; in `.vscode/tasks.json` setzen:

```json
"command": "ig-update-publisher"
```

### Der Publisher ist trotz Rebuild alt

Ein einfacher Rebuild kann das zwischengespeicherte Image weiterverwenden. **Rebuild Without Cache** verwenden, in Codespaces **Full Rebuild Container** — oder für einen sofort aktuellen Publisher den Task **„Update IG Publisher"**.

### `input-cache/publisher.jar` ist auf dem Host ein toter Link

Das ist erwartbar: der Link verweist auf einen Pfad im Container. Innerhalb des Dev Containers ist er gültig, und `input-cache/` steht ohnehin in `.gitignore`.

## Mitwirken

Issues und Pull Requests sind willkommen.

## Lizenz

[Apache License 2.0](LICENSE)

## Links

- [FSH School](https://fshschool.org/) — FHIR Shorthand lernen
- [SUSHI-Dokumentation](https://fshschool.org/docs/sushi/)
- [IG-Publisher-Dokumentation](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation)
- [FHIR-Spezifikation](https://hl7.org/fhir/)
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) · [GitHub Codespaces](https://github.com/features/codespaces)
- [FHIR Chat](https://chat.fhir.org/) — Anlaufstelle für FHIR-Fragen
