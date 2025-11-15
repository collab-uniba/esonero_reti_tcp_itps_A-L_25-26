#!/bin/bash
################################################################################
# run-tests.sh - Esegue test funzionali sul client/server
#
# Usage: ./run-tests.sh <work_directory> [port]
#
# Legge test-cases.txt ed esegue tutti i test cases definiti.
# Output: JSON array con risultati dei test
################################################################################

WORK_DIR=${1:-.}
SERVER_PORT=${2:-56700}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_CASES_FILE="$SCRIPT_DIR/test-cases.txt"
TIMEOUT_TEST=10

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$WORK_DIR" || exit 1

# Array per risultati
declare -a RESULTS=()

# Funzione per eseguire un singolo test
run_test() {
    local test_name=$1
    local request_type=$2
    local request_city=$3
    local expected_pattern=$4
    local points=$5

    # Esegui il client
    local output=$(timeout $TIMEOUT_TEST ./client-project/client -p $SERVER_PORT -r "$request_type $request_city" 2>&1 || echo "TIMEOUT_ERROR")

    # Verifica il risultato
    if echo "$output" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✓${NC} $test_name" >&2
        RESULTS+=("{\"name\":\"$test_name\",\"result\":\"PASS\",\"expected\":\"$expected_pattern\",\"actual\":\"match\",\"score\":$points}")
    else
        echo -e "${RED}✗${NC} $test_name" >&2
        # Escape delle virgolette nell'output
        local escaped_output=$(echo "$output" | sed 's/"/\\"/g' | tr '\n' ' ' | head -c 100)
        RESULTS+=("{\"name\":\"$test_name\",\"result\":\"FAIL\",\"expected\":\"$expected_pattern\",\"actual\":\"$escaped_output\",\"score\":0}")
    fi
}

# Leggi test cases se il file esiste
if [ ! -f "$TEST_CASES_FILE" ]; then
    echo -e "${YELLOW}Warning: test-cases.txt not found, using default tests${NC}" >&2

    # Test di default
    run_test "valid_temp_bari" "t" "bari" "Temperatura =" 1
    run_test "valid_humid_milano" "h" "milano" "Umidità =" 1
    run_test "valid_wind_roma" "w" "roma" "Vento =" 1
    run_test "valid_press_napoli" "p" "napoli" "Pressione =" 1
    run_test "invalid_city" "t" "parigi" "Città non disponibile" 1
    run_test "invalid_type" "x" "roma" "Richiesta non valida" 1
    run_test "case_insensitive" "t" "BARI" "Temperatura =" 1
    run_test "city_with_space" "p" "Reggio Calabria" "Pressione =" 1

else
    # Leggi test cases da file
    # || [ -n "$test_name" ] gestisce l'ultima riga anche senza newline finale
    while IFS='|' read -r test_name request_type request_city expected_pattern points || [ -n "$test_name" ]; do
        # Salta linee vuote e commenti
        [[ -z "$test_name" || "$test_name" =~ ^#.*$ ]] && continue

        # Trim whitespace
        test_name=$(echo "$test_name" | xargs)
        request_type=$(echo "$request_type" | xargs)
        request_city=$(echo "$request_city" | xargs)
        expected_pattern=$(echo "$expected_pattern" | xargs)
        points=$(echo "$points" | xargs)

        run_test "$test_name" "$request_type" "$request_city" "$expected_pattern" "$points"
    done < "$TEST_CASES_FILE"
fi

# Output JSON array
echo -n "["
for i in "${!RESULTS[@]}"; do
    echo -n "${RESULTS[$i]}"
    if [ $i -lt $((${#RESULTS[@]} - 1)) ]; then
        echo -n ","
    fi
done
echo "]"

exit 0
