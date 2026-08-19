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

-- Changing data type in public.chrisbrown_album_chartpositions from TEXT to BIGINT
ALTER TABLE public.chrisbrown_album_chartpositions 
ALTER COLUMN us_sales_usd TYPE INTEGER USING us_sales_usd::INTEGER;

SELECT 
	album,
	us_sales_usd,
	DENSE_RANK() OVER( ORDER BY "us_sales_usd" DESC) AS "album_rank"
FROM 
	public.chrisbrown_album_chartpositions;

	