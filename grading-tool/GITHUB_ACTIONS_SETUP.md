# GitHub Actions - Setup

## Configurazione Secret (2 minuti)

1. Repository → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret**
3. Name: `STUDENT_REPOS`
4. Value: un repository per riga
   ```
   https://github.com/student1/repo.git
   https://github.com/student2/repo.git
   ```
5. **Add secret**

## Esecuzione

### Con Secret
1. **Actions** → **Auto Grade Student Projects** → **Run workflow**
2. Lascia il campo vuoto
3. **Run workflow**

### Con Input Manuale
1. **Actions** → **Auto Grade Student Projects** → **Run workflow**
2. Incolla lista repository nel campo
3. **Run workflow**

## Download Report

1. Actions → seleziona workflow completato
2. **Artifacts** (in basso)
3. Scarica `aggregate-reports` e/o `individual-reports`

## Aggiornare Lista

Settings → Secrets → `STUDENT_REPOS` → **Update secret**

## Automazione Schedulata (opzionale)

Modifica `.github/workflows/auto-grade.yml`:

```yaml
# Decommenta queste righe (circa riga 16-17):
schedule:
  - cron: '0 2 * * *'  # Ogni giorno alle 02:00 UTC
```

## Repository Privati

Servono token di accesso. Crea PAT:
1. GitHub Settings → Developer settings → Personal access tokens → Generate new token
2. Permessi: `repo`
3. Copia token
4. Repository → Settings → Secrets → New secret: `GH_PAT` = token
5. Non serve modificare il workflow, usa il PAT nelle URL:
   ```
   https://TOKEN@github.com/user/private-repo.git
   ```
