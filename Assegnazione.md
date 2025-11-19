# Primo Esonero di Laboratorio - Reti di Calcolatori (ITPS A-L) a.a. '25-26 

## Obiettivo

Progettare ed implementare un'applicazione TCP client/server, dove il server è un servizio meteo che risponde alle richieste del client.

## Specifica del Protocollo Applicativo

### Formato dei Messaggi

Tutti i messaggi scambiati tra client e server seguono un protocollo definito in `protocol.h`.

#### Messaggio di Richiesta (Client → Server)

```c
typedef struct {
    char type;        // Weather data type: 't', 'h', 'w', 'p'
    char city[64];    // City name (null-terminated string)
} weather_request_t;
```

**Tipi validi:**
Il campo `type` può assumere solo questi valori:
- `'t'` = Temperatura
- `'h'` = Umidità
- `'w'` = Velocità del vento
- `'p'` = Pressione

#### Messaggio di Risposta (Server → Client)

```c
typedef struct {
    unsigned int status;  // Response status code
    char type;            // Echo of request type
    float value;          // Weather data value
} weather_response_t;
```

**Codici di stato:**
Il campo `status` può assumere solo questi valori:
- `0` = Successo
- `1` = Città non disponibile
- `2` = Richiesta non valida

**Campi della risposta:**
- `status`: codice di stato della risposta
- `type`: eco del tipo di dato richiesto (`'t'`, `'h'`, `'w'`, `'p'`)
- `value`: valore numerico del dato meteo

**Il client deve costruire il messaggio da visualizzare sul terminale:**

Per risposte con successo (status = 0):
- Temperatura (type = 't'): `Nomecittà: Temperatura = XX.X°C` (1 cifra decimale)
- Umidità (type = 'h'): `Nomecittà: Umidità = XX.X%` (1 cifra decimale)
- Vento (type = 'w'): `Nomecittà: Vento = XX.X km/h` (1 cifra decimale)
- Pressione (type = 'p'): `Nomecittà: Pressione = XXXX.X hPa` (1 cifra decimale)

Per risposte con errore (status != 0):
- `Città non disponibile` (status = 1)
- `Richiesta non valida` (status = 2)

> [!WARNING]
> - Il formato dell'output deve essere **ESATTAMENTE** come specificato di seguito
> - **Lingua italiana obbligatoria** - NON tradurre in inglese o altre lingue
->  **NO caratteri extra** (es. "Received result from server IP" invece di "Ricevuto risultato dal server ip")
> - Gli **spazi e la punteggiatura** devono corrispondere esattamente agli esempi

### Funzioni di Generazione Dati

Il server deve implementare le seguenti funzioni con valori casuali entro range realistici:

```c
float get_temperature(void);    // Range: -10.0 to 40.0 °C
float get_humidity(void);       // Range: 20.0 to 100.0 %
float get_wind(void);           // Range: 0.0 to 100.0 km/h
float get_pressure(void);       // Range: 950.0 to 1050.0 hPa
```
Tutte le funzioni restituiscono valori float da inserire nel campo `value` della struttura di risposta.

## Comportamento del Client

### Interfaccia da Riga di Comando

```
./client-project [-s server] [-p port] -r "type city"
```

**Parametri:**
- `-s server`: Indirizzo del server (opzionale, default: `127.0.0.1`)
- `-p port`: Porta del server (opzionale, default: `56700`)
- `-r request`: Richiesta meteo nel formato `"type city"` (obbligatorio)

### Esecuzione

Il client deve essere eseguibile automaticamente senza interazione dell'utente. L'applicazione esegue una singola richiesta e termina:

```bash
client-project.exe -r "t bari"        # da terminale Windows
./client-project -r "h invalid_city"  # da terminale Linux/macOS
./client-project -r "x roma"
```
*Nota*: in caso di città con spazi (es., `-r "p Reggio Calabria"`), si assumerà che il primo carattere specificherà il `type` e tutto il resto sarà da considerarsi come `city`. 

### Esempi di Output

**Richiesta con successo:**
```bash
$ ./client-project -r "t bari"
Ricevuto risultato dal server ip 127.0.0.1. Bari: Temperatura = 22.5°C
```

**Città non disponibile:**
```bash
$ ./client-project -r "h parigi"
Ricevuto risultato dal server ip 127.0.0.1. Città non disponibile
```

**Richiesta non valida:**
```bash
$ ./client-project -r "x roma"
Ricevuto risultato dal server ip 127.0.0.1. Richiesta non valida
```

### Flusso di Esecuzione del Client

1. Analizza gli argomenti da riga di comando
2. Stabilisce connessione TCP con il server
3. Invia la richiesta meteo
4. Riceve la risposta dal server
5. Costruisce e visualizza il messaggio nel formato:
   ```
   Ricevuto risultato dal server ip <ip_address>. <messaggio_costruito>
   ```
   dove `<messaggio_costruito>` dipende dallo status:
   - Se `status = 0`: formatta il messaggio in base al `type` e `value` ricevuti
   - Se `status != 0`: visualizza il messaggio di errore appropriato
6. Chiude la connessione e termina

**Gestione degli errori:**
- Argomenti da riga di comando non validi → stampa l'uso corretto ed esce
- Fallimento della connessione → stampa errore ed esce
- Risposta non valida → stampa errore ed esce

## Comportamento del Server

### Interfaccia da Riga di Comando

```
./server-project [-p port]
```

**Parametri:**
- `-p port`: Porta di ascolto (opzionale, default: `56700`)

### Flusso di Esecuzione del Server

1. Analizza gli argomenti da riga di comando
2. Crea socket TCP e lo lega alla porta specificata
3. Si mette in ascolto per connessioni in ingresso
4. Per ogni connessione client:
   - Accetta la connessione
   - Riceve la richiesta
   - Visualizza il messaggio:
     ```
     Richiesta '<type> <city>' dal client ip <ip_address>
     ```
   - Valida la richiesta (tipo e città)
   - Se valida (`status = 0`):
     - Genera il valore meteo appropriato usando le funzioni `get_*`
     - Imposta type uguale a quello della richiesta
     - Imposta value con il valore generato
   - Se non valida (`status = 1` o `2`):
     - Imposta` type = '\0'`
     - Imposta `value = 0.0`
   - Invia la risposta (struttura `weather_response_t`)
   - Chiude la connessione con il client
5. Torna al punto 4 (il server non termina mai a meno che non venga esplicitamente terminato)

### Città Supportate

Il server deve supportare almeno queste città italiane:
- Bari
- Roma
- Milano
- Napoli
- Torino
- Palermo
- Genova
- Bologna
- Firenze
- Venezia

I nomi delle città sono case-insensitive.

## Requisiti di Implementazione

1. **Definizione del protocollo**: Il file header `protocol.h` deve contenere:
   - Strutture di richiesta/risposta
   - Prototipi delle funzioni di generazione dati
   - Definizioni dei codici di stato
   - Eventuali costanti condivise tra client e server

2. **File sorgente**:
   - `client.c`: Implementazione del client
   - `server.c`: Implementazione del server
   - `protocol.h`: Definizioni del protocollo condivise (file presente sia nel progetto client sia in quello server)

3. **Portabilità**: Il codice deve compilare ed eseguire su Windows, Linux e macOS

4. **Formato di output**: Il codice deve generare output esattamente come indicato nelle specifiche e negli esempi

5. **Portabilità**: Il codice deve compilare ed eseguire su Windows, Linux e macOS

6. **Compatibilità Eclipse CDT**: Il codice deve funzionare in progetti Eclipse CDT

7. **Sicurezza della memoria**: Nessun buffer overflow, memory leak o comportamento indefinito


## Consegna

- **Scadenza**: 28 novembre 2025, entro h. 23.59.59
- **Form di prenotazione / consegna**: [link](https://forms.gle/jwWg3y8zFaFUbH7g7)
- **Formato**: Link a repository GitHub accessibile pubblicamente
- **Note**:
   - Una sola consegna per coppia
 
_Ver. 1.0.3_
