CREATE TABLE ineligibilities (
	ineligibilityid integer PRIMARY KEY,
	ineligibility varchar(32)
);

CREATE TABLE studentineligibilities (
	studentineligibilityid integer,
	ineligibilityid integer REFERENCES ineligibilities
);

INSERT INTO ineligibilities (ineligibilityid, ineligibility) VALUES (1, 'Twice Fail Subject');
INSERT INTO ineligibilities (ineligibilityid, ineligibility) VALUES (2, '50% Passing Subjects');
INSERT INTO ineligibilities (ineligibilityid, ineligibility) VALUES (3, '50% Passing CS/Math');
INSERT INTO ineligibilities (ineligibilityid, ineligibility) VALUES (4, '24 Units Passing per Year');

-- TWICE FAIL ELIG CHECK
CREATE TABLE eligtwicefailcourses (
	courseid	integer
);

DELETE FROM eligtwicefailcourses;
INSERT INTO eligtwicefailcourses 
	SELECT courseid FROM courses WHERE coursename IN ('Math 17', 'Math 53', 'Math 54', 'Math 55');
INSERT INTO eligtwicefailcourses 
	SELECT courseid FROM courses WHERE coursename IN ('CS 11', 'CS 12', 'CS 21', 'CS 32');

DROP TYPE t_elig_twicefailsubjects CASCADE;
CREATE TYPE t_elig_twicefailsubjects AS (
    studentid integer,
    classid integer,
    courseid integer,
	section varchar(7),
	coursename varchar(45),
    termid integer
);

DROP FUNCTION f_elig_twicefailsubjects(integer) CASCADE;
CREATE OR REPLACE FUNCTION f_elig_twicefailsubjects(p_termid integer) 
RETURNS SETOF t_elig_twicefailsubjects AS 
$$
	SELECT students.studentid, classes.classid, classes.courseid, classes.section, courses.coursename, classes.termid
	FROM 
		students JOIN studentterms USING (studentid)
		JOIN studentclasses USING (studenttermid)
		JOIN grades USING (gradeid)
		JOIN classes USING (classid)
		JOIN courses USING (courseid)
		JOIN 
			(SELECT * FROM 
				(SELECT students.studentid as jstudentid, courseid
					FROM students JOIN studentterms USING (studentid)
						JOIN studentclasses USING (studenttermid)
						JOIN classes USING (classid)
						JOIN grades USING (gradeid)
					WHERE grades.gradevalue = 5
						AND courseid IN (SELECT courseid FROM eligtwicefailcourses)
					GROUP BY studentid, courseid
					HAVING count(*) > 1) AS studentlist
				WHERE 
					(SELECT count(*) 
					FROM students JOIN studentterms USING (studentid) 
						JOIN studentclasses USING (studenttermid) 
						JOIN classes USING (classid)
					WHERE classes.termid = $1
						AND students.studentid = studentlist.jstudentid
						AND classes.courseid = studentlist.courseid) >= 1
			) AS studentlist
		ON (studentlist.jstudentid = students.studentid AND studentlist.courseid = classes.courseid)
	WHERE grades.gradevalue = 5
	ORDER BY students.studentid, classes.courseid, classes.termid;
$$
LANGUAGE SQL;

DROP FUNCTION f_loadelig_twicefailsubjects(integer) CASCADE;
CREATE OR REPLACE FUNCTION f_loadelig_twicefailsubjects(p_termid integer) 
RETURNS SETOF t_elig_twicefailsubjects AS 
$$
	SELECT DISTINCT eligtwicefail.*
	FROM eligtwicefail
		JOIN 
			(SELECT studentid, courseid, MAX(termid) AS maxtermid
			FROM eligtwicefail
			GROUP BY studentid, courseid) AS failedcourses 
			ON (failedcourses.studentid = eligtwicefail.studentid AND failedcourses.courseid = eligtwicefail.courseid)
	WHERE failedcourses.maxtermid <= $1
	ORDER BY eligtwicefail.studentid, eligtwicefail.courseid, eligtwicefail.termid
$$
LANGUAGE SQL;


-- MUST PASS MORE THAN 1/2 of subjects per sem
DROP TYPE t_elig_passhalfpersem CASCADE;
CREATE TYPE t_elig_passhalfpersem AS (
	studentid integer,
    studenttermid integer,
	termid integer,
	failpercentage real
);

DROP FUNCTION f_elig_passhalfpersem(integer) CASCADE;
CREATE OR REPLACE FUNCTION f_elig_passhalfpersem(p_termid integer)
RETURNS SETOF t_elig_passhalfpersem AS 
$$
	SELECT *
	FROM
		(SELECT outerStudents.studentid,
			-- Studenttermid
			(SELECT studenttermid 
			FROM studentterms 
			WHERE studentid = outerStudents.studentid 
				AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
				OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
				OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))
			LIMIT 1
			) AS studenttermid,	-- Summer (+2nd Semester)
			-- Termid
			(CASE WHEN $1 % 10 = 1 THEN $1
				WHEN $1 % 10 = 2 THEN $1
				WHEN $1 % 10 = 3 THEN $1 - 1 END) as termid, 
			-- Fail Percentage
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentterms
				JOIN studentclasses USING (studenttermid)
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue = 5
				AND studenttermid IN 
					(SELECT studenttermid 
					FROM studentterms 
					WHERE 
						studentterms.studentid = outerStudents.studentid
						AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
						OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
						OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
					)
			)
			/
			(SELECT COALESCE(SUM(courses.credits), 1)
			FROM studentterms
				JOIN studentclasses USING (studenttermid)
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE studenttermid IN 
					(SELECT studenttermid 
					FROM studentterms 
					WHERE 
						studentterms.studentid = outerStudents.studentid
						AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
						OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
						OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
					)
			) AS failpercentage
		FROM 
			(SELECT DISTINCT studentid
			FROM studentterms 
			WHERE 
				(($1 % 10 = 1 AND termid = $1)				-- 1st Semester
				OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
				OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			) AS outerStudents
		) AS foo
	WHERE failpercentage > 0.5
$$
LANGUAGE SQL;

-- MUST PASS MORE THAN 1/2 of CS/Math
DROP TYPE t_elig_passhalf_mathcs_persem CASCADE;
CREATE TYPE t_elig_passhalf_mathcs_persem AS (
	studentid integer,
    studenttermid integer,
	termid integer,
	failpercentage real
);

DROP FUNCTION f_elig_passhalf_mathcs_persem(integer) CASCADE;
CREATE OR REPLACE FUNCTION f_elig_passhalf_mathcs_persem(p_termid integer) 
RETURNS SETOF t_elig_passhalf_mathcs_persem AS 
$$
	SELECT *
	FROM
		(SELECT outerStudents.studentid,
			-- Studenttermid
			(SELECT studenttermid 
			FROM studentterms 
			WHERE studentid = outerStudents.studentid 
				AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
				OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
				OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))
			LIMIT 1
			) AS studenttermid,	-- Summer (+2nd Semester)
			-- Termid
			(CASE WHEN $1 % 10 = 1 THEN $1
				WHEN $1 % 10 = 2 THEN $1
				WHEN $1 % 10 = 3 THEN $1 - 1 END) as termid, 
			-- Fail Percentage
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentterms
				JOIN studentclasses USING (studenttermid)
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue = 5
				AND studenttermid IN 
					(SELECT studenttermid 
					FROM studentterms 
					WHERE 
						studentterms.studentid = outerStudents.studentid
						AND (courses.coursename ilike 'Math %' OR courses.coursename ilike 'CS %')
						AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
						OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
						OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
					)
			)
			/
			(SELECT COALESCE(SUM(courses.credits), 1)
			FROM studentterms
				JOIN studentclasses USING (studenttermid)
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE studenttermid IN 
					(SELECT studenttermid 
					FROM studentterms 
					WHERE 
						studentterms.studentid = outerStudents.studentid
						AND (courses.coursename ilike 'Math %' OR courses.coursename ilike 'CS %')
						AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
						OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
						OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
					)
			) AS failpercentage
		FROM 
			(SELECT DISTINCT studentid
			FROM studentterms 
			WHERE 
				(($1 % 10 = 1 AND termid = $1)				-- 1st Semester
				OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
				OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			) AS outerStudents
		) AS foo
	WHERE failpercentage > 0.5
$$
LANGUAGE SQL;

-- 24 units passed after year
--> Params: studentid, year (2010) <= NOT 20101
DROP TYPE t_elig_24unitspassed CASCADE;
CREATE TYPE t_elig_24unitspassed AS (
	studentid integer,
	yearid integer,
	unitspassed real
);

DROP FUNCTION f_elig_24unitspassed_singleyear(integer);
CREATE OR REPLACE FUNCTION f_elig_24unitspassed_singleyear(p_year integer)
RETURNS SETOF t_elig_24unitspassed AS
$$
	SELECT studentid, $1, unitspassed
	FROM
		(SELECT studentid, 
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentterms JOIN studentclasses USING (studenttermid)
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue <= 3 AND grades.gradevalue >= 1
				AND studentterms.termid >= $1 * 10
				AND studentterms.termid <= $1 * 10 + 3
				AND studentterms.studentid = studentlist.studentid
			) AS unitspassed
		FROM 
			(SELECT DISTINCT studentid
			FROM studentterms
			WHERE studentterms.termid >= $1 * 10
				AND studentterms.termid <= $1 * 10 + 3
			ORDER BY studentid) AS studentlist
		) AS innerQuery
	WHERE unitspassed < 24
$$
LANGUAGE SQL;

DROP FUNCTION f_elig_24unitspassed(integer);
CREATE OR REPLACE FUNCTION f_elig_24unitspassed(p_year integer) 
RETURNS SETOF t_elig_24unitspassed AS 
$$
	SELECT f_elig_24unitspassed_singleyear(yearid)
	FROM
	(SELECT yearid
	FROM 
		(SELECT DISTINCT (termid / 10) AS yearid FROM terms) AS yearlist
	WHERE yearid <= $1
	ORDER BY yearid ASC) AS innerquery;
$$
LANGUAGE SQL;

------------------------------------------------------
------------------ Search Functions ------------------
------------------------------------------------------

DROP TYPE t_loadstudents_andineligible CASCADE;
CREATE TYPE t_loadstudents_andineligible AS (
	studentid integer,
	studentno varchar(9),
	name varchar(200)
);

DROP FUNCTION f_loadstudents_andineligible_nosum(integer, varchar(100));
CREATE OR REPLACE FUNCTION f_loadstudents_andineligible_nosum(p_termid integer, p_year varchar(100)) 
RETURNS SETOF t_loadstudents_andineligible AS 
$$
	SELECT DISTINCT * FROM 
	(
		SELECT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students 
			JOIN studentterms USING (studentid) 
			JOIN persons USING (personid) 
		WHERE studentterms.termid = $1
		-----
		UNION
		-----
		SELECT DISTINCT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students
			JOIN persons USING (personid)
			JOIN 
				(SELECT studentid
				FROM eligtwicefail
				GROUP BY studentid, courseid
				HAVING MAX(termid) <= $1) AS failedcourses
				USING (studentid)
		-----
		UNION
		-----
		SELECT DISTINCT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students
			JOIN persons USING (personid)
			JOIN eligpasshalf USING (studentid)
		WHERE eligpasshalf.termid <= $1
		-----
		UNION
		-----
		SELECT DISTINCT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students
			JOIN persons USING (personid)
			JOIN eligpasshalfmathcs USING (studentid)
		WHERE eligpasshalfmathcs.termid <= $1
	)
	AS innerquery
	WHERE studentno ILIKE $2 || '%'
	ORDER BY name;
$$
LANGUAGE SQL;

DROP FUNCTION f_loadstudents_andineligible_year(integer, integer, integer);
CREATE OR REPLACE FUNCTION f_loadstudents_andineligible_year(p_termid integer, p_year varchar(100), p_yearid integer) 
RETURNS SETOF t_loadstudents_andineligible AS 
$$
	SELECT DISTINCT * FROM 
	(
		SELECT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students 
			JOIN studentterms USING (studentid) 
			JOIN persons USING (personid) 
		WHERE studentterms.termid = $1
		-----
		UNION
		-----
		SELECT DISTINCT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students
			JOIN persons USING (personid)
			JOIN 
				(SELECT studentid
				FROM eligtwicefail
				GROUP BY studentid, courseid
				HAVING MAX(termid) <= $1) AS failedcourses
				USING (studentid)
		-----
		UNION
		-----
		SELECT DISTINCT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students
			JOIN persons USING (personid)
			JOIN eligpasshalf USING (studentid)
		WHERE eligpasshalf.termid <= $1
		-----
		UNION
		-----
		SELECT DISTINCT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name 
		FROM students
			JOIN persons USING (personid)
			JOIN eligpasshalfmathcs USING (studentid)
		WHERE eligpasshalfmathcs.termid <= $1
		-----
		UNION
		-----
		SELECT DISTINCT studentid, studentno, lastname || ', ' || firstname || ' ' || middlename as name
		FROM students
			JOIN persons USING (personid)
			JOIN elig24unitspassing USING (studentid)
		WHERE elig24unitspassing.yearid <= $3
	)
	AS innerquery
	WHERE studentno ILIKE $2 || '%'
	ORDER BY name;
$$
LANGUAGE SQL;




--------------------------------------------------------- DO NOT RUN BEYOND THIS POINT -----------------------------------------------


-- Gives list of all students enrolled in a particular semester
(SELECT DISTINCT studentid
FROM studentterms
WHERE studentterms.termid >= 2010 * 10
	AND studentterms.termid <= 2010 * 10 + 3
ORDER BY studentid) AS studentlist;


select * 
from studentterms join studentclasses using (studenttermid) 
	join classes using (classid)
	join courses using (courseid)
where studentid = 57 and studentterms.termid >= 20110 and studentterms.termid <= 20113;-- and gradeid < 11;


SELECT COALESCE(SUM(courses.credits), 0)
FROM studentterms JOIN studentclasses USING (studenttermid)
	  JOIN classes USING (classid)
	  JOIN grades USING (gradeid)
	  JOIN courses USING (courseid)
WHERE grades.gradevalue <= 3 AND grades.gradevalue >= 1
	  AND studentterms.termid >= 2010 * 10
	  AND studentterms.termid <= 2010 * 10 + 3
	  AND studentterms.studentid = outerTerms.studentid
) AS unitspassed