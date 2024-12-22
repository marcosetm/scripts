/*

Summer School enrollment still showing

Update summer school sites
has_students = FALSE

run mattyview refresh 

*/

SELECT * FROM sites WHERE site_name ILIKE '%SUMMER%'
	AND has_students IS TRUE;

SELECT 
	site_id
	, site_name
	, has_students
	-- DISTINCT(get_nearest_date(site_id, DATE(NOW()))) AS nearest_date
	, get_nearest_date(site_id, DATE(NOW())) AS nearest_date
    FROM sites
    WHERE has_students IS TRUE
    	AND site_name ILIKE '%SUMMER%'
  	ORDER BY site_id
    
LIMIT 200;

BEGIN;
-- UPDATE has_students
UPDATE sites
SET has_students = FALSE
WHERE
	site_name ILIKE '%SUMMER%'
	AND has_students IS TRUE;

-- CALL matviews.ss_current_refresh(current_date) function
SELECT matviews.ss_current_refresh(DATE(NOW()));

ROLLBACK;