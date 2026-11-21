USE ScuolaDb;
GO

SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM AnniScolastici)
BEGIN
    INSERT INTO AnniScolastici (NomeAnno, DataInizio, DataFine, Attivo)
    VALUES
        ('2025/2026', '2025-09-15', '2026-06-30', 0),
        ('2026/2027', '2026-09-15', '2027-06-30', 1);
END;
GO

IF NOT EXISTS (SELECT 1 FROM Docenti)
BEGIN
    INSERT INTO Docenti
        (Nome, Cognome, Email, CodiceFiscale, Specializzazione, Attivo)
    VALUES
        ('Moussa', 'Salisou', 'moussa.salisou@scuola.test', 'SLSMSS80A01H501Z', 'Informatica', 1),
        ('Anna', 'Rossi', 'anna.rossi@scuola.test', 'RSSNNA90A41H501X', 'Matematica', 1);
END;
GO

IF NOT EXISTS (SELECT 1 FROM Aule)
BEGIN
    INSERT INTO Aule (NomeAula, TipoAula, Capacita, Piano, Attiva)
    VALUES
        ('Aula 101', 'Aula', 30, 1, 1),
        ('Laboratorio Informatica', 'Laboratorio', 24, 1, 1);
END;
GO

IF NOT EXISTS (SELECT 1 FROM Corsi)
BEGIN
    INSERT INTO Corsi
        (NomeCorso, Descrizione, Categoria, DurataOre, Crediti, Costo, Attivo)
    VALUES
        ('SQL Server', 'Fondamenti e gestione relazionale con SQL Server', 'Informatica', 60, 6, 450.00, 1),
        ('Python', 'Programmazione Python per principianti', 'Informatica', 40, 4, 350.00, 1);
END;
GO
