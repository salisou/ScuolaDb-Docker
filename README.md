# Docker ScuolaDb

Ambiente SQL Server 2022 con database scolastico ScuolaDb.

## Avvio

```powershell
docker compose up -d --build
```

Prima dell'avvio, crea il file locale `.env` a partire dall'esempio e imposta una password robusta e personale:

```powershell
Copy-Item .env.example .env
```

Modifica `.env` prima di avviare i container. Il file è escluso da Git e non deve essere pubblicato. Il server SQL ascolta sulla porta `1433`.

Utente: `sa`. Per impostazione predefinita la porta host è `1433`; puoi modificarla in `.env`:

```text
MSSQL_PORT=1433
```

## Verifica

```powershell
docker compose ps
docker compose logs -f sqlserver
```

## Connessione da Visual Studio Code

1. Avvia il container con `docker compose up -d`.
2. In VS Code installa l'estensione **SQL Server (mssql)** di Microsoft.
3. Apri la palette comandi con `Ctrl+Shift+P` e seleziona **MS SQL: Connect** (oppure **MS SQL: Add Connection**).
4. Inserisci i parametri:

   | Campo | Valore |
   | --- | --- |
   | Server name | `localhost,1433` |
   | Authentication type | `SQL Login` |
   | User name | `sa` |
   | Password | Il valore di `MSSQL_SA_PASSWORD` nel file `.env` |
   | Database | `ScuolaDb` |
   | Encrypt | `Mandatory` |
   | Trust server certificate | `Yes` |

5. Salva il profilo se vuoi riutilizzare la connessione. Per provare, apri un file `.sql`, seleziona il profilo e lancia una query, ad esempio:

```sql
SELECT name FROM sys.tables ORDER BY name;
```

## Connessione da SQL Server Management Studio (SSMS)

1. Avvia il container con `docker compose up -d` e verifica che sia healthy con `docker compose ps`.
2. Apri SSMS e nella finestra **Connect to Server** imposta:

   | Campo | Valore |
   | --- | --- |
   | Server type | `Database Engine` |
   | Server name | `localhost,1433` |
   | Authentication | `SQL Server Authentication` |
   | Login | `sa` |
   | Password | Il valore di `MSSQL_SA_PASSWORD` nel file `.env` |

3. Nelle opzioni di connessione, abilita **Trust server certificate** (il certificato del container è autofirmato) e connettiti.
4. Nel selettore database scegli `ScuolaDb`, oppure esegui:

```sql
USE ScuolaDb;
GO
SELECT name FROM sys.tables ORDER BY name;
```

Se hai impostato `MSSQL_PORT` nel file `.env` a un valore diverso da `1433`, usa `localhost,<porta>` in entrambi i programmi.

## Accesso da terminale

Esempio con sqlcmd dal container:

```powershell
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd `
  -S localhost -U sa -P "INSERISCI_LA_PASSWORD_DEL_TUO_FILE_ENV" -C `
  -d ScuolaDb -Q "SELECT COUNT(*) AS Tabelle FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"
```

I dati sono conservati nel volume Docker `sqlserver-data`. Rimuoverli solo con:

```powershell
docker compose down -v
```
