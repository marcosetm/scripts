-- student contact extract 
SELECT
  s.local_student_id AS "Student ID",
  s.first_name AS "Student First Name",
  s.last_name AS "Student Last Name",
  s.birth_date AS "Student DOB",
  cc.email_address AS "Guardian Email",
  cc.first_name AS "Guardian First Name",
  cc.last_name AS "Guardian Last Name",
  regexp_replace(
    cp.phone,
    '(\d{3})(\d{3})(\d{4})',
    '\1-\2-\3',
    'g'
  ) AS "Phone Number"
FROM
  students s
  JOIN contacts.student_contact_aff sca USING(student_id)
  JOIN contacts.contacts cc USING(contact_id)
  LEFT JOIN contacts.contact_phones cp USING(contact_id)
WHERE
  sca.is_legal = TRUE
ORDER BY s.local_student_id