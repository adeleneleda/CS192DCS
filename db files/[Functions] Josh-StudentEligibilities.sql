

DROP FUNCTION f_elig_twicefailsubjects_student(integer) CASCADE;
CREATE OR REPLACE FUNCTION f_elig_twicefailsubjects_student(p_termid integer, studentid integer) 
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
				(SELECT students.studentid as jstudentid, eligtwicefailcourses.courseid
					FROM students JOIN studentterms USING (studentid)
						JOIN studentclasses USING (studenttermid)
						JOIN classes USING (classid)
						JOIN grades USING (gradeid)
						JOIN eligtwicefailcourses USING (courseid)
					WHERE grades.gradevalue = 5
						AND students.studentid = $2
					GROUP BY studentid, eligtwicefailcourses.courseid
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

-- MUST PASS MORE THAN 1/2 of subjects per sem
DROP FUNCTION f_elig_passhalfpersem(integer) CASCADE;
CREATE OR REPLACE FUNCTION f_elig_passhalfpersem_student(p_termid integer, p_studentid integer)
RETURNS SETOF t_elig_passhalfpersem AS 
$$
	SELECT studentid, studenttermid, 
		(CASE WHEN $1 % 10 = 1 THEN $1
			WHEN $1 % 10 = 2 THEN $1
			WHEN $1 % 10 = 3 THEN $1 - 1 END) as termid, failpercentage
	FROM
		(SELECT outerterms.studentid, outerterms.studenttermid, outerterms.termid,
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue = 5
				AND studentclasses.studenttermid = outerTerms.studenttermid
				AND outerTerms.studentid = $2)
				/
			(SELECT COALESCE(SUM(courses.credits), 1)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE studentclasses.studenttermid = outerTerms.studenttermid
				AND outerTerms.studentid = $2)
			AS failpercentage
		FROM studentterms AS outerterms
		WHERE ($1 % 10 = 1 AND termid = $1)	-- 1st Semester
			OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
			OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			AS temp
	WHERE failpercentage > 0.5;
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
CREATE OR REPLACE FUNCTION f_elig_passhalf_mathcs_persem_student(p_termid integer, p_studentid integer) 
RETURNS SETOF t_elig_passhalf_mathcs_persem AS 
$$
	SELECT studentid, studenttermid, 
		(CASE WHEN $1 % 10 = 1 THEN $1
			WHEN $1 % 10 = 2 THEN $1
			WHEN $1 % 10 = 3 THEN $1 - 1 END) as termid, failpercentage
	FROM
		(SELECT outerterms.studentid, outerterms.studenttermid, outerterms.termid, 
			(SELECT COALESCE(SUM(courses.credits), 0)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE grades.gradevalue = 5
				AND studentclasses.studenttermid = outerTerms.studenttermid
				AND outerTerms.studentid = $2
				AND (courses.coursename ilike 'Math %' OR courses.coursename ilike 'CS %'))
				/
			(SELECT COALESCE(SUM(courses.credits), 1)
			FROM studentclasses 
				JOIN classes USING (classid)
				JOIN grades USING (gradeid)
				JOIN courses USING (courseid)
			WHERE studentclasses.studenttermid = outerTerms.studenttermid
				AND outerTerms.studentid = $2
				AND (courses.coursename ilike 'Math %' OR courses.coursename ilike 'CS %'))
			AS failpercentage
		FROM studentterms AS outerterms
		WHERE ($1 % 10 = 1 AND termid = $1)	-- 1st Semester
			OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
			OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			AS temp
	WHERE failpercentage > 0.5;
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
CREATE OR REPLACE FUNCTION f_elig_24unitspassed_singleyear_student(p_year integer, p_studentid integer)
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
				AND studentterms.studentid = $2
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

-----------------------------------------------------
------------------ INSERTION STUFF ------------------
----------------------------------------------------- 

CREATE OR REPLACE FUNCTION f_getall_eligtwicefail_student(p_studentid integer) 
RETURNS SETOF t_elig_twicefailsubjects AS 
$$
	DECLARE
		tempTermid integer;
		tempdata record;
	BEGIN
		
		FOR tempTermid IN
			SELECT termid
			FROM terms
			ORDER BY termid
		LOOP
			FOR tempdata IN 
				SELECT * FROM f_elig_twicefailsubjects_student(tempTermid, $1)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$
LANGUAGE plpgsql;

----- Pass Half -----
CREATE OR REPLACE FUNCTION f_getall_eligpasshalf_student(p_studentid integer) 
RETURNS SETOF t_elig_passhalfpersem AS 
$$
	DECLARE
		tempTermid integer;
		tempdata record;
	BEGIN
		
		FOR tempTermid IN
			SELECT termid
			FROM terms
			ORDER BY termid
		LOOP
			FOR tempdata IN 
				SELECT * FROM f_elig_passhalfpersem_student(tempTermid, $1)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$
LANGUAGE plpgsql;

----- Pass Half Math CS -----
CREATE OR REPLACE FUNCTION f_getall_eligpasshalfmathcs_student(p_studentid integer) 
RETURNS SETOF t_elig_passhalf_mathcs_persem AS 
$$
	DECLARE
		tempTermid integer;
		tempdata record;
	BEGIN
		
		FOR tempTermid IN
			SELECT termid
			FROM terms
			ORDER BY termid
		LOOP
			FOR tempdata IN 
				SELECT * FROM f_elig_passhalf_mathcs_persem_student(tempTermid, $1)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$
LANGUAGE plpgsql;

--SELECT DISTINCT * FROM f_getall_eligpasshalfmathcs() ORDER BY studentid, studenttermid, termid, failpercentage;

INSERT INTO eligpasshalfmathcs
SELECT DISTINCT * FROM f_getall_eligpasshalfmathcs() ORDER BY studentid, studenttermid, termid, failpercentage;


----- 24 Unit Rule -----
CREATE OR REPLACE FUNCTION f_getall_24unitspassed_student(p_studentid integer) 
RETURNS SETOF t_elig_24unitspassed AS 
$$
	DECLARE
		tempyearid integer;
		tempdata record;
	BEGIN
		
		FOR tempyearid IN
			SELECT DISTINCT (termid / 10) AS yearid 
			FROM terms
		LOOP
			FOR tempdata IN 
				SELECT * FROM f_elig_24unitspassed_singleyear_student(tempyearid, $1)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$
LANGUAGE plpgsql;