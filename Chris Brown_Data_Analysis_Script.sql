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
	album
FROM 
	public.chrisbrown_album_chartpositions;
WHERE album IS NULL OR album = '';
	