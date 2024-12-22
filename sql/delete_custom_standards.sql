/*

REQUEST: Delete Standards
- Hiding standards instead. See if that helps the client
schema.table: standards.standards
matching on state_num provided by the client


*/

-- hide CUSTOM standards

BEGIN;
UPDATE standards.standards
SET hidden = TRUE
WHERE state_num ILIKE 'CustomPrefix.Hist%'

RETURNING *;
ROLLBACK;

-- delete CUSTOM standards

BEGIN;
DELETE FROM standards.subjects 
WHERE 
	document = 'Client Specific Collection of Standards' 
	AND year = '2024';
ROLLBACK;

-- SCRATCH PAD
/*
subject_id, code, count
290, Social Studies, 156
291, History, 31
289, Math, 29
293, Civics, 26
292, Geography, 23
*/
-- view standards and match client request
SELECT 
	parent_standard_id,
	STRING_AGG(description, ', ') AS description
FROM standards.standards
WHERE state_num IN ('CustomPrefix.SS.6', 'CustomPrefix.SS.7', 'CustomPrefix.SS.8', 'CustomPrefix.C', 'CustomPrefix.G', 'CustomPrefix.Hist')
GROUP BY parent_standard_ident_id;
