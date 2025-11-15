#!/bin/bash
################################################################################
# generate-report.sh - Genera report aggregato da JSON individuali
#
# Usage: ./generate-report.sh
#
# Legge tutti i file JSON nella directory reports/ e genera:
# - aggregate-report.csv: Report in formato CSV
# - aggregate-report.html: Report in formato HTML
################################################################################

set -e

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/reports"
CSV_FILE="$REPORT_DIR/aggregate-report.csv"
HTML_FILE="$REPORT_DIR/aggregate-report.html"

# Verifica che esistano report
if [ ! -d "$REPORT_DIR" ] || [ -z "$(ls -A "$REPORT_DIR"/*.json 2>/dev/null)" ]; then
    echo -e "${YELLOW}Warning: No JSON reports found in $REPORT_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Generating aggregate report...${NC}"

# Genera CSV header
echo "Student ID,Repository,Clone,Client Compile,Server Compile,Client Warnings,Server Warnings,Tests Passed,Tests Total,Score,Max Score,Percentage,Duration (s),Timestamp" > "$CSV_FILE"

# Variabili per statistiche
TOTAL_STUDENTS=0
TOTAL_PASSED_COMPILE=0
TOTAL_SCORE_SUM=0
TOTAL_MAX_SCORE_SUM=0

# Processa ogni file JSON
for json_file in "$REPORT_DIR"/*.json; do
    [ -e "$json_file" ] || continue

    TOTAL_STUDENTS=$((TOTAL_STUDENTS + 1))

    # Estrai dati usando grep e sed (più portabile di jq)
    student_id=$(grep -o '"student_id": *"[^"]*"' "$json_file" | sed 's/"student_id": *"\([^"]*\)"/\1/')
    repository=$(grep -o '"repository": *"[^"]*"' "$json_file" | sed 's/"repository": *"\([^"]*\)"/\1/')
    clone_status=$(grep -o '"clone_status": *"[^"]*"' "$json_file" | sed 's/"clone_status": *"\([^"]*\)"/\1/')
    comp_client=$(grep -o '"compilation_client": *"[^"]*"' "$json_file" | sed 's/"compilation_client": *"\([^"]*\)"/\1/')
    comp_server=$(grep -o '"compilation_server": *"[^"]*"' "$json_file" | sed 's/"compilation_server": *"\([^"]*\)"/\1/')
    client_warn=$(grep -o '"client_warnings": *[0-9]*' "$json_file" | sed 's/"client_warnings": *\([0-9]*\)/\1/' || echo "0")
    server_warn=$(grep -o '"server_warnings": *[0-9]*' "$json_file" | sed 's/"server_warnings": *\([0-9]*\)/\1/' || echo "0")
    total_score=$(grep -o '"total_score": *[0-9]*' "$json_file" | sed 's/"total_score": *\([0-9]*\)/\1/')
    max_score=$(grep -o '"max_score": *[0-9]*' "$json_file" | sed 's/"max_score": *\([0-9]*\)/\1/')
    percentage=$(grep -o '"percentage": *[0-9.]*' "$json_file" | sed 's/"percentage": *\([0-9.]*\)/\1/')
    duration=$(grep -o '"duration_seconds": *[0-9]*' "$json_file" | sed 's/"duration_seconds": *\([0-9]*\)/\1/')
    timestamp=$(grep -o '"timestamp": *"[^"]*"' "$json_file" | sed 's/"timestamp": *"\([^"]*\)"/\1/')

    # Conta test passati
    tests_passed=$(grep -o '"result": *"PASS"' "$json_file" | wc -l | tr -d ' ')
    tests_total=$(grep -o '"result":' "$json_file" | wc -l | tr -d ' ')

    # Statistiche
    if [ "$comp_client" == "OK" ] && [ "$comp_server" == "OK" ]; then
        TOTAL_PASSED_COMPILE=$((TOTAL_PASSED_COMPILE + 1))
    fi
    TOTAL_SCORE_SUM=$((TOTAL_SCORE_SUM + total_score))
    TOTAL_MAX_SCORE_SUM=$((TOTAL_MAX_SCORE_SUM + max_score))

    # Scrivi riga CSV
    echo "$student_id,$repository,$clone_status,$comp_client,$comp_server,$client_warn,$server_warn,$tests_passed,$tests_total,$total_score,$max_score,$percentage,$duration,$timestamp" >> "$CSV_FILE"
done

echo -e "${GREEN}✓${NC} CSV report generated: $CSV_FILE"

# Genera HTML report
cat > "$HTML_FILE" <<'EOF'
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Grading Report - Esonero Reti TCP</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
        }
        header h1 { font-size: 28px; margin-bottom: 10px; }
        header p { opacity: 0.9; }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-card h3 {
            font-size: 14px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 10px;
        }
        .stat-card .value {
            font-size: 32px;
            font-weight: bold;
            color: #333;
        }
        .stat-card .subtext {
            font-size: 12px;
            color: #999;
            margin-top: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        thead {
            background: #f8f9fa;
            position: sticky;
            top: 0;
        }
        th {
            text-align: left;
            padding: 15px;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #dee2e6;
            font-size: 13px;
            text-transform: uppercase;
        }
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #f0f0f0;
        }
        tbody tr:hover {
            background: #f8f9fa;
        }
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .badge.ok { background: #d4edda; color: #155724; }
        .badge.fail { background: #f8d7da; color: #721c24; }
        .badge.na { background: #e2e3e5; color: #383d41; }
        .score {
            font-weight: 600;
            font-size: 14px;
        }
        .score.high { color: #28a745; }
        .score.medium { color: #ffc107; }
        .score.low { color: #dc3545; }
        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 5px;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transition: width 0.3s;
        }
        footer {
            text-align: center;
            padding: 20px;
            color: #999;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>📊 Report Correzione Automatica</h1>
            <p>Esonero Reti TCP - A.A. 2025-26</p>
        </header>

        <div class="stats">
            <div class="stat-card">
                <h3>Progetti Testati</h3>
                <div class="value">__TOTAL_STUDENTS__</div>
            </div>
            <div class="stat-card">
                <h3>Compilazione OK</h3>
                <div class="value">__TOTAL_PASSED_COMPILE__</div>
                <div class="subtext">__COMPILE_PERCENTAGE__% del totale</div>
            </div>
            <div class="stat-card">
                <h3>Score Medio</h3>
                <div class="value">__AVG_SCORE__</div>
                <div class="subtext">su __MAX_SCORE__ punti</div>
            </div>
            <div class="stat-card">
                <h3>Percentuale Media</h3>
                <div class="value">__AVG_PERCENTAGE__%</div>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Student ID</th>
                    <th>Clone</th>
                    <th>Client</th>
                    <th>Server</th>
                    <th>Warnings</th>
                    <th>Tests</th>
                    <th>Score</th>
                    <th>Progress</th>
                </tr>
            </thead>
            <tbody>
                __TABLE_ROWS__
            </tbody>
        </table>

        <footer>
            Generated on __GENERATION_DATE__
        </footer>
    </div>
</body>
</html>
EOF

# Genera righe tabella HTML
TABLE_ROWS=""
while IFS=, read -r student_id repository clone_status comp_client comp_server client_warn server_warn tests_passed tests_total total_score max_score percentage duration timestamp; do
    # Salta header
    [ "$student_id" == "Student ID" ] && continue

    # Determina classe score
    score_class="low"
    if (( $(echo "$percentage >= 70" | bc -l) )); then
        score_class="high"
    elif (( $(echo "$percentage >= 50" | bc -l) )); then
        score_class="medium"
    fi

    # Badge status
    clone_badge="<span class='badge fail'>$clone_status</span>"
    [ "$clone_status" == "OK" ] && clone_badge="<span class='badge ok'>$clone_status</span>"

    client_badge="<span class='badge fail'>$comp_client</span>"
    [ "$comp_client" == "OK" ] && client_badge="<span class='badge ok'>$comp_client</span>"
    [ "$comp_client" == "N/A" ] && client_badge="<span class='badge na'>$comp_client</span>"

    server_badge="<span class='badge fail'>$comp_server</span>"
    [ "$comp_server" == "OK" ] && server_badge="<span class='badge ok'>$comp_server</span>"
    [ "$comp_server" == "N/A" ] && server_badge="<span class='badge na'>$comp_server</span>"

    total_warnings=$((client_warn + server_warn))

    TABLE_ROWS+="<tr>"
    TABLE_ROWS+="<td><strong>$student_id</strong></td>"
    TABLE_ROWS+="<td>$clone_badge</td>"
    TABLE_ROWS+="<td>$client_badge</td>"
    TABLE_ROWS+="<td>$server_badge</td>"
    TABLE_ROWS+="<td>$total_warnings</td>"
    TABLE_ROWS+="<td>$tests_passed/$tests_total</td>"
    TABLE_ROWS+="<td><span class='score $score_class'>$total_score/$max_score</span></td>"
    TABLE_ROWS+="<td><div class='progress-bar'><div class='progress-fill' style='width: $percentage%'></div></div><small>$percentage%</small></td>"
    TABLE_ROWS+="</tr>"
done < "$CSV_FILE"

# Calcola statistiche
AVG_SCORE=0
AVG_PERCENTAGE=0
COMPILE_PERCENTAGE=0
if [ $TOTAL_STUDENTS -gt 0 ]; then
    AVG_SCORE=$(awk "BEGIN {printf \"%.1f\", $TOTAL_SCORE_SUM/$TOTAL_STUDENTS}")
    AVG_PERCENTAGE=$(awk "BEGIN {printf \"%.1f\", ($TOTAL_SCORE_SUM*100)/($TOTAL_MAX_SCORE_SUM)}")
    COMPILE_PERCENTAGE=$(awk "BEGIN {printf \"%.0f\", ($TOTAL_PASSED_COMPILE*100)/$TOTAL_STUDENTS}")
fi

# Sostituisci placeholder
sed -i.bak "s|__TOTAL_STUDENTS__|$TOTAL_STUDENTS|g" "$HTML_FILE"
sed -i.bak "s|__TOTAL_PASSED_COMPILE__|$TOTAL_PASSED_COMPILE|g" "$HTML_FILE"
sed -i.bak "s|__COMPILE_PERCENTAGE__|$COMPILE_PERCENTAGE|g" "$HTML_FILE"
sed -i.bak "s|__AVG_SCORE__|$AVG_SCORE|g" "$HTML_FILE"
sed -i.bak "s|__MAX_SCORE__|$(awk "BEGIN {printf \"%.0f\", $TOTAL_MAX_SCORE_SUM/$TOTAL_STUDENTS}")|g" "$HTML_FILE"
sed -i.bak "s|__AVG_PERCENTAGE__|$AVG_PERCENTAGE|g" "$HTML_FILE"
sed -i.bak "s|__TABLE_ROWS__|$TABLE_ROWS|g" "$HTML_FILE"
sed -i.bak "s|__GENERATION_DATE__|$(date)|g" "$HTML_FILE"

rm -f "$HTML_FILE.bak"

echo -e "${GREEN}✓${NC} HTML report generated: $HTML_FILE"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  Total students: $TOTAL_STUDENTS"
echo "  Compiled successfully: $TOTAL_PASSED_COMPILE ($COMPILE_PERCENTAGE%)"
echo "  Average score: $AVG_SCORE"
echo "  Average percentage: $AVG_PERCENTAGE%"

exit 0
