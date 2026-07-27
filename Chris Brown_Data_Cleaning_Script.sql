/*
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

PROJECT: Chris Brown Career Evolution - Streaming & Chart Analysis

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

TABLES IN THIS DATABASE:
1. chrisbrown_album_chartpositions     - Peak chart positions per album across 11 countries
2. chrisbrown_album_spotify_streams_kworb  - Album level Spotify streams snapshot (May 2026)
3. chrisbrown_billboard_hot100_billboard   - Billboard Hot 100 chart history for all songs
4. chrisbrown_datosmerged              - Merged Kaggle dataset containing audio features
5. chrisbrown_discography              - Complete discography: 12 solo studio albums, all tracks
6. chrisbrown_song_spotify_streams_kworb   - Song level Spotify streams snapshot (May 2026)
7. chrisbrown_spotifydataset           - Kaggle Spotify dataset with audio features
8. chrisbrown_youtube_song_views       - YouTube views per song snapshot (May 2026)

MAIN TABLE: chrisbrown_discography
This table has been selected as the main/master table for this analysis.
It is the most complete record of Chris Brown's solo discography,
covering all 12 studio albums and their full tracklists.
All other tables will be cleaned and standardized to match the song naming
convention used in this table, after which they will be joined together
into one master table for the final analysis.

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
*/

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

-------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

-- SECTION: Cleaning chrisbrown_discography table

SELECT
    *
FROM 
    chrisbrown_discography;

-- Subsection 1  
-- Removing leading spaces on the genre column
UPDATE chrisbrown_discography
SET genre = TRIM(genre);

SELECT DISTINCT 
    album
FROM
    chrisbrown_discography
ORDER BY 
    album;

-- Subsection 2: Converting all track names into lowercase for uniformity
UPDATE chrisbrown_discography cd 
SET track_name = LOWER(track_name);

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

-- Subsection 3
-- Creating a new column called 'features' to store the featured artist names
ALTER TABLE chrisbrown_discography 
ADD COLUMN features TEXT;

-- Cleaning the track_name column to contain only the core song name
-- Adding the featured artists names into the new column 'features'
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

-- Confirming changes happened successfully			
SELECT
	*
FROM 
	chrisbrown_discography cd

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

/* 
SECTION: Cleaning 'datos_merged_1986_2023.csv' table
(later renamed to: chrisbrown_datosmerged)

This dataset originally contained audio features for a wide range of artists
spanning 1986 to 2023.
Since this analysis is focused exclusively on Chris Brown, the full dataset
was not needed.
The cleaning process involved:
1. Querying the original table and filtering for rows where the artist name
   contains 'Chris Brown', extracting only his songs and their audio features
2. Creating a new table called chrisbrown_datosmerged to store
   only the filtered Chris Brown data
3. Dropping the original unfiltered table since all the data needed
   had already been extracted into the new table
*/

-- Previewing Chris Brown rows in the original dataset before extraction
SELECT
    *
FROM
    "datos_merged_1986_2023.csv"
WHERE
    artists_names LIKE '%Chris Brown%';

-- Subsection 1
-- Creating a new table containing only Chris Brown rows extracted from the original dataset
CREATE TABLE chrisbrown_datosmerged AS
SELECT
    *
FROM
    "datos_merged_1986_2023.csv"
WHERE
    artists_names LIKE '%Chris Brown%';

-- Verifying the new table was created correctly and contains the expected data
SELECT
    *
FROM
    chrisbrown_datosmerged;

-- Subsection 2
-- Dropping the original unfiltered dataset since Chris Brown data has been extracted
DROP TABLE "datos_merged_1986_2023.csv";

-- Subsection 3
-- Converting all track names to lowercase for consistency with other tables
UPDATE public.chrisbrown_datosmerged
SET
    track_name = LOWER(track_name);

-- Subsection 4
-- Fixing truncated song title for 'Poppin' in chrisbrown_datosmerged
-- The title was cleaned with a trailing '- main' artifact from the original dataset
-- Restoring the correct song title
UPDATE public.chrisbrown_datosmerged
SET 
	track_name = 'poppin'''
WHERE 
	track_name LIKE '%poppin%main%';

-- Subsection 5
-- Deleting Superhero from chrisbrown_datosmerged
-- This is a Metro Boomin song featuring Future and Chris Brown
-- Chris Brown is not the principal artist on this track
-- hence it does not belong in this Chris Brown focused dataset
DELETE FROM public.chrisbrown_datosmerged
WHERE 
	track_name = 'superhero (heroes & villains) [with future & chris brown]';

/*
Subsection 6
Checking if the songs in my chrisbrown_datosmerged
exist in my main chrisbrown_discography table.
The purpose of this is to verify song name consistency across both tables
before i proceed to join them together into one master table for analysis.
I am using LIKE instead of IN because song names may not be spelled exactly 
the same way across the two datasets, so LIKE gives me more flexibility in matching.
The results are ordered alphabetically to make it easier to scan through them visually.
*/

SELECT
	*
FROM
	chrisbrown_discography cd 
WHERE 
	cd.track_name LIKE '%deuces%'
	OR cd.track_name LIKE '%forever%'
	OR cd.track_name LIKE '%gimme that%'
	OR cd.track_name LIKE '%go crazy%'
	OR cd.track_name LIKE '%kiss kiss%'
	OR cd.track_name LIKE '%look at me now%'
	OR cd.track_name LIKE '%loyal%'
	OR cd.track_name LIKE '%new flame%'
	OR cd.track_name LIKE '%next to you%'
	OR cd.track_name LIKE '%no guidance%'
	OR cd.track_name LIKE '%poppin%'
	OR cd.track_name LIKE '%run it!%'
	OR cd.track_name LIKE '%say goodbye%'
	OR cd.track_name LIKE '%take you down%'
	OR cd.track_name LIKE '%under the influence%'
	OR cd.track_name LIKE '%wet the bed%'
	OR cd.track_name LIKE '%with you%'
	OR cd.track_name LIKE '%yeah 3x%'
	OR cd.track_name LIKE '%yo (excuse me miss)%'
ORDER BY 
	track_name ASC;

/*
Subsection 7
Cleaning the track_name column in chrisbrown_datosmerged
Since i am using track_name as my joining key across tables, i need the song names 
to be consistent and clean across all datasets.
The chrisbrown_datosmerged table contains track names that include featured artist names
e.g. 'Under The Influence (feat. Davido)' instead of just 'Under The Influence'
I am therefore:
1. First running a SELECT to preview what the cleaned track names will look like before making changes
2. Then running an UPDATE to permanently clean the track_name column
   by removing everything from '(feat.' onwards, keeping only the core song name
This ensures that when i join chrisbrown_datosmerged with chrisbrown_discography,
the song names will match correctly.
*/

SELECT
	*
FROM
	public.chrisbrown_datosmerged;

SELECT
	track_name,
	CASE
		WHEN track_name LIKE '%(feat. %'
		THEN TRIM(SUBSTRING(track_name FROM 1 FOR POSITION('(feat. ' IN track_name) -1))
		ELSE track_name
	END AS clean_track_name
FROM
	public.chrisbrown_datosmerged;

UPDATE public.chrisbrown_datosmerged
SET 
	track_name = CASE
	             	WHEN track_name LIKE '%(feat. %'
	             	THEN TRIM(SUBSTRING(track_name FROM 1 FOR POSITION('(feat. ' IN track_name) -1))
	             	ELSE track_name
	             END;

-- Confirming changes happened successfully
SELECT 
	*
FROM 
	public.chrisbrown_datosmerged;

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
/*
SECTION: Cleaning 'spotify_2023_final' table
(later renamed to: chrisbrown_spotify2023)

This dataset originally contained audio features for a wide range of artists in 2023
Since this analysis is focused exclusively on Chris Brown, the full dataset
was not needed.
The cleaning process involved:
1. Querying the original table and filtering for rows where the artist name
   contains 'Chris Brown', extracting only his songs and their audio features
2. Creating a new table called chrisbrown_spotify2023 to store
   only the filtered Chris Brown data
3. Dropping the original unfiltered table since all the data needed
   had already been extracted into the new table
*/

--  Previewing Chris Brown rows in the original dataset before extraction
SELECT 
	*
FROM
	spotify_2023_final
WHERE 
	"artist(s)_name" LIKE '%Chris Brown%'

-- Subsection 1
-- Creating a new table containing only Chris Brown rows extracted from the original dataset
CREATE TABLE chrisbrown_spotify2023 AS 
SELECT 
	*
FROM
	spotify_2023_final
WHERE 
	"artist(s)_name" LIKE '%Chris Brown%'

-- Verifying the new table was created correctly and contains the expected data
SELECT
	 *
FROM 
	chrisbrown_spotify2023;

-- Subsection 2
-- Dropping the original unfiltered dataset since Chris Brown data has been extracted
DROP TABLE spotify_2023_final;

-- Deleting songs where Chris Brown is not the principal artist
DELETE FROM public.chrisbrown_spotify2023
WHERE 
	"artist(s)_name" = 'Future, Chris Brown, Metro Boomin'
	OR "artist(s)_name" = 'Chris Brown, Rvssian, Rauw Alejandro';

-- Subsection 3
-- Converting all track names to lowercase for consistency with other tables
UPDATE public.chrisbrown_spotify2023
SET
    track_name = LOWER(track_name);

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

-- SECTION: Cleaning spotify_dataset 
-- (later renamed to: 'chrisbrown_spotify dataset')

-- Previewing Chris Brown rows in the original dataset before extraction
SELECT 
	*
FROM
	spotify_dataset
WHERE
	artists LIKE '%Chris Brown%';

-- Subsection 1
-- Creating a new table containing only Chris Brown rows extracted from the original dataset
CREATE TABLE chrisbrown_spotifydataset AS
SELECT 
	*
FROM 
	spotify_dataset
WHERE
	artists LIKE '%Chris Brown%';

-- Verifying the new table was created correctly and contains the expected data
SELECT 	
	*
FROM
	chrisbrown_spotifydataset;

-- Subsection 2
-- Dropping the original unfiltered dataset since Chris Brown data has been extracted
DROP TABLE spotify_dataset;

-- Subsection 3
-- Previewing rows where Chris Brown is not the principal artist
-- In this dataset, artists are separated by semicolons with the lead artist listed first
-- Rows where artists does not start with 'Chris Brown;' or equal 'Chris Brown' alone
-- indicate songs where Chris Brown is a featured artist rather than the lead
-- These rows will be deleted in the subsequent DELETE command

SELECT 
	artists, 
	track_name
FROM 
	public.chrisbrown_spotifydataset
WHERE 
	artists NOT LIKE 'Chris Brown;%'
	AND artists != 'Chris Brown'
ORDER BY 
	artists;

-- Delete rows where Chris Brown is not the principal artist
DELETE FROM public.chrisbrown_spotifydataset
WHERE 
	artists NOT LIKE 'Chris Brown;%'
	AND artists != 'Chris Brown';

-- Subsection 4
-- Removing duplicate 'Under The Influence' entries, keeping only one instance
DELETE FROM public.chrisbrown_spotifydataset
WHERE 
	ctid NOT IN (
    	SELECT DISTINCT ON 
    		(track_name) ctid
    	FROM 
        	public.chrisbrown_spotifydataset
    	ORDER BY 
    		track_name
);

-- Subsection 5
-- Converting all track names to lowercase for consistency with other tables
UPDATE public.chrisbrown_spotifydataset
SET 
	track_name = LOWER(track_name);

-- Subsection 6
-- Deleting 'Under The Influence (Body Language)' - alternate version, not the original song
DELETE FROM public.chrisbrown_spotifydataset
WHERE 
	track_name LIKE '%body language%';

-- Confirming changes happened successfully
SELECT
	*
FROM 
	public.chrisbrown_spotifydataset;

/*
Subsection 7
Standardizing the track_name column by removing featured artist information
so that song names match consistently with my other tables when joining
*/

-- Initial inspection of the table to understand its structure and content
SELECT 
	*
FROM 
	public.chrisbrown_spotifydataset;

-- Song titles in this dataset contain featured artist information in the format '(feat. Artist Name)'
-- Preview of cleaned track names before making permanent changes
SELECT
    "track_name",
    CASE
        WHEN "track_name" LIKE '% (feat. %'
        THEN TRIM(SUBSTRING("track_name" FROM 1 FOR POSITION('(feat. ' IN "track_name") -1))
        ELSE "track_name"
    END AS clean_track_name
FROM public.chrisbrown_spotifydataset;

-- Applying the cleaning permanently
-- Removes everything from '(feat.' onwards, keeping only the core song name
UPDATE public.chrisbrown_spotifydataset
SET track_name =
    TRIM(SUBSTRING("track_name" FROM 1 FOR POSITION('(feat. ' IN "track_name") -1))
WHERE
    track_name LIKE '% (feat. %';

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

/*
SECTION: Cleaning the chrisbrown_song_spotify_streams_kworb table

Purpose: Before joining this table with my other datasets, i need to:
1. Inspect the table structure and data
2. Fix encoding issues in the column name
3. Standardize song titles by removing featured artist information
   so that song names match consistently across all tables
*/

-- Initial inspection of the table
-- Viewing all data to understand the structure and content of the table
SELECT
	*
FROM 
	public.chrisbrown_song_spotify_streams_kworb;

-- Checking exact column names to identify any encoding or naming issues
SELECT 
	column_name
FROM 
	information_schema.columns
WHERE 
	table_name = 'chrisbrown_song_spotify_streams_kworb';

-- Subsection 1
-- Fixing encoding issue in column name - the original column name imported with
-- strange characters (ï»¿) due to UTF-8 BOM encoding in the CSV file
-- Renaming it to a clean usable name
ALTER TABLE chrisbrown_song_spotify_streams_kworb
RENAME COLUMN "ï»¿Song_title" TO song_title;

/*
Subsection 2 
Cleaning song titles in the song_title column
The song titles contain featured artist information in various formats:
- (feat. Artist Name)
- [feat. Artist Name]
- ft. Artist Name
- [with Artist Name]
i am first previewing the changes with a SELECT before applying them permanently with UPDATE
*/

-- Preview of cleaned song titles before making permanent changes
SELECT
    "song_title",
    CASE
        WHEN "song_title" LIKE '%(feat. %'
        THEN TRIM(SUBSTRING("song_title" FROM 1 FOR POSITION('(feat. ' IN "song_title") -1))
        ELSE "song_title"
    END AS clean_song_title
FROM 
	public.chrisbrown_song_spotify_streams_kworb;

-- Applying the cleaning permanently for titles with '(feat.'
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title = CASE
                    WHEN "song_title" LIKE '% (feat. %'
                    THEN TRIM(SUBSTRING("song_title" FROM 1 FOR POSITION('(feat. ' IN "song_title") -1))
                    ELSE "song_title"
                 END;

/*
Subsection 3
Handling edge cases
Some song titles had featured artist info in different formats that were not
captured by the general update above. Handling them individually:
*/

-- 1. Cleaning 'Body On Me' which uses 'ft.' format instead of '(feat.'
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title =
    	TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('ft. ' IN song_title) - 1))
WHERE 
	song_title LIKE 'Body On Me %';

-- 2. Cleaning songs using '[feat.' format with square brackets
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title =
    	TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('[feat. ' IN song_title) - 1))
WHERE 
	song_title LIKE '% [feat. %';

-- 3. Cleaning 'All My Life' which uses 'feat.' without brackets
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title =
    	TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('feat. ' IN song_title) - 1))
WHERE 
	song_title LIKE 'All My Life %';

-- 4. Cleaning 'Superhero' which uses '[with Future' format
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title =
    	TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('[with Future ' IN song_title) - 1))
WHERE 
	song_title LIKE 'Superhero %';

-- 5. Fixing song title 'g walk (with chris brown)' by removing the featured artist credit
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title = 'g walk'
WHERE 
	song_title = 'g walk (with chris brown)';

-- 6. Fixing song title 'little more (royalty)' by removing the album reference in brackets
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title = 'little more'
WHERE 
	song_title = 'little more (royalty)';

-- Fixing song title 'poppin' - main' by removing the trailing artifact
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title = 'poppin'''
WHERE 
	song_title = 'poppin'' - main';

-- Final verification - viewing all data after cleaning to confirm changes look correct
SELECT
	*
FROM 
	public.chrisbrown_song_spotify_streams_kworb;

-- Subsection 4
-- Converting all song titles to lowercase for consistency with other tables
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_title = LOWER(song_title);

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

-- SECTION: Cleaning the chrisbrown_youtube_song_views table


-- Initial inspection of the table to understand its structure and content
SELECT
	*
FROM 
	public.chrisbrown_youtube_song_views;

-- Selecting rows with non-music content
SELECT Video
FROM public.chrisbrown_youtube_song_views
WHERE video LIKE '%Behind The Scenes%'
   OR video LIKE '%Behind the Scenes%'
   OR video LIKE '%BTS%'
   OR video LIKE '%Tour%'
   OR video LIKE '%Live%'
   OR video LIKE '%Sped Up%'
   OR video LIKE '%Speed Up%'
   OR (video LIKE '%Remix%' AND video NOT LIKE '%Gimme That%')
   OR video LIKE '%REMIX%'
   OR video LIKE '%Dave Aud%'
   OR video LIKE '%Legends Remix%'
   OR video LIKE '%Making of%'
   OR video LIKE '%Vevo Footnotes%'
   OR video LIKE '%VevoCertified%'
   OR video LIKE '%#VevoCertified%'
   OR video LIKE '%Fan Q&A%'
   OR video LIKE '%Album Commentary%'
   OR video LIKE '%Interview%'
   OR video LIKE '%Commentary%'
   OR video LIKE '%Fuse Interview%'
   OR video LIKE '%GRAMMY%'
   OR video LIKE '%GRAMMYs%'
   OR video LIKE '%Fine China Dance%'
   OR video LIKE '%One Take Dance%'
   OR video LIKE '%Exclusive%'
   OR video LIKE '%In Store Footage%'
   OR video LIKE '%Journey To South Africa%'
   OR video LIKE '%VEVO News%'
   OR video LIKE '%Vevo News%'
   OR video LIKE '%Go Girlfriend BTS%'
   OR video = 'Weakest Link'
   OR video LIKE '%Wheels Fall Off | From The Block%'
   OR video LIKE '%Justin Bieber and Chris Brown - Sydney%'
   OR video LIKE '%Chris Brown On Tour%'
   OR video LIKE '%Chris Brown Fan Q&A%'
   OR video LIKE '%Chris Brown Album Commentary%'
ORDER BY video;

/*
Subsection 1
Cleaning the chrisbrown_youtube_song_views table
Purpose: Permanently removing non-song video entries (Interviews, BTS, Tours, etc.)
         to maintain a clean dataset for musical analysis.
*/

-- 1. Start a transaction (so I can rollback if I make a mistake)
BEGIN;

-- 2. Deleting the filtered rows
DELETE FROM public.chrisbrown_youtube_song_views
WHERE video LIKE '%Behind The Scenes%'
   OR video LIKE '%Behind the Scenes%'
   OR video LIKE '%BTS%'
   OR video LIKE '%Tour%'
   OR video LIKE '%Live%'
   OR video LIKE '%Sped Up%'
   OR video LIKE '%Speed Up%'
   OR (video LIKE '%Remix%' AND video NOT LIKE '%Gimme That%')
   OR video LIKE '%REMIX%'
   OR video LIKE '%Dave Aud%'
   OR video LIKE '%Legends Remix%'
   OR video LIKE '%Making of%'
   OR video LIKE '%Vevo Footnotes%'
   OR video LIKE '%VevoCertified%'
   OR video LIKE '%#VevoCertified%'
   OR video LIKE '%Fan Q&A%'
   OR video LIKE '%Album Commentary%'
   OR video LIKE '%Interview%'
   OR video LIKE '%Commentary%'
   OR video LIKE '%Fuse Interview%'
   OR video LIKE '%GRAMMY%'
   OR video LIKE '%GRAMMYs%'
   OR video LIKE '%Fine China Dance%'
   OR video LIKE '%One Take Dance%'
   OR video LIKE '%Exclusive%'
   OR video LIKE '%In Store Footage%'
   OR video LIKE '%Journey To South Africa%'
   OR video LIKE '%VEVO News%'
   OR video LIKE '%Vevo News%'
   OR video LIKE '%Go Girlfriend BTS%'
   OR video = 'Weakest Link'
   OR video LIKE '%Wheels Fall Off | From The Block%'
   OR video LIKE '%Justin Bieber and Chris Brown - Sydney%'
   OR video LIKE '%Chris Brown On Tour%'
   OR video LIKE '%Chris Brown Fan Q&A%'
   OR video LIKE '%Chris Brown Album Commentary%';

-- Finalizing changes: Permanently removing non-song video entries from the table
COMMIT;

-- Subsection 2
-- Convert all song titles to lowercase to simplify pattern matching 
-- and cleaning of repetitive metadata labels.
UPDATE public.chrisbrown_youtube_song_views
SET video = LOWER(video);

-- Subsection 3
-- I am standardizing song titles by removing extra metadata (like 'official video', 'audio', etc.) 
-- and stripping away any brackets or parentheses that contain these labels.

-- 1. I am starting a transaction here so I can test my cleanup logic 
--    before I make any permanent changes to the database.
BEGIN;

-- 2. I am running this update to remove specific metadata labels. 
--    I have arranged the terms vertically so I can easily update 
--    the list if I need to filter out more noise in the future.
UPDATE public.chrisbrown_youtube_song_views
SET video = TRIM(
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            video, 
            -- I am looking for these patterns in the titles:
            '(\(|\)|\[|\])?\s*' || 
            '(official\s*video|' ||
            'official\s*music\s*video|' ||
            'official\s*hd\s*video|' ||
            'official\s*lyric\s*video|' ||
            'official\s*audio|' ||
            'official\s*visualizer|' ||
            'official|' ||
            'audio|' ||
            'visualizer|' ||
            'lyric\s*video|' ||
            'explicit\s*version|' ||
            'clean\s*version|' ||
            'edited\s*version|' ||
            'exclusive|' ||
            'online\s*version)' || 
            '\s*(\(|\)|\[|\])?', 
            '', 
            'gi'
        ),
        -- I am cleaning up any extra spaces left behind by the removal process.
        '\s+', ' ', 'g'
    )
);

-- 3. Reviewing the song titles to ensure they look 
--    clean and consistent after my updates.
SELECT
	video 
FROM 
	public.chrisbrown_youtube_song_views 
ORDER BY 
	video;

-- Saving changes permanently
COMMIT;


-- Subsection 4
-- Cleaning metadata labels
-- Removing the word "exclusive" from specific titles to keep my dataset consistent.

UPDATE public.chrisbrown_youtube_song_views
SET video = TRIM(REGEXP_REPLACE(video, 'explicit', '', 'gi'))
WHERE 
	video LIKE '%autumn leaves%' 
  	OR video LIKE '%love more%';

SELECT
	video 
FROM 
	public.chrisbrown_youtube_song_views 
WHERE 
	video LIKE '%autumn leaves%' 
  	OR video LIKE '%love more%';


-- Subsection 5
--Surgical cleaning of empty or broken brackets
-- Removing only the leftover brackets '()' that remain in my song titles 
-- after my previous cleaning steps.
BEGIN;

-- 1. Removing empty parentheses or brackets that are left behind.
-- The pattern looks for '(' followed by ')' with any number of spaces in between.
UPDATE public.chrisbrown_youtube_song_views
SET video = TRIM(
    REGEXP_REPLACE(
        video, 
        '\(\s*\)|\[\s*\]', 
        '', 
        'g'
    )
);

-- 2. Cleaning up any double spaces that might have been created by 
-- removing those brackets.
UPDATE public.chrisbrown_youtube_song_views
SET video = TRIM(
    REGEXP_REPLACE(
        video, 
        '\s+', 
        ' ', 
        'g'
    )
);

-- 3. Verifying that the titles look clean now.
SELECT 
	video 
FROM 
	public.chrisbrown_youtube_song_views 
WHERE 
	video LIKE '%(%' OR video LIKE '%)%' 
	OR video LIKE '%[%' OR video LIKE '%]%';

-- 4. Permanently committing changes.
COMMIT;

SELECT 
	*
FROM
	public.chrisbrown_youtube_song_views;

-- Subsection 6
-- Data Type Conversion
-- Permanently updating the 'Views' column. 
-- First, stripping out the commas, then changing the column type to integer.

BEGIN;

-- 1. Updating the column to remove all commas.
UPDATE public.chrisbrown_youtube_song_views
SET "Views" = REPLACE("Views", ',', '');

-- 2. Altering the column structure to turn it into a numeric (integer) format.
ALTER TABLE public.chrisbrown_youtube_song_views
ALTER COLUMN "Views" TYPE integer USING "Views"::integer;

-- 3. Checking the table structure to ensure the column is now an integer.
--    This will confirm that my change was successful.
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'chrisbrown_youtube_song_views' 
AND column_name = 'Views';

-- Finalizing the changes.
COMMIT;

-- Subsection 7
-- Targeted Row Deletion
-- Removing specific, unwanted versions of songs based on their view counts to ensure 
-- I am left with the "original" or main version of the tracks.

BEGIN;

-- Removing specific "New Flame" versions
DELETE FROM public.chrisbrown_youtube_song_views
WHERE 
	(video LIKE '%new flame%' AND "Views" = 18589385)
	OR (video LIKE '%new flame%' AND video LIKE '% - clean)%')
	OR (video LIKE '%new flame%' AND video LIKE '%(lyric)%');

-- Removing specific "Loyal" versions
DELETE FROM public.chrisbrown_youtube_song_views
WHERE 
	(video LIKE '%loyal%' AND "Views" = 6938309)
	OR (video LIKE '%loyal%' AND video LIKE '%(east coast version)%')
	OR (video LIKE '%loyal%' AND video LIKE '%(west coast version)%');

-- Reviewing the data to confirm the duplicates are gone.
SELECT 
	video, 
	"Views" 
FROM 
	public.chrisbrown_youtube_song_views 
WHERE 
	video LIKE '%new flame%' OR video LIKE '%loyal%';

-- Making the changes permanent
COMMIT;

DELETE FROM public.chrisbrown_youtube_song_views
WHERE
	video = 'love more - clean) ft. nicki minaj';

-- Subsection 8
-- Data clean up - step-by-step vertical logic */

BEGIN;

-- 1. Standardize features to 'ft.'
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(' || 
    'feat\.?|'      || 
    'fe at|'        || 
    'f\.e\.a\.t|'   || 
    'feat'          ||                                      
    ')', 
    ' ft. ', 
    'gi'
);

-- 2. Remove 'official' labels
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(\s*[\(\[]?\s*)' || 
    '(official|official\s*video)' || 
    '(\s*[\)\]]?)', 
    '', 
    'gi'
);

-- 3. Remove 'exclusive' labels
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(\s*[\(\[]?\s*)' || 
    '(exclusive)' || 
    '(\s*[\)\]]?)', 
    '', 
    'gi'
);

-- 4. Remove 'explicit' labels
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(\s*[\(\[]?\s*)' || 
    '(explicit)' || 
    '(\s*[\)\]]?)', 
    '', 
    'gi'
);

-- 5. Remove 'clean' labels
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(\s*[\(\[]?\s*)' || 
    '(clean)' || 
    '(\s*[\)\]]?)', 
    '', 
    'gi'
);

-- 6. Remove 'lyric' labels
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(\s*[\(\[]?\s*)' || 
    '(lyric)' || 
    '(\s*[\)\]]?)', 
    '', 
    'gi'
);

-- 7. Remove 'audio' labels
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(\s*[\(\[]?\s*)' || 
    '(audio)' || 
    '(\s*[\)\]]?)', 
    '', 
    'gi'
);

-- 8. Cleaning specific noise inside brackets
UPDATE public.chrisbrown_youtube_song_views
SET video = REGEXP_REPLACE(
    video, 
    '(\s*[\(\[]\s*)' || 
    '(clean|lyric|explicit|official|exclusive|audio|video)' || 
    '(\s*[\)\]])', 
    '', 
    'gi'
);

-- Review the result
SELECT 
	video 
FROM 
	public.chrisbrown_youtube_song_views 
ORDER BY 
	video;

-- Making changes permanent
COMMIT;

-- Subsection 9
-- Cleanup: Removing guest features and documentary snippets
-- Using LIKE with % wildcards to ensure we catch every variation 
-- of these songs, regardless of invisible characters or encoding issues.

BEGIN;

DELETE FROM public.chrisbrown_youtube_song_views
WHERE video LIKE '%brandy - put it down%'
   OR video LIKE '%future - pie%'
   OR video LIKE '%g-eazy - drifting%'
   OR video LIKE '%game - pot of gold%'
   OR video LIKE '%jeremih - i think of you%'
   OR video LIKE '%kid ink - show me%'
   OR video LIKE '%omarion - post to be%'
   OR video LIKE '%pitbull - fun%'
   OR video LIKE '%pitbull - international love%'
   OR video LIKE '%rick ross - sorry%'
   OR video LIKE '%nost%' -- Catches the problematic character song
   OR video LIKE '%same st%'
   OR video LIKE '%let st go%'
   OR video LIKE '%don''t kill the fun%'
   OR video LIKE '%t.i. - get back up%'
   OR video LIKE '%welcome to my life%';

-- Running this to verify how many rows were actually removed
SELECT 
	count(*) 
FROM 
	public.chrisbrown_youtube_song_views;

-- Making changes permanent
COMMIT;

-- Subsection 10
-- Cleanup: Removing artist prefixes
-- This command looks for any text before a hyphen '-' 
-- that contains 'chris brown' and removes it, leaving only the song title.

-- Running SELECT command first to create virtual column to confirm outcome 
-- before actual deletion
SELECT
	video,
	TRIM(
    REGEXP_REPLACE(
        video, 
        '^.*chris\s+brown.*?\s*-\s*', -- Matches everything up to the hyphen
        '', 
        'gi') 
        ) AS new_video
FROM
	public.chrisbrown_youtube_song_views;

-- Actual deletion
BEGIN;

UPDATE public.chrisbrown_youtube_song_views
SET video = TRIM(
    REGEXP_REPLACE(
        video, 
        '^.*chris\s+brown.*?\s*-\s*', -- Matches everything up to the hyphen
        '', 
        'gi'
    )
)
-- We only apply this to rows that actually contain that pattern
WHERE video ~* '^.*chris\s+brown.*?\s*-';

-- Making the changes permanent
COMMIT;

SELECT
	*
FROM
	public.chrisbrown_youtube_song_views
	
-- Subsection 11
-- Deleting songs where Chris Brown is not the principal artist
DELETE FROM public.chrisbrown_youtube_song_views
WHERE
	video = 'young thug - help me breathe ft. future'
	OR video = 'nicki minaj - only ft. drake, lil wayne, chris brown'
	OR video = 'fat joe - another round ft. chris brown'
	OR video = 'tyga - for the road ft. chris brown';

/*
Subsection 12
Cleaning featured artist information from video titles in chrisbrown_youtube_song_views
Some video titles still contain featured artist credits in the format ' ft. [Artist Name]'
after the initial cleaning steps.
This update removes everything from ' ft.' onwards, keeping only the core song title.
*/
UPDATE public.chrisbrown_youtube_song_views
SET 
	video = TRIM(SUBSTRING(video FROM 1 FOR POSITION(' ft.' IN video) - 1))
WHERE 
	video LIKE '% ft.%';

-- Confirming changes happened successfully
-- Result: All songs names with featured artists ' ft. [Artist Name]' have been deleted
-- Only one song name (ft. schoolboy q) remaining that needs to be deleted
SELECT
	*
FROM
	public.chrisbrown_youtube_song_views
WHERE 
	video LIKE '%ft.%';

-- Subsection 13
-- Deleting column with song name: 'ft. schoolboy q'
DELETE FROM public.chrisbrown_youtube_song_views
WHERE 
	video = 'ft. schoolboy q';

/*
Subsection 14
Fixing truncated song title for 'No Bullshit' in chrisbrown_youtube_song_views.
During a previous cleaning step, the word 'bullshit' was accidentally removed,
leaving the title as 'no bull' instead of the correct full title 'no bullshit'.
This update restores the correct song title.
*/

UPDATE public.chrisbrown_youtube_song_views
SET video = 'no bullshit'
WHERE video LIKE '%no bull%';

/*
Subsection 15
Deduplication of chrisbrown_youtube_song_views.
After cleaning the video titles, some songs now share the same title
but have multiple rows with different view counts, representing different
video versions (e.g. official video, audio, lyric video) that after
title cleaning now look identical.
We only want to keep one row per song - the version with the highest
view count as it best represents the song's overall YouTube performance.
To do this safely, we first run a SELECT using ROW_NUMBER() to preview
which rows will be kept (row_number = 1) and which are duplicates
(row_number > 1) before making any permanent changes.
Once confirmed, the DELETE removes all duplicate rows keeping only
the highest viewed version of each song.
*/

SELECT 
	"Views",
	video,
    ROW_NUMBER() OVER (
        PARTITION BY video
        ORDER BY "Views" DESC
    ) as row_number
FROM 
	public.chrisbrown_youtube_song_views
ORDER BY 
	video, row_number;

DELETE FROM public.chrisbrown_youtube_song_views
WHERE ctid NOT IN (
    SELECT DISTINCT ON 
    	(video) ctid
    FROM 
    	public.chrisbrown_youtube_song_views
    ORDER BY video, "Views" DESC
);

/*
Subsection 16
Manual cleanup of duplicate 'Liquor' entries.
After title cleaning, three versions of Liquor appeared in the table:
'liquor' - the main song
'liquor -' - a cleaning artifact with a trailing hyphen, lowest views
'liquor / zero' - a separate combined song video with Zero
The 'liquor -' entry was identified as a cleaning artifact with the least
views and was deleted. The SELECT was run first to confirm the view counts
before deletion.
*/

SELECT 
	video,
	"Views"
FROM
	public.chrisbrown_youtube_song_views
WHERE 
	video LIKE '%liquor%'
	
DELETE FROM public.chrisbrown_youtube_song_views
WHERE 
	video = 'liquor -';

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


