/* 
REQUEST: 2024 incidents only with OSS response -- student_school.school_id/school_year_id
- Incident ID, 
- Student District ID, 
- Student School, -- incident_field_response.school_id
- Observed by, 
- Type, 
- Code,  
- State Reportable, 
- Law Enforcement Contacted, 
- Response Type, 
- # of days, 
- Police Involvement,
- Suspension Start Date

Example student John Smith
- student_id = 3602
Example user id = 409 (Mandy Madeup)

example incident_id 1302 

custom fields needed
- incident.observer_user_id
	- observed by
	- options

- incident types (incident_field)
	- Major
		- state reportable
		- Laws enforcement contacted
		- subtypes? = incident_behavior_descriptor
- responses (incident_response)
	- number of days
	- police involvement
	- suspension start date

behavior code (incident_behavior)	

tables
- student_incident
	- incident_id
	- student_id

- student_incident_behavior
	- 
*/

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
		AND sy.name = '2023-2024' -- current year only
),
custom_fields AS (
	SELECT 
		sib.student_incident_id,
		(SELECT display_value FROM incident_field_option ifo WHERE ifo.id = ifrsr.incident_field_option_id) AS state_reportable,
		(SELECT display_value FROM incident_field_option ifo WHERE ifo.id = ifrlec.incident_field_option_id) AS law_enforcement_contacted
	FROM student_incident_behavior sib
	LEFT JOIN incident_field_response ifrsr ON ifrsr.student_incident_behavior_id = sib.id AND ifrsr.incident_field_id = 36
	LEFT JOIN incident_field_response ifrlec ON ifrlec.student_incident_behavior_id = sib.id AND ifrlec.incident_field_id = 37
)
SELECT
	si.incident_id, -- what you see at in the UI
	stuinfo.student_district_id,
	stuinfo.school_name,
	CONCAT(u.lname, ', ', u.fname) AS observed_by,
	sbt.name AS 'type',
	ib.name AS code,
	(SELECT ibd.description FROM incident_behavior_descriptor ibd WHERE ibd.id = sibd.incident_behavior_descriptor_id) AS subtypes,
	cf.state_reportable,
	cf.law_enforcement_contacted,
	ir.name AS response_type,
	(SELECT nd.value FROM incident_response_field_response nd WHERE nd.incident_response_field_id = 2 AND sir.id = nd.student_incident_response_id) AS number_of_days,
	(SELECT CASE WHEN pi.value = 1 THEN 'Yes' ELSE 'No' END FROM incident_response_field_response pi WHERE pi.incident_response_field_id = 10 AND sir.id = pi.student_incident_response_id) AS police_involvement,
	(SELECT ssd.value FROM incident_response_field_response ssd WHERE ssd.incident_response_field_id = 12 AND sir.id = ssd.student_incident_response_id) AS suspension_start_date
FROM student_incident si
LEFT JOIN student_info stuinfo ON si.student_id = stuinfo.student_id
LEFT JOIN incident i ON si.incident_id = i.id
LEFT JOIN `user` u ON i.observer_user_id = u.id
LEFT JOIN student_incident_behavior sib ON si.id = sib.student_incident_id
LEFT JOIN incident_behavior ib ON sib.incident_behavior_id = ib.id
LEFT JOIN student_incident_behavior_descriptor sibd ON sib.id = sibd.student_incident_behavior_id
LEFT JOIN incident_behavior_type sbt ON ib.incident_behavior_type_id = sbt.id
LEFT JOIN student_incident_response sir ON sir.student_incident_id = si.id
LEFT JOIN incident_response ir ON ir.id = sir.incident_response_id 
LEFT JOIN custom_fields cf ON si.id = cf.student_incident_id
WHERE 
	stuinfo.student_id = 3183
	and ir.id = 6; -- only return OSS
	-- and si.incident_id = 1296; -- 1300


-- GROUPED VERSION

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
		AND sy.name = '2023-2024' -- current year only
),
custom_fields AS (
	SELECT 
		sib.student_incident_id,
		(SELECT display_value FROM incident_field_option ifo WHERE ifo.id = ifrsr.incident_field_option_id) AS state_reportable,
		(SELECT display_value FROM incident_field_option ifo WHERE ifo.id = ifrlec.incident_field_option_id) AS law_enforcement_contacted
	FROM student_incident_behavior sib
	LEFT JOIN incident_field_response ifrsr ON ifrsr.student_incident_behavior_id = sib.id AND ifrsr.incident_field_id = 36
	LEFT JOIN incident_field_response ifrlec ON ifrlec.student_incident_behavior_id = sib.id AND ifrlec.incident_field_id = 37
)
SELECT
	si.incident_id, -- what you see at in the UI
	stuinfo.student_district_id,
	stuinfo.school_name,
	CONCAT(u.lname, ', ', u.fname) AS observed_by,
	sbt.name AS 'type',
	ib.name AS code,
	GROUP_CONCAT((SELECT ibd.description FROM incident_behavior_descriptor ibd WHERE ibd.id = sibd.incident_behavior_descriptor_id)) AS subtypes,
	cf.state_reportable,
	cf.law_enforcement_contacted,
	ir.name AS response_type,
	(SELECT nd.value FROM incident_response_field_response nd WHERE nd.incident_response_field_id = 2 AND sir.id = nd.student_incident_response_id) AS number_of_days,
	(SELECT CASE WHEN pi.value = 1 THEN 'Yes' ELSE 'No' END FROM incident_response_field_response pi WHERE pi.incident_response_field_id = 10 AND sir.id = pi.student_incident_response_id) AS police_involvement,
	(SELECT ssd.value FROM incident_response_field_response ssd WHERE ssd.incident_response_field_id = 12 AND sir.id = ssd.student_incident_response_id) AS suspension_start_date
FROM student_incident si
LEFT JOIN student_info stuinfo ON si.student_id = stuinfo.student_id
LEFT JOIN incident i ON si.incident_id = i.id
LEFT JOIN `user` u ON i.observer_user_id = u.id
LEFT JOIN student_incident_behavior sib ON si.id = sib.student_incident_id
LEFT JOIN incident_behavior ib ON sib.incident_behavior_id = ib.id
LEFT JOIN student_incident_behavior_descriptor sibd ON sib.id = sibd.student_incident_behavior_id
LEFT JOIN incident_behavior_type sbt ON ib.incident_behavior_type_id = sbt.id
LEFT JOIN student_incident_response sir ON sir.student_incident_id = si.id
LEFT JOIN incident_response ir ON ir.id = sir.incident_response_id 
LEFT JOIN custom_fields cf ON si.id = cf.student_incident_id
WHERE ir.id = 6
GROUP BY si.incident_id;