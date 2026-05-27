CREATE DATABASE chrisbrown_analysis;

CREATE TABLE chrisbrown_discography
(
    album VARCHAR (100),
    release_year INT,
    label VARCHAR (50),
    track_name VARCHAR (150),
    edition VARCHAR (50),
    genre VARCHAR (100)
);

SELECT
    *
FROM 
    chrisbrown_discography;

UPDATE chrisbrown_discography
SET genre = TRIM(genre);

DELETE FROM chrisbrown_discography
WHERE album = 'Slime & B';
    
SELECT DISTINCT 
    album
FROM
    chrisbrown_discography
ORDER BY 
    album;
    
CREATE TABLE chrisbrown_album_chartpositions
(
    album VARCHAR(100),
    label VARCHAR(50),
    release_date VARCHAR(20),
    us_peak VARCHAR(10),
    us_rnb_hh_peak VARCHAR(10),
    australia_peak VARCHAR(10),
    canada_peak VARCHAR(10),
    france_peak VARCHAR(10),
    germany_peak VARCHAR(10),
    ireland_peak VARCHAR(10),
    netherlands_peak VARCHAR(10),
    new_zealand_peak VARCHAR(10),
    switzerland_peak VARCHAR(10),
    uk_peak VARCHAR(10),
    us_sales_usd VARCHAR(20),
    certifications VARCHAR(255)
);

SELECT 
    *
FROM
    chrisbrown_album_chartpositions;

UPDATE chrisbrown_album_chartpositions
SET 
    germany_peak = NULLIF(germany_peak, '—'),
    switzerland_peak = NULLIF(switzerland_peak, '—')
WHERE 
    germany_peak = '—' OR switzerland_peak = '—';


SELECT
    *
FROM
    spotify_2023_final;

SELECT 
    *
FROM
    "datos_merged_1986_2023.csv"; 
 
 SELECT 
    *
FROM
   spotify_dataset;