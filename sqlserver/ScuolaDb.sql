/*
====================================================================
                  CORSO COMPLETO DI SQL SERVER
====================================================================

PROGETTO: DATABASE SCUOLADB
DOCENTE: MOUSSA SALISOU

OBIETTIVO:
Progettare un database relazionale per la gestione completa
di una scuola o di un centro di formazione professionale.

TABELLE:
    01. AnniScolastici
    02. Docenti
    03. Aule
    04. Classi
    05. Studenti
    06. Corsi
    07. Iscrizioni
    08. DocentiCorsi
    09. Lezioni
    10. Voti
    11. Presenze
    12. Pagamenti

ARGOMENTI:
    CREATE DATABASE
    CREATE TABLE
    PRIMARY KEY
    FOREIGN KEY
    IDENTITY
    NOT NULL
    UNIQUE
    DEFAULT
    CHECK
    DECIMAL
    DATE
    TIME
    DATETIME2
    RELAZIONI 1:N
    RELAZIONI N:N

====================================================================
1. CREAZIONE DEL DATABASE
====================================================================

CREATE DATABASE:
    Crea un nuovo database.

USE:
    Seleziona il database sul quale lavorare.

GO:
    Separa i diversi batch di istruzioni SQL Server.

*/

IF DB_ID('ScuolaDb') IS NULL
BEGIN
    CREATE DATABASE ScuolaDb;
END;
GO

USE ScuolaDb;
GO


/*
====================================================================
2. TABELLA ANNI SCOLASTICI
====================================================================

A COSA SERVE?
Memorizza gli anni scolastici gestiti dalla scuola.

ESEMPI:
    2025/2026
    2026/2027
    2027/2028

PERCHE' UTILIZZARLA?
Permette di organizzare studenti, classi, iscrizioni e
attività didattiche in periodi differenti.

IDENTITY(1,1):
    Genera automaticamente l'identificativo.

CHECK:
    Impedisce che la data di fine sia precedente
    alla data di inizio.

*/

CREATE TABLE AnniScolastici
(
    AnnoScolasticoId INT IDENTITY(1,1) NOT NULL,

    NomeAnno NVARCHAR(20) NOT NULL,

    DataInizio DATE NOT NULL,

    DataFine DATE NOT NULL,

    Attivo BIT NOT NULL
        CONSTRAINT DF_AnniScolastici_Attivo DEFAULT (0),

    CONSTRAINT PK_AnniScolastici
        PRIMARY KEY (AnnoScolasticoId),

    CONSTRAINT UQ_AnniScolastici_Nome
        UNIQUE (NomeAnno),

    CONSTRAINT CK_AnniScolastici_Date
        CHECK (DataFine > DataInizio)
);
GO


/*
====================================================================
3. TABELLA DOCENTI
====================================================================

A COSA SERVE?
Memorizza le informazioni personali e professionali
dei docenti.

Email:
    Identifica il docente attraverso un indirizzo email.

CodiceFiscale:
    Contiene il codice fiscale del docente.

CHAR(16):
    Lunghezza fissa di 16 caratteri.

NVARCHAR:
    Memorizza testo Unicode.

UNIQUE:
    Impedisce la presenza di email o codici fiscali duplicati.
*/

CREATE TABLE Docenti
(
    DocenteId INT IDENTITY(1,1) NOT NULL,

    Nome NVARCHAR(50) NOT NULL,

    Cognome NVARCHAR(50) NOT NULL,

    DataNascita DATE NULL,

    Email NVARCHAR(150) NOT NULL,

    Telefono NVARCHAR(20) NULL,

    CodiceFiscale CHAR(16) NULL,

    Specializzazione NVARCHAR(150) NULL,

    DataAssunzione DATE NULL,

    Attivo BIT NOT NULL
        CONSTRAINT DF_Docenti_Attivo DEFAULT (1),

    CONSTRAINT PK_Docenti
        PRIMARY KEY (DocenteId),

    CONSTRAINT UQ_Docenti_Email
        UNIQUE (Email),

    CONSTRAINT UQ_Docenti_CodiceFiscale
        UNIQUE (CodiceFiscale)
);
GO


/*
====================================================================
4. TABELLA AULE
====================================================================

A COSA SERVE?
Memorizza le aule e i laboratori disponibili.

Capacita:
    Indica il numero massimo di persone.

TipoAula:
    Identifica la tipologia di ambiente.

CHECK:
    Impedisce di inserire una capacità negativa o uguale a zero.
*/

CREATE TABLE Aule
(
    AulaId INT IDENTITY(1,1) NOT NULL,

    NomeAula NVARCHAR(100) NOT NULL,

    TipoAula NVARCHAR(50) NOT NULL,

    Capacita INT NOT NULL,

    Piano INT NULL,

    Attiva BIT NOT NULL
        CONSTRAINT DF_Aule_Attiva DEFAULT (1),

    CONSTRAINT PK_Aule
        PRIMARY KEY (AulaId),

    CONSTRAINT UQ_Aule_Nome
        UNIQUE (NomeAula),

    CONSTRAINT CK_Aule_Capacita
        CHECK (Capacita > 0)
);
GO


/*
====================================================================
5. TABELLA CLASSI
====================================================================

A COSA SERVE?
Permette di organizzare gli studenti in classi o gruppi.

ESEMPIO:
    Classe A - 2026/2027
    Classe B - 2026/2027
    Classe C - 2026/2027

RELAZIONI:
    AnniScolastici (1) -> (N) Classi
    Docenti        (1) -> (N) Classi

TutorDocenteId:
    Identifica il docente responsabile della classe.

AnnoScolasticoId:
    Identifica l'anno scolastico di riferimento.
*/

CREATE TABLE Classi
(
    ClasseId INT IDENTITY(1,1) NOT NULL,

    NomeClasse NVARCHAR(50) NOT NULL,

    AnnoScolasticoId INT NOT NULL,

    TutorDocenteId INT NULL,

    Descrizione NVARCHAR(250) NULL,

    CONSTRAINT PK_Classi
        PRIMARY KEY (ClasseId),

    CONSTRAINT FK_Classi_AnniScolastici
        FOREIGN KEY (AnnoScolasticoId)
        REFERENCES AnniScolastici(AnnoScolasticoId),

    CONSTRAINT FK_Classi_Docenti
        FOREIGN KEY (TutorDocenteId)
        REFERENCES Docenti(DocenteId),

    CONSTRAINT UQ_Classi_Anno
        UNIQUE (NomeClasse, AnnoScolasticoId)
);
GO


/*
====================================================================
6. TABELLA STUDENTI
====================================================================

A COSA SERVE?
Memorizza le informazioni anagrafiche degli studenti.

ClasseId:
    Collega lo studente alla propria classe.

La relazione è:
    Classi (1) -> (N) Studenti

ClasseId può essere NULL perché uno studente potrebbe
non essere ancora assegnato a una classe.

CodiceFiscale:
    Deve essere univoco.

Attivo:
    1 = Studente attivo.
    0 = Studente non attivo.
*/

CREATE TABLE Studenti
(
    StudenteId INT IDENTITY(1,1) NOT NULL,

    ClasseId INT NULL,

    Nome NVARCHAR(50) NOT NULL,

    Cognome NVARCHAR(50) NOT NULL,

    DataNascita DATE NOT NULL,

    Sesso CHAR(1) NULL,

    CodiceFiscale CHAR(16) NOT NULL,

    Email NVARCHAR(150) NULL,

    Telefono NVARCHAR(20) NULL,

    Indirizzo NVARCHAR(150) NULL,

    Citta NVARCHAR(100) NULL,

    DataRegistrazione DATE NOT NULL
        CONSTRAINT DF_Studenti_DataRegistrazione
        DEFAULT (CONVERT(DATE, GETDATE())),

    Attivo BIT NOT NULL
        CONSTRAINT DF_Studenti_Attivo DEFAULT (1),

    CONSTRAINT PK_Studenti
        PRIMARY KEY (StudenteId),

    CONSTRAINT FK_Studenti_Classi
        FOREIGN KEY (ClasseId)
        REFERENCES Classi(ClasseId),

    CONSTRAINT UQ_Studenti_CodiceFiscale
        UNIQUE (CodiceFiscale),

    CONSTRAINT CK_Studenti_Sesso
        CHECK (Sesso IS NULL OR Sesso IN ('M', 'F'))
);
GO

-- Gli indirizzi email possono essere NULL,
-- ma non possono essere duplicati quando presenti.

CREATE UNIQUE INDEX UX_Studenti_Email
ON Studenti(Email)
WHERE Email IS NOT NULL;
GO


/*
====================================================================
7. TABELLA CORSI
====================================================================

A COSA SERVE?
Contiene il catalogo dei corsi organizzati dalla scuola.

ESEMPI:
    SQL Server
    Python
    C#
    Java
    Cyber Security
    Power BI

DurataOre:
    Numero complessivo di ore previste.

Costo:
    Costo del corso espresso in euro.

DECIMAL(10,2):
    Memorizza importi con due cifre decimali.

*/

CREATE TABLE Corsi
(
    CorsoId INT IDENTITY(1,1) NOT NULL,

    NomeCorso NVARCHAR(150) NOT NULL,

    Descrizione NVARCHAR(500) NULL,

    Categoria NVARCHAR(100) NULL,

    DurataOre INT NOT NULL,

    Crediti INT NULL,

    Costo DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_Corsi_Costo DEFAULT (0),

    Attivo BIT NOT NULL
        CONSTRAINT DF_Corsi_Attivo DEFAULT (1),

    CONSTRAINT PK_Corsi
        PRIMARY KEY (CorsoId),

    CONSTRAINT UQ_Corsi_Nome
        UNIQUE (NomeCorso),

    CONSTRAINT CK_Corsi_Durata
        CHECK (DurataOre > 0),

    CONSTRAINT CK_Corsi_Costo
        CHECK (Costo >= 0),

    CONSTRAINT CK_Corsi_Crediti
        CHECK (Crediti IS NULL OR Crediti >= 0)
);
GO


/*
====================================================================
8. TABELLA ISCRIZIONI
====================================================================

A COSA SERVE?
Registra gli studenti iscritti ai diversi corsi.

RELAZIONE MOLTI A MOLTI:

Studenti (1) -> (N) Iscrizioni
Corsi    (1) -> (N) Iscrizioni

ESEMPIO:

Studente 1 -> Corso 1
Studente 1 -> Corso 2
Studente 1 -> Corso 3

Significa che lo studente 1 frequenta tre corsi.

Altro esempio:

Studente 1 -> Corso 1
Studente 2 -> Corso 1
Studente 3 -> Corso 1

Significa che tre studenti frequentano lo stesso corso.

La combinazione StudenteId + CorsoId è UNIQUE:
uno studente non può iscriversi due volte allo stesso corso.

*/

CREATE TABLE Iscrizioni
(
    IscrizioneId INT IDENTITY(1,1) NOT NULL,

    StudenteId INT NOT NULL,

    CorsoId INT NOT NULL,

    AnnoScolasticoId INT NOT NULL,

    DataIscrizione DATE NOT NULL
        CONSTRAINT DF_Iscrizioni_Data
        DEFAULT (CONVERT(DATE, GETDATE())),

    Stato NVARCHAR(30) NOT NULL
        CONSTRAINT DF_Iscrizioni_Stato DEFAULT ('Attiva'),

    CONSTRAINT PK_Iscrizioni
        PRIMARY KEY (IscrizioneId),

    CONSTRAINT FK_Iscrizioni_Studenti
        FOREIGN KEY (StudenteId)
        REFERENCES Studenti(StudenteId),

    CONSTRAINT FK_Iscrizioni_Corsi
        FOREIGN KEY (CorsoId)
        REFERENCES Corsi(CorsoId),

    CONSTRAINT FK_Iscrizioni_AnniScolastici
        FOREIGN KEY (AnnoScolasticoId)
        REFERENCES AnniScolastici(AnnoScolasticoId),

    CONSTRAINT UQ_Iscrizioni
        UNIQUE (StudenteId, CorsoId, AnnoScolasticoId),

    CONSTRAINT CK_Iscrizioni_Stato
        CHECK (Stato IN
        ('Attiva', 'Completata', 'Ritirata', 'Sospesa'))
);
GO


/*
====================================================================
9. TABELLA DOCENTICORSI
====================================================================

A COSA SERVE?
Associa i docenti ai corsi che devono insegnare.

RELAZIONE MOLTI A MOLTI:

Docenti (1) -> (N) DocentiCorsi
Corsi   (1) -> (N) DocentiCorsi

ESEMPIO:

Docente 1 -> Corso 1
Docente 1 -> Corso 2
Docente 1 -> Corso 3

Un docente insegna tre corsi.

Altro esempio:

Docente 1 -> Corso 1
Docente 2 -> Corso 1

Due docenti insegnano lo stesso corso.

Ruolo:
    Permette di distinguere docente principale e collaboratore.

*/

CREATE TABLE DocentiCorsi
(
    DocenteCorsoId INT IDENTITY(1,1) NOT NULL,

    DocenteId INT NOT NULL,

    CorsoId INT NOT NULL,

    DataAssegnazione DATE NOT NULL
        CONSTRAINT DF_DocentiCorsi_Data
        DEFAULT (CONVERT(DATE, GETDATE())),

    Ruolo NVARCHAR(50) NOT NULL
        CONSTRAINT DF_DocentiCorsi_Ruolo
        DEFAULT ('Docente'),

    CONSTRAINT PK_DocentiCorsi
        PRIMARY KEY (DocenteCorsoId),

    CONSTRAINT FK_DocentiCorsi_Docenti
        FOREIGN KEY (DocenteId)
        REFERENCES Docenti(DocenteId),

    CONSTRAINT FK_DocentiCorsi_Corsi
        FOREIGN KEY (CorsoId)
        REFERENCES Corsi(CorsoId),

    CONSTRAINT UQ_DocentiCorsi
        UNIQUE (DocenteId, CorsoId),

    CONSTRAINT CK_DocentiCorsi_Ruolo
        CHECK (Ruolo IN
        ('Responsabile', 'Docente', 'Collaboratore'))
);
GO


/*
====================================================================
10. TABELLA LEZIONI
====================================================================

A COSA SERVE?
Memorizza il calendario delle lezioni.

Ogni lezione è collegata:
    - A un corso.
    - A un docente.
    - A un'aula.

RELAZIONI:

Corsi   (1) -> (N) Lezioni
Docenti (1) -> (N) Lezioni
Aule    (1) -> (N) Lezioni

DataLezione:
    Giorno in cui si svolge la lezione.

OraInizio:
    Orario di inizio.

OraFine:
    Orario di conclusione.

CHECK:
    Impedisce che l'ora di fine sia precedente
o uguale all'ora di inizio.

*/

CREATE TABLE Lezioni
(
    LezioneId INT IDENTITY(1,1) NOT NULL,

    CorsoId INT NOT NULL,

    DocenteId INT NOT NULL,

    AulaId INT NOT NULL,

    Titolo NVARCHAR(150) NOT NULL,

    Descrizione NVARCHAR(500) NULL,

    DataLezione DATE NOT NULL,

    OraInizio TIME(0) NOT NULL,

    OraFine TIME(0) NOT NULL,

    Durata AS
        DATEDIFF(MINUTE, OraInizio, OraFine) PERSISTED,

    DataCreazione DATETIME2(0) NOT NULL
        CONSTRAINT DF_Lezioni_DataCreazione
        DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_Lezioni
        PRIMARY KEY (LezioneId),

    CONSTRAINT FK_Lezioni_Corsi
        FOREIGN KEY (CorsoId)
        REFERENCES Corsi(CorsoId),

    CONSTRAINT FK_Lezioni_Docenti
        FOREIGN KEY (DocenteId)
        REFERENCES Docenti(DocenteId),

    CONSTRAINT FK_Lezioni_Aule
        FOREIGN KEY (AulaId)
        REFERENCES Aule(AulaId),

    CONSTRAINT CK_Lezioni_Orari
        CHECK (OraFine > OraInizio)
);
GO


/*
====================================================================
11. TABELLA VOTI
====================================================================

A COSA SERVE?
Registra le valutazioni ottenute dagli studenti.

Ogni voto è collegato a un'iscrizione.

In questo modo sappiamo:
    - Quale studente ha ricevuto il voto.
    - Per quale corso è stato valutato.
    - A quale iscrizione appartiene la valutazione.

IscrizioneId:
    Chiave esterna verso Iscrizioni.

Voto:
    Valutazione numerica da 0 a 10.

DECIMAL(4,2):
    Permette voti come 7.50, 8.25, 10.00.

Tipologia:
    Scritto, Orale oppure Pratico.

Superato:
    1 = Valutazione sufficiente.
    0 = Valutazione insufficiente.

CHECK:
    Impedisce voti inferiori a 0 o superiori a 10.

*/

CREATE TABLE Voti
(
    VotoId INT IDENTITY(1,1) NOT NULL,

    IscrizioneId INT NOT NULL,

    Voto DECIMAL(4,2) NOT NULL,

    DataVoto DATE NOT NULL
        CONSTRAINT DF_Voti_Data
        DEFAULT (CONVERT(DATE, GETDATE())),

    Tipologia NVARCHAR(30) NOT NULL,

    Descrizione NVARCHAR(250) NULL,

    Superato AS
        (CASE WHEN Voto >= 6 THEN 1 ELSE 0 END) PERSISTED,

    CONSTRAINT PK_Voti
        PRIMARY KEY (VotoId),

    CONSTRAINT FK_Voti_Iscrizioni
        FOREIGN KEY (IscrizioneId)
        REFERENCES Iscrizioni(IscrizioneId),

    CONSTRAINT CK_Voti_Valore
        CHECK (Voto >= 0 AND Voto <= 10),

    CONSTRAINT CK_Voti_Tipologia
        CHECK (Tipologia IN ('Scritto', 'Orale', 'Pratico'))
);
GO


/*
====================================================================
12. TABELLA PRESENZE
====================================================================

A COSA SERVE?
Registra la presenza o l'assenza degli studenti
durante le lezioni.

Ogni presenza collega:
    - Uno studente.
    - Una lezione.

ESEMPI DI STATO:
    Presente
    Assente
    Ritardo
    Giustificato

RELAZIONE MOLTI A MOLTI:

Studenti (1) -> (N) Presenze
Lezioni  (1) -> (N) Presenze

Uno studente può partecipare a molte lezioni.
Una lezione può avere molti studenti.

UNIQUE:
    Impedisce di registrare due volte la presenza
dello stesso studente alla stessa lezione.

*/

CREATE TABLE Presenze
(
    PresenzaId INT IDENTITY(1,1) NOT NULL,

    StudenteId INT NOT NULL,

    LezioneId INT NOT NULL,

    Stato NVARCHAR(30) NOT NULL,

    OraRegistrazione TIME(0) NULL,

    Note NVARCHAR(250) NULL,

    DataRegistrazione DATETIME2(0) NOT NULL
        CONSTRAINT DF_Presenze_Data
        DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_Presenze
        PRIMARY KEY (PresenzaId),

    CONSTRAINT FK_Presenze_Studenti
        FOREIGN KEY (StudenteId)
        REFERENCES Studenti(StudenteId),

    CONSTRAINT FK_Presenze_Lezioni
        FOREIGN KEY (LezioneId)
        REFERENCES Lezioni(LezioneId),

    CONSTRAINT UQ_Presenze
        UNIQUE (StudenteId, LezioneId),

    CONSTRAINT CK_Presenze_Stato
        CHECK (Stato IN
        ('Presente', 'Assente', 'Ritardo', 'Giustificato'))
);
GO


/*
====================================================================
13. TABELLA PAGAMENTI
====================================================================

A COSA SERVE?
Permette di gestire i pagamenti effettuati dagli studenti
per i corsi ai quali risultano iscritti.

Ogni pagamento è associato a un'iscrizione.

Uno studente può effettuare:
    - Un pagamento unico.
    - Più pagamenti.
    - Pagamenti parziali.

Importo:
    Importo versato.

MetodoPagamento:
    Carta, Bonifico, Contanti, PayPal.

Stato:
    Pagato, In attesa, Rimborsato.

DECIMAL(10,2):
    Utilizzato per gli importi monetari.

*/

CREATE TABLE Pagamenti
(
    PagamentoId INT IDENTITY(1,1) NOT NULL,

    IscrizioneId INT NOT NULL,

    Importo DECIMAL(10,2) NOT NULL,

    DataPagamento DATETIME2(0) NOT NULL
        CONSTRAINT DF_Pagamenti_Data
        DEFAULT (SYSDATETIME()),

    MetodoPagamento NVARCHAR(50) NOT NULL,

    Stato NVARCHAR(30) NOT NULL
        CONSTRAINT DF_Pagamenti_Stato
        DEFAULT ('In attesa'),

    NumeroTransazione NVARCHAR(100) NULL,

    Note NVARCHAR(250) NULL,

    CONSTRAINT PK_Pagamenti
        PRIMARY KEY (PagamentoId),

    CONSTRAINT FK_Pagamenti_Iscrizioni
        FOREIGN KEY (IscrizioneId)
        REFERENCES Iscrizioni(IscrizioneId),

    CONSTRAINT CK_Pagamenti_Importo
        CHECK (Importo > 0),

    CONSTRAINT CK_Pagamenti_Metodo
        CHECK (MetodoPagamento IN
        ('Carta', 'Bonifico', 'Contanti', 'PayPal')),

    CONSTRAINT CK_Pagamenti_Stato
        CHECK (Stato IN
        ('Pagato', 'In attesa', 'Rimborsato'))
);
GO


/*
====================================================================
14. VERIFICA DELLE TABELLE CREATE
====================================================================

INFORMATION_SCHEMA.TABLES:
    Permette di visualizzare le tabelle presenti nel database.

TABLE_TYPE:
    BASE TABLE identifica una tabella fisica.

*/

SELECT
    TABLE_NAME AS NomeTabella,
    TABLE_TYPE AS TipoTabella
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO


/*
====================================================================
15. VERIFICA DELLE CHIAVI ESTERNE
====================================================================

sys.foreign_keys:
    Contiene i vincoli FOREIGN KEY.

sys.tables:
    Contiene le informazioni sulle tabelle.

Questa query mostra quali tabelle sono collegate tra loro.

*/

SELECT
    fk.name AS NomeForeignKey,
    OBJECT_NAME(fk.parent_object_id) AS TabellaFiglia,
    OBJECT_NAME(fk.referenced_object_id) AS TabellaPadre
FROM sys.foreign_keys AS fk
ORDER BY TabellaFiglia;
GO


/*
====================================================================
16. VERIFICA DEL NUMERO DELLE TABELLE
====================================================================
*/

SELECT
    COUNT(*) AS NumeroTabelle
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO


/*
====================================================================
FINE DELLA CREAZIONE DEL DATABASE
====================================================================

DATABASE: ScuolaDb

TOTALE TABELLE: 12

01. AnniScolastici
02. Docenti
03. Aule
04. Classi
05. Studenti
06. Corsi
07. Iscrizioni
08. DocentiCorsi
09. Lezioni
10. Voti
11. Presenze
12. Pagamenti

PROSSIMA LEZIONE:
INSERIMENTO DI 30 RECORD PER OGNI TABELLA.

© 2026 - Tutti i diritti riservati
Docente Moussa Salisou

====================================================================
*/
