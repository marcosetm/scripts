-- set up CTEs
-- get contacts related codes
WITH codes AS (
	SELECT
		codesetid,
		displayvalue as state,
		description as relationship,
		code
	FROM
		codeset
	WHERE
		codetype = 'State'
		OR codetype = 'Relationship'
		OR codetype = 'Phone'
),
-- sequence phone numbers to use in columns
phonenumbers AS (
	SELECT
		personid,
		MAX(
			CASE
				WHEN seq = 1 THEN phone
			END
		) AS phone1,
		MAX(
			CASE
				WHEN seq = 1 THEN phone_type
			END
		) AS phone_type1,
		MAX(
			CASE
				WHEN seq = 2 THEN phone
			END
		) AS phone2,
		MAX(
			CASE
				WHEN seq = 2 THEN phone_type
			END
		) AS phone_type2
	FROM
		(
			SELECT
				ppna.PERSONID as personid,
				ppna.PHONENUMBERASENTERED as phone,
				(
					SELECT
						code
					FROM
						codes
					WHERE
						codesetid = ppna.phonetypecodesetid
				) AS phone_type,
				ppna.PHONENUMBERPRIORITYORDER AS priority,
				ppna.ISPREFERRED AS perferred,
				ROW_NUMBER() OVER(
					PARTITION BY personid
					ORDER BY
						PHONENUMBERPRIORITYORDER
				) AS seq
			FROM
				personphonenumberassoc ppna
		)
	GROUP BY
		personid
)
-- create extract for contacts data spec
SELECT
	p.lastname AS contact_last_name,
	p.firstname AS contact_first_name,
	(
		SELECT
			relationship
		FROM
			codes
		WHERE
			codesetid = scd.relationshiptypecodesetid
	) AS contact_type,
	pn.phone1,
	pn.phone_type1,
	pn.phone2,
	pn.phone_type2,
	ea.emailaddress AS email,
	pa.street AS address,
	pa.linetwo AS address2,
	pa.city AS city,
	(
		SELECT
			code
		FROM
			codes
		WHERE
			codesetid = pa.statescodesetid
	) AS state,
	pa.postalcode AS zip,
	scd.iscustodial AS is_legal,
	scd.receivesmailflg AS receives_mail,
	scd.isemergency AS emergency,
	s.student_number,
	s.state_studentnumber
FROM
	person p
	LEFT JOIN studentcontactassoc sca ON sca.personid = p.id
	LEFT JOIN phonenumbers pn ON pn.personid = p.id
	LEFT JOIN personemailaddressassoc peaa ON peaa.personid = p.id
	LEFT JOIN emailaddress ea ON ea.emailaddressid = peaa.emailaddressid
	LEFT JOIN personaddressassoc paa ON paa.personid = p.id
	LEFT JOIN personaddress pa ON pa.personaddressid = paa.personaddressid
	JOIN studentcontactdetail scd ON scd.studentcontactassocid = sca.studentcontactassocid
	JOIN students s ON s.dcid = sca.studentdcid;