/*
INSERT new student disability codes

CREATE TABLE `student_disability_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL,
  `description` varchar(255) NOT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `ignore_flag` tinyint(1) NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci
*/

BEGIN;

INSERT INTO student_disability_type (code, description)
VALUES
	('OI', 'Orthopedic Impairment'),
	('VI', 'Visual Impairment'),
	('MD', 'Multiple Disabilities'),
	('CMO', 'Moderate Intellctual Disability');

ROLLBACK;

