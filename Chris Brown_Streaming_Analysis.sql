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

-- In this section, i am cleaning my data for my main table chrisbrown_discography 
-- to make it simple for me to finally combine data from all tables into one master table for my analysis
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
-- afterwards, I am creating tables based off filtered rows.
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

/*
In this section, i am checking if the songs in my chrisbrown_datosmerged (Kaggle) dataset 
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
Subsection: Cleaning the track_name column in chrisbrown_datosmerged (Kaggle dataset)
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

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

/*
SECTION: Cleaning the chrisbrown_song_spotify_streams_kworb table
Source: Kworb.net - snapshot of Chris Brown's Spotify song level streams as of May 20 2026
Purpose: Before joining this table with my other datasets, i need to:
1. Inspect the table structure and data
2. Fix encoding issues in the column name
3. Standardize song titles by removing featured artist information
   so that song names match consistently across all tables
*/

-- Subsection 1: Initial inspection of the table
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

-- Fixing encoding issue in column name - the original column name imported with
-- strange characters (ï»¿) due to UTF-8 BOM encoding in the CSV file
-- Renaming it to a clean usable name
ALTER TABLE chrisbrown_song_spotify_streams_kworb
RENAME COLUMN "ï»¿Song_title" TO song_title;

/*
Subsection 2: Cleaning song titles in the song_title column
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
FROM public.chrisbrown_song_spotify_streams_kworb;

-- Applying the cleaning permanently for titles with '(feat.'
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET song_title = CASE
                    WHEN "song_title" LIKE '% (feat. %'
                    THEN TRIM(SUBSTRING("song_title" FROM 1 FOR POSITION('(feat. ' IN "song_title") -1))
                    ELSE "song_title"
                 END;

/*
Subsection 3: Handling edge cases
Some song titles had featured artist info in different formats that were not
captured by the general update above. Handling them individually:
*/

-- 1. Cleaning 'Body On Me' which uses 'ft.' format instead of '(feat.'
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET song_title =
    TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('ft. ' IN song_title) - 1))
WHERE 
	song_title LIKE 'Body On Me %';

-- 2. Cleaning songs using '[feat.' format with square brackets
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET song_title =
    TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('[feat. ' IN song_title) - 1))
WHERE 
	song_title LIKE '% [feat. %';

-- 3. Cleaning 'All My Life' which uses 'feat.' without brackets
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET song_title =
    TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('feat. ' IN song_title) - 1))
WHERE 
	song_title LIKE 'All My Life %';

-- 4. Cleaning 'Superhero' which uses '[with Future' format
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET song_title =
    TRIM(SUBSTRING(song_title FROM 1 FOR POSITION('[with Future ' IN song_title) - 1))
WHERE 
	song_title LIKE 'Superhero %';

-- Final verification - viewing all data after cleaning to confirm changes look correct
SELECT
	*
FROM 
	public.chrisbrown_song_spotify_streams_kworb;

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

/*
SECTION: Cleaning the chrisbrown_spotifydataset table
Source: Kaggle - Spotify dataset containing audio features for Chris Brown songs
Purpose: Standardizing the track_name column by removing featured artist information
so that song names match consistently with my other tables when joining
*/

-- Initial inspection of the table to understand its structure and content
SELECT *
FROM public.chrisbrown_spotifydataset;

/*
Subsection: Cleaning the track_name column
Song titles in this dataset contain featured artist information in the format '(feat. Artist Name)'
i am first previewing the cleaned track names with a SELECT statement
before applying the changes permanently with an UPDATE
*/

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
SECTION: Cleaning the chrisbrown_youtube_song_views table
Source: Manual extraction from kworb.net
Purpose: Filtering out non-song video content (e.g., Interviews, BTS, Tours) 
         to ensure only official music tracks remain for analysis.
*/

-- Initial inspection of the table to understand its structure and content
SELECT
	*
FROM 
	public.chrisbrown_youtube_song_views;

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
SECTION: Cleaning the chrisbrown_youtube_song_views table
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

-- Standardizing song titles
-- Purpose: Convert all song titles to lowercase to simplify pattern matching 
-- and cleaning of repetitive metadata labels.

UPDATE public.chrisbrown_youtube_song_views
SET video = LOWER(video);

/*
SECTION: Cleaning the public.chrisbrown_youtube_song_views table
PURPOSE: I am standardizing song titles by removing extra metadata 
         (like 'official video', 'audio', etc.) and stripping away 
         any brackets or parentheses that contain these labels.
*/

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

-- 3. I am reviewing the song titles to ensure they look 
--    clean and consistent after my updates.
SELECT
	video 
FROM 
	public.chrisbrown_youtube_song_views 
ORDER BY 
	video;

-- Saving changes permanently
COMMIT;

/*
SECTION: Cleaning metadata labels
PURPOSE: I am removing the word "exclusive" from specific titles to 
         keep my dataset consistent.
*/

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

/*
SECTION: Surgical cleaning of empty or broken brackets
PURPOSE: I am removing only the leftover brackets '()' that remain in 
         my song titles after my previous cleaning steps.
*/

BEGIN;

-- I am removing empty parentheses or brackets that are left behind.
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

-- I am cleaning up any double spaces that might have been created by 
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

-- I am verifying that the titles look clean now.
SELECT 
	video 
FROM 
	public.chrisbrown_youtube_song_views 
WHERE 
	video LIKE '%(%' OR video LIKE '%)%' 
	OR video LIKE '%[%' OR video LIKE '%]%';

-- Permanently committing changes.
COMMIT;

SELECT 
	*
FROM
	public.chrisbrown_youtube_song_views;

/*
SECTION: Data Type Conversion
PURPOSE: I am permanently updating the 'Views' column. 
         First, I strip the commas, then I change the column type to integer.
*/

BEGIN;

-- 1. I am updating the column to remove all commas.
UPDATE public.chrisbrown_youtube_song_views
SET "Views" = REPLACE("Views", ',', '');

-- 2. I am altering the column structure to turn it into a numeric (integer) format.
ALTER TABLE public.chrisbrown_youtube_song_views
ALTER COLUMN "Views" TYPE integer USING "Views"::integer;

-- 3. I am checking the table structure to ensure the column is now an integer.
--    This will confirm that my change was successful.
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'chrisbrown_youtube_song_views' 
AND column_name = 'Views';

-- Finalizing the changes.
COMMIT;


/*
SECTION: Targeted Row Deletion
PURPOSE: I am removing specific, unwanted versions of songs based on 
         their view counts to ensure I am left with the "original" 
         or main version of the tracks.
*/

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

-- I am reviewing the data to confirm the duplicates are gone.
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

/* FINAL DATA CLEANUP - STEP-BY-STEP VERTICAL LOGIC */

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

-- 8. FINAL: Cleaning specific noise inside brackets
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

/* CLEANUP: REMOVE GUEST FEATURES AND DOCUMENTARY SNIPPETS */

/* 
   Using LIKE with % wildcards to ensure we catch every variation 
   of these songs, regardless of invisible characters or encoding issues.
*/

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

-- Run this to verify how many rows were actually removed
-- SELECT count(*) FROM public.chrisbrown_youtube_song_views;

-- Making changes permanent
COMMIT;

/* CLEANUP: REMOVE ARTIST PREFIXES
   This command looks for any text before a hyphen '-' 
   that contains 'chris brown' and removes it, leaving only the song title.
*/

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

-- COMMIT;

SELECT
	*
FROM
	public.chrisbrown_youtube_song_views
ORDER BY
	Video;

/* FINAL AGGREGATION: KEEP ONLY THE HIGHEST VIEW VERSION
   We partition the data by the clean title, order by views descending,
   and then delete everything except the #1 ranked row.
*/

BEGIN;

-- 1. Create a temporary table containing only the top-viewed versions
CREATE TABLE public.chrisbrown_songs_final AS
SELECT * FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY video 
               ORDER BY "Views" DESC
           ) as row_number
    FROM public.chrisbrown_youtube_song_views
) t
WHERE row_number = 1;

-- 2. Drop the old messy table
DROP TABLE public.chrisbrown_youtube_song_views;

-- 3. Rename the new clean table
ALTER TABLE public.chrisbrown_songs_final 
RENAME TO chrisbrown_youtube_song_views;

-- Permanently committing the changes
COMMIT;

/* VIEW PSYCHIC VERSIONS SIDE-BY-SIDE */
SELECT 
	video, 
	"Views"
FROM 
	public.chrisbrown_youtube_song_views
WHERE 
	video ILIKE '%ayo%';