/*

add role system key for ISE

*/

BEGIN;

UPDATE roles
SET	system_key = LOWER(REPLACE(role_name, ' ', '_'))
WHERE role_name IN ('Some Role Name', 'Another Role Name')
RETURNING *;

ROLLBACK;