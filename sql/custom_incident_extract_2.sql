-- remove the null subtypes
WITH student_info AS (
	-- get student district id, current school at current AY
	SELECT 
		stuid.student_id,
		stuid.unique_id AS student_district_id,
		s.fname AS student_first_name,
		s.lname AS student_last_name,
		school.name AS school_name
	FROM student s
	JOIN student_identification stuid ON s.id = stuid.student_id
	JOIN student_enrollment se ON s.id = se.student_id
	JOIN school ON se.school_id = school.id
	JOIN school_year sy ON se.school_year_id = sy.id
	WHERE 
		stuid.district_id_flag = 1 -- district ID
		-- AND sy.name = '2024-2025' -- current year only
)
SELECT
	stuinfo.student_id AS student_district_id
	, CONCAT(stuinfo.student_last_name, ', ',  stuinfo.student_first_name) AS student_name
	, stuinfo.school_name
	, si.incident_id AS ec_incident_details_id -- what you see in the UI
	, si.id AS ec_incident_id
	, i.import_id AS imported_incident_id -- if null, not imported
	, i.datetime
	, i.entry_datetime
	, CONCAT(u.lname, ', ', u.fname) AS observed_by
	, sbt.name AS behavior_type
	, ib.name
	, ( SELECT ibd.description 
		FROM incident_behavior_descriptor ibd 
		WHERE ibd.id = sibd.incident_behavior_descriptor_id) AS subtypes
FROM
	student_incident si
	LEFT JOIN student_info stuinfo ON si.student_id = stuinfo.student_id
	LEFT JOIN incident i ON si.incident_id = i.id
	LEFT JOIN `user` u ON i.observer_user_id = u.id
	LEFT JOIN student_incident_behavior sib ON si.id = sib.student_incident_id
	LEFT JOIN incident_behavior ib ON sib.incident_behavior_id = ib.id
	LEFT JOIN student_incident_behavior_descriptor sibd ON sib.id = sibd.student_incident_behavior_id
	LEFT JOIN incident_behavior_type sbt ON ib.incident_behavior_type_id = sbt.id

ORDER BY subtypes DESC, si.id
;