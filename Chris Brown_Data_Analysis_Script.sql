-- How did the 2009 Rihanna incident visibly impact his streaming numbers and chart performance?

SELECT
	*
FROM 
	public.chrisbrown_album_chartpositions
WHERE 
	album = 'F.A.M.E.';

-- Permanently deleting an empty row in my data
DELETE FROM public.chrisbrown_album_chartpositions
WHERE 
	album IS NULL 
	OR album = '';

-- Changing data type in us_sales_usd from TEXT to BIGINT
ALTER TABLE public.chrisbrown_album_chartpositions 
ALTER COLUMN us_sales_usd TYPE INTEGER USING us_sales_usd::INTEGER;

-- -- Changing data type in release_date from TEXT to DATE
ALTER TABLE public.chrisbrown_album_chartpositions
ALTER COLUMN release_date TYPE DATE 
USING TO_DATE(release_date, 'DD/MM/YYYY');

-- Converting all peak chart position columns from TEXT to INTEGER data type
ALTER TABLE public.chrisbrown_album_chartpositions
ALTER COLUMN us_peak TYPE INTEGER USING NULLIF(TRIM(us_peak), '')::INTEGER,
ALTER COLUMN us_rnb_hh_peak TYPE INTEGER USING NULLIF(TRIM(us_rnb_hh_peak), '')::INTEGER,
ALTER COLUMN australia_peak TYPE INTEGER USING NULLIF(TRIM(australia_peak), '')::INTEGER,
ALTER COLUMN canada_peak TYPE INTEGER USING NULLIF(TRIM(canada_peak), '')::INTEGER,
ALTER COLUMN france_peak TYPE INTEGER USING NULLIF(TRIM(france_peak), '')::INTEGER,
ALTER COLUMN germany_peak TYPE INTEGER USING NULLIF(TRIM(germany_peak), '')::INTEGER,
ALTER COLUMN ireland_peak TYPE INTEGER USING NULLIF(TRIM(ireland_peak), '')::INTEGER,
ALTER COLUMN netherlands_peak TYPE INTEGER USING NULLIF(TRIM(netherlands_peak), '')::INTEGER,
ALTER COLUMN new_zealand_peak TYPE INTEGER USING NULLIF(TRIM(new_zealand_peak), '')::INTEGER,
ALTER COLUMN switzerland_peak TYPE INTEGER USING NULLIF(TRIM(switzerland_peak), '')::INTEGER,
ALTER COLUMN uk_peak TYPE INTEGER USING NULLIF(TRIM(uk_peak), '')::INTEGER;

-- Ranking Chris Brown's albums by US sales while displaying results chronologically by release date
SELECT 
	album,
	us_sales_usd,
	DENSE_RANK() OVER( ORDER BY "us_sales_usd" DESC) AS "album_rank",
	release_date
FROM 
	public.chrisbrown_album_chartpositions
ORDER BY 
	release_date ASC;

CREATE VIEW chrisbrown_album_sales_ranked AS 
SELECT 
	album,
	us_sales_usd,
	DENSE_RANK() OVER( ORDER BY "us_sales_usd" DESC) AS "album_rank",
	release_date
FROM 
	public.chrisbrown_album_chartpositions
ORDER BY 
	release_date ASC;

SELECT  
	*
FROM
	public.chrisbrown_discography;

SELECT 
	public.chrisbrown_discography.track_name,
	public.chrisbrown_song_spotify_streams_kworb.song_title,
	public.chrisbrown_youtube_song_views.video,
	public.chrisbrown_discography.album,
	public.chrisbrown_discography.release_year,
	public.chrisbrown_discography."label",
	public.chrisbrown_discography.edition,
	public.chrisbrown_discography.genre,
	public.chrisbrown_discography.features,
	public.chrisbrown_song_spotify_streams_kworb."Streams" AS Streams_SPTFY,
	public.chrisbrown_youtube_song_views."Views" AS Streams_YT
FROM 
	public.chrisbrown_discography
LEFT JOIN 
	public.chrisbrown_song_spotify_streams_kworb
ON 
	public.chrisbrown_discography.track_name = public.chrisbrown_song_spotify_streams_kworb.song_title
LEFT JOIN 
	public.chrisbrown_youtube_song_views 
ON 
	public.chrisbrown_youtube_song_views.video = public.chrisbrown_discography.track_name;

-- Adding a text-based unique ID column to chrisbrown_discography table
ALTER TABLE public.chrisbrown_discography
ADD COLUMN IF NOT EXISTS song_id VARCHAR(100);

-- Populating song _id column of chrisbrown_discography table with a clean combination of album and track name (stripped of spaces and symbols)
UPDATE public.chrisbrown_discography
SET song_id = LOWER(
    LEFT(REGEXP_REPLACE(album, '[^a-zA-Z0-9]', '', 'g'), 4) 
    || '_' || 
    LEFT(REGEXP_REPLACE(track_name, '[^a-zA-Z0-9]', '', 'g'), 15)
);

-- Creating song_id column in chrisbrown_youtube_song_views table
ALTER TABLE public.chrisbrown_youtube_song_views 
ADD COLUMN IF NOT EXISTS song_id VARCHAR(100);

-- Updating chrisbrown_youtube_song_views table with the new song_ids
UPDATE public.chrisbrown_youtube_song_views
SET 
	song_id = public.chrisbrown_discography.song_id
FROM 
	public.chrisbrown_discography
WHERE 
	LOWER(TRIM(public.chrisbrown_youtube_song_views.video)) = LOWER(TRIM(public.chrisbrown_discography.track_name));


-- Creating song_id column in chrisbrown_song_spotify_streams_kworb table
ALTER TABLE  public.chrisbrown_song_spotify_streams_kworb
ADD COLUMN IF NOT EXISTS song_id VARCHAR(100);

-- Updating table chrisbrown_song_spotify_streams_kworb with the new song_ids
UPDATE public.chrisbrown_song_spotify_streams_kworb
SET 
	song_id = public.chrisbrown_discography.song_id
FROM 
	public.chrisbrown_discography
WHERE 
	LOWER(TRIM(public.chrisbrown_discography.track_name)) = LOWER(TRIM(public.chrisbrown_song_spotify_streams_kworb.song_title))

-- Stanndardizing all album names in chrisbrown_discography table into lowercase and getting rid of spaces
UPDATE public.chrisbrown_discography
SET album = LOWER(TRIM(album));

-- Stanndardizing all album names in chrisbrown_album_chartpositions table into lowercase and getting rid of spaces
UPDATE public.chrisbrown_album_chartpositions
SET album = LOWER(TRIM(album));

-- Creating album_id column in chrisbrown_discography table
ALTER TABLE public.chrisbrown_discography 
ADD COLUMN IF NOT EXISTS album_id VARCHAR(100);

-- Generate a unique, readable album_id by combining a slugified album name,
-- release year, and a short label code (jive/rca/cbe) for quick identification
UPDATE public.chrisbrown_discography
SET album_id = LOWER(
    REGEXP_REPLACE(album, '[^a-zA-Z0-9]', '', 'g') 
    || '_' || 
    release_year 
    || '_' || 
    CASE 
        WHEN label ILIKE '%jive%' THEN 'jive'
        WHEN label ILIKE '%rca%' THEN 'rca'
        ELSE 'cbe'
    END
    
);

-- Creating a new column: album_id on chrisbrown_album_chartpositions table
ALTER TABLE public.chrisbrown_album_chartpositions
ADD COLUMN IF NOT EXISTS album_id VARCHAR(100);

-- Backfill album_id into chartpositions by matching on cleaned album names,
-- pulling the ID that was already generated in the discography table
UPDATE public.chrisbrown_album_chartpositions
SET 
	album_id = public.chrisbrown_discography.album_id
FROM 
	public.chrisbrown_discography
WHERE 
	LOWER(TRIM(public.chrisbrown_discography.album)) = LOWER(TRIM(public.chrisbrown_album_chartpositions.album))
	
-- Rank songs by  spotify stream count within each album using DENSE_RANK,
-- joined to discography to attach album names to each song's stream total
SELECT 
	public.chrisbrown_song_spotify_streams_kworb.song_title,
	public.chrisbrown_song_spotify_streams_kworb."Streams",
	public.chrisbrown_discography.album,
	DENSE_RANK () OVER(
		PARTITION BY public.chrisbrown_discography.album ORDER BY public.chrisbrown_song_spotify_streams_kworb."Streams" DESC)
		AS song_rank 
FROM 
	public.chrisbrown_song_spotify_streams_kworb
LEFT JOIN 
	public.chrisbrown_discography
ON 
	public.chrisbrown_discography.track_name = public.chrisbrown_song_spotify_streams_kworb.song_title;
	
-- Checking the data type for values in streams column for chrisbrown_song_spotify_streams_kworb table
SELECT data_type
FROM information_schema.columns
WHERE table_name = 'chrisbrown_song_spotify_streams_kworb'
AND column_name = 'Streams';

-- Changing data type of values chrisbrown_song_spotify_streams_kworb in table from TEXT to BIGINT 
ALTER TABLE public.chrisbrown_song_spotify_streams_kworb
ALTER COLUMN "Streams" TYPE BIGINT USING "Streams"::BIGINT;
	
SELECT 
	public.chrisbrown_youtube_song_views.video,
	public.chrisbrown_youtube_song_views."Views",
	public.chrisbrown_discography.album,
	DENSE_RANK () OVER(
		PARTITION BY public.chrisbrown_discography.album ORDER BY public.chrisbrown_youtube_song_views."Views" DESC)
		AS song_rank 
FROM 
	public.chrisbrown_youtube_song_views
LEFT JOIN 
	public.chrisbrown_discography
ON 
	public.chrisbrown_discography.track_name = public.chrisbrown_youtube_song_views.video;

SELECT 
	*
FROM 
	public.chrisbrown_discography
WHERE 
	track_name LIKE '%leave me alone%';
	
-- Remove trailing "(intro)" tag from track_name, case-insensitive
UPDATE public.chrisbrown_discography
SET track_name = TRIM(REGEXP_REPLACE(track_name, '\s*\(intro\)\s*$', '', 'i'))
WHERE
    track_name ILIKE '%(intro)%';
	
-- For each album, calculate stream count spread across its songs:
-- MAX/MIN show the range, STDDEV shows how tightly clustered streams are,
-- AVG gives the baseline to compare outliers against
SELECT
    public.chrisbrown_discography.album,
    COUNT(public.chrisbrown_song_spotify_streams_kworb.song_title) AS song_count,
    MAX(public.chrisbrown_song_spotify_streams_kworb."Streams") AS highest_streams,
    MIN(public.chrisbrown_song_spotify_streams_kworb."Streams") AS lowest_streams,
    ROUND(AVG(public.chrisbrown_song_spotify_streams_kworb."Streams")) AS avg_streams,
    ROUND(STDDEV(public.chrisbrown_song_spotify_streams_kworb."Streams")) AS stddev_streams
FROM
    public.chrisbrown_song_spotify_streams_kworb 
LEFT JOIN
    public.chrisbrown_discography 
ON
    public.chrisbrown_discography.track_name = public.chrisbrown_song_spotify_streams_kworb.song_title
GROUP BY
    public.chrisbrown_discography.album
ORDER BY
    stddev_streams DESC;

-- Row-level song streams with album attached, for box plot visualization.
-- Power BI's box plot visual will calculate quartiles, median, and
-- outliers itself from these individual values, so no aggregation needed here.
SELECT
    d.album,
    s.song_title,
    s."Streams"
FROM
    public.chrisbrown_song_spotify_streams_kworb s
LEFT JOIN
    public.chrisbrown_discography d
ON
    d.track_name = s.song_title
WHERE
    d.album IS NOT NULL
ORDER BY
    d.album, s."Streams" DESC;