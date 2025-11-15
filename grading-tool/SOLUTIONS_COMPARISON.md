# Soluzioni Alternative per Lista Repository

## Opzione 1: GitHub Secrets (Implementata)

**Setup:**
```
Settings → Secrets → STUDENT_REPOS = (lista repository)
```

**Pro:** Sicuro, automatizzabile
**Contro:** Richiede configurazione
**Quando:** Produzione

---

## Opzione 2: File Committato

**Setup:**
```bash
sed -i '/student-repos.txt/d' grading-tool/.gitignore
git add grading-tool/student-repos.txt
git commit -m "Add repos"
```

**Pro:** Semplice
**Contro:** Lista pubblica
**Quando:** MAI per dati reali

---

## Opzione 3: Branch Separato

**Setup:**
```bash
git checkout -b grading-data
sed -i '/student-repos.txt/d' grading-tool/.gitignore
echo "https://github.com/..." > grading-tool/student-repos.txt
git add . && git commit -m "Add data"
git push -u origin grading-data
```

Poi proteggi il branch: Settings → Branches → Add rule

**Pro:** Separazione codice/dati
**Contro:** Gestione complessa
**Quando:** Repository privati grandi

---

## Raccomandazione

**Usa Opzione 1 (GitHub Secrets)** salvo casi particolari.
