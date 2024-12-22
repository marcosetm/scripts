/*

Mass update user local ids

*/

-- create a temp table to update `users`
CREATE TEMP TABLE update_table (new_local_user_id VARCHAR(50), og_local_user_id VARCHAR(50));

INSERT INTO update_table(new_local_user_id, og_local_user_id)
VALUES
(/* 2,399 values */);

-- create a backup
CREATE TABLE data_cleanup_backups._og_user_ids_dt_2661 AS 
SELECT * FROM users u WHERE u.local_user_id IN (SELECT og_local_user_id FROM update_table);

-- update users
BEGIN;
UPDATE users u
SET local_user_id = ut.new_local_user_id
FROM update_table ut
WHERE 
	u.local_user_id = ut.og_local_user_id AND
	u.local_user_id <> ut.new_local_user_id;
ROLLBACK;