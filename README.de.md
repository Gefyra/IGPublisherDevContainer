# FHIR IG Publisher Dev Container

[English](README.md) · **Deutsch**

[![Published IG](https://img.shields.io/badge/IG-published-blue)](https://gefyra.github.io/IGPublisherDevContainer/branches/main/)
[![License](https://img.shields.io/github/license/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/blob/main/LICENSE)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/Gefyra/igpublisher-devcontainer-image/pkgs/container/igpublisher-devcontainer-image)
[![GitHub issues](https://img.shields.io/github/issues/Gefyra/IGPublisherDevContainer)](https://github.com/Gefyra/IGPublisherDevContainer/issues)
[![Dev Container](https://img.shields.io/badge/Dev%20Container-Ready-green)](https://code.visualstudio.com/docs/devcontainers/containers)
[![Codespaces](https://img.shields.io/badge/Codespaces-Ready-brightgreen)](https://github.com/features/codespaces)

Ausgangspunkt für FHIR Implementation Guides. Aus dieser Vorlage entsteht ein IG, der sich selbst baut, in der Vorschau anzeigt und veröffentlicht — ohne Java, Ruby, Node oder IG Publisher auf deinem Rechner. SUSHI, IG Publisher, Jekyll und `fhir-pkg-tool` stecken in einem Container, der auf Intel wie Apple Silicon läuft, in VS Code oder komplett im Browser über Codespaces.

**Neu hier?** [Schnellstart](#schnellstart), danach [Dein erstes Profil](#dein-erstes-profil).
**Schon vertraut?** [Täglicher Ablauf](#täglicher-ablauf) · [Veröffentlichen](#veröffentlichen) · [Referenz](#referenz)

---

## Schnellstart

### 1. Repository anlegen

Dieses Repository ist eine **GitHub-Vorlage**. Nicht forken, sondern **„Use this template" → „Create a new repository"** ([direkter Link](https://github.com/Gefyra/IGPublisherDevContainer/generate)), Namen wählen, fertig.

> [!TIP]
> **Warum kein Fork?** Ein Fork lohnt sich, wenn man Änderungen aus dem Original übernehmen will — genau das willst du hier nicht. Dein Repository enthält deine Profile und deine `sushi-config.yaml`, das Original eine Beispiel-IG; ein Merge zöge dessen Beispielinhalte in dein Projekt. Dazu zielen Pull Requests in einem Fork standardmäßig auf das Original, und ein öffentlicher Fork lässt sich nicht nachträglich privat schalten.
>
> Aktualisierungen der Entwicklungsumgebung laufen ohnehin nicht über das Repository, sondern über das Container-Image — siehe [Aktuell bleiben](#aktuell-bleiben).

### 2. Öffnen

**Im Browser (nichts zu installieren):** grüner **„Code"**-Button → Reiter **Codespaces** → **„Create codespace on main"**.

**Lokal:** du brauchst [Docker](https://www.docker.com/get-started), [VS Code](https://code.visualstudio.com/) und die [Dev-Containers-Erweiterung](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

```bash
git clone https://github.com/<owner>/<dein-ig>.git
cd <dein-ig>
code .
```

Dann auf **„Reopen in Container"** klicken oder `F1` → `Dev Containers: Reopen in Container`. Beim ersten Start wird das Image einmalig geladen.

### 3. Bauen und ansehen

`F1` → `Tasks: Run Task` → **„IG Publisher: Full Build"** (oder einfach `Cmd/Ctrl+Shift+B`). Danach den Task **„Serve IG Locally"** starten und die URL aus dem **PORTS**-Panel öffnen.

### 4. Veröffentlichung einschalten

Im neuen Repository unter **Settings → Pages** als Quelle den Branch `gh-pages` einstellen. Ab dann veröffentlicht jeder Push eine Vorschau — siehe [Veröffentlichen](#veröffentlichen).

## Dein erstes Profil

1. **FSH schreiben** in `input/fsh/`:

   ```fsh
   Profile: MyPatient
   Parent: Patient
   * name 1..* MS
   ```

2. **Übersetzen** — Task **„SUSHI: Build FSH"** oder `sushi`. Das Ergebnis landet in `fsh-generated/`.

3. **Abhängigkeiten eintragen** in `sushi-config.yaml`, wenn du auf anderen IGs aufbaust.

4. **Abhängigkeiten laden und snapshotten** — Task **„FHIR Package: Download and Snapshot Dependencies"**. Damit werden die Pakete aufgelöst, von denen deine Profile ableiten.

5. **IG bauen** — Task **„IG Publisher: Full Build"**. Der erste Lauf dauert einige Minuten.

6. **Bericht lesen.** `output/qa.html` listet jede Validierungsmeldung — die Datei, die man vor dem Teilen anschaut.

FHIR Shorthand noch neu? [FSH School](https://fshschool.org/) ist der Ort zum Lernen.

## Täglicher Ablauf

Tasks starten über `F1` → `Tasks: Run Task`. Standard-Build-Task ist **„IG Publisher: Full Build"** auf `Cmd/Ctrl+Shift+B`.

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

Die Tasks rufen Kommandos auf, die das Container-Image mitbringt (`ig-update-publisher`, `ig-commit`, `ig-package`, `ig-json-resources`). Dadurch bleibt `tasks.json` stabil: ändert sich die Logik dahinter, kommt sie mit dem nächsten Image, ohne dass diese Datei angefasst wird.

Lieber im Terminal? `sushi`, `./_genonce.sh`, `fhir-pkg-tool --sushi-deps-file sushi-config.yaml` und `python3 -m http.server 8080` tun dasselbe.

## Veröffentlichen

GitHub Actions baut den IG und veröffentlicht ihn auf GitHub Pages. Die Seite hat drei Ebenen:

```
https://<owner>.github.io/<repo>/                    neuestes Release
https://<owner>.github.io/<repo>/<version>/          archivierte Releases
https://<owner>.github.io/<repo>/branches/<name>/    Vorschau je Branch
```

**Branch-Vorschauen** entstehen bei jedem Push auf einen Branch. Damit lässt sich ein Zwischenstand teilen oder gegen `main` vergleichen, ohne dass jemand selbst baut. Die Pipeline schreibt die URL in die Zusammenfassung des Laufs und kommentiert sie an den zugehörigen Pull Request.

**Releases** entstehen, wenn du auf GitHub ein Release veröffentlichst. Der Build landet dann zugleich im Wurzelverzeichnis als aktueller Stand und im Archiv unter seiner Versionsnummer. Der Tag muss zur `version` in `sushi-config.yaml` passen — sonst bricht der Lauf ab, statt einen Build unter einer falschen Nummer zu veröffentlichen.

Details, die erfahrungsgemäß Fragen aufwerfen:

- Veröffentlicht wird nur bei **Push** und **Release**, nicht für Pull Requests aus Forks.
- Der Branch-Name wird unverändert als Pfad verwendet: `feature/x` landet unter `branches/feature/x/`.
- Wird ein Branch gelöscht, verschwindet seine Vorschau — sofort und noch einmal in der wöchentlichen Nachlese. Der Workflow „Clean up branch previews" lässt sich auch über „Run workflow" von Hand starten.
- **`full-ig.zip` wird nicht veröffentlicht.** Es ändert sich bei jedem Build vollständig und wird von der Seite nirgends verlinkt. Die Package-Tarballs (`package*.tgz`) bleiben dagegen erhalten, damit ein konsumierender IG auf einen Branch- oder Release-Stand zeigen kann.
- `gh-pages` wird bei jeder Veröffentlichung als einzelner Root-Commit neu geschrieben. Pages liefert ohnehin nur den aktuellen Stand aus; mit Historie lägen dort die Binärdateien jedes je gebauten Stands für immer.
- Nach dem Build vergehen einige Minuten, bis Pages die Änderung ausliefert.

## Aktuell bleiben

Bei jedem Start meldet der Container, womit du baust:

```
IG Publisher 2.3.2 (aus dem Image, 14.08.2026)
```

Ist das Jar älter als 14 Tage, kommt ein Hinweis dazu. Zum Aktualisieren gibt es zwei Wege — welcher der richtige ist, hängt davon ab, was du brauchst.

### Nur den IG Publisher

Task **„Update IG Publisher"** ausführen. Holt sofort das aktuelle HL7-Release, unabhängig vom Alter des Images und ohne Rebuild. Der Weg, wenn du auf einen frischen Publisher-Fix wartest.

### Das ganze Image

Bringt außerdem SUSHI, `fhir-pkg-tool`, die Extensions und die Container-Logik auf Stand. Das Image wird automatisch neu gebaut, sobald HL7 ein neues IG-Publisher-Release veröffentlicht, in der Regel innerhalb von 24 Stunden.

**Dein Container holt das nicht von allein.** `latest` ist ein bewegliches Tag: Docker verwendet weiter das lokal zwischengespeicherte Image, bis du es explizit neu ziehst.

| Umgebung | Vorgehen |
|---|---|
| VS Code lokal | `Dev Containers: Rebuild Container`; wenn sich nichts tut, **Rebuild Without Cache** |
| GitHub Codespaces | `Codespaces: Full Rebuild Container` |
| Kommandozeile | `docker pull ghcr.io/gefyra/igpublisher-devcontainer-image:latest`, danach neu bauen |

> [!IMPORTANT]
> **Stoppen und Starten reicht nicht.** Ein angehaltener und wieder gestarteter Container — oder Codespace — ist derselbe Container: `postCreateCommand` läuft nicht, es wird kein Image gezogen. Wer seinen Codespace nur stoppt und startet, arbeitet monatelang mit demselben Publisher. Ein Rebuild bringt dich zurück auf den aktuellen.

### Wo das Publisher-Jar liegt

`input-cache/publisher.jar` ist normalerweise ein **Symlink** auf das Jar im Image (`/opt/ig/publisher.jar`). So existiert es einmal statt zweimal, und ein Rebuild bringt dich automatisch auf die Version des neuen Images.

Der Task „Update IG Publisher" ersetzt den Link durch eine echte Datei — er muss es, weil in das Image nicht geschrieben werden kann. Danach belegst du vorübergehend rund 440 MB statt 220 MB. Sobald das Image aufgeholt hat, tauscht der nächste Rebuild die Kopie gegen den Link zurück und gibt den Platz wieder frei.

## Referenz

### Was im Container steckt

| Werkzeug | Zweck |
|---|---|
| [IG Publisher](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation) | Baut den Implementation Guide |
| [SUSHI](https://fshschool.org/docs/sushi/) | Übersetzt FHIR Shorthand in Ressourcen |
| `fhir-pkg-tool` | Lädt Abhängigkeiten und erzeugt Snapshots |
| Java 21, Node 20, Ruby + Jekyll | Laufzeiten, die der Publisher braucht |
| `python3` | Lokaler Vorschau-Server |
| `zip` / `unzip`, `git`, `curl`, `sudo` | Alltagswerkzeuge |

Das Image liegt in [Gefyra/igpublisher-devcontainer-image](https://github.com/Gefyra/igpublisher-devcontainer-image). Es trägt nicht nur die Toolchain, sondern auch die Devcontainer-Konfiguration selbst: Benutzer, weitergeleitete Ports, Lifecycle-Kommandos und die VS-Code-Extensions kommen aus seinem `devcontainer.metadata`-Label — deshalb ist die `.devcontainer/devcontainer.json` hier nur wenige Zeilen lang.

### Projektstruktur

```
.
├── .devcontainer/
│   └── devcontainer.json   # zeigt auf das fertige Image; Einstellungen kommen von dort
├── .github/workflows/      # bauen, veröffentlichen, Vorschauen aufräumen
├── scripts/gh-pages.sh     # verwaltet den gh-pages-Branch
├── input/
│   ├── fsh/                # deine FSH-Quellen
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

Prüfen, ob Docker läuft, dann `Dev Containers: Rebuild Container`. Die Docker-Logs sagen meist, woran es lag.

### Der Build schlägt fehl

`output/qa.html` enthält den Validierungsbericht und ist die erste Anlaufstelle. Bekannte, akzeptierte Meldungen gehören in `input/ignoreWarnings.txt`. Wenn der Publisher selbst das Problem zu sein scheint, den Task **„Update IG Publisher"** ausführen.

### Port 8080 ist belegt

Dev Containers veröffentlicht Ports nicht auf Docker-Ebene, sondern leitet sie weiter. Es hängt also davon ab, wo der Konflikt sitzt.

**Auf dem Host:** Der Container-Port bleibt 8080, der lokale Port kann abweichen. Ist 8080 lokal belegt, mappt VS Code **still** auf einen freien Port — ohne Meldung, weil `requireLocalPort` standardmäßig `false` ist. Tippst du `localhost:8080` ein, antwortet die andere Anwendung, und der IG scheint zu fehlen.

Deshalb den IG über das **PORTS**-Panel öffnen (Rechtsklick → „Open in Browser"); dort steht unter „Local Address" der tatsächlich verwendete Port. Wer wissen will, wem 8080 gehört:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN     # macOS/Linux
```

`Code Helper` bedeutet: das ist der Forward des Dev Containers, alles in Ordnung.

Das stille Ausweichen ist der Standard der Devcontainer-Spec, keine Einstellung dieses Projekts, und es ist praktisch — so können mehrere IG-Container gleichzeitig laufen, ohne sich um den Port zu streiten. Wer stattdessen informiert werden will, ergänzt in der `devcontainer.json`:

```json
"portsAttributes": { "8080": { "requireLocalPort": true } }
```

Dann meldet VS Code, wenn 8080 lokal nicht verwendet werden kann. Den Port frei machen kann die Option nicht; sie sorgt nur dafür, dass du davon erfährst.

**Im Container:** Belegt dort bereits etwas den Port, bricht der Task mit `Address already in use` ab. Dann in `.vscode/tasks.json` beim Task „Serve IG Locally" einen anderen Port setzen, etwa `python3 -m http.server 8081`.

In Codespaces stellt sich die Frage nicht — die Weiterleitung läuft über den Codespaces-Proxy, nicht über lokale Ports.

### „Update IG Publisher" schlägt mit `curl: (23)` fehl

Der Task ruft noch direkt `_updatePublisher.sh` auf statt `ig-update-publisher`. `curl` schreibt dann durch den Symlink in das schreibgeschützte Image. Es geht nichts verloren; in `.vscode/tasks.json` setzen:

```json
"command": "ig-update-publisher"
```

### Der Publisher ist trotz Rebuild alt

Ein einfacher Rebuild kann das zwischengespeicherte Image weiterverwenden. **Rebuild Without Cache** verwenden, in Codespaces **Full Rebuild Container** — oder für einen sofort aktuellen Publisher den Task **„Update IG Publisher"**.

### `input-cache/publisher.jar` ist auf dem Host ein toter Link

Erwartet: der Link zeigt auf einen Pfad im Container. Innerhalb des Dev Containers ist er gültig, und `input-cache/` steht ohnehin in `.gitignore`.

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
- [FHIR Chat](https://chat.fhir.org/) — wo FHIR-Fragen gestellt werden
