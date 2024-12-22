/*

1. add to home_language

MariaDB [some_client_db]> select * from home_language;
+----+------+-------------+-----------------------+------------------+------------+
| id | code | description | home_language_display | language_code_id | created_by |
+----+------+-------------+-----------------------+------------------+------------+
|  1 | 390  | Dutch       | Dutch                 |               17 |         73 |
|  2 | 450  | Finnish     | Finnish               |               22 |         73 |
+----+------+-------------+-----------------------+------------------+------------+

2. add to home_language_alias with 

MariaDB [some_client_db]> select * from home_language_alias;
+----+------------------+------+-----------+---------------------+---------------------+---------------------+
| id | home_language_id | code | upload_id | created             | created_at          | updated_at          |
+----+------------------+------+-----------+---------------------+---------------------+---------------------+
|  1 |                1 | 390  |      NULL | 2024-09-04 17:10:49 | 2024-09-04 17:10:49 | 2024-09-04 17:16:51 |
|  2 |                2 | 450  |      NULL | 2024-09-04 17:10:49 | 2024-09-04 17:10:49 | 2024-09-04 17:10:49 |
+----+------------------+------+-----------+---------------------+---------------------+---------------------+

3. re-run validation
*/


-- select * from `user` where lname like 'something';
BEGIN;
INSERT INTO home_language (code, description, home_language_display, language_code_id, created_by)
VALUES 
	('07', 'Chinese - Mandarin', 'Chinese - Mandarin',12, 73),
	('011', 'English', 'English',18, 73),
	('040', 'Russian', 'Russian',57, 73),
	('045', 'Spanish', 'Spanish',63, 73),
	('0126', 'Filipino - Tagalog', 'Filipino - Tagalog',21, 73);
ROLLBACK;

/*

UPDATE language description and display

*/

-- explore query
SELECT 
	hl.code,
	hl.description,
	hl.home_language_display,
	lc.language_name
FROM home_language hl
JOIN language_code lc ON hl.language_code_id = lc.id

-- update description and display with mathing language name

BEGIN;
UPDATE home_language hl
JOIN language_code lc ON hl.language_code_id = lc.id
SET 
	hl.description = lc.language_name,
	hl.home_language_display = lc.language_name
WHERE hl.language_code_id = lc.id;
ROLLBACK;

-- update display with it's own description
BEGIN;
UPDATE home_language hl
JOIN home_language hl2 ON hl.id = hl2.id
SET hl.home_language_display = hl2.description
WHERE hl.home_language_display IS NULL AND hl.id = hl2.id;
ROLLBACK;

-- update from laguage_code table
BEGIN; 
UPDATE home_language hl,  
	(SELECT id, language_name FROM language_code WHERE language_name in (select description from home_language)) as foo 
SET language_code_id = foo.id 
WHERE hl.description = foo.language_name; 
ROLLBACK;

-- add to alias
INSERT INTO home_language_alias(home_language_id, code)
SELECT id, code
FROM home_language;