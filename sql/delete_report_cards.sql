
-- (1A) Research and make sure you have the correct report cards
-- Don't trust the request until you've verified
SELECT * FROM report_cards.report_cards WHERE print_group_id IN (
	SELECT print_group_id FROM report_cards.report_cards
	WHERE academic_year = 2025 AND name ILIKE 'zDELETE%'
);

SELECT * FROM report_cards.print_groups WHERE academic_year = YYYY;
SELECT * FROM report_cards.report_cards WHERE academic_year = YYYY;
SELECT * FROM report_cards.field_groups WHERE academic_year = YYYY;
SELECT * FROM report_cards.field_scale_groups WHERE academic_year = YYYY;
SELECT * FROM report_cards.field_map_groups WHERE academic_year = YYYY;
SELECT * FROM report_cards.report_card_overlays WHERE print_group_id IN (
	SELECT print_group_id FROM report_cards.print_groups WHERE academic_year = YYYY
);

-- (2) Create DROP TABLE and DROP SEQUENCE statements
SELECT
	'DROP TABLE report_card_data.rc_' || report_card_id || ';' as statements
FROM report_cards.report_cards 
WHERE name ILIKE 'zDELETE%' AND academic_year = YYYY
UNION
SELECT
	'DROP SEQUENCE report_card_data.rc_' || report_card_id || '_seq;'
FROM report_cards.report_cards 
WHERE name ILIKE 'zDELETE%' AND academic_year = YYYY
ORDER BY statements DESC;

-- (3) Delete transactions
BEGIN;
CREATE TEMP TABLE delete_ids AS 
(
	SELECT 
		report_card_id
		-- print_group_id 
	FROM report_cards.report_cards 
	WHERE name ILIKE 'zDELETE%' AND academic_year = YYYY
);

-- DELETE FROM report_cards.report_card_overlays WHERE print_group_id IN (SELECT print_group_id FROM delete_ids);
DELETE FROM report_cards.field_group_locks WHERE report_card_id IN (SELECT report_card_id FROM delete_ids);
DELETE FROM report_cards.report_card_field_groups WHERE report_card_id IN (SELECT report_card_id FROM delete_ids);
DELETE FROM report_cards.report_cards WHERE report_card_id IN (SELECT report_card_id FROM delete_ids);

/*
Add the DROP TABLE and DROP SEQUENCE statements here
*/

ROLLBACK;

/* RECOVERY SQL, if ever needed */

SELECT 
	rc.report_card_id,
	rc.name,
	rc.print_group_id,
	rco.*
FROM report_cards.report_cards rc
JOIN report_cards.report_card_overlays rco USING(print_group_id)
WHERE academic_year = 2025 AND print_group_id = 149
ORDER BY report_card_overlay_id;