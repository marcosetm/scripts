/*

UPDATE site_types with consortium

*/

BEGIN;
-- create values to insert
WITH cte AS (
	SELECT 
		MAX(site_type_id) + 1 as site_type_id,
		'CONSORTIUM' as site_type_name,
		MAX(site_sort_order) + 1 as site_sort_order
	FROM site_types
)
-- insert new site
INSERT INTO site_types 
SELECT * FROM cte
RETURNING *;

-- update all sort orders
UPDATE site_types as st
SET site_sort_order = site_sort_order + 1
RETURNING *;

-- set consortium as sort order one
UPDATE site_types as st
SET site_sort_order = 1
WHERE site_type_id = (SELECT site_type_id FROM site_types ORDER BY site_type_id DESC LIMIT 1)
RETURNING *;

select * from site_types order by site_sort_order;

ROLLBACK;
