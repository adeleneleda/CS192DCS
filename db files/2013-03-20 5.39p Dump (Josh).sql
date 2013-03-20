--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: t_elig_24unitspassed; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE t_elig_24unitspassed AS (
	studentid integer,
	yearid integer,
	unitspassed real
);


ALTER TYPE public.t_elig_24unitspassed OWNER TO postgres;

--
-- Name: t_elig_passhalf_mathcs_persem; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE t_elig_passhalf_mathcs_persem AS (
	studentid integer,
	studenttermid integer,
	termid integer,
	failpercentage real
);


ALTER TYPE public.t_elig_passhalf_mathcs_persem OWNER TO postgres;

--
-- Name: t_elig_passhalfpersem; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE t_elig_passhalfpersem AS (
	studentid integer,
	studenttermid integer,
	termid integer,
	failpercentage real
);


ALTER TYPE public.t_elig_passhalfpersem OWNER TO postgres;

--
-- Name: t_elig_twicefailsubjects; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE t_elig_twicefailsubjects AS (
	studentid integer,
	classid integer,
	courseid integer,
	section character varying(7),
	coursename character varying(45),
	termid integer
);


ALTER TYPE public.t_elig_twicefailsubjects OWNER TO postgres;

--
-- Name: t_loadstudents_andineligible; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE t_loadstudents_andineligible AS (
	studentid integer,
	studentno character varying(9),
	name character varying(200)
);


ALTER TYPE public.t_loadstudents_andineligible OWNER TO postgres;

--
-- Name: csgwa(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION csgwa(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE x numeric;
sid INTEGER;
tid INTEGER;
BEGIN


-- old query
-- SELECT COALESCE(SUM(gradevalue * credits) / SUM(credits), 0) into x
-- FROM viewclasses
-- WHERE studentid = $1 AND coursename like 'CS%' AND gradeid <= 11;

-- new query: arg1 = studenttermid
SELECT studentid into sid FROM studentterms where studenttermid = $1;
SELECT termid into tid FROM studentterms where studenttermid = $1;


SELECT COALESCE(SUM(gradevalue * credits) / SUM(credits),0) into x
FROM viewclasses
WHERE studentid = sid AND coursename like 'CS%' AND gradeid <= 11 AND termid <= tid;

RETURN round(x,4);



END$_$;


ALTER FUNCTION public.csgwa(p_studentid integer) OWNER TO postgres;

--
-- Name: f_elig_24unitspassed(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_24unitspassed(p_year integer) RETURNS SETOF t_elig_24unitspassed
    LANGUAGE sql
    AS $_$
	SELECT f_elig_24unitspassed_singleyear(yearid)
	FROM
	(SELECT yearid
	FROM 
		(SELECT DISTINCT (termid / 10) AS yearid FROM terms) AS yearlist
	WHERE yearid <= $1
	ORDER BY yearid ASC) AS innerquery;
$_$;


ALTER FUNCTION public.f_elig_24unitspassed(p_year integer) OWNER TO postgres;

--
-- Name: f_elig_24unitspassed_singleyear(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_24unitspassed_singleyear(p_year integer) RETURNS SETOF t_elig_24unitspassed
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_elig_24unitspassed_singleyear(p_year integer) OWNER TO postgres;

--
-- Name: f_elig_24unitspassed_singleyear_student(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_24unitspassed_singleyear_student(p_year integer, p_studentid integer) RETURNS SETOF t_elig_24unitspassed
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_elig_24unitspassed_singleyear_student(p_year integer, p_studentid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalf_mathcs_persem(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalf_mathcs_persem(p_termid integer) RETURNS SETOF t_elig_passhalf_mathcs_persem
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_elig_passhalf_mathcs_persem(p_termid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalf_mathcs_persem_student(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalf_mathcs_persem_student(p_termid integer, p_studentid integer) RETURNS SETOF t_elig_passhalf_mathcs_persem
    LANGUAGE sql
    AS $_$
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
						(courses.coursename ilike 'Math %' OR courses.coursename ilike 'CS %')
						AND studentterms.studentid = outerStudents.studentid
						AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
						OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
						OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
					)
			) AS failpercentage
		FROM 
			(SELECT DISTINCT studentid
			FROM studentterms 
			WHERE 
				studentid = $2
				AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
				OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
				OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			) AS outerStudents
		) AS foo
	WHERE failpercentage > 0.5
$_$;


ALTER FUNCTION public.f_elig_passhalf_mathcs_persem_student(p_termid integer, p_studentid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalfpersem(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalfpersem(p_termid integer) RETURNS SETOF t_elig_passhalfpersem
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_elig_passhalfpersem(p_termid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalfpersem_student(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalfpersem_student(p_termid integer, p_studentid integer) RETURNS SETOF t_elig_passhalfpersem
    LANGUAGE sql
    AS $_$
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
				studentid = $2
				AND (($1 % 10 = 1 AND termid = $1)				-- 1st Semester
				OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
				OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			) AS outerStudents
		) AS foo
	WHERE failpercentage > 0.5;
$_$;


ALTER FUNCTION public.f_elig_passhalfpersem_student(p_termid integer, p_studentid integer) OWNER TO postgres;

--
-- Name: f_elig_twicefailsubjects(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_twicefailsubjects(p_termid integer) RETURNS SETOF t_elig_twicefailsubjects
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_elig_twicefailsubjects(p_termid integer) OWNER TO postgres;

--
-- Name: f_elig_twicefailsubjects_student(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_twicefailsubjects_student(p_termid integer, studentid integer) RETURNS SETOF t_elig_twicefailsubjects
    LANGUAGE sql
    AS $_$
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
						AND students.studentid = $2
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
$_$;


ALTER FUNCTION public.f_elig_twicefailsubjects_student(p_termid integer, studentid integer) OWNER TO postgres;

--
-- Name: f_getall_24unitspassed(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_24unitspassed(p_studentid integer) RETURNS SETOF t_elig_24unitspassed
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_getall_24unitspassed(p_studentid integer) OWNER TO postgres;

--
-- Name: f_getall_24unitspassed_student(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_24unitspassed_student(p_studentid integer) RETURNS SETOF t_elig_24unitspassed
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_getall_24unitspassed_student(p_studentid integer) OWNER TO postgres;

--
-- Name: f_getall_eligpasshalf(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_eligpasshalf() RETURNS SETOF t_elig_passhalfpersem
    LANGUAGE plpgsql
    AS $$
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
				SELECT * FROM f_elig_passhalfpersem(tempTermid)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$;


ALTER FUNCTION public.f_getall_eligpasshalf() OWNER TO postgres;

--
-- Name: f_getall_eligpasshalf_student(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_eligpasshalf_student(p_studentid integer) RETURNS SETOF t_elig_passhalfpersem
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_getall_eligpasshalf_student(p_studentid integer) OWNER TO postgres;

--
-- Name: f_getall_eligpasshalfmathcs(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_eligpasshalfmathcs() RETURNS SETOF t_elig_passhalf_mathcs_persem
    LANGUAGE plpgsql
    AS $$
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
				SELECT * FROM f_elig_passhalf_mathcs_persem(tempTermid)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$;


ALTER FUNCTION public.f_getall_eligpasshalfmathcs() OWNER TO postgres;

--
-- Name: f_getall_eligpasshalfmathcs_student(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_eligpasshalfmathcs_student(p_studentid integer) RETURNS SETOF t_elig_passhalf_mathcs_persem
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_getall_eligpasshalfmathcs_student(p_studentid integer) OWNER TO postgres;

--
-- Name: f_getall_eligtwicefail(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_eligtwicefail() RETURNS SETOF t_elig_twicefailsubjects
    LANGUAGE plpgsql
    AS $$
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
				SELECT * FROM f_elig_twicefailsubjects(tempTermid)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$;


ALTER FUNCTION public.f_getall_eligtwicefail() OWNER TO postgres;

--
-- Name: f_getall_eligtwicefail_student(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_eligtwicefail_student(p_studentid integer) RETURNS SETOF t_elig_twicefailsubjects
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_getall_eligtwicefail_student(p_studentid integer) OWNER TO postgres;

--
-- Name: f_loadelig_twicefailsubjects(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_loadelig_twicefailsubjects(p_termid integer) RETURNS SETOF t_elig_twicefailsubjects
    LANGUAGE sql
    AS $_$
	SELECT DISTINCT eligtwicefail.*
	FROM eligtwicefail
		JOIN 
			(SELECT studentid, courseid, MAX(termid) AS maxtermid
			FROM eligtwicefail
			GROUP BY studentid, courseid) AS failedcourses 
			ON (failedcourses.studentid = eligtwicefail.studentid AND failedcourses.courseid = eligtwicefail.courseid)
	WHERE failedcourses.maxtermid <= $1
	ORDER BY eligtwicefail.studentid, eligtwicefail.courseid, eligtwicefail.termid
$_$;


ALTER FUNCTION public.f_loadelig_twicefailsubjects(p_termid integer) OWNER TO postgres;

--
-- Name: f_loadstudents_andineligible_nosum(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_loadstudents_andineligible_nosum(p_termid integer, p_year character varying) RETURNS SETOF t_loadstudents_andineligible
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_loadstudents_andineligible_nosum(p_termid integer, p_year character varying) OWNER TO postgres;

--
-- Name: f_loadstudents_andineligible_year(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_loadstudents_andineligible_year(p_termid integer, p_year character varying, p_yearid integer) RETURNS SETOF t_loadstudents_andineligible
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_loadstudents_andineligible_year(p_termid integer, p_year character varying, p_yearid integer) OWNER TO postgres;

--
-- Name: gwa(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gwa(p_studenttermid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE
sid INTEGER;
tid INTEGER;
BEGIN
	SELECT studentid into sid FROM studentterms WHERE studenttermid = $1;
	SELECT termid into tid FROM studentterms WHERE studenttermid = $1;

	return gwa(sid, tid);
END;$_$;


ALTER FUNCTION public.gwa(p_studenttermid integer) OWNER TO postgres;

--
-- Name: FUNCTION gwa(p_studenttermid integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION gwa(p_studenttermid integer) IS 'OVERLOADED FUNCTION FOR GWA

OVERLOAD FOR ARGUMENT: studenttermid';


--
-- Name: gwa(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gwa(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE x NUMERIC;


counter NUMERIC;







BEGIN




SELECT COALESCE(SUM(gradevalue*credits) / SUM(credits),0) into x



FROM viewclasses v



WHERE studentid = $1 AND termid = $2 AND gradeid <= 11;





RETURN round(x,4);




END$_$;


ALTER FUNCTION public.gwa(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: mathgwa(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mathgwa(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE x numeric;
sid INTEGER;
tid INTEGER;
BEGIN


-- old query
-- SELECT COALESCE(SUM(gradevalue * credits) / SUM(credits),0) into x
-- FROM viewclasses
-- WHERE studentid = $1 AND coursename like 'Math%' AND (coursename <> 'Math 1' AND coursename <> 'Math 2') AND gradeid <= 11;


-- new query: arg1 = studenttermid
SELECT studentid into sid FROM studentterms where studenttermid = $1;
SELECT termid into tid FROM studentterms where studenttermid = $1;


SELECT COALESCE(SUM(gradevalue * credits) / SUM(credits),0) into x
FROM viewclasses
WHERE studentid = sid AND coursename like 'Math%' AND (coursename <> 'Math 1' AND coursename <> 'Math 2') AND gradeid <= 11 AND termid <= tid;



RETURN round(x,4);



END$_$;


ALTER FUNCTION public.mathgwa(p_studentid integer) OWNER TO postgres;

--
-- Name: xcwa69(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xcwa69(p_studenttermid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE
sid INTEGER;
tid INTEGER;
BEGIN
	SELECT studentid into sid FROM studentterms WHERE studenttermid = $1;
	SELECT termid into tid FROM studentterms WHERE studenttermid = $1;

	return xcwa69(sid, tid);
END;$_$;


ALTER FUNCTION public.xcwa69(p_studenttermid integer) OWNER TO postgres;

--
-- Name: FUNCTION xcwa69(p_studenttermid integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION xcwa69(p_studenttermid integer) IS 'OVERLOADED FUNCTION FOR CWA

OVERLOAD FOR ARGUMENT: studenttermid';


--
-- Name: xcwa69(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xcwa69(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE 

ah numeric DEFAULT 0; -- [SUM] (units*grade) of passing AH
ahf numeric DEFAULT 0; -- [SUM] (units*grade) of failed AH
mst numeric DEFAULT 0;
mstf numeric DEFAULT 0;
ssp numeric DEFAULT 0;
sspf numeric DEFAULT 0;
maj numeric DEFAULT 0;
ele numeric DEFAULT 0;
elef numeric DEFAULT 0;
ahd numeric DEFAULT 0; -- [SUM] units of passing AH
ahdf numeric DEFAULT 0; -- [SUM] units of failed AH
mstd numeric DEFAULT 0;
mstdf numeric DEFAULT 0;
sspd numeric DEFAULT 0;
sspdf numeric DEFAULT 0;
majd numeric DEFAULT 0;
eled numeric DEFAULT 0;
eledf numeric DEFAULT 0;
cwa numeric DEFAULT 0;
numer numeric DEFAULT 0;
denom numeric DEFAULT 0;

BEGIN
	
	--first 5 ah numer
	SELECT COALESCE(SUM(x*y),0) into ah FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--first 5 ah denom
	SELECT COALESCE(SUM(y),0) into ahd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--ah fail numer
	SELECT COALESCE(SUM(x*y), 0) into ahf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'AH' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	--ah fail denom
	SELECT COALESCE(SUM(y), 0) into ahdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'AH' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	--first 4 mst numer
	SELECT COALESCE(SUM(x*y), 0) into mst FROM
	(SELECT v.gradevalue as x, v.credits as y, v.coursename
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 4) as sss;

	--first 4 mst denom
	SELECT COALESCE(SUM(y), 0) into mstd FROM
	(SELECT v.gradevalue as x, v.credits as y, v.coursename
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 4) as sss;

	--ns1 and ns2 corrections
	IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename
								FROM viewclasses v 
								WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2
								ORDER BY v.termid ASC
								LIMIT 4) as sss WHERE coursename IN ('Nat Sci 1', 'Chem 1', 'Physics 10')) > 2 THEN
		SELECT xns1_correction($1, $2) into mst;
		SELECT xns1_dcorrection($1, $2) into mstd;
	ELSE 
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename
								FROM viewclasses v 
								WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2
								ORDER BY v.termid ASC
								LIMIT 4) as sss WHERE coursename IN ('Nat Sci 2', 'Bio 1', 'Geol 1')) > 2 THEN
		SELECT xns2_correction($1, $2) into mst;
		SELECT xns2_dcorrection($1, $2) into mstd;
		END IF;
	END IF;

	--mst fails numer
	SELECT COALESCE(SUM(x*y), 0) into mstf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	--mst fails denom
	SELECT COALESCE(SUM(y), 0) into mstdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	--first 5 ssp numer
	SELECT COALESCE(SUM(x*y), 0) into ssp FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--first 5 ssp denom
	SELECT COALESCE(SUM(y), 0) into sspd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--ssp fails numer
	SELECT COALESCE(SUM(x*y), 0) into sspf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	--ssp fails denom
	SELECT COALESCE(SUM(y), 0) into sspdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	--maj pass+fail numer
	SELECT COALESCE(SUM(x*y), 0) into maj FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid <= 11 AND v.termid <= $2) as sss;

	--maj pass+fail denom
	SELECT COALESCE(SUM(y), 0) into majd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid <= 11 AND v.termid <= $2) as sss;

	--first 3 ele numer
	SELECT COALESCE(SUM(x*y), 0) into ele FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 3) as sss;
	
	--first 3 ele denom
	SELECT COALESCE(SUM(y), 0) into eled FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2
		ORDER BY v.termid ASC
		LIMIT 3) as sss;

	--overflowing electives correction
	IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
								FROM viewclasses v
								WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2
								ORDER BY v.termid ASC
								LIMIT 3) as sss WHERE sss.domain = 'C197') > 2 THEN
		SELECT xovercs197_correction($1, $2) INTO ele;
		SELECT xovercs197_dcorrection($1, $2) INTO eled;
	ELSE
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
									FROM viewclasses v
									WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2
									ORDER BY v.termid ASC
									LIMIT 3) as sss WHERE sss.domain = 'MSEE') > 2 THEN
			SELECT xovermsee_correction($1, $2) INTO ele;
			SELECT xovermsee_dcorrection($1, $2) INTO eled;
		ELSE
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
									FROM viewclasses v
									WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2
									ORDER BY v.termid ASC
									LIMIT 3) as sss WHERE sss.domain = 'FE') > 2 THEN
			SELECT xoverfe_correction($1, $2) INTO ele;
			SELECT xoverfe_dcorrection($1, $2) INTO eled;
		END IF;
		END IF;
	END IF;

	--ele fails numer
	SELECT COALESCE(SUM(x*y),0) into elef FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	--ele fails denom
	SELECT COALESCE(SUM(y),0) into elef FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid <= $2) as sss;

	numer = (ah + ahf + mst + mstf + ssp + sspf + maj + ele);
	denom = (ahd + ahdf + mstd + mstdf + sspd + sspdf + majd + eled);
	IF denom = 0 THEN RETURN 0; END IF;
	cwa = numer / denom;

	RETURN round(cwa,4);	


END;$_$;


ALTER FUNCTION public.xcwa69(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xns1_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xns1_correction(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



ns1group_credits numeric DEFAULT 0;



otherMST_credits numeric DEFAULT 0;



BEGIN




	SELECT SUM(x * y) into ns1group_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherMST_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;




	return ns1group_credits + otherMST_credits;







END;$_$;


ALTER FUNCTION public.xns1_correction(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xns1_dcorrection(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xns1_dcorrection(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



ns1group_units numeric DEFAULT 0;



otherMST_units numeric DEFAULT 0;







BEGIN

	SELECT SUM(y) into ns1group_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;

	



	SELECT COALESCE(SUM(y),0) into otherMST_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;

	return ns1group_units + otherMST_units;







END;$_$;


ALTER FUNCTION public.xns1_dcorrection(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xns2_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xns2_correction(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



ns2group_credits numeric DEFAULT 0;



otherMST_credits numeric DEFAULT 0;







BEGIN

	SELECT SUM(x * y) into ns2group_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherMST_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;

	return ns2group_credits + otherMST_credits;







END;$_$;


ALTER FUNCTION public.xns2_correction(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xns2_dcorrection(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xns2_dcorrection(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



ns2group_units numeric DEFAULT 0;



otherMST_units numeric DEFAULT 0;







BEGIN

	SELECT SUM(y) into ns2group_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss 



	WHERE coursename IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;

	



	SELECT COALESCE(SUM(y),0) into otherMST_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;

	return ns2group_units + otherMST_units;







END;$_$;


ALTER FUNCTION public.xns2_dcorrection(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xovercs197_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xovercs197_correction(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



CSEgroup_credits numeric DEFAULT 0;



otherELE_credits numeric DEFAULT 0;







BEGIN

	SELECT SUM(x * y) into CSEgroup_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain = 'C197'



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherELE_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain <> 'C197'



	LIMIT 1;

	return CSEgroup_credits + otherELE_credits;



END$_$;


ALTER FUNCTION public.xovercs197_correction(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xovercs197_dcorrection(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xovercs197_dcorrection(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



CSEgroup_units numeric DEFAULT 0;



otherELE_units numeric DEFAULT 0;







BEGIN

	SELECT SUM(y) into CSEgroup_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain = 'C197'



	LIMIT 2;





	SELECT COALESCE(SUM(y),0) into otherELE_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain <> 'C197'



	LIMIT 1;

	return CSEgroup_units + otherELE_units;



END$_$;


ALTER FUNCTION public.xovercs197_dcorrection(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xoverfe_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xoverfe_correction(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



FEgroup_credits numeric DEFAULT 0;



otherELE_credits numeric DEFAULT 0;







BEGIN

	SELECT SUM(x * y) into FEgroup_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain = 'FE'



	LIMIT 1;





	SELECT COALESCE(SUM(x * y),0) into otherELE_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain <> 'FE'



	LIMIT 2;

	return FEgroup_credits + otherELE_credits;



END$_$;


ALTER FUNCTION public.xoverfe_correction(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xoverfe_dcorrection(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xoverfe_dcorrection(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



FEgroup_units numeric DEFAULT 0;



otherELE_units numeric DEFAULT 0;







BEGIN

	SELECT SUM(y) into FEgroup_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain = 'FE'



	LIMIT 1;





	SELECT COALESCE(SUM(y),0) into otherELE_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain <> 'FE'



	LIMIT 2;

	return FEgroup_units + otherELE_units;



END$_$;


ALTER FUNCTION public.xoverfe_dcorrection(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xovermsee_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xovermsee_correction(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



MSEEgroup_credits numeric DEFAULT 0;



otherELE_credits numeric DEFAULT 0;







BEGIN

	SELECT SUM(x * y) into MSEEgroup_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain = 'MSEE'



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherELE_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain <> 'MSEE'



	LIMIT 1;

	return MSEEgroup_credits + otherELE_credits;



END$_$;


ALTER FUNCTION public.xovermsee_correction(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xovermsee_dcorrection(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xovermsee_dcorrection(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



MSEEgroup_units numeric DEFAULT 0;



otherELE_units numeric DEFAULT 0;







BEGIN

	SELECT SUM(y) into MSEEgroup_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain = 'MSEE'



	LIMIT 2;





	SELECT COALESCE(SUM(y),0) into otherELE_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.domain



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid <= $2



		ORDER BY v.termid ASC) as sss



	WHERE sss.domain <> 'MSEE'



	LIMIT 1;

	return MSEEgroup_units + otherELE_units;



END$_$;


ALTER FUNCTION public.xovermsee_dcorrection(p_studentid integer, p_termid integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE classes (
    classid integer NOT NULL,
    termid integer,
    courseid integer,
    section character varying(12),
    classcode character varying(5)
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: classes_classid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE classes_classid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.classes_classid_seq OWNER TO postgres;

--
-- Name: classes_classid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE classes_classid_seq OWNED BY classes.classid;


--
-- Name: classes_classid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('classes_classid_seq', 14939, true);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE courses (
    courseid integer NOT NULL,
    coursename character varying(45),
    credits real,
    domain character varying(4),
    commtype character varying(2)
);


ALTER TABLE public.courses OWNER TO postgres;

--
-- Name: courses_courseid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE courses_courseid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.courses_courseid_seq OWNER TO postgres;

--
-- Name: courses_courseid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE courses_courseid_seq OWNED BY courses.courseid;


--
-- Name: courses_courseid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('courses_courseid_seq', 1, false);


--
-- Name: curricula; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE curricula (
    curriculumid integer NOT NULL,
    curriculumname character varying(45)
);


ALTER TABLE public.curricula OWNER TO postgres;

--
-- Name: curricula_curriculumid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE curricula_curriculumid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.curricula_curriculumid_seq OWNER TO postgres;

--
-- Name: curricula_curriculumid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE curricula_curriculumid_seq OWNED BY curricula.curriculumid;


--
-- Name: curricula_curriculumid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('curricula_curriculumid_seq', 4, true);


--
-- Name: elig24unitspassing; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE elig24unitspassing (
    studentid integer,
    yearid integer,
    unitspassed real
);


ALTER TABLE public.elig24unitspassing OWNER TO postgres;

--
-- Name: eligpasshalf; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE eligpasshalf (
    studentid integer,
    studenttermid integer,
    termid integer,
    failpercentage real
);


ALTER TABLE public.eligpasshalf OWNER TO postgres;

--
-- Name: eligpasshalfmathcs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE eligpasshalfmathcs (
    studentid integer,
    studenttermid integer,
    termid integer,
    failpercentage real
);


ALTER TABLE public.eligpasshalfmathcs OWNER TO postgres;

--
-- Name: eligtwicefail; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE eligtwicefail (
    studentid integer,
    classid integer,
    courseid integer,
    section character varying(7),
    coursename character varying(45),
    termid integer
);


ALTER TABLE public.eligtwicefail OWNER TO postgres;

--
-- Name: eligtwicefailcourses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE eligtwicefailcourses (
    courseid integer
);


ALTER TABLE public.eligtwicefailcourses OWNER TO postgres;

--
-- Name: grades; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE grades (
    gradeid integer NOT NULL,
    gradename character varying(4),
    gradevalue numeric(3,2)
);


ALTER TABLE public.grades OWNER TO postgres;

--
-- Name: grades_gradeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE grades_gradeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grades_gradeid_seq OWNER TO postgres;

--
-- Name: grades_gradeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE grades_gradeid_seq OWNED BY grades.gradeid;


--
-- Name: grades_gradeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('grades_gradeid_seq', 26, true);


--
-- Name: ineligibilities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ineligibilities (
    ineligibilityid integer NOT NULL,
    ineligibility character varying(32)
);


ALTER TABLE public.ineligibilities OWNER TO postgres;

--
-- Name: instructorclasses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE instructorclasses (
    instructorclassid integer NOT NULL,
    classid integer,
    instructorid integer
);


ALTER TABLE public.instructorclasses OWNER TO postgres;

--
-- Name: instructorclasses_instructorclassid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE instructorclasses_instructorclassid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.instructorclasses_instructorclassid_seq OWNER TO postgres;

--
-- Name: instructorclasses_instructorclassid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE instructorclasses_instructorclassid_seq OWNED BY instructorclasses.instructorclassid;


--
-- Name: instructorclasses_instructorclassid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('instructorclasses_instructorclassid_seq', 95, true);


--
-- Name: instructors; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE instructors (
    instructorid integer NOT NULL,
    personid integer
);


ALTER TABLE public.instructors OWNER TO postgres;

--
-- Name: instructors_instructorid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE instructors_instructorid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.instructors_instructorid_seq OWNER TO postgres;

--
-- Name: instructors_instructorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE instructors_instructorid_seq OWNED BY instructors.instructorid;


--
-- Name: instructors_instructorid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('instructors_instructorid_seq', 10, true);


--
-- Name: persons; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE persons (
    personid integer NOT NULL,
    lastname character varying(45),
    firstname character varying(45),
    middlename character varying(45),
    pedigree character varying(45)
);


ALTER TABLE public.persons OWNER TO postgres;

--
-- Name: persons_personid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE persons_personid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.persons_personid_seq OWNER TO postgres;

--
-- Name: persons_personid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE persons_personid_seq OWNED BY persons.personid;


--
-- Name: persons_personid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('persons_personid_seq', 2193, true);


--
-- Name: requirements; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requirements (
    requirementid integer NOT NULL,
    requirementname character varying(50),
    functionname character varying(50)
);


ALTER TABLE public.requirements OWNER TO postgres;

--
-- Name: requirements_requirementid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE requirements_requirementid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requirements_requirementid_seq OWNER TO postgres;

--
-- Name: requirements_requirementid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE requirements_requirementid_seq OWNED BY requirements.requirementid;


--
-- Name: requirements_requirementid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('requirements_requirementid_seq', 1, false);


--
-- Name: studentclasses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE studentclasses (
    studentclassid integer NOT NULL,
    studenttermid integer,
    classid integer,
    gradeid integer
);


ALTER TABLE public.studentclasses OWNER TO postgres;

--
-- Name: studentclasses_studentclassid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE studentclasses_studentclassid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.studentclasses_studentclassid_seq OWNER TO postgres;

--
-- Name: studentclasses_studentclassid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE studentclasses_studentclassid_seq OWNED BY studentclasses.studentclassid;


--
-- Name: studentclasses_studentclassid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 41428, true);


--
-- Name: studentineligibilities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE studentineligibilities (
    studentineligibilityid integer,
    ineligibilityid integer
);


ALTER TABLE public.studentineligibilities OWNER TO postgres;

--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE students (
    studentid integer NOT NULL,
    personid integer,
    studentno character varying(9),
    curriculumid integer
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: students_studentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE students_studentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_studentid_seq OWNER TO postgres;

--
-- Name: students_studentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE students_studentid_seq OWNED BY students.studentid;


--
-- Name: students_studentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('students_studentid_seq', 2183, true);


--
-- Name: studentterms; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE studentterms (
    studenttermid integer NOT NULL,
    studentid integer,
    termid integer,
    ineligibilities character varying,
    issettled boolean,
    cwa numeric DEFAULT 0 NOT NULL,
    gwa numeric DEFAULT 0 NOT NULL,
    mathgwa numeric DEFAULT 0 NOT NULL,
    csgwa numeric DEFAULT 0 NOT NULL
);


ALTER TABLE public.studentterms OWNER TO postgres;

--
-- Name: studentterms_studenttermid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE studentterms_studenttermid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.studentterms_studenttermid_seq OWNER TO postgres;

--
-- Name: studentterms_studenttermid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE studentterms_studenttermid_seq OWNED BY studentterms.studenttermid;


--
-- Name: studentterms_studenttermid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 9347, true);


--
-- Name: terms; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE terms (
    termid integer NOT NULL,
    name character varying(45),
    year character varying(9),
    sem character varying(3)
);


ALTER TABLE public.terms OWNER TO postgres;

--
-- Name: terms_termid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE terms_termid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.terms_termid_seq OWNER TO postgres;

--
-- Name: terms_termid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE terms_termid_seq OWNED BY terms.termid;


--
-- Name: terms_termid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('terms_termid_seq', 1, false);


--
-- Name: viewclasses; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW viewclasses AS
    SELECT courses.coursename, grades.gradevalue, courses.credits, students.studentid, terms.termid, courses.domain, persons.lastname, persons.firstname, persons.middlename, grades.gradeid, students.studentno FROM (((((((students JOIN persons USING (personid)) JOIN studentterms USING (studentid)) JOIN terms USING (termid)) JOIN studentclasses USING (studenttermid)) JOIN grades USING (gradeid)) JOIN classes USING (classid)) JOIN courses USING (courseid));


ALTER TABLE public.viewclasses OWNER TO postgres;

--
-- Name: classid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE classes ALTER COLUMN classid SET DEFAULT nextval('classes_classid_seq'::regclass);


--
-- Name: courseid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE courses ALTER COLUMN courseid SET DEFAULT nextval('courses_courseid_seq'::regclass);


--
-- Name: curriculumid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE curricula ALTER COLUMN curriculumid SET DEFAULT nextval('curricula_curriculumid_seq'::regclass);


--
-- Name: gradeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE grades ALTER COLUMN gradeid SET DEFAULT nextval('grades_gradeid_seq'::regclass);


--
-- Name: instructorclassid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE instructorclasses ALTER COLUMN instructorclassid SET DEFAULT nextval('instructorclasses_instructorclassid_seq'::regclass);


--
-- Name: instructorid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE instructors ALTER COLUMN instructorid SET DEFAULT nextval('instructors_instructorid_seq'::regclass);


--
-- Name: personid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE persons ALTER COLUMN personid SET DEFAULT nextval('persons_personid_seq'::regclass);


--
-- Name: requirementid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE requirements ALTER COLUMN requirementid SET DEFAULT nextval('requirements_requirementid_seq'::regclass);


--
-- Name: studentclassid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE studentclasses ALTER COLUMN studentclassid SET DEFAULT nextval('studentclasses_studentclassid_seq'::regclass);


--
-- Name: studentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE students ALTER COLUMN studentid SET DEFAULT nextval('students_studentid_seq'::regclass);


--
-- Name: studenttermid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE studentterms ALTER COLUMN studenttermid SET DEFAULT nextval('studentterms_studenttermid_seq'::regclass);


--
-- Name: termid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE terms ALTER COLUMN termid SET DEFAULT nextval('terms_termid_seq'::regclass);


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY classes (classid, termid, courseid, section, classcode) FROM stdin;
13138	19991	98	TFQ1	418
13139	19991	116	WBC	919
13140	19991	117	11	3557
13141	19991	94	MHQ3	3983
13142	19991	81	MHW	6800
13143	19991	55	TFR2	9661
13144	19991	106	MTHFX6	9764
13145	20001	33	TFR3	12225
13146	20001	108	MTHFW3	35242
13147	20001	110	MTHFI	37302
13148	20001	102	MHR-S	41562
13149	20001	2	HMXY	44901
13150	20002	109	MHW2	35238
13151	20002	118	TFQ	35271
13152	20002	111	MTHFD	37331
13153	20002	3	TFXY	44911
13154	20002	5	MHX1	44913
13155	20003	118	X3-2	35181
13156	20003	95	X1-1	38511
13157	20011	34	TFW-3	11676
13158	20011	119	MHX	35252
13159	20011	103	TFY2	40385
13160	20011	6	TFR	44922
13161	20011	5	W1	44944
13162	20012	113	MHX3	13972
13163	20012	103	MHU1	40344
13164	20012	11	MHY	44919
13165	20012	19	TFR	44921
13166	20012	24	TFY	44939
13167	20012	114	TFZ	45440
13168	20013	39	X6-D	14922
13169	20013	11	X3	44906
13170	20021	8	TFY	44920
13171	20021	6	TFW	44922
13172	20021	7	MHXY	44925
13173	20021	120	TFV	44931
13174	20021	114	MHW	45405
13175	20021	41	TFX2	12350
13176	20021	106	MTHFU1	35138
13177	20021	98	TFY1	39648
13178	20021	81	MHY	41805
13179	20021	1	MHVW	44901
13180	20021	41	TFV6	12389
13181	20021	106	MTHFW4	35161
13182	20021	94	MHV1	38510
13183	20021	81	TFR	41807
13184	20021	1	MHXY	44902
13185	20022	19	TFX	44918
13186	20022	9	TFV	44925
13187	20022	27	TFW	44927
13188	20022	70	TFR2	33729
13189	20022	107	MTHFV1	35165
13190	20022	95	MHX	38533
13191	20022	100	MHW2	39648
13192	20022	2	MHRU	44900
13193	20022	71	MHR	34200
13194	20022	107	MTHFW3	35173
13195	20022	100	MHV	39646
13196	20022	82	TFU	41814
13197	20022	2	MHXY	44901
13198	20031	121	MHW2	16602
13199	20031	17	MHX	54566
13200	20031	20	WSVX2	54582
13201	20031	14	TFVW	54603
13202	20031	122	MHY	54604
13203	20031	123	MHW	14482
13204	20031	63	MHV	15620
13205	20031	109	TFU2	39320
13206	20031	110	MTHFX	41352
13207	20031	93	MHU1	46314
13208	20031	2	TFVW	54555
13209	20031	34	TFV-2	13921
13210	20031	108	MTHFW1	39247
13211	20031	110	MTHFD	41419
13212	20031	93	TFY2	46310
13213	20031	3	MHXY	54560
13214	20031	43	MHW2	14467
13215	20031	106	MTHFX8	39221
13216	20031	82	TFR	41908
13217	20031	1	MHRU	54550
13218	20031	88	(1)	62806
13219	20031	41	TFQ2	14425
13220	20031	106	MTHFW6	39211
13221	20031	82	MHQ	41905
13222	20031	103	MHX2	44662
13223	20031	1	TFRU	54553
13224	20032	20	WSVX2	54595
13225	20032	42	TFW1	14435
13226	20032	73	MTHW	38073
13227	20032	119	MHX	39321
13228	20032	94	TFX2	45813
13229	20032	3	FTRU	54560
13230	20032	5	MHU	54561
13231	20032	109	TFV1	39278
13232	20032	119	MHW	39320
13233	20032	111	MTHFV	41488
13234	20032	95	TFX1	45839
13235	20032	5	MHX	54562
13236	20032	42	TFU2	14432
13237	20032	107	MTHFR3	39215
13238	20032	81	MHW	41902
13239	20032	102	MHU	45213
13240	20032	2	TFVW	54558
13241	20032	107	MTHFW2	39236
13242	20032	98	WSR2	42601
13243	20032	102	TFQ	45220
13244	20032	94	TFR3	45801
13245	20032	1	MHRU	54552
13246	20033	110	Y3	41355
13247	20033	111	Y3	41362
13248	20033	43	X3A	14411
13249	20033	98	X1-1	42451
13250	20033	108	Z1-2	39183
13251	20041	62	MHX1	15613
13252	20041	119	TFW	39305
13253	20041	7	HMRU	54555
13254	20041	8	TFR	54569
13255	20041	6	TFU	54572
13256	20041	112	MHV	70025
13257	20041	36	TFR-1	13856
13258	20041	35	WIJK	15505
13259	20041	109	MHW2	39395
13260	20041	114	TFW	52451
13261	20041	5	MHU	54563
13262	20041	31	MHR1	15507
13263	20041	108	MTHFW2	39255
13264	20041	110	MTHFX	41354
13265	20041	94	MHU5	45761
13266	20041	3	TFRU	54561
13267	20041	41	MHX3	14423
13268	20041	108	MTHFQ2	39369
13269	20041	110	MTHFD	41350
13270	20041	81	MHW	41902
13271	20041	2	TFVW	54557
13272	20041	41	TFQ1	14428
13273	20041	106	MTHFW2	39208
13274	20041	76	MHX	40826
13275	20041	98	TFX2	42471
13276	20041	1	MHRU	54550
13277	20042	113	MHX1	15672
13278	20042	124	TFY	47972
13279	20042	19	MHR	54564
13280	20042	12	TFRU	54573
13281	20042	24	MHU	54597
13282	20042	11	TFV	54598
13283	20042	42	MHW1	14429
13284	20042	55	TFU1	15568
13285	20042	113	MHV3	15668
13286	20042	41	MHR	14401
13287	20042	73	MTHU-2	38052
13288	20042	109	TFU2	39271
13289	20042	119	TFR	39311
13290	20042	110	MTHFI	41352
13291	20042	5	MHX	54561
13292	20042	43	MHV2	14460
13293	20042	119	TFQ	39178
13294	20042	109	TFR	39268
13295	20042	111	MTHFD	41379
13296	20042	42	MHU1	14421
13297	20042	107	MTHFQ2	39209
13298	20042	95	MHR1	45780
13299	20042	93	TFR3	46324
13300	20042	2	MHXY	54557
13301	20043	39	X3-A	16057
13302	20043	111	Y4	41354
13303	20043	84	X4	41905
13304	20043	103	X-5-2	44660
13305	20043	111	Y1	41353
13306	20043	109	X1-1	39196
13307	20043	108	Z1-4	39187
13308	20051	114	MHR	52454
13309	20051	17	MHX	54567
13310	20051	8	TFY	54570
13311	20051	122	MHU	54577
13312	20051	20	WSVX2	54581
13313	20051	27	WRU	54588
13314	20051	21	FR	54592
13315	20051	114	TFU	52455
13316	20051	17	MHU	54566
13317	20051	6	TFW	54573
13318	20051	7	HMXY	54575
13319	20051	112	MHR	69953
13320	20051	113	TFU2	15702
13321	20051	48	MTU	19924
13322	20051	119	TFR	39309
13323	20051	111	MTHFI	41439
13324	20051	94	MHX3	45771
13325	20051	5	TFX	54562
13326	20051	62	TFR1	15564
13327	20051	119	TFQ	39308
13328	20051	93	TFV1	46329
13329	20051	3	MHXY	54559
13330	20051	71	TFX	38890
13331	20051	108	MTHFU1	39242
13332	20051	110	MTHFI	41412
13333	20051	29	WSR	54589
13334	20051	41	TFV2	14437
13335	20051	70	MHV	37502
13336	20051	106	MTHFW4	39212
13337	20051	94	TFQ2	45773
13338	20051	1	MHXY	54551
13339	20051	41	MHU3	14410
13340	20051	71	MHQ	38678
13341	20051	107	MTHFR	39228
13342	20051	98	TFQ3	42463
13343	20051	1	TFVW	54553
13344	20052	76	MHX	40806
13345	20052	115	MHL	52457
13346	20052	115	MHLM	52459
13347	20052	14	TFRU	54570
13348	20052	9	TFW	54573
13349	20052	27	WRU	54575
13350	20052	22	WSVX2	54584
13351	20052	42	MHY	14425
13352	20052	14	HMVW	54568
13353	20052	122	MHU	54571
13354	20052	28	TFV	54576
13355	20052	12	TFXY	54579
13356	20052	21	TR	54580
13357	20052	125	MHTFX	15078
13358	20052	126	MHTFX	15079
13359	20052	60	BMR1	33107
13360	20052	111	MTHFD	41375
13361	20052	103	MHV2	44695
13362	20052	91	MI1	67273
13363	20052	61	MHX1	15613
13364	20052	109	MHV	39215
13365	20052	119	TFV	39279
13366	20052	111	MTHFR	41467
13367	20052	94	MHU2	45759
13368	20052	5	TFU	54561
13369	20052	39	MHR-1	16052
13370	20052	107	MTHFV4	39184
13371	20052	81	TFR	41903
13372	20052	95	TFU1	45811
13373	20052	2	MHXY	54554
13374	20052	108	MTHFX3	39209
13375	20052	110	MTHFV	41353
13376	20052	102	MHQ	44152
13377	20052	2	TFRU	54555
13378	20053	87	MTWHFAB	47950
13379	20053	18	X2	54550
13380	20053	109	X3-2	39181
13381	20053	107	Z3-2	39170
13382	20053	70	X3	37501
13383	20053	109	X2	39179
13384	20061	114	WIJF	52455
13385	20061	114	WIJT1	52456
13386	20061	19	TFX	54565
13387	20061	20	MHXYM2	54582
13388	20061	113	TFZ1	15681
13389	20061	109	MHV	39271
13390	20061	114	WIJT2	52457
13391	20061	6	HMRU	54569
13392	20061	7	TFRU	54574
13393	20061	8	GS2	54603
13394	20061	37	TFX-2	13886
13395	20061	108	MTHFW1	39186
13396	20061	110	MTHFV	41356
13397	20061	93	TFR2	46327
13398	20061	3	MHRU	54557
13399	20061	39	MHX2	16069
13400	20061	111	MTHFV	41382
13401	20061	3	TFXY	54560
13402	20061	5	TFU	54561
13403	20061	29	WSR	54597
13404	20061	41	TFV2	14520
13405	20061	70	MHU	37501
13406	20061	106	MTHFW1	39189
13407	20061	99	TFR	42466
13408	20061	1	MHXY	54551
13409	20061	39	MHR3	16054
13410	20061	106	MTHFQ1	39150
13411	20061	83	MHW	41434
13412	20061	104	TFU	47970
13413	20061	1	TFVW	54553
13414	20061	43	MHV2	14551
13415	20061	106	MTHFX1	39197
13416	20061	76	TFU	40807
13417	20061	105	MHQ	43553
13418	20061	80	TFW	40252
13419	20061	100	MHY2	42478
13420	20061	1	WSRU	54599
13421	20061	41	MHR2	14493
13422	20061	106	MTHFY5	39299
13423	20061	94	TFW2	45853
13424	20061	93	MHV6	46380
13425	20061	41	TFU3	14518
13426	20061	106	MTHFX4	39200
13427	20061	82	MHY	41911
13428	20061	94	TFR3	45763
13429	20061	1	SWRU	54600
13430	20062	115	MHK	52449
13431	20062	115	MHKH	52450
13432	20062	22	W1	54595
13433	20062	36	MHQ-2	13851
13434	20062	42	TFU1	14589
13435	20062	119	TFQ	39314
13436	20062	3	MHXY	54559
13437	20062	24	MHW	54571
13438	20062	100	TFU1	42493
13439	20062	115	MHKM	52451
13440	20062	11	MHY	54565
13441	20062	14	TFVW	54567
13442	20062	9	FTXY	54570
13443	20062	12	MHVW	54573
13444	20062	63	TFX1	15613
13445	20062	108	MTHFR3	39259
13446	20062	111	MTHFY	41440
13447	20062	98	MHV2	42456
13448	20062	5	TFU	54562
13449	20062	119	TFR	39315
13450	20062	81	MHR	41900
13451	20062	100	MHW1	42487
13452	20062	93	TFX2	46335
13453	20062	7	WRUVX	54602
13454	20062	39	MHR1	16054
13455	20062	107	MTHFU5	39212
13456	20062	94	TFV2	45786
13457	20062	93	MHV5	46316
13458	20062	2	TFXY	54558
13459	20062	40	TFX1	14591
13460	20062	62	MHU2	15598
13461	20062	106	MTHFW-1	39184
13462	20062	100	MHX	42489
13463	20062	2	TFRU	54557
13464	20062	36	MHV-2	13859
13465	20062	40	TFV1	14476
13466	20062	47	Z	19918
13467	20062	107	MTHFW1	39201
13468	20062	2	MHRU	54552
13469	20062	41	TFX	14415
13470	20062	107	MTHFV6	39225
13471	20062	98	TFQ1	42460
13472	20062	93	TFR	46328
13473	20062	42	MHR	14417
13474	20062	106	MTHFQ-1	39197
13475	20062	100	MHW2	42488
13476	20062	95	TFV2	45812
13477	20062	107	MTHFQ6	39395
13478	20062	98	TFX1	42466
13479	20062	105	TFW	43616
13480	20063	18	X2	54550
13481	20063	111	Y3	41353
13482	20063	113	X1B	15527
13483	20063	107	Z1-A	39176
13484	20063	110	Y2	41350
13485	20063	110	Y3	41351
13486	20063	107	Z2-C	39175
13487	20063	36	X2-A	13855
13488	20063	127	X1A	15540
13489	20071	114	TFL	52463
13490	20071	114	TFLH	52464
13491	20071	8	TFX3	54561
13492	20071	6	TFRU	54562
13493	20071	19	TFV1	54567
13494	20071	7	MWVWXY	54583
13495	20071	27	WRU2	54585
13496	20071	21	MH	54594
13497	20071	55	MHU1	15574
13498	20071	17	TFU	54566
13499	20071	16	MHV1	54569
13500	20071	20	W2	54571
13501	20071	27	WRU1	54579
13502	20071	21	MQ	54593
13503	20071	112	TFW	70005
13504	20071	119	TFW	39298
13505	20071	109	MHQ	39388
13506	20071	6	TMRU	54563
13507	20071	8	TFX2	54560
13508	20071	17	MHU	54565
13509	20071	19	TFV2	54568
13510	20071	50	MHV1	15526
13511	20071	107	MTHFW2	39228
13512	20071	110	MTHFX	41361
13513	20071	3	TFRU	54576
13514	20071	108	MTHFU2	39237
13515	20071	110	MTHFQ1	41359
13516	20071	93	MHY2	46327
13517	20071	102	TFY	47991
13518	20071	3	MHVW	54574
13519	20071	71	TFU	38606
13520	20071	108	MTHFX	39248
13521	20071	93	TFV1	46370
13522	20071	104	MHV	47978
13523	20071	3	MHRU	54573
13524	20071	128	TFW	15019
13525	20071	108	MTHFU3	39243
13526	20071	104	TFR-1	44162
13527	20071	107	MTHFR2	39410
13528	20071	110	MTHFV	41360
13529	20071	93	TFU2	46331
13530	20071	1	HMXY	54552
13531	20071	73	MHR	38055
13532	20071	108	MTHFU7	39239
13533	20071	110	MTHFI	41357
13534	20071	1	FTXY	54555
13535	20071	63	TFR1	15635
13536	20071	71	TFW	38833
13537	20071	108	MTHFX3	39396
13538	20071	110	MTHFD	41356
13539	20071	71	TFR	38605
13540	20071	108	MTHFW1	39235
13541	20071	74	TFU	52910
13542	20071	43	TFU1	14447
13543	20071	106	MTHFX2	39212
13544	20071	76	TFY	40809
13545	20071	1	HMRU1	54550
13546	20071	43	TFX	14453
13547	20071	70	MHR	37500
13548	20071	106	MTHFW11	39187
13549	20071	100	MHU	42540
13550	20071	1	FTRU	54553
13551	20071	43	TFV	14449
13552	20071	106	MTHFX-6	39342
13553	20071	94	TFR4	45781
13554	20071	1	HMVW	54551
13555	20071	43	TFU2	14448
13556	20071	70	TFV	37508
13557	20071	100	MHR	42539
13558	20071	42	MHW	14433
13559	20071	106	MTHFR3	39218
13560	20071	94	MHU3	45758
13561	20071	74	TFV	52911
13562	20071	82	MHU	41900
13563	20071	93	TFW1	46332
13564	20072	115	MHLW2	52451
13565	20072	129	MHR	40251
13566	20072	115	MHLF	52452
13567	20072	11	MHZ	54570
13568	20072	12	HMVW	54577
13569	20072	28	MHU	54585
13570	20072	23	SRU	54606
13571	20072	36	TFY-1	13875
13572	20072	123	TFW	14462
13573	20072	70	MHW	37503
13574	20072	130	TFV	43031
13575	20072	102	TFX	47972
13576	20072	131	GTH	52932
13577	20072	22	W2	54581
13578	20072	82	TFU	42004
13579	20072	93	TFV5	46332
13580	20072	115	MHLW1	52450
13581	20072	11	MHX2	54569
13582	20072	12	MHVW	54578
13583	20072	23	TFW	54584
13584	20072	14	MHQR2	54609
13585	20072	66	MHX1	26506
13586	20072	130	TFW	43032
13587	20072	115	MHLT	52449
13588	20072	9	MHSUWX	54602
13589	20072	43	MHV3	14437
13590	20072	108	MTHFX	39197
13591	20072	110	MTHFW	41355
13592	20072	5	TFU2	54566
13593	20072	75	MHR	55102
13594	20072	109	TFW1	39211
13595	20072	119	TFY	39260
13596	20072	111	MTHFQ	41357
13597	20072	81	MHR	42009
13598	20072	98	MHX2	42460
13599	20072	70	MHX	37504
13600	20072	109	TFW2	39233
13601	20072	111	MTHFCR	41358
13602	20072	5	TFU	54564
13603	20072	89	MHW	62802
13604	20072	36	TFX-2	13872
13605	20072	109	MHW1	39294
13606	20072	111	MTHFGV	41360
13607	20072	95	MHX1	45814
13608	20072	5	MHU	54563
13609	20072	36	TFR-1	13864
13610	20072	70	TFU	37507
13611	20072	108	MTHFQ	39207
13612	20072	2	MHRU	54556
13613	20072	39	MHU4	16065
13614	20072	109	MHV	39206
13615	20072	119	TFX	39259
13616	20072	111	MTHFW	41361
13617	20072	74	MHX	52911
13618	20072	1	FTRU	54550
13619	20072	45	TFU	14470
13620	20072	109	MHR	39202
13621	20072	123	TFV	14459
13622	20072	119	TFX1	39383
13623	20072	63	MHR	15608
13624	20072	107	MTHFW4	39183
13625	20072	81	TFX	42012
13626	20072	105	MHV	43552
13627	20072	2	TFRU	54559
13628	20072	123	MHU2	14453
13629	20072	107	MTHFW6	39189
13630	20072	93	MHR4	46307
13631	20072	123	MHU	14451
13632	20072	37	TFQ-2	13887
13633	20072	106	MTHFX	39200
13634	20072	98	MHW2	42458
13635	20072	2	TFVW	54560
13636	20072	123	MHR	14450
13637	20072	107	MTHFW2	39171
13638	20072	98	MHU2	42452
13639	20072	40	MHR	14471
13640	20072	107	MTHFW3	39177
13641	20072	83	MHX	41425
13642	20072	103	MHU1	44677
13643	20072	2	TFXY	54561
13644	20072	39	TFX2	16133
13645	20072	107	MTHFV4	39182
13646	20072	98	MHX1	42459
13647	20072	40	TFW	14481
13648	20072	55	MHU	15575
13649	20072	107	MTHFR	39155
13650	20072	95	TFX1	45831
13651	20072	2	MHVW	54557
13652	20072	50	TFR1	15529
13653	20072	55	MHQ	15573
13654	20072	94	TFX1	45796
13655	20072	55	MHV1	15577
13656	20072	107	MTHFR4	39180
13657	20072	81	TFW	42011
13658	20072	100	MHW	42481
13659	20073	44	MTWHFBC	11651
13660	20073	18	X2	54550
13661	20073	127	X2-A	15518
13662	20073	111	MTWHFJ	41354
13663	20073	109	X1-1	39164
13664	20073	109	X3-1	39167
13665	20073	37	X3-A	13862
13666	20073	71	X5	38604
13667	20073	109	X3-2	39206
13668	20073	111	MTWHFQ	41352
13669	20073	107	Z1-4	39180
13670	20073	98	X2-1	42450
13671	20073	107	Z3-1	39186
13672	20073	107	Z1-6	39182
13673	20073	107	Z1-5	39181
13674	20081	132	THV-2	44102
13675	20081	17	THU	54562
13676	20081	6	FWRU	54571
13677	20081	16	WFV2	54578
13678	20081	20	MS2	54584
13679	20081	75	WFW	55101
13680	20081	100	THR1	42483
13681	20081	133	THW	52938
13682	20081	8	WFW	54568
13683	20081	21	MU	54580
13684	20081	20	MS3	54585
13685	20081	23	THV	54609
13686	20081	112	WFR	69950
13687	20081	47	W	19916
13688	20081	134	THX	43031
13689	20081	16	WFV	54577
13690	20081	20	MS4	54586
13691	20081	29	THW3	54602
13692	20081	108	TWHFR	39212
13693	20081	97	THY	43057
13694	20081	114	THQF2	52451
13695	20081	6	FWVW	54572
13696	20081	91	THD/HJ2	67252
13697	20081	70	THY	37505
13698	20081	114	THQW2	52450
13699	20081	7	THVW	54574
13700	20081	8	SUV	54599
13701	20081	62	THW3	15694
13702	20081	109	THV	39301
13703	20081	114	THQF1	52449
13704	20081	6	THRU	54573
13705	20081	112	WFV	69957
13706	20081	114	THQW1	52448
13707	20081	19	THW	54565
13708	20081	23	WFU	54610
13709	20081	108	TWHFU1	39219
13710	20081	111	TWHFGV	41386
13711	20081	99	THW2	42474
13712	20081	2	FWXY	54556
13713	20081	45	THR2	14480
13714	20081	135	THU	15105
13715	20081	19	THW2	54566
13716	20081	111	TWHFQ	41383
13717	20081	7	THXY2	54576
13718	20081	136	THV	13927
13719	20081	66	THU2	26503
13720	20081	108	TWHFX	39226
13721	20081	119	WFV	39347
13722	20081	110	TWHFW	41382
13723	20081	3	WFRU	54561
13724	20081	48	W	19919
13725	20081	71	WFX	38601
13726	20081	107	TWHFW	39209
13727	20081	1	THXY2	54551
13728	20081	89	A	62800
13729	20081	108	TWHFV1	39221
13730	20081	98	WFY2	42471
13731	20081	95	THQ2	45799
13732	20081	36	WFR-4	13872
13733	20081	103	THR-4	44662
13734	20081	3	THXY	54558
13735	20081	40	THY	14496
13736	20081	62	THU2	15618
13737	20081	93	THX1	46320
13738	20081	39	THX4	16137
13739	20081	108	TWHFW2	39229
13740	20081	110	TWHFQ	41378
13741	20081	36	THR-1	13851
13742	20081	91	WFB/WC	67292
13743	20081	49	WFX1	15543
13744	20081	127	THX2	15575
13745	20081	37	THU-1	13881
13746	20081	137	THR	15043
13747	20081	108	TWHFV	39217
13748	20081	39	WFV1	16136
13749	20081	108	TWHFW1	39225
13750	20081	100	THR2	42484
13751	20081	108	TWHFR4	39216
13752	20081	3	WFXY	54559
13753	20081	75	THW	55100
13754	20081	39	WFW2	16113
13755	20081	108	TWHFR2	39214
13756	20081	110	TWHFU	41380
13757	20081	95	THW1	45808
13758	20081	43	WFR1	14463
13759	20081	70	WFU	37507
13760	20081	106	TWHFW2	39167
13761	20081	100	WFX1	42494
13762	20081	1	HTRU	54554
13763	20081	37	THV-1	13882
13764	20081	106	TWHFR7	39277
13765	20081	76	WFU-1	40811
13766	20081	104	THU	44165
13767	20081	40	THU	14489
13768	20081	106	TWHFQ4	39174
13769	20081	95	THR1	45800
13770	20081	1	THXY	54550
13771	20081	43	THV2	14459
13772	20081	106	TWHFU3	39158
13773	20081	82	WFR	42007
13774	20081	94	THX2	45768
13775	20081	1	WFXY2	54553
13776	20081	43	WFX	14467
13777	20081	70	THU	37501
13778	20081	106	TWHFR9	39279
13779	20081	99	WFY	42478
13780	20081	40	WFX1	14501
13781	20081	106	TWHFW3	39168
13782	20081	84	THU	42004
13783	20081	93	WFU3	46330
13784	20081	45	THU	14481
13785	20081	100	THW	42485
13786	20081	43	WFR2	14464
13787	20081	41	WFW2	14434
13788	20081	93	THV3	46313
13789	20081	74	THX	52900
13790	20081	41	THX2	14418
13791	20081	106	TWHFV7	39258
13792	20081	76	THY	40808
13793	20081	94	WFR2	45776
13794	20081	1	WFXY	54552
13795	20081	41	THW2	14413
13796	20081	82	WFW	42008
13797	20081	94	THQ1	45750
13798	20081	41	WFU2	14427
13799	20081	81	WFR	42001
13800	20081	94	WFX1	45791
13801	20081	1	HTQR	54555
13802	20081	41	THR1	14402
13803	20081	106	TWHFW8	39270
13804	20081	94	THU5	45761
13805	20081	42	THW	14446
13806	20081	106	TWHFR2	39152
13807	20081	82	THU	42009
13808	20081	93	WFU1	46328
13809	20081	123	WFV	14477
13810	20081	82	THW	42010
13811	20081	41	WFX2	14438
13812	20081	70	THR	37500
13813	20081	106	TWHFQ	39170
13814	20081	94	THU3	45759
13815	20081	43	WFY	14468
13816	20081	106	TWHFW7	39260
13817	20081	83	WFU	41375
13818	20081	98	THR2	42451
13819	20081	39	THU3	16133
13820	20081	106	TWHFW6	39259
13821	20081	81	WFX	42003
13822	20081	93	THR3	46305
13823	20081	41	WFW4	14436
13824	20081	106	TWHFQ5	39280
13825	20081	41	THR2	14403
13826	20081	100	WFW	42493
13827	20081	42	THV1	14444
13828	20081	106	TWHFR3	39153
13829	20081	39	THY2	16078
13830	20081	43	THQ	14455
13831	20081	138	WFV	40824
13832	20081	105	WFQ1	43583
13833	20081	123	THX	14469
13834	20081	79	THV1	39703
13835	20081	50	WFU3	15547
13836	20081	55	THR2	15664
13837	20081	106	TWHFX2	39187
13838	20081	93	THV6	46345
13839	20081	1	MUVWX	54597
13840	20081	43	THW3	14600
13841	20081	41	WFX5	14607
13842	20081	106	TWHFU2	39157
13843	20081	94	THX3	45769
13844	20081	37	WFY-2	13931
13845	20081	50	THV1	15528
13846	20081	93	THY4	46325
13847	20082	123	THX	14474
13848	20082	40	THW1	14505
13849	20082	119	THR	39281
13850	20082	111	S3L/R4	41472
13851	20082	89	WFA	62804
13852	20082	45	WFV	14496
13853	20082	138	WFW	40816
13854	20082	14	THRU	54566
13855	20082	9	THVW	54570
13856	20082	22	S2	54581
13857	20082	131	GM	56235
13858	20082	113	WFU2	15707
13859	20082	74	THW	52917
13860	20082	11	WFV	54565
13861	20082	21	HV	54579
13862	20082	22	S1	54580
13863	20082	60	MR2A	33109
13864	20082	84	THW	42007
13865	20082	139	THWFY	43021
13866	20082	140	THWFY	43022
13867	20082	22	S4	54583
13868	20082	89	THK	62800
13869	20082	109	WFU2	39310
13870	20082	5	THU2	54561
13871	20082	14	THVW	54567
13872	20082	141	WFIJ	67206
13873	20082	123	THQ1	14536
13874	20082	115	WFLT	52430
13875	20082	11	WFW	54562
13876	20082	9	THYZ	54571
13877	20082	12	WFUV	54575
13878	20082	135	WFU2	15154
13879	20082	94	THV4	45765
13880	20082	14	THXY	54568
13881	20082	40	THV1	14503
13882	20082	81	THR	42008
13883	20082	115	WFLW	52431
13884	20082	5	THU	54559
13885	20082	11	WFX	54563
13886	20082	14	WFVW	54569
13887	20082	41	THV2	14406
13888	20082	123	WFV1	14480
13889	20082	119	THU	39233
13890	20082	109	WFU5	39321
13891	20082	81	WFW	42010
13892	20082	3	HTQR	54609
13893	20082	115	WFLF	52433
13894	20082	39	WFU4	16078
13895	20082	12	WFWX	54576
13896	20082	30	SWX	54588
13897	20082	112	TBA	70009
13898	20082	5	WFU	54560
13899	20082	89	WFV	62829
13900	20082	42	THU1	14429
13901	20082	109	THR1	39274
13902	20082	111	S4L/R1	41386
13903	20082	100	THW2	42475
13904	20082	75	WFW	55100
13905	20082	43	THV1	14450
13906	20082	108	TWHFU1	39213
13907	20082	110	S2L/R4	41439
13908	20082	94	THW3	45768
13909	20082	2	WFXY	54555
13910	20082	111	S5L/R5	41481
13911	20082	82	THY	42003
13912	20082	94	THV2	45763
13913	20082	119	THV	39271
13914	20082	95	THX3	45817
13915	20082	48	X	19904
13916	20082	108	TWHFW	39211
13917	20082	111	S2L/R4	41468
13918	20082	87	THY	47957
13919	20082	35	THX1	15506
13920	20082	109	THW1	39221
13921	20082	111	S1L/R5	41465
13922	20082	103	WFR-2	44731
13923	20082	5	WFU2	54618
13924	20082	37	THR-3	13884
13925	20082	119	THQ	39280
13926	20082	110	S5L/R1	41392
13927	20082	94	THX3	45771
13928	20082	123	WFX	14484
13929	20082	111	S1L/R1	41383
13930	20082	24	THR	54585
13931	20082	109	WFR2	39309
13932	20082	111	S5L/R1	41387
13933	20082	95	WFV2	45826
13934	20082	123	WFV3	14482
13935	20082	108	TWHFR	39212
13936	20082	45	WFQ	14491
13937	20082	109	THQ1	39378
13938	20082	111	S5L/R3	41479
13939	20082	93	WFU2	46319
13940	20082	36	THV-2	13859
13941	20082	107	TWHFU7	39326
13942	20082	98	THR3	42452
13943	20082	103	WFR-4	44733
13944	20082	1	FWVW	54614
13945	20082	73	WFW-1	38078
13946	20082	111	S4L/R3	41475
13947	20082	89	TNQ	62803
13948	20082	41	WFR	14415
13949	20082	49	THR1	15522
13950	20082	107	TWHFW2	39169
13951	20082	94	WFU1	45782
13952	20082	1	HTXY	54550
13953	20082	39	WFV3	16081
13954	20082	107	TWHFQ4	39268
13955	20082	81	WFX	42011
13956	20082	98	WFU2	42464
13957	20082	2	HTVW	54552
13958	20082	142	WFV	14556
13959	20082	107	TWHFQ1	39158
13960	20082	82	THU	42000
13961	20082	100	THR2	42472
13962	20082	2	WFRU	54554
13963	20082	39	THQ1	16050
13964	20082	107	TWHFU3	39173
13965	20082	100	WFQ2	42477
13966	20082	42	THY	14435
13967	20082	73	WFV	38059
13968	20082	107	TWHFQ5	39345
13969	20082	94	WFX1	45795
13970	20082	41	THX2	14411
13971	20082	123	WFR	14477
13972	20082	98	WFU1	42463
13973	20082	2	THRU	54556
13974	20082	61	THW1	15620
13975	20082	107	TWHFV3	39174
13976	20082	76	WFU	40850
13977	20082	2	HTXY	54557
13978	20082	41	WFU	14416
13979	20082	107	TWHFW	39155
13980	20082	81	WFR	42009
13981	20082	93	WFX	46327
13982	20082	36	WFU-1	13867
13983	20082	93	WFV2	46321
13984	20082	143	WFR/WFRUV2	38632
13985	20082	104	MUV	44132
13986	20082	94	THU2	45758
13987	20082	75	WFX	55101
13988	20082	42	THW2	14433
13989	20082	100	WFR2	42479
13990	20082	123	THR	14537
13991	20082	106	TWHFQ1	39232
13992	20082	70	THU	37501
13993	20082	107	TWHFR4	39177
13994	20082	100	WFW	42481
13995	20082	40	WFX1	14513
13996	20082	76	THX	40804
13997	20082	55	WFR1	15580
13998	20082	71	THX	38600
13999	20082	107	TWHFU6	39325
14000	20082	103	WFV-2	44736
14001	20082	39	WFU2	16076
14002	20082	107	TWHFW4	39179
14003	20082	2	THXY	54553
14004	20082	123	WFW	14483
14005	20082	107	TWHFQ3	39171
14006	20082	80	THU	40251
14007	20082	41	THV3	14407
14008	20082	98	WFV2	42466
14009	20082	93	THU1	46303
14010	20082	43	WFR	14457
14011	20082	107	TWHFU5	39181
14012	20082	93	THQ1	46322
14013	20082	123	THR1	14465
14014	20082	70	WFU	37507
14015	20082	100	WFX	42482
14016	20082	105	THV	43563
14017	20082	40	THU2	14515
14018	20082	106	TWHFX	39186
14019	20082	82	WFV	42004
14020	20082	37	WFR-2	13894
14021	20082	100	WFU	42480
14022	20082	42	WFX1	14443
14023	20082	107	TWHFU2	39167
14024	20082	98	WFR1	42461
14025	20082	107	TWHFR3	39172
14026	20082	42	THR1	14427
14027	20082	100	WFR1	42478
14028	20082	39	WFU3	16077
14029	20082	107	TWHFR2	39166
14030	20082	94	WFW1	45791
14031	20082	123	THU	14466
14032	20082	107	TWHFR	39152
14033	20082	76	WFW	40808
14034	20082	41	THW	14408
14035	20082	104	THX	44130
14036	20082	41	WFV	14417
14037	20082	43	WFU	14459
14038	20082	105	THY	43554
14039	20082	62	THX1	15624
14040	20082	71	WFX	38601
14041	20082	107	TWHFW3	39175
14042	20082	105	WFR	43552
14043	20082	94	THR4	45755
14044	20082	100	WFQ1	42476
14045	20082	93	WFV1	46320
14046	20082	36	WFX-2	13879
14047	20082	106	TWHFU	39372
14048	20082	94	THX1	45769
14049	20082	95	THW2	45813
14050	20083	70	X2	37500
14051	20083	113	X4-A	15534
14052	20083	70	X5	37503
14053	20083	71	X2	38601
14054	20083	43	X5	14420
14055	20083	105	X-3C	43554
14056	20083	98	X5-1	42456
14057	20083	130	X2-1	43011
14058	20083	133	X4	52901
14059	20083	70	X4	37502
14060	20083	109	X3	39181
14061	20083	111	MTWHFJ	41366
14062	20083	109	X2	39180
14063	20083	108	Z2-6	39201
14064	20083	108	Z1-6	39197
14065	20083	109	X4	39206
14066	20083	40	X2	14432
14067	20083	109	X4-1	39210
14068	20083	111	MTWHFQ	41364
14069	20083	108	Z2-2	39175
14070	20083	107	Z1-3	39164
14071	20083	37	X4	13861
14072	20083	93	X3-2	46302
14073	20083	110	MTWHFE	41362
14074	20083	108	Z3-5	39204
14075	20083	107	Z2	39165
14076	20083	71	X3	38602
14077	20083	93	X5-1	46305
14078	20083	108	Z3-2	39178
14079	20083	110	MTWHFJ	41363
14080	20083	108	Z1-1	39170
14081	20083	36	X5	13859
14082	20083	130	X1	43000
14083	20083	107	Z1	39161
14084	20083	95	X2	45753
14085	20083	43	X3-B	14419
14086	20083	107	Z3	39168
14087	20083	108	Z3	39176
14088	20083	108	Z3-1	39177
14089	20083	107	Z2-1	39166
14090	20083	108	Z2-4	39199
14091	20091	24	THX	54565
14092	20091	8	WFV	54575
14093	20091	6	THVW	54580
14094	20091	7	FWXY	54583
14095	20091	112	WFW	69988
14096	20091	143	WFQ/WFUV1	38617
14097	20091	63	WFW1	15604
14098	20091	132	THU1	44103
14099	20091	17	THV	54567
14100	20091	19	THW	54571
14101	20091	16	WFX	54587
14102	20091	20	S6	54625
14103	20091	144	TWHFX	43036
14104	20091	145	TWHFX	43037
14105	20091	71	THW	38717
14106	20091	114	THQ	52479
14107	20091	114	THQS2	52483
14108	20091	7	THXY	54585
14109	20091	21	MR	54589
14110	20091	112	WFY	69990
14111	20091	17	THU	54568
14112	20091	19	THX	54572
14113	20091	23	MXY	54592
14114	20091	20	S7	54629
14115	20091	146	THX	53508
14116	20091	17	WFU	54569
14117	20091	19	THR	54570
14118	20091	7	HTVW	54582
14119	20091	16	WFV	54586
14120	20091	37	WFU-1	13892
14121	20091	133	THU	52904
14122	20091	23	WFX	54591
14123	20091	45	WFV1	14606
14124	20091	147	TWHFR	43056
14125	20091	148	TWHFR	43057
14126	20091	2	THVW	54559
14127	20091	19	WFU	54573
14128	20091	43	THW1	14544
14129	20091	40	WFX3	14637
14130	20091	114	THQT	52480
14131	20091	5	WFR	54564
14132	20091	6	FWVW	54579
14133	20091	149	THR	14968
14134	20091	111	S3L/R3	41398
14135	20091	150	WFV	43061
14136	20091	114	THQS1	52482
14137	20091	17	THW	54566
14138	20091	8	THV	54574
14139	20091	98	WFR2	42458
14140	20091	6	THXY	54581
14141	20091	112	WFX	69989
14142	20091	73	THW	38071
14143	20091	109	WFR	39303
14144	20091	119	WFY	39310
14145	20091	3	WFVW	54562
14146	20091	73	WFU	38063
14147	20091	114	THQH	52481
14148	20091	1	HTXY	54552
14149	20091	75	WFV	55104
14150	20091	87	THU	47951
14151	20091	8	SWX	54577
14152	20091	88	WFX	62814
14153	20091	57	WFU1	15575
14154	20091	111	S4L/R2	41402
14155	20091	6	HTXY	54578
14156	20091	7	WFWX	54584
14157	20091	93	THW2	46362
14158	20091	75	WFW	55100
14159	20091	109	WFQ	39302
14160	20091	111	S5L/R3	41408
14161	20091	3	THRU	54560
14162	20091	8	THY	54576
14163	20091	111	S1L/R5	41390
14164	20091	88	THV	62807
14165	20091	50	WFU1	15533
14166	20091	39	THU1	16075
14167	20091	151	WFX	39266
14168	20091	123	THQ	14562
14169	20091	50	THU3	15523
14170	20091	109	WFV	39297
14171	20091	110	S2L/R3	41358
14172	20091	43	WFW2	14556
14173	20091	35	THQ1	15500
14174	20091	57	THR1	15574
14175	20091	107	TWHFV	39388
14176	20091	110	S6L/R2	41381
14177	20091	1	WFRU2	54616
14178	20091	123	THU2	14565
14179	20091	39	THV3	16119
14180	20091	107	TWHFY	39272
14181	20091	110	S5L/R1	41374
14182	20091	63	WFR1	15601
14183	20091	108	TWHFU3	39278
14184	20091	110	S1L/R4	41353
14185	20091	123	THV3	14568
14186	20091	108	TWHFR4	39339
14187	20091	110	S3L/R1	41362
14188	20091	100	THW	42471
14189	20091	43	THW2	14545
14190	20091	108	TWHFQ2	39371
14191	20091	110	S6L/R6	41385
14192	20091	95	THV3	45805
14193	20091	123	THV2	14567
14194	20091	108	TWHFQ3	39372
14195	20091	81	WFR	42001
14196	20091	3	WFXY	54563
14197	20091	43	THR1	14635
14198	20091	35	WFQ1	15504
14199	20091	110	S6L/R4	41383
14200	20091	41	THX5	14502
14201	20091	108	TWHFR1	39277
14202	20091	110	S3L/R4	41365
14203	20091	97	THV	43059
14204	20091	108	TWHFR	39275
14205	20091	110	S3L/R3	41364
14206	20091	98	WFX	42525
14207	20091	3	THXY	54561
14208	20091	63	THR1	15594
14209	20091	107	TWHFX	39271
14210	20091	111	S3L/R2	41397
14211	20091	43	THQ	14539
14212	20091	108	TWHFU	39273
14213	20091	110	S2L/R4	41359
14214	20091	99	THV	42461
14215	20091	127	THY1	15552
14216	20091	110	S6L/R5	41384
14217	20091	2	THRU	54628
14218	20091	127	WFR1	15554
14219	20091	93	THV3	46307
14220	20091	50	THV2	15558
14221	20091	110	S1L/R5	41354
14222	20091	36	WFV-3	13865
14223	20091	108	TWHFQ1	39338
14224	20091	110	S5L/R6	41379
14225	20091	93	WFX2	46357
14226	20091	108	TWHFU2	39276
14227	20091	110	S4L/R1	41368
14228	20091	81	WFX	42003
14229	20091	94	WFY3	45798
14230	20091	41	THX6	14638
14231	20091	50	WFV2	15536
14232	20091	109	WFW	39298
14233	20091	93	THU4	46305
14234	20091	64	THQ1	15666
14235	20091	50	WFV1	15535
14236	20091	57	WFX1	15577
14237	20091	110	S3L/R5	41366
14238	20091	43	WFW4	14558
14239	20091	108	TWHFR5	39340
14240	20091	95	THW1	45806
14241	20091	62	THR1	15665
14242	20091	70	THY	37505
14243	20091	108	TWHFU4	39287
14244	20091	36	WFY-1	13878
14245	20091	107	TWHFR1	39383
14246	20091	110	S6L/R3	41382
14247	20091	99	WFU	42463
14248	20091	95	WFR1	45813
14249	20091	152	NONE	20509
14250	20091	110	S4L/R4	41371
14251	20091	97	WFU	43001
14252	20091	127	THV2	15561
14253	20091	108	TWHFQ	39285
14254	20091	111	S2L/R1	41391
14255	20091	89	WFX	62805
14256	20091	37	WFW-1	13896
14257	20091	63	THV1	15596
14258	20091	108	TWHFR6	39347
14259	20091	108	TWHFR2	39284
14260	20091	94	WFX2	45793
14261	20091	65	THV1	15616
14262	20091	107	TWHFR	39270
14263	20091	110	S5L/R4	41377
14264	20091	134	THU	43031
14265	20091	37	THW-1	13883
14266	20091	95	WFW1	45820
14267	20091	37	WFY-1	13898
14268	20091	39	THW1	16091
14269	20091	110	S3L/R2	41363
14270	20091	36	WFW-4	13864
14271	20091	57	WFV1	15576
14272	20091	94	THV4	45763
14273	20091	39	THV1	16090
14274	20091	109	THX	39300
14275	20091	23	WFY	54550
14276	20091	36	WFR-2	13868
14277	20091	110	S4L/R3	41370
14278	20091	95	THW2	45807
14279	20091	36	THU-3	13938
14280	20091	109	WFU	39385
14281	20091	110	S5L/R5	41378
14282	20091	74	THV	52915
14283	20091	62	WFR1	15668
14284	20091	107	TWHFU	39378
14285	20091	36	WFX-4	13939
14286	20091	50	THW1	15525
14287	20091	111	S1L/R3	41388
14288	20091	50	THX3	15638
14289	20091	109	THY	39296
14290	20091	95	WFY1	45824
14291	20091	36	THV-1	13856
14292	20091	123	THW	14571
14293	20091	39	THX2	16082
14294	20091	110	S2L/R1	41356
14295	20091	108	TWHFU1	39274
14296	20091	110	S2L/R5	41360
14297	20091	87	THQ1	47992
14298	20091	89	THZ	62833
14299	20091	81	WFW	42002
14300	20091	43	THX2	14547
14301	20091	106	TWHFW5	39209
14302	20091	94	WFQ2	45774
14303	20091	1	HTRU	54554
14304	20091	41	THX2	14499
14305	20091	83	WFU	41502
14306	20091	43	THR	14540
14307	20091	70	THU	37501
14308	20091	106	TWHFW4	39174
14309	20091	100	WFX	42475
14310	20091	1	FWRU	54553
14311	20091	41	THV2	14490
14312	20091	106	TWHFQ1	39151
14313	20091	82	THU	42006
14314	20091	1	WFRU	54557
14315	20091	41	WFV2	14513
14316	20091	106	TWHFU3	39163
14317	20091	83	WFW	41503
14318	20091	100	THR2	42469
14319	20091	1	HTVW	54551
14320	20091	41	WFX2	14521
14321	20091	106	TWHFW7	39248
14322	20091	81	THR	42000
14323	20091	93	THU2	46303
14324	20091	41	WFX1	14520
14325	20091	106	TWHFU2	39162
14326	20091	94	THW1	45765
14327	20091	1	FWVW	54555
14328	20091	106	TWHFQ3	39153
14329	20091	82	WFW	42005
14330	20091	100	THR1	42468
14331	20091	42	THW	14530
14332	20091	106	TWHFV2	39167
14333	20091	82	THR	42004
14334	20091	93	WFR2	46317
14335	20091	1	FWXY	54556
14336	20091	70	THR	37500
14337	20091	99	THW	42462
14338	20091	41	WFX3	14522
14339	20091	70	WFW	37509
14340	20091	93	THR	46369
14341	20091	40	THX1	14585
14342	20091	87	WFR	47957
14343	20091	39	THR2	16099
14344	20091	70	WFV	37508
14345	20091	88	WFR	62809
14346	20091	106	TWHFQ5	39249
14347	20091	83	WFX	41504
14348	20091	100	WFR	42473
14349	20091	43	THV	14543
14350	20091	106	TWHFU1	39161
14351	20091	94	WFW2	45790
14352	20091	40	WFX1	14594
14353	20091	106	TWHFV4	39169
14354	20091	76	WFU1	40810
14355	20091	91	WFB/WI2	67207
14356	20091	39	THX3	16054
14357	20091	94	WFX4	45795
14358	20091	42	THY	14531
14359	20091	106	TWHFV6	39242
14360	20091	94	WFX1	45792
14361	20091	40	WFY	14596
14362	20091	100	WFQ1	42472
14363	20091	123	WFW	14578
14364	20091	100	THR3	42515
14365	20091	39	WFV2	16114
14366	20091	100	WFW	42474
14367	20091	93	THV1	46306
14368	20091	123	WFV3	14577
14369	20091	76	WFX	40811
14370	20091	94	WFQ3	45775
14371	20091	40	THX2	14586
14372	20091	93	WFY1	46331
14373	20091	43	WFW1	14555
14374	20091	93	WFY2	46320
14375	20091	41	THU4	14488
14376	20091	106	TWHFW6	39243
14377	20091	94	THQ1	45750
14378	20091	153	WFU	39192
14379	20091	105	WFV1	43584
14380	20091	44	WFY	11656
14381	20091	40	THY	14588
14382	20091	41	THQ	14483
14383	20091	106	TWHFX7	39254
14384	20091	104	THV1	45853
14385	20091	94	THX2	45769
14386	20091	41	THW5	14497
14387	20091	106	TWHFQ	39150
14388	20091	39	THQ1	16098
14389	20091	93	THX3	46314
14390	20091	40	WFV2	14592
14391	20091	100	WFQ2	42522
14392	20091	60	MR2B	33108
14393	20091	70	WFU	37507
14394	20091	102	THX	44146
14395	20091	41	THX3	14500
14396	20091	94	WFX3	45794
14397	20091	42	WFY1	14536
14398	20091	93	WFU1	46319
14399	20091	106	TWHFY1	39180
14400	20091	94	THU1	45756
14401	20091	42	WFY2	14537
14402	20091	42	THR	14525
14403	20091	106	TWHFX6	39244
14404	20091	98	WFV	42460
14405	20091	76	THX1	40806
14406	20091	88	WFU	62810
14407	20091	123	THR	14563
14408	20091	99	WFV	42464
14409	20091	94	WFV4	45788
14410	20091	106	TWHFY2	39203
14411	20091	43	WFX2	14560
14412	20091	70	WFR	37506
14413	20091	100	THQ1	42466
14414	20091	94	WFV3	45787
14415	20091	123	THU3	14611
14416	20091	106	TWHFY3	39204
14417	20092	154	THY	39298
14418	20092	118	THW	39332
14419	20092	11	WFV	54554
14420	20092	9	WFRU	54591
14421	20092	19	WFW	54631
14422	20092	23	MWX	54637
14423	20092	113	THY1	15663
14424	20092	39	WFU2	16144
14425	20092	155	THW	40256
14426	20092	84	WFV	42006
14427	20092	115	THX	52450
14428	20092	115	THXH	52453
14429	20092	9	WFXY	54566
14430	20092	22	SCVMIG	54602
14431	20092	81	WFW	42002
14432	20092	12	THVW	54575
14433	20092	27	MBD	54625
14434	20092	156	WFQ	15001
14435	20092	50	THU1	15531
14436	20092	115	THXW	52452
14437	20092	131	WFW	56273
14438	20092	39	THV	16073
14439	20092	59	MR11A	33100
14440	20092	74	THW	54000
14441	20092	12	FWVW	54572
14442	20092	157	THX	55673
14443	20092	94	THU1	45755
14444	20092	24	THW	54567
14445	20092	11	WFU	54578
14446	20092	35	THR1	15502
14447	20092	3	THVW	54551
14448	20092	11	WFW	54555
14449	20092	23	WFX	54573
14450	20092	5	WFU	54589
14451	20092	29	THQ	54628
14452	20092	137	THX	15026
14453	20092	14	WFVW	54560
14454	20092	11	WFR	54577
14455	20092	75	THY	55115
14456	20092	41	THY1	14408
14457	20092	113	WFV1	15650
14458	20092	79	THV2	39704
14459	20092	83	THU	41483
14460	20092	21	HR	54570
14461	20092	23	THY	54571
14462	20092	22	MACL	54600
14463	20092	43	THV1	14441
14464	20092	115	THXF	52454
14465	20092	123	THR1	14470
14466	20092	45	SDEF	14501
14467	20092	109	THW	39239
14468	20092	81	WFX	42003
14469	20092	23	WFY1	54638
14470	20092	42	WFX	14435
14471	20092	45	THV	14492
14472	20092	158	THW	16135
14473	20092	2	THRU	54579
14474	20092	37	WFW-2	13928
14475	20092	12	HTVW	54563
14476	20092	9	HTRU	54568
14477	20092	42	THV1	14615
14478	20092	94	THX1	45765
14479	20092	14	WFXY	54561
14480	20092	23	MVW	54634
14481	20092	47	Y	19902
14482	20092	109	THW1	39343
14483	20092	111	S3L/R1	41398
14484	20092	94	THV2	45760
14485	20092	26	THX	54569
14486	20092	125	THY	15057
14487	20092	159	WFW	16126
14488	20092	5	THX	54587
14489	20092	23	WFENTREP	54635
14490	20092	91	WFB/WK2	67256
14491	20092	109	THV1	39245
14492	20092	111	S1L/R5	41392
14493	20092	135	THW	14956
14494	20092	97	WFX	43062
14495	20092	93	THQ2	46301
14496	20092	102	THX	44162
14497	20092	14	WFRU	54559
14498	20092	81	THR	42000
14499	20092	14	THXY	54562
14500	20092	98	THY1	42456
14501	20092	35	WFV1	15508
14502	20092	119	WFX	39214
14503	20092	109	WFU2	39334
14504	20092	45	WFU	14495
14505	20092	115	THXT	52451
14506	20092	9	WFVW	54592
14507	20092	43	WFQ	14452
14508	20092	107	TWHFV6	39335
14509	20092	103	THR-1	44670
14510	20092	2	HTXY	54586
14511	20092	108	TWHFX	39230
14512	20092	111	S5L/R2	41409
14513	20092	97	WFR	43002
14514	20092	93	WFV3	46327
14515	20092	109	THU1	39333
14516	20092	111	S2L/R4	41396
14517	20092	23	WFY	54633
14518	20092	36	WFU-3	13878
14519	20092	111	S1L/R4	41389
14520	20092	100	THR1	42472
14521	20092	93	THY1	46319
14522	20092	2	HTVW	54580
14523	20092	50	WFW1	15543
14524	20092	111	S2L/R1	41393
14525	20092	94	THV1	45759
14526	20092	55	WFW1	15573
14527	20092	70	THR	37500
14528	20092	109	THQ	39248
14529	20092	111	S3L/R5	41402
14530	20092	108	TWHFV	39233
14531	20092	111	S5L/R5	41412
14532	20092	82	WFR	42009
14533	20092	2	FWXY	54582
14534	20092	109	WFU1	39253
14535	20092	93	THV5	46307
14536	20092	87	WFY	47951
14537	20092	5	THU	54590
14538	20092	108	TWHFR	39232
14539	20092	95	THY1	45805
14540	20092	108	TWHFX1	39235
14541	20092	94	WFR1	45774
14542	20092	41	THV1	14402
14543	20092	109	WFV1	39255
14544	20092	100	WFW	42478
14545	20092	93	THU2	46305
14546	20092	36	WFW-1	13880
14547	20092	61	THX1	15597
14548	20092	107	TWHFU7	39338
14549	20092	5	THY	54588
14550	20092	43	THW1	14446
14551	20092	60	MR1	33108
14552	20092	109	THX	39240
14553	20092	111	S2L/R3	41395
14554	20092	43	WFU2	14454
14555	20092	123	WFV1	14484
14556	20092	109	THV	39238
14557	20092	2	THXY	54584
14558	20092	63	THQ1	15608
14559	20092	108	TWHFW1	39234
14560	20092	123	THV2	14473
14561	20092	55	THW1	15570
14562	20092	118	THR	39323
14563	20092	109	THU2	39340
14564	20092	94	WFY1	45790
14565	20092	37	WFV-2	13926
14566	20092	73	WFR	38050
14567	20092	100	THR3	42523
14568	20092	108	TWHFU	39231
14569	20092	94	WFV2	45782
14570	20092	50	WFX2	15535
14571	20092	109	THR1	39326
14572	20092	94	THU2	45756
14573	20092	107	TWHFV4	39204
14574	20092	110	S5L/R6	41379
14575	20092	1	FWXY	54553
14576	20092	109	WFU	39244
14577	20092	93	THY2	46320
14578	20092	70	THW	37503
14579	20092	111	S2L/R5	41397
14580	20092	42	WFR2	14429
14581	20092	111	S4L/R5	41407
14582	20092	160	THU	42480
14583	20092	36	THY-2	13870
14584	20092	35	WFX1	15544
14585	20092	107	TWHFU4	39203
14586	20092	1	FWVW	54565
14587	20092	42	WFU1	14430
14588	20092	109	THV2	39254
14589	20092	74	THY	54001
14590	20092	50	THV4	15656
14591	20092	94	WFV3	45783
14592	20092	109	WFW	39257
14593	20092	111	S2L/R2	41394
14594	20092	95	THX1	45803
14595	20092	66	THX1	26506
14596	20092	51	FWX	29251
14597	20092	95	WFR1	45808
14598	20092	40	THU2	14503
14599	20092	110	S6L/R3	41382
14600	20092	36	THR-2	13852
14601	20092	43	THU1	14438
14602	20092	111	S5L/R3	41410
14603	20092	93	WFX2	46330
14604	20092	35	WFR1	15506
14605	20092	70	THV	37502
14606	20092	109	THR3	39339
14607	20092	111	S3L/R4	41401
14608	20092	50	WFR1	15539
14609	20092	109	THR	39250
14610	20092	93	WFV1	46325
14611	20092	50	THV2	15534
14612	20092	111	S3L/R2	41399
14613	20092	123	THX1	14478
14614	20092	109	THR2	39331
14615	20092	111	S5L/R1	41408
14616	20092	93	WFX1	46332
14617	20092	50	WFX1	15545
14618	20092	109	WFR	39251
14619	20092	94	THR2	45753
14620	20092	94	THQ1	45750
14621	20092	35	THV1	15504
14622	20092	70	THY	37505
14623	20092	110	S6L/R2	41381
14624	20092	75	WFW	55101
14625	20092	37	THV-1	13917
14626	20092	95	WFV2	45812
14627	20092	93	THU3	46306
14628	20092	104	WFW	47957
14629	20092	39	THR	16069
14630	20092	70	THU	37501
14631	20092	138	WFU	40812
14632	20092	111	S4L/R4	41406
14633	20092	161	FAB2	41451
14634	20092	70	WFV	37508
14635	20092	111	S5L/R4	41411
14636	20092	87	WFR	47963
14637	20092	43	WFV2	14457
14638	20092	42	THX2	14425
14639	20092	45	WFX	14500
14640	20092	107	TWHFW	39180
14641	20092	100	WFQ1	42475
14642	20092	2	HTRU1	54557
14643	20092	36	WFV-2	13873
14644	20092	107	TWHFW3	39201
14645	20092	98	THY3	42458
14646	20092	2	HTRU2	54550
14647	20092	36	THX-2	13867
14648	20092	41	THU1	14606
14649	20092	107	TWHFW2	39194
14650	20092	93	WFU3	46324
14651	20092	123	WFV2	14485
14652	20092	107	TWHFQ1	39183
14653	20092	105	WFU	43562
14654	20092	107	TWHFV3	39200
14655	20092	94	THW2	45764
14656	20092	93	WFR1	46321
14657	20092	40	WFR	14511
14658	20092	70	WFU	37507
14659	20092	87	WFX	47970
14660	20092	43	WFX	14466
14661	20092	82	THR	42008
14662	20092	95	WFV1	45811
14663	20092	1	THVW	54556
14664	20092	123	WFW1	14487
14665	20092	48	X	19904
14666	20092	39	THQ	16094
14667	20092	79	THW2	39705
14668	20092	94	WFW2	45785
14669	20092	41	WFX1	14417
14670	20092	36	WFU-2	13877
14671	20092	41	WFR	14411
14672	20092	100	WFQ2	42476
14673	20092	107	TWHFQ3	39196
14674	20092	98	WFV2	42461
14675	20092	123	WFR	14481
14676	20092	40	WFU1	14512
14677	20092	106	TWHFW	39174
14678	20092	107	TWHFU2	39192
14679	20092	98	WFV1	42460
14680	20092	41	THX2	14406
14681	20092	81	WFR	42001
14682	20092	39	WFX4	16105
14683	20092	70	WFW	37509
14684	20092	107	TWHFU1	39185
14685	20092	39	THX1	16053
14686	20092	106	TWHFV1	39211
14687	20092	94	WFR3	45776
14688	20092	158	THX	16136
14689	20092	107	TWHFU	39178
14690	20092	98	THV1	42453
14691	20092	99	WFW	42467
14692	20092	43	WFV4	14459
14693	20092	107	TWHFQ4	39209
14694	20092	93	WFU1	46322
14695	20092	39	WFV1	16104
14696	20092	73	WFU	38065
14697	20092	107	TWHFR	39177
14698	20092	93	WFW1	46328
14699	20092	70	WFX	37510
14700	20092	89	WFR	62802
14701	20092	42	WFU2	14431
14702	20092	107	TWHFR2	39191
14703	20092	100	THQ2	42470
14704	20092	39	THW	16074
14705	20092	107	TWHFV1	39186
14706	20092	41	WFU1	14412
14707	20092	107	TWHFR4	39202
14708	20092	98	THU	42452
14709	20092	63	WFV1	15617
14710	20092	39	WFR1	16097
14711	20092	107	TWHFU3	39198
14712	20092	41	WFW1	14415
14713	20092	93	THW2	46316
14714	20092	70	THX	37504
14715	20092	39	WFW	16121
14716	20092	106	TWHFR	39171
14717	20092	83	THX	41485
14718	20092	63	THW3	15664
14719	20092	94	WFU3	45780
14720	20092	79	THV1	39703
14721	20092	83	WFX	41488
14722	20092	93	THW3	46313
14723	20092	41	THX3	14407
14724	20092	105	THY	43560
14725	20092	42	THX1	14424
14726	20092	95	WFU1	45809
14727	20092	83	THW	41484
14728	20092	94	WFR4	45777
14729	20092	107	TWHFW1	39187
14730	20092	99	WFU	42464
14731	20092	71	THX	38794
14732	20092	94	WFX3	45789
14733	20092	100	THQ1	42469
14734	20092	46	WFR	14951
14735	20092	107	TWHFV2	39193
14736	20092	95	WFQ1	45807
14737	20092	93	THU1	46304
14738	20092	43	WFU3	14455
14739	20092	99	WFX	42468
14740	20092	76	WFY	40806
14741	20092	93	THX1	46317
14742	20092	123	WFU1	14482
14743	20092	75	WFV	55100
14744	20092	61	WFU1	15599
14745	20092	107	TWHFW4	39321
14746	20092	93	THV4	46312
14747	20092	57	WFR1	15588
14748	20092	63	WFY1	15620
14749	20092	99	THW	42463
14750	20092	41	WFU3	14414
14751	20092	97	THW1	43003
14752	20092	39	THX2	16078
14753	20092	59	MR11C	33102
14754	20092	36	WFU-1	13875
14755	20092	70	WFR	37506
14756	20092	107	TWHFV5	39329
14757	20092	94	WFU2	45779
14758	20092	41	WFW2	14416
14759	20092	123	WFW2	14488
14760	20092	40	THW	14506
14761	20092	36	THQ-1	13850
14762	20092	106	TWHFV	39173
14763	20092	89	WFU	62803
14764	20092	36	THU-2	13855
14765	20092	39	WFQ1	16096
14766	20092	43	THU2	14439
14767	20092	40	THY2	14510
14768	20092	158	WFX	16127
14769	20092	76	THW	40802
14770	20092	94	THX4	45768
14771	20092	107	TWHFU5	39206
14772	20092	100	THW	42474
14773	20092	41	WFX2	14418
14774	20092	93	THR1	46302
14775	20092	94	WFX1	45787
14776	20092	43	WFW1	14461
14777	20092	106	TWHFQ	39170
14778	20092	103	WFV-1	44684
14779	20092	39	THX3	16081
14780	20092	93	THW1	46315
14781	20092	42	THX3	14426
14782	20092	39	WFY2	16068
14783	20092	104	MCDE1	45817
14784	20092	100	WFR	42477
14785	20092	95	THU2	45796
14786	20092	39	WFU	16103
14787	20093	41	X4A	14406
14788	20093	111	X7-5	41355
14789	20093	93	X3-1	46307
14790	20093	35	X2-A	15501
14791	20093	18	Prac	54551
14792	20093	162	X7-9	41359
14793	20093	94	X3	45753
14794	20093	113	X1-A	15546
14795	20093	70	X5	37504
14796	20093	113	X2-B	15543
14797	20093	133	X4	55651
14798	20093	61	X3-A	15519
14799	20093	109	X2-1	39205
14800	20093	81	X4	42003
14801	20093	71	X3	38602
14802	20093	123	X3A	14431
14803	20093	111	X7-4	41354
14804	20093	98	X1	42451
14805	20093	5	X	54554
14806	20093	108	Z1-4	39195
14807	20093	109	X1-1	39193
14808	20093	103	X-2	44659
14809	20093	109	X4	39182
14810	20093	109	X3	39181
14811	20093	100	X4-1	42461
14812	20093	108	Z2	39172
14813	20093	108	Z3-1	39175
14814	20093	108	Z3-4	39206
14815	20093	109	X4-1	39183
14816	20093	43	X2B	14418
14817	20093	123	X2A	14428
14818	20093	93	X3	46302
14819	20093	23	X	54553
14820	20093	109	X2	39180
14821	20093	103	X5	43556
14822	20093	50	X4-A	15507
14823	20093	41	X3A	14403
14824	20093	108	Z1-1	39173
14825	20093	108	Z2-3	39199
14826	20093	137	X3	14966
14827	20093	163	X-2-2	44653
14828	20093	107	Z1-2	39169
14829	20093	108	Z1	39170
14830	20093	108	Z1-3	39194
14831	20093	108	Z1-5	39196
14832	20093	95	X3	45755
14833	20093	93	X2	46301
14834	20093	108	Z2-2	39177
14835	20093	105	X3	43554
14836	20093	94	X2	45752
14837	20093	40	X4A	14439
14838	20093	100	X3-1	42459
14839	20093	107	Z1	39164
14840	20093	108	Z1-2	39176
14841	20093	108	Z1-6	39197
14842	20093	107	Z2	39165
14843	20093	107	Z1-3	39201
14844	20093	108	Z3-2	39178
14845	20093	100	X3-2	42460
14846	20093	94	X1	45751
14847	20093	107	Z2-1	39168
14848	20093	107	Z2-2	39202
14849	20093	84	X3	42002
14850	20093	39	X1A	16051
14851	20093	102	X2-1	44110
14852	20093	71	X2	38601
14853	20093	107	Z1-1	39167
14854	20093	108	Z1-8	39215
14855	20093	108	Z2-1	39174
14856	20101	17	THU	54569
14857	20101	7	HTVW	54586
14858	20101	16	THY	54592
14859	20101	6	S2	54650
14860	20101	112	WFR	69955
14861	20101	37	WFX-1	13890
14862	20101	102	WFU	44164
14863	20101	17	WFV	54571
14864	20101	21	HR	54593
14865	20101	20	MACL	54614
14866	20101	19	WFX	54576
14867	20101	16	WFY	54591
14868	20101	20	MWSG	54619
14869	20101	112	WFU	69956
14870	20101	164	THD	66665
14871	20101	164	HJ4	66745
14872	20101	70	WFV	37509
14873	20101	82	THX	42012
14874	20101	16	WFX	54590
14875	20101	23	THR	54605
14876	20101	114	WBC	52481
14877	20101	114	WBCH	52483
14878	20101	17	WFW	54572
14879	20101	8	THV	54579
14880	20101	6	HTXY	54582
14881	20101	7	M	54649
14882	20101	114	WBCT	52482
14883	20101	8	THW	54577
14884	20101	7	WFVW	54646
14885	20101	23	THV	54595
14886	20101	114	FBCS2	52528
14887	20101	114	FBC	52530
14888	20101	113	WFQ2	15650
14889	20101	155	THW	40258
14890	20101	19	WFU	54574
14891	20101	16	WFV	54589
14892	20101	20	MCVMIG	54616
14893	20101	112	WFX	70034
14894	20101	123	WFU1	14497
14895	20101	87	WFW1	47967
14896	20101	7	HTRU	54585
14897	20101	113	THV1	15631
14898	20101	70	THW	37504
14899	20101	100	WFR1	42472
14900	20101	3	WFVW	54567
14901	20101	19	THR	54573
14902	20101	17	WFU	54570
14903	20101	19	WFW	54575
14904	20101	26	THX	54596
14905	20101	75	WFY	55106
14906	20101	8	THY	54578
14907	20101	113	THX2	15636
14908	20101	165	THU	39268
14909	20101	111	S4-A	41382
14910	20101	114	FBCS1	52484
14911	20101	20	MNDSG	54617
14912	20101	43	THW1	14465
14913	20101	111	S3-A	41380
14914	20101	95	THV1	45796
14915	20101	79	WFV1	39705
14916	20101	20	MSCL	54618
14917	20101	108	TWHFV1	39249
14918	20101	72	WFX	52379
14919	20101	3	WFRU	54566
14920	20101	35	WFV2	15505
14921	20101	109	THX	39261
14922	20101	100	THR3	42519
14923	20101	166	THU	43030
14924	20101	23	THW	54604
14925	20101	36	THY-1	13862
14926	20101	103	WFQ-2	44665
14927	20101	74	THX	54001
14928	20101	23	WFY	54607
14929	20101	127	THV1	15554
14930	20101	81	WFX	42002
14931	20101	82	THR	42003
14932	20101	107	TWHFY1	39382
14933	20101	110	S3-A	41361
14934	20101	1	FWVW	54555
14935	20101	45	WFV	14519
14936	20101	6	S	54643
14937	20101	137	THQ	15024
14938	20101	56	THX1	15566
14939	20101	6	FWVW	54583
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY courses (courseid, coursename, credits, domain, commtype) FROM stdin;
1	CS 11	3	MAJ	\N
2	CS 12	3	MAJ	\N
3	CS 21	4	MAJ	\N
4	CS 30	3	MAJ	\N
5	CS 32	3	MAJ	\N
6	CS 140	3	MAJ	\N
7	CS 150	3	MAJ	\N
8	CS 135	3	MAJ	\N
9	CS 165	3	MAJ	\N
10	CS 191	3	MAJ	\N
11	CS 130	3	MAJ	\N
12	CS 192	3	MAJ	\N
13	CS 194	1	MAJ	\N
14	CS 145	3	MAJ	\N
15	CS 153	3	MAJ	\N
16	CS 180	3	MAJ	\N
17	CS 131	3	MAJ	\N
18	CS 195	3	MAJ	\N
19	CS 133	3	MAJ	\N
20	CS 198	3	MAJ	\N
21	CS 196	1	MAJ	\N
22	CS 199	3	MAJ	\N
23	CS 197	3	C197	\N
24	CS 120	3	CSE	\N
27	CS 173	3	CSE	\N
28	CS 174	3	CSE	\N
29	CS 175	3	CSE	\N
30	CS 176	3	CSE	\N
25	CS 171	3	CSE	\N
26	CS 172	3	CSE	\N
31	Comm 1	3	AH	E
32	Comm 2	3	AH	E
33	Hum 1	3	AH	\N
34	Hum 2	3	AH	\N
35	Aral Pil 12	3	AH	P
36	Art Stud 1	3	AH	\N
37	Art Stud 2	3	AH	\N
38	BC 10	3	AH	\N
39	Comm 3	3	AH	E
40	CW 10	3	AH	E
41	Eng 1	3	AH	E
42	Eng 10	3	AH	E
43	Eng 11	3	AH	E
44	L Arch 1	3	AH	\N
45	Eng 30	3	AH	E
46	EL 50	3	AH	\N
47	FA 28	3	AH	P
48	FA 30	3	AH	\N
49	Fil 25	3	AH	\N
50	Fil 40	3	AH	P
51	Film 10	3	AH	\N
52	Film 12	3	AH	P
53	Humad 1	3	AH	P
54	J 18	3	AH	\N
55	Kom 1	3	AH	E
56	Kom 2	3	AH	E
57	MPs 10	3	AH	P
58	MuD 1	3	AH	\N
59	MuL 9	3	AH	P
60	MuL 13	3	AH	\N
61	Pan Pil 12	3	AH	P
62	Pan Pil 17	3	AH	P
63	Pan Pil 19	3	AH	P
64	Pan Pil 40	3	AH	P
65	Pan Pil 50	3	AH	P
66	SEA 30	3	AH	\N
67	Theatre 10	3	AH	\N
68	Theatre 11	3	AH	P
69	Theatre 12	3	AH	\N
70	Bio 1	3	MST	\N
71	Chem 1	3	MST	\N
72	EEE 10	3	MST	\N
73	Env Sci 1	3	MST	\N
74	ES 10	3	MST	\N
75	GE 1	3	MST	\N
76	Geol 1	3	MST	\N
77	L Arch 1	3	MST	\N
78	Math 2	3	MST	\N
79	MBB 1	3	MST	\N
80	MS 1	3	MST	\N
81	Nat Sci 1	3	MST	\N
82	Nat Sci 2	3	MST	\N
83	Physics 10	3	MST	\N
84	STS	3	MST	\N
85	FN 1	3	MST	\N
86	CE 10	3	MST	\N
87	Anthro 10	3	SSP	\N
88	Archaeo 2	3	SSP	\N
89	Arkiyoloji 1	3	SSP	P
90	CE 10	3	SSP	\N
91	Econ 11	3	SSP	\N
92	Econ 31	3	SSP	\N
93	Geog 1	3	SSP	\N
94	Kas 1	3	SSP	P
95	Kas 2	3	SSP	\N
96	L Arch 1	3	SSP	\N
97	Lingg 1	3	SSP	\N
98	Philo 1	3	SSP	\N
99	Philo 10	3	SSP	\N
100	Philo 11	3	SSP	\N
101	SEA 30	3	SSP	P
102	Soc Sci 1	3	SSP	\N
103	Soc Sci 2	3	SSP	\N
104	Soc Sci 3	3	SSP	\N
105	Socio 10	3	SSP	P
106	Math 17	5	MAJ	\N
107	Math 53	5	MAJ	\N
108	Math 54	5	MAJ	\N
109	Math 55	3	MAJ	\N
110	Physics 71	4	MAJ	\N
111	Physics 72	4	MAJ	\N
112	Stat 130	3	MAJ	\N
113	PI 100	3	MAJ	\N
114	EEE 8	3	MAJ	\N
115	EEE 9	3	MAJ	\N
116	P E 2F	3	FE	\N
117	MS	3	FE	\N
118	Math 114	3	MSEE	\N
119	Math 157	3	MSEE	\N
120	CS 160	3	CSE	\N
121	BA 101	3	FE	\N
122	CS 155	3	CSE	\N
123	Eng 12	3	FE	\N
124	Anthro 185	3	FE	\N
125	Span 10	3	FE	\N
126	Span 11	3	FE	\N
127	Humanidades 1	3	FE	\N
128	Russ 10	3	FE	\N
129	MS 102	3	MSEE	\N
130	Hapon 10	3	FE	\N
131	ES 204	3	FE	\N
132	Psych 101	3	FE	\N
133	ES 21	3	FE	\N
134	Hapon 11	3	FE	\N
135	French 10	3	FE	\N
136	Art Stud 194	3	FE	\N
137	Ital 10	3	FE	\N
138	Geol 11	3	MSEE	\N
139	Hapon 12	3	FE	\N
140	Hapon 13	3	FE	\N
141	Econ 102	3	FE	\N
142	CW 180	3	FE	\N
143	Chem 16	3	MSEE	\N
144	Hapon 100	3	FE	\N
145	Hapon 101	3	FE	\N
146	EnE 31	3	FE	\N
147	Intsik 10	3	FE	\N
148	Intsik 11	3	FE	\N
149	French 11	3	FE	\N
150	Koreyano 10	3	FE	\N
151	Math 197	3	MSEE	\N
152	VC 50	3	FE	\N
153	Math 14	3	MSEE	\N
154	Math 121.1	3	MSEE	\N
155	MS 101	3	MSEE	\N
156	German 10	3	FE	\N
157	IE 3	3	MSEE	\N
158	Theater 12	3	FE	\N
159	Theater 11	3	FE	\N
160	Philo 100	3	FE	\N
161	Physics 71.1	3	MSEE	\N
162	Physics 73	3	MSEE	\N
163	POLSC 14	3	FE	\N
164	Econ 100.1	3	FE	\N
165	Math 109	3	MSEE	\N
166	Thai 10	3	FE	\N
\.


--
-- Data for Name: curricula; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY curricula (curriculumid, curriculumname) FROM stdin;
1	new
2	old
\.


--
-- Data for Name: elig24unitspassing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY elig24unitspassing (studentid, yearid, unitspassed) FROM stdin;
2009	2006	9
2009	2007	3
2010	2004	13
2010	2008	12
2010	2009	22
2010	2010	6
2011	2005	12
2011	2006	13
2011	2007	22
2011	2009	3
2013	2006	23
2013	2008	18
2013	2010	4
2014	2009	6
2014	2010	3
2015	2010	9
2016	2010	12
2018	2010	15
2019	2010	0
2020	2010	9
2021	2010	9
2022	2010	13
2023	2010	12
2024	2010	15
2025	2010	16
2026	2009	22
2026	2010	6
2027	2010	15
2028	2009	13
2028	2010	10
2029	2010	12
2030	2010	15
2031	2010	15
2032	2010	19
2033	2010	15
2034	2010	18
2035	2010	15
2036	2010	18
2037	2010	9
2054	2009	15
2063	2009	23
2069	2008	22
2069	2010	9
2070	2010	12
2071	2010	13
2072	2010	15
2073	2010	19
2074	2010	19
2180	2009	11
2181	2009	14
2182	2009	19
2183	2010	15
2007	1999	23
2007	2001	18
2007	2002	18
2007	2003	6
2088	2009	20
\.


--
-- Data for Name: eligpasshalf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalf (studentid, studenttermid, termid, failpercentage) FROM stdin;
2009	8601	20032	0.649999976
2010	8615	20042	0.652173936
2010	8880	20091	0.600000024
2010	9316	20101	0.600000024
2054	8935	20091	0.631578922
2088	9127	20092	0.647058845
\.


--
-- Data for Name: eligpasshalfmathcs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalfmathcs (studentid, studenttermid, termid, failpercentage) FROM stdin;
2009	8601	20032	0.666666687
2010	8615	20042	1
2011	8621	20042	0.75
2013	8642	20061	0.555555582
2015	8655	20062	0.625
2016	8645	20061	0.625
2017	8699	20072	0.666666687
2021	8701	20072	1
2026	8684	20071	0.625
2031	8749	20081	0.555555582
2038	9081	20092	0.666666687
2039	8915	20091	0.555555582
2043	8922	20091	0.555555582
2046	8763	20081	0.625
2047	8865	20082	0.625
2050	9100	20092	0.600000024
2053	8829	20082	0.625
2054	8935	20091	0.666666687
2055	8772	20081	0.625
2068	8785	20081	1
2072	8907	20091	0.625
2096	8965	20091	0.625
2101	8970	20091	0.625
2102	9141	20092	0.625
2114	8983	20091	0.625
2120	8989	20091	0.625
2153	9022	20091	0.625
2169	9038	20091	0.625
2173	9212	20092	1
2088	9127	20092	0.625
\.


--
-- Data for Name: eligtwicefail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligtwicefail (studentid, classid, courseid, section, coursename, termid) FROM stdin;
2063	14450	5	WFU	CS 32	20092
2063	14805	5	X	CS 32	20093
2007	13154	5	MHX1	CS 32	20002
2007	13161	5	W1	CS 32	20011
\.


--
-- Data for Name: eligtwicefailcourses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligtwicefailcourses (courseid) FROM stdin;
106
107
108
109
1
2
3
5
\.


--
-- Data for Name: grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY grades (gradeid, gradename, gradevalue) FROM stdin;
1	1.00	1.00
2	1.25	1.25
3	1.50	1.50
4	1.75	1.75
5	2.00	2.00
6	2.25	2.25
7	2.50	2.50
8	2.75	2.75
9	3.00	3.00
10	4.00	4.00
11	5.00	5.00
12	INC	-1.00
13	DRP	0.00
14	NG	-2.00
\.


--
-- Data for Name: ineligibilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ineligibilities (ineligibilityid, ineligibility) FROM stdin;
1	Twice Fail Subject
2	50% Passing Subjects
3	50% Passing CS/Math
4	24 Units Passing per Year
\.


--
-- Data for Name: instructorclasses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY instructorclasses (instructorclassid, classid, instructorid) FROM stdin;
\.


--
-- Data for Name: instructors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY instructors (instructorid, personid) FROM stdin;
\.


--
-- Data for Name: persons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY persons (personid, lastname, firstname, middlename, pedigree) FROM stdin;
2017	ORENSE	ADRIAN	CORDOVA	
2018	VILLARANTE	JAY RICKY	BARRAMEDA	
2019	LUMONGSOD	PIO RYAN	SAGARINO	
2020	TOBIAS	GEORGE HELAMAN	ASTURIAS	
2021	CUNANAN	JENNIFER	DELA CRUZ	
2022	RAGASA	ROGER JOHN	ESTEPA	
2023	MARANAN	KERVIN	CATUNGAL	
2024	DEINLA	REGINALD ELI	ATIENZA	
2025	RAMIREZ	NORBERTO	ALLAREY	II
2026	PUGAL	EDGAR	STA BARBARA	JR
2027	JOVEN	KATHLEEN GRACE	GUERRERO	
2028	ESCALANTE	ED ALBERT	BELARGO	
2029	CONTRERAS	PAUL VINCENT	SALES	
2030	DIRECTO	KAREIN JOY	TOLENTINO	
2031	VALLO	LOVELIA	LAROCO	
2032	DOMINGO	CYROD JOHN	FLORIDA	
2033	SUBA	KEVIN RAINIER	SINOGAYA	
2034	CATAJOY	VINCENT NICHOLAS	RANA	
2035	BATANES	BRYAN MATTHEW	AVENDANO	
2036	BALAGAPO	JOSHUA	KHO	
2037	DOMANTAY	ERIC	AMPARO	JR
2038	JAVIER	JEWEL LEX	TONG	
2039	JUAT	WESLEY	MENDOZA	
2040	ISIDRO	HOMER IRIC	SANTOS	
2041	VILLANUEVA	MARIANNE ANGELIE	OCAMPO	
2042	MAMARIL	VIC ANGELO	DELOS SANTOS	
2043	ARANA	RYAN KRISTOFER	IGMAT	
2044	NICOLAS	DANA ELISA	GAGALAC	
2045	VACALARES	ISAIAH JAMES	VALDES	
2046	SANTILLAN	MA CECILIA		
2047	PINEDA	JAKE ERICKSON	BOTEROS	
2048	LOYOLA	ELIZABETH	CUETO	
2049	BUGAOAN	FRANCIS KEVIN	ALIMORONG	
2050	GALLARDO	FRANCIS JOMER	DE LEON	
2051	ARGARIN	MICHAEL ERICK	STA TERESA	
2052	VILLARUZ	JULIAN	CASTILLO	
2053	FRANCISCO	ARMINA	EUGENIO	
2054	AQUINO	JOSEPH ARMAN	BONGCO	
2055	AME	MARTIN ROMAN LORENZO	ILAGAN	
2056	CELEDONIO	MESSIAH JAN	LEBID	
2057	SABIDONG	JEROME	RONCESVALLES	
2058	FLORENCIO	JOHN CARLO	MAQUILAN	
2059	EPISTOLA	SILVEN VICTOR	DUMALAG	
2060	SANTOS	JOHN ISRAEL	LORENZO	
2061	SANTOS	MARIE JUNNE	CABRAL	
2062	FABIC	JULIAN NICHOLAS	REYES	
2063	TORRES	ERIC	TUQUERO	
2064	CUETO	BENJAMIN	ANGELES	JR
2065	PASCUAL	JEANELLA KLARYS	ESPIRITU	
2066	GAMBA	JOSE NOEL	CARDONES	
2067	REFAMONTE	JARED	MUMAR	
2068	BARITUA	KARESSA ALEXANDRA	ONG	
2069	SEMILLA	STANLEY	TINA	
2070	ANGELES	MARC ARTHUR	PAJE	
2071	SORIAO	HANS CHRISTIAN	BALTAZAR	
2072	DINO	ARVIN	PABINES	
2073	MORALES	NOELYN JOYCE	ROL	
2074	MANALAC	DAVID ROBIN	MANALAC	
2075	SAY	KOHLEN ANGELO	PEREZ	
2076	ADRIANO	JAMES PATRICK	DAVID	
2077	SERRANO	MICHAEL	DIONISIO	
2078	CHOAPECK	MARIE ANTOINETTE	R	
2079	TURLA	ISAIAH EDWARD	G	
2080	MONCADA	DEAN ALVIN	BAJAMONDE	
2081	EVANGELISTA	JOHN EROL	MILANO	
2082	ASIS	KRYSTIAN VIEL	CABUGAO	
2083	CLAVECILLA	VANESSA VIVIEN	FRANCISCO	
2084	RONDON	RYAN ODYLON	GAZMEN	
2085	ARANAS	CHRISTIAN JOY	MARQUEZ	
2086	AGUILAR	JENNIFER	RAMOS	
2087	CUEVAS	SARAH	BERNABE	
2088	PASCUAL	JAYVEE ELJOHN	ACABO	
2089	TORRES	DANAH VERONICA	PADILLA	
2090	BISAIS	APRYL ROSE	LABAYOG	
2091	CHUA	TED GUILLANO	SY	
2092	CRUZ	IVAN KRISTEL	POLICARPIO	
2093	AQUINO	CHLOEBELLE	RAMOS	
2094	YUTUC	DANIEL	LALAGUNA	
2095	DEL ROSARIO	BENJIE	REYES	
2096	RAMOS	ANNA CLARISSA	BEATO	
2097	REYES	CHARMAILENE	CAPILI	
2098	ABANTO	JEANELLE	ESGUERRA	
2099	BONDOC	ROD XANDER	RIVERA	
2100	TACATA	NERISSA MONICA	DE GUZMAN	
2101	RABE	REZELEE	AQUINO	
2102	DECENA	BERLYN ANNE	ARAGON	
2103	DIMLA	KARL LEN MAE	BALDOMERO	
2104	SANCHEZ	ZIV YVES	MONTOYA	
2105	LITIMCO	CZELINA ELLAINE	ONG	
2106	GUILLEN	NEIL DAVID	BALGOS	
2107	SOMOSON	LOU MERLENETTE	BAUTISTA	
2108	TALAVERA	RHIZA MAE	GO	
2109	CANOY	JOHN GABRIEL	ERUM	
2110	CHUA	RALPH JACOB	ANG	
2111	EALA	MARIA AZRIEL THERESE	DESTUA	
2112	AYAG	DANIELLE ANNE	FRANCISCO	
2113	DE VILLA	RACHEL	LUNA	
2114	JAYMALIN	JEAN DOMINIQUE	BERNAL	
2115	LEGASPI	CHARMAINE PAMELA	ABERCA	
2116	LIBUNAO	ARIANNE FRANCESCA	QUIJANO	
2117	REGENCIA	FELIX ARAM	JEREMIAS	
2118	SANTI	NATHAN LEMUEL	GO	
2119	LEONOR	WENDY GENEVA	SANTOS	
2120	LUNA	MARA ISSABEL	SUPLICO	
2121	SIRIBAN	MA LORENA JOY	ASCUTIA	
2122	LEGASPI	MISHAEL MAE	CRUZ	
2123	SUN	HANNAH ERIKA	YAP	
2124	PARRENO	NICOLE ANNE	KAHN	
2125	BULANHAGUI	KEVIN DAVID	BALANAY	
2126	MONCADA	JULIA NINA	SOMERA	
2127	IBANEZ	SEBASTIAN	CANLAS	
2128	COLA	VERNA KATRIN	BEDUYA	
2129	SANTOS	MARIA RUBYLISA	AREVALO	
2130	YECLA	NORVIN	GARCIA	
2131	CASTANEDA	ANNA MANNELLI	ESPIRITU	
2132	FOJAS	EDGAR ALLAN	GO	
2133	DELA CRUZ	EMERY	FABRO	
2134	SADORNAS	JON PERCIVAL	GARCIA	
2135	VILLANUEVA	MARY GRACE	AYENTO	
2136	ESGUERRA	JOSE MARI	MARCELO	
2137	SY	KYLE BENEDICT	GUERRERO	
2138	TORRES	LUIS ANTONIO	PEREZ	
2139	TONG	MAYNARD JEFFERSON	ZHUANG	
2140	DATU	PATRICH PAOLO	BONETE	
2141	PEREA	EMMANUEL	LOYOLA	
2142	BALOY	MICHAEL JOYSON	GERMAR	
2143	REAL	VICTORIA CASSANDRA	RUIVIVAR	
2144	MARTIJA	JASPER	ENRIQUEZ	
2145	OCHAVEZ	ARISA	CAAKBAY	
2146	AMORANTO	PAOLO	SISON	
2147	SAN ANTONIO	JAYVIC	PORTILLO	
2148	SARDONA	CATHERINE LORAINE	FESTIN	
2149	MENESES	ANGELO	CAL	
2150	AUSTRIA	DARRWIN DEAREST	CRISOSTOMO	
2151	BURGOS	ALVIN JOHN	MANLIGUEZ	
2152	MAGNO	JENNY	NARSOLIS	
2153	SAPASAP	RIC JANUS	OLIVER	
2154	QUILAB	FRANCIS MIGUEL	EVANGELISTA	
2155	PINEDA	RIZA RAE	ALDECOA	
2156	TAN	XYRIZ CZAR	PINEDA	
2157	DELAS PENAS	KRISTOFER	EMPUERTO	
2158	MANSOS	JOHN FRANCIS	LLAGAS	
2159	PANOPIO	GIRAH MAY	CHUA	
2160	LEGASPINA	CHRISLENE	BUGARIN	
2161	RIVERA	DON JOSEPH	TIANGCO	
2162	RUBIO	MARY GRACE	TALAN	
2163	LEONOR	CHARLES TIMOTHY	DEL ROSARIO	
2164	CABUHAT	JOHN JOEL	URBISTONDO	
2165	MARANAN	GENIE LINN	PADILLA	
2166	WANG	CASSANDRA LEIGH	LACASTA	
2167	YU	GLADYS JOYCE	OCAP	
2168	TOMACRUZ	ARVIN JOHN	CRUZ	
2169	BALDUEZA	GYZELLE	EVANGELISTA	
2170	BATAC	JOSE EMMANUEL	DE JESUS	
2171	CUETO	JAN COLIN	OJEDA	
2172	RUBI	SHIELA PAULINE JOY	VERGARA	
2173	ALCARAZ	KEN GERARD	TECSON	
2174	DE LOS SANTOS	PAOLO MIGUEL	MACALINDONG	
2175	CHAVEZ	JOE-MAR	ORINDAY	
2176	PERALTA	PAOLO THOMAS	REYES	
2177	SANTOS	ALEXANDREI	GONZALES	
2178	MACAPINLAC	VERONICA	ALCARAZ	
2179	PACAPAC	DIANA MAE	CANLAS	
2180	DUNGCA	JOHN ALPERT	ANCHO	
2181	ZACARIAS	ROEL JEREMIAH	ALCANTARA	
2182	RICIO	DUSTIN EDRIC	LEGARDA	
2183	ARBAS	HARVEY IAN	SOLAYAO	
2184	SALVADOR	RAMON JOSE NILO	DELA VEGA	
2185	DORADO	JOHN PHILIP	URRIZA	
2186	DEATRAS	SHEALTIEL PAUL ROSSNERR	CALUAG	
2187	CAPACILLO	JULES ALBERT	BERINGUELA	
2188	SALAMANCA	KYLA MARIE	G.	
2189	AVE	ARMOND	C.	
2190	CALARANAN	MICHAEL KEVIN	PONTE	
2191	DOCTOR	JET LAWRENCE	PARONE	
2192	ANG	RITZ DANIEL	CATAMPATAN	
2193	FORMES	RAFAEL GERARD	DELA CRUZ	
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY requirements (requirementid, requirementname, functionname) FROM stdin;
\.


--
-- Data for Name: studentclasses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentclasses (studentclassid, studenttermid, classid, gradeid) FROM stdin;
38076	8581	13138	6
38077	8581	13139	7
38078	8581	13140	7
38079	8581	13141	6
38080	8581	13142	4
38081	8581	13143	3
38082	8581	13144	1
38083	8582	13145	4
38084	8582	13146	5
38085	8582	13147	6
38086	8582	13148	4
38087	8582	13149	3
38088	8583	13150	10
38089	8583	13151	11
38090	8583	13152	9
38091	8583	13153	8
38092	8583	13154	11
38093	8584	13155	3
38094	8584	13156	9
38095	8585	13157	7
38096	8585	13158	9
38097	8585	13159	13
38098	8585	13160	10
38100	8586	13162	13
38101	8586	13163	9
38102	8586	13164	11
38103	8586	13165	11
38104	8586	13166	9
38105	8586	13167	11
38106	8587	13168	6
38107	8587	13169	5
38108	8588	13170	9
38109	8588	13171	6
38110	8588	13172	11
38111	8588	13173	9
38112	8588	13174	5
38113	8589	13175	6
38114	8589	13176	9
38115	8589	13177	6
38116	8589	13178	8
38117	8589	13179	3
38118	8590	13180	7
38119	8590	13181	6
38120	8590	13182	5
38121	8590	13183	6
38122	8590	13184	6
38123	8591	13185	9
38124	8591	13186	8
38125	8591	13187	10
38126	8592	13188	5
38127	8592	13189	9
38128	8592	13190	7
38129	8592	13191	7
38130	8592	13192	11
38131	8593	13193	7
38132	8593	13194	9
38133	8593	13195	3
38134	8593	13196	6
38135	8593	13197	9
38136	8594	13198	14
38137	8594	13199	9
38138	8594	13200	10
38139	8594	13201	5
38140	8594	13202	14
38141	8595	13203	7
38142	8595	13204	14
38143	8595	13205	9
38144	8595	13206	14
38145	8595	13207	5
38146	8595	13208	5
38147	8596	13209	9
38148	8596	13210	8
38149	8596	13211	9
38150	8596	13212	4
38151	8596	13213	7
38152	8597	13214	12
38153	8597	13215	7
38154	8597	13216	5
38155	8597	13217	9
38156	8597	13218	14
38157	8598	13219	14
38158	8598	13220	9
38159	8598	13221	6
38160	8598	13222	6
38161	8598	13223	12
38162	8599	13224	12
38163	8600	13225	5
38164	8600	13226	4
38165	8600	13227	13
38166	8600	13228	4
38167	8600	13229	9
38168	8600	13230	9
38169	8601	13231	11
38170	8601	13232	9
38171	8601	13233	11
38172	8601	13234	11
38173	8601	13235	11
38174	8602	13236	13
38175	8602	13237	9
38176	8602	13238	9
38177	8602	13239	9
38178	8602	13240	5
38179	8603	13241	9
38180	8603	13242	6
38181	8603	13243	4
38182	8603	13244	2
38183	8603	13245	2
38184	8604	13246	6
38185	8605	13247	8
38186	8606	13248	5
38187	8606	13249	5
38188	8607	13250	10
38189	8608	13251	4
38190	8608	13252	9
38191	8608	13253	8
38192	8608	13254	11
38193	8608	13255	8
38194	8608	13256	9
38195	8609	13257	9
38196	8609	13258	4
38197	8609	13259	9
38198	8609	13260	11
38199	8609	13261	9
38200	8609	13255	11
38201	8610	13262	12
38202	8610	13263	7
38203	8610	13264	11
38204	8610	13265	13
38205	8610	13266	6
38206	8611	13267	12
38207	8611	13268	6
38208	8611	13269	7
38209	8611	13270	7
38210	8611	13271	7
38211	8612	13272	4
38212	8612	13273	7
38213	8612	13274	1
38214	8612	13275	4
38215	8612	13276	1
38216	8613	13277	7
38217	8613	13278	4
38218	8613	13279	8
38219	8613	13280	1
38220	8613	13281	7
38221	8613	13282	9
38222	8614	13283	12
38223	8614	13284	4
38224	8614	13285	5
38225	8614	13279	11
38226	8614	13281	8
38227	8614	13282	9
38228	8615	13286	11
38229	8615	13287	11
38230	8615	13288	11
38231	8615	13289	11
38232	8615	13290	9
38233	8615	13291	11
38234	8616	13292	5
38235	8616	13293	11
38236	8616	13294	11
38237	8616	13295	9
38238	8616	13291	11
38239	8617	13296	9
38240	8617	13297	6
38241	8617	13298	13
38242	8617	13299	5
38243	8617	13300	2
38244	8618	13301	4
38245	8618	13302	7
38246	8619	13303	2
38247	8619	13304	4
38248	8620	13305	14
38249	8621	13306	6
38250	8622	13307	13
38251	8623	13308	6
38252	8623	13309	9
38253	8623	13310	9
38254	8623	13311	6
38255	8623	13312	2
38256	8623	13313	5
38257	8623	13314	6
38258	8624	13315	11
38259	8624	13316	5
38260	8624	13310	5
38261	8624	13317	6
38262	8624	13318	6
38263	8624	13319	9
38264	8625	13320	6
38265	8625	13321	5
38266	8625	13322	11
38267	8625	13323	11
38268	8625	13324	3
38269	8625	13325	9
38270	8626	13326	8
38271	8626	13327	11
38272	8626	13328	6
38273	8626	13329	12
38274	8626	13325	9
38275	8626	13319	7
38276	8627	13330	4
38277	8627	13331	8
38278	8627	13332	7
38279	8627	13329	1
38280	8627	13333	7
38281	8628	13334	7
38282	8628	13335	5
38283	8628	13336	4
38284	8628	13337	3
38285	8628	13338	4
38286	8629	13339	6
38287	8629	13340	4
38288	8629	13341	4
38289	8629	13342	8
38290	8629	13343	2
38291	8630	13344	3
38292	8630	13345	14
38293	8630	13346	9
38294	8630	13347	9
38295	8630	13348	12
38296	8630	13349	7
38297	8630	13350	2
38298	8631	13351	8
38299	8631	13352	5
38300	8631	13353	9
38301	8631	13348	6
38302	8631	13354	6
38303	8631	13355	2
38304	8631	13356	3
38305	8632	13357	6
38306	8632	13358	5
38307	8632	13359	5
38308	8632	13360	10
38309	8632	13361	8
38310	8632	13362	7
38311	8633	13363	12
38312	8633	13364	10
38313	8633	13365	4
38314	8633	13366	9
38315	8633	13367	6
38316	8633	13368	5
38317	8634	13369	13
38318	8634	13370	11
38319	8634	13371	9
38320	8634	13372	6
38321	8634	13373	4
38322	8635	13351	8
38323	8635	13374	7
38324	8635	13375	5
38325	8635	13376	4
38326	8635	13377	1
38327	8636	13378	1
38328	8636	13379	2
38329	8637	13380	5
38330	8638	13381	6
38331	8639	13382	3
38332	8639	13383	6
38333	8640	13384	14
38334	8640	13385	8
38335	8640	13386	10
38336	8640	13387	6
38337	8641	13388	2
38338	8641	13389	3
38339	8641	13384	5
38340	8641	13390	5
38341	8641	13391	5
38342	8641	13392	6
38343	8641	13393	1
38344	8642	13394	11
38345	8642	13395	11
38346	8642	13396	8
38347	8642	13397	13
38348	8642	13398	9
38349	8643	13399	4
38350	8643	13400	8
38351	8643	13401	6
38352	8643	13402	9
38353	8643	13403	3
38354	8644	13404	5
38355	8644	13405	5
38356	8644	13406	9
38357	8644	13407	2
38358	8644	13408	5
38359	8645	13409	3
38360	8645	13410	11
38361	8645	13411	2
38362	8645	13412	3
38363	8645	13413	5
38364	8646	13414	2
38365	8646	13415	8
38366	8646	13416	1
38367	8646	13417	3
38368	8646	13413	6
38369	8647	13409	4
38370	8647	13415	9
38371	8647	13418	1
38372	8647	13419	7
38373	8647	13420	7
38374	8648	13421	5
38375	8648	13422	10
38376	8648	13423	5
38377	8648	13424	5
38378	8648	13420	1
38379	8649	13425	7
38380	8649	13426	9
38381	8649	13427	6
38382	8649	13428	3
38383	8649	13429	2
38384	8650	13430	14
38385	8650	13431	14
38386	8650	13432	9
38387	8651	13433	4
38388	8651	13434	7
38389	8651	13435	8
38390	8651	13436	4
38391	8651	13437	12
38392	8652	13438	2
38393	8652	13430	14
38394	8652	13439	8
38395	8652	13440	1
38396	8652	13441	2
38397	8652	13442	4
38398	8652	13443	1
38399	8653	13444	13
38400	8653	13445	9
38401	8653	13446	11
38402	8653	13447	9
38403	8653	13448	9
38404	8654	13449	8
38405	8654	13450	6
38406	8654	13451	9
38407	8654	13452	3
38408	8654	13440	6
38409	8654	13453	5
38410	8655	13454	6
38411	8655	13455	11
38412	8655	13456	4
38413	8655	13457	4
38414	8655	13458	6
38415	8656	13459	8
38416	8656	13460	4
38417	8656	13461	8
38418	8656	13462	5
38419	8656	13463	8
38420	8657	13464	5
38421	8657	13465	3
38422	8657	13466	3
38423	8657	13467	9
38424	8657	13468	4
38425	8658	13469	3
38426	8658	13470	9
38427	8658	13471	6
38428	8658	13472	4
38429	8658	13468	5
38430	8659	13473	5
38431	8659	13474	5
38432	8659	13475	4
38433	8659	13476	7
38434	8659	13463	2
38435	8660	13477	9
38436	8660	13478	3
38437	8660	13479	2
38438	8660	13472	4
38439	8660	13468	3
38440	8661	13480	14
38441	8662	13481	9
38442	8663	13482	4
38443	8664	13483	9
38444	8665	13484	8
38445	8666	13485	7
38446	8667	13486	8
38447	8668	13487	2
38448	8668	13488	4
38449	8669	13489	14
38450	8669	13490	4
38451	8669	13491	7
38452	8669	13492	11
38453	8669	13493	8
38454	8669	13494	12
38455	8669	13495	11
38456	8669	13496	1
38457	8670	13497	8
38458	8670	13498	11
38459	8670	13493	8
38460	8670	13499	12
38461	8670	13500	2
38462	8670	13501	5
38463	8670	13502	14
38464	8670	13503	4
38465	8671	13504	9
38466	8671	13505	9
38467	8671	13489	14
38468	8671	13490	5
38469	8671	13506	9
38470	8671	13494	8
38471	8671	13495	7
38472	8672	13489	14
38473	8672	13490	3
38474	8672	13507	2
38475	8672	13492	9
38476	8672	13508	9
38477	8672	13509	9
38478	8672	13503	8
38479	8673	13510	3
38480	8673	13511	7
38481	8673	13512	11
38482	8673	13513	7
38483	8674	13514	7
38484	8674	13515	7
38485	8674	13516	1
38486	8674	13517	2
38487	8674	13518	7
38488	8675	13519	5
38489	8675	13520	9
38490	8675	13521	2
38491	8675	13522	4
38492	8675	13523	5
38493	8676	13524	4
38494	8676	13525	8
38495	8676	13526	1
38496	8676	13518	8
38497	8677	13527	6
38498	8677	13528	8
38499	8677	13529	2
38500	8677	13530	9
38501	8678	13531	4
38502	8678	13532	4
38503	8678	13533	9
38504	8678	13534	13
38505	8679	13535	6
38506	8679	13536	9
38507	8679	13537	6
38508	8679	13538	6
38509	8679	13518	4
38510	8680	13539	3
38511	8680	13540	8
38512	8680	13515	9
38513	8680	13541	2
38514	8680	13523	8
38515	8681	13542	5
38516	8681	13543	7
38517	8681	13544	1
38518	8681	13521	2
38519	8681	13545	2
38520	8682	13546	1
38521	8682	13547	5
38522	8682	13548	3
38523	8682	13549	11
38524	8682	13550	2
38525	8683	13546	1
38526	8683	13547	5
38527	8683	13548	3
38528	8683	13549	11
38529	8683	13550	2
38530	8684	13551	4
38531	8684	13547	7
38532	8684	13552	11
38533	8684	13553	10
38534	8684	13554	5
38535	8685	13546	1
38536	8685	13547	5
38537	8685	13548	9
38538	8685	13549	8
38539	8685	13550	4
38540	8686	13555	12
38541	8686	13556	7
38542	8686	13552	7
38543	8686	13557	11
38544	8686	13554	2
38545	8687	13546	1
38546	8687	13547	4
38547	8687	13548	8
38548	8687	13549	6
38549	8687	13550	3
38550	8688	13546	2
38551	8688	13547	7
38552	8688	13548	1
38553	8688	13549	5
38554	8688	13550	1
38555	8689	13558	7
38556	8689	13559	9
38557	8689	13560	3
38558	8689	13561	3
38559	8689	13534	5
38560	8690	13546	1
38561	8690	13547	6
38562	8690	13548	3
38563	8690	13549	8
38564	8690	13550	3
38565	8691	13558	4
38566	8691	13559	6
38567	8691	13562	6
38568	8691	13563	1
38569	8691	13534	1
38570	8692	13564	9
38571	8693	13565	11
38572	8693	13566	6
38573	8693	13567	5
38574	8693	13568	2
38575	8693	13569	12
38576	8693	13570	6
38577	8694	13571	4
38578	8694	13572	3
38579	8694	13573	4
38580	8694	13574	8
38581	8694	13575	5
38582	8694	13576	12
38583	8694	13577	12
38584	8695	13578	11
38585	8695	13579	5
38586	8695	13580	10
38587	8695	13581	11
38588	8695	13582	9
38589	8695	13583	12
38590	8695	13584	11
38591	8696	13585	13
38592	8696	13586	6
38593	8696	13587	5
38594	8696	13582	2
38595	8696	13588	2
38596	8696	13584	5
38597	8697	13589	9
38598	8697	13590	13
38599	8697	13591	5
38600	8697	13592	13
38601	8697	13593	7
38602	8698	13594	13
38603	8698	13595	3
38604	8698	13596	7
38605	8698	13597	7
38606	8698	13598	3
38607	8698	13592	8
38608	8699	13599	9
38609	8699	13600	11
38610	8699	13595	8
38611	8699	13601	9
38612	8699	13602	11
38613	8699	13603	2
38614	8700	13604	4
38615	8700	13595	6
38616	8700	13605	11
38617	8700	13606	9
38618	8700	13607	5
38619	8700	13608	11
38620	8701	13609	9
38621	8701	13610	8
38622	8701	13611	11
38623	8701	13606	10
38624	8701	13612	11
38625	8702	13613	12
38626	8702	13614	6
38627	8702	13615	8
38628	8702	13616	10
38629	8702	13617	7
38630	8702	13618	6
38631	8703	13619	6
38632	8703	13599	8
38633	8703	13620	9
38634	8703	13595	4
38635	8703	13616	13
38636	8703	13608	8
38637	8704	13621	2
38638	8704	13605	11
38639	8704	13622	9
38640	8704	13596	11
38641	8704	13608	11
38642	8705	13623	5
38643	8705	13624	11
38644	8705	13625	2
38645	8705	13626	3
38646	8705	13627	4
38647	8706	13628	7
38648	8706	13629	9
38649	8706	13625	4
38650	8706	13630	5
38651	8706	13627	3
38652	8707	13631	8
38653	8707	13629	9
38654	8707	13625	5
38655	8707	13630	6
38656	8707	13627	7
38657	8708	13632	4
38658	8708	13633	8
38659	8708	13578	8
38660	8708	13634	7
38661	8708	13635	6
38662	8709	13636	4
38663	8709	13637	9
38664	8709	13625	6
38665	8709	13638	1
38666	8709	13627	9
38667	8710	13639	13
38668	8710	13640	11
38669	8710	13641	5
38670	8710	13642	6
38671	8710	13643	3
38672	8711	13644	4
38673	8711	13645	11
38674	8711	13597	8
38675	8711	13646	5
38676	8711	13627	5
38677	8712	13628	5
38678	8712	13629	5
38679	8712	13625	5
38680	8712	13630	6
38681	8712	13627	2
38682	8713	13647	4
38683	8713	13648	4
38684	8713	13649	7
38685	8713	13650	2
38686	8713	13651	1
38687	8714	13652	3
38688	8714	13653	3
38689	8714	13629	7
38690	8714	13654	3
38691	8714	13612	3
38692	8715	13655	1
38693	8715	13656	7
38694	8715	13657	4
38695	8715	13658	2
38696	8715	13643	2
38697	8716	13659	3
38698	8717	13660	12
38699	8718	13661	3
38700	8718	13662	9
38701	8719	13663	4
38702	8720	13664	5
38703	8721	13665	6
38704	8721	13666	5
38705	8722	13662	11
38706	8723	13667	4
38707	8723	13668	6
38708	8724	13669	4
38709	8725	13670	3
38710	8726	13671	9
38711	8727	13672	3
38712	8728	13673	5
38713	8729	13674	6
38714	8729	13675	11
38715	8729	13676	7
38716	8729	13677	8
38717	8729	13678	2
38718	8729	13679	9
38719	8730	13680	13
38720	8730	13681	14
38721	8730	13682	13
38722	8730	13683	14
38723	8730	13684	9
38724	8730	13685	9
38725	8730	13686	11
38726	8731	13687	4
38727	8731	13688	6
38728	8731	13689	1
38729	8731	13690	4
38730	8731	13691	1
38731	8732	13692	6
38732	8732	13693	3
38733	8732	13694	11
38734	8732	13695	6
38735	8732	13696	7
38736	8733	13697	5
38737	8733	13698	7
38738	8733	13676	6
38739	8733	13699	3
38740	8733	13700	3
38741	8734	13701	2
38742	8734	13702	9
38743	8734	13703	11
38744	8734	13704	5
38745	8734	13705	6
38746	8735	13706	7
38747	8735	13707	11
38748	8735	13704	3
38749	8735	13708	2
38750	8735	13705	8
38751	8736	13709	8
38752	8736	13710	7
38753	8736	13711	5
38754	8736	13712	2
38755	8737	13713	5
38756	8737	13714	4
38757	8737	13703	8
38758	8737	13712	4
38759	8737	13715	11
38760	8737	13705	6
38761	8738	13716	7
38762	8738	13715	11
38763	8738	13682	7
38764	8738	13704	7
38765	8738	13717	7
38766	8738	13677	6
38767	8739	13718	3
38768	8739	13706	8
38769	8739	13715	8
38770	8739	13704	4
38771	8739	13708	2
38772	8740	13719	12
38773	8740	13720	9
38774	8740	13721	7
38775	8740	13722	6
38776	8740	13723	2
38777	8741	13724	2
38778	8741	13725	4
38779	8741	13726	7
38780	8741	13727	2
38781	8741	13728	7
38782	8742	13729	8
38783	8742	13722	5
38784	8742	13730	4
38785	8742	13731	4
38786	8742	13723	3
38787	8743	13732	9
38788	8743	13729	9
38789	8743	13722	6
38790	8743	13733	8
38791	8743	13734	13
38792	8744	13735	6
38793	8744	13736	9
38794	8744	13722	9
38795	8744	13737	4
38796	8744	13723	7
38797	8745	13738	4
38798	8745	13739	9
38799	8745	13740	9
38800	8745	13723	8
38801	8746	13741	6
38802	8746	13720	10
38803	8746	13722	11
38804	8746	13742	6
38805	8747	13743	3
38806	8747	13744	2
38807	8747	13739	9
38808	8747	13740	7
38809	8747	13723	6
38810	8748	13745	5
38811	8748	13746	7
38812	8748	13747	7
38813	8748	13722	6
38814	8748	13723	7
38815	8749	13748	5
38816	8749	13749	11
38817	8749	13740	9
38818	8749	13750	6
38819	8749	13723	1
38820	8750	13751	8
38821	8750	13721	6
38822	8750	13740	6
38823	8750	13752	9
38824	8750	13753	8
38825	8751	13754	3
38826	8751	13755	7
38827	8751	13756	7
38828	8751	13757	6
38829	8751	13734	2
38830	8752	13758	3
38831	8752	13759	6
38832	8752	13760	9
38833	8752	13761	2
38834	8752	13762	3
38835	8753	13763	4
38836	8753	13764	7
38837	8753	13765	2
38838	8753	13766	5
38839	8753	13727	1
38840	8754	13767	4
38841	8754	13725	6
38842	8754	13768	6
38843	8754	13769	7
38844	8754	13770	6
38845	8755	13771	2
38846	8755	13772	9
38847	8755	13773	3
38848	8755	13774	3
38849	8755	13775	6
38850	8756	13776	7
38851	8756	13777	6
38852	8756	13778	8
38853	8756	13779	11
38854	8756	13770	6
38855	8757	13758	3
38856	8757	13759	9
38857	8757	13760	5
38858	8757	13761	9
38859	8757	13762	8
38860	8758	13780	6
38861	8758	13781	6
38862	8758	13782	4
38863	8758	13783	2
38864	8758	13770	6
38865	8759	13784	7
38866	8759	13725	5
38867	8759	13778	5
38868	8759	13785	9
38869	8759	13770	1
38870	8760	13758	3
38871	8760	13759	7
38872	8760	13760	6
38873	8760	13761	3
38874	8760	13762	6
38875	8761	13786	8
38876	8761	13759	8
38877	8761	13781	8
38878	8761	13761	9
38879	8761	13762	9
38880	8762	13787	4
38881	8762	13772	6
38882	8762	13788	5
38883	8762	13789	4
38884	8762	13775	5
38885	8763	13790	8
38886	8763	13791	11
38887	8763	13792	3
38888	8763	13793	8
38889	8763	13794	7
38890	8764	13795	6
38891	8764	13772	9
38892	8764	13796	5
38893	8764	13797	10
38894	8764	13775	7
38895	8765	13758	4
38896	8765	13759	6
38897	8765	13760	8
38898	8765	13761	3
38899	8765	13762	6
38900	8766	13798	6
38901	8766	13781	5
38902	8766	13799	5
38903	8766	13800	4
38904	8766	13801	1
38905	8767	13802	4
38906	8767	13803	6
38907	8767	13773	4
38908	8767	13804	2
38909	8767	13727	1
38910	8768	13805	6
38911	8768	13806	7
38912	8768	13807	6
38913	8768	13808	2
38914	8768	13770	6
38915	8769	13809	5
38916	8769	13736	4
38917	8769	13764	7
38918	8769	13810	7
38919	8769	13794	1
38920	8770	13811	3
38921	8770	13812	9
38922	8770	13813	8
38923	8770	13814	4
38924	8770	13727	1
38925	8771	13815	6
38926	8771	13816	5
38927	8771	13817	4
38928	8771	13818	6
38929	8771	13770	5
38930	8772	13819	5
38931	8772	13820	11
38932	8772	13821	4
38933	8772	13822	12
38934	8772	13770	5
38935	8773	13798	7
38936	8773	13781	8
38937	8773	13799	7
38938	8773	13800	3
38939	8773	13801	4
38940	8774	13823	6
38941	8774	13812	10
38942	8774	13824	8
38943	8774	13814	3
38944	8774	13727	11
38945	8775	13805	5
38946	8775	13806	8
38947	8775	13807	5
38948	8775	13808	1
38949	8775	13794	5
38950	8776	13798	6
38951	8776	13781	4
38952	8776	13799	8
38953	8776	13800	4
38954	8776	13801	1
38955	8777	13825	4
38956	8777	13772	7
38957	8777	13810	4
38958	8777	13826	8
38959	8777	13775	6
38960	8778	13827	7
38961	8778	13828	9
38962	8778	13796	5
38963	8778	13783	2
38964	8778	13794	6
38965	8779	13829	4
38966	8779	13772	8
38967	8779	13810	5
38968	8779	13826	9
38969	8779	13775	8
38970	8780	13830	3
38971	8780	13772	4
38972	8780	13831	9
38973	8780	13832	4
38974	8780	13775	3
38975	8781	13833	12
38976	8781	13772	1
38977	8781	13834	8
38978	8781	13826	7
38979	8781	13775	5
38980	8782	13798	4
38981	8782	13781	9
38982	8782	13799	9
38983	8782	13800	4
38984	8782	13801	5
38985	8783	13835	1
38986	8783	13836	3
38987	8783	13837	8
38988	8783	13838	3
38989	8783	13839	4
38990	8784	13840	5
38991	8784	13841	5
38992	8784	13842	2
38993	8784	13843	7
38994	8784	13839	5
38995	8785	13844	1
38996	8785	13845	2
38997	8785	13837	11
38998	8785	13846	1
38999	8785	13839	11
39000	8786	13847	8
39001	8786	13848	12
39002	8786	13849	8
39003	8786	13850	10
39004	8786	13851	7
39005	8787	13852	5
39006	8787	13853	6
39007	8787	13854	12
39008	8787	13855	3
39009	8787	13856	12
39010	8787	13857	3
39011	8788	13847	6
39012	8788	13858	14
39013	8788	13859	4
39014	8788	13860	7
39015	8788	13854	9
39016	8788	13861	12
39017	8788	13862	11
39018	8789	13863	7
39019	8789	13864	5
39020	8789	13865	2
39021	8789	13866	2
39022	8789	13861	3
39023	8789	13867	12
39024	8789	13868	7
39025	8790	13849	7
39026	8790	13869	8
39027	8790	13870	5
39028	8790	13871	8
39029	8790	13872	6
39030	8791	13873	2
39031	8791	13874	11
39032	8791	13875	6
39033	8791	13871	8
39034	8791	13876	6
39035	8791	13877	2
39036	8792	13878	7
39037	8792	13879	8
39038	8792	13870	7
39039	8792	13875	7
39040	8792	13880	9
39041	8793	13881	6
39042	8793	13882	6
39043	8793	13883	11
39044	8793	13884	8
39045	8793	13885	12
39046	8793	13886	5
39047	8794	13887	9
39048	8794	13888	13
39049	8794	13889	7
39050	8794	13890	7
39051	8794	13891	3
39052	8794	13892	6
39053	8795	13891	5
39054	8795	13893	11
39055	8795	13870	1
39056	8795	13885	7
39057	8795	13892	5
39058	8796	13894	4
39059	8796	13860	12
39060	8796	13880	5
39061	8796	13855	6
39062	8796	13895	3
39063	8796	13896	12
39064	8796	13897	11
39065	8797	13874	11
39066	8797	13898	8
39067	8797	13860	5
39068	8797	13871	9
39069	8797	13899	5
39070	8798	13900	12
39071	8798	13901	11
39072	8798	13902	8
39073	8798	13903	1
39074	8798	13898	7
39075	8798	13904	5
39076	8799	13905	8
39077	8799	13906	7
39078	8799	13907	9
39079	8799	13908	6
39080	8799	13909	7
39081	8800	13849	7
39082	8800	13890	8
39083	8800	13910	6
39084	8800	13911	3
39085	8800	13912	6
39086	8800	13870	8
39087	8801	13913	10
39088	8801	13910	8
39089	8801	13914	5
39090	8801	13870	11
39091	8801	13892	9
39092	8802	13915	8
39093	8802	13916	13
39094	8802	13917	13
39095	8802	13918	6
39096	8802	13870	9
39097	8803	13919	2
39098	8803	13920	9
39099	8803	13849	8
39100	8803	13921	9
39101	8803	13922	6
39102	8803	13923	13
39103	8804	13924	6
39104	8804	13925	4
39105	8804	13926	7
39106	8804	13927	5
39107	8804	13884	3
39108	8805	13928	4
39109	8805	13889	9
39110	8805	13929	11
39111	8805	13898	13
39112	8805	13930	12
39113	8806	13889	6
39114	8806	13931	11
39115	8806	13932	9
39116	8806	13933	5
39117	8806	13923	7
39118	8807	13934	5
39119	8807	13935	9
39120	8807	13925	11
39121	8807	13910	11
39122	8807	13870	5
39123	8808	13936	4
39124	8808	13937	5
39125	8808	13938	9
39126	8808	13939	1
39127	8808	13884	13
39128	8808	13897	8
39129	8809	13940	3
39130	8809	13941	9
39131	8809	13942	5
39132	8809	13943	5
39133	8809	13944	6
39134	8810	13945	2
39135	8810	13849	6
39136	8810	13931	8
39137	8810	13946	6
39138	8810	13870	9
39139	8810	13947	3
39140	8811	13948	4
39141	8811	13949	5
39142	8811	13950	6
39143	8811	13951	7
39144	8811	13952	3
39145	8812	13953	4
39146	8812	13954	5
39147	8812	13955	2
39148	8812	13956	3
39149	8812	13957	2
39150	8813	13958	6
39151	8813	13959	9
39152	8813	13960	6
39153	8813	13961	9
39154	8813	13962	6
39155	8814	13963	2
39156	8814	13964	11
39157	8814	13882	8
39158	8814	13965	1
39159	8814	13909	5
39160	8815	13966	5
39161	8815	13967	7
39162	8815	13968	8
39163	8815	13969	4
39164	8815	13957	7
39165	8816	13970	7
39166	8816	13971	5
39167	8816	13950	10
39168	8816	13972	2
39169	8816	13973	9
39170	8817	13974	12
39171	8817	13975	9
39172	8817	13976	2
39173	8817	13977	3
39174	8817	13851	3
39175	8818	13978	5
39176	8818	13979	6
39177	8818	13980	7
39178	8818	13981	5
39179	8818	13973	1
39180	8819	13982	5
39181	8819	13948	4
39182	8819	13959	8
39183	8819	13983	2
39184	8819	13973	7
39185	8820	13984	9
39186	8820	13979	7
39187	8820	13985	8
39188	8820	13986	13
39189	8820	13987	9
39190	8821	13988	4
39191	8821	13941	6
39192	8821	13882	7
39193	8821	13989	8
39194	8821	13909	5
39195	8822	13990	3
39196	8822	13991	8
39197	8822	13853	6
39198	8822	13903	2
39199	8822	13962	10
39200	8823	13988	5
39201	8823	13992	10
39202	8823	13993	11
39203	8823	13994	8
39204	8823	13909	5
39205	8824	13995	6
39206	8824	13950	7
39207	8824	13996	2
39208	8824	13939	3
39209	8824	13973	6
39210	8825	13997	8
39211	8825	13998	3
39212	8825	13999	8
39213	8825	14000	5
39214	8825	13957	1
39215	8826	14001	2
39216	8826	14002	6
39217	8826	13961	4
39218	8826	14003	4
39219	8826	13987	6
39220	8827	14004	5
39221	8827	14005	8
39222	8827	14006	7
39223	8827	13972	2
39224	8827	13957	3
39225	8828	14007	8
39226	8828	13968	9
39227	8828	14008	5
39228	8828	14009	2
39229	8828	13909	4
39230	8829	14010	7
39231	8829	14011	11
39232	8829	14012	6
39233	8829	13859	6
39234	8829	14003	8
39235	8830	14013	8
39236	8830	14014	10
39237	8830	13979	3
39238	8830	14015	2
39239	8830	14016	6
39240	8830	14003	8
39241	8831	14017	2
39242	8831	14018	7
39243	8831	14019	5
39244	8831	13942	4
39245	8831	13962	3
39246	8832	14020	5
39247	8832	13998	3
39248	8832	14002	8
39249	8832	14021	6
39250	8832	13909	7
39251	8833	14022	4
39252	8833	14023	13
39253	8833	14019	4
39254	8833	14024	1
39255	8833	13952	2
39256	8834	14004	5
39257	8834	14025	9
39258	8834	14006	7
39259	8834	13972	2
39260	8834	13977	9
39261	8835	14026	4
39262	8835	13998	4
39263	8835	13964	9
39264	8835	14027	5
39265	8835	13957	1
39266	8836	14028	2
39267	8836	14029	6
39268	8836	14030	4
39269	8836	13859	6
39270	8836	13909	5
39271	8837	14031	3
39272	8837	14032	9
39273	8837	14033	4
39274	8837	14021	4
39275	8837	13977	6
39276	8838	14034	5
39277	8838	13992	9
39278	8838	13993	8
39279	8838	14035	7
39280	8838	13909	7
39281	8839	14036	4
39282	8839	14005	3
39283	8839	13882	8
39284	8839	14009	5
39285	8839	13962	3
39286	8840	14037	7
39287	8840	13950	6
39288	8840	13960	7
39289	8840	14038	12
39290	8840	13909	9
39291	8841	14039	3
39292	8841	14040	4
39293	8841	14041	11
39294	8841	14042	7
39295	8841	13973	8
39296	8842	13978	5
39297	8842	13950	7
39298	8842	14027	7
39299	8842	14043	5
39300	8842	14003	8
39301	8843	13945	3
39302	8843	14023	7
39303	8843	14044	11
39304	8843	14045	2
39305	8843	13957	4
39306	8844	14046	2
39307	8844	14047	8
39308	8844	14048	4
39309	8844	14049	5
39310	8844	13944	8
39311	8845	14050	8
39312	8846	14051	4
39313	8846	14052	6
39314	8847	14053	2
39315	8848	14054	2
39316	8849	14055	4
39317	8850	14056	3
39318	8850	14057	5
39319	8850	14058	9
39320	8851	14059	3
39321	8851	14060	6
39322	8852	14061	6
39323	8853	14062	8
39324	8854	14063	8
39325	8855	14064	1
39326	8856	14065	9
39327	8857	14066	11
39328	8857	14060	7
39329	8858	14067	6
39330	8858	14068	8
39331	8859	14069	9
39332	8860	14070	8
39333	8861	14071	4
39334	8861	14072	2
39335	8862	14073	9
39336	8863	14074	9
39337	8864	14075	8
39338	8865	14076	2
39339	8865	14077	1
39340	8866	14078	3
39341	8867	14079	6
39342	8868	14080	11
39343	8869	14081	9
39344	8869	14082	6
39345	8870	14083	9
39346	8871	14084	3
39347	8871	14072	3
39348	8872	14085	3
39349	8872	14086	4
39350	8873	14080	11
39351	8874	14069	5
39352	8875	14078	9
39353	8876	14087	6
39354	8876	14073	7
39355	8877	14088	1
39356	8878	14089	8
39357	8879	14090	4
39358	8880	14091	12
39359	8880	14092	9
39360	8880	14093	11
39361	8880	14094	11
39362	8880	14095	11
39363	8881	14096	7
39364	8882	14097	13
39365	8882	14098	4
39366	8882	14099	11
39367	8882	14100	9
39368	8882	14092	5
39369	8882	14101	5
39370	8882	14102	2
39371	8883	14103	6
39372	8883	14104	4
39373	8883	14102	12
39374	8884	14105	5
39375	8884	14106	5
39376	8884	14107	14
39377	8884	14092	5
39378	8884	14108	4
39379	8884	14109	4
39380	8884	14110	13
39381	8885	14111	11
39382	8885	14112	9
39383	8885	14101	11
39384	8885	14113	2
39385	8885	14114	12
39386	8886	14098	2
39387	8886	14115	4
39388	8886	14116	13
39389	8886	14117	11
39390	8886	14118	5
39391	8886	14119	8
39392	8887	14120	7
39393	8887	14121	13
39394	8887	14117	9
39395	8887	14092	8
39396	8887	14118	5
39397	8887	14122	6
39398	8888	14123	5
39399	8888	14124	2
39400	8888	14125	2
39401	8888	14126	2
39402	8888	14127	8
39403	8889	14128	6
39404	8889	14129	5
39405	8889	14106	13
39406	8889	14130	14
39407	8889	14131	9
39408	8889	14132	8
39409	8889	14110	10
39410	8890	14133	4
39411	8890	14134	13
39412	8890	14092	8
39413	8890	14093	9
39414	8890	14108	4
39415	8891	14135	3
39416	8891	14106	11
39417	8891	14136	14
39418	8891	14137	8
39419	8891	14117	9
39420	8891	14122	4
39421	8891	14114	7
39422	8891	14095	8
39423	8892	14111	9
39424	8892	14138	3
39425	8892	14108	5
39426	8892	14101	6
39427	8892	14109	5
39428	8892	14110	11
39429	8893	14139	7
39430	8893	14106	11
39431	8893	14130	14
39432	8893	14092	5
39433	8893	14140	5
39434	8893	14118	12
39435	8893	14141	11
39436	8894	14142	6
39437	8894	14143	11
39438	8894	14144	10
39439	8894	14106	8
39440	8894	14136	14
39441	8894	14145	4
39442	8895	14146	4
39443	8895	14144	6
39444	8895	14106	7
39445	8895	14147	14
39446	8895	14148	5
39447	8895	14149	4
39448	8896	14150	4
39449	8896	14106	2
39450	8896	14136	14
39451	8896	14151	9
39452	8896	14140	5
39453	8896	14118	7
39454	8896	14152	11
39455	8896	14110	9
39456	8897	14153	5
39457	8897	14105	6
39458	8897	14106	11
39459	8897	14136	14
39460	8897	14131	9
39461	8897	14132	9
39462	8897	14141	9
39463	8898	14143	13
39464	8898	14144	11
39465	8898	14154	10
39466	8898	14155	9
39467	8898	14156	9
39468	8899	14157	3
39469	8899	14140	4
39470	8899	14113	4
39471	8899	14158	7
39472	8899	14110	11
39473	8900	14159	11
39474	8900	14160	11
39475	8900	14161	2
39476	8900	14162	6
39477	8900	14094	12
39478	8901	14163	8
39479	8901	14131	6
39480	8901	14132	9
39481	8901	14113	4
39482	8901	14164	4
39483	8901	14110	11
39484	8902	14165	13
39485	8902	14106	11
39486	8902	14130	14
39487	8902	14092	8
39488	8902	14140	3
39489	8902	14118	5
39490	8902	14141	8
39491	8903	14144	10
39492	8903	14106	11
39493	8903	14147	14
39494	8903	14092	6
39495	8903	14093	6
39496	8903	14108	5
39497	8903	14141	11
39498	8904	14166	6
39499	8904	14167	8
39500	8904	14106	5
39501	8904	14136	14
39502	8904	14131	3
39503	8904	14093	4
39504	8905	14168	2
39505	8905	14169	5
39506	8905	14170	11
39507	8905	14171	8
39508	8905	14126	4
39509	8906	14172	5
39510	8906	14106	6
39511	8906	14107	14
39512	8906	14092	3
39513	8906	14155	2
39514	8906	14118	6
39515	8906	14141	8
39516	8907	14173	4
39517	8907	14174	4
39518	8907	14175	11
39519	8907	14176	9
39520	8907	14177	4
39521	8908	14178	4
39522	8908	14179	3
39523	8908	14180	9
39524	8908	14181	9
39525	8908	14177	8
39526	8909	14182	3
39527	8909	14183	7
39528	8909	14184	8
39529	8909	14126	2
39530	8910	14185	2
39531	8910	14186	9
39532	8910	14187	3
39533	8910	14188	11
39534	8911	14189	5
39535	8911	14190	5
39536	8911	14191	5
39537	8911	14192	5
39538	8911	14145	2
39539	8912	14193	2
39540	8912	14194	9
39541	8912	14187	7
39542	8912	14195	7
39543	8912	14196	7
39544	8913	14197	3
39545	8913	14198	2
39546	8913	14175	7
39547	8913	14199	7
39548	8913	14177	5
39549	8914	14200	1
39550	8914	14201	9
39551	8914	14202	7
39552	8914	14203	3
39553	8914	14196	5
39554	8915	14204	11
39555	8915	14205	8
39556	8915	14206	2
39557	8915	14207	6
39558	8916	14208	5
39559	8916	14209	9
39560	8916	14210	11
39561	8916	14195	9
39562	8917	14211	3
39563	8917	14212	9
39564	8917	14213	7
39565	8917	14214	3
39566	8917	14145	7
39567	8918	14198	3
39568	8918	14215	3
39569	8918	14175	7
39570	8918	14216	8
39571	8918	14217	13
39572	8919	14198	3
39573	8919	14218	3
39574	8919	14191	7
39575	8919	14219	1
39576	8919	14217	9
39577	8920	14220	4
39578	8920	14183	7
39579	8920	14221	7
39580	8920	14145	1
39581	8921	14222	8
39582	8921	14223	9
39583	8921	14224	7
39584	8921	14225	3
39585	8921	14177	6
39586	8922	14226	11
39587	8922	14227	9
39588	8922	14228	8
39589	8922	14229	7
39590	8922	14207	3
39591	8923	14230	2
39592	8923	14231	7
39593	8923	14232	11
39594	8923	14233	3
39595	8923	14126	5
39596	8924	14234	12
39597	8924	14175	8
39598	8924	14216	9
39599	8924	14217	6
39600	8925	14235	2
39601	8925	14236	1
39602	8925	14186	13
39603	8925	14237	7
39604	8925	14126	3
39605	8926	14238	1
39606	8926	14239	7
39607	8926	14202	6
39608	8926	14240	5
39609	8926	14196	7
39610	8927	14241	5
39611	8927	14242	5
39612	8927	14243	9
39613	8927	14184	9
39614	8927	14126	2
39615	8928	14244	7
39616	8928	14245	9
39617	8928	14205	5
39618	8928	14207	9
39619	8929	14190	5
39620	8929	14246	9
39621	8929	14247	1
39622	8929	14248	5
39623	8929	14161	4
39624	8930	14249	2
39625	8930	14250	3
39626	8930	14251	3
39627	8930	14161	2
39628	8930	14131	4
39629	8931	14252	2
39630	8931	14253	5
39631	8931	14254	5
39632	8931	14145	4
39633	8931	14255	3
39634	8932	14256	3
39635	8932	14257	3
39636	8932	14258	8
39637	8932	14205	7
39638	8932	14196	9
39639	8933	14257	4
39640	8933	14259	9
39641	8933	14187	7
39642	8933	14260	8
39643	8933	14207	7
39644	8934	14261	4
39645	8934	14262	8
39646	8934	14263	9
39647	8934	14207	5
39648	8935	14190	11
39649	8935	14227	11
39650	8935	14264	12
39651	8935	14207	12
39652	8935	14131	11
39653	8936	14265	3
39654	8936	14253	7
39655	8936	14199	9
39656	8936	14266	5
39657	8936	14161	3
39658	8937	14267	4
39659	8937	14186	9
39660	8937	14187	5
39661	8937	14148	3
39662	8938	14268	3
39663	8938	14201	9
39664	8938	14269	6
39665	8938	14145	7
39666	8939	14270	2
39667	8939	14267	4
39668	8939	14186	8
39669	8939	14187	6
39670	8939	14148	4
39671	8940	14271	4
39672	8940	14258	9
39673	8940	14202	6
39674	8940	14266	2
39675	8940	14126	6
39676	8941	14256	3
39677	8941	14239	9
39678	8941	14187	9
39679	8941	14272	4
39680	8941	14196	8
39681	8942	14273	3
39682	8942	14274	9
39683	8942	14205	7
39684	8942	14275	1
39685	8942	14145	5
39686	8942	14131	6
39687	8943	14238	1
39688	8943	14239	9
39689	8943	14202	6
39690	8943	14240	6
39691	8943	14196	8
39692	8944	14276	6
39693	8944	14190	8
39694	8944	14277	7
39695	8944	14278	5
39696	8944	14161	2
39697	8945	14279	5
39698	8945	14280	11
39699	8945	14281	8
39700	8945	14282	4
39701	8945	14196	9
39702	8946	14198	2
39703	8946	14283	2
39704	8946	14284	6
39705	8946	14246	7
39706	8946	14126	3
39707	8947	14285	4
39708	8947	14286	4
39709	8947	14143	11
39710	8947	14287	8
39711	8947	14161	6
39712	8948	14288	7
39713	8948	14289	10
39714	8948	14237	8
39715	8948	14290	7
39716	8948	14145	7
39717	8949	14291	3
39718	8949	14258	13
39719	8949	14246	9
39720	8949	14233	3
39721	8949	14145	8
39722	8950	14292	4
39723	8950	14293	3
39724	8950	14280	7
39725	8950	14294	9
39726	8950	14228	8
39727	8950	14145	8
39728	8951	14295	7
39729	8951	14296	9
39730	8951	14297	12
39731	8951	14145	7
39732	8951	14298	4
39733	8952	14209	9
39734	8952	14205	9
39735	8952	14299	5
39736	8952	14126	9
39737	8953	14300	5
39738	8953	14301	1
39739	8953	14228	4
39740	8953	14302	7
39741	8953	14303	1
39742	8954	14304	5
39743	8954	14301	2
39744	8954	14305	3
39745	8954	14260	6
39746	8954	14303	3
39747	8955	14306	4
39748	8955	14307	8
39749	8955	14308	6
39750	8955	14309	1
39751	8955	14310	3
39752	8956	14311	5
39753	8956	14312	7
39754	8956	14313	5
39755	8956	14278	3
39756	8956	14314	9
39757	8957	14315	5
39758	8957	14316	4
39759	8957	14317	1
39760	8957	14318	1
39761	8957	14319	4
39762	8958	14320	4
39763	8958	14321	6
39764	8958	14322	7
39765	8958	14323	2
39766	8958	14314	3
39767	8959	14324	6
39768	8959	14325	8
39769	8959	14322	6
39770	8959	14326	3
39771	8959	14327	11
39772	8960	14166	5
39773	8960	14328	5
39774	8960	14329	5
39775	8960	14330	8
39776	8960	14314	8
39777	8961	14331	3
39778	8961	14332	6
39779	8961	14333	2
39780	8961	14334	1
39781	8961	14335	8
39782	8962	14306	3
39783	8962	14307	4
39784	8962	14308	4
39785	8962	14309	1
39786	8962	14310	2
39787	8963	14166	4
39788	8963	14336	2
39789	8963	14312	8
39790	8963	14337	1
39791	8963	14314	1
39792	8964	14338	3
39793	8964	14339	6
39794	8964	14316	8
39795	8964	14340	1
39796	8964	14319	7
39797	8965	14306	3
39798	8965	14307	5
39799	8965	14308	11
39800	8965	14309	6
39801	8965	14310	8
39802	8966	14324	5
39803	8966	14325	7
39804	8966	14322	7
39805	8966	14326	2
39806	8966	14327	7
39807	8967	14306	3
39808	8967	14307	6
39809	8967	14308	6
39810	8967	14309	1
39811	8967	14310	1
39812	8968	14324	5
39813	8968	14325	1
39814	8968	14322	4
39815	8968	14326	3
39816	8968	14327	1
39817	8969	14331	4
39818	8969	14332	3
39819	8969	14333	3
39820	8969	14334	3
39821	8969	14335	1
39822	8970	14341	4
39823	8970	14316	11
39824	8970	14317	6
39825	8970	14342	5
39826	8970	14319	8
39827	8971	14343	2
39828	8971	14344	5
39829	8971	14316	7
39830	8971	14319	5
39831	8971	14345	3
39832	8972	14273	1
39833	8972	14346	5
39834	8972	14347	1
39835	8972	14348	8
39836	8972	14148	4
39837	8973	14349	5
39838	8973	14350	6
39839	8973	14322	6
39840	8973	14351	2
39841	8973	14148	4
39842	8974	14352	6
39843	8974	14353	1
39844	8974	14354	2
39845	8974	14148	3
39846	8974	14355	3
39847	8975	14324	6
39848	8975	14325	8
39849	8975	14322	7
39850	8975	14326	3
39851	8975	14327	11
39852	8976	14324	6
39853	8976	14325	5
39854	8976	14322	7
39855	8976	14326	5
39856	8976	14327	7
39857	8977	14356	3
39858	8977	14301	2
39859	8977	14305	2
39860	8977	14357	5
39861	8977	14303	3
39862	8978	14331	4
39863	8978	14332	4
39864	8978	14333	1
39865	8978	14334	1
39866	8978	14335	7
39867	8979	14331	3
39868	8979	14332	5
39869	8979	14333	3
39870	8979	14334	2
39871	8979	14335	4
39872	8980	14358	7
39873	8980	14359	8
39874	8980	14313	4
39875	8980	14360	4
39876	8980	14314	8
39877	8981	14361	4
39878	8981	14301	3
39879	8981	14354	3
39880	8981	14362	8
39881	8981	14303	5
39882	8982	14324	5
39883	8982	14325	8
39884	8982	14322	4
39885	8982	14326	4
39886	8982	14327	9
39887	8983	14363	3
39888	8983	14344	5
39889	8983	14316	11
39890	8983	14364	6
39891	8983	14319	8
39892	8984	14365	5
39893	8984	14316	4
39894	8984	14228	7
39895	8984	14366	1
39896	8984	14319	4
39897	8985	14300	5
39898	8985	14301	1
39899	8985	14195	4
39900	8985	14367	1
39901	8985	14303	2
39902	8986	14368	5
39903	8986	14316	5
39904	8986	14317	2
39905	8986	14348	6
39906	8986	14319	5
39907	8987	14300	4
39908	8987	14301	4
39909	8987	14369	2
39910	8987	14370	2
39911	8987	14303	3
39912	8988	14371	3
39913	8988	14301	6
39914	8988	14347	7
39915	8988	14372	1
39916	8988	14303	3
39917	8989	14373	4
39918	8989	14316	11
39919	8989	14369	2
39920	8989	14374	5
39921	8989	14319	5
39922	8990	14375	6
39923	8990	14336	6
39924	8990	14376	9
39925	8990	14377	5
39926	8990	14314	9
39927	8991	14324	6
39928	8991	14325	8
39929	8991	14322	6
39930	8991	14326	5
39931	8991	14327	2
39932	8992	14324	6
39933	8992	14325	6
39934	8992	14322	4
39935	8992	14326	7
39936	8992	14327	1
39937	8993	14315	5
39938	8993	14316	7
39939	8993	14195	7
39940	8993	14364	5
39941	8993	14319	4
39942	8994	14358	7
39943	8994	14378	1
39944	8994	14329	4
39945	8994	14379	3
39946	8994	14319	5
39947	8995	14306	3
39948	8995	14307	4
39949	8995	14308	5
39950	8995	14309	1
39951	8995	14310	1
39952	8996	14324	5
39953	8996	14325	8
39954	8996	14322	8
39955	8996	14326	6
39956	8996	14327	5
39957	8997	14380	3
39958	8997	14381	3
39959	8997	14301	4
39960	8997	14347	2
39961	8997	14303	2
39962	8998	14331	4
39963	8998	14332	6
39964	8998	14333	3
39965	8998	14334	1
39966	8998	14335	1
39967	8999	14382	5
39968	8999	14383	7
39969	8999	14333	1
39970	8999	14384	5
39971	8999	14314	9
39972	9000	14306	4
39973	9000	14307	5
39974	9000	14308	2
39975	9000	14309	2
39976	9000	14310	3
39977	9001	14331	2
39978	9001	14332	4
39979	9001	14333	1
39980	9001	14334	1
39981	9001	14335	1
39982	9002	14311	5
39983	9002	14336	4
39984	9002	14312	9
39985	9002	14385	6
39986	9002	14314	5
39987	9003	14386	3
39988	9003	14336	7
39989	9003	14387	8
39990	9003	14266	2
39991	9003	14314	7
39992	9004	14306	2
39993	9004	14307	4
39994	9004	14308	5
39995	9004	14309	1
39996	9004	14310	1
39997	9005	14306	4
39998	9005	14307	5
39999	9005	14308	9
40000	9005	14309	2
40001	9005	14310	2
40002	9006	14306	3
40003	9006	14307	5
40004	9006	14308	6
40005	9006	14309	2
40006	9006	14310	3
40007	9007	14388	3
40008	9007	14301	2
40009	9007	14354	5
40010	9007	14389	1
40011	9007	14303	3
40012	9008	14324	7
40013	9008	14325	6
40014	9008	14322	7
40015	9008	14326	6
40016	9008	14327	6
40017	9009	14363	9
40018	9009	14316	6
40019	9009	14228	3
40020	9009	14362	9
40021	9009	14319	1
40022	9010	14352	5
40023	9010	14378	1
40024	9010	14322	1
40025	9010	14362	1
40026	9010	14319	1
40027	9011	14390	4
40028	9011	14316	1
40029	9011	14299	2
40030	9011	14391	1
40031	9011	14319	3
40032	9012	14343	3
40033	9012	14316	1
40034	9012	14317	4
40035	9012	14391	2
40036	9012	14319	1
40037	9013	14361	4
40038	9013	14392	4
40039	9013	14316	6
40040	9013	14299	3
40041	9013	14319	1
40042	9014	14390	4
40043	9014	14393	5
40044	9014	14301	4
40045	9014	14394	4
40046	9014	14303	5
40047	9015	14395	4
40048	9015	14346	9
40049	9015	14299	4
40050	9015	14396	5
40051	9015	14314	1
40052	9016	14397	5
40053	9016	14301	1
40054	9016	14228	2
40055	9016	14398	2
40056	9016	14303	3
40057	9017	14128	5
40058	9017	14399	6
40059	9017	14228	6
40060	9017	14400	5
40061	9017	14314	8
40062	9018	14331	3
40063	9018	14332	3
40064	9018	14333	1
40065	9018	14334	1
40066	9018	14335	1
40067	9019	14324	6
40068	9019	14325	6
40069	9019	14322	5
40070	9019	14326	3
40071	9019	14327	6
40072	9020	14401	8
40073	9020	14316	5
40074	9020	14317	2
40075	9020	14362	10
40076	9020	14319	6
40077	9021	14324	6
40078	9021	14325	9
40079	9021	14322	7
40080	9021	14326	2
40081	9021	14327	7
40082	9022	14324	6
40083	9022	14325	11
40084	9022	14322	8
40085	9022	14326	6
40086	9022	14327	7
40087	9023	14402	5
40088	9023	14307	3
40089	9023	14403	2
40090	9023	14404	1
40091	9023	14314	1
40092	9024	14306	3
40093	9024	14307	7
40094	9024	14308	9
40095	9024	14309	1
40096	9024	14310	4
40097	9025	14352	5
40098	9025	14301	3
40099	9025	14405	2
40100	9025	14303	4
40101	9025	14406	3
40102	9026	14407	3
40103	9026	14307	6
40104	9026	14308	3
40105	9026	14309	2
40106	9026	14310	2
40107	9027	14306	5
40108	9027	14307	4
40109	9027	14308	2
40110	9027	14309	1
40111	9027	14310	1
40112	9028	14306	4
40113	9028	14307	6
40114	9028	14308	8
40115	9028	14309	2
40116	9028	14310	4
40117	9029	14306	4
40118	9029	14307	7
40119	9029	14308	8
40120	9029	14309	2
40121	9029	14310	5
40122	9030	14363	5
40123	9030	14316	6
40124	9030	14333	1
40125	9030	14408	1
40126	9030	14319	5
40127	9031	14331	3
40128	9031	14332	9
40129	9031	14333	2
40130	9031	14334	1
40131	9031	14335	5
40132	9032	14381	6
40133	9032	14316	6
40134	9032	14409	6
40135	9032	14319	6
40136	9032	14158	8
40137	9033	14331	4
40138	9033	14332	6
40139	9033	14333	2
40140	9033	14334	2
40141	9033	14335	8
40142	9034	14306	5
40143	9034	14307	8
40144	9034	14308	8
40145	9034	14309	4
40146	9034	14310	1
40147	9035	14306	4
40148	9035	14307	8
40149	9035	14308	9
40150	9035	14309	3
40151	9035	14310	8
40152	9036	14331	3
40153	9036	14332	7
40154	9036	14333	3
40155	9036	14334	1
40156	9036	14335	3
40157	9037	14324	6
40158	9037	14325	7
40159	9037	14322	6
40160	9037	14326	3
40161	9037	14327	2
40162	9038	14311	4
40163	9038	14410	11
40164	9038	14322	6
40165	9038	14379	4
40166	9038	14314	1
40167	9039	14324	4
40168	9039	14325	9
40169	9039	14322	7
40170	9039	14326	6
40171	9039	14327	4
40172	9040	14331	5
40173	9040	14332	9
40174	9040	14333	4
40175	9040	14334	1
40176	9040	14335	9
40177	9041	14411	4
40178	9041	14412	5
40179	9041	14316	6
40180	9041	14413	1
40181	9041	14319	4
40182	9042	14338	4
40183	9042	14316	8
40184	9042	14333	3
40185	9042	14414	9
40186	9042	14319	6
40187	9043	14331	3
40188	9043	14332	9
40189	9043	14333	1
40190	9043	14334	3
40191	9043	14335	4
40192	9044	14306	3
40193	9044	14307	6
40194	9044	14308	7
40195	9044	14309	4
40196	9044	14310	5
40197	9045	14324	7
40198	9045	14325	9
40199	9045	14322	7
40200	9045	14326	6
40201	9045	14327	10
40202	9046	14415	5
40203	9046	14321	4
40204	9046	14360	2
40205	9046	14177	4
40206	9046	14164	2
40207	9047	14173	3
40208	9047	14169	6
40209	9047	14416	7
40210	9047	14177	5
40211	9047	14158	6
40212	9048	14197	1
40213	9048	14399	5
40214	9048	14329	5
40215	9048	14113	2
40216	9048	14177	1
40217	9049	14417	11
40218	9049	14418	10
40219	9049	14419	7
40220	9049	14420	11
40221	9049	14421	9
40222	9049	14422	1
40223	9050	14423	6
40224	9050	14424	4
40225	9050	14425	3
40226	9050	14426	2
40227	9050	14427	3
40228	9050	14428	14
40229	9050	14429	1
40230	9050	14430	11
40231	9051	14431	6
40232	9051	14427	3
40233	9051	14428	14
40234	9051	14419	5
40235	9051	14432	4
40236	9051	14420	2
40237	9051	14433	4
40238	9052	14434	4
40239	9052	14435	3
40240	9052	14427	4
40241	9052	14436	14
40242	9052	14437	9
40243	9053	14438	3
40244	9053	14439	5
40245	9053	14440	2
40246	9053	14441	7
40247	9053	14442	10
40248	9054	14443	7
40249	9054	14429	5
40250	9054	14444	7
40251	9054	14441	7
40252	9054	14445	9
40253	9055	14446	13
40254	9055	14447	4
40255	9055	14448	4
40256	9055	14449	7
40257	9055	14450	9
40258	9055	14451	3
40259	9056	14452	2
40260	9056	14453	7
40261	9056	14444	13
40262	9056	14454	7
40263	9056	14455	3
40264	9057	14456	8
40265	9057	14427	3
40266	9057	14428	14
40267	9057	14453	7
40268	9057	14432	1
40269	9057	14420	1
40270	9057	14433	7
40271	9058	14457	13
40272	9058	14458	8
40273	9058	14459	5
40274	9058	14444	13
40275	9058	14460	5
40276	9058	14461	2
40277	9058	14462	12
40278	9059	14463	9
40279	9059	14427	11
40280	9059	14464	14
40281	9059	14429	5
40282	9059	14441	8
40283	9060	14465	10
40284	9060	14466	6
40285	9060	14453	6
40286	9060	14429	6
40287	9060	14461	2
40288	9060	14432	7
40289	9060	14445	13
40290	9061	14467	7
40291	9061	14468	7
40292	9061	14427	4
40293	9061	14428	14
40294	9061	14419	6
40295	9061	14450	9
40296	9061	14469	8
40297	9062	14470	3
40298	9062	14471	4
40299	9062	14472	3
40300	9062	14427	11
40301	9062	14464	14
40302	9062	14448	7
40303	9062	14473	9
40304	9063	14474	4
40305	9063	14427	5
40306	9063	14436	14
40307	9063	14419	6
40308	9063	14475	4
40309	9063	14476	3
40310	9063	14449	4
40311	9064	14477	9
40312	9064	14478	5
40313	9064	14448	7
40314	9064	14479	7
40315	9064	14444	4
40316	9064	14480	4
40317	9065	14481	12
40318	9065	14482	11
40319	9065	14483	8
40320	9065	14484	9
40321	9065	14485	12
40322	9065	14469	5
40323	9066	14486	2
40324	9066	14487	2
40325	9066	14445	9
40326	9066	14488	6
40327	9066	14489	4
40328	9066	14490	2
40329	9067	14491	7
40330	9067	14492	11
40331	9067	14444	13
40332	9067	14476	13
40333	9067	14485	13
40334	9068	14493	1
40335	9068	14494	2
40336	9068	14495	5
40337	9068	14445	8
40338	9068	14489	3
40339	9069	14456	13
40340	9069	14496	4
40341	9069	14419	5
40342	9069	14497	5
40343	9069	14475	2
40344	9069	14476	7
40345	9070	14498	9
40346	9070	14499	7
40347	9070	14429	3
40348	9070	14432	4
40349	9070	14454	8
40350	9070	14433	7
40351	9071	14500	4
40352	9071	14448	3
40353	9071	14479	9
40354	9071	14444	6
40355	9072	14501	6
40356	9072	14502	9
40357	9072	14503	5
40358	9072	14447	7
40359	9072	14488	11
40360	9073	14504	8
40361	9073	14427	5
40362	9073	14505	14
40363	9073	14479	7
40364	9073	14432	5
40365	9073	14454	6
40366	9073	14506	8
40367	9074	14507	8
40368	9074	14508	7
40369	9074	14483	7
40370	9074	14509	9
40371	9074	14510	9
40372	9075	14511	11
40373	9075	14512	9
40374	9075	14513	3
40375	9075	14514	2
40376	9075	14473	9
40377	9076	14515	8
40378	9076	14516	6
40379	9076	14431	11
40380	9076	14447	8
40381	9076	14517	11
40382	9077	14518	3
40383	9077	14515	9
40384	9077	14519	6
40385	9077	14520	7
40386	9077	14521	3
40387	9077	14522	1
40388	9078	14523	4
40389	9078	14467	8
40390	9078	14524	3
40391	9078	14525	4
40392	9078	14488	5
40393	9078	14480	6
40394	9079	14526	3
40395	9079	14527	8
40396	9079	14528	11
40397	9079	14529	9
40398	9079	14488	7
40399	9079	14517	3
40400	9080	14530	9
40401	9080	14531	9
40402	9080	14532	6
40403	9080	14533	5
40404	9080	14480	11
40405	9081	14502	10
40406	9081	14534	11
40407	9081	14519	8
40408	9081	14535	4
40409	9081	14536	4
40410	9081	14537	11
40411	9082	14538	5
40412	9082	14512	7
40413	9082	14539	5
40414	9082	14537	9
40415	9082	14517	11
40416	9083	14540	10
40417	9083	14541	5
40418	9083	14447	8
40419	9083	14450	11
40420	9083	14469	8
40421	9084	14542	5
40422	9084	14543	11
40423	9084	14524	8
40424	9084	14450	7
40425	9084	14469	6
40426	9085	14530	9
40427	9085	14544	4
40428	9085	14545	2
40429	9085	14533	5
40430	9085	14480	9
40431	9086	14546	8
40432	9086	14547	6
40433	9086	14548	7
40434	9086	14447	5
40435	9086	14549	7
40436	9086	14480	8
40437	9087	14550	8
40438	9087	14551	9
40439	9087	14552	7
40440	9087	14553	7
40441	9087	14450	1
40442	9087	14480	4
40443	9088	14554	5
40444	9088	14555	3
40445	9088	14556	6
40446	9088	14531	8
40447	9088	14557	8
40448	9088	14517	8
40449	9089	14558	13
40450	9089	14559	9
40451	9089	14524	11
40452	9089	14450	7
40453	9089	14469	8
40454	9090	14560	7
40455	9090	14561	9
40456	9090	14502	9
40457	9090	14562	13
40458	9090	14563	8
40459	9090	14564	10
40460	9091	14565	3
40461	9091	14566	8
40462	9091	14567	8
40463	9091	14447	6
40464	9091	14488	7
40465	9091	14480	7
40466	9092	14568	7
40467	9092	14569	9
40468	9092	14447	7
40469	9092	14549	6
40470	9092	14480	11
40471	9093	14570	4
40472	9093	14571	9
40473	9093	14531	10
40474	9093	14572	5
40475	9093	14488	8
40476	9093	14469	6
40477	9094	14573	9
40478	9094	14574	11
40479	9094	14575	6
40480	9094	14455	4
40481	9095	14502	9
40482	9095	14576	11
40483	9095	14524	9
40484	9095	14577	4
40485	9095	14447	9
40486	9095	14488	7
40487	9096	14578	6
40488	9096	14530	10
40489	9096	14579	5
40490	9096	14572	6
40491	9096	14450	9
40492	9097	14502	10
40493	9097	14556	6
40494	9097	14512	11
40495	9097	14498	6
40496	9097	14569	10
40497	9097	14549	8
40498	9098	14580	8
40499	9098	14503	2
40500	9098	14581	4
40501	9098	14582	6
40502	9098	14469	5
40503	9099	14583	2
40504	9099	14584	4
40505	9099	14585	9
40506	9099	14586	7
40507	9100	14587	3
40508	9100	14588	9
40509	9100	14589	1
40510	9100	14537	11
40511	9100	14517	11
40512	9101	14590	5
40513	9101	14515	13
40514	9101	14516	8
40515	9101	14591	3
40516	9101	14549	9
40517	9101	14517	11
40518	9102	14502	9
40519	9102	14592	9
40520	9102	14593	8
40521	9102	14594	6
40522	9102	14537	11
40523	9103	14595	3
40524	9103	14596	5
40525	9103	14568	9
40526	9103	14597	9
40527	9103	14549	11
40528	9103	14517	11
40529	9104	14598	6
40530	9104	14559	9
40531	9104	14599	6
40532	9104	14498	11
40533	9104	14549	9
40534	9105	14600	2
40535	9105	14601	4
40536	9105	14528	13
40537	9105	14602	9
40538	9105	14450	9
40539	9105	14469	6
40540	9106	14588	8
40541	9106	14529	6
40542	9106	14520	4
40543	9106	14603	2
40544	9106	14510	7
40545	9106	14480	6
40546	9107	14604	5
40547	9107	14605	10
40548	9107	14606	11
40549	9107	14607	7
40550	9107	14488	9
40551	9107	14469	7
40552	9108	14608	3
40553	9108	14609	7
40554	9108	14607	5
40555	9108	14533	4
40556	9108	14480	8
40557	9109	14571	9
40558	9109	14607	9
40559	9109	14610	3
40560	9109	14447	8
40561	9109	14549	9
40562	9109	14480	11
40563	9110	14611	4
40564	9110	14576	9
40565	9110	14553	7
40566	9110	14468	6
40567	9110	14549	9
40568	9110	14517	11
40569	9111	14612	8
40570	9111	14444	3
40571	9111	14449	9
40572	9111	14454	9
40573	9111	14451	2
40574	9111	14517	11
40575	9112	14613	6
40576	9112	14614	6
40577	9112	14615	9
40578	9112	14616	4
40579	9112	14537	6
40580	9112	14469	6
40581	9113	14617	5
40582	9113	14618	9
40583	9113	14612	8
40584	9113	14619	4
40585	9113	14488	8
40586	9113	14517	11
40587	9114	14614	6
40588	9114	14512	11
40589	9114	14620	10
40590	9114	14616	4
40591	9114	14549	11
40592	9114	14469	6
40593	9115	14621	4
40594	9115	14622	3
40595	9115	14482	8
40596	9115	14623	7
40597	9115	14586	5
40598	9115	14517	7
40599	9116	14568	2
40600	9116	14492	4
40601	9116	14447	1
40602	9116	14488	2
40603	9116	14624	3
40604	9117	14625	6
40605	9117	14467	7
40606	9117	14532	8
40607	9117	14626	11
40608	9117	14450	11
40609	9117	14469	14
40610	9118	14579	8
40611	9118	14627	1
40612	9118	14628	3
40613	9118	14549	7
40614	9118	14469	7
40615	9119	14629	6
40616	9119	14630	4
40617	9119	14540	6
40618	9119	14631	5
40619	9119	14632	7
40620	9119	14633	5
40621	9120	14634	9
40622	9120	14635	7
40623	9120	14636	7
40624	9120	14537	9
40625	9120	14480	8
40626	9121	14560	9
40627	9121	14576	4
40628	9121	14553	11
40629	9121	14537	9
40630	9121	14517	8
40631	9122	14637	2
40632	9122	14560	2
40633	9122	14483	6
40634	9122	14549	11
40635	9122	14469	6
40636	9123	14638	4
40637	9123	14639	4
40638	9123	14640	5
40639	9123	14641	1
40640	9123	14642	1
40641	9124	14643	3
40642	9124	14644	5
40643	9124	14468	8
40644	9124	14645	1
40645	9124	14646	7
40646	9125	14647	3
40647	9125	14648	5
40648	9125	14649	7
40649	9125	14650	1
40650	9125	14533	6
40651	9126	14651	6
40652	9126	14652	7
40653	9126	14653	4
40654	9126	14473	8
40655	9126	14624	4
40659	9127	14656	1
40660	9127	14473	12
40661	9128	14638	5
40662	9128	14657	4
40663	9128	14658	3
40664	9128	14644	7
40665	9128	14659	4
40666	9128	14473	3
40667	9129	14660	4
40668	9129	14652	5
40669	9129	14661	3
40670	9129	14662	4
40671	9129	14663	6
40672	9130	14664	6
40673	9130	14665	5
40674	9130	14652	8
40675	9130	14610	2
40676	9130	14473	7
40677	9131	14666	3
40678	9131	14654	9
40679	9131	14667	6
40680	9131	14668	2
40681	9131	14557	7
40682	9132	14669	3
40683	9132	14604	3
40684	9132	14649	5
40685	9132	14650	1
40686	9132	14642	2
40687	9133	14670	3
40688	9133	14671	3
40689	9133	14644	9
40690	9133	14672	3
40691	9133	14473	2
40692	9134	14424	2
40693	9134	14673	9
40694	9134	14468	5
40695	9134	14674	4
40696	9134	14557	5
40697	9135	14675	7
40698	9135	14676	4
40699	9135	14677	8
40700	9135	14603	3
40701	9135	14642	13
40702	9136	14660	3
40703	9136	14678	7
40704	9136	14661	4
40705	9136	14679	1
40706	9136	14522	4
40707	9137	14680	4
40708	9137	14649	7
40709	9137	14681	6
40710	9137	14650	1
40711	9137	14642	3
40712	9138	14682	2
40713	9138	14683	4
40714	9138	14678	4
40715	9138	14656	1
40716	9138	14522	2
40717	9139	14625	1
40718	9139	14684	7
40719	9139	14498	7
40720	9139	14628	3
40721	9139	14557	1
40722	9140	14685	4
40723	9140	14686	8
40724	9140	14667	11
40725	9140	14687	4
40726	9140	14646	8
40727	9141	14637	2
40728	9141	14688	3
40729	9141	14689	11
40730	9141	14690	1
40731	9141	14691	2
40732	9141	14533	6
40733	9142	14692	3
40734	9142	14693	4
40735	9142	14431	4
40736	9142	14694	2
40737	9142	14646	6
40738	9143	14695	3
40739	9143	14696	6
40740	9143	14697	9
40741	9143	14698	1
40742	9143	14522	1
40743	9144	14666	2
40744	9144	14699	2
40745	9144	14644	5
40746	9144	14642	1
40747	9144	14700	2
40748	9145	14701	5
40749	9145	14630	7
40750	9145	14702	9
40751	9145	14703	3
40752	9145	14663	2
40753	9146	14704	3
40754	9146	14683	6
40755	9146	14705	8
40756	9146	14641	3
40757	9146	14510	5
40758	9147	14706	4
40759	9147	14707	3
40760	9147	14667	6
40761	9147	14708	5
40762	9147	14533	3
40763	9148	14709	4
40764	9148	14710	3
40765	9148	14585	7
40766	9148	14668	2
40767	9148	14557	11
40768	9149	14710	3
40769	9149	14711	4
40770	9149	14667	5
40771	9149	14498	7
40772	9149	14557	4
40773	9150	14712	5
40774	9150	14658	6
40775	9150	14705	8
40776	9150	14713	2
40777	9150	14557	7
40778	9151	14660	3
40779	9151	14714	7
40780	9151	14644	9
40781	9151	14687	2
40782	9151	14646	3
40783	9152	14660	3
40784	9152	14678	6
40785	9152	14661	4
40786	9152	14674	4
40787	9152	14522	3
40788	9153	14637	2
40789	9153	14715	3
40790	9153	14716	9
40791	9153	14717	4
40792	9153	14533	8
40793	9154	14718	3
40794	9154	14573	9
40795	9154	14719	4
40796	9154	14628	4
40797	9154	14557	9
40798	9155	14678	6
40799	9155	14720	4
40800	9155	14721	2
40801	9155	14641	6
40802	9155	14557	3
40803	9156	14546	4
40804	9156	14654	8
40805	9156	14681	3
40806	9156	14722	3
40807	9156	14642	1
40808	9157	14723	3
40809	9157	14640	6
40810	9157	14721	1
40811	9157	14724	4
40812	9157	14646	4
40813	9158	14725	12
40814	9158	14640	10
40815	9158	14681	8
40816	9158	14726	6
40817	9158	14646	8
40818	9159	14699	4
40819	9159	14686	7
40820	9159	14727	1
40821	9159	14728	3
40822	9159	14646	7
40823	9160	14660	4
40824	9160	14729	9
40825	9160	14730	2
40826	9160	14656	1
40827	9160	14473	8
40828	9161	14704	4
40829	9161	14683	6
40830	9161	14705	9
40831	9161	14641	1
40832	9161	14510	2
40833	9162	14660	3
40834	9162	14548	8
40835	9162	14661	3
40836	9162	14679	1
40837	9162	14522	1
40838	9163	14474	3
40839	9163	14731	4
40840	9163	14654	10
40657	9127	14654	11
40658	9127	14655	11
40841	9163	14732	4
40842	9163	14473	5
40843	9164	14629	5
40844	9164	14711	3
40845	9164	14431	3
40846	9164	14733	4
40847	9164	14522	3
40848	9165	14669	3
40849	9165	14649	9
40850	9165	14681	3
40851	9165	14650	1
40852	9165	14642	2
40853	9166	14704	3
40854	9166	14634	6
40855	9166	14678	8
40856	9166	14616	4
40857	9166	14510	5
40858	9167	14734	4
40859	9167	14735	7
40860	9167	14736	9
40861	9167	14737	4
40862	9167	14557	4
40863	9168	14738	4
40864	9168	14654	8
40865	9168	14498	6
40866	9168	14641	1
40867	9168	14557	1
40868	9169	14654	9
40869	9169	14721	3
40870	9169	14733	2
40871	9169	14650	4
40872	9169	14473	6
40873	9170	14657	3
40874	9170	14649	8
40875	9170	14739	1
40876	9170	14496	3
40877	9170	14642	8
40878	9171	14555	2
40879	9171	14585	6
40880	9171	14740	1
40881	9171	14733	9
40882	9171	14510	1
40883	9172	14664	6
40884	9172	14501	2
40885	9172	14652	8
40886	9172	14681	6
40887	9172	14741	3
40888	9172	14473	5
40889	9173	14664	5
40890	9173	14652	7
40891	9173	14681	9
40892	9173	14653	6
40893	9173	14473	8
40894	9174	14742	2
40895	9174	14729	5
40896	9174	14656	1
40897	9174	14646	1
40898	9174	14743	6
40899	9175	14669	4
40900	9175	14649	11
40901	9175	14681	8
40902	9175	14694	1
40903	9175	14642	7
40904	9176	14680	3
40905	9176	14604	2
40906	9176	14649	11
40907	9176	14650	1
40908	9176	14642	4
40909	9177	14744	1
40910	9177	14714	3
40911	9177	14745	9
40912	9177	14732	1
40913	9177	14646	7
40914	9178	14744	4
40915	9178	14714	4
40916	9178	14745	8
40917	9178	14746	3
40918	9178	14642	9
40919	9179	14747	2
40920	9179	14622	9
40921	9179	14705	8
40922	9179	14698	2
40923	9179	14473	5
40924	9180	14748	3
40925	9180	14644	2
40926	9180	14510	1
40927	9180	14743	4
40928	9180	14490	1
40929	9181	14738	2
40930	9181	14699	3
40931	9181	14654	4
40932	9181	14749	1
40933	9181	14646	1
40934	9182	14750	5
40935	9182	14654	2
40936	9182	14751	9
40937	9182	14642	1
40938	9182	14451	1
40939	9183	14752	4
40940	9183	14753	7
40941	9183	14622	8
40942	9183	14654	9
40943	9183	14646	5
40944	9184	14723	3
40945	9184	14745	9
40946	9184	14532	6
40947	9184	14726	4
40948	9184	14646	6
40949	9185	14754	5
40950	9185	14566	5
40951	9185	14644	7
40952	9185	14641	2
40953	9185	14473	2
40954	9186	14715	3
40955	9186	14755	2
40956	9186	14756	4
40957	9186	14757	2
40958	9186	14646	2
40959	9187	14758	5
40960	9187	14652	7
40961	9187	14532	6
40962	9187	14674	7
40963	9187	14473	12
40964	9188	14759	5
40965	9188	14585	4
40966	9188	14498	6
40967	9188	14641	1
40968	9188	14557	1
40969	9189	14660	4
40970	9189	14678	6
40971	9189	14661	3
40972	9189	14679	1
40973	9189	14522	5
40974	9190	14760	4
40975	9190	14654	8
40976	9190	14691	2
40977	9190	14616	1
40978	9190	14646	7
40979	9191	14761	3
40980	9191	14660	3
40981	9191	14678	7
40982	9191	14679	1
40983	9191	14522	3
40984	9192	14704	5
40985	9192	14683	6
40986	9192	14762	9
40987	9192	14641	1
40988	9192	14510	6
40989	9193	14671	4
40990	9193	14644	2
40991	9193	14468	2
40992	9193	14473	1
40993	9193	14763	2
40994	9194	14764	4
40995	9194	14765	3
40996	9194	14649	11
40997	9194	14650	1
40998	9194	14533	6
40999	9195	14766	5
41000	9195	14644	8
41001	9195	14468	6
41002	9195	14520	5
41003	9195	14557	5
41004	9196	14669	5
41005	9196	14649	11
41006	9196	14694	1
41007	9196	14642	4
41008	9196	14455	2
41009	9197	14669	5
41010	9197	14649	2
41011	9197	14681	4
41012	9197	14694	1
41013	9197	14642	1
41014	9198	14669	4
41015	9198	14649	8
41016	9198	14681	6
41017	9198	14650	2
41018	9198	14642	6
41019	9199	14680	4
41020	9199	14649	11
41021	9199	14681	7
41022	9199	14694	2
41023	9199	14642	4
41024	9200	14767	3
41025	9200	14768	2
41026	9200	14654	7
41027	9200	14769	4
41028	9200	14770	4
41029	9200	14646	2
41030	9201	14759	7
41031	9201	14605	8
41032	9201	14548	9
41033	9201	14641	4
41034	9201	14557	3
41035	9202	14758	5
41036	9202	14771	8
41037	9202	14468	6
41038	9202	14674	5
41039	9202	14557	8
41040	9203	14625	1
41041	9203	14585	11
41042	9203	14498	8
41043	9203	14772	9
41044	9203	14510	9
41045	9204	14669	6
41046	9204	14649	11
41047	9204	14694	2
41048	9204	14642	3
41049	9204	14455	4
41050	9205	14773	6
41051	9205	14649	13
41052	9205	14541	4
41053	9205	14774	5
41054	9205	14510	9
41055	9206	14625	1
41056	9206	14548	7
41057	9206	14498	8
41058	9206	14775	2
41059	9206	14557	5
41060	9207	14776	5
41061	9207	14678	6
41062	9207	14661	6
41063	9207	14674	4
41064	9207	14522	1
41065	9208	14742	2
41066	9208	14777	7
41067	9208	14778	2
41068	9208	14732	2
41069	9208	14473	3
41070	9209	14637	4
41071	9209	14683	5
41072	9209	14678	8
41073	9209	14641	3
41074	9209	14522	2
41075	9210	14625	3
41076	9210	14585	13
41077	9210	14772	8
41078	9210	14564	7
41079	9210	14557	7
41080	9211	14779	2
41081	9211	14654	8
41082	9211	14780	3
41083	9211	14646	2
41084	9211	14490	1
41085	9212	14781	5
41086	9212	14782	3
41087	9212	14705	11
41088	9212	14641	4
41089	9212	14646	11
41090	9213	14704	3
41091	9213	14711	8
41092	9213	14681	7
41093	9213	14783	4
41094	9213	14557	6
41095	9214	14647	3
41096	9214	14669	4
41097	9214	14649	11
41098	9214	14650	1
41099	9214	14642	5
41100	9215	14682	3
41101	9215	14683	6
41102	9215	14678	9
41103	9215	14656	1
41104	9215	14663	5
41105	9216	14699	5
41106	9216	14649	9
41107	9216	14784	3
41108	9216	14495	5
41109	9216	14510	4
41110	9217	14699	8
41111	9217	14729	8
41112	9217	14784	11
41113	9217	14785	4
41114	9217	14510	6
41115	9218	14786	1
41116	9218	14729	7
41117	9218	14572	1
41118	9218	14510	1
41119	9218	14451	1
41120	9219	14787	6
41121	9219	14788	5
41122	9219	14789	3
41123	9220	14790	5
41124	9221	14791	3
41125	9222	14792	4
41126	9222	14793	5
41127	9223	14791	11
41128	9224	14794	13
41129	9224	14795	4
41130	9225	14791	3
41131	9226	14791	1
41132	9227	14791	3
41133	9228	14796	3
41134	9228	14797	11
41135	9229	14787	4
41136	9229	14798	7
41137	9230	14799	7
41138	9230	14800	8
41139	9231	14801	4
41140	9232	14802	3
41141	9232	14803	11
41142	9233	14804	7
41143	9233	14789	3
41144	9234	14789	2
41145	9234	14805	13
41146	9235	14806	8
41147	9236	14807	2
41148	9236	14808	4
41149	9237	14809	5
41150	9237	14805	5
41151	9238	14810	11
41152	9238	14811	10
41153	9239	14812	7
41154	9239	14803	9
41155	9240	14805	11
41156	9241	14813	7
41157	9242	14805	4
41158	9243	14810	2
41159	9243	14803	9
41160	9244	14814	8
41161	9245	14815	8
41162	9246	14816	6
41163	9246	14801	4
41164	9247	14800	3
41165	9248	14817	5
41166	9248	14818	1
41167	9249	14819	11
41168	9249	14805	2
41169	9250	14819	3
41170	9251	14807	5
41171	9251	14819	3
41172	9252	14820	9
41173	9252	14793	5
41174	9253	14817	7
41175	9253	14815	8
41176	9254	14821	4
41177	9254	14819	5
41178	9255	14822	3
41179	9255	14808	3
41180	9256	14803	8
41181	9257	14815	4
41182	9257	14819	11
41183	9258	14805	11
41184	9259	14823	4
41185	9260	14819	11
41186	9260	14805	5
41187	9261	14801	2
41188	9261	14813	4
41189	9262	14801	5
41190	9262	14806	1
41191	9263	14824	5
41192	9264	14825	8
41193	9265	14826	8
41194	9265	14827	4
41195	9266	14828	7
41196	9267	14829	2
41197	9268	14806	6
41198	9269	14830	6
41199	9270	14831	5
41200	9271	14832	4
41201	9271	14833	2
41202	9272	14812	1
41203	9273	14834	4
41204	9274	14834	7
41205	9275	14835	3
41206	9275	14836	5
41207	9276	14837	1
41208	9276	14793	3
41209	9277	14838	1
41210	9278	14839	11
41211	9279	14819	11
41212	9279	14805	4
41213	9280	14840	5
41214	9281	14828	3
41215	9282	14841	2
41216	9283	14830	5
41217	9284	14819	2
41218	9284	14805	1
41219	9285	14842	8
41220	9286	14843	1
41221	9287	14841	1
41222	9288	14844	1
41223	9289	14813	9
41224	9290	14845	1
41225	9290	14846	3
41226	9291	14831	3
41227	9292	14806	8
41228	9293	14812	5
41229	9294	14844	2
41230	9295	14840	5
41231	9296	14847	5
41232	9297	14819	1
41233	9297	14805	1
41234	9298	14848	6
41235	9299	14847	1
41236	9300	14842	7
41237	9301	14831	4
41238	9302	14841	7
41239	9302	14849	2
41240	9303	14839	5
41241	9304	14848	5
41242	9305	14850	2
41243	9305	14851	3
41244	9306	14852	2
41245	9307	14812	5
41246	9308	14839	11
41247	9309	14806	9
41248	9310	14853	11
41249	9311	14834	4
41250	9312	14843	3
41251	9313	14854	9
41252	9314	14834	1
41253	9315	14855	6
41254	9316	14856	11
41255	9316	14857	5
41256	9316	14858	11
41257	9316	14859	6
41258	9316	14860	11
41259	9317	14861	14
41260	9317	14862	14
41261	9317	14863	7
41262	9317	14864	4
41263	9317	14860	10
41264	9318	14865	3
41265	9319	14863	6
41266	9319	14866	11
41267	9319	14867	5
41268	9319	14868	4
41269	9319	14869	13
41270	9320	14867	4
41271	9320	14865	3
41272	9320	14870	14
41273	9320	14871	6
41274	9320	14860	9
41275	9321	14872	4
41276	9321	14873	2
41277	9321	14856	11
41278	9321	14874	5
41279	9321	14875	4
41280	9321	14868	3
41281	9322	14876	11
41282	9322	14877	14
41283	9322	14878	9
41284	9322	14879	8
41285	9322	14880	8
41286	9322	14874	11
41287	9322	14881	9
41288	9323	14876	5
41289	9323	14882	14
41290	9323	14866	11
41291	9323	14883	8
41292	9323	14884	7
41293	9324	14863	6
41294	9324	14866	11
41295	9324	14867	6
41296	9324	14864	3
41297	9324	14885	9
41298	9324	14868	4
41299	9325	14886	14
41300	9325	14887	11
41301	9326	14888	7
41302	9326	14889	8
41303	9326	14868	3
41304	9326	14860	11
41305	9327	14886	14
41306	9327	14887	11
41307	9327	14890	11
41308	9327	14891	3
41309	9327	14875	6
41310	9327	14892	1
41311	9327	14893	9
41312	9328	14894	2
41313	9328	14895	7
41314	9328	14863	8
41315	9328	14883	8
41316	9328	14880	2
41317	9328	14896	7
41318	9329	14897	5
41319	9329	14898	2
41320	9329	14899	10
41321	9329	14900	3
41322	9329	14901	13
41323	9329	14869	8
41324	9330	14902	9
41325	9330	14903	6
41326	9330	14874	6
41327	9330	14904	5
41328	9330	14865	7
41329	9330	14905	11
41330	9331	14878	3
41331	9331	14866	8
41332	9331	14906	6
41333	9331	14857	4
41334	9331	14867	8
41335	9331	14864	1
41336	9332	14907	3
41337	9332	14876	11
41338	9332	14877	14
41339	9332	14879	8
41340	9332	14858	11
41341	9332	14869	11
41342	9333	14878	7
41343	9333	14879	9
41344	9333	14896	6
41345	9333	14904	4
41346	9333	14860	9
41347	9334	14908	11
41348	9334	14909	2
41349	9334	14886	14
41350	9334	14887	11
41351	9334	14901	6
41352	9334	14859	12
41353	9334	14869	8
41354	9335	14878	6
41355	9335	14883	11
41356	9335	14896	6
41357	9335	14904	6
41358	9335	14869	9
41359	9336	14910	14
41360	9336	14887	5
41361	9336	14878	5
41362	9336	14866	2
41363	9336	14867	6
41364	9336	14904	13
41365	9336	14865	7
41366	9337	14876	11
41367	9337	14882	14
41368	9337	14863	9
41369	9337	14890	11
41370	9337	14867	8
41371	9337	14904	4
41372	9337	14911	2
41373	9337	14893	6
41374	9338	14878	5
41375	9338	14866	3
41376	9338	14906	6
41377	9338	14857	4
41378	9338	14867	2
41379	9338	14864	5
41380	9338	14904	5
41381	9339	14912	5
41382	9339	14913	11
41383	9339	14914	8
41384	9339	14904	13
41385	9339	14859	5
41386	9339	14860	11
41387	9340	14915	6
41388	9340	14902	11
41389	9340	14901	9
41390	9340	14858	8
41391	9340	14885	9
41392	9340	14916	3
41393	9341	14917	9
41394	9341	14918	3
41395	9341	14919	2
41396	9341	14875	2
41397	9342	14920	4
41398	9342	14921	9
41399	9342	14922	8
41400	9342	14923	4
41401	9342	14919	7
41402	9342	14924	9
41403	9343	14925	4
41404	9343	14926	9
41405	9343	14927	7
41406	9343	14924	12
41407	9343	14928	5
41408	9343	14860	8
41409	9344	14929	6
41410	9344	14930	5
41411	9344	14931	3
41412	9344	14900	5
41413	9344	14924	6
41414	9344	14869	8
41415	9345	14932	8
41416	9345	14933	9
41417	9345	14934	9
41418	9345	14924	9
41419	9346	14935	4
41420	9346	14879	2
41421	9346	14896	2
41422	9346	14858	5
41423	9346	14904	3
41424	9346	14936	2
41425	9347	14937	4
41426	9347	14938	5
41427	9347	14879	11
41428	9347	14939	8
38099	8585	13161	11
40656	9127	14474	11
\.


--
-- Data for Name: studentineligibilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentineligibilities (studentineligibilityid, ineligibilityid) FROM stdin;
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY students (studentid, personid, studentno, curriculumid) FROM stdin;
2007	2017	199938944	1
2008	2018	200258957	1
2009	2019	200261631	1
2010	2020	200302684	1
2011	2021	200306538	1
2012	2022	200427046	1
2013	2023	200505277	1
2014	2024	200571597	1
2015	2025	200604764	1
2016	2026	200611321	1
2017	2027	200618693	1
2018	2028	200645172	1
2019	2029	200678578	1
2020	2030	200678652	1
2021	2031	200660742	1
2022	2032	200660849	1
2023	2033	200702110	1
2024	2034	200716081	1
2025	2035	200722129	1
2026	2036	200727064	1
2027	2037	200729866	1
2028	2038	200737513	1
2029	2039	200742060	1
2030	2040	200746440	1
2031	2041	200746691	1
2032	2042	200750610	1
2033	2043	200776104	1
2034	2044	200703789	1
2035	2045	200801494	1
2036	2046	200804269	1
2037	2047	200805213	1
2038	2048	200806725	1
2039	2049	200807619	1
2040	2050	200810012	1
2041	2051	200810449	1
2042	2052	200812434	1
2043	2053	200816057	1
2044	2054	200816182	1
2045	2055	200818798	1
2046	2056	200820492	1
2047	2057	200820845	1
2048	2058	200822195	1
2049	2059	200824411	1
2050	2060	200826125	1
2051	2061	200826132	1
2052	2062	200829462	1
2053	2063	200831088	1
2054	2064	200835065	1
2055	2065	200838847	1
2056	2066	200850304	1
2057	2067	200854833	1
2058	2068	200859513	1
2059	2069	200861979	1
2060	2070	200863141	1
2061	2071	200863910	1
2062	2072	200863943	1
2063	2073	200867820	1
2064	2074	200867969	1
2065	2075	200869234	1
2066	2076	200878505	1
2067	2077	200878522	1
2068	2078	200879055	1
2069	2079	200751702	1
2070	2080	200649333	1
2071	2081	200704149	1
2072	2082	200800722	1
2073	2083	200800992	1
2074	2084	200802019	1
2075	2085	200805994	1
2076	2086	200810511	1
2077	2087	200810842	1
2078	2088	200815563	1
2079	2089	200816422	1
2080	2090	200817653	1
2081	2091	200850077	1
2082	2092	200852284	1
2083	2093	200865811	1
2084	2094	200900039	1
2085	2095	200900138	1
2086	2096	200900163	1
2087	2097	200900184	1
2088	2098	200900407	1
2089	2099	200900495	1
2090	2100	200900643	1
2091	2101	200900790	1
2092	2102	200901056	1
2093	2103	200903933	1
2094	2104	200904996	1
2095	2105	200905558	1
2096	2106	200906611	1
2097	2107	200906984	1
2098	2108	200907623	1
2099	2109	200909509	1
2100	2110	200910151	1
2101	2111	200910605	1
2102	2112	200911631	1
2103	2113	200911675	1
2104	2114	200911724	1
2105	2115	200911734	1
2106	2116	200911738	1
2107	2117	200911827	1
2108	2118	200912221	1
2109	2119	200912581	1
2110	2120	200912820	1
2111	2121	200912874	1
2112	2122	200912972	1
2113	2123	200913084	1
2114	2124	200913146	1
2115	2125	200913757	1
2116	2126	200913846	1
2117	2127	200913901	1
2118	2128	200914214	1
2119	2129	200914369	1
2120	2130	200914550	1
2121	2131	200915033	1
2122	2132	200920483	1
2123	2133	200920633	1
2124	2134	200921105	1
2125	2135	200921634	1
2126	2136	200922056	1
2127	2137	200922763	1
2128	2138	200922784	1
2129	2139	200922882	1
2130	2140	200924554	1
2131	2141	200925215	1
2132	2142	200925241	1
2133	2143	200925249	1
2134	2144	200925556	1
2135	2145	200925562	1
2136	2146	200926277	1
2137	2147	200926328	1
2138	2148	200926380	1
2139	2149	200926385	1
2140	2150	200929259	1
2141	2151	200929277	1
2142	2152	200929367	1
2143	2153	200929381	1
2144	2154	200929428	1
2145	2155	200929656	1
2146	2156	200930017	1
2147	2157	200932205	1
2148	2158	200933686	1
2149	2159	200935632	1
2150	2160	200936633	1
2151	2161	200937320	1
2152	2162	200939122	1
2153	2163	200940273	1
2154	2164	200942368	1
2155	2165	200942606	1
2156	2166	200945214	1
2157	2167	200945219	1
2158	2168	200950378	1
2159	2169	200950655	1
2160	2170	200950663	1
2161	2171	200951345	1
2162	2172	200951383	1
2163	2173	200952820	1
2164	2174	200952936	1
2165	2175	200953322	1
2166	2176	200953427	1
2167	2177	200953449	1
2168	2178	200953589	1
2169	2179	200953593	1
2170	2180	200953879	1
2171	2181	200953979	1
2172	2182	200954553	1
2173	2183	200955605	1
2174	2184	200957922	1
2175	2185	200960039	1
2176	2186	200962443	1
2177	2187	200978170	1
2178	2188	200978810	1
2179	2189	200978939	1
2180	2190	200819985	1
2181	2191	200824759	1
2182	2192	200865810	1
2183	2193	200804221	1
\.


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentterms (studenttermid, studentid, termid, ineligibilities, issettled, cwa, gwa, mathgwa, csgwa) FROM stdin;
8583	2007	20002	N/A	t	2.3136	3.8235	2.6250	3.0500
8584	2007	20003	N/A	t	2.3074	2.2500	2.4474	3.0500
8586	2007	20012	N/A	t	2.6951	4.2000	2.5227	3.5300
8587	2007	20013	N/A	t	2.6563	2.1250	2.5227	3.3661
8589	2008	20021	N/A	t	2.4265	2.4265	3.0000	1.5000
8590	2009	20021	N/A	t	2.2500	2.2500	2.2500	2.2500
8591	2007	20022	N/A	t	2.7146	3.2500	2.5227	3.3316
8592	2008	20022	N/A	t	2.7132	3.0000	3.0000	3.2500
8594	2007	20031	N/A	t	2.7370	3.0000	2.5227	3.2802
8595	2008	20031	N/A	t	2.6250	2.3750	3.0000	2.8333
8597	2010	20031	N/A	t	2.5000	2.5000	2.5000	3.0000
8598	2011	20031	N/A	t	2.5909	2.5909	3.0000	0.0000
8599	2007	20032	N/A	t	2.7370	0.0000	2.5227	3.2802
8601	2009	20032	N/A	t	2.9710	4.6250	3.0476	3.1346
8602	2010	20032	N/A	t	2.6600	2.7857	2.7500	2.5000
8603	2011	20032	N/A	t	2.2500	2.0294	3.0000	1.2500
8605	2009	20033	N/A	t	2.9589	2.7500	3.0476	3.1346
8606	2010	20033	N/A	t	2.5323	2.0000	2.7500	2.5000
8607	2011	20033	N/A	t	2.5152	4.0000	3.3333	1.2500
8609	2009	20041	N/A	t	3.0577	3.4583	3.0417	3.4079
8610	2010	20041	N/A	t	2.7273	3.1923	2.6667	2.4000
8611	2011	20041	N/A	t	2.4844	2.4167	3.0625	1.8750
8613	2008	20042	N/A	t	2.5758	2.2500	3.0000	2.8581
8614	2009	20042	N/A	t	3.0354	2.9000	3.0417	3.4643
8615	2010	20042	N/A	t	3.2000	4.5789	3.3333	3.0000
8617	2012	20042	N/A	t	1.9032	2.1429	2.3750	1.1250
8618	2008	20043	N/A	t	2.5495	2.1786	3.0000	2.8581
8620	2010	20043	N/A	t	3.2000	0.0000	3.3333	3.0000
8621	2011	20043	N/A	t	2.7188	2.2500	3.3793	2.9167
8622	2012	20043	N/A	t	1.9032	0.0000	2.3750	1.1250
8624	2009	20051	N/A	t	2.9250	2.7500	3.0417	3.0625
8625	2010	20051	N/A	t	3.1349	3.2237	3.5417	3.0000
8626	2011	20051	N/A	t	2.7039	3.1000	3.5313	2.9375
8628	2013	20051	N/A	t	1.8824	1.8824	1.7500	1.7500
8629	2014	20051	N/A	t	1.9265	1.9265	1.7500	1.2500
8630	2008	20052	N/A	t	2.4981	2.2500	3.0000	2.6250
8632	2010	20052	N/A	t	3.0395	2.6579	3.5417	3.0000
8633	2012	20052	N/A	t	2.1439	2.6250	2.6071	1.5156
8634	2013	20052	N/A	t	2.5161	3.2857	3.3750	1.7500
8636	2009	20053	N/A	t	2.7785	1.1250	3.0417	2.7119
8637	2010	20053	N/A	t	3.0077	2.0000	3.3704	3.0000
8638	2013	20053	N/A	t	2.4792	2.2500	3.0000	1.7500
8640	2009	20061	N/A	t	2.7911	3.0000	3.0417	2.7500
8641	2012	20061	N/A	t	2.0402	1.7143	2.4688	1.6000
8643	2014	20061	N/A	t	2.0647	2.2794	2.1538	1.8281
8644	2015	20061	N/A	t	2.1618	2.1618	3.0000	2.0000
8645	2016	20061	N/A	t	2.5735	2.5735	5.0000	2.0000
8647	2018	20061	N/A	t	2.2500	2.2500	3.0000	2.5000
8648	2019	20061	N/A	t	2.4118	2.4118	4.0000	1.0000
8649	2020	20061	N/A	t	2.2059	2.2059	3.0000	1.2500
8651	2011	20062	N/A	t	2.6236	2.1538	3.4643	2.6406
8652	2012	20062	N/A	t	1.9476	1.5000	2.4688	1.4865
8653	2013	20062	N/A	t	3.0634	3.5333	3.4000	2.4231
8655	2015	20062	N/A	t	2.5221	2.8824	4.0000	2.1250
8656	2016	20062	N/A	t	2.5074	2.4412	3.8750	2.3750
8657	2017	20062	N/A	t	1.9706	2.0735	2.8750	2.0000
8659	2019	20062	N/A	t	2.1618	1.9118	3.0000	1.1250
8660	2020	20062	N/A	t	2.0735	1.9412	3.0000	1.3750
8661	2012	20063	N/A	t	1.9476	0.0000	2.4688	1.4865
8663	2014	20063	N/A	t	2.1044	1.7500	2.2656	1.9091
8664	2016	20063	N/A	t	2.5705	3.0000	3.5833	2.3750
8665	2017	20063	N/A	t	2.0526	2.7500	2.8750	2.0000
8667	2019	20063	N/A	t	2.2372	2.7500	2.9167	1.1250
8668	2020	20063	N/A	t	1.9875	1.5000	3.0000	1.3750
8670	2012	20071	N/A	t	2.0407	2.5833	2.4688	1.7959
8671	2013	20071	N/A	t	2.9888	2.7083	3.3226	2.5568
8672	2014	20071	N/A	t	2.1624	2.4167	2.2656	2.1397
8674	2016	20071	N/A	t	2.4052	2.0658	3.3125	2.4250
8675	2017	20071	N/A	t	2.0714	2.1111	2.9167	2.0000
8676	2018	20071	N/A	t	2.2406	2.2000	2.9167	2.4500
8678	2022	20071	N/A	t	2.1667	2.1667	1.7500	0.0000
8679	2019	20071	N/A	t	2.2457	2.2632	2.7500	1.3750
8681	2023	20071	N/A	t	1.7059	1.7059	2.5000	1.2500
8682	2024	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
8683	2025	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
8684	2026	20071	N/A	t	3.2794	3.2794	5.0000	2.0000
8686	2028	20071	N/A	t	2.7679	2.7679	2.5000	1.2500
8687	2029	20071	N/A	t	1.9559	1.9559	2.7500	1.5000
8689	2031	20071	N/A	t	2.2059	2.2059	3.0000	2.0000
8690	2032	20071	N/A	t	1.7647	1.7647	1.5000	1.5000
8691	2033	20071	N/A	t	1.7206	1.7206	2.2500	1.0000
8693	2011	20072	N/A	t	2.5768	2.5500	3.4643	2.7763
8694	2012	20072	N/A	t	2.0265	1.9500	2.4688	1.7959
8695	2013	20072	N/A	t	3.1589	4.0000	3.3226	3.0726
8697	2015	20072	N/A	t	2.6208	2.4500	3.5000	2.2750
8698	2016	20072	N/A	t	2.3547	2.1719	3.0761	2.5000
8700	2018	20072	N/A	t	2.4826	3.1579	3.1190	3.0385
8701	2021	20072	N/A	t	3.2803	4.0694	3.6250	4.0000
8702	2022	20072	N/A	t	2.5446	2.8281	2.1591	2.2500
8704	2020	20072	N/A	t	2.4967	3.9219	3.2262	2.6346
8705	2023	20072	N/A	t	2.1618	2.6176	3.7500	1.5000
8706	2024	20072	N/A	t	2.1618	2.2500	2.2500	1.3750
8708	2026	20072	N/A	t	2.8603	2.4412	3.8750	2.1250
8709	2027	20072	N/A	t	2.2500	2.2941	3.0000	2.3750
8710	2028	20072	N/A	t	2.8929	3.0179	3.7500	1.3750
8712	2030	20072	N/A	t	1.6985	1.9118	1.5000	1.1250
8713	2031	20072	N/A	t	1.9779	1.7500	2.7500	1.5000
8714	2032	20072	N/A	t	1.7794	1.7941	2.0000	1.5000
8716	2012	20073	N/A	t	2.0148	1.5000	2.4688	1.7959
8719	2016	20073	N/A	t	2.3312	1.7500	2.9231	2.5000
8720	2018	20073	N/A	t	2.4633	2.0000	2.9792	3.0385
8722	2019	20073	N/A	t	2.4383	5.0000	2.6635	1.6923
8723	2020	20073	N/A	t	2.4573	2.0357	3.0417	2.6346
8725	2025	20073	N/A	t	2.2500	1.5000	2.2500	1.8750
8726	2026	20073	N/A	t	2.8782	3.0000	3.5833	2.1250
8727	2028	20073	N/A	t	2.6818	1.5000	3.0000	1.3750
8728	2029	20073	N/A	t	2.4038	2.0000	3.2500	1.7500
8730	2013	20081	N/A	t	3.1983	3.6667	3.3226	3.0608
8731	2014	20081	N/A	t	2.0620	1.5500	2.2656	1.8750
8733	2016	20081	N/A	t	2.2690	1.9500	2.9231	2.1932
8734	2017	20081	N/A	t	2.4389	2.7000	3.1667	2.5625
8735	2018	20081	N/A	t	2.4861	2.6000	2.9792	2.8523
8737	2022	20081	N/A	t	2.5598	2.5833	2.1591	3.0000
8738	2019	20081	N/A	t	2.5208	2.8553	2.6635	2.3661
8739	2020	20081	N/A	t	2.4533	2.0000	3.0417	2.3409
8741	2034	20081	N/A	t	1.9265	1.9265	2.5000	1.2500
8742	2024	20081	N/A	t	2.1085	2.0132	2.4167	1.4250
8744	2026	20081	N/A	t	2.7723	2.5294	3.5833	2.2750
8745	2027	20081	N/A	t	2.3950	2.7031	3.0000	2.5250
8746	2028	20081	N/A	t	2.9583	3.5667	3.2500	1.3750
8748	2030	20081	N/A	t	1.9387	2.3684	1.8333	1.6750
8749	2031	20081	N/A	t	2.2830	2.8289	3.5000	1.3000
8750	2032	20081	N/A	t	2.0802	2.6184	2.2500	2.1000
8752	2035	20081	N/A	t	2.0294	2.0294	3.0000	1.5000
8753	2036	20081	N/A	t	1.7941	1.7941	2.5000	1.0000
8754	2037	20081	N/A	t	2.2059	2.2059	2.2500	2.2500
8756	2039	20081	N/A	t	2.9265	2.9265	2.7500	2.2500
8757	2040	20081	N/A	t	2.3971	2.3971	2.0000	2.7500
8758	2041	20081	N/A	t	1.9853	1.9853	2.2500	2.2500
8760	2043	20081	N/A	t	2.0294	2.0294	2.2500	2.2500
8761	2044	20081	N/A	t	2.8382	2.8382	2.7500	3.0000
8762	2045	20081	N/A	t	1.9853	1.9853	2.2500	2.0000
8764	2047	20081	N/A	t	2.7794	2.7794	3.0000	2.5000
8765	2048	20081	N/A	t	2.1765	2.1765	2.7500	2.2500
8766	2049	20081	N/A	t	1.8235	1.8235	2.0000	1.0000
8768	2051	20081	N/A	t	2.1471	2.1471	2.5000	2.2500
8769	2052	20081	N/A	t	2.0147	2.0147	2.5000	1.0000
8771	2054	20081	N/A	t	2.0441	2.0441	2.0000	2.0000
8772	2055	20081	N/A	t	3.0179	3.0179	5.0000	2.0000
8773	2056	20081	N/A	t	2.2647	2.2647	2.7500	1.7500
8775	2058	20081	N/A	t	2.0441	2.0441	2.7500	2.0000
8776	2059	20081	N/A	t	1.8824	1.8824	1.7500	1.0000
8777	2060	20081	N/A	t	2.2353	2.2353	2.5000	2.2500
8779	2062	20081	N/A	t	2.4853	2.4853	2.7500	2.7500
8780	2063	20081	N/A	t	1.8824	1.8824	1.7500	1.5000
8781	2064	20081	N/A	t	1.9107	1.9107	1.0000	2.0000
8783	2066	20081	N/A	t	1.8235	1.8235	2.7500	1.7500
8784	2067	20081	N/A	t	1.8676	1.8676	1.2500	2.0000
8785	2068	20081	N/A	t	2.9265	2.9265	5.0000	5.0000
8787	2011	20082	N/A	t	2.5688	1.8125	3.4643	2.7264
8788	2013	20082	N/A	t	3.1855	2.9000	3.3226	3.1467
8790	2015	20082	N/A	t	2.5808	2.4500	3.0577	2.3026
8791	2016	20082	N/A	t	2.3000	2.4583	2.9231	2.1691
8792	2017	20082	N/A	t	2.4690	2.6500	3.1667	2.6000
8794	2021	20082	N/A	t	2.7429	2.3438	3.0952	2.8269
8795	2022	20082	N/A	t	2.5363	2.4688	2.1591	2.3947
8796	2019	20082	N/A	t	2.5180	2.5000	2.6635	2.2568
8798	2023	20082	N/A	t	2.2711	2.6563	3.2212	1.6538
8799	2034	20082	N/A	t	2.2786	2.6111	2.5000	1.8750
8801	2025	20082	N/A	t	2.5530	3.2941	2.7500	2.9423
8802	2026	20082	N/A	t	2.7577	2.6667	3.5833	2.4423
8803	2027	20082	N/A	t	2.4167	2.4844	2.9643	2.5250
8805	2029	20082	N/A	t	2.5037	3.4250	3.1630	1.9500
8806	2030	20082	N/A	t	2.1739	2.9531	2.3452	1.8654
8807	2031	20082	N/A	t	2.4706	3.4444	3.5870	1.4615
8809	2069	20082	N/A	t	2.2500	2.2500	3.0000	2.2500
8810	2033	20082	N/A	t	1.9097	2.1711	2.4405	1.5962
8811	2035	20082	N/A	t	2.0294	2.0294	2.6250	1.5000
8813	2037	20082	N/A	t	2.4044	2.6029	2.6250	2.2500
8814	2038	20082	N/A	t	2.3676	2.7059	4.0000	2.1250
8815	2039	20082	N/A	t	2.6397	2.3529	2.7500	2.3750
8817	2041	20082	N/A	t	1.9839	1.9821	2.6250	1.8750
8818	2042	20082	N/A	t	2.0368	1.9853	2.1250	1.0000
8820	2044	20082	N/A	t	2.8065	2.7679	2.6250	3.0000
8821	2045	20082	N/A	t	2.1176	2.2500	2.2500	2.0000
8822	2046	20082	N/A	t	2.7721	2.3971	3.8750	3.2500
8824	2048	20082	N/A	t	2.0956	2.0147	2.6250	2.2500
8825	2049	20082	N/A	t	1.9559	2.0882	2.3750	1.0000
8826	2050	20082	N/A	t	1.7868	1.8971	2.2500	1.3750
8828	2052	20082	N/A	t	2.1324	2.2500	2.7500	1.3750
8829	2053	20082	N/A	t	2.6397	3.1912	3.8750	1.8750
8830	2054	20082	N/A	t	2.1959	2.3250	1.7500	2.3750
8832	2056	20082	N/A	t	2.2647	2.2647	2.7500	2.1250
8833	2057	20082	N/A	t	2.3879	1.4375	2.7500	3.1250
8834	2058	20082	N/A	t	2.2353	2.4265	2.8750	2.5000
8836	2060	20082	N/A	t	2.0882	1.9412	2.3750	2.1250
8837	2061	20082	N/A	t	2.2279	2.1618	3.0000	2.2500
8839	2063	20082	N/A	t	1.8676	1.8529	1.6250	1.5000
8840	2064	20082	N/A	t	2.2143	2.5179	1.6250	2.5000
8841	2065	20082	N/A	t	2.6765	2.9706	4.0000	2.3750
8843	2067	20082	N/A	t	2.1397	2.4118	1.8750	1.8750
8844	2068	20082	N/A	t	2.5515	2.1765	3.8750	3.8750
8845	2010	20083	N/A	t	3.0225	2.7500	3.3083	3.0000
8847	2016	20083	N/A	t	2.2721	1.2500	2.9231	2.1691
8848	2018	20083	N/A	t	2.5023	1.2500	2.9792	2.7500
8849	2021	20083	N/A	t	2.7021	1.7500	3.0952	2.8269
8851	2023	20083	N/A	t	2.2403	1.8750	3.1207	1.6538
8852	2034	20083	N/A	t	2.2756	2.2500	2.5000	1.8750
8855	2028	20083	N/A	t	2.6014	1.0000	2.6875	1.4167
8856	2029	20083	N/A	t	2.5246	3.0000	3.1442	1.9500
8858	2031	20083	N/A	t	2.4767	2.5357	3.4327	1.4615
8859	2069	20083	N/A	t	2.4205	3.0000	3.0000	2.2500
8861	2039	20083	N/A	t	2.4688	1.5000	2.7500	2.3750
8862	2040	20083	N/A	t	2.6053	3.0000	3.0000	2.8750
8863	2044	20083	N/A	t	2.8333	3.0000	2.7500	3.0000
8865	2047	20083	N/A	t	2.7813	1.1250	4.0000	2.2500
8866	2049	20083	N/A	t	1.8974	1.5000	2.0833	1.0000
8867	2050	20083	N/A	t	1.8355	2.2500	2.2500	1.3750
8869	2054	20083	N/A	t	2.2558	2.6250	1.7500	2.3750
8870	2055	20083	N/A	t	2.4792	3.0000	3.5000	1.7500
8871	2056	20083	N/A	t	2.1500	1.5000	2.7500	2.1250
8873	2058	20083	N/A	t	2.5897	5.0000	3.5833	2.5000
8874	2059	20083	N/A	t	1.9615	2.0000	2.2500	1.0000
8875	2062	20083	N/A	t	2.5897	3.0000	2.8333	2.6250
8877	2064	20083	N/A	t	2.0303	1.0000	1.4167	2.5000
8878	2065	20083	N/A	t	2.6859	2.7500	3.5833	2.3750
8880	2010	20091	N/A	t	3.1667	4.5000	3.3083	3.4800
8881	2011	20091	N/A	t	2.5451	2.5000	3.4643	2.7264
8882	2013	20091	N/A	t	3.1294	2.5000	3.3226	3.0246
8883	2014	20091	N/A	t	2.0763	2.0000	2.2656	1.8679
8885	2016	20091	N/A	t	2.3960	3.5625	2.9231	2.5326
8886	2017	20091	N/A	t	2.4979	2.5500	3.1667	2.7721
8888	2070	20091	N/A	t	1.7000	1.7000	0.0000	2.0000
8889	2021	20091	N/A	t	2.7188	2.8000	3.0952	2.8421
8890	2022	20091	N/A	t	2.5000	2.3125	2.1591	2.4286
8892	2020	20091	N/A	t	2.5471	2.7031	3.0417	2.3409
8893	2023	20091	N/A	t	2.4130	3.3000	3.1207	1.7632
8894	2034	20091	N/A	t	2.4183	3.0625	3.2500	1.8250
8896	2024	20091	N/A	t	2.2742	2.6429	2.4762	2.0455
8897	2025	20091	N/A	t	2.6609	3.0417	2.7500	2.9605
8898	2026	20091	N/A	t	2.8375	3.7692	3.5870	2.6184
8900	2028	20091	N/A	t	2.7259	3.3393	2.9113	1.5313
8901	2029	20091	N/A	t	2.6006	2.7500	3.1442	2.1316
8902	2030	20091	N/A	t	2.3833	2.8000	2.3646	1.9545
8904	2032	20091	N/A	t	2.0893	2.0500	2.2813	1.9219
8905	2069	20091	N/A	t	2.4803	2.5625	3.4615	2.0000
8906	2033	20091	N/A	t	1.9278	2.0000	2.4405	1.6250
8908	2073	20091	N/A	t	2.5000	2.5000	3.0000	2.7500
8909	2035	20091	N/A	t	2.0561	2.1167	2.5833	1.4167
8910	2074	20091	N/A	t	2.6500	2.6500	3.0000	0.0000
8912	2037	20091	N/A	t	2.4151	2.4342	2.7500	2.3500
8913	2075	20091	N/A	t	2.0417	2.0417	2.5000	2.0000
8915	2039	20091	N/A	t	2.6339	3.0469	3.5000	2.3250
8916	2040	20091	N/A	t	2.8113	3.3333	3.0000	2.8750
8917	2041	20091	N/A	t	2.1100	2.3158	2.7500	2.1250
8918	2076	20091	N/A	t	2.1667	2.1667	2.5000	0.0000
8920	2042	20091	N/A	t	2.0200	1.9844	2.2500	1.0000
8921	2078	20091	N/A	t	2.4722	2.4722	3.0000	2.2500
8923	2044	20091	N/A	t	2.7206	2.4500	3.1250	2.5000
8924	2079	20091	N/A	t	2.7083	2.7083	2.7500	2.2500
8925	2080	20091	N/A	t	1.6346	1.6346	0.0000	1.5000
8927	2046	20091	N/A	t	2.6447	2.3750	3.3750	2.5833
8928	2047	20091	N/A	t	2.7455	2.6563	3.6667	2.5500
8929	2048	20091	N/A	t	2.0613	2.0000	2.4167	2.0500
8931	2050	20091	N/A	t	1.8070	1.7500	2.1667	1.5250
8932	2051	20091	N/A	t	2.4440	2.3553	3.2500	2.3250
8934	2053	20091	N/A	t	2.5750	2.4375	3.5000	1.9250
8935	2054	20091	N/A	t	2.8545	5.0000	2.8333	3.2500
8936	2055	20091	N/A	t	2.3682	2.1579	3.2500	1.6500
8938	2056	20091	N/A	t	2.2232	2.4063	2.8333	2.2750
8939	2082	20091	N/A	t	2.0556	2.0556	2.7500	1.7500
8940	2057	20091	N/A	t	2.2227	2.2083	2.5000	2.8333
8942	2059	20091	N/A	t	1.9958	2.0625	2.3750	1.4844
8943	2060	20091	N/A	t	2.1840	2.3553	2.5833	2.3750
8944	2061	20091	N/A	t	2.2123	2.1842	2.9167	1.8500
8946	2083	20091	N/A	t	1.8472	1.8472	2.2500	1.5000
8947	2063	20091	N/A	t	2.1708	2.6765	2.3611	1.8000
8948	2064	20091	N/A	t	2.3000	2.8235	1.8472	2.5000
8950	2066	20091	N/A	t	2.1780	2.4250	2.3611	2.4500
8951	2067	20091	N/A	t	2.2500	2.4844	2.0833	2.1250
8953	2084	20091	N/A	t	1.5735	1.5735	1.0000	1.0000
8954	2085	20091	N/A	t	1.6471	1.6471	1.2500	1.5000
8955	2086	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
8956	2087	20091	N/A	t	2.2353	2.2353	2.5000	3.0000
8958	2089	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
8959	2090	20091	N/A	t	2.7500	2.7500	2.7500	5.0000
8961	2092	20091	N/A	t	1.8088	1.8088	2.2500	2.7500
8962	2093	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
8963	2094	20091	N/A	t	1.6912	1.6912	2.7500	1.0000
8965	2096	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
8966	2097	20091	N/A	t	2.1912	2.1912	2.5000	2.5000
8967	2098	20091	N/A	t	1.6765	1.6765	2.2500	1.0000
8969	2100	20091	N/A	t	1.4559	1.4559	1.5000	1.0000
8970	2101	20091	N/A	t	3.0147	3.0147	5.0000	2.7500
8971	2102	20091	N/A	t	1.9265	1.9265	2.5000	2.0000
8973	2104	20091	N/A	t	1.9412	1.9412	2.2500	1.7500
8974	2105	20091	N/A	t	1.4412	1.4412	1.0000	1.5000
8975	2106	20091	N/A	t	2.7941	2.7941	2.7500	5.0000
8977	2108	20091	N/A	t	1.4706	1.4706	1.2500	1.5000
8978	2109	20091	N/A	t	1.6176	1.6176	1.7500	2.5000
8980	2111	20091	N/A	t	2.3529	2.3529	2.7500	2.7500
8981	2112	20091	N/A	t	1.8529	1.8529	1.5000	2.0000
8982	2113	20091	N/A	t	2.3088	2.3088	2.7500	3.0000
8984	2115	20091	N/A	t	1.7941	1.7941	1.7500	1.7500
8985	2116	20091	N/A	t	1.3529	1.3529	1.0000	1.2500
8986	2117	20091	N/A	t	1.9118	1.9118	2.0000	2.0000
8988	2119	20091	N/A	t	1.8088	1.8088	2.2500	1.5000
8991	2122	20091	N/A	t	2.1765	2.1765	2.7500	1.2500
8992	2123	20091	N/A	t	1.9853	1.9853	2.2500	1.0000
8994	2125	20091	N/A	t	1.7500	1.7500	1.0000	2.0000
8995	2126	20091	N/A	t	1.5147	1.5147	2.0000	1.0000
8996	2127	20091	N/A	t	2.3971	2.3971	2.7500	2.0000
8998	2129	20091	N/A	t	1.5882	1.5882	2.2500	1.0000
8999	2130	20091	N/A	t	2.1471	2.1471	2.5000	3.0000
9001	2132	20091	N/A	t	1.2647	1.2647	1.7500	1.0000
9002	2133	20091	N/A	t	2.2941	2.2941	3.0000	2.0000
9003	2134	20091	N/A	t	2.1765	2.1765	2.7500	2.5000
9005	2136	20091	N/A	t	1.9853	1.9853	3.0000	1.2500
9006	2137	20091	N/A	t	1.7647	1.7647	2.2500	1.5000
9007	2138	20091	N/A	t	1.4265	1.4265	1.2500	1.5000
9009	2140	20091	N/A	t	2.1618	2.1618	2.2500	1.0000
9010	2141	20091	N/A	t	1.2000	1.2000	1.0000	1.0000
9011	2142	20091	N/A	t	1.2647	1.2647	1.0000	1.5000
9013	2144	20091	N/A	t	1.7206	1.7206	2.2500	1.0000
9014	2145	20091	N/A	t	1.8382	1.8382	1.7500	2.0000
9015	2146	20091	N/A	t	2.0294	2.0294	3.0000	1.0000
9017	2148	20091	N/A	t	2.2500	2.2500	2.2500	2.7500
9018	2149	20091	N/A	t	1.2353	1.2353	1.5000	1.0000
9020	2151	20091	N/A	t	2.3971	2.3971	2.0000	2.2500
9021	2152	20091	N/A	t	2.3824	2.3824	3.0000	2.5000
9022	2153	20091	N/A	t	3.1912	3.1912	5.0000	2.5000
9024	2155	20091	N/A	t	2.0735	2.0735	3.0000	1.7500
9025	2156	20091	N/A	t	1.5882	1.5882	1.5000	1.7500
9026	2157	20091	N/A	t	1.5441	1.5441	1.5000	1.2500
9028	2159	20091	N/A	t	2.0441	2.0441	2.7500	1.7500
9029	2160	20091	N/A	t	2.1324	2.1324	2.7500	2.0000
9030	2161	20091	N/A	t	1.7206	1.7206	2.2500	2.0000
9032	2163	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
9033	2164	20091	N/A	t	1.8971	1.8971	2.2500	2.7500
9034	2165	20091	N/A	t	2.1324	2.1324	2.7500	1.0000
9036	2167	20091	N/A	t	1.7059	1.7059	2.5000	1.5000
9037	2168	20091	N/A	t	2.0147	2.0147	2.5000	1.2500
9038	2169	20091	N/A	t	2.6618	2.6618	5.0000	1.0000
9040	2171	20091	N/A	t	2.2500	2.2500	3.0000	3.0000
9041	2172	20091	N/A	t	1.8088	1.8088	2.2500	1.7500
9043	2174	20091	N/A	t	1.8971	1.8971	3.0000	1.7500
9044	2175	20091	N/A	t	2.0588	2.0588	2.5000	2.0000
9045	2176	20091	N/A	t	2.8676	2.8676	3.0000	4.0000
9047	2178	20091	N/A	t	2.1471	2.1471	2.5000	2.0000
9048	2179	20091	N/A	t	1.5147	1.5147	2.0000	1.1250
9049	2010	20092	N/A	t	3.1407	3.4167	3.5069	3.2838
9051	2015	20092	N/A	t	2.4154	1.7500	3.0577	2.0263
9052	2016	20092	N/A	t	2.3607	2.0000	2.9231	2.5326
9054	2018	20092	N/A	t	2.5079	2.5000	2.9792	2.6346
9055	2070	20092	N/A	t	1.9375	2.0781	0.0000	2.0568
9056	2021	20092	N/A	t	2.6250	1.9375	3.0952	2.7600
9058	2019	20092	N/A	t	2.5581	2.0000	2.6635	2.2500
9059	2020	20092	N/A	t	2.6045	3.1875	3.0417	2.3450
9060	2023	20092	N/A	t	2.3692	2.4167	3.1207	1.8790
9062	2071	20092	N/A	t	2.3182	2.5417	2.2500	2.5000
9063	2024	20092	N/A	t	2.2027	1.8333	2.4762	1.9632
9064	2025	20092	N/A	t	2.5905	2.2500	2.7500	2.6371
9066	2027	20092	N/A	t	2.4056	1.7917	2.9643	2.2700
9067	2028	20092	N/A	t	2.8194	3.9286	2.8750	1.5313
9068	2029	20092	N/A	t	2.5443	1.7000	3.1442	2.1300
9070	2031	20092	N/A	t	2.5671	2.3333	3.4914	1.9324
9071	2032	20092	N/A	t	2.0938	2.1250	2.2813	2.0400
9073	2033	20092	N/A	t	2.0023	2.3750	2.4405	1.8897
9074	2072	20092	N/A	t	2.8194	2.7083	3.7500	2.3750
9075	2073	20092	N/A	t	2.7569	3.0139	4.0000	2.8750
9077	2074	20092	N/A	t	2.2721	1.9737	3.0000	1.0000
9078	2036	20092	N/A	t	1.8090	1.9737	2.2639	1.5313
9079	2037	20092	N/A	t	2.4965	2.7237	3.1250	2.2188
9081	2038	20092	N/A	t	2.5169	3.3421	3.6827	2.7500
9082	2039	20092	N/A	t	2.5704	2.7778	3.1250	2.9531
9083	2040	20092	N/A	t	2.9472	3.3472	3.2500	3.2188
9085	2076	20092	N/A	t	2.2344	2.2941	2.7500	2.5000
9086	2077	20092	N/A	t	2.2230	2.4405	2.5000	2.5192
9087	2042	20092	N/A	t	2.0870	2.2632	2.2917	1.1406
9089	2043	20092	N/A	t	2.6507	3.3833	3.2500	2.2500
9090	2044	20092	N/A	t	2.7955	3.0500	3.0625	2.5000
9092	2080	20092	N/A	t	2.1250	2.9583	2.5000	2.7885
9093	2045	20092	N/A	t	2.2743	2.6974	2.4444	2.3125
9094	2180	20092	N/A	t	3.1333	3.1333	3.0000	2.2500
9096	2047	20092	N/A	t	2.7601	2.8056	3.7500	2.6538
9097	2048	20092	N/A	t	2.3623	3.4605	2.6190	2.2115
9098	2049	20092	N/A	t	1.8090	1.9844	1.9444	1.3906
9100	2050	20092	N/A	t	1.9493	3.1000	2.3056	2.8281
9101	2051	20092	N/A	t	2.4261	2.8438	3.2500	2.9531
9102	2052	20092	N/A	t	2.4891	3.1719	2.8810	2.5577
9104	2054	20092	N/A	t	2.9007	3.0417	2.8750	3.1875
9105	2055	20092	N/A	t	2.3521	2.2969	3.2500	2.0156
9106	2081	20092	N/A	t	2.1544	2.1316	2.9063	2.0833
9108	2082	20092	N/A	t	2.0735	2.0938	2.6563	2.0833
9109	2057	20092	N/A	t	2.3299	3.0250	2.5833	3.1842
9111	2059	20092	N/A	t	2.1007	2.7500	2.3750	2.0968
9112	2060	20092	N/A	t	2.2222	2.3289	2.5278	2.3281
9113	2061	20092	N/A	t	2.2717	2.8684	2.9306	2.6094
9115	2182	20092	N/A	t	2.1842	2.1842	2.7500	2.2500
9116	2083	20092	N/A	t	1.5878	1.3421	1.7500	1.2250
9117	2063	20092	N/A	t	2.4367	3.5000	2.3810	2.5385
9119	2065	20092	N/A	t	2.4595	2.1548	3.2500	2.5250
9120	2066	20092	N/A	t	2.2967	2.7344	2.3611	2.6094
9121	2067	20092	N/A	t	2.4848	3.2188	2.0278	2.4063
9123	2084	20092	N/A	t	1.5662	1.5588	1.5000	1.0000
9124	2085	20092	N/A	t	1.8015	1.9559	1.6250	2.0000
9127	2088	20092	N/A	t	2.7097	4.1429	3.3750	1.7500
9128	2089	20092	N/A	t	1.8986	1.9000	2.3750	1.5000
9130	2091	20092	N/A	t	2.2426	2.2206	2.3750	2.6250
9131	2092	20092	N/A	t	2.0074	2.2059	2.6250	2.6250
9133	2094	20092	N/A	t	1.7941	1.8971	2.8750	1.1250
9134	2095	20092	N/A	t	2.1029	2.1176	2.8750	2.2500
9135	2096	20092	N/A	t	2.6290	2.2143	3.8750	2.7500
9137	2098	20092	N/A	t	1.7794	1.8824	2.3750	1.2500
9138	2099	20092	N/A	t	1.4191	1.4412	1.3750	1.1250
9139	2100	20092	N/A	t	1.6250	1.7941	2.0000	1.0000
9141	2102	20092	N/A	t	2.1486	2.3375	3.7500	2.1250
9142	2103	20092	N/A	t	1.7206	1.7059	1.8750	2.0000
9143	2104	20092	N/A	t	1.9191	1.8971	2.6250	1.3750
9145	2106	20092	N/A	t	2.4779	2.1618	2.8750	3.1250
9146	2107	20092	N/A	t	2.1544	2.0882	2.3750	2.2500
9147	2108	20092	N/A	t	1.6176	1.7647	1.3750	1.5000
9149	2110	20092	N/A	t	1.7647	1.8824	1.8750	1.7500
9150	2111	20092	N/A	t	2.2868	2.2206	2.7500	2.6250
9152	2113	20092	N/A	t	2.0588	1.8088	2.5000	2.2500
9153	2114	20092	N/A	t	2.5662	2.1618	4.0000	2.7500
9154	2115	20092	N/A	t	2.0441	2.2941	2.3750	2.3750
9156	2117	20092	N/A	t	1.8676	1.8235	2.3750	1.5000
9157	2118	20092	N/A	t	1.6250	1.7206	2.0000	1.6250
9158	2119	20092	N/A	t	2.3871	3.0893	3.1250	2.1250
9160	2121	20092	N/A	t	2.3162	2.0735	3.0000	2.8750
9161	2122	20092	N/A	t	2.0809	1.9853	2.8750	1.2500
9162	2123	20092	N/A	t	1.8382	1.6912	2.5000	1.0000
9164	2125	20092	N/A	t	1.6875	1.6324	1.3125	1.7500
9165	2126	20092	N/A	t	1.6618	1.8088	2.5000	1.1250
9166	2127	20092	N/A	t	2.2647	2.1324	2.7500	2.0000
9168	2129	20092	N/A	t	1.7279	1.8676	2.5000	1.0000
9169	2130	20092	N/A	t	2.1103	2.0735	2.7500	2.6250
9170	2131	20092	N/A	t	1.7574	2.0000	2.0000	2.1250
9172	2133	20092	N/A	t	2.1757	2.0750	2.8750	2.0000
9173	2134	20092	N/A	t	2.3382	2.5000	2.6250	2.6250
9174	2135	20092	N/A	t	1.5147	1.5588	2.0000	1.0000
9176	2137	20092	N/A	t	2.1029	2.4412	3.6250	1.6250
9177	2138	20092	N/A	t	1.6838	1.9412	2.1250	2.0000
9179	2140	20092	N/A	t	2.1471	2.1324	2.5000	1.5000
9180	2141	20092	N/A	t	1.2500	1.2941	1.1563	1.0000
9181	2142	20092	N/A	t	1.3088	1.3529	1.3750	1.2500
9183	2144	20092	N/A	t	2.0956	2.4706	2.6250	1.5000
9184	2145	20092	N/A	t	2.0441	2.2500	2.3750	2.1250
9185	2146	20092	N/A	t	1.9559	1.8824	2.7500	1.1250
9187	2148	20092	N/A	t	2.2903	2.3393	2.3750	2.7500
9188	2149	20092	N/A	t	1.4265	1.6176	1.6250	1.0000
9190	2151	20092	N/A	t	2.1765	1.9559	2.3750	2.3750
9191	2152	20092	N/A	t	2.0441	1.7059	2.7500	2.0000
9192	2153	20092	N/A	t	2.6985	2.2059	4.0000	2.3750
9193	2154	20092	N/A	t	1.3162	1.2941	1.2500	1.0000
9195	2156	20092	N/A	t	1.9265	2.2647	2.1250	1.8750
9196	2157	20092	N/A	t	2.0368	2.5294	3.2500	1.5000
9198	2159	20092	N/A	t	2.0882	2.1324	2.7500	2.0000
9199	2160	20092	N/A	t	2.4412	2.7500	3.8750	1.8750
9200	2161	20092	N/A	t	1.7365	1.7500	2.3750	1.6250
9202	2163	20092	N/A	t	2.3676	2.3971	2.5000	2.5000
9203	2164	20092	N/A	t	2.5441	3.1912	3.6250	2.8750
9204	2165	20092	N/A	t	2.3971	2.6618	3.8750	1.2500
9206	2167	20092	N/A	t	1.8382	1.9706	2.5000	1.7500
9207	2168	20092	N/A	t	1.9559	1.8971	2.3750	1.1250
9209	2170	20092	N/A	t	2.1471	1.9559	2.8750	1.5000
9210	2171	20092	N/A	t	2.2759	2.3125	3.0000	2.7500
9211	2172	20092	N/A	t	1.7500	1.6912	2.5000	1.5000
9213	2174	20092	N/A	t	2.0588	2.2206	2.8750	2.0000
9214	2175	20092	N/A	t	2.3162	2.5735	3.7500	2.0000
9215	2176	20092	N/A	t	2.4706	2.0735	3.0000	3.0000
9217	2178	20092	N/A	t	2.5147	2.8824	2.6250	2.1250
9218	2179	20092	N/A	t	1.4779	1.4412	2.2500	1.0625
9219	2010	20093	N/A	t	3.0898	1.9250	3.5069	3.2838
9221	2015	20093	N/A	t	2.3942	1.5000	3.0577	1.9878
9222	2016	20093	N/A	t	2.3607	1.8750	2.9231	2.5326
9223	2018	20093	N/A	t	2.5659	5.0000	2.9792	2.7636
9225	2022	20093	N/A	t	2.3451	1.5000	2.1591	2.1744
9226	2019	20093	N/A	t	2.5259	1.0000	2.6635	2.1830
9228	2023	20093	N/A	t	2.3455	3.2500	3.1207	1.8790
9229	2024	20093	N/A	t	2.1987	2.1250	2.4762	1.9632
9230	2026	20093	N/A	t	2.8662	2.6250	3.6207	2.5341
9232	2028	20093	N/A	t	2.8686	3.5000	2.8750	1.5313
9233	2031	20093	N/A	t	2.5373	2.0000	3.4914	1.9324
9234	2069	20093	N/A	t	2.5395	1.2500	3.1579	2.8462
9236	2037	20093	N/A	t	2.4199	1.5000	2.8571	2.2188
9237	2075	20093	N/A	t	2.2692	2.0000	2.5769	2.7500
9238	2039	20093	N/A	t	2.7208	4.5000	3.3696	2.9531
9240	2076	20093	N/A	t	2.4714	5.0000	2.7500	3.3333
9241	2077	20093	N/A	t	2.2560	2.5000	2.5000	2.5192
9242	2078	20093	N/A	t	2.3625	1.7500	2.7188	2.3750
9244	2079	20093	N/A	t	2.5347	2.7500	2.7500	2.3654
9245	2080	20093	N/A	t	2.1855	2.7500	2.5938	2.7885
9246	2046	20093	N/A	t	2.6928	2.0000	3.5192	2.6719
9248	2049	20093	N/A	t	1.7767	1.5000	1.9444	1.3906
9249	2050	20093	N/A	t	1.9201	3.1250	2.3056	2.9091
9251	2053	20093	N/A	t	2.5856	1.7500	3.1957	2.8289
9252	2055	20093	N/A	t	2.3636	2.5000	3.2174	2.0156
9253	2056	20093	N/A	t	2.4660	2.6250	3.1310	2.4531
9255	2060	20093	N/A	t	2.1667	1.5000	2.5278	2.3281
9256	2062	20093	N/A	t	2.8734	2.7500	3.0595	3.0938
9257	2083	20093	N/A	t	1.6000	3.3750	1.7500	2.0962
9259	2064	20093	N/A	t	2.2283	1.7500	1.8472	2.5000
9260	2065	20093	N/A	t	2.4416	3.5000	3.2500	2.8906
8585	2007	20011	N/A	t	2.5036	3.6250	2.5227	3.5938
8631	2009	20052	N/A	t	2.8479	2.2105	3.0417	2.7902
8581	2007	19991	N/A	t	1.8804	1.8804	1.0000	0.0000
8635	2014	20052	N/A	t	1.9929	2.0556	2.1250	1.1250
8582	2007	20001	N/A	t	1.8841	1.8889	1.5000	1.5000
8588	2007	20021	N/A	t	2.7050	3.0500	2.5227	3.3500
8593	2009	20022	N/A	t	2.3824	2.5147	2.6250	2.6250
8596	2009	20031	N/A	t	2.4717	2.6316	2.6667	2.5750
8600	2008	20032	N/A	t	2.5524	2.3438	3.0000	2.9063
8604	2008	20033	N/A	t	2.5341	2.2500	3.0000	2.9063
8608	2008	20041	N/A	t	2.6429	3.0417	3.0000	3.1200
8612	2012	20041	N/A	t	1.7059	1.7059	2.5000	1.0000
8639	2014	20053	N/A	t	1.9756	1.8750	2.1538	1.1250
8616	2011	20042	N/A	t	2.7418	3.9375	3.5096	2.9167
8619	2009	20043	N/A	t	2.9531	1.5000	3.0417	3.4643
8623	2008	20051	N/A	t	2.5294	2.2895	3.0000	2.6887
8627	2012	20051	N/A	t	1.9900	2.1316	2.5000	1.4038
8642	2013	20061	N/A	t	2.9279	3.9375	3.5000	2.2500
8646	2017	20061	N/A	t	1.8676	1.8676	2.7500	2.2500
8650	2009	20062	N/A	t	2.7950	3.0000	3.0417	2.7610
8654	2014	20062	N/A	t	2.1184	2.2917	2.2656	1.9091
8658	2018	20062	N/A	t	2.2279	2.2059	3.0000	2.2500
8662	2013	20063	N/A	t	3.0599	3.0000	3.4000	2.4231
8669	2011	20071	N/A	t	2.6520	3.2500	3.4643	3.0690
8666	2018	20063	N/A	t	2.2566	2.5000	3.0000	2.2500
8673	2015	20071	N/A	t	2.6550	2.9375	3.5000	2.2750
8677	2021	20071	N/A	t	2.3333	2.3333	2.2500	3.0000
8680	2020	20071	N/A	t	2.1102	2.3684	2.9167	1.9250
8688	2030	20071	N/A	t	1.4853	1.4853	1.0000	1.0000
8685	2027	20071	N/A	t	2.2059	2.2059	3.0000	1.7500
8692	2009	20072	N/A	t	2.7988	3.0000	3.0417	2.7610
8696	2014	20072	N/A	t	2.1071	1.7500	2.2656	2.0058
8699	2017	20072	N/A	t	2.3867	3.3158	3.1905	2.6923
8703	2019	20072	N/A	t	2.2979	2.5000	2.6635	1.6923
8707	2025	20072	N/A	t	2.3162	2.5588	2.2500	1.8750
8711	2029	20072	N/A	t	2.4632	2.9706	3.8750	1.7500
9261	2084	20093	N/A	t	1.5655	1.5625	1.5833	1.0000
9262	2089	20093	N/A	t	1.8056	1.3750	1.9167	1.5000
9264	2094	20093	N/A	t	1.9167	2.7500	2.8333	1.1250
9265	2096	20093	N/A	t	2.5676	2.2500	3.8750	2.7500
9266	2101	20093	N/A	t	2.8526	2.5000	3.4167	2.7500
9268	2104	20093	N/A	t	1.9615	2.2500	2.5000	1.3750
9269	2106	20093	N/A	t	2.4487	2.2500	2.6667	3.1250
9270	2107	20093	N/A	t	2.1346	2.0000	2.2500	2.2500
9272	2109	20093	N/A	t	1.8846	1.0000	1.7500	3.7500
9273	2110	20093	N/A	t	1.7628	1.7500	1.8333	1.7500
9275	2116	20093	N/A	t	1.6250	1.7500	1.6250	1.3750
9276	2117	20093	N/A	t	1.7750	1.2500	2.3750	1.5000
9277	2119	20093	N/A	t	2.2647	1.0000	3.1250	2.1250
9279	2121	20093	N/A	t	2.2703	3.3750	3.0000	3.1250
9280	2122	20093	N/A	t	2.0705	2.0000	2.5833	1.2500
9281	2124	20093	N/A	t	2.1987	1.5000	2.6667	1.8750
9283	2134	20093	N/A	t	2.2949	2.0000	2.4167	2.6250
9284	2135	20093	N/A	t	1.4563	1.1250	2.0000	1.0625
9285	2136	20093	N/A	t	2.4744	2.7500	3.5833	1.8750
9287	2141	20093	N/A	t	1.2162	1.0000	1.0962	1.0000
9288	2142	20093	N/A	t	1.2692	1.0000	1.2500	1.2500
9289	2144	20093	N/A	t	2.2115	3.0000	2.7500	1.5000
9291	2146	20093	N/A	t	1.8974	1.5000	2.3333	1.1250
9292	2148	20093	N/A	t	2.3542	2.7500	2.5000	2.7500
9293	2150	20093	N/A	t	1.9295	2.0000	2.1667	2.1250
9295	2152	20093	N/A	t	2.0385	2.0000	2.5000	2.0000
9296	2153	20093	N/A	t	2.6090	2.0000	3.3333	2.3750
9298	2155	20093	N/A	t	2.3333	2.2500	3.4167	2.0000
9299	2157	20093	N/A	t	1.9038	1.0000	2.5000	1.5000
9300	2160	20093	N/A	t	2.4487	2.5000	3.4167	1.8750
9302	2163	20093	N/A	t	2.3036	2.0313	2.5000	2.5000
9303	2164	20093	N/A	t	2.4744	2.0000	3.0833	2.8750
9304	2165	20093	N/A	t	2.3462	2.0000	3.2500	1.2500
9306	2167	20093	N/A	t	1.7905	1.2500	2.5000	1.7500
9307	2168	20093	N/A	t	1.9615	2.0000	2.2500	1.1250
9308	2169	20093	N/A	t	2.5256	5.0000	4.1667	1.2500
9310	2171	20093	N/A	t	2.6765	5.0000	4.0000	2.7500
9311	2172	20093	N/A	t	1.7500	1.7500	2.2500	1.5000
9312	2175	20093	N/A	t	2.2115	1.5000	3.0000	2.0000
9314	2177	20093	N/A	t	1.7756	1.0000	1.9167	1.7500
9315	2178	20093	N/A	t	2.4808	2.2500	2.5000	2.1250
9317	2013	20101	N/A	t	3.0000	3.0357	3.3226	2.9824
9318	2014	20101	N/A	t	2.0634	1.5000	2.2656	1.8482
9319	2015	20101	N/A	t	2.4243	2.7500	3.0577	2.1604
9321	2018	20101	N/A	t	2.5382	2.2083	2.9792	2.7276
9322	2070	20101	N/A	t	2.5306	3.5833	0.0000	2.5608
9323	2021	20101	N/A	t	2.6719	3.0625	3.0952	2.9338
9325	2019	20101	N/A	t	2.5760	5.0000	2.6635	2.1830
9326	2020	20101	N/A	t	2.6062	2.9375	3.0417	2.2545
9328	2034	20101	N/A	t	2.3750	2.1667	3.1316	2.2581
9329	2071	20101	N/A	t	2.2959	2.2500	2.2500	2.1923
9330	2024	20101	N/A	t	2.2898	2.8333	2.4762	2.0969
9332	2026	20101	N/A	t	2.9956	3.8500	3.6207	2.8214
9333	2027	20101	N/A	t	2.4190	2.5000	2.9643	2.3041
9334	2028	20101	N/A	t	2.8477	3.1250	3.0473	1.6447
9336	2030	20101	N/A	t	2.2750	2.0000	2.3646	1.9620
9337	2031	20101	N/A	t	2.6093	3.0000	3.4914	2.1683
9338	2032	20101	N/A	t	2.0469	1.8026	2.2813	1.9375
9340	2033	20101	N/A	t	2.1329	2.9167	2.4405	2.2449
9341	2072	20101	N/A	t	2.5441	1.8833	3.5000	1.7692
9342	2073	20101	N/A	t	2.6625	2.4605	3.4861	2.7885
9344	2074	20101	N/A	t	2.2170	2.1184	3.0000	1.7750
9345	2183	20101	N/A	t	2.9167	2.9167	2.7500	3.0000
9347	2037	20101	N/A	t	2.5057	2.8750	2.8571	2.6705
8715	2033	20072	N/A	t	1.6912	1.6618	2.3750	1.1250
8903	2031	20091	N/A	t	2.6139	3.4167	3.4914	1.7500
8717	2014	20073	N/A	t	2.1071	0.0000	2.2656	2.0058
8983	2114	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
8718	2015	20073	N/A	t	2.5933	2.3571	3.5000	2.2750
8721	2021	20073	N/A	t	3.1026	2.1250	3.6250	4.0000
8724	2023	20073	N/A	t	2.1090	1.7500	3.0833	1.5000
8907	2072	20091	N/A	t	2.9306	2.9306	5.0000	1.7500
8729	2011	20081	N/A	t	2.6061	2.7917	3.4643	2.8000
8732	2015	20081	N/A	t	2.6042	2.6471	3.1875	2.2692
8736	2021	20081	N/A	t	2.8611	2.2333	3.3333	3.0833
8740	2023	20081	N/A	t	2.1591	2.2813	2.9891	1.4000
8743	2025	20081	N/A	t	2.3942	2.7500	2.5000	1.8750
8747	2029	20081	N/A	t	2.3448	2.2237	3.1875	1.9500
8751	2033	20081	N/A	t	1.8160	2.0395	2.4167	1.1750
8755	2038	20081	N/A	t	2.0294	2.0294	3.0000	2.2500
8759	2042	20081	N/A	t	2.0882	2.0882	2.0000	1.0000
8763	2046	20081	N/A	t	3.1471	3.1471	5.0000	2.5000
8911	2036	20091	N/A	t	1.7500	1.8421	2.1667	1.1750
8767	2050	20081	N/A	t	1.6765	1.6765	2.2500	1.0000
8770	2053	20081	N/A	t	2.0882	2.0882	2.7500	1.0000
8774	2057	20081	N/A	t	3.0588	3.0588	2.7500	5.0000
8778	2061	20081	N/A	t	2.2941	2.2941	3.0000	2.2500
8914	2038	20091	N/A	t	2.3233	2.1316	3.4375	2.0750
8782	2065	20081	N/A	t	2.3824	2.3824	3.0000	2.0000
8786	2010	20082	N/A	t	3.0301	3.0769	3.3083	3.0000
8789	2014	20082	N/A	t	2.0763	1.8750	2.2656	1.8679
8793	2018	20082	N/A	t	2.5381	2.8500	2.9792	2.7500
8797	2020	20082	N/A	t	2.5236	2.9500	3.0417	2.4113
8800	2024	20082	N/A	t	2.1667	2.3289	2.4762	1.7308
8804	2028	20082	N/A	t	2.7266	2.0313	3.0543	1.4167
8808	2032	20082	N/A	t	2.0978	2.1563	2.2143	2.1000
8812	2036	20082	N/A	t	1.6985	1.6029	2.2500	1.1250
8816	2040	20082	N/A	t	2.5588	2.7206	3.0000	2.8750
8819	2043	20082	N/A	t	2.0809	2.1324	2.5000	2.3750
8823	2047	20082	N/A	t	3.0735	3.3676	4.0000	2.2500
8827	2051	20082	N/A	t	2.1176	2.0882	2.6250	1.8750
8831	2055	20082	N/A	t	2.3952	1.8824	3.7500	1.7500
8835	2059	20082	N/A	t	1.9559	2.0294	2.3750	1.0000
8838	2062	20082	N/A	t	2.5294	2.5735	2.7500	2.6250
8842	2066	20082	N/A	t	2.0956	2.3676	2.6250	2.2500
8846	2011	20083	N/A	t	2.5451	2.0000	3.4643	2.7264
8850	2019	20083	N/A	t	2.4917	2.1667	2.6635	2.2568
8919	2077	20091	N/A	t	1.9375	1.9375	0.0000	3.0000
8853	2025	20083	N/A	t	2.5616	2.7500	2.7500	2.9423
8922	2043	20091	N/A	t	2.4434	3.0921	3.3333	2.0250
8854	2026	20083	N/A	t	2.7571	2.7500	3.3750	2.4423
8857	2030	20083	N/A	t	2.3000	3.7500	2.3646	1.8654
8860	2038	20083	N/A	t	2.4167	2.7500	3.5833	2.1250
8864	2046	20083	N/A	t	2.7692	2.7500	3.5000	3.2500
8868	2051	20083	N/A	t	2.4872	5.0000	3.4167	1.8750
8872	2057	20083	N/A	t	2.2297	1.6563	2.2500	3.1250
8876	2063	20083	N/A	t	1.9709	2.3611	1.8333	1.5000
8879	2066	20083	N/A	t	2.0513	1.7500	2.3333	2.2500
8884	2015	20091	N/A	t	2.5045	1.9231	3.0577	2.1827
8887	2018	20091	N/A	t	2.5085	2.5000	2.9792	2.6750
8891	2019	20091	N/A	t	2.5704	2.7500	2.6635	2.3163
8895	2071	20091	N/A	t	2.0500	2.0500	2.2500	2.0000
8899	2027	20091	N/A	t	2.4321	2.5000	2.9643	2.2344
8926	2045	20091	N/A	t	2.1226	2.1316	2.3333	2.2000
8930	2049	20091	N/A	t	1.7589	1.4412	2.0833	1.2500
8933	2052	20091	N/A	t	2.2830	2.5526	2.8333	1.8250
8937	2081	20091	N/A	t	2.1833	2.1833	3.0000	1.5000
8941	2058	20091	N/A	t	2.5647	2.5132	3.4375	2.6000
8945	2062	20091	N/A	t	2.6830	2.8971	3.1944	2.7750
8949	2065	20091	N/A	t	2.5802	2.2857	3.5833	2.5250
8952	2068	20091	N/A	t	2.6276	2.8000	3.5833	3.5833
8987	2118	20091	N/A	t	1.5294	1.5294	1.7500	1.5000
8957	2088	20091	N/A	t	1.5294	1.5294	1.7500	1.7500
8960	2091	20091	N/A	t	2.2647	2.2647	2.0000	2.7500
8964	2095	20091	N/A	t	2.0882	2.0882	2.7500	2.5000
8968	2099	20091	N/A	t	1.3971	1.3971	1.0000	1.0000
8972	2103	20091	N/A	t	1.7353	1.7353	2.0000	1.7500
9012	2143	20091	N/A	t	1.2647	1.2647	1.0000	1.0000
8976	2107	20091	N/A	t	2.2206	2.2206	2.0000	2.5000
8979	2110	20091	N/A	t	1.6471	1.6471	2.0000	1.7500
8989	2120	20091	N/A	t	2.7059	2.7059	5.0000	2.0000
9016	2147	20091	N/A	t	1.3529	1.3529	1.0000	1.5000
8990	2121	20091	N/A	t	2.5588	2.5588	3.0000	3.0000
8993	2124	20091	N/A	t	2.1912	2.1912	2.5000	1.7500
9019	2150	20091	N/A	t	2.0735	2.0735	2.2500	2.2500
8997	2128	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
9000	2131	20091	N/A	t	1.5147	1.5147	1.2500	1.5000
9004	2135	20091	N/A	t	1.4706	1.4706	2.0000	1.0000
9008	2139	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
9023	2154	20091	N/A	t	1.3382	1.3382	1.2500	1.0000
9027	2158	20091	N/A	t	1.3824	1.3824	1.2500	1.0000
9031	2162	20091	N/A	t	1.8971	1.8971	3.0000	2.0000
9035	2166	20091	N/A	t	2.4265	2.4265	3.0000	2.7500
9039	2170	20091	N/A	t	2.3382	2.3382	3.0000	1.7500
9042	2173	20091	N/A	t	2.3088	2.3088	2.7500	2.2500
9046	2177	20091	N/A	t	1.6176	1.6176	1.7500	1.7500
9050	2013	20092	N/A	t	3.0171	2.0357	3.3226	3.0224
9053	2017	20092	N/A	t	2.4675	2.2500	3.1667	2.7500
9057	2022	20092	N/A	t	2.3736	1.8750	2.1591	2.2250
9061	2034	20092	N/A	t	2.4286	2.4583	3.1316	2.2237
9065	2026	20092	N/A	t	2.8817	3.1538	3.7500	2.5341
9069	2030	20092	N/A	t	2.3143	1.9000	2.3646	1.9485
9072	2069	20092	N/A	t	2.6111	2.9219	3.1579	2.8462
9076	2035	20092	N/A	t	2.2857	3.4265	2.6111	2.4219
9080	2075	20092	N/A	t	2.3182	3.0417	2.7500	3.0000
9084	2041	20092	N/A	t	2.2992	2.8906	3.1250	2.2188
9088	2078	20092	N/A	t	2.4122	2.3553	2.7188	2.5833
9091	2079	20092	N/A	t	2.5000	2.3684	2.7500	2.3654
9095	2046	20092	N/A	t	2.7468	3.0375	3.5192	2.6719
9099	2181	20092	N/A	t	2.2500	2.2500	3.0000	2.5000
9103	2053	20092	N/A	t	2.6604	3.2250	3.3750	3.0781
9107	2056	20092	N/A	t	2.4533	3.1316	3.1944	2.4531
9110	2058	20092	N/A	t	2.5507	2.8947	3.3804	3.1250
9114	2062	20092	N/A	t	2.8800	3.4605	3.0595	3.0938
9118	2064	20092	N/A	t	2.2500	2.0938	1.8472	2.5000
9122	2068	20092	N/A	t	2.5692	2.3906	3.5833	3.6000
9294	2151	20093	N/A	t	2.0577	1.2500	2.0000	2.3750
9125	2086	20092	N/A	t	1.9118	1.9265	2.3750	1.8750
9297	2154	20093	N/A	t	1.2688	1.0000	1.2500	1.0000
9126	2087	20092	N/A	t	2.2353	2.2353	2.5000	2.8750
9129	2090	20092	N/A	t	2.3088	1.8676	2.3750	3.6250
9132	2093	20092	N/A	t	1.5000	1.5147	1.8750	1.2500
9136	2097	20092	N/A	t	1.9926	1.7941	2.5000	2.1250
9140	2101	20092	N/A	t	2.9044	2.7941	3.8750	2.7500
9144	2105	20092	N/A	t	1.4338	1.4265	1.5000	1.2500
9148	2109	20092	N/A	t	2.0147	2.4118	2.1250	3.7500
9151	2112	20092	N/A	t	1.9632	2.0735	2.2500	1.7500
9155	2116	20092	N/A	t	1.6029	1.8529	1.6250	1.3750
9159	2120	20092	N/A	t	2.3162	1.9265	3.7500	2.2500
9163	2124	20092	N/A	t	2.3015	2.4118	3.2500	1.8750
9167	2128	20092	N/A	t	1.8382	2.1912	2.1250	1.5000
9301	2161	20093	N/A	t	1.7381	1.7500	2.1667	1.6250
9171	2132	20092	N/A	t	1.5147	1.7647	2.0000	1.0000
9175	2136	20092	N/A	t	2.4338	2.8824	4.0000	1.8750
9178	2139	20092	N/A	t	2.2794	2.2206	2.5000	2.6250
9182	2143	20092	N/A	t	1.4338	1.6029	1.1250	1.0000
9186	2147	20092	N/A	t	1.3971	1.4412	1.3750	1.3750
9189	2150	20092	N/A	t	1.9191	1.7647	2.2500	2.1250
9305	2166	20093	N/A	t	2.1857	1.3750	3.0000	2.8750
9194	2155	20092	N/A	t	2.3456	2.6176	4.0000	2.0000
9197	2158	20092	N/A	t	1.3824	1.3824	1.2500	1.0000
9201	2162	20092	N/A	t	2.1397	2.3824	3.0000	1.7500
9205	2166	20092	N/A	t	2.3534	2.2500	3.0000	2.8750
9208	2169	20092	N/A	t	2.1618	1.6618	3.7500	1.2500
9212	2173	20092	N/A	t	2.7941	3.2794	3.8750	3.6250
9216	2177	20092	N/A	t	1.8897	2.1618	2.3750	1.7500
9220	2013	20093	N/A	t	2.9985	2.0000	3.3226	3.0224
9224	2070	20093	N/A	t	1.9194	1.7500	0.0000	2.0568
9227	2020	20093	N/A	t	2.5803	1.5000	3.0417	2.2972
9231	2027	20093	N/A	t	2.3844	1.7500	2.9643	2.2700
9235	2073	20093	N/A	t	2.7561	2.7500	3.5833	2.8750
9239	2040	20093	N/A	t	2.9219	2.7222	3.1000	3.2188
9243	2043	20093	N/A	t	2.6133	2.2500	2.9891	2.2500
9247	2047	20093	N/A	t	2.7110	1.5000	3.7500	2.6538
9250	2051	20093	N/A	t	2.3885	1.5000	3.2500	2.7237
9254	2058	20093	N/A	t	2.5000	1.8750	3.3804	2.9474
9258	2063	20093	N/A	t	2.5353	5.0000	2.3810	3.0000
9263	2090	20093	N/A	t	2.2692	2.0000	2.2500	3.6250
9267	2103	20093	N/A	t	1.6603	1.2500	1.6667	2.0000
9271	2108	20093	N/A	t	1.6000	1.5000	1.3750	1.5000
9274	2113	20093	N/A	t	2.1154	2.5000	2.5000	2.2500
9278	2120	20093	N/A	t	2.6603	5.0000	4.1667	2.2500
9282	2125	20093	N/A	t	1.6284	1.2500	1.2885	1.7500
9286	2137	20093	N/A	t	1.9615	1.0000	2.7500	1.6250
9309	2170	20093	N/A	t	2.2564	3.0000	2.9167	1.5000
9290	2145	20093	N/A	t	1.9250	1.2500	2.3750	2.1250
9313	2176	20093	N/A	t	2.5385	3.0000	3.0000	3.0000
9316	2010	20101	N/A	t	3.1624	3.8500	3.5069	3.3520
9320	2016	20101	N/A	t	2.3429	2.1250	2.9231	2.4279
9324	2022	20101	N/A	t	2.3905	2.7656	2.1591	2.3347
9327	2023	20101	N/A	t	2.4316	2.9583	3.1207	2.0349
9331	2025	20101	N/A	t	2.5289	2.1250	2.7500	2.4628
9335	2029	20101	N/A	t	2.6088	2.9500	3.1442	2.3919
9339	2069	20101	N/A	t	2.7397	3.4531	3.1579	2.6875
9343	2035	20101	N/A	t	2.3077	2.4000	2.6111	2.3553
9346	2036	20101	N/A	t	1.7472	1.5000	2.2639	1.4919
\.


--
-- Data for Name: terms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY terms (termid, name, year, sem) FROM stdin;
20091	1st Semester 2009-2010	2009-2010	1st
20092	2nd Semester 2009-2010	2009-2010	2nd
20093	Summer Semester 2009-2010	2009-2010	Sum
20101	1st Semester 2010-2011	2010-2011	1st
20102	2nd Semester 2010-2011	2010-2011	2nd
20103	Summer Semester 2010-2011	2010-2011	Sum
20111	1st Semester 2011-2012	2011-2012	1st
20112	2nd Semester 2011-2012	2011-2012	2nd
20113	Summer Semester 2011-2012	2011-2012	Sum
20121	1st Semester 2012-2013	2012-2013	1st
20122	2nd Semester 2012-2013	2012-2013	2nd
20123	Summer Semester 2012-2013	2012-2013	Sum
20081	1st Semester 2008-2009	2008-2009	1st
20082	2nd Semester 2008-2009	2008-2009	2nd
20083	Summer 2008-2009	2008-2009	Sum
20131	1st Semester 2013-2014	2013-2014	1st
20132	2nd Semester 2013-2014	2013-2014	2nd
20133	Summer 2013-2014	2013-2014	Sum
19991	1st Semester 1999-2000	1999-2000	1st
20001	1st Semester 2000-2001	2000-2001	1st
20002	2nd Semester 2000-2001	2000-2001	2nd
20003	Summer 2000-2001	2000-2001	Sum
20011	1st Semester 2001-2002	2001-2002	1st
20012	2nd Semester 2001-2002	2001-2002	2nd
20013	Summer 2001-2002	2001-2002	Sum
20021	1st Semester 2002-2003	2002-2003	1st
20022	2nd Semester 2002-2003	2002-2003	2nd
20031	1st Semester 2003-2004	2003-2004	1st
20032	2nd Semester 2003-2004	2003-2004	2nd
20033	Summer 2003-2004	2003-2004	Sum
20041	1st Semester 2004-2005	2004-2005	1st
20042	2nd Semester 2004-2005	2004-2005	2nd
20043	Summer 2004-2005	2004-2005	Sum
20051	1st Semester 2005-2006	2005-2006	1st
20052	2nd Semester 2005-2006	2005-2006	2nd
20053	Summer 2005-2006	2005-2006	Sum
20061	1st Semester 2006-2007	2006-2007	1st
20062	2nd Semester 2006-2007	2006-2007	2nd
20063	Summer 2006-2007	2006-2007	Sum
20071	1st Semester 2007-2008	2007-2008	1st
20072	2nd Semester 2007-2008	2007-2008	2nd
20073	Summer 2007-2008	2007-2008	Sum
\.


--
-- Name: classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (classid);


--
-- Name: courses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (courseid);


--
-- Name: curricula_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY curricula
    ADD CONSTRAINT curricula_pkey PRIMARY KEY (curriculumid);


--
-- Name: grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (gradeid);


--
-- Name: ineligibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ineligibilities
    ADD CONSTRAINT ineligibilities_pkey PRIMARY KEY (ineligibilityid);


--
-- Name: instructorclasses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY instructorclasses
    ADD CONSTRAINT instructorclasses_pkey PRIMARY KEY (instructorclassid);


--
-- Name: instructors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY instructors
    ADD CONSTRAINT instructors_pkey PRIMARY KEY (instructorid);


--
-- Name: persons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (personid);


--
-- Name: requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requirements
    ADD CONSTRAINT requirements_pkey PRIMARY KEY (requirementid);


--
-- Name: studentclasses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY studentclasses
    ADD CONSTRAINT studentclasses_pkey PRIMARY KEY (studentclassid);


--
-- Name: students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY students
    ADD CONSTRAINT students_pkey PRIMARY KEY (studentid);


--
-- Name: studentterms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY studentterms
    ADD CONSTRAINT studentterms_pkey PRIMARY KEY (studenttermid);


--
-- Name: terms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY terms
    ADD CONSTRAINT terms_pkey PRIMARY KEY (termid);


--
-- Name: classes_termid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY classes
    ADD CONSTRAINT classes_termid_fkey FOREIGN KEY (termid) REFERENCES terms(termid);


--
-- Name: instructorclasses_classid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY instructorclasses
    ADD CONSTRAINT instructorclasses_classid_fkey FOREIGN KEY (classid) REFERENCES classes(classid);


--
-- Name: instructorclasses_instructorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY instructorclasses
    ADD CONSTRAINT instructorclasses_instructorid_fkey FOREIGN KEY (instructorid) REFERENCES instructors(instructorid);


--
-- Name: instructors_personid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY instructors
    ADD CONSTRAINT instructors_personid_fkey FOREIGN KEY (personid) REFERENCES persons(personid);


--
-- Name: studentclasses_classid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentclasses
    ADD CONSTRAINT studentclasses_classid_fkey FOREIGN KEY (classid) REFERENCES classes(classid);


--
-- Name: studentclasses_gradeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentclasses
    ADD CONSTRAINT studentclasses_gradeid_fkey FOREIGN KEY (gradeid) REFERENCES grades(gradeid);


--
-- Name: studentclasses_studenttermid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentclasses
    ADD CONSTRAINT studentclasses_studenttermid_fkey FOREIGN KEY (studenttermid) REFERENCES studentterms(studenttermid);


--
-- Name: studentineligibilities_ineligibilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentineligibilities
    ADD CONSTRAINT studentineligibilities_ineligibilityid_fkey FOREIGN KEY (ineligibilityid) REFERENCES ineligibilities(ineligibilityid);


--
-- Name: students_curriculumid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY students
    ADD CONSTRAINT students_curriculumid_fkey FOREIGN KEY (curriculumid) REFERENCES curricula(curriculumid);


--
-- Name: students_personid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY students
    ADD CONSTRAINT students_personid_fkey FOREIGN KEY (personid) REFERENCES persons(personid);


--
-- Name: studentterms_studentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentterms
    ADD CONSTRAINT studentterms_studentid_fkey FOREIGN KEY (studentid) REFERENCES students(studentid);


--
-- Name: studentterms_termid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentterms
    ADD CONSTRAINT studentterms_termid_fkey FOREIGN KEY (termid) REFERENCES terms(termid);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

