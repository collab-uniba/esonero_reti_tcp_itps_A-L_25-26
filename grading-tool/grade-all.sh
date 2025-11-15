#!/bin/bash
################################################################################
# grade-all.sh - Corregge tutti i progetti da una lista
#
# Usage: ./grade-all.sh [student_repos_file]
#
# Legge un file con la lista dei repository (uno per riga) e li testa tutti.
# Genera report JSON individuali e un report aggregato finale.
################################################################################

set -e

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurazione
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_FILE=${1:-"$SCRIPT_DIR/student-repos.txt"}
REPORT_DIR="$SCRIPT_DIR/reports"
TEMP_DIR="$SCRIPT_DIR/temp"
PARALLEL_JOBS=${PARALLEL_JOBS:-1}  # Numero di test paralleli (default: 1)

# Validazione
if [ ! -f "$REPOS_FILE" ]; then
    echo -e "${RED}Error: Repository list file not found: $REPOS_FILE${NC}"
    echo "Usage: $0 [student_repos_file]"
    echo ""
    echo "Create a file with one repository URL per line:"
    echo "  https://github.com/student1/repo.git"
    echo "  https://github.com/student2/repo.git"
    exit 1
fi

# Pulizia e inizializzazione
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Auto Grading System${NC}"
echo -e "${BLUE}========================================${NC}"

# Pulisci report e temp precedenti
if [ -d "$REPORT_DIR" ]; then
    echo -e "${YELLOW}Cleaning previous reports...${NC}"
    rm -rf "$REPORT_DIR"
fi
mkdir -p "$REPORT_DIR"

if [ -d "$TEMP_DIR" ]; then
    echo -e "${YELLOW}Cleaning temporary files...${NC}"
    rm -rf "$TEMP_DIR"
fi
mkdir -p "$TEMP_DIR"

# Conta repository
TOTAL_REPOS=$(grep -v '^#' "$REPOS_FILE" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
echo -e "${BLUE}Total repositories to test: $TOTAL_REPOS${NC}"
echo ""

# Variabili per statistiche
CURRENT=0
PASSED=0
FAILED=0
START_TIME=$(date +%s)

# Funzione per testare un singolo repository
test_repository() {
    local repo_url=$1
    local student_id=$(basename "$repo_url" .git)

    # Se il repo URL contiene un identificativo studente, estrailo
    if [[ "$repo_url" =~ /([^/]+)/[^/]+\.git$ ]]; then
        student_id="${BASH_REMATCH[1]}_$(basename "$repo_url" .git)"
    fi

    echo -e "${YELLOW}[$((CURRENT))/$TOTAL_REPOS]${NC} Testing: $student_id"

    # Esegui il test
    if bash "$SCRIPT_DIR/test-project.sh" "$repo_url" "$student_id" > "$TEMP_DIR/${student_id}.log" 2>&1; then
        echo -e "${GREEN}✓${NC} $student_id completed"
        return 0
    else
        echo -e "${RED}✗${NC} $student_id failed"
        return 1
    fi
}

# Esegui test per ogni repository
# || [ -n "$repo_url" ] gestisce l'ultima riga anche senza newline finale
while IFS= read -r repo_url || [ -n "$repo_url" ]; do
    # Salta linee vuote e commenti
    [[ -z "$repo_url" || "$repo_url" =~ ^#.*$ ]] && continue

    CURRENT=$((CURRENT + 1))

    if test_repository "$repo_url"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi

    echo ""
done < "$REPOS_FILE"

# Genera report aggregato
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Generating aggregate report...${NC}"
bash "$SCRIPT_DIR/generate-report.sh"

# Statistiche finali
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Grading Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total repositories: $TOTAL_REPOS"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "Duration: ${MINUTES}m ${SECONDS}s"
echo ""
echo -e "Reports available in: ${YELLOW}$REPORT_DIR${NC}"
echo -e "  - Individual reports: ${YELLOW}*.json${NC}"
echo -e "  - Aggregate CSV: ${YELLOW}aggregate-report.csv${NC}"
echo -e "  - Aggregate HTML: ${YELLOW}aggregate-report.html${NC}"
echo -e "${BLUE}========================================${NC}"

exit 0
