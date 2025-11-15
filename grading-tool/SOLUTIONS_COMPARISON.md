# 🔀 Confronto Soluzioni per Lista Repository

## Il Problema

Il file `student-repos.txt` è nel `.gitignore` per proteggere la privacy. Quando GitHub Actions clona il repository, questo file non esiste.

## 🎯 Soluzioni Disponibili

### ✅ Soluzione 1: GitHub Secrets (IMPLEMENTATA - CONSIGLIATA)

**Come funziona:**
- Crei un secret `STUDENT_REPOS` nelle impostazioni GitHub
- Il workflow legge la lista dal secret
- Alternativamente puoi fornire input manuale

**Pro:**
- ✅ Sicuro - lista criptata e privata
- ✅ Automatizzabile - supporta schedule
- ✅ Facile da aggiornare
- ✅ Flessibile - supporta override manuale

**Contro:**
- ⚠️ Richiede configurazione iniziale (2 minuti)

**Quando usare:**
- ✅ Per correzioni in produzione
- ✅ Per automazione periodica
- ✅ Quando hai molti studenti (10+)

**Setup:** Vedi [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

---

### 🔄 Soluzione 2: File Committato (NON CONSIGLIATA)

**Come funziona:**
- Rimuovi `student-repos.txt` dal `.gitignore`
- Committi il file con la lista repository
- GitHub Actions lo trova automaticamente

**Pro:**
- ✅ Semplice - nessuna configurazione extra
- ✅ Trigger automatici su push

**Contro:**
- ❌ **Privacy** - lista repository pubblica
- ❌ Visibile nello storico git
- ❌ Espone informazioni studenti

**Quando usare:**
- ⚠️ **MAI** per dati reali studenti
- ✅ Solo per repository template di test

**Come implementare:**

```bash
# Modifica .gitignore
sed -i '/student-repos.txt/d' grading-tool/.gitignore

# Crea e committi il file
echo "https://github.com/test/repo.git" > grading-tool/student-repos.txt
git add grading-tool/student-repos.txt grading-tool/.gitignore
git commit -m "Add test repository list"
git push
```

---

### 📝 Soluzione 3: File Committato con Template (ALTERNATIVA)

**Come funziona:**
- Committare un file `student-repos-template.txt` con repository di esempio
- Il workflow lo copia a `student-repos.txt` se non esiste altro

**Pro:**
- ✅ Sicuro - no dati reali committati
- ✅ Fornisce esempio agli studenti
- ✅ Trigger automatici possibili

**Contro:**
- ⚠️ Richiede modifiche al workflow
- ⚠️ Meno flessibile dei secrets

**Come implementare:**

```bash
# Crea template
cat > grading-tool/student-repos-template.txt <<EOF
# Questo è un template - NON committare dati reali qui
# Usa GitHub Secrets per la lista vera
https://github.com/example/repo1.git
https://github.com/example/repo2.git
EOF

# Modifica workflow (aggiungi prima dello step "Prepare...")
- name: Use template if no other source
  run: |
    cd grading-tool
    if [ ! -f student-repos.txt ] && [ -f student-repos-template.txt ]; then
      cp student-repos-template.txt student-repos.txt
    fi

# Commit
git add grading-tool/student-repos-template.txt
git commit -m "Add repository list template"
git push
```

---

### 🌐 Soluzione 4: URL Remoto (AVANZATA)

**Come funziona:**
- Lista repository su server esterno (Google Sheets, API, ecc.)
- Workflow scarica la lista via HTTP

**Pro:**
- ✅ Centralizzato - una fonte di verità
- ✅ Aggiornabile da interfaccia web
- ✅ Può includere metadata studenti

**Contro:**
- ❌ Complesso - richiede server esterno
- ❌ Dipendenza esterna
- ❌ Richiede autenticazione

**Come implementare:**

```yaml
# Nel workflow, aggiungi step per scaricare
- name: Download repository list
  run: |
    cd grading-tool
    curl -H "Authorization: Bearer ${{ secrets.API_TOKEN }}" \
      https://your-api.com/student-repos.txt > student-repos.txt
```

---

### 💾 Soluzione 5: Branch Separato (ALTERNATIVA PRIVACY)

**Come funziona:**
- Crea un branch privato `grading-data`
- Committare `student-repos.txt` solo lì
- Workflow fa checkout di entrambi i branch

**Pro:**
- ✅ Separazione dati/codice
- ✅ Storia pulita nel main branch
- ✅ Automatizzabile

**Contro:**
- ⚠️ Complessità branch management
- ⚠️ Richiede branch protetto
- ❌ Non funziona su repository pubblici

**Come implementare:**

```bash
# Crea branch dati
git checkout -b grading-data
echo "https://github.com/student1/repo.git" > grading-tool/student-repos.txt
sed -i '/student-repos.txt/d' grading-tool/.gitignore
git add .
git commit -m "Add grading data"
git push -u origin grading-data

# Proteggi il branch (Settings → Branches → Add rule)
# Branch name: grading-data
# ✅ Require a pull request before merging
# ✅ Restrict who can push to matching branches
```

Modifica workflow:
```yaml
- name: Checkout grading tool
  uses: actions/checkout@v4

- name: Checkout grading data
  uses: actions/checkout@v4
  with:
    ref: grading-data
    path: grading-data

- name: Copy repository list
  run: |
    cp grading-data/grading-tool/student-repos.txt grading-tool/
```

---

## 📊 Tabella Comparativa

| Soluzione | Sicurezza | Semplicità | Automazione | Consigliata |
|-----------|-----------|------------|-------------|-------------|
| **1. GitHub Secrets** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ **SÌ** |
| 2. File Committato | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ❌ No |
| 3. Template File | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⚠️ Ok |
| 4. URL Remoto | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⚠️ Avanzato |
| 5. Branch Separato | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⚠️ Complesso |

## 🎓 Raccomandazioni per Caso d'Uso

### Docente con repository pubblico template

**Usa:** Soluzione 1 (GitHub Secrets)
**Perché:** Massima sicurezza senza esporre dati studenti

### Docente con repository privato di correzione

**Usa:** Soluzione 1 (GitHub Secrets) o 5 (Branch Separato)
**Perché:** Entrambe sicure, secrets più semplice

### Test e sviluppo

**Usa:** Soluzione 3 (Template File)
**Perché:** Fornisce esempi senza rischi

### Integrazione con sistema esistente

**Usa:** Soluzione 4 (URL Remoto)
**Perché:** Centralizzazione con sistema gestione studenti

## ✅ Implementazione Attuale

Il sistema attuale implementa **Soluzione 1 (GitHub Secrets)** con:

- ✅ Supporto GitHub Secrets (`STUDENT_REPOS`)
- ✅ Override con input manuale
- ✅ Validazione e error handling
- ✅ Privacy-first design
- ✅ Automazione schedulata opzionale

Vedi [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) per istruzioni d'uso.

## 🔄 Migrare tra Soluzioni

### Da "nessuna soluzione" a Secrets (2 min)

```bash
# 1. Prepara la lista locale
cat > /tmp/repos.txt <<EOF
https://github.com/student1/repo.git
https://github.com/student2/repo.git
EOF

# 2. Vai su GitHub
# Settings → Secrets → New secret
# Name: STUDENT_REPOS
# Value: <incolla contenuto di /tmp/repos.txt>

# 3. Esegui workflow
# Actions → Run workflow (lascia input vuoto)
```

### Da File Committato a Secrets (5 min)

```bash
# 1. Salva contenuto attuale
cp grading-tool/student-repos.txt /tmp/backup-repos.txt

# 2. Rimuovi dal git
git rm grading-tool/student-repos.txt
echo "student-repos.txt" >> grading-tool/.gitignore
git commit -m "Move repository list to secrets"
git push

# 3. Crea secret con contenuto salvato
# (vedi sopra)
```

---

**Conclusione:** Per la maggior parte dei casi d'uso, **Soluzione 1 (GitHub Secrets)** è la scelta ottimale.
