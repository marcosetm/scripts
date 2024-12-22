/*
to delete all student emails
	first disable all portals
	remove all portal accounts from portal_db.users
	remove all student emails from public.students 

tasks
	get portal_student_id 
*/
-- get portal_student_id = accessor_id in api.access_keys
SELECT portal_student_id FROM portal.portal_students WHERE student_id = (SELECT student_id FROM students WHERE local_student_id = '');

-- delete from portal_db.users
 DELETE FROM users WHERE user_type = 'student' AND access_key_id = '';

SELECT *
FROM portal.accessor_info
WHERE access_id = ''

DELETE FROM api.access_keys
WHERE /*student conditions*/

DELETE FROM portal.portal_students
WHERE student_id = ''


-- SCRATCH PAD
SELECT portal_id FROM portal.portal_students WHERE student_id = 
-- portal db
DELETE FROM users 