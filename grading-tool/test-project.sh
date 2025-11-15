#!/bin/bash
################################################################################
# test-project.sh - Testa un singolo repository studente
#
# Usage: ./test-project.sh <repository_url> [student_id]
#
# Clona il repository, compila client e server, esegue test funzionali,
# e genera un report JSON dettagliato.
################################################################################

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurazione
REPO_URL=$1
STUDENT_ID=${2:-$(basename "$REPO_URL" .git)}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/reports"
TEMP_DIR="$SCRIPT_DIR/temp"
WORK_DIR="$TEMP_DIR/$STUDENT_ID"
SERVER_PORT=56700
TIMEOUT_COMPILE=30
TIMEOUT_TEST=10

# Validazione argomenti
if [ -z "$REPO_URL" ]; then
    echo "Usage: $0 <repository_url> [student_id]"
    exit 1
fi

# Inizializzazione
mkdir -p "$REPORT_DIR"
mkdir -p "$TEMP_DIR"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Testing: $STUDENT_ID${NC}"
echo -e "${YELLOW}========================================${NC}"

# Cleanup precedente
if [ -d "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
fi

# Variabili per il report
COMPILATION_CLIENT="FAIL"
COMPILATION_SERVER="FAIL"
CLONE_STATUS="FAIL"
declare -a TEST_RESULTS=()
START_TIME=$(date +%s)

# 1. Clone repository
echo -e "\n${YELLOW}[1/4]${NC} Cloning repository..."
if timeout $TIMEOUT_COMPILE git clone --quiet --depth 1 "$REPO_URL" "$WORK_DIR" 2>/dev/null; then
    CLONE_STATUS="OK"
    echo -e "${GREEN}✓ Clone successful${NC}"
else
    echo -e "${RED}✗ Clone failed${NC}"
    # Genera report e esci
    cat > "$REPORT_DIR/$STUDENT_ID.json" <<EOF
{
  "student_id": "$STUDENT_ID",
  "repository": "$REPO_URL",
  "timestamp": "$(date -Iseconds)",
  "clone_status": "$CLONE_STATUS",
  "compilation_client": "N/A",
  "compilation_server": "N/A",
  "tests": [],
  "total_score": 0,
  "max_score": 0,
  "duration_seconds": $(($(date +%s) - START_TIME))
}
EOF
    exit 1
fi

cd "$WORK_DIR"

# 2. Compilazione Client
echo -e "\n${YELLOW}[2/4]${NC} Compiling client..."
CLIENT_COMPILE_OUTPUT=$(mktemp)
if timeout $TIMEOUT_COMPILE gcc -o client-project/client client-project/src/*.c -Wall -Wextra 2>"$CLIENT_COMPILE_OUTPUT"; then
    COMPILATION_CLIENT="OK"
    echo -e "${GREEN}✓ Client compilation successful${NC}"
else
    COMPILATION_CLIENT="FAIL"
    echo -e "${RED}✗ Client compilation failed${NC}"
    cat "$CLIENT_COMPILE_OUTPUT"
fi
CLIENT_WARNINGS=$(grep -c "warning:" "$CLIENT_COMPILE_OUTPUT" 2>/dev/null || echo "0")

# 3. Compilazione Server
echo -e "\n${YELLOW}[3/4]${NC} Compiling server..."
SERVER_COMPILE_OUTPUT=$(mktemp)
if timeout $TIMEOUT_COMPILE gcc -o server-project/server server-project/src/*.c -Wall -Wextra 2>"$SERVER_COMPILE_OUTPUT"; then
    COMPILATION_SERVER="OK"
    echo -e "${GREEN}✓ Server compilation successful${NC}"
else
    COMPILATION_SERVER="FAIL"
    echo -e "${RED}✗ Server compilation failed${NC}"
    cat "$SERVER_COMPILE_OUTPUT"
fi
SERVER_WARNINGS=$(grep -c "warning:" "$SERVER_COMPILE_OUTPUT" 2>/dev/null || echo "0")

# 4. Test funzionali (solo se entrambe le compilazioni sono OK)
echo -e "\n${YELLOW}[4/4]${NC} Running functional tests..."

if [ "$COMPILATION_CLIENT" == "OK" ] && [ "$COMPILATION_SERVER" == "OK" ]; then
    # Avvia il server in background
    ./server-project/server -p $SERVER_PORT > server.log 2>&1 &
    SERVER_PID=$!

    # Attendi che il server sia pronto
    sleep 2

    # Verifica che il server sia ancora in esecuzione
    if ! kill -0 $SERVER_PID 2>/dev/null; then
        echo -e "${RED}✗ Server failed to start${NC}"
        TEST_RESULTS+=('{"name":"server_start","result":"FAIL","expected":"server running","actual":"server crashed","score":0}')
    else
        # Esegui i test usando run-tests.sh se esiste
        if [ -f "$SCRIPT_DIR/run-tests.sh" ]; then
            # Salva il report dei test in un file temporaneo
            TEST_REPORT=$(mktemp)
            bash "$SCRIPT_DIR/run-tests.sh" "$WORK_DIR" $SERVER_PORT > "$TEST_REPORT"

            # Leggi i risultati (formato JSON array)
            if [ -f "$TEST_REPORT" ]; then
                TEST_RESULTS_JSON=$(cat "$TEST_REPORT")
            fi
        else
            # Test di base manuale
            echo "Running basic tests..."

            # Test 1: Richiesta valida - temperatura Bari
            TEST_OUTPUT=$(timeout $TIMEOUT_TEST ./client-project/client -p $SERVER_PORT -r "t bari" 2>&1 || echo "TIMEOUT")
            if echo "$TEST_OUTPUT" | grep -q "Temperatura ="; then
                echo -e "${GREEN}✓ Test 1: Valid request (t bari)${NC}"
                TEST_RESULTS+=('{"name":"valid_request_temp","result":"PASS","expected":"Temperatura =","actual":"found","score":1}')
            else
                echo -e "${RED}✗ Test 1: Valid request (t bari)${NC}"
                TEST_RESULTS+=('{"name":"valid_request_temp","result":"FAIL","expected":"Temperatura =","actual":"'"$TEST_OUTPUT"'","score":0}')
            fi

            # Test 2: Città non valida
            TEST_OUTPUT=$(timeout $TIMEOUT_TEST ./client-project/client -p $SERVER_PORT -r "h invalidcity" 2>&1 || echo "TIMEOUT")
            if echo "$TEST_OUTPUT" | grep -q "Città non disponibile"; then
                echo -e "${GREEN}✓ Test 2: Invalid city${NC}"
                TEST_RESULTS+=('{"name":"invalid_city","result":"PASS","expected":"Città non disponibile","actual":"found","score":1}')
            else
                echo -e "${RED}✗ Test 2: Invalid city${NC}"
                TEST_RESULTS+=('{"name":"invalid_city","result":"FAIL","expected":"Città non disponibile","actual":"'"$TEST_OUTPUT"'","score":0}')
            fi

            # Test 3: Tipo richiesta non valido
            TEST_OUTPUT=$(timeout $TIMEOUT_TEST ./client-project/client -p $SERVER_PORT -r "x roma" 2>&1 || echo "TIMEOUT")
            if echo "$TEST_OUTPUT" | grep -q "Richiesta non valida"; then
                echo -e "${GREEN}✓ Test 3: Invalid request type${NC}"
                TEST_RESULTS+=('{"name":"invalid_type","result":"PASS","expected":"Richiesta non valida","actual":"found","score":1}')
            else
                echo -e "${RED}✗ Test 3: Invalid request type${NC}"
                TEST_RESULTS+=('{"name":"invalid_type","result":"FAIL","expected":"Richiesta non valida","actual":"'"$TEST_OUTPUT"'","score":0}')
            fi
        fi
    fi

    # Termina il server
    if kill -0 $SERVER_PID 2>/dev/null; then
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
else
    echo -e "${RED}Skipping tests (compilation failed)${NC}"
fi

# 5. Calcola punteggio
TOTAL_SCORE=0
MAX_SCORE=0

# Punteggio compilazione
if [ "$COMPILATION_CLIENT" == "OK" ]; then
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
fi
if [ "$COMPILATION_SERVER" == "OK" ]; then
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
fi
MAX_SCORE=$((MAX_SCORE + 4))

# Punteggio test
for test in "${TEST_RESULTS[@]}"; do
    score=$(echo "$test" | grep -o '"score":[0-9]*' | cut -d':' -f2)
    TOTAL_SCORE=$((TOTAL_SCORE + score))
    MAX_SCORE=$((MAX_SCORE + 1))
done

# 6. Genera report JSON
TESTS_JSON=""
if [ ${#TEST_RESULTS[@]} -gt 0 ]; then
    TESTS_JSON=$(IFS=','; echo "${TEST_RESULTS[*]}")
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Calcola percentuale (compatibile macOS e Linux)
if [ $MAX_SCORE -gt 0 ]; then
    PERCENTAGE=$(echo "scale=1; $TOTAL_SCORE * 100 / $MAX_SCORE" | bc)
else
    PERCENTAGE="0.0"
fi

cat > "$REPORT_DIR/$STUDENT_ID.json" <<EOF
{
  "student_id": "$STUDENT_ID",
  "repository": "$REPO_URL",
  "timestamp": "$(date -Iseconds)",
  "clone_status": "$CLONE_STATUS",
  "compilation_client": "$COMPILATION_CLIENT",
  "compilation_server": "$COMPILATION_SERVER",
  "client_warnings": $CLIENT_WARNINGS,
  "server_warnings": $SERVER_WARNINGS,
  "tests": [$TESTS_JSON],
  "total_score": $TOTAL_SCORE,
  "max_score": $MAX_SCORE,
  "percentage": $PERCENTAGE,
  "duration_seconds": $DURATION
}
EOF

echo -e "\n${YELLOW}========================================${NC}"
echo -e "${GREEN}Score: $TOTAL_SCORE/$MAX_SCORE ($PERCENTAGE%)${NC}"
echo -e "${YELLOW}Report saved: $REPORT_DIR/$STUDENT_ID.json${NC}"
echo -e "${YELLOW}========================================${NC}"

# Cleanup (opzionale - commenta se vuoi ispezionare i file)
# rm -rf "$WORK_DIR"

exit 0
