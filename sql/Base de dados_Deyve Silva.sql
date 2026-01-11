-- Deyve Silva - a22403432  
-- Laeek Ravat - a22504368
-- Jacira Lourenço - a22502992

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'deisIMDB')
CREATE DATABASE deisIMDB;
GO

USE deisIMDB;
GO

-- Limpar tabelas na ordem correta (devido a constraints FK)
--DROP TABLE IF EXISTS movie_votes;
--DROP TABLE IF EXISTS genres_movies;
--DROP TABLE IF EXISTS MovieActor;
--DROP TABLE IF EXISTS MovieDirector;
--DROP TABLE IF EXISTS moviePlatform;
--DROP TABLE IF EXISTS movieCountry;
--DROP TABLE IF EXISTS interaction;
--DROP TABLE IF EXISTS platform;
--DROP TABLE IF EXISTS country;
--DROP TABLE IF EXISTS continent;
--DROP TABLE IF EXISTS AgeRating;

--DROP TABLE IF EXISTS movies;
--DROP TABLE IF EXISTS genres;
--DROP TABLE IF EXISTS directors;
--DROP TABLE IF EXISTS actors;
--DROP TABLE IF EXISTS continent;

GO

-------------------------
-- DROPAR PROCEDURES
-------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'COUNT_MOVIES_MONTH_YEAR')
    DROP PROCEDURE COUNT_MOVIES_MONTH_YEAR;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'COUNT_MOVIES_DIRECTOR')
    DROP PROCEDURE COUNT_MOVIES_DIRECTOR;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'COUNT_ACTORS_IN_2_YEARS')
    DROP PROCEDURE COUNT_ACTORS_IN_2_YEARS;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'COUNT_MOVIES_BETWEEN_YEARS_WITH_N_ACTORS')
    DROP PROCEDURE COUNT_MOVIES_BETWEEN_YEARS_WITH_N_ACTORS;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GET_MOVIES_ACTOR_YEAR')
    DROP PROCEDURE GET_MOVIES_ACTOR_YEAR;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GET_MOVIES_WITH_ACTOR_CONTAINING')
    DROP PROCEDURE GET_MOVIES_WITH_ACTOR_CONTAINING;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GET_TOP_4_YEARS_WITH_MOVIES_CONTAINING')
    DROP PROCEDURE GET_TOP_4_YEARS_WITH_MOVIES_CONTAINING;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GET_ACTORS_BY_DIRECTOR')
    DROP PROCEDURE GET_ACTORS_BY_DIRECTOR;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'TOP_MONTH_MOVIE_COUNT')
    DROP PROCEDURE TOP_MONTH_MOVIE_COUNT;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'TOP_VOTED_ACTORS')
    DROP PROCEDURE TOP_VOTED_ACTORS;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'TOP_MOVIES_WITH_MORE_GENDER')
    DROP PROCEDURE TOP_MOVIES_WITH_MORE_GENDER;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'TOP_MOVIES_WITH_GENDER_BIAS')
    DROP PROCEDURE TOP_MOVIES_WITH_GENDER_BIAS;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'TOP_6_DIRECTORS_WITHIN_FAMILY')
    DROP PROCEDURE TOP_6_DIRECTORS_WITHIN_FAMILY;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'DISTANCE_BETWEEN_ACTORS')
    DROP PROCEDURE DISTANCE_BETWEEN_ACTORS;


-------------------------
-- DROPAR VIEWS
-------------------------
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_Top5Directors')
    DROP VIEW dbo.vw_Top5Directors;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_Top10Actors')
    DROP VIEW vw_Top10Actors;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ContinentsMoreThan10Movies')
    DROP VIEW vw_ContinentsMoreThan10Movies;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CountriesLessThan5Movies')
    DROP VIEW vw_CountriesLessThan5Movies;

--*************************************CRIAR TABELAS
-- 1. Primeiro criar tabelas sem dependências FK (ou com menos dependências)

CREATE TABLE genres (
    genreId INT PRIMARY KEY,
    genreName NVARCHAR(100) NOT NULL
);

CREATE TABLE movies (
    movieId INT PRIMARY KEY,
    movieName NVARCHAR(255) NOT NULL,
    movieDuration DECIMAL(5,1) NULL,
    movieBudget DECIMAL(15,2) NULL,
    movieReleaseDate DATE NULL
    --registrationDate DATETIME DEFAULT '2026-01-01' : will be added on next line 
    --ageRatingId INT NULL : will be added on next line 
);

CREATE TABLE directors (
    directorId INT PRIMARY KEY,
    directorName NVARCHAR(255) NOT NULL
  );

CREATE TABLE actors (
    actorId INT PRIMARY KEY,
    actorName NVARCHAR(255) NOT NULL,
    actorGender CHAR(1) CHECK (actorGender IN ('M', 'F'))
);

CREATE TABLE movie_votes (
    --ratingId INT IDENTITY(1,1) PRIMARY KEY,
    movieId INT NOT NULL,
    movieRating DECIMAL(3,1) NOT NULL CHECK (movieRating >= 0 AND movieRating <= 10),
    movieRatingCount INT NOT NULL DEFAULT 0,
    --source NVARCHAR(100) DEFAULT 'IMDb', this column will update in another file
    FOREIGN KEY (movieId) REFERENCES Movies(movieId)
);

CREATE TABLE genres_movies (
    genreId INT NOT NULL,
    movieId INT NOT NULL,
    PRIMARY KEY (genreId, movieId),
    FOREIGN KEY (genreId) REFERENCES genres(genreId),
    FOREIGN KEY (movieId) REFERENCES movies(movieId)
);


CREATE TABLE MovieDirector (
    directorId INT NOT NULL,
    movieId INT NOT NULL,
    PRIMARY KEY (directorId, movieId),
    FOREIGN KEY (directorId) REFERENCES Directors(directorId),
    FOREIGN KEY (movieId) REFERENCES Movies(movieId)
);

CREATE TABLE MovieActor (
    actorId INT NOT NULL,
    movieId INT NOT NULL,
    characterName NVARCHAR(255) NULL, --TODO: actualizar a tabela para ter essa coluna
    PRIMARY KEY (actorId, movieId),
    FOREIGN KEY (actorId) REFERENCES Actors(actorId),
    FOREIGN KEY (movieId) REFERENCES Movies(movieId)
);

-- 2. Tabelas adicionais da etapa 2 (independentes)


CREATE TABLE continent (
    continentId INT PRIMARY KEY IDENTITY(1,1),
    continentName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE ageRating (
    ageRatingId INT PRIMARY KEY IDENTITY(1,1),
    code NVARCHAR(10) NOT NULL UNIQUE,
    description NVARCHAR(100) NOT NULL,
    minAge INT NULL
);

CREATE TABLE platform (
    platformId INT PRIMARY KEY IDENTITY(1,1),
    platformName NVARCHAR(100) NOT NULL UNIQUE,
    website NVARCHAR(255) NULL
);

-- 3. Agora tabelas que dependem das anteriores
CREATE TABLE country (
    countryId INT PRIMARY KEY IDENTITY(1,1),
    countryName NVARCHAR(100) NOT NULL UNIQUE,
    continentId INT NOT NULL,
    FOREIGN KEY (continentId) REFERENCES continent(continentId)
);


CREATE TABLE MoviePlatform (
    movieId INT NOT NULL,
    platformId INT NOT NULL,
    availableSince DATE NULL,
    PRIMARY KEY (movieId, platformId),
    FOREIGN KEY (movieId) REFERENCES Movies (movieId),
    FOREIGN KEY (platformId) REFERENCES Platform(platformId)
);

CREATE TABLE movieCountry (
    movieId INT NOT NULL,
    countryId INT NOT NULL,
    PRIMARY KEY (movieId, countryId),
    FOREIGN KEY (movieId) REFERENCES Movies(movieId),
    FOREIGN KEY (countryId) REFERENCES Country(countryId)
);

CREATE TABLE interaction (
    interactionId INT PRIMARY KEY IDENTITY(1,1),
    movieId INT NOT NULL,
    userId INT NOT NULL,
    interactionType NVARCHAR(50) NOT NULL,
    interactionDate DATETIME DEFAULT GETDATE(),
    details NVARCHAR(500) NULL,
    FOREIGN KEY (movieId) REFERENCES Movies(movieId)
);

-- ============================================
-- CONSTRAINTS E iNDICES: Note: 
-- ============================================
ALTER TABLE movies ADD CONSTRAINT CHK_MoviesBudget CHECK (movieBudget >= 0 OR movieBudget IS NULL);
ALTER TABLE movies ADD CONSTRAINT CHK_MoviesDuration CHECK (movieDuration > 0 OR movieDuration IS NULL); -- TODO: ANALISEM ESSA LINHA
ALTER TABLE movies ALTER COLUMN movieReleaseDate DATE NOT NULL; -- ANALISEM ESSA LINHA
ALTER TABLE movies ALTER COLUMN movieBudget DECIMAL(15,2) NOT NULL;
ALTER TABLE movies ADD CONSTRAINT DF_MovieBudget DEFAULT 0 FOR movieBudget;
GO

-- indices
CREATE INDEX IX_Movie_Name ON movies(movieName);
CREATE INDEX IX_Movies_ReleaseDate ON Movies(movieReleaseDate);
CREATE INDEX IX_Genre_Name ON genres(genreName);
CREATE INDEX IX_Director_Name ON directors(directorName);
CREATE INDEX IX_Actor_Name ON actors(actorName);
CREATE INDEX IX_Actor_Gender ON actors(actorGender);
CREATE INDEX IX_Rating_MoviesId ON movie_votes(movieId);
CREATE INDEX IX_MoviesGenre_MoviesId ON genres_movies(movieId);
CREATE INDEX IX_MoviesGenre_GenreId ON genres_movies(genreId);
CREATE INDEX IX_MoviesDirector_MovieId ON MovieDirector(movieId);
CREATE INDEX IX_MovieActor_MovieId ON MovieActor(movieId);
GO



--******************CARREGAR FICHEIRO E ESCERVER NA DEVIDAS TABELAS
USE deisIMDB;
GO
/*
-- Ajuste o diretorio
DECLARE @basePath NVARCHAR(260) = N'D:\Projects\Coding\FilmeCiname\base_de_dados_cinena2026Lusofono\ficheiros\';


DECLARE @loads TABLE (
    TableName SYSNAME,
    FileName  NVARCHAR(260)
);

INSERT INTO @loads (TableName, FileName)
VALUES
    (N'Actors',    N'Actors.csv'),
    (N'movies',    N'movies.csv'),
   (N'Directors', N'Directors.csv'),
   (N'genres',      N'genres.csv'),
   (N'genres_movies',      N'genres_movies.csv'),
   (N'MovieActor',      N'MovieActor.csv'),
   (N'MovieDirector',      N'MovieDirector.csv'),
   (N'movie_votes',      N'movie_votes.csv');

DECLARE
    @tbl SYSNAME,
    @file NVARCHAR(260),
    @path NVARCHAR(520),
    @sql  NVARCHAR(MAX);

DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT TableName, FileName
    FROM @loads;

OPEN c;
FETCH NEXT FROM c INTO @tbl, @file;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @path = @basePath + @file;

    -- 1 tentativa: caso os ficheiros sejam carregados em linux
    SET @sql = N'
BULK INSERT ' + QUOTENAME(@tbl) + N'
FROM ' + QUOTENAME(@path,'''') + N'
WITH (
    DATAFILETYPE    = ''char'',
    FIELDTERMINATOR = '','',
    ROWTERMINATOR   = ''0x0a'',
    FIRSTROW        = 2,
    CODEPAGE        = ''65001''
);';



    BEGIN TRY
        PRINT N'Carregando ' + @file + N' em ' + @tbl + N' (ROWTERMINATOR = 0x0a)...';
        EXEC (@sql);
    END TRY


    BEGIN CATCH
        -- 2 tentativa: caso os ficheiros sejam carregados em windows
        PRINT N'Falha com 0x0a. A tentar novamente com 0x0d0a...';
        SET @sql = N'
BULK INSERT ' + QUOTENAME(@tbl) + N'
FROM ' + QUOTENAME(@path,'''') + N'
WITH (
    DATAFILETYPE    = ''char'',
    FIELDTERMINATOR = '','',
    ROWTERMINATOR   = ''0x0d0a'',
    FIRSTROW        = 2,
    CODEPAGE        = ''65001''
);';

        BEGIN TRY
            EXEC (@sql);
        END TRY
        BEGIN CATCH
            DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @ErrNum INT = ERROR_NUMBER();
            PRINT N'Falha ao carregar ' + @file + N' em ' + @tbl + N'. Erro ' + CAST(@ErrNum AS NVARCHAR(10)) + N': ' + @ErrMsg;
        END CATCH
    END CATCH

    FETCH NEXT FROM c INTO @tbl, @file;
END

CLOSE c;
DEALLOCATE c;
*/


ALTER TABLE movie_votes ADD source NVARCHAR(100) DEFAULT 'IMDb' NULL;

ALTER TABLE movies ADD ageRatingId INT NULL;

ALTER TABLE movies ADD registrationDate DATETIME DEFAULT '2026-01-01';

ALTER TABLE directors ADD created_at DATETIME DEFAULT GETDATE();

ALTER TABLE actors ADD created_at DATETIME DEFAULT GETDATE();



--*******************************INSERCAO MANUAL DOS DADOS NAS TABELAS
    -- 16. Inserir Interactions

    INSERT INTO Interaction (movieId, userId, interactionType, details) VALUES
    (56429, 1001, 'VIEW', 'Usuário visualizou detalhes do filme'),
    --(56429, 1002, 'RATE', 'Avaliação: 4 estrelas'),
    (95853, 1001, 'SEARCH', 'Pesquisa por filmes de animação'),
    (149870, 1003, 'VIEW', 'Visualização em dispositivo móvel'),
    (84084, 1004, 'RATE', 'Avaliação: 5 estrelas'),
    (12166, 1002, 'VIEW', 'Visualizaçãoo rápida');

-- Continentes
    INSERT INTO continent (continentName) VALUES
    ('Europe'), ('North America'), ('Asia'), ('Africa'), ('Oceania'), ('South America');

-- Platforms

 INSERT INTO Platform (platformName, website) VALUES
 ('Netflix', 'https://netflix.com'),
 ('HBO Max', 'https://hbomax.com'),
 ('Amazon Prime Video', 'https://primevideo.com'),
 ('Disney+', 'https://disneyplus.com'),
 ('YouTube Premium', 'https://youtube.com/premium');

-- Countries (associados a continentes)
INSERT INTO country (countryName, continentId) VALUES
('United Kingdom', (SELECT continentId FROM Continent WHERE continentName='Europe')),
('France', (SELECT continentId FROM Continent WHERE continentName='Europe')),
('Germany', (SELECT continentId FROM Continent WHERE continentName='Europe')),
('Spain', (SELECT continentId FROM Continent WHERE continentName='Europe')),
('Italy', (SELECT continentId FROM Continent WHERE continentName='Europe')),
('United States', (SELECT continentId FROM Continent WHERE continentName='North America')),
('Canada', (SELECT continentId FROM Continent WHERE continentName='North America')),
('Mexico', (SELECT continentId FROM Continent WHERE continentName='North America')),
('India', (SELECT continentId FROM Continent WHERE continentName='Asia')),
('China', (SELECT continentId FROM Continent WHERE continentName='Asia')),
('Japan', (SELECT continentId FROM Continent WHERE continentName='Asia')),
('Nigeria', (SELECT continentId FROM Continent WHERE continentName='Africa')),
('South Africa', (SELECT continentId FROM Continent WHERE continentName='Africa')),
('Australia', (SELECT continentId FROM Continent WHERE continentName='Oceania')),
('New Zealand', (SELECT continentId FROM Continent WHERE continentName='Oceania')),
('Brazil', (SELECT continentId FROM Continent WHERE continentName='South America')),
('Argentina', (SELECT continentId FROM Continent WHERE continentName='South America'));

 -- 15. Inserir MovieCountry
  INSERT INTO MovieCountry (movieId, countryId) VALUES
    (56429, 1),  -- EUA
    (95853, 3),  -- Japão
    (90532, 4),  -- India
    (149870, 1), -- EUA
    (84084, 5),  -- França
    (12166, 7),  -- Brasil
    (29920, 8),  -- Canada
    (24,(SELECT countryId FROM Country WHERE countryName='India')),
    (25,(SELECT countryId FROM Country WHERE countryName='China')),
    (26,(SELECT countryId FROM Country WHERE countryName='Japan')),
    (27,(SELECT countryId FROM Country WHERE countryName='India')),
    (28,(SELECT countryId FROM Country WHERE countryName='China')),
    (66,(SELECT countryId FROM Country WHERE countryName='Germany')),
    (93,(SELECT countryId FROM Country WHERE countryName='Italy')),
    (1365,(SELECT countryId FROM Country WHERE countryName='Germany')),
    (1375,(SELECT countryId FROM Country WHERE countryName='Italy')),
    (1419,(SELECT countryId FROM Country WHERE countryName='Germany')),
    (1640,(SELECT countryId FROM Country WHERE countryName='Italy'));

    INSERT INTO AgeRating (code, description, minAge) VALUES
    ('L', 'Livre', NULL),
    ('7+', 'Maiores de 7', 7),
    ('12+', 'Maiores de 12', 12),
    ('14+', 'Maiores de 14', 14),
    ('16+', 'Maiores de 16', 16),
    ('18+', 'Maiores de 18', 18),
    ('-10', 'Adequado até 10 anos', NULL);

     -- 14. Inserir MoviePlatform 
    INSERT INTO MoviePlatform (movieId, platformId, availableSince) VALUES
    (56429, 1, '2020-01-01'),
    (95853, 2, '2021-03-15'),
    (90532, 3, '2019-11-20'),
    (149870, 1, '2020-12-01'),
    (149870, 4, '2021-06-01'),
    (84084, 2, '2019-05-10'),
    (12166, 5, '2020-08-22');

    INSERT INTO genres_movies (genreId,movieId) VALUES (3817,1419),(3817,1640); --adicao de filmes da europa para genero accao


UPDATE movies set ageRatingId = 6  where movieId = 84084;
UPDATE movies set ageRatingId = 6 where movieId = 93;
UPDATE movies set ageRatingId = 5 where movieId = 66;
UPDATE movies set ageRatingId = 2  where movieId = 56429;
UPDATE movies set ageRatingId = 2 where movieId = 24;
UPDATE movies set ageRatingId = 2 where movieId = 1419;
UPDATE movies set ageRatingId = 2 where movieId = 1640;
UPDATE movies set movieReleaseDate = '2014-12-29' where movieId = 1419;
UPDATE movies set movieReleaseDate = '2017-12-17' where movieId = 1640;


    
--CONSULTAS

-- ============================================
-- EXECUTAR CONSULTAS (Etapa 2 - Exercicios 4.1 a 4.9)
-- ============================================
PRINT '=== EXECUTANDO CONSULTAS ===';

-- ----------------------------------------------------------------------------
-- EXERCiCIO 4.1: Obtenha/Liste todos os videos de um certo genero.
-- ABORDAGEM: 
-- 1. JOIN triplo: Movie -> MovieGenre (tabela de juncao) -> Genre
-- 2. Filtro no WHERE pelo nome do genero especifico ('Action')
-- 3. Seleciona apenas informações essenciais do video
-- OBS: Usamos INNER JOIN para garantir que se retorne videos com o genero especificado
-- ----------------------------------------------------------------------------
PRINT '4.1 - Videos do genero Action:';
SELECT 
    v.movieId, 
    v.movieName, 
    v.movieReleaseDate
FROM Movies v
INNER JOIN genres_movies vg ON v.movieId = vg.movieId  -- Liga videos aos seus generos
INNER JOIN Genres g ON vg.genreId = g.genreId        -- Obtem detalhes do genero
WHERE g.genreName = 'Action';                       -- Filtra apenas videos de Action
GO

-- ----------------------------------------------------------------------------
-- EXERCiCIO 4.2: Obtenha/Liste a informacao de todos os directores de videos 
--                produzidos num qualquer pais.
-- ABORDAGEM:
-- 1. JOIN em cadeia: Director -> MovieDirector -> MovieCountry -> Country
-- 2. DISTINCT para evitar duplicados (um diretor pode ter multiplos filmes no mesmo pais)
-- 3. Filtro pelo nome do pais ('United States')
-- OBS: A estrutura permite expandir para qualquer pais mudando a condicao WHERE
-- ----------------------------------------------------------------------------
PRINT '4.2 - Diretores de videos produzidos nos EUA:';
SELECT DISTINCT 
    d.directorId, 
    d.directorName
FROM Directors d
INNER JOIN MovieDirector vd ON d.directorId = vd.directorId      -- Liga diretor aos seus videos
INNER JOIN MovieCountry vc ON vd.movieId = vc.movieId            -- Liga videos aos paises de producao
INNER JOIN Country c ON vc.countryId = c.countryId               -- Obtem detalhes do pais
WHERE c.countryName = 'United Kingdom';                           -- Filtra por pais especifico
GO

-- ----------------------------------------------------------------------------
-- EXERCiCIO 4.3: Obtenha/Liste a informacao de todos os atores do sexo Masculino 
--                que participaram em filmes de paises Asiáticos.
-- ABORDAGEM:
-- 1. JOIN complexa: Actor -> MovieActor -> MovieCountry -> Country -> Continent
-- 2. Duplo filtro: gênero Masculino + continente Ásia
-- 3. DISTINCT para atores que atuaram em multiplos filmes asiáticos
-- OBS: A hierarquia Continent->Country permite filtragem geográfica flexivel
-- ----------------------------------------------------------------------------
PRINT '4.3 - Atores Masculinos em filmes Asiáticos:';
SELECT DISTINCT 
    a.actorId, 
    a.actorName, 
    a.actorGender,
    ct.continentName
FROM Actors a
INNER JOIN MovieActor va ON a.actorId = va.actorId              -- Liga ator aos seus videos
INNER JOIN MovieCountry vc ON va.movieId = vc.movieId           -- Liga videos aos paises
INNER JOIN Country c ON vc.countryId = c.countryId              -- Obtem pais
INNER JOIN Continent ct ON c.continentId = ct.continentId       -- Obtem continente do pais
WHERE a.actorGender = 'M' AND ct.continentName = 'Asia';        -- Filtro duplo: gênero + continente
GO




-- ----------------------------------------------------------------------------
-- EXERCiCIO 4.4: Obtenha/Liste todos os videos lançados nos meses de Maio, Junho e Julho.
-- ABORDAGEM:
-- 1. Consulta simples na tabela Movie (não precisa de JOINs)
-- 2. Uso da funcao MONTH() para extrair o mês da data
-- 3. Operador IN para filtrar multiplos meses simultaneamente
-- 4. ORDER BY para ordenacao cronológica
-- OBS: Funcao MONTH() retorna inteiro (5=Maio, 6=Junho, 7=Julho)
-- ----------------------------------------------------------------------------
PRINT '4.4 - Videos lançados em Maio, Junho e Julho:';
SELECT 
    movieId, 
    movieName, 
    movieReleaseDate,
    MONTH(movieReleaseDate) as ReleaseMonth  -- Extrai mês para visualizacao
FROM Movies
WHERE MONTH(movieReleaseDate) IN (5, 6, 7)   -- Filtra pelos meses especificados
ORDER BY movieReleaseDate;                    -- Ordena por data de lançamento
GO

-- ----------------------------------------------------------------------------
-- EXERCiCIO 4.5: Obtenha/Liste todos os videos de accao (Action) realizados num 
--                pais europeu e lançados em Dezembro.
-- ABORDAGEM:
-- 1. JOIN multipla: Movie -> MovieGenre -> Genre -> MovieCountry -> Country -> Continent
-- 2. Filtro triplo: genero Action + continente Europa + mês Dezembro
-- 3. MONTH()=12 para Dezembro
-- OBS: Condições especificas combinadas com AND para precisão na filtragem
-- ----------------------------------------------------------------------------
PRINT '4.5 - Videos de Action europeus lançados em Dezembro:';
SELECT 
    v.movieId, 
    v.movieName, 
    v.movieReleaseDate, 
    c.countryName, 
    ct.continentName
FROM Movies v
INNER JOIN genres_movies vg ON v.movieId = vg.movieId              -- Para filtrar por genero
INNER JOIN Genres g ON vg.genreId = g.genreId                    -- Obtem nome do genero
INNER JOIN MovieCountry vc ON v.movieId = vc.movieId            -- Para filtrar por pais
INNER JOIN Country c ON vc.countryId = c.countryId              -- Obtem nome do i
INNER JOIN Continent ct ON c.continentId = ct.continentId       -- Para filtrar por continente
WHERE g.genreId = 3817                                    -- Condicao 1: genero Action
  AND ct.continentId = 1                                  -- Condicao 2: Continente Europa
  AND MONTH(v.movieReleaseDate) = 12;                           -- Condicao 3: Mês Dezembro
GO

-- ----------------------------------------------------------------------------
-- EXERCICIO 4.6: Obtenha/Liste todos os vIdeos para maiores de 18 (ex: 18+)
-- ABORDAGEM:
-- 1. JOIN simples: Movie -> AgeRating
-- 2. Filtro por classificacao etaria: idade minima >= 18 OU copdigo '18+'
-- 3. Inclui codigo e descricao para verificacao
-- OBS: Condicao OR abrange diferentes formatos de classificacao (idade numerica ou codigo)
-- ----------------------------------------------------------------------------
PRINT '4.6 - Videos para maiores de 18:';
SELECT 
    v.movieId, 
    v.movieName, 
    ar.code, 
    ar.description
FROM Movies v
INNER JOIN AgeRating ar ON v.ageRatingId = ar.ageRatingId       -- Liga a classificacao etaria
WHERE ar.minAge >= 18 OR ar.code = '18+';                       -- Filtro duplo para +18
GO

-- ----------------------------------------------------------------------------
-- EXERCiCIO 4.7: Conte quantos videos existem para menores de 10 (ex: -10) 
--                produzidos por Continente.
-- ABORDAGEM:
-- 1. JOIN em cadeia: Movie ->AgeRating -> MovieCountry -> Country -> Continent
-- 2. Filtro por classificacao para menores de 10 (codigo '-10' OU minAge < 10)
-- 3. GROUP BY por continente para agregacao
-- 4. COUNT(DISTINCT) para evitar contagem duplicada de videos em multiplos ies
-- 5. ORDER BY descendente para destacar continentes com mais videos
-- OBS: DISTINCT no COUNT e crucial pois um video pode ser produzido em vários paises
-- ----------------------------------------------------------------------------
PRINT '4.7 - Videos para menores de 10 por Continente:';
SELECT 
    ct.continentName, 
    COUNT(DISTINCT v.movieId) as TotalMovies  -- Conta vdeos unicos por continente
FROM Movies v
INNER JOIN AgeRating ar ON v.ageRatingId = ar.ageRatingId       -- Classificacao etária
INNER JOIN MovieCountry vc ON v.movieId = vc.movieId            -- ies de producao
INNER JOIN Country c ON vc.countryId = c.countryId              -- Detalhes do pais
INNER JOIN Continent ct ON c.continentId = ct.continentId       -- Continente do pais
WHERE ar.code = '-10' OR ar.minAge < 10                         -- Filtro para menores de 10
GROUP BY ct.continentName                                       -- Agrupa resultados por continente
ORDER BY TotalMovies DESC;                                      -- Ordena do maior para menor
GO

-- ----------------------------------------------------------------------------
-- EXERCICIO 4.8: Conte quantos videos existem para maiores de 18 (ex: 18+) 
--                produzidos por pais da Europa.
-- ABORDAGEM:
-- 1. Similar ao 4.7, mas com filtros diferentes
-- 2. Filtro duplo: classificacao 18+ E continente Europa
-- 3. GROUP BY por i (nao por continente)
-- 4. COUNT(DISTINCT) para videos unicos por pais
-- OBS: Parenteses na condicao WHERE garantem logica correta com operador OR
-- ----------------------------------------------------------------------------
PRINT '4.8 - Videos 18+ por pais europeu:';
SELECT 
    c.countryName, 
    COUNT(DISTINCT v.movieId) as TotalMovies  -- Conta videos unicos por pais
FROM Movies v
INNER JOIN AgeRating ar ON ar.ageRatingId = v.ageRatingId       -- Classificacao etaria
INNER JOIN MovieCountry vc ON v.movieId = vc.movieId            -- paises de producao
INNER JOIN Country c ON vc.countryId = c.countryId              -- Detalhes do pais
INNER JOIN Continent ct ON c.continentId = ct.continentId       -- Continente do pais
WHERE (ar.minAge >= 18 OR ar.code = '18+')                      -- Condicao 1: Classificacao 18+
  --AND ct.continentName = 'Europe'                               -- Condicao 2: Apenas paises europeus
GROUP BY c.countryName                                          -- Agrupa resultados por pais
ORDER BY TotalMovies DESC;                                      -- Ordena do maior para menor
GO



-- ----------------------------------------------------------------------------
-- EXERCiCIO 4.9: Qual o nome dos top 10 directores com melhor rating medio 
--                nos seus filmes.
-- ABORDAGEM:
-- 1. JOIN em cadeia: Director  MovieDirector  Rating
-- 2. Funcoees agregadas: AVG para media, COUNT para numero de filmes, SUM para votos totais
-- 3. GROUP BY por diretor para agregar estatisticas
-- 4. HAVING para garantir que diretor tenha pelo menos 1 filme avaliado
-- 5. TOP 10 + ORDER BY AVG DESC para os melhores ratings
-- 6. Inclui metricas adicionais (numero de filmes, votos totais) para contexto
-- OBS: AVG considera todos os ratings dos filmes do diretor, ponderados por filme
-- ----------------------------------------------------------------------------
PRINT '4.9 - Top 10 diretores por rating medio:';
SELECT TOP 10 
    d.directorId, 
    d.directorName, 
    AVG(r.movieRating) as AvgRating,                -- Media de ratings dos filmes do diretor
    COUNT(DISTINCT vd.movieId) as NumberOfMovies,   -- Numero de filmes distintos dirigidos
    SUM(r.movieRatingCount) as TotalVotes           -- Soma total de votos recebidos
FROM Directors d
INNER JOIN MovieDirector vd ON d.directorId = vd.directorId    -- Liga diretor aos seus filmes
INNER JOIN movie_votes r ON vd.movieId = r.movieId                  -- Liga filmes aos seus ratings
GROUP BY d.directorId, d.directorName                         -- Agrupa por diretor
HAVING COUNT(DISTINCT vd.movieId) >= 1                        -- Garante que diretor tem filmes
ORDER BY AvgRating DESC;                                      -- Ordena pela melhor media
GO

--********************************VIEWS

-- a) Top 5 diretores com mais filmes produzidos
GO
CREATE VIEW vw_Top5Directors AS
SELECT TOP 5
    d.directorId,
    d.directorName,
    COUNT(md.movieId) AS movieCount
FROM Directors d
JOIN MovieDirector md ON d.directorId = md.directorId
GROUP BY d.directorId, d.directorName
ORDER BY COUNT(md.movieId) DESC;
GO

-- b) Top 10 atores participantes em filmes
GO
CREATE VIEW vw_Top10Actors AS
SELECT TOP 10
    a.actorId,
    a.actorName,
    COUNT(ma.movieId) AS participationCount
FROM Actors a
JOIN MovieActor ma ON a.actorId = ma.actorId
GROUP BY a.actorId, a.actorName
ORDER BY COUNT(ma.movieId) DESC;
GO

-- c) Paises com menos de 5 filmes produzidos

CREATE VIEW vw_CountriesLessThan5Movies AS
SELECT
    c.countryId,
    c.countryName,
    COUNT(mc.movieId) AS movieCount
FROM Country c
LEFT JOIN MovieCountry mc ON c.countryId = mc.countryId
GROUP BY c.countryId, c.countryName
HAVING COUNT(mc.movieId) < 5;
GO

GO
-- d) Continentes com mais de 10 filmes produzidos
CREATE VIEW vw_ContinentsMoreThan10Movies AS
SELECT
    cont.continentId,
    cont.continentName,
    COUNT(mc.movieId) AS movieCount
FROM Continent cont
JOIN Country c ON cont.continentId = c.continentId
JOIN MovieCountry mc ON c.countryId = mc.countryId
GROUP BY cont.continentId, cont.continentName
HAVING COUNT(mc.movieId) > 10;

GO

----**********************************VIEWS***************************

-- return all columns/rows
SELECT * FROM dbo.vw_Top5Directors;

SELECT * FROM vw_Top10Actors;

SELECT * FROM  vw_ContinentsMoreThan10Movies;

SELECT * FROM  vw_CountriesLessThan5Movies;


--****************************PROCEDIMENTOS

--2.1. COUNT_MOVIES_MONTH_YEAR <month> <year>
GO
CREATE PROCEDURE dbo.COUNT_MOVIES_MONTH_YEAR
    @month INT,
    @year INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS MovieCount
    FROM dbo.Movies
    WHERE MONTH(movieReleaseDate) = @month
      AND YEAR(movieReleaseDate) = @year;
END
GO


--2.2. COUNT_MOVIES_DIRECTOR <full-name>
CREATE PROCEDURE dbo.COUNT_MOVIES_DIRECTOR
    @fullName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.directorId, d.directorName, COUNT(md.movieId) AS MovieCount
    FROM dbo.Directors d
    LEFT JOIN dbo.MovieDirector md ON d.directorId = md.directorId
    WHERE d.directorName = @fullName
    GROUP BY d.directorId, d.directorName;
END
GO


--2.3. COUNT_ACTORS_IN_2_YEARS <year-1> <year-2>
CREATE PROCEDURE dbo.COUNT_ACTORS_IN_2_YEARS
    @year1 INT,
    @year2 INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(DISTINCT ma.actorId) AS ActorsInBothYears
    FROM dbo.MovieActor ma
    JOIN dbo.Movies m ON ma.movieId = m.movieId
    WHERE YEAR(m.movieReleaseDate) IN (@year1, @year2)
    GROUP BY ma.actorId
    HAVING COUNT(DISTINCT YEAR(m.movieReleaseDate)) = 2;
END
GO


--2.4. COUNT_MOVIES_BETWEEN_YEARS_WITH_N_ACTO--RS <year-start>  <year-end>  <min>  <max> 
CREATE PROCEDURE dbo.COUNT_MOVIES_BETWEEN_YEARS_WITH_N_ACTORS
    @yearStart INT,
    @yearEnd INT,
    @minActors INT,
    @maxActors INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS MovieCount
    FROM (
        SELECT m.movieId, COUNT(ma.actorId) AS ActorCount
        FROM dbo.Movies m
        LEFT JOIN dbo.MovieActor ma ON m.movieId = ma.movieId
        WHERE YEAR(m.movieReleaseDate) BETWEEN @yearStart AND @yearEnd
        GROUP BY m.movieId
    ) t
    WHERE t.ActorCount BETWEEN @minActors AND @maxActors;
END
GO


--2.5. GET_MOVIES_ACTOR_YEAR <year> <full-name> 
CREATE PROCEDURE dbo.GET_MOVIES_ACTOR_YEAR
    @year INT,
    @actorFullName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.movieId, m.movieName, m.movieReleaseDate, ma.characterName
    FROM dbo.Movies m
    JOIN dbo.MovieActor ma ON m.movieId = ma.movieId
    JOIN dbo.Actors a ON ma.actorId = a.actorId
    WHERE YEAR(m.movieReleaseDate) = @year
      AND a.actorName = @actorFullName
    ORDER BY m.movieReleaseDate;
END
GO
    

--2.6. GET_MOVIES_WITH_ACTOR_CONTAINING <name> 
CREATE PROCEDURE dbo.GET_MOVIES_WITH_ACTOR_CONTAINING
    @namePart NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DISTINCT m.movieId, m.movieName, m.movieReleaseDate
    FROM dbo.Movies m
    JOIN dbo.MovieActor ma ON m.movieId = ma.movieId
    JOIN dbo.Actors a ON ma.actorId = a.actorId
    WHERE a.actorName LIKE '%' + @namePart + '%'
    ORDER BY m.movieReleaseDate DESC;
END
GO


--2.7. GET_TOP_4_YEARS_WITH_MOVIES_CONTAINING <search-string> 
CREATE PROCEDURE dbo.GET_TOP_4_YEARS_WITH_MOVIES_CONTAINING
    @searchString NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 4 YEAR(m.movieReleaseDate) AS [Year], COUNT(*) AS MovieCount
    FROM dbo.Movies m
    WHERE m.movieName LIKE '%' + @searchString + '%'
      AND m.movieReleaseDate IS NOT NULL
    GROUP BY YEAR(m.movieReleaseDate)
    ORDER BY COUNT(*) DESC, YEAR(m.movieReleaseDate) DESC;
END
GO



--2.8. GET_ACTORS_BY_DIRECTOR <num> <full-name> 
CREATE PROCEDURE dbo.GET_ACTORS_BY_DIRECTOR
    @topN INT,
    @directorFullName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@topN) a.actorId, a.actorName, COUNT(*) AS TimesWorkedTogether
    FROM dbo.Directors d
    JOIN dbo.MovieDirector md ON d.directorId = md.directorId
    JOIN dbo.MovieActor ma ON md.movieId = ma.movieId
    JOIN dbo.Actors a ON ma.actorId = a.actorId
    WHERE d.directorName = @directorFullName
    GROUP BY a.actorId, a.actorName
    ORDER BY COUNT(*) DESC, a.actorName;
END
GO



--2.9. TOP_MONTH_MOVIE_COUNT <year> 
CREATE PROCEDURE dbo.TOP_MONTH_MOVIE_COUNT
    @year INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 MONTH(m.movieReleaseDate) AS MonthNumber,
                 DATENAME(month, DATEFROMPARTS(@year, MONTH(m.movieReleaseDate), 1)) AS MonthName,
                 COUNT(*) AS MovieCount
    FROM dbo.Movies m
    WHERE YEAR(m.movieReleaseDate) = @year
    GROUP BY MONTH(m.movieReleaseDate)
    ORDER BY COUNT(*) DESC, MONTH(m.movieReleaseDate);
END
GO

-- 2.10. TOP_VOTED_ACTORS <num>  <year>
CREATE OR ALTER PROCEDURE dbo.TOP_VOTED_ACTORS
    @topN INT,
    @year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@topN)
        a.actorId,
        a.actorName,
        AVG(r.movieRating) AS AvgRating,
        COUNT(DISTINCT r.movieId) AS RatedMoviesCount
    FROM dbo.Actors AS a
    JOIN dbo.MovieActor AS ma
        ON a.actorId = ma.actorId
    JOIN dbo.Movies AS m
        ON ma.movieId = m.movieId
    JOIN dbo.movie_votes AS r           
        ON r.movieId = m.movieId       
    WHERE
        m.movieReleaseDate >= DATEFROMPARTS(@year, 1, 1)   
        AND m.movieReleaseDate <  DATEFROMPARTS(@year + 1, 1, 1)
    GROUP BY
        a.actorId, a.actorName
    HAVING
        COUNT(DISTINCT r.movieId) > 0   
    ORDER BY
        AVG(r.movieRating) DESC,        
        RatedMoviesCount DESC;
END;


--2.11. TOP_MOVIES_WITH_MORE_GENDER <num>  <year> --<gender> 
GO
CREATE PROCEDURE dbo.TOP_MOVIES_WITH_MORE_GENDER
    @topN INT,
    @year INT,
    @gender CHAR(1)  -- 'M' or 'F'
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@topN)
        m.movieId,
        m.movieName,
        COUNT(CASE WHEN a.actorGender = @gender THEN 1 END) AS GenderCount,
        COUNT(ma.actorId) AS TotalActors
    FROM dbo.Movies m
    JOIN dbo.MovieActor ma ON m.movieId = ma.movieId
    JOIN dbo.Actors a ON ma.actorId = a.actorId
    WHERE YEAR(m.movieReleaseDate) = @year
    GROUP BY m.movieId, m.movieName
    ORDER BY GenderCount DESC, TotalActors DESC;
END
GO


--2.12. TOP_MOVIES_WITH_GENDER_BIAS <num>  <year>
CREATE PROCEDURE dbo.TOP_MOVIES_WITH_GENDER_BIAS
    @topN INT,
    @year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@topN)
        m.movieId,
        m.movieName,
        SUM(CASE WHEN a.actorGender = 'M' THEN 1 ELSE 0 END) AS MaleCount,
        SUM(CASE WHEN a.actorGender = 'F' THEN 1 ELSE 0 END) AS FemaleCount,
        ABS(SUM(CASE WHEN a.actorGender = 'M' THEN 1 ELSE 0 END)
            - SUM(CASE WHEN a.actorGender = 'F' THEN 1 ELSE 0 END)) AS GenderBias,
        COUNT(ma.actorId) AS TotalActors
    FROM dbo.Movies m
    JOIN dbo.MovieActor ma ON m.movieId = ma.movieId
    JOIN dbo.Actors a ON ma.actorId = a.actorId
    WHERE YEAR(m.movieReleaseDate) = @year
    GROUP BY m.movieId, m.movieName
    ORDER BY GenderBias DESC, TotalActors DESC;
END
GO

--2.13. TOP_6_DIRECTORS_WITHIN_FAMILY <year-start>  --<year-end> 
CREATE PROCEDURE dbo.TOP_6_DIRECTORS_WITHIN_FAMILY
    @yearStart INT,
    @yearEnd INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 6
        d.directorId,
        d.directorName,
        COUNT(DISTINCT md.movieId) AS MovieCount
    FROM dbo.Directors d
    JOIN dbo.MovieDirector md ON d.directorId = md.directorId
    JOIN dbo.Movies m ON md.movieId = m.movieId
    LEFT JOIN dbo.genres_movies mg ON m.movieId = mg.movieId
    LEFT JOIN dbo.Genres g ON mg.genreId = g.genreId
    -- calcula a lista de generos distintos por director no intervalo pedido
    CROSS APPLY (
        SELECT STRING_AGG(dg.genreName, ', ') AS Genres
        FROM (
            SELECT DISTINCT g2.genreName
            FROM dbo.MovieDirector md2
            JOIN dbo.Movies m2 ON md2.movieId = m2.movieId
            LEFT JOIN dbo.genres_movies mg2 ON m2.movieId = mg2.movieId
            LEFT JOIN dbo.Genres g2 ON mg2.genreId = g2.genreId
            WHERE md2.directorId = d.directorId
              AND YEAR(m2.movieReleaseDate) BETWEEN @yearStart AND @yearEnd
              AND g2.genreName IS NOT NULL
        ) dg
    ) ga
    WHERE YEAR(m.movieReleaseDate) BETWEEN @yearStart AND @yearEnd
    GROUP BY d.directorId, d.directorName, ga.Genres
    ORDER BY COUNT(DISTINCT md.movieId) DESC, d.directorName;
END
GO

--2.14. DISTANCE_BETWEEN_ACTORS <actor-1>   <actor-2>
 
-- 1) Busca rapida pelo ID a partir do nome do ator
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Actors_actorName' AND object_id = OBJECT_ID('dbo.Actors')
)
CREATE INDEX IX_Actors_actorName ON dbo.Actors(actorName);

-- 2) Recuperar atores de um filme (movieId -> actorId)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_MovieActor_movie_actor' AND object_id = OBJECT_ID('dbo.MovieActor')
)
CREATE INDEX IX_MovieActor_movie_actor ON dbo.MovieActor(movieId, actorId);

-- 3) Recuperar filmes de um ator (actorId -> movieId)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_MovieActor_actor_movie' AND object_id = OBJECT_ID('dbo.MovieActor')
)
CREATE INDEX IX_MovieActor_actor_movie ON dbo.MovieActor(actorId, movieId);

GO

CREATE OR ALTER PROCEDURE dbo.DISTANCE_BETWEEN_ACTORS
    @actor1 NVARCHAR(255),
    @actor2 NVARCHAR(255),
    @MaxDepth INT = 12   -- limite de seguranca; ajuste conforme necessario
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @startId INT = (SELECT actorId FROM dbo.Actors WHERE actorName = @actor1);
    DECLARE @targetId INT = (SELECT actorId FROM dbo.Actors WHERE actorName = @actor2);

    IF @startId IS NULL OR @targetId IS NULL
    BEGIN
        SELECT CAST(NULL AS INT) AS Distance, 'One or both actor names not found' AS Note;
        RETURN;
    END

    IF @startId = @targetId
    BEGIN
        SELECT 0 AS Distance,
               CONCAT('[', @actor1, ']') AS Path;
        RETURN;
    END

/* ---------- Atalhos: 1 e 2 passos ---------- */

    -- Distância 1: mesmo filme
    IF EXISTS (
        SELECT 1
        FROM dbo.MovieActor ma1
        JOIN dbo.MovieActor ma2
          ON ma2.movieId = ma1.movieId
         AND ma2.actorId  = @targetId
        WHERE ma1.actorId = @startId
    )
    BEGIN
        SELECT 1 AS Distance,
               CONCAT(@actor1, ' -> ', @actor2) AS Path;
        RETURN;
    END

-- Distância 2: ator intermedio comum
    DECLARE @bridgeId INT;
    SELECT TOP (1) @bridgeId = s.actorId
    FROM (
        SELECT DISTINCT ma2.actorId
        FROM dbo.MovieActor ma1
        JOIN dbo.MovieActor ma2
          ON ma2.movieId = ma1.movieId
         AND ma2.actorId <> ma1.actorId
        WHERE ma1.actorId = @startId
    ) AS s
    INNER JOIN (
        SELECT DISTINCT ma2.actorId
        FROM dbo.MovieActor ma1
        JOIN dbo.MovieActor ma2
          ON ma2.movieId = ma1.movieId
         AND ma2.actorId <> ma1.actorId
        WHERE ma1.actorId = @targetId)
         AS t
      ON t.actorId = s.actorId;

    IF @bridgeId IS NOT NULL
    BEGIN
        SELECT 2 AS Distance,
               CONCAT(@actor1, ' -> ', (SELECT actorName FROM dbo.Actors WHERE actorId = @bridgeId), ' -> ', @actor2) AS Path;
        RETURN;
END
    -- Nos visitados
    CREATE TABLE #Visited (
        actorId INT PRIMARY KEY
    );

    -- Antecessor e profundidade (para reconstruir caminho)
    CREATE TABLE #Parent (
        actorId INT PRIMARY KEY,
        prevActorId INT NULL,
        depth INT NOT NULL
    );

    -- Fronteira (nivel atual da BFS)
    CREATE TABLE #Frontier (
        actorId INT PRIMARY KEY
    );

    INSERT INTO #Visited(actorId) VALUES (@startId);
    INSERT INTO #Parent(actorId, prevActorId, depth) VALUES (@startId, NULL, 0);
    INSERT INTO #Frontier(actorId) VALUES (@startId);

    DECLARE @depth INT = 0;
    DECLARE @found BIT = 0;

    WHILE @found = 0 AND @depth < @MaxDepth AND EXISTS(SELECT 1 FROM #Frontier)
    BEGIN
        SET @depth += 1;

        -- Proxima fronteira
        CREATE TABLE #NextFrontier (actorId INT PRIMARY KEY);
  /* 
           Descoberta determinística do pai:
           Para cada ator f na fronteira, inserimos todos os vizinhos ainda não visitados;
           Registramos o pai como f.actorId quando o vizinho é visto pela 1ª vez.
        */
        INSERT INTO #NextFrontier(actorId)
        SELECT DISTINCT ma2.actorId
        FROM #Frontier f
        JOIN dbo.MovieActor ma1
          ON ma1.actorId = f.actorId
        JOIN dbo.MovieActor ma2
          ON ma2.movieId = ma1.movieId
         AND ma2.actorId <> ma1.actorId
        LEFT JOIN #Visited v
          ON v.actorId = ma2.actorId
        WHERE v.actorId IS NULL;

        -- Registra pais e profundidade dos nos recm-descobertos (garante menor distancia por BFS)
        INSERT INTO #Parent(actorId, prevActorId, depth)
        SELECT nf.actorId,
               MIN(f.actorId) AS prevActorId,
               @depth AS depth
        FROM #NextFrontier nf
        JOIN #Frontier f
          ON EXISTS (
               SELECT 1
               FROM dbo.MovieActor x1
               JOIN dbo.MovieActor x2
                 ON x2.movieId = x1.movieId
               WHERE x1.actorId = f.actorId
                 AND x2.actorId = nf.actorId
                 AND x2.actorId <> x1.actorId
          )
        LEFT JOIN #Parent p ON p.actorId = nf.actorId
        WHERE p.actorId IS NULL
        GROUP BY nf.actorId;

        -- Marca visitados
        INSERT INTO #Visited(actorId)
        SELECT nf.actorId
        FROM #NextFrontier nf
        WHERE NOT EXISTS (SELECT 1 FROM #Visited v WHERE v.actorId = nf.actorId);

        -- Verifica alvo
        IF EXISTS (SELECT 1 FROM #NextFrontier WHERE actorId = @targetId)
            SET @found = 1;

        -- Avanca fronteira
        DELETE FROM #Frontier;
        INSERT INTO #Frontier(actorId)
        SELECT actorId FROM #NextFrontier;

        DROP TABLE #NextFrontier;
    END

    IF @found = 1
    BEGIN
        -- Reconstroi caminho por IDs (do alvo ate a origem)
        DECLARE @pathIds TABLE (pos INT IDENTITY(1,1), actorId INT);
        DECLARE @curr INT = @targetId;

        WHILE @curr IS NOT NULL
        BEGIN
            INSERT INTO @pathIds(actorId) VALUES (@curr);
            SELECT @curr = prevActorId
            FROM #Parent
            WHERE actorId = @curr;
        END

        -- Converte para nomes na ordem correta (origem -> alvo)
        -- Observacao: como @pathIds foi preenchida do alvo para a origem,
        -- precisamos inverter a ordem. Fazemos isso na STRING_AGG:
        SELECT
            (SELECT depth FROM #Parent WHERE actorId = @targetId) AS Distance,
            STRING_AGG(a.actorName, ' -> ') WITHIN GROUP (ORDER BY p.pos DESC) AS Path
        FROM @pathIds AS p
        JOIN dbo.Actors AS a
          ON a.actorId = p.actorId;
    END
    ELSE
    BEGIN
        SELECT CAST(NULL AS INT) AS Distance,
               'No connection found between actors or depth limit reached' AS Note;
    END
END
GO


---------------------------------CHAMAR OS PROCEDIMENTOS------------------------

--2.1
EXEC dbo.COUNT_MOVIES_MONTH_YEAR @month = 2, @year = 2000;

--2.2
EXEC dbo.COUNT_MOVIES_DIRECTOR @fullName = N'Albert Brooks';

--2.3
EXEC dbo.COUNT_ACTORS_IN_2_YEARS @year1 = 1999, @year2 = 2001;


--2.4
EXEC dbo.COUNT_MOVIES_BETWEEN_YEARS_WITH_N_ACTORS @yearStart = 2005, @yearEnd = 2015, @minActors = 3, @maxActors = 8;


--2.5
EXEC dbo.GET_MOVIES_ACTOR_YEAR @year = 2006, @actorFullName = N'George Lucas';

--2.6
EXEC dbo.GET_MOVIES_WITH_ACTOR_CONTAINING @namePart = N'George Lucas';

--2.7
EXEC dbo.GET_TOP_4_YEARS_WITH_MOVIES_CONTAINING @searchString = N'Film';

--2.8
EXEC dbo.GET_ACTORS_BY_DIRECTOR @topN = 5, @directorFullName = N'George Lucas';

--2.9
EXEC dbo.TOP_MONTH_MOVIE_COUNT @year = 2000;

--2.10
EXEC dbo.TOP_VOTED_ACTORS @topN = 5, @year = 2001;

--2.11
EXEC dbo.TOP_MOVIES_WITH_MORE_GENDER @topN = 10, @year = 2000, @gender = 'M';

--2.12
EXEC dbo.TOP_MOVIES_WITH_GENDER_BIAS @topN = 10, @year = 2000;

--2.13
EXEC dbo.TOP_6_DIRECTORS_WITHIN_FAMILY @yearStart = 1900, @yearEnd = 2024;


--2.14
EXEC dbo.DISTANCE_BETWEEN_ACTORS @actor1 = N'Leonardo Dicaprio', @actor2 = N'Michael Caine';

--Insert into MovieActor (movieId,actorId) VALUES (63540,3895)


--************************TRIGGERS*********************************

/*Sem que o utilizador se aperceba, sempre que se tentar 
apagar um diretor, ele nao e de facto apagado, mas no seu
lugar e colocado um campo hidden a True. Por defeito,
este campo est  a False (criar coluna de [hiden], se nao
existir). Adicionalmente devera ser feito um registo numa
tabela de Audit com a informacao da acao executada
(DELETE) e do dia e hora em que foi executada. 
*/

USE deisIMDB;
GO

-- 1. Adicionar coluna hidden na tabela Director - se nao existir
IF COL_LENGTH('dbo.Director','hidden') IS NULL
BEGIN
    ALTER TABLE dbo.Directors
    ADD hidden BIT NOT NULL CONSTRAINT DF_Director_Hidden DEFAULT (0);
END
GO

-- 2. Criar tabela de auditoria (AuditLog)
IF OBJECT_ID('dbo.AuditLog','U') IS NOT NULL
    DROP TABLE dbo.AuditLog;
GO

CREATE TABLE dbo.AuditLog (
    AuditId INT IDENTITY(1,1) PRIMARY KEY,
    ObjectType NVARCHAR(50) NOT NULL,      -- e.g., 'Director', 'Actor'
    ObjectId INT NULL,                     -- id da entidade afetada
    ObjectName NVARCHAR(255) NULL,         -- nome (quando aplic vel)
    ActionType NVARCHAR(20) NOT NULL,      -- e.g., 'DELETE', 'INSERT', 'UPDATE'
    ActionDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Details NVARCHAR(1000) NULL,           -- informacao adicional (JSON/text)
    ExecutedBy NVARCHAR(255) NULL          -- opcional: user name / application
);
GO

-- 3) Trigger: impedir delete fisico em Director -> marcar hidden = 1 e registar AuditLog
IF OBJECT_ID('dbo.trg_Director_InsteadOfDelete','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Director_InsteadOfDelete;
GO

CREATE TRIGGER dbo.trg_Director_InsteadOfDelete
ON dbo.Directors
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Marcar hidden = 1 para os directors que foram "apagados"
    UPDATE d 
    SET hidden = 1
    FROM dbo.Directors d
    JOIN deleted del ON d.directorId = del.directorId;

    -- 2) Inserir registos de auditoria para cada linha "apagada"
    INSERT INTO dbo.AuditLog (ObjectType, ObjectId, ObjectName, ActionType, ActionDate, Details, ExecutedBy)
    SELECT
        'Directors' AS ObjectType,
        del.directorId AS ObjectId,
        del.directorName AS ObjectName,
        'DELETE' AS ActionType,
        SYSUTCDATETIME() AS ActionDate,
        CONCAT('Soft-delete performed; previous hidden=', COALESCE(CAST(del.hidden AS NVARCHAR(5)),'NULL')) AS Details,
        SUSER_SNAME() AS ExecutedBy
    FROM deleted del;
END
GO

-- 4) Trigger: registar inser  es em Actor (AFTER INSERT)
IF OBJECT_ID('dbo.trg_Actor_AfterInsert','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Actor_AfterInsert;
GO

CREATE TRIGGER dbo.trg_Actor_AfterInsert
ON dbo.Actors
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AuditLog (ObjectType, ObjectId, ObjectName, ActionType, ActionDate, Details, ExecutedBy)
    SELECT
        'Actor' AS ObjectType,
        ins.actorId AS ObjectId,
        ins.actorName AS ObjectName,
        'INSERT' AS ActionType,
        SYSUTCDATETIME() AS ActionDate,
        -- guardar dados originais da insercao em formato legivel
        CONCAT('actorGender=', ins.actorGender) AS Details,
        SUSER_SNAME() AS ExecutedBy
    FROM inserted ins;
END
GO


--******************************TRIGGERS

-- Inserir um actor (ver trigger de INSERT)
INSERT INTO dbo.Actors (actorId, actorName, actorGender) VALUES (999, N'Test Actor', 'M');
-- Verificar registo na AuditLog
SELECT TOP 1 * FROM dbo.AuditLog WHERE ObjectType='Actor' AND ObjectId = 999 ORDER BY AuditId DESC;

-- Tentar apagar um director (sera soft-deleted)
-- (crie um director de teste se necess rio)
INSERT INTO dbo.Directors (directorId, directorName) VALUES (999, N'Test Director');
-- Apagar (o trigger ir  marcar hidde = 1 e inserir AuditLog)
DELETE FROM dbo.Directors WHERE directorId = 999;
-- Verificar que n o foi removido fisicamente e que hidde = 1
SELECT directorId, directorName, hidden FROM dbo.Directors WHERE directorId = 999;
-- Verificar registo na AuditLog
SELECT TOP 1 * FROM dbo.AuditLog WHERE ObjectType='Directors' AND ObjectId = 999 ORDER BY AuditId DESC;
