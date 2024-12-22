/*

REQUEST: Delete all two letter ethnicity codes

*/

-- Find codes:
SELECT * FROM ethnicity 
WHERE LENGTH(value) = 2;

-- find references
SELECT *
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'some_client_specific_schema'
AND REFERENCED_TABLE_NAME like '%ethnicity%';

-- DELETE 
BEGIN;

UPDATE student
SET ethnicity = NULL
WHERE LENGTH(ethnicity) = 2;

DELETE FROM ethnicity
WHERE id IN (
	SELECT id FROM ethnicity 
	WHERE LENGTH(value) = 2
);

ROLLBACK;