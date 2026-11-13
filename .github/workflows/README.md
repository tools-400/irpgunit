# GitHub Actions Workflows

## release.yml — Release-Veröffentlichung

Veröffentlicht bei einem Release-Build die folgenden Dateien als Assets eines GitHub Release:

- `docs/files/iRPGUnit for RDi <RDi-Version>+.pdf`
- `docs/files/rdi8.0/iRPGUnit for RDi <RDi-Version>+ (v<VERSION> Update Site).zip`
- `docs/update-site/eclipse/rdi8.0/Server/RPGUNIT.SAVF`, nur wenn sich die Bibliothek seit dem vorigen Release geändert hat (siehe unten)

### Trigger

- **Push auf `main`**, der `docs/files/rdi8.0/` ändert, also der Commit „Release v…“ mit dem neuen Update-Site-ZIP. Die Version stammt aus dem Namen des ZIPs (`(v<VERSION> Update Site).zip`). Fehlt der Tag `v<VERSION>`, legt der Workflow ihn auf dem Commit an, der das ZIP zuletzt geändert hat, und erstellt das Release.
- **Push eines Tags** im Release-Format `v<major>.<minor>.<patch>.r`, z. B. `v6.0.12.r`. Der Tag bestimmt die Version.
- **Manueller Start** (*Run workflow*) wie ein Push auf `main`. Mit `dry_run` (Voreinstellung) zeigt er nur an, welcher Commit getaggt würde, und prüft die Assets.

Beta-Versionen (`v6.0.12.b001` usw.) werden bewusst ignoriert. Ihre ZIPs liegen unter `docs/beta-version/` und lösen den Workflow nicht aus.

### Ablauf

1. **Checkout** des Repos mit allen Commits und Tags.
2. **Release bestimmen**: aus dem gepushten Tag oder aus dem Namen des ZIPs in `docs/files/rdi8.0/`. Existiert der Tag auf GitHub schon, endet der Workflow ohne Änderung.
3. **Tag anlegen** (nur beim Push auf `main` und beim manuellen Start ohne `dry_run`): annotiert, Nachricht `Tag v<VERSION>.`, Tagger `github-actions[bot]`. Tag und Release entstehen im selben Lauf, weil ein mit `GITHUB_TOKEN` angelegter Tag keinen weiteren Workflow auslöst.
4. **Assets validieren** auf dem Stand des Tags:
   - Unter `docs/files/` muss genau eine PDF `iRPGUnit for RDi*.pdf` existieren.
   - Im Verzeichnis `docs/files/rdi8.0/` muss genau ein ZIP existieren, dessen Name auf `(v<VERSION> Update Site).zip` endet. Bei 0 oder mehreren Treffern bricht der Workflow mit klarer Fehlermeldung ab.
   - Die Save-Datei `RPGUNIT.SAVF` muss existieren.
5. **Save-Datei prüfen**: Sie kommt nur in das Release, wenn sie sich gegenüber dem vorigen Release-Tag geändert hat. Sonst nennt der Text des Release diesen Tag.
6. **GitHub Release erstellen** mit Titel `v<VERSION>` und den Dateien als Assets (`softprops/action-gh-release`).

### Veröffentlichen

Den Commit „Release v<VERSION>.“ auf `main` pushen. Tag und Release entstehen automatisch. Lokal holt `git fetch --tags` den Tag.

Ein Tag lässt sich weiterhin von Hand pushen, z. B. um ein Release neu zu erstellen:

```bash
git tag -a v6.0.12.r -m "Tag v6.0.12.r."
git push origin v6.0.12.r
```

Eine Datei eines Release lässt sich später austauschen, z. B. das Handbuch nach einer Korrektur. Der Name muss dem Asset entsprechen (GitHub ersetzt Leerzeichen durch Punkte):

```bash
gh release upload v6.0.12.r "iRPGUnit.for.RDi.9.6.0.13+.pdf" --clobber -R tools-400/irpgunit
```

### VS Code Extension IBM i Testing

Die Extension [IBM i Testing](https://github.com/IBM/vscode-ibmi-testing) liest die GitHub Releases dieses Repos
(`tools-400/irpgunit`, nicht `irpgunit-plugin`). Sie bietet jedes Release mit dem Asset `RPGUNIT.SAVF` ab Version
6.0.0 als Bibliothek zum Installieren an und liest die Version aus dem Namen des Release. Deshalb:

- Der Name des Release ist genau `v<VERSION>`, z. B. `v6.0.11.r`, ohne Produktnamen.
- `RPGUNIT.SAVF` kommt nur in Releases, die die Bibliothek ändern. Ein Release, das nur das Plug-in ändert, sieht die
  Extension nicht.

### Nachträgliche Releases

Der Workflow kann keinen Tag auf einen Commit setzen, dessen Dateien unter `.github/workflows/` sich vom aktuellen `main` unterscheiden: GitHub erlaubt das dem `GITHUB_TOKEN` nicht (fehlende Berechtigung `workflows`). Das betrifft nur Releases, die älter sind als die letzte Änderung eines Workflows. Für sie den Tag von Hand pushen (siehe oben); der Workflow legt dann das Release an.

### Vorbedingung

Das Update-Site-ZIP muss unter dem Release-Namen in `docs/files/rdi8.0/` liegen. Heißt das ZIP noch `... (v6.0.12.b010 Update Site).zip`, muss es vorher in `... (v6.0.12.r Update Site).zip` umbenannt und committet werden.

### Berechtigungen

Der Job läuft mit `contents: write`, was zum Anlegen von Tag und Release nötig ist. Es werden keine zusätzlichen Secrets benötigt — `GITHUB_TOKEN` reicht.

### Beta-Builds

Aktuell nicht im Scope. Falls Beta-Tags (`v*.b*`) später ebenfalls automatisch als Pre-Release veröffentlicht werden sollen, lässt sich das über einen zweiten Tag-Filter und `prerelease: true` ergänzen.
