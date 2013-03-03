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

INSERT INTO eligtwicefailcourses 
	SELECT courseid FROM courses WHERE coursename IN ('math 17', 'math 53', 'math 54', 'math 55');
INSERT INTO eligtwicefailcourses 
	SELECT courseid FROM courses WHERE coursename IN ('cs 11', 'cs 12', 'cs 21', 'cs 32');

DROP TYPE t_elig_twicefailsubjects;
CREATE TYPE t_elig_twicefailsubjects AS (
    studentid integer,
    classid integer,
    courseid integer,
    termid integer
);

DROP FUNCTION f_elig_twicefailsubjects(integer);
CREATE OR REPLACE FUNCTION f_elig_twicefailsubjects(p_termid integer) 
RETURNS SETOF t_elig_twicefailsubjects AS 
$$
	SELECT students.studentid, classes.classid, classes.courseid, classes.termid
	FROM 
		students JOIN studentterms USING (studentid)
		JOIN studentclasses USING (studenttermid)
		JOIN grades USING (gradeid)
		JOIN classes USING (classid)
		JOIN 
			(SELECT * FROM 
				(SELECT students.studentid as jstudentid, eligtwicefailcourses.courseid
					FROM students JOIN studentterms USING (studentid)
						JOIN studentclasses USING (studenttermid)
						JOIN classes USING (classid)
						JOIN grades USING (gradeid)
						JOIN eligtwicefailcourses USING (courseid)
					WHERE grades.gradevalue = 5
					GROUP BY studentid, eligtwicefailcourses.courseid
					HAVING count(*) > 1) AS studentlist
				WHERE 
					(SELECT count(*) 
					FROM students JOIN studentterms USING (studentid) 
						JOIN studentclasses USING (studenttermid) 
						JOIN classes USING (classid)
					WHERE classes.termid <= $1
						AND students.studentid = studentlist.jstudentid
						AND classes.courseid = studentlist.courseid) >= 1
			) AS studentlist
		ON (studentlist.jstudentid = students.studentid AND studentlist.courseid = classes.courseid)
	WHERE grades.gradevalue = 5
	ORDER BY students.studentid, classes.courseid, classes.termid;
$$
LANGUAGE SQL;

-- MUST PASS MORE THAN 1/2 of subjects per sem
DROP TYPE t_elig_passhalfpersem CASCADE;
CREATE TYPE t_elig_passhalfpersem AS (
	studentid integer,
    studenttermid integer,
	failpercentage real
);

DROP FUNCTION f_elig_passhalfpersem(integer);
CREATE OR REPLACE FUNCTION f_elig_passhalfpersem(p_termid integer) 
RETURNS SETOF t_elig_passhalfpersem AS 
$$
	SELECT studentid, studenttermid, failpercentage
	FROM
		(SELECT outerterms.studentid, outerterms.studenttermid,
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue = 5
				AND studentclasses.studenttermid = outerTerms.studenttermid)
				/
			(SELECT COALESCE(SUM(courses.credits), 1)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE studentclasses.studenttermid = outerTerms.studenttermid)
			AS failpercentage
		FROM studentterms AS outerterms
		WHERE termid <= $1) AS temp
	WHERE failpercentage > 0.5;
$$
LANGUAGE SQL;

-- MUST PASS MORE THAN 1/2 of CS/Math
DROP TYPE t_elig_passhalf_mathcs_persem CASCADE;
CREATE TYPE t_elig_passhalf_mathcs_persem AS (
	studentid integer,
    studenttermid integer,
	failpercentage real
);

DROP FUNCTION f_elig_passhalf_mathcs_persem(integer);
CREATE OR REPLACE FUNCTION f_elig_passhalf_mathcs_persem(p_termid integer) 
RETURNS SETOF t_elig_passhalf_mathcs_persem AS 
$$
	SELECT studentid, studenttermid, failpercentage
	FROM
		(SELECT outerterms.studentid, outerterms.studenttermid,
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue = 5
				AND studentclasses.studenttermid = outerTerms.studenttermid
				AND (courses.coursename ilike 'Math %' OR courses.coursename ilike 'CS %'))
				/
			(SELECT COALESCE(SUM(courses.credits), 1)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE studentclasses.studenttermid = outerTerms.studenttermid
				AND (courses.coursename ilike 'Math %' OR courses.coursename ilike 'CS %'))
			AS failpercentage
		FROM studentterms AS outerterms
		WHERE termid <= $1) AS temp
	WHERE failpercentage > 0.5;
$$
LANGUAGE SQL;

-- 24 units passed after year
--> Params: studentid, year (2010) <= NOT 20101
DROP TYPE t_elig_24unitspassed CASCADE;
CREATE TYPE t_elig_24unitspassed AS (
	studentid integer,
	studenttermid integer,
	unitspassed real
);

DROP FUNCTION f_elig_24unitspassed(integer);
CREATE OR REPLACE FUNCTION f_elig_24unitspassed(p_year integer) 
RETURNS SETOF t_elig_24unitspassed AS 
$$
	SELECT studentid, studenttermid, unitspassed
	FROM 
		(SELECT studentid, studenttermid,
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentterms JOIN studentclasses USING (studenttermid)
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue <= 1 AND grades.gradevalue >= 1
				AND studentterms.termid >= $1 * 10
				AND studentterms.termid <= $1 * 10 + 3
				AND studentterms.studenttermid = outerTerms.studenttermid
			)
			AS unitspassed
		FROM studentterms AS outerTerms) as innerQuery
	WHERE unitspassed < 24
$$
LANGUAGE SQL;
