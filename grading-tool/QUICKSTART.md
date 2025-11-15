# 🚀 Quick Start Guide - Test del Sistema

## Test Rapido (5 minuti)

### 1. Preparazione

```bash
cd grading-tool

# Verifica che gli script siano eseguibili
ls -la *.sh

# Se non lo sono:
chmod +x *.sh
```

### 2. Crea un file di test con un repository pubblico

```bash
# Usa questo repository template come esempio
cat > student-repos-test.txt <<EOF
https://github.com/collab-uniba/esonero_reti_tcp_itps_A-L_25-26.git
EOF
```

### 3. Esegui il test

```bash
# Test singolo progetto
./test-project.sh https://github.com/collab-uniba/esonero_reti_tcp_itps_A-L_25-26.git template_test

# Oppure test completo
./grade-all.sh student-repos-test.txt
```

### 4. Visualizza i risultati

```bash
# Visualizza il report JSON
cat reports/template_test.json

# Se hai jq installato (per formattazione migliore):
cat reports/template_test.json | jq .

# Visualizza il report HTML (su Mac)
open reports/aggregate-report.html

# Su Linux
xdg-open reports/aggregate-report.html

# Oppure apri manualmente il file HTML nel browser
```

## Verifiche Veloci

### ✅ Checklist pre-utilizzo

1. **Script eseguibili?**
   ```bash
   ls -la *.sh | grep "rwx"
   ```

2. **GCC installato?**
   ```bash
   gcc --version
   ```

3. **Git installato?**
   ```bash
   git --version
   ```

4. **bc installato?** (per calcoli matematici)
   ```bash
   bc --version
   # Se non installato:
   # Mac: brew install bc
   # Linux: sudo apt-get install bc
   ```

### 🧪 Test dei singoli componenti

#### Test 1: Solo compilazione

```bash
# Clona manualmente un repository
git clone https://github.com/student/repo.git temp/test-student
cd temp/test-student

# Testa compilazione client
gcc -o client-project/client client-project/src/*.c -Wall -Wextra

# Testa compilazione server
gcc -o server-project/server server-project/src/*.c -Wall -Wextra
```

#### Test 2: Solo test funzionali

```bash
# Avvia il server in background
./server-project/server -p 56700 &
SERVER_PID=$!

# Esegui un test
./client-project/client -r "t bari"

# Termina il server
kill $SERVER_PID
```

#### Test 3: Script run-tests.sh

```bash
# Dal repository clonato
cd temp/test-student

# Avvia server
./server-project/server -p 56700 &
SERVER_PID=$!

# Esegui test suite
bash ../../run-tests.sh . 56700

kill $SERVER_PID
```

## Risoluzione Problemi Comuni

### Errore: "command not found: bc"

**Soluzione:**
```bash
# Mac
brew install bc

# Linux Ubuntu/Debian
sudo apt-get install bc

# Linux CentOS/RHEL
sudo yum install bc
```

### Errore: "Permission denied" durante esecuzione

**Soluzione:**
```bash
chmod +x *.sh
```

### Errore: "No such file or directory: student-repos.txt"

**Soluzione:**
```bash
# Crea il file dalla template
cp student-repos.txt.example student-repos.txt

# Oppure crea manualmente
nano student-repos.txt
```

### Server non si avvia durante i test

**Soluzione:**
```bash
# Verifica che la porta non sia già in uso
lsof -i :56700

# Se in uso, termina il processo
kill -9 <PID>

# Oppure usa una porta diversa modificando test-project.sh
```

### Test troppo lenti

**Soluzione:**
```bash
# Riduci il numero di test in test-cases.txt
# Oppure aumenta i timeout in test-project.sh
```

## Personalizzazioni Rapide

### Cambiare porta del server

Modifica in `test-project.sh`:
```bash
SERVER_PORT=56701  # Invece di 56700
```

### Ridurre i test per debug veloce

Commenta test in `test-cases.txt`:
```
# valid_temp_bari       | t | bari    | Temperatura = | 1
# valid_temp_roma       | t | roma    | Temperatura = | 1
```

### Mantenere i file temporanei per debug

Commenta in `test-project.sh` (alla fine):
```bash
# rm -rf "$WORK_DIR"  # Commentato per debug
```

## Prossimi Passi

Una volta verificato che il sistema funziona:

1. **Aggiungi i repository studenti reali** in `student-repos.txt`
2. **Personalizza i test** in `test-cases.txt` secondo le tue esigenze
3. **Configura GitHub Actions** se vuoi automazione cloud
4. **Esegui la correzione finale** con `./grade-all.sh`

---

**Pronto per la correzione?** Leggi il [README.md](README.md) completo per dettagli avanzati.
