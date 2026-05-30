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

-- Removing leading spaces on the genre column
UPDATE chrisbrown_discography
SET genre = TRIM(genre);

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

 SELECT
 	*
 FROM
 	chrisbrown_billboard_hot100_billboard;
 
UPDATE chrisbrown_discography cd 
SET track_name = LOWER(track_name);

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

-- In this section, i am cleaning my data to make it simple for me to finally 
-- combine data from all tables into one master table for my analysis
-- I am aimimng to make chrisbrown_discography table my master table
-- I have therefore started by cleaning it's track_name column,which cotains data on song names
-- I do not have a primary key for my data hence, i want to make sure all the song names read the same in all tables
-- that will make it easier forme when joining the data
-- the track-name column contains rows where the song name is accompanied by names of the featured artists
-- this will make it difficult for me in standardizing the song names
-- hence, i am creating a new column called features to carry the names of the featured artsits on each song that has a feature
-- then, cleaning the track_name column to only contain song names

SELECT 
	track_name,
	CASE 
		WHEN track_name LIKE '% ft. %'
		THEN TRIM(SUBSTRING(track_name FROM 1 FOR POSITION('ft. ' IN track_name) -1)) 
		ELSE track_name
	END AS clean_track_name,
	CASE
		WHEN track_name LIKE '% ft. %'
		THEN TRIM(SUBSTRING(track_name FROM POSITION('ft. ' IN track_name) +3))
		ELSE NULL 
		END AS features
FROM
	chrisbrown_discography cd;

ALTER TABLE chrisbrown_discography 
ADD COLUMN features TEXT;

UPDATE chrisbrown_discography cd 
SET 
	track_name = CASE
	             	WHEN track_name LIKE '% ft. %'
					THEN TRIM(SUBSTRING(track_name FROM 1 FOR POSITION('ft. ' IN track_name) -1))
					ELSE track_name
				 END,
	features = CASE
		       	  WHEN track_name LIKE '% ft. %'
		       	  THEN TRIM(SUBSTRING(track_name FROM POSITION('ft. ' IN track_name) +3))
		       	  ELSE NULL
		       END;
				
SELECT
	*
FROM 
	chrisbrown_discography cd
WHERE
	cd.track_name = 'go crazy'
	
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

-- In this section, I am working on getting rid of data i do not need for this analysis.
-- Since this analysis is purely focused on Chris Brown, 
-- I am querying the datasets with a whole range of artist, 
-- and filtering for rows where the artist name is Chris Brown
-- afterwards, I am creating table based off filtered rows.
-- Then, finally, i am deleting the original tables since i have extracted the data i need from them
	
SELECT
	*
FROM
	"datos_merged_1986_2023.csv"
WHERE
	artists_names LIKE '%Chris Brown%';

CREATE TABLE chrisbrown_datosmerged AS
SELECT
	*
FROM
	"datos_merged_1986_2023.csv"
WHERE
	artists_names LIKE '%Chris Brown%';

SELECT
	*
FROM 
	chrisbrown_datosmerged;

DROP TABLE "datos_merged_1986_2023.csv";

SELECT 
	*
FROM
	spotify_2023_final
WHERE 
	"artist(s)_name" LIKE '%Chris Brown%'

CREATE TABLE chrisbrown_spotify2023 AS 
SELECT 
	*
FROM
	spotify_2023_final
WHERE 
	"artist(s)_name" LIKE '%Chris Brown%'
	
SELECT
	 *
FROM 
	chrisbrown_spotify2023;

DROP TABLE spotify_2023_final;

SELECT 
	*
FROM
	spotify_dataset
WHERE
	artists LIKE '%Chris Brown%';

CREATE TABLE chrisbrown_spotifydataset AS
SELECT 
	*
FROM 
	spotify_dataset
WHERE
	artists LIKE '%Chris Brown%';

SELECT 	
	*
FROM
	chrisbrown_spotifydataset;

DROP TABLE spotify_dataset;


---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

