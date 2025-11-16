# 🤖 Sistema di Correzione Automatica - Esonero Reti TCP

Sistema completo per la correzione automatizzata dei progetti studenti dell'Esonero di Laboratorio del corso di Reti di Calcolatori.

## 📋 Caratteristiche

- ✅ **Clonazione automatica** dei repository studenti
- 🔨 **Verifica compilazione** client e server
- 🧪 **Test funzionali** configurabili
- 📊 **Report dettagliati** in formato JSON, CSV e HTML
- 🚀 **Deployment locale** (Mac/Linux) e **GitHub Actions**
- ⚡ **Portabile** - solo script bash, nessuna dipendenza complessa

## 📁 Struttura

```
grading-tool/
├── test-project.sh          # Testa un singolo progetto
├── run-tests.sh             # Esegue test funzionali
├── grade-all.sh             # Corregge tutti i progetti
├── generate-report.sh       # Genera report aggregati
├── test-cases.txt           # Configurazione test cases
├── student-repos.txt        # Lista repository studenti
├── reports/                 # Output report (generato)
│   ├── *.json              # Report individuali
│   ├── aggregate-report.csv # Report aggregato CSV
│   └── aggregate-report.html # Report aggregato HTML
├── temp/                    # Directory temporanea (generato)
└── .github/
    └── workflows/
        └── auto-grade.yml   # Workflow GitHub Actions
```

## 🚀 Quick Start

### Opzione 1: Esecuzione Locale (Mac/Linux)

#### 1. Preparazione

```bash
cd grading-tool

# Rendi eseguibili gli script
chmod +x *.sh

# Crea la lista dei repository studenti
cp student-repos.txt.example student-repos.txt
nano student-repos.txt  # Modifica con i repository reali
```

#### 2. Esecuzione

```bash
# Correggi tutti i progetti
./grade-all.sh

# Oppure testa un singolo progetto
./test-project.sh https://github.com/student/repo.git student_id
```

#### 3. Visualizza i report

```bash
# Apri il report HTML
open reports/aggregate-report.html

# Oppure visualizza il CSV
cat reports/aggregate-report.csv

# Oppure visualizza un report JSON individuale
cat reports/student_id.json | python -m json.tool
```

### Opzione 2: GitHub Actions (Automatizzato)

> **⚠️ IMPORTANTE:** Il file `student-repos.txt` è nel `.gitignore` per proteggere la privacy.
> Per GitHub Actions, devi configurare un **GitHub Secret** o fornire input manuale.
>
> **📖 Leggi la guida completa:** [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

#### 1. Setup iniziale (una tantum - 3 minuti)

**Configurazione GitHub Secret (consigliata):**

1. Vai su **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. **Name:** `STUDENT_REPOS`
4. **Value:** Lista repository (uno per riga)
   ```
   https://github.com/student1/esonero-reti.git
   https://github.com/student2/esonero-reti.git
   ```
5. Click **"Add secret"**

✅ **Fatto!** Ora puoi eseguire il workflow automaticamente.

#### 2. Esecuzione con Secret (automatica)

1. Vai su GitHub → **Actions** → **Auto Grade Student Projects**
2. Click **"Run workflow"**
3. **Lascia il campo input VUOTO** (userà il secret)
4. Click **"Run workflow"**

#### 3. Esecuzione con Input Manuale (alternativa)

1. Vai su GitHub → **Actions** → **Auto Grade Student Projects**
2. Click **"Run workflow"**
3. **Incolla la lista** nel campo "Lista repository studenti"
4. Click **"Run workflow"**

> **💡 Tip:** Usa input manuale per test rapidi, secret per correzioni complete

#### 4. Scarica i report

1. Vai su GitHub → **Actions** → seleziona il workflow completato
2. Scorri in basso a **Artifacts**
3. Scarica:
   - `aggregate-reports` - Report CSV/HTML aggregati
   - `individual-reports` - Report JSON per ogni studente
   - `grading-logs` - Log dettagliati

## ⚙️ Configurazione

### Test Cases (`test-cases.txt`)

Personalizza i test modificando `test-cases.txt`:

```
# Format: test_name | type | city | expected_pattern | points
valid_temp_bari       | t | bari    | Temperatura = | 1
invalid_city_parigi   | t | parigi  | Città non disponibile | 1
invalid_type_x        | x | roma    | Richiesta non valida | 1
```

**Colonne:**
- `test_name`: Nome descrittivo del test
- `type`: Tipo richiesta (t, h, w, p, o carattere invalido)
- `city`: Nome città
- `expected_pattern`: Stringa attesa nell'output
- `points`: Punti assegnati se passa

### Timeout e Parametri

Modifica le variabili in `test-project.sh`:

```bash
SERVER_PORT=56700          # Porta del server
TIMEOUT_COMPILE=30         # Timeout compilazione (secondi)
TIMEOUT_TEST=10            # Timeout singolo test (secondi)
```

## 📊 Sistema di Punteggio

Il punteggio viene calcolato come:

- **Compilazione client**: 2 punti
- **Compilazione server**: 2 punti
- **Ogni test passato**: 1 punto (configurabile)

**Esempio:**
- Compilazione OK: 4 punti
- 15 test configurati: 15 punti
- **Totale massimo**: 19 punti

## 📈 Report Generati

### 1. Report JSON Individuale (`reports/student_id.json`)

```json
{
  "student_id": "student123",
  "repository": "https://github.com/student/repo.git",
  "timestamp": "2025-11-15T10:30:00+01:00",
  "clone_status": "OK",
  "compilation_client": "OK",
  "compilation_server": "OK",
  "client_warnings": 2,
  "server_warnings": 0,
  "tests": [
    {
      "name": "valid_temp_bari",
      "result": "PASS",
      "expected": "Temperatura =",
      "actual": "match",
      "score": 1
    }
  ],
  "total_score": 18,
  "max_score": 19,
  "percentage": 94.7,
  "duration_seconds": 12
}
```

### 2. Report CSV Aggregato (`reports/aggregate-report.csv`)

```csv
Student ID,Repository,Clone,Client Compile,Server Compile,...
student1,https://...,OK,OK,OK,...
student2,https://...,OK,FAIL,OK,...
```

### 3. Report HTML Aggregato (`reports/aggregate-report.html`)

Report visuale con:
- Statistiche generali
- Tabella risultati con filtri
- Progress bar per ogni studente
- Indicatori visivi colorati

## 🔧 Troubleshooting

### GitHub Actions non trova student-repos.txt

**Problema:** Il workflow fallisce con "Error: student-repos.txt not found"

**Causa:** Il file è nel `.gitignore` per privacy e non viene committato

**Soluzione:** Configura un GitHub Secret o usa input manuale

📖 **Guida completa:** [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

**Quick fix:**
1. Settings → Secrets → New secret
2. Name: `STUDENT_REPOS`
3. Value: lista repository (uno per riga)
4. Actions → Run workflow (lascia input vuoto)

### Il server non si avvia durante i test

**Problema:** Il server crasha all'avvio

**Soluzione:** Verifica i log in `temp/student_id/server.log`:

```bash
cat grading-tool/temp/student_id/server.log
```

### Timeout durante i test

**Problema:** Test troppo lenti

**Soluzione:** Aumenta i timeout in `test-project.sh`:

```bash
TIMEOUT_TEST=20  # Invece di 10
```

### Errori di compilazione non rilevati

**Problema:** GCC non installato o versione diversa

**Soluzione:** Verifica GCC:

```bash
gcc --version
```

Per GitHub Actions, è già installato.

### Repository privati

**Problema:** Non riesce a clonare repository privati

**Soluzione locale:** Usa SSH o configura credenziali:

```bash
git config --global credential.helper store
```

**Soluzione GitHub Actions:** Aggiungi un Personal Access Token:

1. GitHub Settings → Developer settings → Personal access tokens
2. Genera token con permessi `repo`
3. Aggiungi come secret nel repository: `Settings → Secrets → GITHUB_TOKEN`
4. Modifica il workflow per usare il token

## 🎯 Best Practices

### Per il Docente

1. **Test incrementali**: Inizia con pochi test e aggiungi man mano
2. **Revisione manuale**: Usa i report come base, rivedi casi dubbi manualmente
3. **Backup report**: Salva i report prima della consegna finale
4. **Test dry-run**: Testa il sistema con repository di esempio prima

### Personalizzazioni Utili

#### Eseguire test in parallelo (velocizza la correzione)

Modifica `grade-all.sh` per test paralleli:

```bash
# All'inizio dello script
PARALLEL_JOBS=4  # Esegui 4 progetti in parallelo
```

Poi installa GNU parallel:

```bash
brew install parallel  # Mac
sudo apt-get install parallel  # Linux
```

#### Aggiungere controlli anti-plagio

Aggiungi alla fine di `test-project.sh`:

```bash
# Calcola hash dei file sorgente
find client-project/src -name "*.c" -exec md5sum {} \; > "$REPORT_DIR/$STUDENT_ID.hash"
```

#### Email automatica dei risultati

Integra con `mail` o servizi SMTP:

```bash
# In generate-report.sh
echo "Report attached" | mail -s "Grading Complete" -a aggregate-report.html prof@university.it
```

## 📝 Esempi Avanzati

### Testare solo progetti modificati recentemente

```bash
# Filtra repository per data ultimo commit
while read repo; do
    if git ls-remote "$repo" | grep -q "$(date -d '7 days ago' +%Y-%m-%d)"; then
        ./test-project.sh "$repo"
    fi
done < student-repos.txt
```

### Generare statistiche per domanda frequente

```bash
# Conta quanti studenti hanno usato strcasecmp per case-insensitive
grep -r "strcasecmp" temp/*/server-project/src/*.c | wc -l
```

### Esportare in formato per registro elettronico

Modifica `generate-report.sh` per generare formato compatibile:

```bash
# Aggiungi dopo la generazione CSV
awk -F',' 'NR>1 {print $1 ";" $11}' aggregate-report.csv > voti.csv
```

## 🛡️ Sicurezza

⚠️ **Attenzione:**
- Gli script eseguono codice studenti **non verificato**
- Usa sempre una VM o container per esecuzioni massive
- I timeout prevengono loop infiniti ma non esecuzione di codice malevolo

**Raccomandazioni:**
- Esegui in ambiente isolato
- Verifica manualmente repository sospetti
- Non eseguire come root
- Per GitHub Actions, il sandbox è già fornito

## 📄 Licenza

Questo sistema di grading è fornito come strumento didattico.
Modificalo liberamente secondo le esigenze del corso.

## 🤝 Contributi

Per miglioramenti o bug:
1. Testa le modifiche localmente
2. Documenta i cambiamenti
3. Condividi con il team docente

---

**Versione:** 1.0.0
**Ultimo aggiornamento:** Novembre 2025
**Compatibilità:** macOS, Linux, GitHub Actions (Ubuntu)
