/*

Refresh Attendance
- Run each statement separately

*/

update attendance_rollup_status 
set expired_flag = 1 
where school_year_id = (select id from school_year where name = '2024-2025');
call refresh_student_attendance_rate(CURDATE(), @rows);