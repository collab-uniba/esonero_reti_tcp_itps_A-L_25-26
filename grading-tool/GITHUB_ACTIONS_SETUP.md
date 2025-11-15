# 🔐 Configurazione GitHub Actions - Guida Completa

## Problema Risolto

Il file `student-repos.txt` è nel `.gitignore` per proteggere la privacy degli studenti. Il workflow GitHub Actions ora supporta **due metodi** per fornire la lista repository.

## 📋 Metodo 1: GitHub Secrets (CONSIGLIATO)

### Vantaggi
✅ **Sicuro** - Lista repository privata e criptata
✅ **Automatico** - Una volta configurato, funziona sempre
✅ **Schedulabile** - Puoi abilitare correzioni automatiche periodiche

### Setup (3 minuti)

1. **Vai nelle impostazioni del repository**
   ```
   Repository → Settings → Secrets and variables → Actions
   ```

2. **Crea un nuovo secret**
   - Click su **"New repository secret"**
   - **Name:** `STUDENT_REPOS`
   - **Value:** Incolla la lista repository (uno per riga)
     ```
     https://github.com/student1/esonero-reti.git
     https://github.com/student2/esonero-reti.git
     https://github.com/student3/esonero-reti.git
     ```
   - Click su **"Add secret"**

3. **Esegui il workflow**
   - Vai su **Actions** → **Auto Grade Student Projects**
   - Click **"Run workflow"**
   - Lascia il campo input **vuoto** (userà il secret)
   - Click **"Run workflow"**

### Aggiornare la lista studenti

Per aggiungere/rimuovere repository:

1. Settings → Secrets and variables → Actions
2. Click su `STUDENT_REPOS`
3. Click **"Update secret"**
4. Modifica la lista
5. Click **"Update secret"**

## 🖱️ Metodo 2: Input Manuale

### Vantaggi
✅ **Semplice** - Nessuna configurazione richiesta
✅ **Flessibile** - Lista diversa ogni volta
✅ **Test rapidi** - Ideale per testare singoli studenti

### Come usare

1. **Vai su Actions**
   ```
   Repository → Actions → Auto Grade Student Projects
   ```

2. **Run workflow**
   - Click **"Run workflow"**
   - Nel campo **"Lista repository studenti"** incolla:
     ```
     https://github.com/student1/esonero-reti.git
     https://github.com/student2/esonero-reti.git
     ```
   - Click **"Run workflow"**

## 🔄 Confronto Metodi

| Caratteristica | Secret (Metodo 1) | Input Manuale (Metodo 2) |
|----------------|-------------------|--------------------------|
| Privacy | ✅ Privato | ⚠️ Visibile nei log |
| Setup | Una volta | Ogni esecuzione |
| Automazione | ✅ Supporta schedule | ❌ Solo manuale |
| Flessibilità | ⚠️ Lista fissa | ✅ Lista variabile |
| **Consigliato per** | **Uso in produzione** | **Test e debug** |

## 🤝 Combinazione dei Metodi

Puoi anche usare **entrambi**:

- **Secret**: Lista completa di tutti gli studenti
- **Input manuale**: Testa solo 2-3 studenti specifici

**Priorità:** Input manuale > Secret

```bash
# Se fornisci input manuale, sovrascrive il secret
Input: https://github.com/student5/repo.git
Secret: (ignorato)

# Se input è vuoto, usa il secret
Input: (vuoto)
Secret: https://github.com/student1/repo.git
        https://github.com/student2/repo.git
        ...
```

## 📅 Automazione Schedulata (Opzionale)

Per eseguire la correzione automaticamente ogni giorno:

### 1. Configura il Secret

Prima configura `STUDENT_REPOS` come descritto sopra.

### 2. Abilita lo Schedule

Modifica `.github/workflows/auto-grade.yml`:

```yaml
# Trova queste righe (circa riga 13-17)
  # Esecuzione schedulata (es. ogni giorno alle 02:00 UTC)
  # Decommentare per abilitare correzioni automatiche periodiche
  # Richiede il secret STUDENT_REPOS configurato
  # schedule:
  #   - cron: '0 2 * * *'

# Rimuovi i commenti (#):
  # Esecuzione schedulata (ogni giorno alle 02:00 UTC)
  schedule:
    - cron: '0 2 * * *'
```

### 3. Personalizza l'Orario

Usa [crontab.guru](https://crontab.guru/) per generare il cron:

```yaml
# Esempi:
- cron: '0 2 * * *'      # Ogni giorno alle 02:00 UTC
- cron: '0 14 * * 1'     # Ogni Lunedì alle 14:00 UTC
- cron: '0 9 * * 1,3,5'  # Lun/Mer/Ven alle 09:00 UTC
- cron: '0 0 * * 0'      # Ogni Domenica a mezzanotte UTC
```

⚠️ **Nota:** Gli orari sono in UTC (Italia = UTC+1/+2)

## 🚨 Troubleshooting

### Errore: "No repository list provided"

**Causa:** Né secret né input forniti

**Soluzione:**
1. Verifica che il secret `STUDENT_REPOS` esista (Settings → Secrets)
2. O fornisci l'input manuale quando esegui il workflow

### Errore: "Repository list is empty"

**Causa:** Il secret/input contiene solo linee vuote o commenti

**Soluzione:**
1. Verifica il contenuto del secret
2. Assicurati che ci sia almeno un URL valido
3. Le linee con `#` sono ignorate (commenti)

### Il workflow non trova il file

**Causa:** Questo era il problema originale - il file è nel gitignore

**Soluzione:** ✅ Già risolto! Ora il workflow crea il file da secret/input

### I repository sono privati e il clone fallisce

**Causa:** GitHub Actions non ha accesso ai repository privati

**Soluzioni:**

#### Opzione A: Rendi i repository pubblici
- I repository studenti devono essere pubblici per essere testati

#### Opzione B: Usa un Personal Access Token (PAT)
1. Crea un PAT: GitHub → Settings → Developer settings → Personal access tokens
2. Dai permessi `repo` (full access)
3. Copia il token
4. Crea un secret `GH_PAT` con il token
5. Modifica lo step "Checkout" nel workflow:
   ```yaml
   - name: Checkout grading tool
     uses: actions/checkout@v4
     with:
       token: ${{ secrets.GH_PAT }}
   ```

## 📊 Visualizzare i Risultati

Dopo che il workflow completa:

1. **Vai su Actions** → Seleziona l'esecuzione completata
2. **Scorri in basso** a "Artifacts"
3. **Scarica:**
   - `aggregate-reports` - Report CSV/HTML
   - `individual-reports` - JSON per ogni studente
   - `grading-logs` - Log di debug

## 💡 Best Practices

### Per uso in produzione

1. ✅ Usa **GitHub Secrets** per la lista repository
2. ✅ Testa prima con **input manuale** su 2-3 repository
3. ✅ Verifica i report scaricati
4. ✅ **Solo dopo**, aggiungi tutti i repository al secret

### Per test e debug

1. ✅ Usa **input manuale** con repository template
2. ✅ Scarica i log se qualcosa fallisce
3. ✅ Verifica i file in `temp/` negli artifacts

### Per privacy

1. ✅ **MAI** committare `student-repos.txt` (già nel gitignore)
2. ✅ Usa **Secrets** per dati sensibili
3. ✅ Limita l'accesso al repository solo ai docenti
4. ⚠️ I report scaricati contengono URL repository - trattali come privati

## 📝 Esempio Completo

### Prima esecuzione (test)

```
1. Actions → Auto Grade Student Projects → Run workflow
2. Input: https://github.com/tuousername/esonero-reti-template.git
3. Run workflow
4. Attendi ~1 minuto
5. Download artifacts → Verifica report
```

### Configurazione produzione

```
1. Settings → Secrets → New secret
2. Name: STUDENT_REPOS
3. Value: (lista completa 50+ studenti)
4. Actions → Run workflow (lascia input vuoto)
5. Scarica aggregate-report.html
```

### Correzioni periodiche automatiche

```
1. Configura secret STUDENT_REPOS
2. Modifica workflow → Decommenta schedule
3. Commit e push
4. Ogni giorno alle 02:00 UTC → Report automatici
```

---

**Domande?** Verifica il file `README.md` per la documentazione completa.
