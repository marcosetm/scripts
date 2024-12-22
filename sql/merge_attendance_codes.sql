/*
goal: merge both 'Unverified' and 'Unverfied' codes into 'Unexecused'

transaction
- update aliasses in the UI
- update all attendance reason IDs with the keeper ID
- remove both codes in the UI

TABLE: attendance_reason
REFERENCES:
- student_attendance_period
- attendance_treshold_reason
- attendance_reason_alias
*/
-- update reason aliases in the UI first
-- check the following before update
SELECT * FROM attendance_reason ar WHERE LOWER(name) LIKE '%unver%'; -- 13 = Unverified and 38 = Unverfied 
SELECT COUNT(attendance_reason_id) FROM student_attendance_period WHERE attendance_reason_id IN (13, 38); -- 2,476 records
SELECT COUNT(attendance_reason_id) FROM attendance_threshold_reason atr WHERE attendance_reason_id IN (13, 38); -- 34 records

-- UPDATE ALL attendance_reason_id in relevant tables
-- table student_attendance_period
BEGIN;
UPDATE student_attendance_period  
SET attendance_reason_id = 8
WHERE attendance_reason_id IN (13, 38);
ROLLBACK;

-- table attendance_threshold_reason, had to delete to avoid duplicates
BEGIN;
DELETE FROM attendance_threshold_reason 
WHERE attendance_reason_id IN (13, 38);
ROLLBACK;
