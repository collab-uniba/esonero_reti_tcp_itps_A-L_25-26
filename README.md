# Esonero TCP - Corso di Reti di Calcolatori - ITPS A-L

Repository per l'assegnazione della prima prova di esonero: client-server TCP.


## Descrizione

Questo repository contiene la struttura base per lo sviluppo di un'applicazione client-server TCP in linguaggio C, utilizzando la libreria standard delle socket. Il codice è progettato per essere portabile su sistemi operativi **Windows**, **Linux** e **macOS**.

## Struttura del Repository

Il repository è organizzato in due progetti Eclipse CDT separati:

```
.
├── client-project/         # Progetto Eclipse per il client
│   ├── .project            # Configurazione progetto Eclipse
│   ├── .cproject           # Configurazione Eclipse CDT
│   └── src/
│       ├── main.c          # File principale del client
│       └── protocol.h      # Header con definizioni e prototipi
│
└── server-project/         # Progetto Eclipse per il server
    ├── .project            # Configurazione progetto Eclipse
    ├── .cproject           # Configurazione Eclipse CDT
    └── src/
        ├── main.c          # File principale del server
        └── protocol.h      # Header con definizioni e prototipi
```

## Come Utilizzare il Template

### 1. Creare la propria copia del repository

1. Cliccare su "Use this template" in alto a destra su GitHub
2. Creare un nuovo repository personale
    - Rinominare il repository sostituendo la parola _template_ con il vostro _cognome_ seguito dalla _matricola_ (`template_esonero_tcp` -> `cognome_12345_esonero_tcp`)
    - Se l'esonero è svolto in coppia, il nome del repository sarà `cognome1_12345_cognome2_6789_esonero_tcp`
4. Clonare il repository sul proprio computer:
   ```bash
   git clone <url-del-tuo-repository>
   ```

### 2. Importare i progetti in Eclipse

1. Aprire **Eclipse CDT**
2. Selezionare `File → Import → General → Existing Projects into Workspace`
3. Selezionare la directory `client-project`
4. Ripetere i passi 2-3 per `server-project`

### 3. Configurare il progetto in Eclipse

Dopo aver importato i progetti, è necessario verificare e configurare le impostazioni del compilatore:

#### Verificare il Toolchain
Per ciascun progetto (client e server):
1. Click destro sul progetto → `Properties`
2. Andare in `C/C++ Build → Tool Chain Editor`
3. Verificare che il **Current toolchain** sia corretto per il proprio sistema operativo:
   - **Linux**: GCC
   - **macOS**: GCC
   - **Windows**: MinGW GCC (Assicurarsi di avere già installato MinGW o MinGW-w64)

#### Solo per Windows: Aggiungere libreria Winsock
Per compilare su Windows, è necessario linkare la libreria Winsock:
1. Click destro sul progetto → `Properties`
2. Andare in `C/C++ Build → Settings`
3. Selezionare `MinGW C Linker → Libraries`
4. In **Libraries (-l)**, cliccare su `Add` e inserire: `wsock32`
5. Applicare le modifiche e cliccare `OK`


## File Principali

### protocol.h
Contiene:
- **Costanti condivise**: numero di porta del server, dimensione buffer, ecc.
- **Prototipi delle funzioni**: inserire qui le firme di tutte le funzioni implementate

Esempio:
```c
#define SERVER_PORT 27015
#define BUFFER_SIZE 512

// Prototipo funzione esempio
int connect_to_server(const char* server_address);
```

### main.c (Client e Server)
Contiene:
- **Codice boilerplate** per la portabilità cross-platform
- **Inizializzazione Winsock** su Windows
- **Sezioni TODO** dove implementare la logica dell'applicazione

## Implementazione dell'Assegnazione

[Protocollo applicativo e istruzioni per la consegna](Assegnazione.md)

## Licenza

Vedere il file [LICENSE](LICENSE) per i dettagli.
