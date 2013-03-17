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
		WHERE ($1 % 10 = 1 AND termid = $1)	-- 1st Semester
			OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
			OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			AS temp
	WHERE failpercentage > 0.5;
$_$;


ALTER FUNCTION public.f_elig_passhalf_mathcs_persem(p_termid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalf_mathcs_persem_student(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalf_mathcs_persem_student(p_termid integer, p_studentid integer) RETURNS SETOF t_elig_passhalf_mathcs_persem
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_elig_passhalf_mathcs_persem_student(p_termid integer, p_studentid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalfpersem(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalfpersem(p_termid integer) RETURNS SETOF t_elig_passhalfpersem
    LANGUAGE sql
    AS $_$
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
		WHERE ($1 % 10 = 1 AND termid = $1)	-- 1st Semester
			OR ($1 % 10 = 2 AND termid in ($1, $1 + 1))	-- 2nd Semester (+Summer)
			OR ($1 % 10 = 3 AND termid in ($1, $1 - 1)))	-- Summer (+2nd Semester)
			AS temp
	WHERE failpercentage > 0.5;
$_$;


ALTER FUNCTION public.f_elig_passhalfpersem(p_termid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalfpersem_student(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalfpersem_student(p_termid integer, p_studentid integer) RETURNS SETOF t_elig_passhalfpersem
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.f_elig_twicefailsubjects_student(p_termid integer, studentid integer) OWNER TO postgres;

--
-- Name: f_getall_24unitspassed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_24unitspassed() RETURNS SETOF t_elig_24unitspassed
    LANGUAGE plpgsql
    AS $$
	DECLARE
		tempyearid integer;
		tempdata record;
	BEGIN
		
		FOR tempyearid IN
			SELECT DISTINCT (termid / 10) AS yearid 
			FROM terms
		LOOP
			FOR tempdata IN 
				SELECT * FROM f_elig_24unitspassed_singleyear(tempyearid)
			LOOP
				RETURN NEXT tempdata;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$;


ALTER FUNCTION public.f_getall_24unitspassed() OWNER TO postgres;

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
-- Name: f_getall_eligpasshalfmathcs_student(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_getall_eligpasshalfmathcs_student() RETURNS SETOF t_elig_passhalf_mathcs_persem
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


ALTER FUNCTION public.f_getall_eligpasshalfmathcs_student() OWNER TO postgres;

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
	SELECT eligtwicefail.*
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

SELECT pg_catalog.setval('classes_classid_seq', 19979, true);


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

SELECT pg_catalog.setval('persons_personid_seq', 2721, true);


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

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 50536, true);


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

SELECT pg_catalog.setval('students_studentid_seq', 2711, true);


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

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 11397, true);


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
18178	19991	98	TFQ1	418
18179	19991	116	WBC	919
18180	19991	117	11	3557
18181	19991	94	MHQ3	3983
18182	19991	81	MHW	6800
18183	19991	55	TFR2	9661
18184	19991	106	MTHFX6	9764
18185	20001	33	TFR3	12225
18186	20001	108	MTHFW3	35242
18187	20001	110	MTHFI	37302
18188	20001	102	MHR-S	41562
18189	20001	2	HMXY	44901
18190	20002	109	MHW2	35238
18191	20002	118	TFQ	35271
18192	20002	111	MTHFD	37331
18193	20002	3	TFXY	44911
18194	20002	5	MHX1	44913
18195	20003	118	X3-2	35181
18196	20003	95	X1-1	38511
18197	20011	34	TFW-3	11676
18198	20011	119	MHX	35252
18199	20011	103	TFY2	40385
18200	20011	6	TFR	44922
18201	20011	5	W1	44944
18202	20012	113	MHX3	13972
18203	20012	103	MHU1	40344
18204	20012	11	MHY	44919
18205	20012	19	TFR	44921
18206	20012	24	TFY	44939
18207	20012	114	TFZ	45440
18208	20013	39	X6-D	14922
18209	20013	11	X3	44906
18210	20021	8	TFY	44920
18211	20021	6	TFW	44922
18212	20021	7	MHXY	44925
18213	20021	120	TFV	44931
18214	20021	114	MHW	45405
18215	20021	41	TFX2	12350
18216	20021	106	MTHFU1	35138
18217	20021	98	TFY1	39648
18218	20021	81	MHY	41805
18219	20021	1	MHVW	44901
18220	20021	41	TFV6	12389
18221	20021	106	MTHFW4	35161
18222	20021	94	MHV1	38510
18223	20021	81	TFR	41807
18224	20021	1	MHXY	44902
18225	20022	19	TFX	44918
18226	20022	9	TFV	44925
18227	20022	27	TFW	44927
18228	20022	70	TFR2	33729
18229	20022	107	MTHFV1	35165
18230	20022	95	MHX	38533
18231	20022	100	MHW2	39648
18232	20022	2	MHRU	44900
18233	20022	71	MHR	34200
18234	20022	107	MTHFW3	35173
18235	20022	100	MHV	39646
18236	20022	82	TFU	41814
18237	20022	2	MHXY	44901
18238	20031	121	MHW2	16602
18239	20031	17	MHX	54566
18240	20031	20	WSVX2	54582
18241	20031	14	TFVW	54603
18242	20031	122	MHY	54604
18243	20031	123	MHW	14482
18244	20031	63	MHV	15620
18245	20031	109	TFU2	39320
18246	20031	110	MTHFX	41352
18247	20031	93	MHU1	46314
18248	20031	2	TFVW	54555
18249	20031	34	TFV-2	13921
18250	20031	108	MTHFW1	39247
18251	20031	110	MTHFD	41419
18252	20031	93	TFY2	46310
18253	20031	3	MHXY	54560
18254	20031	43	MHW2	14467
18255	20031	106	MTHFX8	39221
18256	20031	82	TFR	41908
18257	20031	1	MHRU	54550
18258	20031	88	(1)	62806
18259	20031	41	TFQ2	14425
18260	20031	106	MTHFW6	39211
18261	20031	82	MHQ	41905
18262	20031	103	MHX2	44662
18263	20031	1	TFRU	54553
18264	20032	20	WSVX2	54595
18265	20032	42	TFW1	14435
18266	20032	73	MTHW	38073
18267	20032	119	MHX	39321
18268	20032	94	TFX2	45813
18269	20032	3	FTRU	54560
18270	20032	5	MHU	54561
18271	20032	109	TFV1	39278
18272	20032	119	MHW	39320
18273	20032	111	MTHFV	41488
18274	20032	95	TFX1	45839
18275	20032	5	MHX	54562
18276	20032	42	TFU2	14432
18277	20032	107	MTHFR3	39215
18278	20032	81	MHW	41902
18279	20032	102	MHU	45213
18280	20032	2	TFVW	54558
18281	20032	107	MTHFW2	39236
18282	20032	98	WSR2	42601
18283	20032	102	TFQ	45220
18284	20032	94	TFR3	45801
18285	20032	1	MHRU	54552
18286	20033	110	Y3	41355
18287	20033	111	Y3	41362
18288	20033	43	X3A	14411
18289	20033	98	X1-1	42451
18290	20033	108	Z1-2	39183
18291	20041	62	MHX1	15613
18292	20041	119	TFW	39305
18293	20041	7	HMRU	54555
18294	20041	8	TFR	54569
18295	20041	6	TFU	54572
18296	20041	112	MHV	70025
18297	20041	36	TFR-1	13856
18298	20041	35	WIJK	15505
18299	20041	109	MHW2	39395
18300	20041	114	TFW	52451
18301	20041	5	MHU	54563
18302	20041	31	MHR1	15507
18303	20041	108	MTHFW2	39255
18304	20041	110	MTHFX	41354
18305	20041	94	MHU5	45761
18306	20041	3	TFRU	54561
18307	20041	41	MHX3	14423
18308	20041	108	MTHFQ2	39369
18309	20041	110	MTHFD	41350
18310	20041	81	MHW	41902
18311	20041	2	TFVW	54557
18312	20041	41	TFQ1	14428
18313	20041	106	MTHFW2	39208
18314	20041	76	MHX	40826
18315	20041	98	TFX2	42471
18316	20041	1	MHRU	54550
18317	20042	113	MHX1	15672
18318	20042	124	TFY	47972
18319	20042	19	MHR	54564
18320	20042	12	TFRU	54573
18321	20042	24	MHU	54597
18322	20042	11	TFV	54598
18323	20042	42	MHW1	14429
18324	20042	55	TFU1	15568
18325	20042	113	MHV3	15668
18326	20042	41	MHR	14401
18327	20042	73	MTHU-2	38052
18328	20042	109	TFU2	39271
18329	20042	119	TFR	39311
18330	20042	110	MTHFI	41352
18331	20042	5	MHX	54561
18332	20042	43	MHV2	14460
18333	20042	119	TFQ	39178
18334	20042	109	TFR	39268
18335	20042	111	MTHFD	41379
18336	20042	42	MHU1	14421
18337	20042	107	MTHFQ2	39209
18338	20042	95	MHR1	45780
18339	20042	93	TFR3	46324
18340	20042	2	MHXY	54557
18341	20043	39	X3-A	16057
18342	20043	111	Y4	41354
18343	20043	84	X4	41905
18344	20043	103	X-5-2	44660
18345	20043	111	Y1	41353
18346	20043	109	X1-1	39196
18347	20043	108	Z1-4	39187
18348	20051	114	MHR	52454
18349	20051	17	MHX	54567
18350	20051	8	TFY	54570
18351	20051	122	MHU	54577
18352	20051	20	WSVX2	54581
18353	20051	27	WRU	54588
18354	20051	21	FR	54592
18355	20051	114	TFU	52455
18356	20051	17	MHU	54566
18357	20051	6	TFW	54573
18358	20051	7	HMXY	54575
18359	20051	112	MHR	69953
18360	20051	113	TFU2	15702
18361	20051	48	MTU	19924
18362	20051	119	TFR	39309
18363	20051	111	MTHFI	41439
18364	20051	94	MHX3	45771
18365	20051	5	TFX	54562
18366	20051	62	TFR1	15564
18367	20051	119	TFQ	39308
18368	20051	93	TFV1	46329
18369	20051	3	MHXY	54559
18370	20051	71	TFX	38890
18371	20051	108	MTHFU1	39242
18372	20051	110	MTHFI	41412
18373	20051	29	WSR	54589
18374	20051	41	TFV2	14437
18375	20051	70	MHV	37502
18376	20051	106	MTHFW4	39212
18377	20051	94	TFQ2	45773
18378	20051	1	MHXY	54551
18379	20051	41	MHU3	14410
18380	20051	71	MHQ	38678
18381	20051	107	MTHFR	39228
18382	20051	98	TFQ3	42463
18383	20051	1	TFVW	54553
18384	20052	76	MHX	40806
18385	20052	115	MHL	52457
18386	20052	115	MHLM	52459
18387	20052	14	TFRU	54570
18388	20052	9	TFW	54573
18389	20052	27	WRU	54575
18390	20052	22	WSVX2	54584
18391	20052	42	MHY	14425
18392	20052	14	HMVW	54568
18393	20052	122	MHU	54571
18394	20052	28	TFV	54576
18395	20052	12	TFXY	54579
18396	20052	21	TR	54580
18397	20052	125	MHTFX	15078
18398	20052	126	MHTFX	15079
18399	20052	60	BMR1	33107
18400	20052	111	MTHFD	41375
18401	20052	103	MHV2	44695
18402	20052	91	MI1	67273
18403	20052	61	MHX1	15613
18404	20052	109	MHV	39215
18405	20052	119	TFV	39279
18406	20052	111	MTHFR	41467
18407	20052	94	MHU2	45759
18408	20052	5	TFU	54561
18409	20052	39	MHR-1	16052
18410	20052	107	MTHFV4	39184
18411	20052	81	TFR	41903
18412	20052	95	TFU1	45811
18413	20052	2	MHXY	54554
18414	20052	108	MTHFX3	39209
18415	20052	110	MTHFV	41353
18416	20052	102	MHQ	44152
18417	20052	2	TFRU	54555
18418	20053	87	MTWHFAB	47950
18419	20053	18	X2	54550
18420	20053	109	X3-2	39181
18421	20053	107	Z3-2	39170
18422	20053	70	X3	37501
18423	20053	109	X2	39179
18424	20061	114	WIJF	52455
18425	20061	114	WIJT1	52456
18426	20061	19	TFX	54565
18427	20061	20	MHXYM2	54582
18428	20061	113	TFZ1	15681
18429	20061	109	MHV	39271
18430	20061	114	WIJT2	52457
18431	20061	6	HMRU	54569
18432	20061	7	TFRU	54574
18433	20061	8	GS2	54603
18434	20061	37	TFX-2	13886
18435	20061	108	MTHFW1	39186
18436	20061	110	MTHFV	41356
18437	20061	93	TFR2	46327
18438	20061	3	MHRU	54557
18439	20061	39	MHX2	16069
18440	20061	111	MTHFV	41382
18441	20061	3	TFXY	54560
18442	20061	5	TFU	54561
18443	20061	29	WSR	54597
18444	20061	41	TFV2	14520
18445	20061	70	MHU	37501
18446	20061	106	MTHFW1	39189
18447	20061	99	TFR	42466
18448	20061	1	MHXY	54551
18449	20061	39	MHR3	16054
18450	20061	106	MTHFQ1	39150
18451	20061	83	MHW	41434
18452	20061	104	TFU	47970
18453	20061	1	TFVW	54553
18454	20061	43	MHV2	14551
18455	20061	106	MTHFX1	39197
18456	20061	76	TFU	40807
18457	20061	105	MHQ	43553
18458	20061	80	TFW	40252
18459	20061	100	MHY2	42478
18460	20061	1	WSRU	54599
18461	20061	41	MHR2	14493
18462	20061	106	MTHFY5	39299
18463	20061	94	TFW2	45853
18464	20061	93	MHV6	46380
18465	20061	41	TFU3	14518
18466	20061	106	MTHFX4	39200
18467	20061	82	MHY	41911
18468	20061	94	TFR3	45763
18469	20061	1	SWRU	54600
18470	20062	115	MHK	52449
18471	20062	115	MHKH	52450
18472	20062	22	W1	54595
18473	20062	36	MHQ-2	13851
18474	20062	42	TFU1	14589
18475	20062	119	TFQ	39314
18476	20062	3	MHXY	54559
18477	20062	24	MHW	54571
18478	20062	100	TFU1	42493
18479	20062	115	MHKM	52451
18480	20062	11	MHY	54565
18481	20062	14	TFVW	54567
18482	20062	9	FTXY	54570
18483	20062	12	MHVW	54573
18484	20062	63	TFX1	15613
18485	20062	108	MTHFR3	39259
18486	20062	111	MTHFY	41440
18487	20062	98	MHV2	42456
18488	20062	5	TFU	54562
18489	20062	119	TFR	39315
18490	20062	81	MHR	41900
18491	20062	100	MHW1	42487
18492	20062	93	TFX2	46335
18493	20062	7	WRUVX	54602
18494	20062	39	MHR1	16054
18495	20062	107	MTHFU5	39212
18496	20062	94	TFV2	45786
18497	20062	93	MHV5	46316
18498	20062	2	TFXY	54558
18499	20062	40	TFX1	14591
18500	20062	62	MHU2	15598
18501	20062	106	MTHFW-1	39184
18502	20062	100	MHX	42489
18503	20062	2	TFRU	54557
18504	20062	36	MHV-2	13859
18505	20062	40	TFV1	14476
18506	20062	47	Z	19918
18507	20062	107	MTHFW1	39201
18508	20062	2	MHRU	54552
18509	20062	41	TFX	14415
18510	20062	107	MTHFV6	39225
18511	20062	98	TFQ1	42460
18512	20062	93	TFR	46328
18513	20062	42	MHR	14417
18514	20062	106	MTHFQ-1	39197
18515	20062	100	MHW2	42488
18516	20062	95	TFV2	45812
18517	20062	107	MTHFQ6	39395
18518	20062	98	TFX1	42466
18519	20062	105	TFW	43616
18520	20063	18	X2	54550
18521	20063	111	Y3	41353
18522	20063	113	X1B	15527
18523	20063	107	Z1-A	39176
18524	20063	110	Y2	41350
18525	20063	110	Y3	41351
18526	20063	107	Z2-C	39175
18527	20063	36	X2-A	13855
18528	20063	127	X1A	15540
18529	20071	114	TFL	52463
18530	20071	114	TFLH	52464
18531	20071	8	TFX3	54561
18532	20071	6	TFRU	54562
18533	20071	19	TFV1	54567
18534	20071	7	MWVWXY	54583
18535	20071	27	WRU2	54585
18536	20071	21	MH	54594
18537	20071	55	MHU1	15574
18538	20071	17	TFU	54566
18539	20071	16	MHV1	54569
18540	20071	20	W2	54571
18541	20071	27	WRU1	54579
18542	20071	21	MQ	54593
18543	20071	112	TFW	70005
18544	20071	119	TFW	39298
18545	20071	109	MHQ	39388
18546	20071	6	TMRU	54563
18547	20071	8	TFX2	54560
18548	20071	17	MHU	54565
18549	20071	19	TFV2	54568
18550	20071	50	MHV1	15526
18551	20071	107	MTHFW2	39228
18552	20071	110	MTHFX	41361
18553	20071	3	TFRU	54576
18554	20071	108	MTHFU2	39237
18555	20071	110	MTHFQ1	41359
18556	20071	93	MHY2	46327
18557	20071	102	TFY	47991
18558	20071	3	MHVW	54574
18559	20071	71	TFU	38606
18560	20071	108	MTHFX	39248
18561	20071	93	TFV1	46370
18562	20071	104	MHV	47978
18563	20071	3	MHRU	54573
18564	20071	128	TFW	15019
18565	20071	108	MTHFU3	39243
18566	20071	104	TFR-1	44162
18567	20071	107	MTHFR2	39410
18568	20071	110	MTHFV	41360
18569	20071	93	TFU2	46331
18570	20071	1	HMXY	54552
18571	20071	73	MHR	38055
18572	20071	108	MTHFU7	39239
18573	20071	110	MTHFI	41357
18574	20071	1	FTXY	54555
18575	20071	63	TFR1	15635
18576	20071	71	TFW	38833
18577	20071	108	MTHFX3	39396
18578	20071	110	MTHFD	41356
18579	20071	71	TFR	38605
18580	20071	108	MTHFW1	39235
18581	20071	74	TFU	52910
18582	20071	43	TFU1	14447
18583	20071	106	MTHFX2	39212
18584	20071	76	TFY	40809
18585	20071	1	HMRU1	54550
18586	20071	43	TFX	14453
18587	20071	70	MHR	37500
18588	20071	106	MTHFW11	39187
18589	20071	100	MHU	42540
18590	20071	1	FTRU	54553
18591	20071	43	TFV	14449
18592	20071	106	MTHFX-6	39342
18593	20071	94	TFR4	45781
18594	20071	1	HMVW	54551
18595	20071	43	TFU2	14448
18596	20071	70	TFV	37508
18597	20071	100	MHR	42539
18598	20071	42	MHW	14433
18599	20071	106	MTHFR3	39218
18600	20071	94	MHU3	45758
18601	20071	74	TFV	52911
18602	20071	82	MHU	41900
18603	20071	93	TFW1	46332
18604	20072	115	MHLW2	52451
18605	20072	129	MHR	40251
18606	20072	115	MHLF	52452
18607	20072	11	MHZ	54570
18608	20072	12	HMVW	54577
18609	20072	28	MHU	54585
18610	20072	23	SRU	54606
18611	20072	36	TFY-1	13875
18612	20072	123	TFW	14462
18613	20072	70	MHW	37503
18614	20072	130	TFV	43031
18615	20072	102	TFX	47972
18616	20072	131	GTH	52932
18617	20072	22	W2	54581
18618	20072	82	TFU	42004
18619	20072	93	TFV5	46332
18620	20072	115	MHLW1	52450
18621	20072	11	MHX2	54569
18622	20072	12	MHVW	54578
18623	20072	23	TFW	54584
18624	20072	14	MHQR2	54609
18625	20072	66	MHX1	26506
18626	20072	130	TFW	43032
18627	20072	115	MHLT	52449
18628	20072	9	MHSUWX	54602
18629	20072	43	MHV3	14437
18630	20072	108	MTHFX	39197
18631	20072	110	MTHFW	41355
18632	20072	5	TFU2	54566
18633	20072	75	MHR	55102
18634	20072	109	TFW1	39211
18635	20072	119	TFY	39260
18636	20072	111	MTHFQ	41357
18637	20072	81	MHR	42009
18638	20072	98	MHX2	42460
18639	20072	70	MHX	37504
18640	20072	109	TFW2	39233
18641	20072	111	MTHFCR	41358
18642	20072	5	TFU	54564
18643	20072	89	MHW	62802
18644	20072	36	TFX-2	13872
18645	20072	109	MHW1	39294
18646	20072	111	MTHFGV	41360
18647	20072	95	MHX1	45814
18648	20072	5	MHU	54563
18649	20072	36	TFR-1	13864
18650	20072	70	TFU	37507
18651	20072	108	MTHFQ	39207
18652	20072	2	MHRU	54556
18653	20072	39	MHU4	16065
18654	20072	109	MHV	39206
18655	20072	119	TFX	39259
18656	20072	111	MTHFW	41361
18657	20072	74	MHX	52911
18658	20072	1	FTRU	54550
18659	20072	45	TFU	14470
18660	20072	109	MHR	39202
18661	20072	123	TFV	14459
18662	20072	119	TFX1	39383
18663	20072	63	MHR	15608
18664	20072	107	MTHFW4	39183
18665	20072	81	TFX	42012
18666	20072	105	MHV	43552
18667	20072	2	TFRU	54559
18668	20072	123	MHU2	14453
18669	20072	107	MTHFW6	39189
18670	20072	93	MHR4	46307
18671	20072	123	MHU	14451
18672	20072	37	TFQ-2	13887
18673	20072	106	MTHFX	39200
18674	20072	98	MHW2	42458
18675	20072	2	TFVW	54560
18676	20072	123	MHR	14450
18677	20072	107	MTHFW2	39171
18678	20072	98	MHU2	42452
18679	20072	40	MHR	14471
18680	20072	107	MTHFW3	39177
18681	20072	83	MHX	41425
18682	20072	103	MHU1	44677
18683	20072	2	TFXY	54561
18684	20072	39	TFX2	16133
18685	20072	107	MTHFV4	39182
18686	20072	98	MHX1	42459
18687	20072	40	TFW	14481
18688	20072	55	MHU	15575
18689	20072	107	MTHFR	39155
18690	20072	95	TFX1	45831
18691	20072	2	MHVW	54557
18692	20072	50	TFR1	15529
18693	20072	55	MHQ	15573
18694	20072	94	TFX1	45796
18695	20072	55	MHV1	15577
18696	20072	107	MTHFR4	39180
18697	20072	81	TFW	42011
18698	20072	100	MHW	42481
18699	20073	44	MTWHFBC	11651
18700	20073	18	X2	54550
18701	20073	127	X2-A	15518
18702	20073	111	MTWHFJ	41354
18703	20073	109	X1-1	39164
18704	20073	109	X3-1	39167
18705	20073	37	X3-A	13862
18706	20073	71	X5	38604
18707	20073	109	X3-2	39206
18708	20073	111	MTWHFQ	41352
18709	20073	107	Z1-4	39180
18710	20073	98	X2-1	42450
18711	20073	107	Z3-1	39186
18712	20073	107	Z1-6	39182
18713	20073	107	Z1-5	39181
18714	20081	132	THV-2	44102
18715	20081	17	THU	54562
18716	20081	6	FWRU	54571
18717	20081	16	WFV2	54578
18718	20081	20	MS2	54584
18719	20081	75	WFW	55101
18720	20081	100	THR1	42483
18721	20081	133	THW	52938
18722	20081	8	WFW	54568
18723	20081	21	MU	54580
18724	20081	20	MS3	54585
18725	20081	23	THV	54609
18726	20081	112	WFR	69950
18727	20081	47	W	19916
18728	20081	134	THX	43031
18729	20081	16	WFV	54577
18730	20081	20	MS4	54586
18731	20081	29	THW3	54602
18732	20081	108	TWHFR	39212
18733	20081	97	THY	43057
18734	20081	114	THQF2	52451
18735	20081	6	FWVW	54572
18736	20081	91	THD/HJ2	67252
18737	20081	70	THY	37505
18738	20081	114	THQW2	52450
18739	20081	7	THVW	54574
18740	20081	8	SUV	54599
18741	20081	62	THW3	15694
18742	20081	109	THV	39301
18743	20081	114	THQF1	52449
18744	20081	6	THRU	54573
18745	20081	112	WFV	69957
18746	20081	114	THQW1	52448
18747	20081	19	THW	54565
18748	20081	23	WFU	54610
18749	20081	108	TWHFU1	39219
18750	20081	111	TWHFGV	41386
18751	20081	99	THW2	42474
18752	20081	2	FWXY	54556
18753	20081	45	THR2	14480
18754	20081	135	THU	15105
18755	20081	19	THW2	54566
18756	20081	111	TWHFQ	41383
18757	20081	7	THXY2	54576
18758	20081	136	THV	13927
18759	20081	66	THU2	26503
18760	20081	108	TWHFX	39226
18761	20081	119	WFV	39347
18762	20081	110	TWHFW	41382
18763	20081	3	WFRU	54561
18764	20081	48	W	19919
18765	20081	71	WFX	38601
18766	20081	107	TWHFW	39209
18767	20081	1	THXY2	54551
18768	20081	89	A	62800
18769	20081	108	TWHFV1	39221
18770	20081	98	WFY2	42471
18771	20081	95	THQ2	45799
18772	20081	36	WFR-4	13872
18773	20081	103	THR-4	44662
18774	20081	3	THXY	54558
18775	20081	40	THY	14496
18776	20081	62	THU2	15618
18777	20081	93	THX1	46320
18778	20081	39	THX4	16137
18779	20081	108	TWHFW2	39229
18780	20081	110	TWHFQ	41378
18781	20081	36	THR-1	13851
18782	20081	91	WFB/WC	67292
18783	20081	49	WFX1	15543
18784	20081	127	THX2	15575
18785	20081	37	THU-1	13881
18786	20081	137	THR	15043
18787	20081	108	TWHFV	39217
18788	20081	39	WFV1	16136
18789	20081	108	TWHFW1	39225
18790	20081	100	THR2	42484
18791	20081	108	TWHFR4	39216
18792	20081	3	WFXY	54559
18793	20081	75	THW	55100
18794	20081	39	WFW2	16113
18795	20081	108	TWHFR2	39214
18796	20081	110	TWHFU	41380
18797	20081	95	THW1	45808
18798	20081	43	WFR1	14463
18799	20081	70	WFU	37507
18800	20081	106	TWHFW2	39167
18801	20081	100	WFX1	42494
18802	20081	1	HTRU	54554
18803	20081	37	THV-1	13882
18804	20081	106	TWHFR7	39277
18805	20081	76	WFU-1	40811
18806	20081	104	THU	44165
18807	20081	40	THU	14489
18808	20081	106	TWHFQ4	39174
18809	20081	95	THR1	45800
18810	20081	1	THXY	54550
18811	20081	43	THV2	14459
18812	20081	106	TWHFU3	39158
18813	20081	82	WFR	42007
18814	20081	94	THX2	45768
18815	20081	1	WFXY2	54553
18816	20081	43	WFX	14467
18817	20081	70	THU	37501
18818	20081	106	TWHFR9	39279
18819	20081	99	WFY	42478
18820	20081	40	WFX1	14501
18821	20081	106	TWHFW3	39168
18822	20081	84	THU	42004
18823	20081	93	WFU3	46330
18824	20081	45	THU	14481
18825	20081	100	THW	42485
18826	20081	43	WFR2	14464
18827	20081	41	WFW2	14434
18828	20081	93	THV3	46313
18829	20081	74	THX	52900
18830	20081	41	THX2	14418
18831	20081	106	TWHFV7	39258
18832	20081	76	THY	40808
18833	20081	94	WFR2	45776
18834	20081	1	WFXY	54552
18835	20081	41	THW2	14413
18836	20081	82	WFW	42008
18837	20081	94	THQ1	45750
18838	20081	41	WFU2	14427
18839	20081	81	WFR	42001
18840	20081	94	WFX1	45791
18841	20081	1	HTQR	54555
18842	20081	41	THR1	14402
18843	20081	106	TWHFW8	39270
18844	20081	94	THU5	45761
18845	20081	42	THW	14446
18846	20081	106	TWHFR2	39152
18847	20081	82	THU	42009
18848	20081	93	WFU1	46328
18849	20081	123	WFV	14477
18850	20081	82	THW	42010
18851	20081	41	WFX2	14438
18852	20081	70	THR	37500
18853	20081	106	TWHFQ	39170
18854	20081	94	THU3	45759
18855	20081	43	WFY	14468
18856	20081	106	TWHFW7	39260
18857	20081	83	WFU	41375
18858	20081	98	THR2	42451
18859	20081	39	THU3	16133
18860	20081	106	TWHFW6	39259
18861	20081	81	WFX	42003
18862	20081	93	THR3	46305
18863	20081	41	WFW4	14436
18864	20081	106	TWHFQ5	39280
18865	20081	41	THR2	14403
18866	20081	100	WFW	42493
18867	20081	42	THV1	14444
18868	20081	106	TWHFR3	39153
18869	20081	39	THY2	16078
18870	20081	43	THQ	14455
18871	20081	138	WFV	40824
18872	20081	105	WFQ1	43583
18873	20081	123	THX	14469
18874	20081	79	THV1	39703
18875	20081	50	WFU3	15547
18876	20081	55	THR2	15664
18877	20081	106	TWHFX2	39187
18878	20081	93	THV6	46345
18879	20081	1	MUVWX	54597
18880	20081	43	THW3	14600
18881	20081	41	WFX5	14607
18882	20081	106	TWHFU2	39157
18883	20081	94	THX3	45769
18884	20081	37	WFY-2	13931
18885	20081	50	THV1	15528
18886	20081	93	THY4	46325
18887	20082	123	THX	14474
18888	20082	40	THW1	14505
18889	20082	119	THR	39281
18890	20082	111	S3L/R4	41472
18891	20082	89	WFA	62804
18892	20082	45	WFV	14496
18893	20082	138	WFW	40816
18894	20082	14	THRU	54566
18895	20082	9	THVW	54570
18896	20082	22	S2	54581
18897	20082	131	GM	56235
18898	20082	113	WFU2	15707
18899	20082	74	THW	52917
18900	20082	11	WFV	54565
18901	20082	21	HV	54579
18902	20082	22	S1	54580
18903	20082	60	MR2A	33109
18904	20082	84	THW	42007
18905	20082	139	THWFY	43021
18906	20082	140	THWFY	43022
18907	20082	22	S4	54583
18908	20082	89	THK	62800
18909	20082	109	WFU2	39310
18910	20082	5	THU2	54561
18911	20082	14	THVW	54567
18912	20082	141	WFIJ	67206
18913	20082	123	THQ1	14536
18914	20082	115	WFLT	52430
18915	20082	11	WFW	54562
18916	20082	9	THYZ	54571
18917	20082	12	WFUV	54575
18918	20082	135	WFU2	15154
18919	20082	94	THV4	45765
18920	20082	14	THXY	54568
18921	20082	40	THV1	14503
18922	20082	81	THR	42008
18923	20082	115	WFLW	52431
18924	20082	5	THU	54559
18925	20082	11	WFX	54563
18926	20082	14	WFVW	54569
18927	20082	41	THV2	14406
18928	20082	123	WFV1	14480
18929	20082	119	THU	39233
18930	20082	109	WFU5	39321
18931	20082	81	WFW	42010
18932	20082	3	HTQR	54609
18933	20082	115	WFLF	52433
18934	20082	39	WFU4	16078
18935	20082	12	WFWX	54576
18936	20082	30	SWX	54588
18937	20082	112	TBA	70009
18938	20082	5	WFU	54560
18939	20082	89	WFV	62829
18940	20082	42	THU1	14429
18941	20082	109	THR1	39274
18942	20082	111	S4L/R1	41386
18943	20082	100	THW2	42475
18944	20082	75	WFW	55100
18945	20082	43	THV1	14450
18946	20082	108	TWHFU1	39213
18947	20082	110	S2L/R4	41439
18948	20082	94	THW3	45768
18949	20082	2	WFXY	54555
18950	20082	111	S5L/R5	41481
18951	20082	82	THY	42003
18952	20082	94	THV2	45763
18953	20082	119	THV	39271
18954	20082	95	THX3	45817
18955	20082	48	X	19904
18956	20082	108	TWHFW	39211
18957	20082	111	S2L/R4	41468
18958	20082	87	THY	47957
18959	20082	35	THX1	15506
18960	20082	109	THW1	39221
18961	20082	111	S1L/R5	41465
18962	20082	103	WFR-2	44731
18963	20082	5	WFU2	54618
18964	20082	37	THR-3	13884
18965	20082	119	THQ	39280
18966	20082	110	S5L/R1	41392
18967	20082	94	THX3	45771
18968	20082	123	WFX	14484
18969	20082	111	S1L/R1	41383
18970	20082	24	THR	54585
18971	20082	109	WFR2	39309
18972	20082	111	S5L/R1	41387
18973	20082	95	WFV2	45826
18974	20082	123	WFV3	14482
18975	20082	108	TWHFR	39212
18976	20082	45	WFQ	14491
18977	20082	109	THQ1	39378
18978	20082	111	S5L/R3	41479
18979	20082	93	WFU2	46319
18980	20082	36	THV-2	13859
18981	20082	107	TWHFU7	39326
18982	20082	98	THR3	42452
18983	20082	103	WFR-4	44733
18984	20082	1	FWVW	54614
18985	20082	73	WFW-1	38078
18986	20082	111	S4L/R3	41475
18987	20082	89	TNQ	62803
18988	20082	41	WFR	14415
18989	20082	49	THR1	15522
18990	20082	107	TWHFW2	39169
18991	20082	94	WFU1	45782
18992	20082	1	HTXY	54550
18993	20082	39	WFV3	16081
18994	20082	107	TWHFQ4	39268
18995	20082	81	WFX	42011
18996	20082	98	WFU2	42464
18997	20082	2	HTVW	54552
18998	20082	142	WFV	14556
18999	20082	107	TWHFQ1	39158
19000	20082	82	THU	42000
19001	20082	100	THR2	42472
19002	20082	2	WFRU	54554
19003	20082	39	THQ1	16050
19004	20082	107	TWHFU3	39173
19005	20082	100	WFQ2	42477
19006	20082	42	THY	14435
19007	20082	73	WFV	38059
19008	20082	107	TWHFQ5	39345
19009	20082	94	WFX1	45795
19010	20082	41	THX2	14411
19011	20082	123	WFR	14477
19012	20082	98	WFU1	42463
19013	20082	2	THRU	54556
19014	20082	61	THW1	15620
19015	20082	107	TWHFV3	39174
19016	20082	76	WFU	40850
19017	20082	2	HTXY	54557
19018	20082	41	WFU	14416
19019	20082	107	TWHFW	39155
19020	20082	81	WFR	42009
19021	20082	93	WFX	46327
19022	20082	36	WFU-1	13867
19023	20082	93	WFV2	46321
19024	20082	143	WFR/WFRUV2	38632
19025	20082	104	MUV	44132
19026	20082	94	THU2	45758
19027	20082	75	WFX	55101
19028	20082	42	THW2	14433
19029	20082	100	WFR2	42479
19030	20082	123	THR	14537
19031	20082	106	TWHFQ1	39232
19032	20082	70	THU	37501
19033	20082	107	TWHFR4	39177
19034	20082	100	WFW	42481
19035	20082	40	WFX1	14513
19036	20082	76	THX	40804
19037	20082	55	WFR1	15580
19038	20082	71	THX	38600
19039	20082	107	TWHFU6	39325
19040	20082	103	WFV-2	44736
19041	20082	39	WFU2	16076
19042	20082	107	TWHFW4	39179
19043	20082	2	THXY	54553
19044	20082	123	WFW	14483
19045	20082	107	TWHFQ3	39171
19046	20082	80	THU	40251
19047	20082	41	THV3	14407
19048	20082	98	WFV2	42466
19049	20082	93	THU1	46303
19050	20082	43	WFR	14457
19051	20082	107	TWHFU5	39181
19052	20082	93	THQ1	46322
19053	20082	123	THR1	14465
19054	20082	70	WFU	37507
19055	20082	100	WFX	42482
19056	20082	105	THV	43563
19057	20082	40	THU2	14515
19058	20082	106	TWHFX	39186
19059	20082	82	WFV	42004
19060	20082	37	WFR-2	13894
19061	20082	100	WFU	42480
19062	20082	42	WFX1	14443
19063	20082	107	TWHFU2	39167
19064	20082	98	WFR1	42461
19065	20082	107	TWHFR3	39172
19066	20082	42	THR1	14427
19067	20082	100	WFR1	42478
19068	20082	39	WFU3	16077
19069	20082	107	TWHFR2	39166
19070	20082	94	WFW1	45791
19071	20082	123	THU	14466
19072	20082	107	TWHFR	39152
19073	20082	76	WFW	40808
19074	20082	41	THW	14408
19075	20082	104	THX	44130
19076	20082	41	WFV	14417
19077	20082	43	WFU	14459
19078	20082	105	THY	43554
19079	20082	62	THX1	15624
19080	20082	71	WFX	38601
19081	20082	107	TWHFW3	39175
19082	20082	105	WFR	43552
19083	20082	94	THR4	45755
19084	20082	100	WFQ1	42476
19085	20082	93	WFV1	46320
19086	20082	36	WFX-2	13879
19087	20082	106	TWHFU	39372
19088	20082	94	THX1	45769
19089	20082	95	THW2	45813
19090	20083	70	X2	37500
19091	20083	113	X4-A	15534
19092	20083	70	X5	37503
19093	20083	71	X2	38601
19094	20083	43	X5	14420
19095	20083	105	X-3C	43554
19096	20083	98	X5-1	42456
19097	20083	130	X2-1	43011
19098	20083	133	X4	52901
19099	20083	70	X4	37502
19100	20083	109	X3	39181
19101	20083	111	MTWHFJ	41366
19102	20083	109	X2	39180
19103	20083	108	Z2-6	39201
19104	20083	108	Z1-6	39197
19105	20083	109	X4	39206
19106	20083	40	X2	14432
19107	20083	109	X4-1	39210
19108	20083	111	MTWHFQ	41364
19109	20083	108	Z2-2	39175
19110	20083	107	Z1-3	39164
19111	20083	37	X4	13861
19112	20083	93	X3-2	46302
19113	20083	110	MTWHFE	41362
19114	20083	108	Z3-5	39204
19115	20083	107	Z2	39165
19116	20083	71	X3	38602
19117	20083	93	X5-1	46305
19118	20083	108	Z3-2	39178
19119	20083	110	MTWHFJ	41363
19120	20083	108	Z1-1	39170
19121	20083	36	X5	13859
19122	20083	130	X1	43000
19123	20083	107	Z1	39161
19124	20083	95	X2	45753
19125	20083	43	X3-B	14419
19126	20083	107	Z3	39168
19127	20083	108	Z3	39176
19128	20083	108	Z3-1	39177
19129	20083	107	Z2-1	39166
19130	20083	108	Z2-4	39199
19131	20091	24	THX	54565
19132	20091	8	WFV	54575
19133	20091	6	THVW	54580
19134	20091	7	FWXY	54583
19135	20091	112	WFW	69988
19136	20091	143	WFQ/WFUV1	38617
19137	20091	63	WFW1	15604
19138	20091	132	THU1	44103
19139	20091	17	THV	54567
19140	20091	19	THW	54571
19141	20091	16	WFX	54587
19142	20091	20	S6	54625
19143	20091	144	TWHFX	43036
19144	20091	145	TWHFX	43037
19145	20091	71	THW	38717
19146	20091	114	THQ	52479
19147	20091	114	THQS2	52483
19148	20091	7	THXY	54585
19149	20091	21	MR	54589
19150	20091	112	WFY	69990
19151	20091	17	THU	54568
19152	20091	19	THX	54572
19153	20091	23	MXY	54592
19154	20091	20	S7	54629
19155	20091	146	THX	53508
19156	20091	17	WFU	54569
19157	20091	19	THR	54570
19158	20091	7	HTVW	54582
19159	20091	16	WFV	54586
19160	20091	37	WFU-1	13892
19161	20091	133	THU	52904
19162	20091	23	WFX	54591
19163	20091	45	WFV1	14606
19164	20091	147	TWHFR	43056
19165	20091	148	TWHFR	43057
19166	20091	2	THVW	54559
19167	20091	19	WFU	54573
19168	20091	43	THW1	14544
19169	20091	40	WFX3	14637
19170	20091	114	THQT	52480
19171	20091	5	WFR	54564
19172	20091	6	FWVW	54579
19173	20091	149	THR	14968
19174	20091	111	S3L/R3	41398
19175	20091	150	WFV	43061
19176	20091	114	THQS1	52482
19177	20091	17	THW	54566
19178	20091	8	THV	54574
19179	20091	98	WFR2	42458
19180	20091	6	THXY	54581
19181	20091	112	WFX	69989
19182	20091	73	THW	38071
19183	20091	109	WFR	39303
19184	20091	119	WFY	39310
19185	20091	3	WFVW	54562
19186	20091	73	WFU	38063
19187	20091	114	THQH	52481
19188	20091	1	HTXY	54552
19189	20091	75	WFV	55104
19190	20091	87	THU	47951
19191	20091	8	SWX	54577
19192	20091	88	WFX	62814
19193	20091	57	WFU1	15575
19194	20091	111	S4L/R2	41402
19195	20091	6	HTXY	54578
19196	20091	7	WFWX	54584
19197	20091	93	THW2	46362
19198	20091	75	WFW	55100
19199	20091	109	WFQ	39302
19200	20091	111	S5L/R3	41408
19201	20091	3	THRU	54560
19202	20091	8	THY	54576
19203	20091	111	S1L/R5	41390
19204	20091	88	THV	62807
19205	20091	50	WFU1	15533
19206	20091	39	THU1	16075
19207	20091	151	WFX	39266
19208	20091	123	THQ	14562
19209	20091	50	THU3	15523
19210	20091	109	WFV	39297
19211	20091	110	S2L/R3	41358
19212	20091	43	WFW2	14556
19213	20091	35	THQ1	15500
19214	20091	57	THR1	15574
19215	20091	107	TWHFV	39388
19216	20091	110	S6L/R2	41381
19217	20091	1	WFRU2	54616
19218	20091	123	THU2	14565
19219	20091	39	THV3	16119
19220	20091	107	TWHFY	39272
19221	20091	110	S5L/R1	41374
19222	20091	63	WFR1	15601
19223	20091	108	TWHFU3	39278
19224	20091	110	S1L/R4	41353
19225	20091	123	THV3	14568
19226	20091	108	TWHFR4	39339
19227	20091	110	S3L/R1	41362
19228	20091	100	THW	42471
19229	20091	43	THW2	14545
19230	20091	108	TWHFQ2	39371
19231	20091	110	S6L/R6	41385
19232	20091	95	THV3	45805
19233	20091	123	THV2	14567
19234	20091	108	TWHFQ3	39372
19235	20091	81	WFR	42001
19236	20091	3	WFXY	54563
19237	20091	43	THR1	14635
19238	20091	35	WFQ1	15504
19239	20091	110	S6L/R4	41383
19240	20091	41	THX5	14502
19241	20091	108	TWHFR1	39277
19242	20091	110	S3L/R4	41365
19243	20091	97	THV	43059
19244	20091	108	TWHFR	39275
19245	20091	110	S3L/R3	41364
19246	20091	98	WFX	42525
19247	20091	3	THXY	54561
19248	20091	63	THR1	15594
19249	20091	107	TWHFX	39271
19250	20091	111	S3L/R2	41397
19251	20091	43	THQ	14539
19252	20091	108	TWHFU	39273
19253	20091	110	S2L/R4	41359
19254	20091	99	THV	42461
19255	20091	127	THY1	15552
19256	20091	110	S6L/R5	41384
19257	20091	2	THRU	54628
19258	20091	127	WFR1	15554
19259	20091	93	THV3	46307
19260	20091	50	THV2	15558
19261	20091	110	S1L/R5	41354
19262	20091	36	WFV-3	13865
19263	20091	108	TWHFQ1	39338
19264	20091	110	S5L/R6	41379
19265	20091	93	WFX2	46357
19266	20091	108	TWHFU2	39276
19267	20091	110	S4L/R1	41368
19268	20091	81	WFX	42003
19269	20091	94	WFY3	45798
19270	20091	41	THX6	14638
19271	20091	50	WFV2	15536
19272	20091	109	WFW	39298
19273	20091	93	THU4	46305
19274	20091	64	THQ1	15666
19275	20091	50	WFV1	15535
19276	20091	57	WFX1	15577
19277	20091	110	S3L/R5	41366
19278	20091	43	WFW4	14558
19279	20091	108	TWHFR5	39340
19280	20091	95	THW1	45806
19281	20091	62	THR1	15665
19282	20091	70	THY	37505
19283	20091	108	TWHFU4	39287
19284	20091	36	WFY-1	13878
19285	20091	107	TWHFR1	39383
19286	20091	110	S6L/R3	41382
19287	20091	99	WFU	42463
19288	20091	95	WFR1	45813
19289	20091	152	NONE	20509
19290	20091	110	S4L/R4	41371
19291	20091	97	WFU	43001
19292	20091	127	THV2	15561
19293	20091	108	TWHFQ	39285
19294	20091	111	S2L/R1	41391
19295	20091	89	WFX	62805
19296	20091	37	WFW-1	13896
19297	20091	63	THV1	15596
19298	20091	108	TWHFR6	39347
19299	20091	108	TWHFR2	39284
19300	20091	94	WFX2	45793
19301	20091	65	THV1	15616
19302	20091	107	TWHFR	39270
19303	20091	110	S5L/R4	41377
19304	20091	134	THU	43031
19305	20091	37	THW-1	13883
19306	20091	95	WFW1	45820
19307	20091	37	WFY-1	13898
19308	20091	39	THW1	16091
19309	20091	110	S3L/R2	41363
19310	20091	36	WFW-4	13864
19311	20091	57	WFV1	15576
19312	20091	94	THV4	45763
19313	20091	39	THV1	16090
19314	20091	109	THX	39300
19315	20091	23	WFY	54550
19316	20091	36	WFR-2	13868
19317	20091	110	S4L/R3	41370
19318	20091	95	THW2	45807
19319	20091	36	THU-3	13938
19320	20091	109	WFU	39385
19321	20091	110	S5L/R5	41378
19322	20091	74	THV	52915
19323	20091	62	WFR1	15668
19324	20091	107	TWHFU	39378
19325	20091	36	WFX-4	13939
19326	20091	50	THW1	15525
19327	20091	111	S1L/R3	41388
19328	20091	50	THX3	15638
19329	20091	109	THY	39296
19330	20091	95	WFY1	45824
19331	20091	36	THV-1	13856
19332	20091	123	THW	14571
19333	20091	39	THX2	16082
19334	20091	110	S2L/R1	41356
19335	20091	108	TWHFU1	39274
19336	20091	110	S2L/R5	41360
19337	20091	87	THQ1	47992
19338	20091	89	THZ	62833
19339	20091	81	WFW	42002
19340	20091	43	THX2	14547
19341	20091	106	TWHFW5	39209
19342	20091	94	WFQ2	45774
19343	20091	1	HTRU	54554
19344	20091	41	THX2	14499
19345	20091	83	WFU	41502
19346	20091	43	THR	14540
19347	20091	70	THU	37501
19348	20091	106	TWHFW4	39174
19349	20091	100	WFX	42475
19350	20091	1	FWRU	54553
19351	20091	41	THV2	14490
19352	20091	106	TWHFQ1	39151
19353	20091	82	THU	42006
19354	20091	1	WFRU	54557
19355	20091	41	WFV2	14513
19356	20091	106	TWHFU3	39163
19357	20091	83	WFW	41503
19358	20091	100	THR2	42469
19359	20091	1	HTVW	54551
19360	20091	41	WFX2	14521
19361	20091	106	TWHFW7	39248
19362	20091	81	THR	42000
19363	20091	93	THU2	46303
19364	20091	41	WFX1	14520
19365	20091	106	TWHFU2	39162
19366	20091	94	THW1	45765
19367	20091	1	FWVW	54555
19368	20091	106	TWHFQ3	39153
19369	20091	82	WFW	42005
19370	20091	100	THR1	42468
19371	20091	42	THW	14530
19372	20091	106	TWHFV2	39167
19373	20091	82	THR	42004
19374	20091	93	WFR2	46317
19375	20091	1	FWXY	54556
19376	20091	70	THR	37500
19377	20091	99	THW	42462
19378	20091	41	WFX3	14522
19379	20091	70	WFW	37509
19380	20091	93	THR	46369
19381	20091	40	THX1	14585
19382	20091	87	WFR	47957
19383	20091	39	THR2	16099
19384	20091	70	WFV	37508
19385	20091	88	WFR	62809
19386	20091	106	TWHFQ5	39249
19387	20091	83	WFX	41504
19388	20091	100	WFR	42473
19389	20091	43	THV	14543
19390	20091	106	TWHFU1	39161
19391	20091	94	WFW2	45790
19392	20091	40	WFX1	14594
19393	20091	106	TWHFV4	39169
19394	20091	76	WFU1	40810
19395	20091	91	WFB/WI2	67207
19396	20091	39	THX3	16054
19397	20091	94	WFX4	45795
19398	20091	42	THY	14531
19399	20091	106	TWHFV6	39242
19400	20091	94	WFX1	45792
19401	20091	40	WFY	14596
19402	20091	100	WFQ1	42472
19403	20091	123	WFW	14578
19404	20091	100	THR3	42515
19405	20091	39	WFV2	16114
19406	20091	100	WFW	42474
19407	20091	93	THV1	46306
19408	20091	123	WFV3	14577
19409	20091	76	WFX	40811
19410	20091	94	WFQ3	45775
19411	20091	40	THX2	14586
19412	20091	93	WFY1	46331
19413	20091	43	WFW1	14555
19414	20091	93	WFY2	46320
19415	20091	41	THU4	14488
19416	20091	106	TWHFW6	39243
19417	20091	94	THQ1	45750
19418	20091	153	WFU	39192
19419	20091	105	WFV1	43584
19420	20091	44	WFY	11656
19421	20091	40	THY	14588
19422	20091	41	THQ	14483
19423	20091	106	TWHFX7	39254
19424	20091	104	THV1	45853
19425	20091	94	THX2	45769
19426	20091	41	THW5	14497
19427	20091	106	TWHFQ	39150
19428	20091	39	THQ1	16098
19429	20091	93	THX3	46314
19430	20091	40	WFV2	14592
19431	20091	100	WFQ2	42522
19432	20091	60	MR2B	33108
19433	20091	70	WFU	37507
19434	20091	102	THX	44146
19435	20091	41	THX3	14500
19436	20091	94	WFX3	45794
19437	20091	42	WFY1	14536
19438	20091	93	WFU1	46319
19439	20091	106	TWHFY1	39180
19440	20091	94	THU1	45756
19441	20091	42	WFY2	14537
19442	20091	42	THR	14525
19443	20091	106	TWHFX6	39244
19444	20091	98	WFV	42460
19445	20091	76	THX1	40806
19446	20091	88	WFU	62810
19447	20091	123	THR	14563
19448	20091	99	WFV	42464
19449	20091	94	WFV4	45788
19450	20091	106	TWHFY2	39203
19451	20091	43	WFX2	14560
19452	20091	70	WFR	37506
19453	20091	100	THQ1	42466
19454	20091	94	WFV3	45787
19455	20091	123	THU3	14611
19456	20091	106	TWHFY3	39204
19457	20092	154	THY	39298
19458	20092	118	THW	39332
19459	20092	11	WFV	54554
19460	20092	9	WFRU	54591
19461	20092	19	WFW	54631
19462	20092	23	MWX	54637
19463	20092	113	THY1	15663
19464	20092	39	WFU2	16144
19465	20092	155	THW	40256
19466	20092	84	WFV	42006
19467	20092	115	THX	52450
19468	20092	115	THXH	52453
19469	20092	9	WFXY	54566
19470	20092	22	SCVMIG	54602
19471	20092	81	WFW	42002
19472	20092	12	THVW	54575
19473	20092	27	MBD	54625
19474	20092	156	WFQ	15001
19475	20092	50	THU1	15531
19476	20092	115	THXW	52452
19477	20092	131	WFW	56273
19478	20092	39	THV	16073
19479	20092	59	MR11A	33100
19480	20092	74	THW	54000
19481	20092	12	FWVW	54572
19482	20092	157	THX	55673
19483	20092	94	THU1	45755
19484	20092	24	THW	54567
19485	20092	11	WFU	54578
19486	20092	35	THR1	15502
19487	20092	3	THVW	54551
19488	20092	11	WFW	54555
19489	20092	23	WFX	54573
19490	20092	5	WFU	54589
19491	20092	29	THQ	54628
19492	20092	137	THX	15026
19493	20092	14	WFVW	54560
19494	20092	11	WFR	54577
19495	20092	75	THY	55115
19496	20092	41	THY1	14408
19497	20092	113	WFV1	15650
19498	20092	79	THV2	39704
19499	20092	83	THU	41483
19500	20092	21	HR	54570
19501	20092	23	THY	54571
19502	20092	22	MACL	54600
19503	20092	43	THV1	14441
19504	20092	115	THXF	52454
19505	20092	123	THR1	14470
19506	20092	45	SDEF	14501
19507	20092	109	THW	39239
19508	20092	81	WFX	42003
19509	20092	23	WFY1	54638
19510	20092	42	WFX	14435
19511	20092	45	THV	14492
19512	20092	158	THW	16135
19513	20092	2	THRU	54579
19514	20092	37	WFW-2	13928
19515	20092	12	HTVW	54563
19516	20092	9	HTRU	54568
19517	20092	42	THV1	14615
19518	20092	94	THX1	45765
19519	20092	14	WFXY	54561
19520	20092	23	MVW	54634
19521	20092	47	Y	19902
19522	20092	109	THW1	39343
19523	20092	111	S3L/R1	41398
19524	20092	94	THV2	45760
19525	20092	26	THX	54569
19526	20092	125	THY	15057
19527	20092	159	WFW	16126
19528	20092	5	THX	54587
19529	20092	23	WFENTREP	54635
19530	20092	91	WFB/WK2	67256
19531	20092	109	THV1	39245
19532	20092	111	S1L/R5	41392
19533	20092	135	THW	14956
19534	20092	97	WFX	43062
19535	20092	93	THQ2	46301
19536	20092	102	THX	44162
19537	20092	14	WFRU	54559
19538	20092	81	THR	42000
19539	20092	14	THXY	54562
19540	20092	98	THY1	42456
19541	20092	35	WFV1	15508
19542	20092	119	WFX	39214
19543	20092	109	WFU2	39334
19544	20092	45	WFU	14495
19545	20092	115	THXT	52451
19546	20092	9	WFVW	54592
19547	20092	43	WFQ	14452
19548	20092	107	TWHFV6	39335
19549	20092	103	THR-1	44670
19550	20092	2	HTXY	54586
19551	20092	108	TWHFX	39230
19552	20092	111	S5L/R2	41409
19553	20092	97	WFR	43002
19554	20092	93	WFV3	46327
19555	20092	109	THU1	39333
19556	20092	111	S2L/R4	41396
19557	20092	23	WFY	54633
19558	20092	36	WFU-3	13878
19559	20092	111	S1L/R4	41389
19560	20092	100	THR1	42472
19561	20092	93	THY1	46319
19562	20092	2	HTVW	54580
19563	20092	50	WFW1	15543
19564	20092	111	S2L/R1	41393
19565	20092	94	THV1	45759
19566	20092	55	WFW1	15573
19567	20092	70	THR	37500
19568	20092	109	THQ	39248
19569	20092	111	S3L/R5	41402
19570	20092	108	TWHFV	39233
19571	20092	111	S5L/R5	41412
19572	20092	82	WFR	42009
19573	20092	2	FWXY	54582
19574	20092	109	WFU1	39253
19575	20092	93	THV5	46307
19576	20092	87	WFY	47951
19577	20092	5	THU	54590
19578	20092	108	TWHFR	39232
19579	20092	95	THY1	45805
19580	20092	108	TWHFX1	39235
19581	20092	94	WFR1	45774
19582	20092	41	THV1	14402
19583	20092	109	WFV1	39255
19584	20092	100	WFW	42478
19585	20092	93	THU2	46305
19586	20092	36	WFW-1	13880
19587	20092	61	THX1	15597
19588	20092	107	TWHFU7	39338
19589	20092	5	THY	54588
19590	20092	43	THW1	14446
19591	20092	60	MR1	33108
19592	20092	109	THX	39240
19593	20092	111	S2L/R3	41395
19594	20092	43	WFU2	14454
19595	20092	123	WFV1	14484
19596	20092	109	THV	39238
19597	20092	2	THXY	54584
19598	20092	63	THQ1	15608
19599	20092	108	TWHFW1	39234
19600	20092	123	THV2	14473
19601	20092	55	THW1	15570
19602	20092	118	THR	39323
19603	20092	109	THU2	39340
19604	20092	94	WFY1	45790
19605	20092	37	WFV-2	13926
19606	20092	73	WFR	38050
19607	20092	100	THR3	42523
19608	20092	108	TWHFU	39231
19609	20092	94	WFV2	45782
19610	20092	50	WFX2	15535
19611	20092	109	THR1	39326
19612	20092	94	THU2	45756
19613	20092	107	TWHFV4	39204
19614	20092	110	S5L/R6	41379
19615	20092	1	FWXY	54553
19616	20092	109	WFU	39244
19617	20092	93	THY2	46320
19618	20092	70	THW	37503
19619	20092	111	S2L/R5	41397
19620	20092	42	WFR2	14429
19621	20092	111	S4L/R5	41407
19622	20092	160	THU	42480
19623	20092	36	THY-2	13870
19624	20092	35	WFX1	15544
19625	20092	107	TWHFU4	39203
19626	20092	1	FWVW	54565
19627	20092	42	WFU1	14430
19628	20092	109	THV2	39254
19629	20092	74	THY	54001
19630	20092	50	THV4	15656
19631	20092	94	WFV3	45783
19632	20092	109	WFW	39257
19633	20092	111	S2L/R2	41394
19634	20092	95	THX1	45803
19635	20092	66	THX1	26506
19636	20092	51	FWX	29251
19637	20092	95	WFR1	45808
19638	20092	40	THU2	14503
19639	20092	110	S6L/R3	41382
19640	20092	36	THR-2	13852
19641	20092	43	THU1	14438
19642	20092	111	S5L/R3	41410
19643	20092	93	WFX2	46330
19644	20092	35	WFR1	15506
19645	20092	70	THV	37502
19646	20092	109	THR3	39339
19647	20092	111	S3L/R4	41401
19648	20092	50	WFR1	15539
19649	20092	109	THR	39250
19650	20092	93	WFV1	46325
19651	20092	50	THV2	15534
19652	20092	111	S3L/R2	41399
19653	20092	123	THX1	14478
19654	20092	109	THR2	39331
19655	20092	111	S5L/R1	41408
19656	20092	93	WFX1	46332
19657	20092	50	WFX1	15545
19658	20092	109	WFR	39251
19659	20092	94	THR2	45753
19660	20092	94	THQ1	45750
19661	20092	35	THV1	15504
19662	20092	70	THY	37505
19663	20092	110	S6L/R2	41381
19664	20092	75	WFW	55101
19665	20092	37	THV-1	13917
19666	20092	95	WFV2	45812
19667	20092	93	THU3	46306
19668	20092	104	WFW	47957
19669	20092	39	THR	16069
19670	20092	70	THU	37501
19671	20092	138	WFU	40812
19672	20092	111	S4L/R4	41406
19673	20092	161	FAB2	41451
19674	20092	70	WFV	37508
19675	20092	111	S5L/R4	41411
19676	20092	87	WFR	47963
19677	20092	43	WFV2	14457
19678	20092	42	THX2	14425
19679	20092	45	WFX	14500
19680	20092	107	TWHFW	39180
19681	20092	100	WFQ1	42475
19682	20092	2	HTRU1	54557
19683	20092	36	WFV-2	13873
19684	20092	107	TWHFW3	39201
19685	20092	98	THY3	42458
19686	20092	2	HTRU2	54550
19687	20092	36	THX-2	13867
19688	20092	41	THU1	14606
19689	20092	107	TWHFW2	39194
19690	20092	93	WFU3	46324
19691	20092	123	WFV2	14485
19692	20092	107	TWHFQ1	39183
19693	20092	105	WFU	43562
19694	20092	107	TWHFV3	39200
19695	20092	94	THW2	45764
19696	20092	93	WFR1	46321
19697	20092	40	WFR	14511
19698	20092	70	WFU	37507
19699	20092	87	WFX	47970
19700	20092	43	WFX	14466
19701	20092	82	THR	42008
19702	20092	95	WFV1	45811
19703	20092	1	THVW	54556
19704	20092	123	WFW1	14487
19705	20092	48	X	19904
19706	20092	39	THQ	16094
19707	20092	79	THW2	39705
19708	20092	94	WFW2	45785
19709	20092	41	WFX1	14417
19710	20092	36	WFU-2	13877
19711	20092	41	WFR	14411
19712	20092	100	WFQ2	42476
19713	20092	107	TWHFQ3	39196
19714	20092	98	WFV2	42461
19715	20092	123	WFR	14481
19716	20092	40	WFU1	14512
19717	20092	106	TWHFW	39174
19718	20092	107	TWHFU2	39192
19719	20092	98	WFV1	42460
19720	20092	41	THX2	14406
19721	20092	81	WFR	42001
19722	20092	39	WFX4	16105
19723	20092	70	WFW	37509
19724	20092	107	TWHFU1	39185
19725	20092	39	THX1	16053
19726	20092	106	TWHFV1	39211
19727	20092	94	WFR3	45776
19728	20092	158	THX	16136
19729	20092	107	TWHFU	39178
19730	20092	98	THV1	42453
19731	20092	99	WFW	42467
19732	20092	43	WFV4	14459
19733	20092	107	TWHFQ4	39209
19734	20092	93	WFU1	46322
19735	20092	39	WFV1	16104
19736	20092	73	WFU	38065
19737	20092	107	TWHFR	39177
19738	20092	93	WFW1	46328
19739	20092	70	WFX	37510
19740	20092	89	WFR	62802
19741	20092	42	WFU2	14431
19742	20092	107	TWHFR2	39191
19743	20092	100	THQ2	42470
19744	20092	39	THW	16074
19745	20092	107	TWHFV1	39186
19746	20092	41	WFU1	14412
19747	20092	107	TWHFR4	39202
19748	20092	98	THU	42452
19749	20092	63	WFV1	15617
19750	20092	39	WFR1	16097
19751	20092	107	TWHFU3	39198
19752	20092	41	WFW1	14415
19753	20092	93	THW2	46316
19754	20092	70	THX	37504
19755	20092	39	WFW	16121
19756	20092	106	TWHFR	39171
19757	20092	83	THX	41485
19758	20092	63	THW3	15664
19759	20092	94	WFU3	45780
19760	20092	79	THV1	39703
19761	20092	83	WFX	41488
19762	20092	93	THW3	46313
19763	20092	41	THX3	14407
19764	20092	105	THY	43560
19765	20092	42	THX1	14424
19766	20092	95	WFU1	45809
19767	20092	83	THW	41484
19768	20092	94	WFR4	45777
19769	20092	107	TWHFW1	39187
19770	20092	99	WFU	42464
19771	20092	71	THX	38794
19772	20092	94	WFX3	45789
19773	20092	100	THQ1	42469
19774	20092	46	WFR	14951
19775	20092	107	TWHFV2	39193
19776	20092	95	WFQ1	45807
19777	20092	93	THU1	46304
19778	20092	43	WFU3	14455
19779	20092	99	WFX	42468
19780	20092	76	WFY	40806
19781	20092	93	THX1	46317
19782	20092	123	WFU1	14482
19783	20092	75	WFV	55100
19784	20092	61	WFU1	15599
19785	20092	107	TWHFW4	39321
19786	20092	93	THV4	46312
19787	20092	57	WFR1	15588
19788	20092	63	WFY1	15620
19789	20092	99	THW	42463
19790	20092	41	WFU3	14414
19791	20092	97	THW1	43003
19792	20092	39	THX2	16078
19793	20092	59	MR11C	33102
19794	20092	36	WFU-1	13875
19795	20092	70	WFR	37506
19796	20092	107	TWHFV5	39329
19797	20092	94	WFU2	45779
19798	20092	41	WFW2	14416
19799	20092	123	WFW2	14488
19800	20092	40	THW	14506
19801	20092	36	THQ-1	13850
19802	20092	106	TWHFV	39173
19803	20092	89	WFU	62803
19804	20092	36	THU-2	13855
19805	20092	39	WFQ1	16096
19806	20092	43	THU2	14439
19807	20092	40	THY2	14510
19808	20092	158	WFX	16127
19809	20092	76	THW	40802
19810	20092	94	THX4	45768
19811	20092	107	TWHFU5	39206
19812	20092	100	THW	42474
19813	20092	41	WFX2	14418
19814	20092	93	THR1	46302
19815	20092	94	WFX1	45787
19816	20092	43	WFW1	14461
19817	20092	106	TWHFQ	39170
19818	20092	103	WFV-1	44684
19819	20092	39	THX3	16081
19820	20092	93	THW1	46315
19821	20092	42	THX3	14426
19822	20092	39	WFY2	16068
19823	20092	104	MCDE1	45817
19824	20092	100	WFR	42477
19825	20092	95	THU2	45796
19826	20092	39	WFU	16103
19827	20093	41	X4A	14406
19828	20093	111	X7-5	41355
19829	20093	93	X3-1	46307
19830	20093	35	X2-A	15501
19831	20093	18	Prac	54551
19832	20093	162	X7-9	41359
19833	20093	94	X3	45753
19834	20093	113	X1-A	15546
19835	20093	70	X5	37504
19836	20093	113	X2-B	15543
19837	20093	133	X4	55651
19838	20093	61	X3-A	15519
19839	20093	109	X2-1	39205
19840	20093	81	X4	42003
19841	20093	71	X3	38602
19842	20093	123	X3A	14431
19843	20093	111	X7-4	41354
19844	20093	98	X1	42451
19845	20093	5	X	54554
19846	20093	108	Z1-4	39195
19847	20093	109	X1-1	39193
19848	20093	103	X-2	44659
19849	20093	109	X4	39182
19850	20093	109	X3	39181
19851	20093	100	X4-1	42461
19852	20093	108	Z2	39172
19853	20093	108	Z3-1	39175
19854	20093	108	Z3-4	39206
19855	20093	109	X4-1	39183
19856	20093	43	X2B	14418
19857	20093	123	X2A	14428
19858	20093	93	X3	46302
19859	20093	23	X	54553
19860	20093	109	X2	39180
19861	20093	103	X5	43556
19862	20093	50	X4-A	15507
19863	20093	41	X3A	14403
19864	20093	108	Z1-1	39173
19865	20093	108	Z2-3	39199
19866	20093	137	X3	14966
19867	20093	163	X-2-2	44653
19868	20093	107	Z1-2	39169
19869	20093	108	Z1	39170
19870	20093	108	Z1-3	39194
19871	20093	108	Z1-5	39196
19872	20093	95	X3	45755
19873	20093	93	X2	46301
19874	20093	108	Z2-2	39177
19875	20093	105	X3	43554
19876	20093	94	X2	45752
19877	20093	40	X4A	14439
19878	20093	100	X3-1	42459
19879	20093	107	Z1	39164
19880	20093	108	Z1-2	39176
19881	20093	108	Z1-6	39197
19882	20093	107	Z2	39165
19883	20093	107	Z1-3	39201
19884	20093	108	Z3-2	39178
19885	20093	100	X3-2	42460
19886	20093	94	X1	45751
19887	20093	107	Z2-1	39168
19888	20093	107	Z2-2	39202
19889	20093	84	X3	42002
19890	20093	39	X1A	16051
19891	20093	102	X2-1	44110
19892	20093	71	X2	38601
19893	20093	107	Z1-1	39167
19894	20093	108	Z1-8	39215
19895	20093	108	Z2-1	39174
19896	20101	17	THU	54569
19897	20101	7	HTVW	54586
19898	20101	16	THY	54592
19899	20101	6	S2	54650
19900	20101	112	WFR	69955
19901	20101	37	WFX-1	13890
19902	20101	102	WFU	44164
19903	20101	17	WFV	54571
19904	20101	21	HR	54593
19905	20101	20	MACL	54614
19906	20101	19	WFX	54576
19907	20101	16	WFY	54591
19908	20101	20	MWSG	54619
19909	20101	112	WFU	69956
19910	20101	164	THD	66665
19911	20101	164	HJ4	66745
19912	20101	70	WFV	37509
19913	20101	82	THX	42012
19914	20101	16	WFX	54590
19915	20101	23	THR	54605
19916	20101	114	WBC	52481
19917	20101	114	WBCH	52483
19918	20101	17	WFW	54572
19919	20101	8	THV	54579
19920	20101	6	HTXY	54582
19921	20101	7	M	54649
19922	20101	114	WBCT	52482
19923	20101	8	THW	54577
19924	20101	7	WFVW	54646
19925	20101	23	THV	54595
19926	20101	114	FBCS2	52528
19927	20101	114	FBC	52530
19928	20101	113	WFQ2	15650
19929	20101	155	THW	40258
19930	20101	19	WFU	54574
19931	20101	16	WFV	54589
19932	20101	20	MCVMIG	54616
19933	20101	112	WFX	70034
19934	20101	123	WFU1	14497
19935	20101	87	WFW1	47967
19936	20101	7	HTRU	54585
19937	20101	113	THV1	15631
19938	20101	70	THW	37504
19939	20101	100	WFR1	42472
19940	20101	3	WFVW	54567
19941	20101	19	THR	54573
19942	20101	17	WFU	54570
19943	20101	19	WFW	54575
19944	20101	26	THX	54596
19945	20101	75	WFY	55106
19946	20101	8	THY	54578
19947	20101	113	THX2	15636
19948	20101	165	THU	39268
19949	20101	111	S4-A	41382
19950	20101	114	FBCS1	52484
19951	20101	20	MNDSG	54617
19952	20101	43	THW1	14465
19953	20101	111	S3-A	41380
19954	20101	95	THV1	45796
19955	20101	79	WFV1	39705
19956	20101	20	MSCL	54618
19957	20101	108	TWHFV1	39249
19958	20101	72	WFX	52379
19959	20101	3	WFRU	54566
19960	20101	35	WFV2	15505
19961	20101	109	THX	39261
19962	20101	100	THR3	42519
19963	20101	166	THU	43030
19964	20101	23	THW	54604
19965	20101	36	THY-1	13862
19966	20101	103	WFQ-2	44665
19967	20101	74	THX	54001
19968	20101	23	WFY	54607
19969	20101	127	THV1	15554
19970	20101	81	WFX	42002
19971	20101	82	THR	42003
19972	20101	107	TWHFY1	39382
19973	20101	110	S3-A	41361
19974	20101	1	FWVW	54555
19975	20101	45	WFV	14519
19976	20101	6	S	54643
19977	20101	137	THQ	15024
19978	20101	56	THX1	15566
19979	20101	6	FWVW	54583
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
2537	2006	9
2537	2007	3
2538	2004	13
2538	2008	12
2538	2009	22
2538	2010	6
2539	2005	12
2539	2006	13
2539	2007	22
2539	2009	3
2541	2006	23
2541	2008	18
2541	2010	4
2542	2009	6
2542	2010	3
2543	2010	9
2544	2010	12
2546	2010	15
2547	2010	0
2548	2010	9
2549	2010	9
2550	2010	13
2551	2010	12
2552	2010	15
2553	2010	16
2554	2009	22
2554	2010	6
2555	2010	15
2556	2009	13
2556	2010	10
2557	2010	12
2558	2010	15
2559	2010	15
2560	2010	19
2561	2010	15
2562	2010	18
2563	2010	15
2564	2010	18
2565	2010	9
2582	2009	15
2591	2009	23
2597	2008	22
2597	2010	9
2598	2010	12
2599	2010	13
2600	2010	15
2601	2010	19
2602	2010	19
2708	2009	11
2709	2009	14
2710	2009	19
2711	2010	15
\.


--
-- Data for Name: eligpasshalf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalf (studentid, studenttermid, termid, failpercentage) FROM stdin;
2537	10651	20032	0.8125
2538	10665	20042	0.789473712
2538	10930	20091	0.600000024
2538	11366	20101	0.600000024
2539	10666	20042	0.5625
2546	11273	20093	1
2547	10772	20073	1
2548	10754	20072	0.625
2556	11282	20093	0.571428597
2579	10918	20083	1
2582	10985	20091	0.631578922
2586	10923	20083	1
2591	11308	20093	1
2604	11290	20093	1
2648	11328	20093	1
2697	11358	20093	1
2699	11360	20093	1
2651	11042	20091	1
2535	10631	19991	1
2535	10644	20031	1
\.


--
-- Data for Name: eligpasshalfmathcs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalfmathcs (studentid, studenttermid, termid, failpercentage) FROM stdin;
2537	10651	20032	0.666666687
2538	10665	20042	1
2539	10666	20042	1
2541	10684	20052	0.625
2541	10692	20061	0.555555582
2543	10705	20062	0.625
2544	10695	20061	0.625
2545	10749	20072	0.666666687
2546	10750	20072	0.666666687
2546	11273	20093	1
2548	10754	20072	0.666666687
2549	10751	20072	1
2551	10755	20072	0.625
2554	10734	20071	0.625
2556	10760	20072	0.625
2557	10761	20072	0.625
2559	10799	20081	0.555555582
2566	10864	20082	0.625
2566	11131	20092	0.666666687
2567	10965	20091	0.555555582
2567	11288	20093	1
2571	10972	20091	0.555555582
2574	10813	20081	0.625
2575	10873	20082	0.625
2578	11150	20092	0.666666687
2579	10918	20083	1
2581	10879	20082	0.625
2581	11153	20092	0.545454562
2582	10985	20091	0.666666687
2583	10822	20081	0.625
2586	10923	20083	1
2591	11308	20093	1
2593	10891	20082	0.625
2596	10835	20081	1
2600	10957	20091	0.625
2601	11125	20092	0.625
2604	11290	20093	1
2624	11015	20091	0.625
2629	11020	20091	0.625
2630	11191	20092	0.625
2642	11033	20091	0.625
2648	11039	20091	0.625
2648	11328	20093	1
2664	11225	20092	0.625
2665	11226	20092	0.625
2681	11072	20091	0.625
2683	11244	20092	0.625
2685	11246	20092	0.625
2688	11249	20092	0.625
2692	11253	20092	0.625
2693	11254	20092	0.625
2697	11088	20091	0.625
2697	11358	20093	1
2699	11360	20093	1
2701	11262	20092	1
2703	11264	20092	0.625
2651	11042	20091	1
2535	10631	19991	1
2535	10636	20012	0.666666687
2535	10644	20031	1
\.


--
-- Data for Name: eligtwicefail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligtwicefail (studentid, classid, courseid, section, coursename, termid) FROM stdin;
2591	19490	5	WFU	CS 32	20092
2591	19845	5	X	CS 32	20093
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
2545	ORENSE	ADRIAN	CORDOVA	
2546	VILLARANTE	JAY RICKY	BARRAMEDA	
2547	LUMONGSOD	PIO RYAN	SAGARINO	
2548	TOBIAS	GEORGE HELAMAN	ASTURIAS	
2549	CUNANAN	JENNIFER	DELA CRUZ	
2550	RAGASA	ROGER JOHN	ESTEPA	
2551	MARANAN	KERVIN	CATUNGAL	
2552	DEINLA	REGINALD ELI	ATIENZA	
2553	RAMIREZ	NORBERTO	ALLAREY	II
2554	PUGAL	EDGAR	STA BARBARA	JR
2555	JOVEN	KATHLEEN GRACE	GUERRERO	
2556	ESCALANTE	ED ALBERT	BELARGO	
2557	CONTRERAS	PAUL VINCENT	SALES	
2558	DIRECTO	KAREIN JOY	TOLENTINO	
2559	VALLO	LOVELIA	LAROCO	
2560	DOMINGO	CYROD JOHN	FLORIDA	
2561	SUBA	KEVIN RAINIER	SINOGAYA	
2562	CATAJOY	VINCENT NICHOLAS	RANA	
2563	BATANES	BRYAN MATTHEW	AVENDANO	
2564	BALAGAPO	JOSHUA	KHO	
2565	DOMANTAY	ERIC	AMPARO	JR
2566	JAVIER	JEWEL LEX	TONG	
2567	JUAT	WESLEY	MENDOZA	
2568	ISIDRO	HOMER IRIC	SANTOS	
2569	VILLANUEVA	MARIANNE ANGELIE	OCAMPO	
2570	MAMARIL	VIC ANGELO	DELOS SANTOS	
2571	ARANA	RYAN KRISTOFER	IGMAT	
2572	NICOLAS	DANA ELISA	GAGALAC	
2573	VACALARES	ISAIAH JAMES	VALDES	
2574	SANTILLAN	MA CECILIA		
2575	PINEDA	JAKE ERICKSON	BOTEROS	
2576	LOYOLA	ELIZABETH	CUETO	
2577	BUGAOAN	FRANCIS KEVIN	ALIMORONG	
2578	GALLARDO	FRANCIS JOMER	DE LEON	
2579	ARGARIN	MICHAEL ERICK	STA TERESA	
2580	VILLARUZ	JULIAN	CASTILLO	
2581	FRANCISCO	ARMINA	EUGENIO	
2582	AQUINO	JOSEPH ARMAN	BONGCO	
2583	AME	MARTIN ROMAN LORENZO	ILAGAN	
2584	CELEDONIO	MESSIAH JAN	LEBID	
2585	SABIDONG	JEROME	RONCESVALLES	
2586	FLORENCIO	JOHN CARLO	MAQUILAN	
2587	EPISTOLA	SILVEN VICTOR	DUMALAG	
2588	SANTOS	JOHN ISRAEL	LORENZO	
2589	SANTOS	MARIE JUNNE	CABRAL	
2590	FABIC	JULIAN NICHOLAS	REYES	
2591	TORRES	ERIC	TUQUERO	
2592	CUETO	BENJAMIN	ANGELES	JR
2593	PASCUAL	JEANELLA KLARYS	ESPIRITU	
2594	GAMBA	JOSE NOEL	CARDONES	
2595	REFAMONTE	JARED	MUMAR	
2596	BARITUA	KARESSA ALEXANDRA	ONG	
2597	SEMILLA	STANLEY	TINA	
2598	ANGELES	MARC ARTHUR	PAJE	
2599	SORIAO	HANS CHRISTIAN	BALTAZAR	
2600	DINO	ARVIN	PABINES	
2601	MORALES	NOELYN JOYCE	ROL	
2602	MANALAC	DAVID ROBIN	MANALAC	
2603	SAY	KOHLEN ANGELO	PEREZ	
2604	ADRIANO	JAMES PATRICK	DAVID	
2605	SERRANO	MICHAEL	DIONISIO	
2606	CHOAPECK	MARIE ANTOINETTE	R	
2607	TURLA	ISAIAH EDWARD	G	
2608	MONCADA	DEAN ALVIN	BAJAMONDE	
2609	EVANGELISTA	JOHN EROL	MILANO	
2610	ASIS	KRYSTIAN VIEL	CABUGAO	
2611	CLAVECILLA	VANESSA VIVIEN	FRANCISCO	
2612	RONDON	RYAN ODYLON	GAZMEN	
2613	ARANAS	CHRISTIAN JOY	MARQUEZ	
2614	AGUILAR	JENNIFER	RAMOS	
2615	CUEVAS	SARAH	BERNABE	
2616	PASCUAL	JAYVEE ELJOHN	ACABO	
2617	TORRES	DANAH VERONICA	PADILLA	
2618	BISAIS	APRYL ROSE	LABAYOG	
2619	CHUA	TED GUILLANO	SY	
2620	CRUZ	IVAN KRISTEL	POLICARPIO	
2621	AQUINO	CHLOEBELLE	RAMOS	
2622	YUTUC	DANIEL	LALAGUNA	
2623	DEL ROSARIO	BENJIE	REYES	
2624	RAMOS	ANNA CLARISSA	BEATO	
2625	REYES	CHARMAILENE	CAPILI	
2626	ABANTO	JEANELLE	ESGUERRA	
2627	BONDOC	ROD XANDER	RIVERA	
2628	TACATA	NERISSA MONICA	DE GUZMAN	
2629	RABE	REZELEE	AQUINO	
2630	DECENA	BERLYN ANNE	ARAGON	
2631	DIMLA	KARL LEN MAE	BALDOMERO	
2632	SANCHEZ	ZIV YVES	MONTOYA	
2633	LITIMCO	CZELINA ELLAINE	ONG	
2634	GUILLEN	NEIL DAVID	BALGOS	
2635	SOMOSON	LOU MERLENETTE	BAUTISTA	
2636	TALAVERA	RHIZA MAE	GO	
2637	CANOY	JOHN GABRIEL	ERUM	
2638	CHUA	RALPH JACOB	ANG	
2639	EALA	MARIA AZRIEL THERESE	DESTUA	
2640	AYAG	DANIELLE ANNE	FRANCISCO	
2641	DE VILLA	RACHEL	LUNA	
2642	JAYMALIN	JEAN DOMINIQUE	BERNAL	
2643	LEGASPI	CHARMAINE PAMELA	ABERCA	
2644	LIBUNAO	ARIANNE FRANCESCA	QUIJANO	
2645	REGENCIA	FELIX ARAM	JEREMIAS	
2646	SANTI	NATHAN LEMUEL	GO	
2647	LEONOR	WENDY GENEVA	SANTOS	
2648	LUNA	MARA ISSABEL	SUPLICO	
2649	SIRIBAN	MA LORENA JOY	ASCUTIA	
2650	LEGASPI	MISHAEL MAE	CRUZ	
2651	SUN	HANNAH ERIKA	YAP	
2652	PARRENO	NICOLE ANNE	KAHN	
2653	BULANHAGUI	KEVIN DAVID	BALANAY	
2654	MONCADA	JULIA NINA	SOMERA	
2655	IBANEZ	SEBASTIAN	CANLAS	
2656	COLA	VERNA KATRIN	BEDUYA	
2657	SANTOS	MARIA RUBYLISA	AREVALO	
2658	YECLA	NORVIN	GARCIA	
2659	CASTANEDA	ANNA MANNELLI	ESPIRITU	
2660	FOJAS	EDGAR ALLAN	GO	
2661	DELA CRUZ	EMERY	FABRO	
2662	SADORNAS	JON PERCIVAL	GARCIA	
2663	VILLANUEVA	MARY GRACE	AYENTO	
2664	ESGUERRA	JOSE MARI	MARCELO	
2665	SY	KYLE BENEDICT	GUERRERO	
2666	TORRES	LUIS ANTONIO	PEREZ	
2667	TONG	MAYNARD JEFFERSON	ZHUANG	
2668	DATU	PATRICH PAOLO	BONETE	
2669	PEREA	EMMANUEL	LOYOLA	
2670	BALOY	MICHAEL JOYSON	GERMAR	
2671	REAL	VICTORIA CASSANDRA	RUIVIVAR	
2672	MARTIJA	JASPER	ENRIQUEZ	
2673	OCHAVEZ	ARISA	CAAKBAY	
2674	AMORANTO	PAOLO	SISON	
2675	SAN ANTONIO	JAYVIC	PORTILLO	
2676	SARDONA	CATHERINE LORAINE	FESTIN	
2677	MENESES	ANGELO	CAL	
2678	AUSTRIA	DARRWIN DEAREST	CRISOSTOMO	
2679	BURGOS	ALVIN JOHN	MANLIGUEZ	
2680	MAGNO	JENNY	NARSOLIS	
2681	SAPASAP	RIC JANUS	OLIVER	
2682	QUILAB	FRANCIS MIGUEL	EVANGELISTA	
2683	PINEDA	RIZA RAE	ALDECOA	
2684	TAN	XYRIZ CZAR	PINEDA	
2685	DELAS PENAS	KRISTOFER	EMPUERTO	
2686	MANSOS	JOHN FRANCIS	LLAGAS	
2687	PANOPIO	GIRAH MAY	CHUA	
2688	LEGASPINA	CHRISLENE	BUGARIN	
2689	RIVERA	DON JOSEPH	TIANGCO	
2690	RUBIO	MARY GRACE	TALAN	
2691	LEONOR	CHARLES TIMOTHY	DEL ROSARIO	
2692	CABUHAT	JOHN JOEL	URBISTONDO	
2693	MARANAN	GENIE LINN	PADILLA	
2694	WANG	CASSANDRA LEIGH	LACASTA	
2695	YU	GLADYS JOYCE	OCAP	
2696	TOMACRUZ	ARVIN JOHN	CRUZ	
2697	BALDUEZA	GYZELLE	EVANGELISTA	
2698	BATAC	JOSE EMMANUEL	DE JESUS	
2699	CUETO	JAN COLIN	OJEDA	
2700	RUBI	SHIELA PAULINE JOY	VERGARA	
2701	ALCARAZ	KEN GERARD	TECSON	
2702	DE LOS SANTOS	PAOLO MIGUEL	MACALINDONG	
2703	CHAVEZ	JOE-MAR	ORINDAY	
2704	PERALTA	PAOLO THOMAS	REYES	
2705	SANTOS	ALEXANDREI	GONZALES	
2706	MACAPINLAC	VERONICA	ALCARAZ	
2707	PACAPAC	DIANA MAE	CANLAS	
2708	DUNGCA	JOHN ALPERT	ANCHO	
2709	ZACARIAS	ROEL JEREMIAH	ALCANTARA	
2710	RICIO	DUSTIN EDRIC	LEGARDA	
2711	ARBAS	HARVEY IAN	SOLAYAO	
2712	SALVADOR	RAMON JOSE NILO	DELA VEGA	
2713	DORADO	JOHN PHILIP	URRIZA	
2714	DEATRAS	SHEALTIEL PAUL ROSSNERR	CALUAG	
2715	CAPACILLO	JULES ALBERT	BERINGUELA	
2716	SALAMANCA	KYLA MARIE	G.	
2717	AVE	ARMOND	C.	
2718	CALARANAN	MICHAEL KEVIN	PONTE	
2719	DOCTOR	JET LAWRENCE	PARONE	
2720	ANG	RITZ DANIEL	CATAMPATAN	
2721	FORMES	RAFAEL GERARD	DELA CRUZ	
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
47191	10632	18185	4
47192	10632	18186	5
47193	10632	18187	6
47194	10632	18188	4
47195	10632	18189	3
47196	10633	18190	10
47197	10633	18191	11
47198	10633	18192	9
47199	10633	18193	8
47200	10633	18194	11
47201	10634	18195	3
47202	10634	18196	9
47203	10635	18197	7
47204	10635	18198	9
47205	10635	18199	13
47206	10635	18200	10
47207	10635	18201	6
47208	10636	18202	13
47209	10636	18203	9
47210	10636	18204	11
47211	10636	18205	11
47212	10636	18206	9
47213	10636	18207	11
47214	10637	18208	6
47215	10637	18209	5
47216	10638	18210	9
47217	10638	18211	6
47218	10638	18212	11
47219	10638	18213	9
47220	10638	18214	5
47221	10639	18215	6
47222	10639	18216	9
47223	10639	18217	6
47224	10639	18218	8
47225	10639	18219	3
47226	10640	18220	7
47227	10640	18221	6
47228	10640	18222	5
47229	10640	18223	6
47230	10640	18224	6
47231	10641	18225	9
47232	10641	18226	8
47233	10641	18227	10
47234	10642	18228	5
47235	10642	18229	9
47236	10642	18230	7
47237	10642	18231	7
47238	10642	18232	11
47239	10643	18233	7
47240	10643	18234	9
47241	10643	18235	3
47242	10643	18236	6
47243	10643	18237	9
47249	10645	18243	7
47250	10645	18244	14
47251	10645	18245	9
47252	10645	18246	14
47253	10645	18247	5
47254	10645	18248	5
47255	10646	18249	9
47256	10646	18250	8
47257	10646	18251	9
47258	10646	18252	4
47259	10646	18253	7
47260	10647	18254	12
47261	10647	18255	7
47262	10647	18256	5
47263	10647	18257	9
47264	10647	18258	14
47265	10648	18259	14
47266	10648	18260	9
47267	10648	18261	6
47268	10648	18262	6
47269	10648	18263	12
47270	10649	18264	12
47271	10650	18265	5
47272	10650	18266	4
47273	10650	18267	13
47274	10650	18268	4
47275	10650	18269	9
47276	10650	18270	9
47277	10651	18271	11
47278	10651	18272	9
47279	10651	18273	11
47280	10651	18274	11
47281	10651	18275	11
47282	10652	18276	13
47285	10652	18279	9
47286	10652	18280	5
47287	10653	18281	9
47288	10653	18282	6
47289	10653	18283	4
47290	10653	18284	2
47291	10653	18285	2
47292	10654	18286	6
47293	10655	18287	8
47294	10656	18288	5
47295	10656	18289	5
47296	10657	18290	10
47297	10658	18291	4
47298	10658	18292	9
47299	10658	18293	8
47300	10658	18294	11
47301	10658	18295	8
47302	10658	18296	9
47303	10659	18297	9
47304	10659	18298	4
47305	10659	18299	9
47306	10659	18300	11
47307	10659	18301	9
47308	10659	18295	11
47309	10660	18302	12
47310	10660	18303	7
47311	10660	18304	11
47312	10660	18305	13
47313	10660	18306	6
47314	10661	18307	12
47315	10661	18308	6
47316	10661	18309	7
47317	10661	18310	7
47318	10661	18311	7
47319	10662	18312	4
47320	10662	18313	7
47321	10662	18314	1
47322	10662	18315	4
47323	10662	18316	1
47324	10663	18317	7
47325	10663	18318	4
47326	10663	18319	8
47327	10663	18320	1
47328	10663	18321	7
47329	10663	18322	9
47330	10664	18323	12
47331	10664	18324	4
47332	10664	18325	5
47333	10664	18319	11
47334	10664	18321	8
47335	10664	18322	9
47336	10665	18326	11
47337	10665	18327	11
47338	10665	18328	11
47339	10665	18329	11
47340	10665	18330	9
47341	10665	18331	11
47342	10666	18332	5
47343	10666	18333	11
47344	10666	18334	11
47345	10666	18335	9
47346	10666	18331	11
47347	10667	18336	9
47348	10667	18337	6
47349	10667	18338	13
47350	10667	18339	5
47351	10667	18340	2
47352	10668	18341	4
47353	10668	18342	7
47354	10669	18343	2
47355	10669	18344	4
47356	10670	18345	14
47357	10671	18346	6
47358	10672	18347	13
47359	10673	18348	6
47360	10673	18349	9
47361	10673	18350	9
47362	10673	18351	6
47363	10673	18352	2
47364	10673	18353	5
47365	10673	18354	6
47366	10674	18355	11
47367	10674	18356	5
47368	10674	18350	5
47284	10652	18278	5
47184	10631	18178	11
47185	10631	18179	11
47186	10631	18180	11
47187	10631	18181	11
47188	10631	18182	11
47189	10631	18183	11
47244	10644	18238	11
47245	10644	18239	11
47246	10644	18240	11
47247	10644	18241	11
47248	10644	18242	11
47369	10674	18357	6
47370	10674	18358	6
47371	10674	18359	9
47372	10675	18360	6
47373	10675	18361	5
47374	10675	18362	11
47375	10675	18363	11
47376	10675	18364	3
47377	10675	18365	9
47378	10676	18366	8
47379	10676	18367	11
47380	10676	18368	6
47381	10676	18369	12
47382	10676	18365	9
47383	10676	18359	7
47384	10677	18370	4
47385	10677	18371	8
47386	10677	18372	7
47387	10677	18369	1
47388	10677	18373	7
47389	10678	18374	7
47390	10678	18375	5
47391	10678	18376	4
47392	10678	18377	3
47393	10678	18378	4
47394	10679	18379	6
47395	10679	18380	4
47396	10679	18381	4
47397	10679	18382	8
47398	10679	18383	2
47399	10680	18384	3
47400	10680	18385	14
47401	10680	18386	9
47402	10680	18387	9
47403	10680	18388	12
47404	10680	18389	7
47405	10680	18390	2
47406	10681	18391	8
47407	10681	18392	5
47408	10681	18393	9
47409	10681	18388	6
47410	10681	18394	6
47411	10681	18395	2
47412	10681	18396	3
47413	10682	18397	6
47414	10682	18398	5
47415	10682	18399	5
47416	10682	18400	10
47417	10682	18401	8
47418	10682	18402	7
47419	10683	18403	12
47420	10683	18404	10
47421	10683	18405	4
47422	10683	18406	9
47423	10683	18407	6
47424	10683	18408	5
47425	10684	18409	13
47426	10684	18410	11
47427	10684	18411	9
47428	10684	18412	6
47429	10684	18413	4
47430	10685	18391	8
47431	10685	18414	7
47432	10685	18415	5
47433	10685	18416	4
47434	10685	18417	1
47435	10686	18418	1
47436	10686	18419	2
47437	10687	18420	5
47438	10688	18421	6
47439	10689	18422	3
47440	10689	18423	6
47441	10690	18424	14
47442	10690	18425	8
47443	10690	18426	10
47444	10690	18427	6
47445	10691	18428	2
47446	10691	18429	3
47447	10691	18424	5
47448	10691	18430	5
47449	10691	18431	5
47450	10691	18432	6
47451	10691	18433	1
47452	10692	18434	11
47453	10692	18435	11
47454	10692	18436	8
47455	10692	18437	13
47456	10692	18438	9
47457	10693	18439	4
47458	10693	18440	8
47459	10693	18441	6
47460	10693	18442	9
47461	10693	18443	3
47462	10694	18444	5
47463	10694	18445	5
47464	10694	18446	9
47465	10694	18447	2
47466	10694	18448	5
47467	10695	18449	3
47468	10695	18450	11
47469	10695	18451	2
47470	10695	18452	3
47471	10695	18453	5
47472	10696	18454	2
47473	10696	18455	8
47474	10696	18456	1
47475	10696	18457	3
47476	10696	18453	6
47477	10697	18449	4
47478	10697	18455	9
47479	10697	18458	1
47480	10697	18459	7
47481	10697	18460	7
47482	10698	18461	5
47483	10698	18462	10
47484	10698	18463	5
47485	10698	18464	5
47486	10698	18460	1
47487	10699	18465	7
47488	10699	18466	9
47489	10699	18467	6
47490	10699	18468	3
47491	10699	18469	2
47492	10700	18470	14
47493	10700	18471	14
47494	10700	18472	9
47495	10701	18473	4
47496	10701	18474	7
47497	10701	18475	8
47498	10701	18476	4
47499	10701	18477	12
47500	10702	18478	2
47501	10702	18470	14
47502	10702	18479	8
47503	10702	18480	1
47504	10702	18481	2
47505	10702	18482	4
47506	10702	18483	1
47507	10703	18484	13
47508	10703	18485	9
47509	10703	18486	11
47510	10703	18487	9
47511	10703	18488	9
47512	10704	18489	8
47513	10704	18490	6
47514	10704	18491	9
47515	10704	18492	3
47516	10704	18480	6
47517	10704	18493	5
47518	10705	18494	6
47519	10705	18495	11
47520	10705	18496	4
47521	10705	18497	4
47522	10705	18498	6
47523	10706	18499	8
47524	10706	18500	4
47525	10706	18501	8
47526	10706	18502	5
47527	10706	18503	8
47528	10707	18504	5
47529	10707	18505	3
47530	10707	18506	3
47531	10707	18507	9
47532	10707	18508	4
47533	10708	18509	3
47534	10708	18510	9
47535	10708	18511	6
47536	10708	18512	4
47537	10708	18508	5
47538	10709	18513	5
47539	10709	18514	5
47540	10709	18515	4
47541	10709	18516	7
47542	10709	18503	2
47543	10710	18517	9
47544	10710	18518	3
47545	10710	18519	2
47546	10710	18512	4
47547	10710	18508	3
47548	10711	18520	14
47549	10712	18521	9
47550	10713	18522	4
47551	10714	18523	9
47552	10715	18524	8
47553	10716	18525	7
47554	10717	18526	8
47555	10718	18527	2
47556	10718	18528	4
47557	10719	18529	14
47558	10719	18530	4
47559	10719	18531	7
47560	10719	18532	11
47561	10719	18533	8
47562	10719	18534	12
47563	10719	18535	11
47564	10719	18536	1
47565	10720	18537	8
47566	10720	18538	11
47567	10720	18533	8
47568	10720	18539	12
47569	10720	18540	2
47570	10720	18541	5
47571	10720	18542	14
47572	10720	18543	4
47573	10721	18544	9
47574	10721	18545	9
47575	10721	18529	14
47576	10721	18530	5
47577	10721	18546	9
47578	10721	18534	8
47579	10721	18535	7
47580	10722	18529	14
47581	10722	18530	3
47582	10722	18547	2
47583	10722	18532	9
47584	10722	18548	9
47585	10722	18549	9
47586	10722	18543	8
47587	10723	18550	3
47588	10723	18551	7
47589	10723	18552	11
47590	10723	18553	7
47591	10724	18554	7
47592	10724	18555	7
47593	10724	18556	1
47594	10724	18557	2
47595	10724	18558	7
47596	10725	18559	5
47597	10725	18560	9
47598	10725	18561	2
47599	10725	18562	4
47600	10725	18563	5
47601	10726	18564	4
47602	10726	18565	8
47603	10726	18566	1
47604	10726	18558	8
47605	10727	18567	6
47606	10727	18568	8
47607	10727	18569	2
47608	10727	18570	9
47609	10728	18571	4
47610	10728	18572	4
47611	10728	18573	9
47612	10728	18574	13
47613	10729	18575	6
47614	10729	18576	9
47615	10729	18577	6
47616	10729	18578	6
47617	10729	18558	4
47618	10730	18579	3
47619	10730	18580	8
47620	10730	18555	9
47621	10730	18581	2
47622	10730	18563	8
47623	10731	18582	5
47624	10731	18583	7
47625	10731	18584	1
47626	10731	18561	2
47627	10731	18585	2
47628	10732	18586	1
47629	10732	18587	5
47630	10732	18588	3
47631	10732	18589	11
47632	10732	18590	2
47633	10733	18586	1
47634	10733	18587	5
47635	10733	18588	3
47636	10733	18589	11
47637	10733	18590	2
47638	10734	18591	4
47639	10734	18587	7
47640	10734	18592	11
47641	10734	18593	10
47642	10734	18594	5
47643	10735	18586	1
47644	10735	18587	5
47645	10735	18588	9
47646	10735	18589	8
47647	10735	18590	4
47648	10736	18595	12
47649	10736	18596	7
47650	10736	18592	7
47651	10736	18597	11
47652	10736	18594	2
47653	10737	18586	1
47654	10737	18587	4
47655	10737	18588	8
47656	10737	18589	6
47657	10737	18590	3
47658	10738	18586	2
47659	10738	18587	7
47660	10738	18588	1
47661	10738	18589	5
47662	10738	18590	1
47663	10739	18598	7
47664	10739	18599	9
47665	10739	18600	3
47666	10739	18601	3
47667	10739	18574	5
47668	10740	18586	1
47669	10740	18587	6
47670	10740	18588	3
47671	10740	18589	8
47672	10740	18590	3
47673	10741	18598	4
47674	10741	18599	6
47675	10741	18602	6
47676	10741	18603	1
47677	10741	18574	1
47679	10743	18605	11
47680	10743	18606	6
47681	10743	18607	5
47682	10743	18608	2
47683	10743	18609	12
47684	10743	18610	6
47685	10744	18611	4
47686	10744	18612	3
47687	10744	18613	4
47688	10744	18614	8
47689	10744	18615	5
47690	10744	18616	12
47691	10744	18617	12
47692	10745	18618	11
47693	10745	18619	5
47694	10745	18620	10
47695	10745	18621	11
47696	10745	18622	9
47697	10745	18623	12
47698	10745	18624	11
47699	10746	18625	13
47700	10746	18626	6
47701	10746	18627	5
47702	10746	18622	2
47703	10746	18628	2
47704	10746	18624	5
47705	10747	18629	9
47706	10747	18630	13
47707	10747	18631	5
47708	10747	18632	13
47709	10747	18633	7
47710	10748	18634	13
47711	10748	18635	3
47712	10748	18636	7
47713	10748	18637	7
47714	10748	18638	3
47715	10748	18632	8
47716	10749	18639	9
47717	10749	18640	11
47718	10749	18635	8
47719	10749	18641	9
47720	10749	18642	11
47721	10749	18643	2
47722	10750	18644	4
47723	10750	18635	6
47724	10750	18645	11
47725	10750	18646	9
47726	10750	18647	5
47727	10750	18648	11
47728	10751	18649	9
47729	10751	18650	8
47730	10751	18651	11
47731	10751	18646	10
47732	10751	18652	11
47733	10752	18653	12
47734	10752	18654	6
47735	10752	18655	8
47736	10752	18656	10
47737	10752	18657	7
47738	10752	18658	6
47739	10753	18659	6
47740	10753	18639	8
47741	10753	18660	9
47742	10753	18635	4
47743	10753	18656	13
47744	10753	18648	8
47745	10754	18661	2
47746	10754	18645	11
47747	10754	18662	9
47748	10754	18636	11
47749	10754	18648	11
47750	10755	18663	5
47751	10755	18664	11
47752	10755	18665	2
47753	10755	18666	3
47754	10755	18667	4
47755	10756	18668	7
47756	10756	18669	9
47757	10756	18665	4
47758	10756	18670	5
47759	10756	18667	3
47760	10757	18671	8
47761	10757	18669	9
47762	10757	18665	5
47763	10757	18670	6
47764	10757	18667	7
47765	10758	18672	4
47766	10758	18673	8
47767	10758	18618	8
47768	10758	18674	7
47769	10758	18675	6
47770	10759	18676	4
47771	10759	18677	9
47772	10759	18665	6
47773	10759	18678	1
47774	10759	18667	9
47775	10760	18679	13
47776	10760	18680	11
47777	10760	18681	5
47778	10760	18682	6
47779	10760	18683	3
47780	10761	18684	4
47781	10761	18685	11
47782	10761	18637	8
47783	10761	18686	5
47784	10761	18667	5
47785	10762	18668	5
47786	10762	18669	5
47787	10762	18665	5
47788	10762	18670	6
47789	10762	18667	2
47790	10763	18687	4
47791	10763	18688	4
47792	10763	18689	7
47793	10763	18690	2
47794	10763	18691	1
47795	10764	18692	3
47796	10764	18693	3
47797	10764	18669	7
47798	10764	18694	3
47799	10764	18652	3
47800	10765	18695	1
47801	10765	18696	7
47802	10765	18697	4
47803	10765	18698	2
47804	10765	18683	2
47805	10766	18699	3
47806	10767	18700	12
47807	10768	18701	3
47808	10768	18702	9
47809	10769	18703	4
47810	10770	18704	5
47811	10771	18705	6
47812	10771	18706	5
47813	10772	18702	11
47814	10773	18707	4
47815	10773	18708	6
47816	10774	18709	4
47817	10775	18710	3
47818	10776	18711	9
47819	10777	18712	3
47820	10778	18713	5
47821	10779	18714	6
47822	10779	18715	11
47823	10779	18716	7
47824	10779	18717	8
47825	10779	18718	2
47826	10779	18719	9
47827	10780	18720	13
47828	10780	18721	14
47829	10780	18722	13
47830	10780	18723	14
47831	10780	18724	9
47832	10780	18725	9
47833	10780	18726	11
47834	10781	18727	4
47835	10781	18728	6
47836	10781	18729	1
47837	10781	18730	4
47838	10781	18731	1
47839	10782	18732	6
47840	10782	18733	3
47841	10782	18734	11
47842	10782	18735	6
47843	10782	18736	7
47844	10783	18737	5
47845	10783	18738	7
47846	10783	18716	6
47847	10783	18739	3
47848	10783	18740	3
47849	10784	18741	2
47850	10784	18742	9
47851	10784	18743	11
47852	10784	18744	5
47853	10784	18745	6
47854	10785	18746	7
47855	10785	18747	11
47856	10785	18744	3
47857	10785	18748	2
47858	10785	18745	8
47859	10786	18749	8
47860	10786	18750	7
47861	10786	18751	5
47862	10786	18752	2
47863	10787	18753	5
47864	10787	18754	4
47865	10787	18743	8
47866	10787	18752	4
47867	10787	18755	11
47868	10787	18745	6
47869	10788	18756	7
47870	10788	18755	11
47871	10788	18722	7
47872	10788	18744	7
47873	10788	18757	7
47874	10788	18717	6
47875	10789	18758	3
47876	10789	18746	8
47877	10789	18755	8
47878	10789	18744	4
47879	10789	18748	2
47880	10790	18759	12
47881	10790	18760	9
47882	10790	18761	7
47883	10790	18762	6
47884	10790	18763	2
47885	10791	18764	2
47886	10791	18765	4
47887	10791	18766	7
47888	10791	18767	2
47889	10791	18768	7
47890	10792	18769	8
47891	10792	18762	5
47892	10792	18770	4
47893	10792	18771	4
47894	10792	18763	3
47895	10793	18772	9
47896	10793	18769	9
47897	10793	18762	6
47898	10793	18773	8
47899	10793	18774	13
47900	10794	18775	6
47901	10794	18776	9
47902	10794	18762	9
47903	10794	18777	4
47904	10794	18763	7
47905	10795	18778	4
47906	10795	18779	9
47907	10795	18780	9
47908	10795	18763	8
47909	10796	18781	6
47910	10796	18760	10
47911	10796	18762	11
47912	10796	18782	6
47913	10797	18783	3
47914	10797	18784	2
47915	10797	18779	9
47916	10797	18780	7
47917	10797	18763	6
47918	10798	18785	5
47919	10798	18786	7
47920	10798	18787	7
47921	10798	18762	6
47922	10798	18763	7
47923	10799	18788	5
47924	10799	18789	11
47925	10799	18780	9
47926	10799	18790	6
47927	10799	18763	1
47928	10800	18791	8
47929	10800	18761	6
47930	10800	18780	6
47931	10800	18792	9
47932	10800	18793	8
47933	10801	18794	3
47934	10801	18795	7
47935	10801	18796	7
47936	10801	18797	6
47937	10801	18774	2
47938	10802	18798	3
47939	10802	18799	6
47940	10802	18800	9
47941	10802	18801	2
47942	10802	18802	3
47943	10803	18803	4
47944	10803	18804	7
47945	10803	18805	2
47946	10803	18806	5
47947	10803	18767	1
47948	10804	18807	4
47949	10804	18765	6
47950	10804	18808	6
47951	10804	18809	7
47952	10804	18810	6
47953	10805	18811	2
47954	10805	18812	9
47955	10805	18813	3
47956	10805	18814	3
47957	10805	18815	6
47958	10806	18816	7
47959	10806	18817	6
47960	10806	18818	8
47961	10806	18819	11
47962	10806	18810	6
47963	10807	18798	3
47964	10807	18799	9
47965	10807	18800	5
47966	10807	18801	9
47967	10807	18802	8
47968	10808	18820	6
47969	10808	18821	6
47970	10808	18822	4
47971	10808	18823	2
47972	10808	18810	6
47973	10809	18824	7
47974	10809	18765	5
47975	10809	18818	5
47976	10809	18825	9
47977	10809	18810	1
47978	10810	18798	3
47979	10810	18799	7
47980	10810	18800	6
47981	10810	18801	3
47982	10810	18802	6
47983	10811	18826	8
47984	10811	18799	8
47985	10811	18821	8
47986	10811	18801	9
47987	10811	18802	9
47988	10812	18827	4
47989	10812	18812	6
47990	10812	18828	5
47991	10812	18829	4
47992	10812	18815	5
47993	10813	18830	8
47994	10813	18831	11
47995	10813	18832	3
47996	10813	18833	8
47997	10813	18834	7
47998	10814	18835	6
47999	10814	18812	9
48000	10814	18836	5
48001	10814	18837	10
48002	10814	18815	7
48003	10815	18798	4
48004	10815	18799	6
48005	10815	18800	8
48006	10815	18801	3
48007	10815	18802	6
48008	10816	18838	6
48009	10816	18821	5
48010	10816	18839	5
48011	10816	18840	4
48012	10816	18841	1
48013	10817	18842	4
48014	10817	18843	6
48015	10817	18813	4
48016	10817	18844	2
48017	10817	18767	1
48018	10818	18845	6
48019	10818	18846	7
48020	10818	18847	6
48021	10818	18848	2
48022	10818	18810	6
48023	10819	18849	5
48024	10819	18776	4
48025	10819	18804	7
48026	10819	18850	7
48027	10819	18834	1
48028	10820	18851	3
48029	10820	18852	9
48030	10820	18853	8
48031	10820	18854	4
48032	10820	18767	1
48033	10821	18855	6
48034	10821	18856	5
48035	10821	18857	4
48036	10821	18858	6
48037	10821	18810	5
48038	10822	18859	5
48039	10822	18860	11
48040	10822	18861	4
48041	10822	18862	12
48042	10822	18810	5
48043	10823	18838	7
48044	10823	18821	8
48045	10823	18839	7
48046	10823	18840	3
48047	10823	18841	4
48048	10824	18863	6
48049	10824	18852	10
48050	10824	18864	8
48051	10824	18854	3
48052	10824	18767	11
48053	10825	18845	5
48054	10825	18846	8
48055	10825	18847	5
48056	10825	18848	1
48057	10825	18834	5
48058	10826	18838	6
48059	10826	18821	4
48060	10826	18839	8
48061	10826	18840	4
48062	10826	18841	1
48063	10827	18865	4
48064	10827	18812	7
48065	10827	18850	4
48066	10827	18866	8
48067	10827	18815	6
48068	10828	18867	7
48069	10828	18868	9
48070	10828	18836	5
48071	10828	18823	2
48072	10828	18834	6
48073	10829	18869	4
48074	10829	18812	8
48075	10829	18850	5
48076	10829	18866	9
48077	10829	18815	8
48078	10830	18870	3
48079	10830	18812	4
48080	10830	18871	9
48081	10830	18872	4
48082	10830	18815	3
48083	10831	18873	12
48084	10831	18812	1
48085	10831	18874	8
48086	10831	18866	7
48087	10831	18815	5
48088	10832	18838	4
48089	10832	18821	9
48090	10832	18839	9
48091	10832	18840	4
48092	10832	18841	5
48093	10833	18875	1
48094	10833	18876	3
48095	10833	18877	8
48096	10833	18878	3
48097	10833	18879	4
48098	10834	18880	5
48099	10834	18881	5
48100	10834	18882	2
48101	10834	18883	7
48102	10834	18879	5
48103	10835	18884	1
48104	10835	18885	2
48105	10835	18877	11
48106	10835	18886	1
48107	10835	18879	11
48108	10836	18887	8
48109	10836	18888	12
48110	10836	18889	8
48111	10836	18890	10
48112	10836	18891	7
48113	10837	18892	5
48114	10837	18893	6
48115	10837	18894	12
48116	10837	18895	3
48117	10837	18896	12
48118	10837	18897	3
48119	10838	18887	6
48120	10838	18898	14
48121	10838	18899	4
48122	10838	18900	7
48123	10838	18894	9
48124	10838	18901	12
48125	10838	18902	11
48126	10839	18903	7
48127	10839	18904	5
48128	10839	18905	2
48129	10839	18906	2
48130	10839	18901	3
48131	10839	18907	12
48132	10839	18908	7
48133	10840	18889	7
48134	10840	18909	8
48135	10840	18910	5
48136	10840	18911	8
48137	10840	18912	6
48138	10841	18913	2
48139	10841	18914	11
48140	10841	18915	6
48141	10841	18911	8
48142	10841	18916	6
48143	10841	18917	2
48144	10842	18918	7
48145	10842	18919	8
48146	10842	18910	7
48147	10842	18915	7
48148	10842	18920	9
48149	10843	18921	6
48150	10843	18922	6
48151	10843	18923	11
48152	10843	18924	8
48153	10843	18925	12
48154	10843	18926	5
48155	10844	18927	9
48156	10844	18928	13
48157	10844	18929	7
48158	10844	18930	7
48159	10844	18931	3
48160	10844	18932	6
48161	10845	18931	5
48162	10845	18933	11
48163	10845	18910	1
48164	10845	18925	7
48165	10845	18932	5
48166	10846	18934	4
48167	10846	18900	12
48168	10846	18920	5
48169	10846	18895	6
48170	10846	18935	3
48171	10846	18936	12
48172	10846	18937	11
48173	10847	18914	11
48174	10847	18938	8
48175	10847	18900	5
48176	10847	18911	9
48177	10847	18939	5
48178	10848	18940	12
48179	10848	18941	11
48180	10848	18942	8
48181	10848	18943	1
48182	10848	18938	7
48183	10848	18944	5
48184	10849	18945	8
48185	10849	18946	7
48186	10849	18947	9
48187	10849	18948	6
48188	10849	18949	7
48189	10850	18889	7
48190	10850	18930	8
48191	10850	18950	6
48192	10850	18951	3
48193	10850	18952	6
48194	10850	18910	8
48195	10851	18953	10
48196	10851	18950	8
48197	10851	18954	5
48198	10851	18910	11
48199	10851	18932	9
48200	10852	18955	8
48201	10852	18956	13
48202	10852	18957	13
48203	10852	18958	6
48204	10852	18910	9
48205	10853	18959	2
48206	10853	18960	9
48207	10853	18889	8
48208	10853	18961	9
48209	10853	18962	6
48210	10853	18963	13
48211	10854	18964	6
48212	10854	18965	4
48213	10854	18966	7
48214	10854	18967	5
48215	10854	18924	3
48216	10855	18968	4
48217	10855	18929	9
48218	10855	18969	11
48219	10855	18938	13
48220	10855	18970	12
48221	10856	18929	6
48222	10856	18971	11
48223	10856	18972	9
48224	10856	18973	5
48225	10856	18963	7
48226	10857	18974	5
48227	10857	18975	9
48228	10857	18965	11
48229	10857	18950	11
48230	10857	18910	5
48231	10858	18976	4
48232	10858	18977	5
48233	10858	18978	9
48234	10858	18979	1
48235	10858	18924	13
48236	10858	18937	8
48237	10859	18980	3
48238	10859	18981	9
48239	10859	18982	5
48240	10859	18983	5
48241	10859	18984	6
48242	10860	18985	2
48243	10860	18889	6
48244	10860	18971	8
48245	10860	18986	6
48246	10860	18910	9
48247	10860	18987	3
48248	10861	18988	4
48249	10861	18989	5
48250	10861	18990	6
48251	10861	18991	7
48252	10861	18992	3
48253	10862	18993	4
48254	10862	18994	5
48255	10862	18995	2
48256	10862	18996	3
48257	10862	18997	2
48258	10863	18998	6
48259	10863	18999	9
48260	10863	19000	6
48261	10863	19001	9
48262	10863	19002	6
48263	10864	19003	2
48264	10864	19004	11
48265	10864	18922	8
48266	10864	19005	1
48267	10864	18949	5
48268	10865	19006	5
48269	10865	19007	7
48270	10865	19008	8
48271	10865	19009	4
48272	10865	18997	7
48273	10866	19010	7
48274	10866	19011	5
48275	10866	18990	10
48276	10866	19012	2
48277	10866	19013	9
48278	10867	19014	12
48279	10867	19015	9
48280	10867	19016	2
48281	10867	19017	3
48282	10867	18891	3
48283	10868	19018	5
48284	10868	19019	6
48285	10868	19020	7
48286	10868	19021	5
48287	10868	19013	1
48288	10869	19022	5
48289	10869	18988	4
48290	10869	18999	8
48291	10869	19023	2
48292	10869	19013	7
48293	10870	19024	9
48294	10870	19019	7
48295	10870	19025	8
48296	10870	19026	13
48297	10870	19027	9
48298	10871	19028	4
48299	10871	18981	6
48300	10871	18922	7
48301	10871	19029	8
48302	10871	18949	5
48303	10872	19030	3
48304	10872	19031	8
48305	10872	18893	6
48306	10872	18943	2
48307	10872	19002	10
48308	10873	19028	5
48309	10873	19032	10
48310	10873	19033	11
48311	10873	19034	8
48312	10873	18949	5
48313	10874	19035	6
48314	10874	18990	7
48315	10874	19036	2
48316	10874	18979	3
48317	10874	19013	6
48318	10875	19037	8
48319	10875	19038	3
48320	10875	19039	8
48321	10875	19040	5
48322	10875	18997	1
48323	10876	19041	2
48324	10876	19042	6
48325	10876	19001	4
48326	10876	19043	4
48327	10876	19027	6
48328	10877	19044	5
48329	10877	19045	8
48330	10877	19046	7
48331	10877	19012	2
48332	10877	18997	3
48333	10878	19047	8
48334	10878	19008	9
48335	10878	19048	5
48336	10878	19049	2
48337	10878	18949	4
48338	10879	19050	7
48339	10879	19051	11
48340	10879	19052	6
48341	10879	18899	6
48342	10879	19043	8
48343	10880	19053	8
48344	10880	19054	10
48345	10880	19019	3
48346	10880	19055	2
48347	10880	19056	6
48348	10880	19043	8
48349	10881	19057	2
48350	10881	19058	7
48351	10881	19059	5
48352	10881	18982	4
48353	10881	19002	3
48354	10882	19060	5
48355	10882	19038	3
48356	10882	19042	8
48357	10882	19061	6
48358	10882	18949	7
48359	10883	19062	4
48360	10883	19063	13
48361	10883	19059	4
48362	10883	19064	1
48363	10883	18992	2
48364	10884	19044	5
48365	10884	19065	9
48366	10884	19046	7
48367	10884	19012	2
48368	10884	19017	9
48369	10885	19066	4
48370	10885	19038	4
48371	10885	19004	9
48372	10885	19067	5
48373	10885	18997	1
48374	10886	19068	2
48375	10886	19069	6
48376	10886	19070	4
48377	10886	18899	6
48378	10886	18949	5
48379	10887	19071	3
48380	10887	19072	9
48381	10887	19073	4
48382	10887	19061	4
48383	10887	19017	6
48384	10888	19074	5
48385	10888	19032	9
48386	10888	19033	8
48387	10888	19075	7
48388	10888	18949	7
48389	10889	19076	4
48390	10889	19045	3
48391	10889	18922	8
48392	10889	19049	5
48393	10889	19002	3
48394	10890	19077	7
48395	10890	18990	6
48396	10890	19000	7
48397	10890	19078	12
48398	10890	18949	9
48399	10891	19079	3
48400	10891	19080	4
48401	10891	19081	11
48402	10891	19082	7
48403	10891	19013	8
48404	10892	19018	5
48405	10892	18990	7
48406	10892	19067	7
48407	10892	19083	5
48408	10892	19043	8
48409	10893	18985	3
48410	10893	19063	7
48411	10893	19084	11
48412	10893	19085	2
48413	10893	18997	4
48414	10894	19086	2
48415	10894	19087	8
48416	10894	19088	4
48417	10894	19089	5
48418	10894	18984	8
48419	10895	19090	8
48420	10896	19091	4
48421	10896	19092	6
48422	10897	19093	2
48423	10898	19094	2
48424	10899	19095	4
48425	10900	19096	3
48426	10900	19097	5
48427	10900	19098	9
48428	10901	19099	3
48429	10901	19100	6
48430	10902	19101	6
48431	10903	19102	8
48432	10904	19103	8
48433	10905	19104	1
48434	10906	19105	9
48435	10907	19106	11
48436	10907	19100	7
48437	10908	19107	6
48438	10908	19108	8
48439	10909	19109	9
48440	10910	19110	8
48441	10911	19111	4
48442	10911	19112	2
48443	10912	19113	9
48444	10913	19114	9
48445	10914	19115	8
48446	10915	19116	2
48447	10915	19117	1
48448	10916	19118	3
48449	10917	19119	6
48450	10918	19120	11
48451	10919	19121	9
48452	10919	19122	6
48453	10920	19123	9
48454	10921	19124	3
48455	10921	19112	3
48456	10922	19125	3
48457	10922	19126	4
48458	10923	19120	11
48459	10924	19109	5
48460	10925	19118	9
48461	10926	19127	6
48462	10926	19113	7
48463	10927	19128	1
48464	10928	19129	8
48465	10929	19130	4
48466	10930	19131	12
48467	10930	19132	9
48468	10930	19133	11
48469	10930	19134	11
48470	10930	19135	11
48471	10931	19136	7
48472	10932	19137	13
48473	10932	19138	4
48474	10932	19139	11
48475	10932	19140	9
48476	10932	19132	5
48477	10932	19141	5
48478	10932	19142	2
48479	10933	19143	6
48480	10933	19144	4
48481	10933	19142	12
48482	10934	19145	5
48483	10934	19146	5
48484	10934	19147	14
48485	10934	19132	5
48486	10934	19148	4
48487	10934	19149	4
48488	10934	19150	13
48489	10935	19151	11
48490	10935	19152	9
48491	10935	19141	11
48492	10935	19153	2
48493	10935	19154	12
48494	10936	19138	2
48495	10936	19155	4
48496	10936	19156	13
48497	10936	19157	11
48498	10936	19158	5
48499	10936	19159	8
48500	10937	19160	7
48501	10937	19161	13
48502	10937	19157	9
48503	10937	19132	8
48504	10937	19158	5
48505	10937	19162	6
48506	10938	19163	5
48507	10938	19164	2
48508	10938	19165	2
48509	10938	19166	2
48510	10938	19167	8
48511	10939	19168	6
48512	10939	19169	5
48513	10939	19146	13
48514	10939	19170	14
48515	10939	19171	9
48516	10939	19172	8
48517	10939	19150	10
48518	10940	19173	4
48519	10940	19174	13
48520	10940	19132	8
48521	10940	19133	9
48522	10940	19148	4
48523	10941	19175	3
48524	10941	19146	11
48525	10941	19176	14
48526	10941	19177	8
48527	10941	19157	9
48528	10941	19162	4
48529	10941	19154	7
48530	10941	19135	8
48531	10942	19151	9
48532	10942	19178	3
48533	10942	19148	5
48534	10942	19141	6
48535	10942	19149	5
48536	10942	19150	11
48537	10943	19179	7
48538	10943	19146	11
48539	10943	19170	14
48540	10943	19132	5
48541	10943	19180	5
48542	10943	19158	12
48543	10943	19181	11
48544	10944	19182	6
48545	10944	19183	11
48546	10944	19184	10
48547	10944	19146	8
48548	10944	19176	14
48549	10944	19185	4
48550	10945	19186	4
48551	10945	19184	6
48552	10945	19146	7
48553	10945	19187	14
48554	10945	19188	5
48555	10945	19189	4
48556	10946	19190	4
48557	10946	19146	2
48558	10946	19176	14
48559	10946	19191	9
48560	10946	19180	5
48561	10946	19158	7
48562	10946	19192	11
48563	10946	19150	9
48564	10947	19193	5
48565	10947	19145	6
48566	10947	19146	11
48567	10947	19176	14
48568	10947	19171	9
48569	10947	19172	9
48570	10947	19181	9
48571	10948	19183	13
48572	10948	19184	11
48573	10948	19194	10
48574	10948	19195	9
48575	10948	19196	9
48576	10949	19197	3
48577	10949	19180	4
48578	10949	19153	4
48579	10949	19198	7
48580	10949	19150	11
48581	10950	19199	11
48582	10950	19200	11
48583	10950	19201	2
48584	10950	19202	6
48585	10950	19134	12
48586	10951	19203	8
48587	10951	19171	6
48588	10951	19172	9
48589	10951	19153	4
48590	10951	19204	4
48591	10951	19150	11
48592	10952	19205	13
48593	10952	19146	11
48594	10952	19170	14
48595	10952	19132	8
48596	10952	19180	3
48597	10952	19158	5
48598	10952	19181	8
48599	10953	19184	10
48600	10953	19146	11
48601	10953	19187	14
48602	10953	19132	6
48603	10953	19133	6
48604	10953	19148	5
48605	10953	19181	11
48606	10954	19206	6
48607	10954	19207	8
48608	10954	19146	5
48609	10954	19176	14
48610	10954	19171	3
48611	10954	19133	4
48612	10955	19208	2
48613	10955	19209	5
48614	10955	19210	11
48615	10955	19211	8
48616	10955	19166	4
48617	10956	19212	5
48618	10956	19146	6
48619	10956	19147	14
48620	10956	19132	3
48621	10956	19195	2
48622	10956	19158	6
48623	10956	19181	8
48624	10957	19213	4
48625	10957	19214	4
48626	10957	19215	11
48627	10957	19216	9
48628	10957	19217	4
48629	10958	19218	4
48630	10958	19219	3
48631	10958	19220	9
48632	10958	19221	9
48633	10958	19217	8
48634	10959	19222	3
48635	10959	19223	7
48636	10959	19224	8
48637	10959	19166	2
48638	10960	19225	2
48639	10960	19226	9
48640	10960	19227	3
48641	10960	19228	11
48642	10961	19229	5
48643	10961	19230	5
48644	10961	19231	5
48645	10961	19232	5
48646	10961	19185	2
48647	10962	19233	2
48648	10962	19234	9
48649	10962	19227	7
48650	10962	19235	7
48651	10962	19236	7
48652	10963	19237	3
48653	10963	19238	2
48654	10963	19215	7
48655	10963	19239	7
48656	10963	19217	5
48657	10964	19240	1
48658	10964	19241	9
48659	10964	19242	7
48660	10964	19243	3
48661	10964	19236	5
48662	10965	19244	11
48663	10965	19245	8
48664	10965	19246	2
48665	10965	19247	6
48666	10966	19248	5
48667	10966	19249	9
48668	10966	19250	11
48669	10966	19235	9
48670	10967	19251	3
48671	10967	19252	9
48672	10967	19253	7
48673	10967	19254	3
48674	10967	19185	7
48675	10968	19238	3
48676	10968	19255	3
48677	10968	19215	7
48678	10968	19256	8
48679	10968	19257	13
48680	10969	19238	3
48681	10969	19258	3
48682	10969	19231	7
48683	10969	19259	1
48684	10969	19257	9
48685	10970	19260	4
48686	10970	19223	7
48687	10970	19261	7
48688	10970	19185	1
48689	10971	19262	8
48690	10971	19263	9
48691	10971	19264	7
48692	10971	19265	3
48693	10971	19217	6
48694	10972	19266	11
48695	10972	19267	9
48696	10972	19268	8
48697	10972	19269	7
48698	10972	19247	3
48699	10973	19270	2
48700	10973	19271	7
48701	10973	19272	11
48702	10973	19273	3
48703	10973	19166	5
48704	10974	19274	12
48705	10974	19215	8
48706	10974	19256	9
48707	10974	19257	6
48708	10975	19275	2
48709	10975	19276	1
48710	10975	19226	13
48711	10975	19277	7
48712	10975	19166	3
48713	10976	19278	1
48714	10976	19279	7
48715	10976	19242	6
48716	10976	19280	5
48717	10976	19236	7
48718	10977	19281	5
48719	10977	19282	5
48720	10977	19283	9
48721	10977	19224	9
48722	10977	19166	2
48723	10978	19284	7
48724	10978	19285	9
48725	10978	19245	5
48726	10978	19247	9
48727	10979	19230	5
48728	10979	19286	9
48729	10979	19287	1
48730	10979	19288	5
48731	10979	19201	4
48732	10980	19289	2
48733	10980	19290	3
48734	10980	19291	3
48735	10980	19201	2
48736	10980	19171	4
48737	10981	19292	2
48738	10981	19293	5
48739	10981	19294	5
48740	10981	19185	4
48741	10981	19295	3
48742	10982	19296	3
48743	10982	19297	3
48744	10982	19298	8
48745	10982	19245	7
48746	10982	19236	9
48747	10983	19297	4
48748	10983	19299	9
48749	10983	19227	7
48750	10983	19300	8
48751	10983	19247	7
48752	10984	19301	4
48753	10984	19302	8
48754	10984	19303	9
48755	10984	19247	5
48756	10985	19230	11
48757	10985	19267	11
48758	10985	19304	12
48759	10985	19247	12
48760	10985	19171	11
48761	10986	19305	3
48762	10986	19293	7
48763	10986	19239	9
48764	10986	19306	5
48765	10986	19201	3
48766	10987	19307	4
48767	10987	19226	9
48768	10987	19227	5
48769	10987	19188	3
48770	10988	19308	3
48771	10988	19241	9
48772	10988	19309	6
48773	10988	19185	7
48774	10989	19310	2
48775	10989	19307	4
48776	10989	19226	8
48777	10989	19227	6
48778	10989	19188	4
48779	10990	19311	4
48780	10990	19298	9
48781	10990	19242	6
48782	10990	19306	2
48783	10990	19166	6
48784	10991	19296	3
48785	10991	19279	9
48786	10991	19227	9
48787	10991	19312	4
48788	10991	19236	8
48789	10992	19313	3
48790	10992	19314	9
48791	10992	19245	7
48792	10992	19315	1
48793	10992	19185	5
48794	10992	19171	6
48795	10993	19278	1
48796	10993	19279	9
48797	10993	19242	6
48798	10993	19280	6
48799	10993	19236	8
48800	10994	19316	6
48801	10994	19230	8
48802	10994	19317	7
48803	10994	19318	5
48804	10994	19201	2
48805	10995	19319	5
48806	10995	19320	11
48807	10995	19321	8
48808	10995	19322	4
48809	10995	19236	9
48810	10996	19238	2
48811	10996	19323	2
48812	10996	19324	6
48813	10996	19286	7
48814	10996	19166	3
48815	10997	19325	4
48816	10997	19326	4
48817	10997	19183	11
48818	10997	19327	8
48819	10997	19201	6
48820	10998	19328	7
48821	10998	19329	10
48822	10998	19277	8
48823	10998	19330	7
48824	10998	19185	7
48825	10999	19331	3
48826	10999	19298	13
48827	10999	19286	9
48828	10999	19273	3
48829	10999	19185	8
48830	11000	19332	4
48831	11000	19333	3
48832	11000	19320	7
48833	11000	19334	9
48834	11000	19268	8
48835	11000	19185	8
48836	11001	19335	7
48837	11001	19336	9
48838	11001	19337	12
48839	11001	19185	7
48840	11001	19338	4
48841	11002	19249	9
48842	11002	19245	9
48843	11002	19339	5
48844	11002	19166	9
48845	11003	19340	5
48846	11003	19341	1
48847	11003	19268	4
48848	11003	19342	7
48849	11003	19343	1
48850	11004	19344	5
48851	11004	19341	2
48852	11004	19345	3
48853	11004	19300	6
48854	11004	19343	3
48855	11005	19346	4
48856	11005	19347	8
48857	11005	19348	6
48858	11005	19349	1
48859	11005	19350	3
48860	11006	19351	5
48861	11006	19352	7
48862	11006	19353	5
48863	11006	19318	3
48864	11006	19354	9
48865	11007	19355	5
48866	11007	19356	4
48867	11007	19357	1
48868	11007	19358	1
48869	11007	19359	4
48870	11008	19360	4
48871	11008	19361	6
48872	11008	19362	7
48873	11008	19363	2
48874	11008	19354	3
48875	11009	19364	6
48876	11009	19365	8
48877	11009	19362	6
48878	11009	19366	3
48879	11009	19367	11
48880	11010	19206	5
48881	11010	19368	5
48882	11010	19369	5
48883	11010	19370	8
48884	11010	19354	8
48885	11011	19371	3
48886	11011	19372	6
48887	11011	19373	2
48888	11011	19374	1
48889	11011	19375	8
48890	11012	19346	3
48891	11012	19347	4
48892	11012	19348	4
48893	11012	19349	1
48894	11012	19350	2
48895	11013	19206	4
48896	11013	19376	2
48897	11013	19352	8
48898	11013	19377	1
48899	11013	19354	1
48900	11014	19378	3
48901	11014	19379	6
48902	11014	19356	8
48903	11014	19380	1
48904	11014	19359	7
48905	11015	19346	3
48906	11015	19347	5
48907	11015	19348	11
48908	11015	19349	6
48909	11015	19350	8
48910	11016	19364	5
48911	11016	19365	7
48912	11016	19362	7
48913	11016	19366	2
48914	11016	19367	7
48915	11017	19346	3
48916	11017	19347	6
48917	11017	19348	6
48918	11017	19349	1
48919	11017	19350	1
48920	11018	19364	5
48921	11018	19365	1
48922	11018	19362	4
48923	11018	19366	3
48924	11018	19367	1
48925	11019	19371	4
48926	11019	19372	3
48927	11019	19373	3
48928	11019	19374	3
48929	11019	19375	1
48930	11020	19381	4
48931	11020	19356	11
48932	11020	19357	6
48933	11020	19382	5
48934	11020	19359	8
48935	11021	19383	2
48936	11021	19384	5
48937	11021	19356	7
48938	11021	19359	5
48939	11021	19385	3
48940	11022	19313	1
48941	11022	19386	5
48942	11022	19387	1
48943	11022	19388	8
48944	11022	19188	4
48945	11023	19389	5
48946	11023	19390	6
48947	11023	19362	6
48948	11023	19391	2
48949	11023	19188	4
48950	11024	19392	6
48951	11024	19393	1
48952	11024	19394	2
48953	11024	19188	3
48954	11024	19395	3
48955	11025	19364	6
48956	11025	19365	8
48957	11025	19362	7
48958	11025	19366	3
48959	11025	19367	11
48960	11026	19364	6
48961	11026	19365	5
48962	11026	19362	7
48963	11026	19366	5
48964	11026	19367	7
48965	11027	19396	3
48966	11027	19341	2
48967	11027	19345	2
48968	11027	19397	5
48969	11027	19343	3
48970	11028	19371	4
48971	11028	19372	4
48972	11028	19373	1
48973	11028	19374	1
48974	11028	19375	7
48975	11029	19371	3
48976	11029	19372	5
48977	11029	19373	3
48978	11029	19374	2
48979	11029	19375	4
48980	11030	19398	7
48981	11030	19399	8
48982	11030	19353	4
48983	11030	19400	4
48984	11030	19354	8
48985	11031	19401	4
48986	11031	19341	3
48987	11031	19394	3
48988	11031	19402	8
48989	11031	19343	5
48990	11032	19364	5
48991	11032	19365	8
48992	11032	19362	4
48993	11032	19366	4
48994	11032	19367	9
48995	11033	19403	3
48996	11033	19384	5
48997	11033	19356	11
48998	11033	19404	6
48999	11033	19359	8
49000	11034	19405	5
49001	11034	19356	4
49002	11034	19268	7
49003	11034	19406	1
49004	11034	19359	4
49005	11035	19340	5
49006	11035	19341	1
49007	11035	19235	4
49008	11035	19407	1
49009	11035	19343	2
49010	11036	19408	5
49011	11036	19356	5
49012	11036	19357	2
49013	11036	19388	6
49014	11036	19359	5
49015	11037	19340	4
49016	11037	19341	4
49017	11037	19409	2
49018	11037	19410	2
49019	11037	19343	3
49020	11038	19411	3
49021	11038	19341	6
49022	11038	19387	7
49023	11038	19412	1
49024	11038	19343	3
49025	11039	19413	4
49026	11039	19356	11
49027	11039	19409	2
49028	11039	19414	5
49029	11039	19359	5
49030	11040	19415	6
49031	11040	19376	6
49032	11040	19416	9
49033	11040	19417	5
49034	11040	19354	9
49035	11041	19364	6
49036	11041	19365	8
49037	11041	19362	6
49038	11041	19366	5
49039	11041	19367	2
49045	11043	19355	5
49046	11043	19356	7
49047	11043	19235	7
49048	11043	19404	5
49049	11043	19359	4
49050	11044	19398	7
49051	11044	19418	1
49052	11044	19369	4
49053	11044	19419	3
49054	11044	19359	5
49055	11045	19346	3
49056	11045	19347	4
49057	11045	19348	5
49058	11045	19349	1
49059	11045	19350	1
49060	11046	19364	5
49061	11046	19365	8
49062	11046	19362	8
49063	11046	19366	6
49064	11046	19367	5
49065	11047	19420	3
49066	11047	19421	3
49067	11047	19341	4
49068	11047	19387	2
49069	11047	19343	2
49070	11048	19371	4
49071	11048	19372	6
49072	11048	19373	3
49073	11048	19374	1
49074	11048	19375	1
49075	11049	19422	5
49076	11049	19423	7
49077	11049	19373	1
49078	11049	19424	5
49079	11049	19354	9
49080	11050	19346	4
49081	11050	19347	5
49082	11050	19348	2
49083	11050	19349	2
49084	11050	19350	3
49085	11051	19371	2
49086	11051	19372	4
49087	11051	19373	1
49088	11051	19374	1
49089	11051	19375	1
49090	11052	19351	5
49091	11052	19376	4
49092	11052	19352	9
49093	11052	19425	6
49094	11052	19354	5
49095	11053	19426	3
49096	11053	19376	7
49097	11053	19427	8
49098	11053	19306	2
49099	11053	19354	7
49100	11054	19346	2
49101	11054	19347	4
49102	11054	19348	5
49103	11054	19349	1
49104	11054	19350	1
49105	11055	19346	4
49106	11055	19347	5
49107	11055	19348	9
49108	11055	19349	2
49109	11055	19350	2
49110	11056	19346	3
49111	11056	19347	5
49112	11056	19348	6
49113	11056	19349	2
49114	11056	19350	3
49115	11057	19428	3
49116	11057	19341	2
49117	11057	19394	5
49118	11057	19429	1
49119	11057	19343	3
49120	11058	19364	7
49121	11058	19365	6
49122	11058	19362	7
49123	11058	19366	6
49124	11058	19367	6
49125	11059	19403	9
49126	11059	19356	6
49127	11059	19268	3
49128	11059	19402	9
49129	11059	19359	1
49130	11060	19392	5
49131	11060	19418	1
49132	11060	19362	1
49133	11060	19402	1
49134	11060	19359	1
49135	11061	19430	4
49136	11061	19356	1
49137	11061	19339	2
49138	11061	19431	1
49139	11061	19359	3
49140	11062	19383	3
49141	11062	19356	1
49142	11062	19357	4
49143	11062	19431	2
49144	11062	19359	1
49145	11063	19401	4
49146	11063	19432	4
49147	11063	19356	6
49148	11063	19339	3
49149	11063	19359	1
49150	11064	19430	4
49151	11064	19433	5
49152	11064	19341	4
49153	11064	19434	4
49154	11064	19343	5
49155	11065	19435	4
49156	11065	19386	9
49157	11065	19339	4
49158	11065	19436	5
49159	11065	19354	1
49160	11066	19437	5
49161	11066	19341	1
49162	11066	19268	2
49163	11066	19438	2
49164	11066	19343	3
49165	11067	19168	5
49166	11067	19439	6
49167	11067	19268	6
49168	11067	19440	5
49169	11067	19354	8
49170	11068	19371	3
49171	11068	19372	3
49172	11068	19373	1
49173	11068	19374	1
49174	11068	19375	1
49175	11069	19364	6
49176	11069	19365	6
49177	11069	19362	5
49178	11069	19366	3
49179	11069	19367	6
49180	11070	19441	8
49181	11070	19356	5
49182	11070	19357	2
49183	11070	19402	10
49184	11070	19359	6
49190	11072	19364	6
49191	11072	19365	11
49192	11072	19362	8
49193	11072	19366	6
49194	11072	19367	7
49195	11073	19442	5
49196	11073	19347	3
49197	11073	19443	2
49198	11073	19444	1
49199	11073	19354	1
49200	11074	19346	3
49201	11074	19347	7
49202	11074	19348	9
49203	11074	19349	1
49204	11074	19350	4
49205	11075	19392	5
49206	11075	19341	3
49207	11075	19445	2
49208	11075	19343	4
49209	11075	19446	3
49210	11076	19447	3
49211	11076	19347	6
49212	11076	19348	3
49213	11076	19349	2
49214	11076	19350	2
49215	11077	19346	5
49216	11077	19347	4
49217	11077	19348	2
49218	11077	19349	1
49186	11071	19365	11
49187	11071	19362	11
49188	11071	19366	11
49189	11071	19367	11
49040	11042	19364	11
49041	11042	19365	11
49042	11042	19362	11
49044	11042	19367	11
49219	11077	19350	1
49220	11078	19346	4
49221	11078	19347	6
49222	11078	19348	8
49223	11078	19349	2
49224	11078	19350	4
49225	11079	19346	4
49226	11079	19347	7
49227	11079	19348	8
49228	11079	19349	2
49229	11079	19350	5
49230	11080	19403	5
49231	11080	19356	6
49232	11080	19373	1
49233	11080	19448	1
49234	11080	19359	5
49235	11081	19371	3
49236	11081	19372	9
49237	11081	19373	2
49238	11081	19374	1
49239	11081	19375	5
49240	11082	19421	6
49241	11082	19356	6
49242	11082	19449	6
49243	11082	19359	6
49244	11082	19198	8
49245	11083	19371	4
49246	11083	19372	6
49247	11083	19373	2
49248	11083	19374	2
49249	11083	19375	8
49250	11084	19346	5
49251	11084	19347	8
49252	11084	19348	8
49253	11084	19349	4
49254	11084	19350	1
49255	11085	19346	4
49256	11085	19347	8
49257	11085	19348	9
49258	11085	19349	3
49259	11085	19350	8
49260	11086	19371	3
49261	11086	19372	7
49262	11086	19373	3
49263	11086	19374	1
49264	11086	19375	3
49265	11087	19364	6
49266	11087	19365	7
49267	11087	19362	6
49268	11087	19366	3
49269	11087	19367	2
49270	11088	19351	4
49271	11088	19450	11
49272	11088	19362	6
49273	11088	19419	4
49274	11088	19354	1
49275	11089	19364	4
49276	11089	19365	9
49277	11089	19362	7
49278	11089	19366	6
49279	11089	19367	4
49280	11090	19371	5
49281	11090	19372	9
49282	11090	19373	4
49283	11090	19374	1
49284	11090	19375	9
49285	11091	19451	4
49286	11091	19452	5
49287	11091	19356	6
49288	11091	19453	1
49289	11091	19359	4
49290	11092	19378	4
49291	11092	19356	8
49292	11092	19373	3
49293	11092	19454	9
49294	11092	19359	6
49295	11093	19371	3
49296	11093	19372	9
49297	11093	19373	1
49298	11093	19374	3
49299	11093	19375	4
49300	11094	19346	3
49301	11094	19347	6
49302	11094	19348	7
49303	11094	19349	4
49304	11094	19350	5
49305	11095	19364	7
49306	11095	19365	9
49307	11095	19362	7
49308	11095	19366	6
49309	11095	19367	10
49310	11096	19455	5
49311	11096	19361	4
49312	11096	19400	2
49313	11096	19217	4
49314	11096	19204	2
49315	11097	19213	3
49316	11097	19209	6
49317	11097	19456	7
49318	11097	19217	5
49319	11097	19198	6
49320	11098	19237	1
49321	11098	19439	5
49322	11098	19369	5
49323	11098	19153	2
49324	11098	19217	1
49325	11099	19457	11
49326	11099	19458	10
49327	11099	19459	7
49328	11099	19460	11
49329	11099	19461	9
49330	11099	19462	1
49331	11100	19463	6
49332	11100	19464	4
49333	11100	19465	3
49334	11100	19466	2
49335	11100	19467	3
49336	11100	19468	14
49337	11100	19469	1
49338	11100	19470	11
49339	11101	19471	6
49340	11101	19467	3
49341	11101	19468	14
49342	11101	19459	5
49343	11101	19472	4
49344	11101	19460	2
49345	11101	19473	4
49346	11102	19474	4
49347	11102	19475	3
49348	11102	19467	4
49349	11102	19476	14
49350	11102	19477	9
49351	11103	19478	3
49352	11103	19479	5
49353	11103	19480	2
49354	11103	19481	7
49355	11103	19482	10
49356	11104	19483	7
49357	11104	19469	5
49358	11104	19484	7
49359	11104	19481	7
49360	11104	19485	9
49361	11105	19486	13
49362	11105	19487	4
49363	11105	19488	4
49364	11105	19489	7
49365	11105	19490	9
49366	11105	19491	3
49367	11106	19492	2
49368	11106	19493	7
49369	11106	19484	13
49370	11106	19494	7
49371	11106	19495	3
49372	11107	19496	8
49373	11107	19467	3
49374	11107	19468	14
49375	11107	19493	7
49376	11107	19472	1
49377	11107	19460	1
49378	11107	19473	7
49379	11108	19497	13
49380	11108	19498	8
49381	11108	19499	5
49382	11108	19484	13
49383	11108	19500	5
49384	11108	19501	2
49385	11108	19502	12
49386	11109	19503	9
49387	11109	19467	11
49388	11109	19504	14
49389	11109	19469	5
49390	11109	19481	8
49391	11110	19505	10
49392	11110	19506	6
49393	11110	19493	6
49394	11110	19469	6
49395	11110	19501	2
49396	11110	19472	7
49397	11110	19485	13
49398	11111	19507	7
49399	11111	19508	7
49400	11111	19467	4
49401	11111	19468	14
49402	11111	19459	6
49403	11111	19490	9
49404	11111	19509	8
49405	11112	19510	3
49406	11112	19511	4
49407	11112	19512	3
49408	11112	19467	11
49409	11112	19504	14
49410	11112	19488	7
49411	11112	19513	9
49412	11113	19514	4
49413	11113	19467	5
49414	11113	19476	14
49415	11113	19459	6
49416	11113	19515	4
49417	11113	19516	3
49418	11113	19489	4
49419	11114	19517	9
49420	11114	19518	5
49421	11114	19488	7
49422	11114	19519	7
49423	11114	19484	4
49424	11114	19520	4
49425	11115	19521	12
49426	11115	19522	11
49427	11115	19523	8
49428	11115	19524	9
49429	11115	19525	12
49430	11115	19509	5
49431	11116	19526	2
49432	11116	19527	2
49433	11116	19485	9
49434	11116	19528	6
49435	11116	19529	4
49436	11116	19530	2
49437	11117	19531	7
49438	11117	19532	11
49439	11117	19484	13
49440	11117	19516	13
49441	11117	19525	13
49442	11118	19533	1
49443	11118	19534	2
49444	11118	19535	5
49445	11118	19485	8
49446	11118	19529	3
49447	11119	19496	13
49448	11119	19536	4
49449	11119	19459	5
49450	11119	19537	5
49451	11119	19515	2
49452	11119	19516	7
49453	11120	19538	9
49454	11120	19539	7
49455	11120	19469	3
49456	11120	19472	4
49457	11120	19494	8
49458	11120	19473	7
49459	11121	19540	4
49460	11121	19488	3
49461	11121	19519	9
49462	11121	19484	6
49463	11122	19541	6
49464	11122	19542	9
49465	11122	19543	5
49466	11122	19487	7
49467	11122	19528	11
49468	11123	19544	8
49469	11123	19467	5
49470	11123	19545	14
49471	11123	19519	7
49472	11123	19472	5
49473	11123	19494	6
49474	11123	19546	8
49475	11124	19547	8
49476	11124	19548	7
49477	11124	19523	7
49478	11124	19549	9
49479	11124	19550	9
49480	11125	19551	11
49481	11125	19552	9
49482	11125	19553	3
49483	11125	19554	2
49484	11125	19513	9
49485	11126	19555	8
49486	11126	19556	6
49487	11126	19471	11
49488	11126	19487	8
49489	11126	19557	11
49490	11127	19558	3
49491	11127	19555	9
49492	11127	19559	6
49493	11127	19560	7
49494	11127	19561	3
49495	11127	19562	1
49496	11128	19563	4
49497	11128	19507	8
49498	11128	19564	3
49499	11128	19565	4
49500	11128	19528	5
49501	11128	19520	6
49502	11129	19566	3
49503	11129	19567	8
49504	11129	19568	11
49505	11129	19569	9
49506	11129	19528	7
49507	11129	19557	3
49508	11130	19570	9
49509	11130	19571	9
49510	11130	19572	6
49511	11130	19573	5
49512	11130	19520	11
49513	11131	19542	10
49514	11131	19574	11
49515	11131	19559	8
49516	11131	19575	4
49517	11131	19576	4
49518	11131	19577	11
49519	11132	19578	5
49520	11132	19552	7
49521	11132	19579	5
49522	11132	19577	9
49523	11132	19557	11
49524	11133	19580	10
49525	11133	19581	5
49526	11133	19487	8
49527	11133	19490	11
49528	11133	19509	8
49529	11134	19582	5
49530	11134	19583	11
49531	11134	19564	8
49532	11134	19490	7
49533	11134	19509	6
49534	11135	19570	9
49535	11135	19584	4
49536	11135	19585	2
49537	11135	19573	5
49538	11135	19520	9
49539	11136	19586	8
49540	11136	19587	6
49541	11136	19588	7
49542	11136	19487	5
49543	11136	19589	7
49544	11136	19520	8
49545	11137	19590	8
49546	11137	19591	9
49547	11137	19592	7
49548	11137	19593	7
49549	11137	19490	1
49550	11137	19520	4
49551	11138	19594	5
49552	11138	19595	3
49553	11138	19596	6
49554	11138	19571	8
49555	11138	19597	8
49556	11138	19557	8
49557	11139	19598	13
49558	11139	19599	9
49559	11139	19564	11
49560	11139	19490	7
49561	11139	19509	8
49562	11140	19600	7
49563	11140	19601	9
49564	11140	19542	9
49565	11140	19602	13
49566	11140	19603	8
49567	11140	19604	10
49568	11141	19605	3
49569	11141	19606	8
49570	11141	19607	8
49571	11141	19487	6
49572	11141	19528	7
49573	11141	19520	7
49574	11142	19608	7
49575	11142	19609	9
49576	11142	19487	7
49577	11142	19589	6
49578	11142	19520	11
49579	11143	19610	4
49580	11143	19611	9
49581	11143	19571	10
49582	11143	19612	5
49583	11143	19528	8
49584	11143	19509	6
49585	11144	19613	9
49586	11144	19614	11
49587	11144	19615	6
49588	11144	19495	4
49589	11145	19542	9
49590	11145	19616	11
49591	11145	19564	9
49592	11145	19617	4
49593	11145	19487	9
49594	11145	19528	7
49595	11146	19618	6
49596	11146	19570	10
49597	11146	19619	5
49598	11146	19612	6
49599	11146	19490	9
49600	11147	19542	10
49601	11147	19596	6
49602	11147	19552	11
49603	11147	19538	6
49604	11147	19609	10
49605	11147	19589	8
49606	11148	19620	8
49607	11148	19543	2
49608	11148	19621	4
49609	11148	19622	6
49610	11148	19509	5
49611	11149	19623	2
49612	11149	19624	4
49613	11149	19625	9
49614	11149	19626	7
49615	11150	19627	3
49616	11150	19628	9
49617	11150	19629	1
49618	11150	19577	11
49619	11150	19557	11
49620	11151	19630	5
49621	11151	19555	13
49622	11151	19556	8
49623	11151	19631	3
49624	11151	19589	9
49625	11151	19557	11
49626	11152	19542	9
49627	11152	19632	9
49628	11152	19633	8
49629	11152	19634	6
49630	11152	19577	11
49631	11153	19635	3
49632	11153	19636	5
49633	11153	19608	9
49634	11153	19637	9
49635	11153	19589	11
49636	11153	19557	11
49637	11154	19638	6
49638	11154	19599	9
49639	11154	19639	6
49640	11154	19538	11
49641	11154	19589	9
49642	11155	19640	2
49643	11155	19641	4
49644	11155	19568	13
49645	11155	19642	9
49646	11155	19490	9
49647	11155	19509	6
49648	11156	19628	8
49649	11156	19569	6
49650	11156	19560	4
49651	11156	19643	2
49652	11156	19550	7
49653	11156	19520	6
49654	11157	19644	5
49655	11157	19645	10
49656	11157	19646	11
49657	11157	19647	7
49658	11157	19528	9
49659	11157	19509	7
49660	11158	19648	3
49661	11158	19649	7
49662	11158	19647	5
49663	11158	19573	4
49664	11158	19520	8
49665	11159	19611	9
49666	11159	19647	9
49667	11159	19650	3
49668	11159	19487	8
49669	11159	19589	9
49670	11159	19520	11
49671	11160	19651	4
49672	11160	19616	9
49673	11160	19593	7
49674	11160	19508	6
49675	11160	19589	9
49676	11160	19557	11
49677	11161	19652	8
49678	11161	19484	3
49679	11161	19489	9
49680	11161	19494	9
49681	11161	19491	2
49682	11161	19557	11
49683	11162	19653	6
49684	11162	19654	6
49685	11162	19655	9
49686	11162	19656	4
49687	11162	19577	6
49688	11162	19509	6
49689	11163	19657	5
49690	11163	19658	9
49691	11163	19652	8
49692	11163	19659	4
49693	11163	19528	8
49694	11163	19557	11
49695	11164	19654	6
49696	11164	19552	11
49697	11164	19660	10
49698	11164	19656	4
49699	11164	19589	11
49700	11164	19509	6
49701	11165	19661	4
49702	11165	19662	3
49703	11165	19522	8
49704	11165	19663	7
49705	11165	19626	5
49706	11165	19557	7
49707	11166	19608	2
49708	11166	19532	4
49709	11166	19487	1
49710	11166	19528	2
49711	11166	19664	3
49712	11167	19665	6
49713	11167	19507	7
49714	11167	19572	8
49715	11167	19666	11
49716	11167	19490	11
49717	11167	19509	14
49718	11168	19619	8
49719	11168	19667	1
49720	11168	19668	3
49721	11168	19589	7
49722	11168	19509	7
49723	11169	19669	6
49724	11169	19670	4
49725	11169	19580	6
49726	11169	19671	5
49727	11169	19672	7
49728	11169	19673	5
49729	11170	19674	9
49730	11170	19675	7
49731	11170	19676	7
49732	11170	19577	9
49733	11170	19520	8
49734	11171	19600	9
49735	11171	19616	4
49736	11171	19593	11
49737	11171	19577	9
49738	11171	19557	8
49739	11172	19677	2
49740	11172	19600	2
49741	11172	19523	6
49742	11172	19589	11
49743	11172	19509	6
49744	11173	19678	4
49745	11173	19679	4
49746	11173	19680	5
49747	11173	19681	1
49748	11173	19682	1
49749	11174	19683	3
49750	11174	19684	5
49751	11174	19508	8
49752	11174	19685	1
49753	11174	19686	7
49754	11175	19687	3
49755	11175	19688	5
49756	11175	19689	7
49757	11175	19690	1
49758	11175	19573	6
49759	11176	19691	6
49760	11176	19692	7
49761	11176	19693	4
49762	11176	19513	8
49763	11176	19664	4
49764	11177	19514	4
49765	11177	19694	9
49766	11177	19695	5
49767	11177	19696	1
49768	11177	19513	12
49769	11178	19678	5
49770	11178	19697	4
49771	11178	19698	3
49772	11178	19684	7
49773	11178	19699	4
49774	11178	19513	3
49775	11179	19700	4
49776	11179	19692	5
49777	11179	19701	3
49778	11179	19702	4
49779	11179	19703	6
49780	11180	19704	6
49781	11180	19705	5
49782	11180	19692	8
49783	11180	19650	2
49784	11180	19513	7
49785	11181	19706	3
49786	11181	19694	9
49787	11181	19707	6
49788	11181	19708	2
49789	11181	19597	7
49790	11182	19709	3
49791	11182	19644	3
49792	11182	19689	5
49793	11182	19690	1
49794	11182	19682	2
49795	11183	19710	3
49796	11183	19711	3
49797	11183	19684	9
49798	11183	19712	3
49799	11183	19513	2
49800	11184	19464	2
49801	11184	19713	9
49802	11184	19508	5
49803	11184	19714	4
49804	11184	19597	5
49805	11185	19715	7
49806	11185	19716	4
49807	11185	19717	8
49808	11185	19643	3
49809	11185	19682	13
49810	11186	19700	3
49811	11186	19718	7
49812	11186	19701	4
49813	11186	19719	1
49814	11186	19562	4
49815	11187	19720	4
49816	11187	19689	7
49817	11187	19721	6
49818	11187	19690	1
49819	11187	19682	3
49820	11188	19722	2
49821	11188	19723	4
49822	11188	19718	4
49823	11188	19696	1
49824	11188	19562	2
49825	11189	19665	1
49826	11189	19724	7
49827	11189	19538	7
49828	11189	19668	3
49829	11189	19597	1
49830	11190	19725	4
49831	11190	19726	8
49832	11190	19707	11
49833	11190	19727	4
49834	11190	19686	8
49835	11191	19677	2
49836	11191	19728	3
49837	11191	19729	11
49838	11191	19730	1
49839	11191	19731	2
49840	11191	19573	6
49841	11192	19732	3
49842	11192	19733	4
49843	11192	19471	4
49844	11192	19734	2
49845	11192	19686	6
49846	11193	19735	3
49847	11193	19736	6
49848	11193	19737	9
49849	11193	19738	1
49850	11193	19562	1
49851	11194	19706	2
49852	11194	19739	2
49853	11194	19684	5
49854	11194	19682	1
49855	11194	19740	2
49856	11195	19741	5
49857	11195	19670	7
49858	11195	19742	9
49859	11195	19743	3
49860	11195	19703	2
49861	11196	19744	3
49862	11196	19723	6
49863	11196	19745	8
49864	11196	19681	3
49865	11196	19550	5
49866	11197	19746	4
49867	11197	19747	3
49868	11197	19707	6
49869	11197	19748	5
49870	11197	19573	3
49871	11198	19749	4
49872	11198	19750	3
49873	11198	19625	7
49874	11198	19708	2
49875	11198	19597	11
49876	11199	19750	3
49877	11199	19751	4
49878	11199	19707	5
49879	11199	19538	7
49880	11199	19597	4
49881	11200	19752	5
49882	11200	19698	6
49883	11200	19745	8
49884	11200	19753	2
49885	11200	19597	7
49886	11201	19700	3
49887	11201	19754	7
49888	11201	19684	9
49889	11201	19727	2
49890	11201	19686	3
49891	11202	19700	3
49892	11202	19718	6
49893	11202	19701	4
49894	11202	19714	4
49895	11202	19562	3
49896	11203	19677	2
49897	11203	19755	3
49898	11203	19756	9
49899	11203	19757	4
49900	11203	19573	8
49901	11204	19758	3
49902	11204	19613	9
49903	11204	19759	4
49904	11204	19668	4
49905	11204	19597	9
49906	11205	19718	6
49907	11205	19760	4
49908	11205	19761	2
49909	11205	19681	6
49910	11205	19597	3
49911	11206	19586	4
49912	11206	19694	8
49913	11206	19721	3
49914	11206	19762	3
49915	11206	19682	1
49916	11207	19763	3
49917	11207	19680	6
49918	11207	19761	1
49919	11207	19764	4
49920	11207	19686	4
49921	11208	19765	12
49922	11208	19680	10
49923	11208	19721	8
49924	11208	19766	6
49925	11208	19686	8
49926	11209	19739	4
49927	11209	19726	7
49928	11209	19767	1
49929	11209	19768	3
49930	11209	19686	7
49931	11210	19700	4
49932	11210	19769	9
49933	11210	19770	2
49934	11210	19696	1
49935	11210	19513	8
49936	11211	19744	4
49937	11211	19723	6
49938	11211	19745	9
49939	11211	19681	1
49940	11211	19550	2
49941	11212	19700	3
49942	11212	19588	8
49943	11212	19701	3
49944	11212	19719	1
49945	11212	19562	1
49946	11213	19514	3
49947	11213	19771	4
49948	11213	19694	10
49949	11213	19772	4
49950	11213	19513	5
49951	11214	19669	5
49952	11214	19751	3
49953	11214	19471	3
49954	11214	19773	4
49955	11214	19562	3
49956	11215	19709	3
49957	11215	19689	9
49958	11215	19721	3
49959	11215	19690	1
49960	11215	19682	2
49961	11216	19744	3
49962	11216	19674	6
49963	11216	19718	8
49964	11216	19656	4
49965	11216	19550	5
49966	11217	19774	4
49967	11217	19775	7
49968	11217	19776	9
49969	11217	19777	4
49970	11217	19597	4
49971	11218	19778	4
49972	11218	19694	8
49973	11218	19538	6
49974	11218	19681	1
49975	11218	19597	1
49976	11219	19694	9
49977	11219	19761	3
49978	11219	19773	2
49979	11219	19690	4
49980	11219	19513	6
49981	11220	19697	3
49982	11220	19689	8
49983	11220	19779	1
49984	11220	19536	3
49985	11220	19682	8
49986	11221	19595	2
49987	11221	19625	6
49988	11221	19780	1
49989	11221	19773	9
49990	11221	19550	1
49991	11222	19704	6
49992	11222	19541	2
49993	11222	19692	8
49994	11222	19721	6
49995	11222	19781	3
49996	11222	19513	5
49997	11223	19704	5
49998	11223	19692	7
49999	11223	19721	9
50000	11223	19693	6
50001	11223	19513	8
50002	11224	19782	2
50003	11224	19769	5
50004	11224	19696	1
50005	11224	19686	1
50006	11224	19783	6
50007	11225	19709	4
50008	11225	19689	11
50009	11225	19721	8
50010	11225	19734	1
50011	11225	19682	7
50012	11226	19720	3
50013	11226	19644	2
50014	11226	19689	11
50015	11226	19690	1
50016	11226	19682	4
50017	11227	19784	1
50018	11227	19754	3
50019	11227	19785	9
50020	11227	19772	1
50021	11227	19686	7
50022	11228	19784	4
50023	11228	19754	4
50024	11228	19785	8
50025	11228	19786	3
50026	11228	19682	9
50027	11229	19787	2
50028	11229	19662	9
50029	11229	19745	8
50030	11229	19738	2
50031	11229	19513	5
50032	11230	19788	3
50033	11230	19684	2
50034	11230	19550	1
50035	11230	19783	4
50036	11230	19530	1
50037	11231	19778	2
50038	11231	19739	3
50039	11231	19694	4
50040	11231	19789	1
50041	11231	19686	1
50042	11232	19790	5
50043	11232	19694	2
50044	11232	19791	9
50045	11232	19682	1
50046	11232	19491	1
50047	11233	19792	4
50048	11233	19793	7
50049	11233	19662	8
50050	11233	19694	9
50051	11233	19686	5
50052	11234	19763	3
50053	11234	19785	9
50054	11234	19572	6
50055	11234	19766	4
50056	11234	19686	6
50057	11235	19794	5
50058	11235	19606	5
50059	11235	19684	7
50060	11235	19681	2
50061	11235	19513	2
50062	11236	19755	3
50063	11236	19795	2
50064	11236	19796	4
50065	11236	19797	2
50066	11236	19686	2
50067	11237	19798	5
50068	11237	19692	7
50069	11237	19572	6
50070	11237	19714	7
50071	11237	19513	12
50072	11238	19799	5
50073	11238	19625	4
50074	11238	19538	6
50075	11238	19681	1
50076	11238	19597	1
50077	11239	19700	4
50078	11239	19718	6
50079	11239	19701	3
50080	11239	19719	1
50081	11239	19562	5
50082	11240	19800	4
50083	11240	19694	8
50084	11240	19731	2
50085	11240	19656	1
50086	11240	19686	7
50087	11241	19801	3
50088	11241	19700	3
50089	11241	19718	7
50090	11241	19719	1
50091	11241	19562	3
50092	11242	19744	5
50093	11242	19723	6
50094	11242	19802	9
50095	11242	19681	1
50096	11242	19550	6
50097	11243	19711	4
50098	11243	19684	2
50099	11243	19508	2
50100	11243	19513	1
50101	11243	19803	2
50102	11244	19804	4
50103	11244	19805	3
50104	11244	19689	11
50105	11244	19690	1
50106	11244	19573	6
50107	11245	19806	5
50108	11245	19684	8
50109	11245	19508	6
50110	11245	19560	5
50111	11245	19597	5
50112	11246	19709	5
50113	11246	19689	11
50114	11246	19734	1
50115	11246	19682	4
50116	11246	19495	2
50117	11247	19709	5
50118	11247	19689	2
50119	11247	19721	4
50120	11247	19734	1
50121	11247	19682	1
50122	11248	19709	4
50123	11248	19689	8
50124	11248	19721	6
50125	11248	19690	2
50126	11248	19682	6
50127	11249	19720	4
50128	11249	19689	11
50129	11249	19721	7
50130	11249	19734	2
50131	11249	19682	4
50132	11250	19807	3
50133	11250	19808	2
50134	11250	19694	7
50135	11250	19809	4
50136	11250	19810	4
50137	11250	19686	2
50138	11251	19799	7
50139	11251	19645	8
50140	11251	19588	9
50141	11251	19681	4
50142	11251	19597	3
50143	11252	19798	5
50144	11252	19811	8
50145	11252	19508	6
50146	11252	19714	5
50147	11252	19597	8
50148	11253	19665	1
50149	11253	19625	11
50150	11253	19538	8
50151	11253	19812	9
50152	11253	19550	9
50153	11254	19709	6
50154	11254	19689	11
50155	11254	19734	2
50156	11254	19682	3
50157	11254	19495	4
50158	11255	19813	6
50159	11255	19689	13
50160	11255	19581	4
50161	11255	19814	5
50162	11255	19550	9
50163	11256	19665	1
50164	11256	19588	7
50165	11256	19538	8
50166	11256	19815	2
50167	11256	19597	5
50168	11257	19816	5
50169	11257	19718	6
50170	11257	19701	6
50171	11257	19714	4
50172	11257	19562	1
50173	11258	19782	2
50174	11258	19817	7
50175	11258	19818	2
50176	11258	19772	2
50177	11258	19513	3
50178	11259	19677	4
50179	11259	19723	5
50180	11259	19718	8
50181	11259	19681	3
50182	11259	19562	2
50183	11260	19665	3
50184	11260	19625	13
50185	11260	19812	8
50186	11260	19604	7
50187	11260	19597	7
50188	11261	19819	2
50189	11261	19694	8
50190	11261	19820	3
50191	11261	19686	2
50192	11261	19530	1
50193	11262	19821	5
50194	11262	19822	3
50195	11262	19745	11
50196	11262	19681	4
50197	11262	19686	11
50198	11263	19744	3
50199	11263	19751	8
50200	11263	19721	7
50201	11263	19823	4
50202	11263	19597	6
50203	11264	19687	3
50204	11264	19709	4
50205	11264	19689	11
50206	11264	19690	1
50207	11264	19682	5
50208	11265	19722	3
50209	11265	19723	6
50210	11265	19718	9
50211	11265	19696	1
50212	11265	19703	5
50213	11266	19739	5
50214	11266	19689	9
50215	11266	19824	3
50216	11266	19535	5
50217	11266	19550	4
50218	11267	19739	8
50219	11267	19769	8
50220	11267	19824	11
50221	11267	19825	4
50222	11267	19550	6
50223	11268	19826	1
50224	11268	19769	7
50225	11268	19612	1
50226	11268	19550	1
50227	11268	19491	1
50228	11269	19827	6
50229	11269	19828	5
50230	11269	19829	3
50231	11270	19830	5
50232	11271	19831	3
50233	11272	19832	4
50234	11272	19833	5
50235	11273	19831	11
50236	11274	19834	13
50237	11274	19835	4
50238	11275	19831	3
50239	11276	19831	1
50240	11277	19831	3
50241	11278	19836	3
50242	11278	19837	11
50243	11279	19827	4
50244	11279	19838	7
50245	11280	19839	7
50246	11280	19840	8
50247	11281	19841	4
50248	11282	19842	3
50249	11282	19843	11
50250	11283	19844	7
50251	11283	19829	3
50252	11284	19829	2
50253	11284	19845	13
50254	11285	19846	8
50255	11286	19847	2
50256	11286	19848	4
50257	11287	19849	5
50258	11287	19845	5
50259	11288	19850	11
50260	11288	19851	10
50261	11289	19852	7
50262	11289	19843	9
50263	11290	19845	11
50264	11291	19853	7
50265	11292	19845	4
50266	11293	19850	2
50267	11293	19843	9
50268	11294	19854	8
50269	11295	19855	8
50270	11296	19856	6
50271	11296	19841	4
50272	11297	19840	3
50273	11298	19857	5
50274	11298	19858	1
50275	11299	19859	11
50276	11299	19845	2
50277	11300	19859	3
50278	11301	19847	5
50279	11301	19859	3
50280	11302	19860	9
50281	11302	19833	5
50282	11303	19857	7
50283	11303	19855	8
50284	11304	19861	4
50285	11304	19859	5
50286	11305	19862	3
50287	11305	19848	3
50288	11306	19843	8
50289	11307	19855	4
50290	11307	19859	11
50291	11308	19845	11
50292	11309	19863	4
50293	11310	19859	11
50294	11310	19845	5
50295	11311	19841	2
50296	11311	19853	4
50297	11312	19841	5
50298	11312	19846	1
50299	11313	19864	5
50300	11314	19865	8
50301	11315	19866	8
50302	11315	19867	4
50303	11316	19868	7
50304	11317	19869	2
50305	11318	19846	6
50306	11319	19870	6
50307	11320	19871	5
50308	11321	19872	4
50309	11321	19873	2
50310	11322	19852	1
50311	11323	19874	4
50312	11324	19874	7
50313	11325	19875	3
50314	11325	19876	5
50315	11326	19877	1
50316	11326	19833	3
50317	11327	19878	1
50318	11328	19879	11
50319	11329	19859	11
50320	11329	19845	4
50321	11330	19880	5
50322	11331	19868	3
50323	11332	19881	2
50324	11333	19870	5
50325	11334	19859	2
50326	11334	19845	1
50327	11335	19882	8
50328	11336	19883	1
50329	11337	19881	1
50330	11338	19884	1
50331	11339	19853	9
50332	11340	19885	1
50333	11340	19886	3
50334	11341	19871	3
50335	11342	19846	8
50336	11343	19852	5
50337	11344	19884	2
50338	11345	19880	5
50339	11346	19887	5
50340	11347	19859	1
50341	11347	19845	1
50342	11348	19888	6
50343	11349	19887	1
50344	11350	19882	7
50345	11351	19871	4
50346	11352	19881	7
50347	11352	19889	2
50348	11353	19879	5
50349	11354	19888	5
50350	11355	19890	2
50351	11355	19891	3
50352	11356	19892	2
50353	11357	19852	5
50354	11358	19879	11
50355	11359	19846	9
50356	11360	19893	11
50357	11361	19874	4
50358	11362	19883	3
50359	11363	19894	9
50360	11364	19874	1
50361	11365	19895	6
50362	11366	19896	11
50364	11366	19898	11
50365	11366	19899	6
50366	11366	19900	11
50367	11367	19901	14
50368	11367	19902	14
50369	11367	19903	7
50370	11367	19904	4
50371	11367	19900	10
50372	11368	19905	3
50373	11369	19903	6
50374	11369	19906	11
50375	11369	19907	5
50376	11369	19908	4
50377	11369	19909	13
50378	11370	19907	4
50379	11370	19905	3
50380	11370	19910	14
50381	11370	19911	6
50382	11370	19900	9
50383	11371	19912	4
50384	11371	19913	2
50385	11371	19896	11
50386	11371	19914	5
50387	11371	19915	4
50388	11371	19908	3
50389	11372	19916	11
50390	11372	19917	14
50391	11372	19918	9
50392	11372	19919	8
50393	11372	19920	8
50394	11372	19914	11
50395	11372	19921	9
50396	11373	19916	5
50397	11373	19922	14
50398	11373	19906	11
50399	11373	19923	8
50400	11373	19924	7
50401	11374	19903	6
50402	11374	19906	11
50403	11374	19907	6
50404	11374	19904	3
50405	11374	19925	9
50406	11374	19908	4
50407	11375	19926	14
50408	11375	19927	11
50409	11376	19928	7
50410	11376	19929	8
50411	11376	19908	3
50412	11376	19900	11
50413	11377	19926	14
50414	11377	19927	11
50415	11377	19930	11
50416	11377	19931	3
50417	11377	19915	6
50418	11377	19932	1
50419	11377	19933	9
50420	11378	19934	2
50421	11378	19935	7
50422	11378	19903	8
50423	11378	19923	8
50424	11378	19920	2
50425	11378	19936	7
50426	11379	19937	5
50427	11379	19938	2
50428	11379	19939	10
50429	11379	19940	3
50430	11379	19941	13
50431	11379	19909	8
50432	11380	19942	9
50433	11380	19943	6
50434	11380	19914	6
50435	11380	19944	5
50436	11380	19905	7
50437	11380	19945	11
50438	11381	19918	3
50439	11381	19906	8
50440	11381	19946	6
50441	11381	19897	4
50442	11381	19907	8
50443	11381	19904	1
50444	11382	19947	3
50445	11382	19916	11
50446	11382	19917	14
50447	11382	19919	8
50448	11382	19898	11
50449	11382	19909	11
50450	11383	19918	7
50451	11383	19919	9
50452	11383	19936	6
50453	11383	19944	4
50454	11383	19900	9
50455	11384	19948	11
50456	11384	19949	2
50457	11384	19926	14
50458	11384	19927	11
50459	11384	19941	6
50460	11384	19899	12
50461	11384	19909	8
50462	11385	19918	6
50463	11385	19923	11
50464	11385	19936	6
50465	11385	19944	6
50466	11385	19909	9
50467	11386	19950	14
50468	11386	19927	5
50469	11386	19918	5
50470	11386	19906	2
50471	11386	19907	6
50472	11386	19944	13
50473	11386	19905	7
50474	11387	19916	11
50475	11387	19922	14
50476	11387	19903	9
50477	11387	19930	11
50478	11387	19907	8
50479	11387	19944	4
50480	11387	19951	2
50481	11387	19933	6
50482	11388	19918	5
50483	11388	19906	3
50484	11388	19946	6
50485	11388	19897	4
50486	11388	19907	2
50487	11388	19904	5
50488	11388	19944	5
50489	11389	19952	5
50490	11389	19953	11
50491	11389	19954	8
50492	11389	19944	13
50493	11389	19899	5
50494	11389	19900	11
50495	11390	19955	6
50496	11390	19942	11
50497	11390	19941	9
50498	11390	19898	8
50499	11390	19925	9
50500	11390	19956	3
50501	11391	19957	9
50502	11391	19958	3
50503	11391	19959	2
50504	11391	19915	2
50505	11392	19960	4
50506	11392	19961	9
50507	11392	19962	8
50508	11392	19963	4
50509	11392	19959	7
50510	11392	19964	9
50511	11393	19965	4
50512	11393	19966	9
50513	11393	19967	7
50514	11393	19964	12
50515	11393	19968	5
50516	11393	19900	8
50517	11394	19969	6
50518	11394	19970	5
50519	11394	19971	3
50520	11394	19940	5
50521	11394	19964	6
50522	11394	19909	8
50523	11395	19972	8
50524	11395	19973	9
50525	11395	19974	9
50526	11395	19964	9
50527	11396	19975	4
50528	11396	19919	2
50529	11396	19936	2
50530	11396	19898	5
50531	11396	19944	3
50532	11396	19976	2
50533	11397	19977	4
50534	11397	19978	5
50535	11397	19919	11
50536	11397	19979	8
47283	10652	18277	5
50363	11366	19897	9
47678	10742	18604	5
49185	11071	19364	11
49043	11042	19366	11
47190	10631	18184	11
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
2535	2545	199938944	1
2536	2546	200258957	1
2537	2547	200261631	1
2538	2548	200302684	1
2539	2549	200306538	1
2540	2550	200427046	1
2541	2551	200505277	1
2542	2552	200571597	1
2543	2553	200604764	1
2544	2554	200611321	1
2545	2555	200618693	1
2546	2556	200645172	1
2547	2557	200678578	1
2548	2558	200678652	1
2549	2559	200660742	1
2550	2560	200660849	1
2551	2561	200702110	1
2552	2562	200716081	1
2553	2563	200722129	1
2554	2564	200727064	1
2555	2565	200729866	1
2556	2566	200737513	1
2557	2567	200742060	1
2558	2568	200746440	1
2559	2569	200746691	1
2560	2570	200750610	1
2561	2571	200776104	1
2562	2572	200703789	1
2563	2573	200801494	1
2564	2574	200804269	1
2565	2575	200805213	1
2566	2576	200806725	1
2567	2577	200807619	1
2568	2578	200810012	1
2569	2579	200810449	1
2570	2580	200812434	1
2571	2581	200816057	1
2572	2582	200816182	1
2573	2583	200818798	1
2574	2584	200820492	1
2575	2585	200820845	1
2576	2586	200822195	1
2577	2587	200824411	1
2578	2588	200826125	1
2579	2589	200826132	1
2580	2590	200829462	1
2581	2591	200831088	1
2582	2592	200835065	1
2583	2593	200838847	1
2584	2594	200850304	1
2585	2595	200854833	1
2586	2596	200859513	1
2587	2597	200861979	1
2588	2598	200863141	1
2589	2599	200863910	1
2590	2600	200863943	1
2591	2601	200867820	1
2592	2602	200867969	1
2593	2603	200869234	1
2594	2604	200878505	1
2595	2605	200878522	1
2596	2606	200879055	1
2597	2607	200751702	1
2598	2608	200649333	1
2599	2609	200704149	1
2600	2610	200800722	1
2601	2611	200800992	1
2602	2612	200802019	1
2603	2613	200805994	1
2604	2614	200810511	1
2605	2615	200810842	1
2606	2616	200815563	1
2607	2617	200816422	1
2608	2618	200817653	1
2609	2619	200850077	1
2610	2620	200852284	1
2611	2621	200865811	1
2612	2622	200900039	1
2613	2623	200900138	1
2614	2624	200900163	1
2615	2625	200900184	1
2616	2626	200900407	1
2617	2627	200900495	1
2618	2628	200900643	1
2619	2629	200900790	1
2620	2630	200901056	1
2621	2631	200903933	1
2622	2632	200904996	1
2623	2633	200905558	1
2624	2634	200906611	1
2625	2635	200906984	1
2626	2636	200907623	1
2627	2637	200909509	1
2628	2638	200910151	1
2629	2639	200910605	1
2630	2640	200911631	1
2631	2641	200911675	1
2632	2642	200911724	1
2633	2643	200911734	1
2634	2644	200911738	1
2635	2645	200911827	1
2636	2646	200912221	1
2637	2647	200912581	1
2638	2648	200912820	1
2639	2649	200912874	1
2640	2650	200912972	1
2641	2651	200913084	1
2642	2652	200913146	1
2643	2653	200913757	1
2644	2654	200913846	1
2645	2655	200913901	1
2646	2656	200914214	1
2647	2657	200914369	1
2648	2658	200914550	1
2649	2659	200915033	1
2650	2660	200920483	1
2651	2661	200920633	1
2652	2662	200921105	1
2653	2663	200921634	1
2654	2664	200922056	1
2655	2665	200922763	1
2656	2666	200922784	1
2657	2667	200922882	1
2658	2668	200924554	1
2659	2669	200925215	1
2660	2670	200925241	1
2661	2671	200925249	1
2662	2672	200925556	1
2663	2673	200925562	1
2664	2674	200926277	1
2665	2675	200926328	1
2666	2676	200926380	1
2667	2677	200926385	1
2668	2678	200929259	1
2669	2679	200929277	1
2670	2680	200929367	1
2671	2681	200929381	1
2672	2682	200929428	1
2673	2683	200929656	1
2674	2684	200930017	1
2675	2685	200932205	1
2676	2686	200933686	1
2677	2687	200935632	1
2678	2688	200936633	1
2679	2689	200937320	1
2680	2690	200939122	1
2681	2691	200940273	1
2682	2692	200942368	1
2683	2693	200942606	1
2684	2694	200945214	1
2685	2695	200945219	1
2686	2696	200950378	1
2687	2697	200950655	1
2688	2698	200950663	1
2689	2699	200951345	1
2690	2700	200951383	1
2691	2701	200952820	1
2692	2702	200952936	1
2693	2703	200953322	1
2694	2704	200953427	1
2695	2705	200953449	1
2696	2706	200953589	1
2697	2707	200953593	1
2698	2708	200953879	1
2699	2709	200953979	1
2700	2710	200954553	1
2701	2711	200955605	1
2702	2712	200957922	1
2703	2713	200960039	1
2704	2714	200962443	1
2705	2715	200978170	1
2706	2716	200978810	1
2707	2717	200978939	1
2708	2718	200819985	1
2709	2719	200824759	1
2710	2720	200865810	1
2711	2721	200804221	1
\.


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentterms (studenttermid, studentid, termid, ineligibilities, issettled, cwa, gwa, mathgwa, csgwa) FROM stdin;
10633	2535	20002	N/A	t	2.3136	3.8235	2.6250	3.0500
10634	2535	20003	N/A	t	2.3074	2.2500	2.4474	3.0500
10636	2535	20012	N/A	t	2.6951	4.2000	2.5227	3.5300
10637	2535	20013	N/A	t	2.6563	2.1250	2.5227	3.3661
10639	2536	20021	N/A	t	2.4265	2.4265	3.0000	1.5000
10640	2537	20021	N/A	t	2.2500	2.2500	2.2500	2.2500
10641	2535	20022	N/A	t	2.7146	3.2500	2.5227	3.3316
10642	2536	20022	N/A	t	2.7132	3.0000	3.0000	3.2500
10645	2536	20031	N/A	t	2.6250	2.3750	3.0000	2.8333
10647	2538	20031	N/A	t	2.5000	2.5000	2.5000	3.0000
10648	2539	20031	N/A	t	2.5909	2.5909	3.0000	0.0000
10649	2535	20032	N/A	t	2.7370	0.0000	2.5227	3.2802
10651	2537	20032	N/A	t	2.9710	4.6250	3.0476	3.1346
10653	2539	20032	N/A	t	2.2500	2.0294	3.0000	1.2500
10655	2537	20033	N/A	t	2.9589	2.7500	3.0476	3.1346
10656	2538	20033	N/A	t	2.5323	2.0000	2.7500	2.5000
10657	2539	20033	N/A	t	2.5152	4.0000	3.3333	1.2500
10659	2537	20041	N/A	t	3.0577	3.4583	3.0417	3.4079
10660	2538	20041	N/A	t	2.7273	3.1923	2.6667	2.4000
10661	2539	20041	N/A	t	2.4844	2.4167	3.0625	1.8750
10663	2536	20042	N/A	t	2.5758	2.2500	3.0000	2.8581
10664	2537	20042	N/A	t	3.0354	2.9000	3.0417	3.4643
10665	2538	20042	N/A	t	3.2000	4.5789	3.3333	3.0000
10667	2540	20042	N/A	t	1.9032	2.1429	2.3750	1.1250
10668	2536	20043	N/A	t	2.5495	2.1786	3.0000	2.8581
10670	2538	20043	N/A	t	3.2000	0.0000	3.3333	3.0000
10671	2539	20043	N/A	t	2.7188	2.2500	3.3793	2.9167
10672	2540	20043	N/A	t	1.9032	0.0000	2.3750	1.1250
10674	2537	20051	N/A	t	2.9250	2.7500	3.0417	3.0625
10675	2538	20051	N/A	t	3.1349	3.2237	3.5417	3.0000
10676	2539	20051	N/A	t	2.7039	3.1000	3.5313	2.9375
10678	2541	20051	N/A	t	1.8824	1.8824	1.7500	1.7500
10679	2542	20051	N/A	t	1.9265	1.9265	1.7500	1.2500
10680	2536	20052	N/A	t	2.4981	2.2500	3.0000	2.6250
10682	2538	20052	N/A	t	3.0395	2.6579	3.5417	3.0000
10683	2540	20052	N/A	t	2.1439	2.6250	2.6071	1.5156
10684	2541	20052	N/A	t	2.5161	3.2857	3.3750	1.7500
10686	2537	20053	N/A	t	2.7785	1.1250	3.0417	2.7119
10687	2538	20053	N/A	t	3.0077	2.0000	3.3704	3.0000
10688	2541	20053	N/A	t	2.4792	2.2500	3.0000	1.7500
10690	2537	20061	N/A	t	2.7911	3.0000	3.0417	2.7500
10691	2540	20061	N/A	t	2.0402	1.7143	2.4688	1.6000
10693	2542	20061	N/A	t	2.0647	2.2794	2.1538	1.8281
10694	2543	20061	N/A	t	2.1618	2.1618	3.0000	2.0000
10695	2544	20061	N/A	t	2.5735	2.5735	5.0000	2.0000
10697	2546	20061	N/A	t	2.2500	2.2500	3.0000	2.5000
10698	2547	20061	N/A	t	2.4118	2.4118	4.0000	1.0000
10699	2548	20061	N/A	t	2.2059	2.2059	3.0000	1.2500
10701	2539	20062	N/A	t	2.6236	2.1538	3.4643	2.6406
10702	2540	20062	N/A	t	1.9476	1.5000	2.4688	1.4865
10703	2541	20062	N/A	t	3.0634	3.5333	3.4000	2.4231
10705	2543	20062	N/A	t	2.5221	2.8824	4.0000	2.1250
10706	2544	20062	N/A	t	2.5074	2.4412	3.8750	2.3750
10707	2545	20062	N/A	t	1.9706	2.0735	2.8750	2.0000
10709	2547	20062	N/A	t	2.1618	1.9118	3.0000	1.1250
10710	2548	20062	N/A	t	2.0735	1.9412	3.0000	1.3750
10711	2540	20063	N/A	t	1.9476	0.0000	2.4688	1.4865
10713	2542	20063	N/A	t	2.1044	1.7500	2.2656	1.9091
10714	2544	20063	N/A	t	2.5705	3.0000	3.5833	2.3750
10715	2545	20063	N/A	t	2.0526	2.7500	2.8750	2.0000
10717	2547	20063	N/A	t	2.2372	2.7500	2.9167	1.1250
10718	2548	20063	N/A	t	1.9875	1.5000	3.0000	1.3750
10720	2540	20071	N/A	t	2.0407	2.5833	2.4688	1.7959
10721	2541	20071	N/A	t	2.9888	2.7083	3.3226	2.5568
10722	2542	20071	N/A	t	2.1624	2.4167	2.2656	2.1397
10724	2544	20071	N/A	t	2.4052	2.0658	3.3125	2.4250
10725	2545	20071	N/A	t	2.0714	2.1111	2.9167	2.0000
10726	2546	20071	N/A	t	2.2406	2.2000	2.9167	2.4500
10728	2550	20071	N/A	t	2.1667	2.1667	1.7500	0.0000
10729	2547	20071	N/A	t	2.2457	2.2632	2.7500	1.3750
10731	2551	20071	N/A	t	1.7059	1.7059	2.5000	1.2500
10732	2552	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
10733	2553	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
10734	2554	20071	N/A	t	3.2794	3.2794	5.0000	2.0000
10736	2556	20071	N/A	t	2.7679	2.7679	2.5000	1.2500
10737	2557	20071	N/A	t	1.9559	1.9559	2.7500	1.5000
10739	2559	20071	N/A	t	2.2059	2.2059	3.0000	2.0000
10740	2560	20071	N/A	t	1.7647	1.7647	1.5000	1.5000
10741	2561	20071	N/A	t	1.7206	1.7206	2.2500	1.0000
10743	2539	20072	N/A	t	2.5768	2.5500	3.4643	2.7763
10744	2540	20072	N/A	t	2.0265	1.9500	2.4688	1.7959
10745	2541	20072	N/A	t	3.1589	4.0000	3.3226	3.0726
10747	2543	20072	N/A	t	2.6208	2.4500	3.5000	2.2750
10748	2544	20072	N/A	t	2.3547	2.1719	3.0761	2.5000
10750	2546	20072	N/A	t	2.4826	3.1579	3.1190	3.0385
10751	2549	20072	N/A	t	3.2803	4.0694	3.6250	4.0000
10752	2550	20072	N/A	t	2.5446	2.8281	2.1591	2.2500
10754	2548	20072	N/A	t	2.4967	3.9219	3.2262	2.6346
10755	2551	20072	N/A	t	2.1618	2.6176	3.7500	1.5000
10756	2552	20072	N/A	t	2.1618	2.2500	2.2500	1.3750
10758	2554	20072	N/A	t	2.8603	2.4412	3.8750	2.1250
10759	2555	20072	N/A	t	2.2500	2.2941	3.0000	2.3750
10760	2556	20072	N/A	t	2.8929	3.0179	3.7500	1.3750
10762	2558	20072	N/A	t	1.6985	1.9118	1.5000	1.1250
10763	2559	20072	N/A	t	1.9779	1.7500	2.7500	1.5000
10764	2560	20072	N/A	t	1.7794	1.7941	2.0000	1.5000
10766	2540	20073	N/A	t	2.0148	1.5000	2.4688	1.7959
10769	2544	20073	N/A	t	2.3312	1.7500	2.9231	2.5000
10770	2546	20073	N/A	t	2.4633	2.0000	2.9792	3.0385
10772	2547	20073	N/A	t	2.4383	5.0000	2.6635	1.6923
10773	2548	20073	N/A	t	2.4573	2.0357	3.0417	2.6346
10775	2553	20073	N/A	t	2.2500	1.5000	2.2500	1.8750
10776	2554	20073	N/A	t	2.8782	3.0000	3.5833	2.1250
10777	2556	20073	N/A	t	2.6818	1.5000	3.0000	1.3750
10778	2557	20073	N/A	t	2.4038	2.0000	3.2500	1.7500
10644	2535	20031	N/A	t	3.4130	5.0000	3.4318	3.6598
10780	2541	20081	N/A	t	3.1983	3.6667	3.3226	3.0608
10781	2542	20081	N/A	t	2.0620	1.5500	2.2656	1.8750
10783	2544	20081	N/A	t	2.2690	1.9500	2.9231	2.1932
10784	2545	20081	N/A	t	2.4389	2.7000	3.1667	2.5625
10785	2546	20081	N/A	t	2.4861	2.6000	2.9792	2.8523
10787	2550	20081	N/A	t	2.5598	2.5833	2.1591	3.0000
10788	2547	20081	N/A	t	2.5208	2.8553	2.6635	2.3661
10789	2548	20081	N/A	t	2.4533	2.0000	3.0417	2.3409
10791	2562	20081	N/A	t	1.9265	1.9265	2.5000	1.2500
10792	2552	20081	N/A	t	2.1085	2.0132	2.4167	1.4250
10794	2554	20081	N/A	t	2.7723	2.5294	3.5833	2.2750
10795	2555	20081	N/A	t	2.3950	2.7031	3.0000	2.5250
10796	2556	20081	N/A	t	2.9583	3.5667	3.2500	1.3750
10798	2558	20081	N/A	t	1.9387	2.3684	1.8333	1.6750
10799	2559	20081	N/A	t	2.2830	2.8289	3.5000	1.3000
10800	2560	20081	N/A	t	2.0802	2.6184	2.2500	2.1000
10802	2563	20081	N/A	t	2.0294	2.0294	3.0000	1.5000
10803	2564	20081	N/A	t	1.7941	1.7941	2.5000	1.0000
10804	2565	20081	N/A	t	2.2059	2.2059	2.2500	2.2500
10806	2567	20081	N/A	t	2.9265	2.9265	2.7500	2.2500
10807	2568	20081	N/A	t	2.3971	2.3971	2.0000	2.7500
10808	2569	20081	N/A	t	1.9853	1.9853	2.2500	2.2500
10810	2571	20081	N/A	t	2.0294	2.0294	2.2500	2.2500
10811	2572	20081	N/A	t	2.8382	2.8382	2.7500	3.0000
10812	2573	20081	N/A	t	1.9853	1.9853	2.2500	2.0000
10814	2575	20081	N/A	t	2.7794	2.7794	3.0000	2.5000
10815	2576	20081	N/A	t	2.1765	2.1765	2.7500	2.2500
10816	2577	20081	N/A	t	1.8235	1.8235	2.0000	1.0000
10818	2579	20081	N/A	t	2.1471	2.1471	2.5000	2.2500
10819	2580	20081	N/A	t	2.0147	2.0147	2.5000	1.0000
10821	2582	20081	N/A	t	2.0441	2.0441	2.0000	2.0000
10822	2583	20081	N/A	t	3.0179	3.0179	5.0000	2.0000
10823	2584	20081	N/A	t	2.2647	2.2647	2.7500	1.7500
10825	2586	20081	N/A	t	2.0441	2.0441	2.7500	2.0000
10826	2587	20081	N/A	t	1.8824	1.8824	1.7500	1.0000
10827	2588	20081	N/A	t	2.2353	2.2353	2.5000	2.2500
10829	2590	20081	N/A	t	2.4853	2.4853	2.7500	2.7500
10830	2591	20081	N/A	t	1.8824	1.8824	1.7500	1.5000
10831	2592	20081	N/A	t	1.9107	1.9107	1.0000	2.0000
10833	2594	20081	N/A	t	1.8235	1.8235	2.7500	1.7500
10834	2595	20081	N/A	t	1.8676	1.8676	1.2500	2.0000
10835	2596	20081	N/A	t	2.9265	2.9265	5.0000	5.0000
10837	2539	20082	N/A	t	2.5688	1.8125	3.4643	2.7264
10838	2541	20082	N/A	t	3.1855	2.9000	3.3226	3.1467
10840	2543	20082	N/A	t	2.5808	2.4500	3.0577	2.3026
10841	2544	20082	N/A	t	2.3000	2.4583	2.9231	2.1691
10842	2545	20082	N/A	t	2.4690	2.6500	3.1667	2.6000
10844	2549	20082	N/A	t	2.7429	2.3438	3.0952	2.8269
10845	2550	20082	N/A	t	2.5363	2.4688	2.1591	2.3947
10846	2547	20082	N/A	t	2.5180	2.5000	2.6635	2.2568
10848	2551	20082	N/A	t	2.2711	2.6563	3.2212	1.6538
10849	2562	20082	N/A	t	2.2786	2.6111	2.5000	1.8750
10851	2553	20082	N/A	t	2.5530	3.2941	2.7500	2.9423
10852	2554	20082	N/A	t	2.7577	2.6667	3.5833	2.4423
10853	2555	20082	N/A	t	2.4167	2.4844	2.9643	2.5250
10855	2557	20082	N/A	t	2.5037	3.4250	3.1630	1.9500
10856	2558	20082	N/A	t	2.1739	2.9531	2.3452	1.8654
10857	2559	20082	N/A	t	2.4706	3.4444	3.5870	1.4615
10859	2597	20082	N/A	t	2.2500	2.2500	3.0000	2.2500
10860	2561	20082	N/A	t	1.9097	2.1711	2.4405	1.5962
10861	2563	20082	N/A	t	2.0294	2.0294	2.6250	1.5000
10863	2565	20082	N/A	t	2.4044	2.6029	2.6250	2.2500
10864	2566	20082	N/A	t	2.3676	2.7059	4.0000	2.1250
10865	2567	20082	N/A	t	2.6397	2.3529	2.7500	2.3750
10867	2569	20082	N/A	t	1.9839	1.9821	2.6250	1.8750
10868	2570	20082	N/A	t	2.0368	1.9853	2.1250	1.0000
10870	2572	20082	N/A	t	2.8065	2.7679	2.6250	3.0000
10871	2573	20082	N/A	t	2.1176	2.2500	2.2500	2.0000
10872	2574	20082	N/A	t	2.7721	2.3971	3.8750	3.2500
10874	2576	20082	N/A	t	2.0956	2.0147	2.6250	2.2500
10875	2577	20082	N/A	t	1.9559	2.0882	2.3750	1.0000
10876	2578	20082	N/A	t	1.7868	1.8971	2.2500	1.3750
10878	2580	20082	N/A	t	2.1324	2.2500	2.7500	1.3750
10879	2581	20082	N/A	t	2.6397	3.1912	3.8750	1.8750
10880	2582	20082	N/A	t	2.1959	2.3250	1.7500	2.3750
10882	2584	20082	N/A	t	2.2647	2.2647	2.7500	2.1250
10883	2585	20082	N/A	t	2.3879	1.4375	2.7500	3.1250
10884	2586	20082	N/A	t	2.2353	2.4265	2.8750	2.5000
10886	2588	20082	N/A	t	2.0882	1.9412	2.3750	2.1250
10887	2589	20082	N/A	t	2.2279	2.1618	3.0000	2.2500
10889	2591	20082	N/A	t	1.8676	1.8529	1.6250	1.5000
10890	2592	20082	N/A	t	2.2143	2.5179	1.6250	2.5000
10891	2593	20082	N/A	t	2.6765	2.9706	4.0000	2.3750
10893	2595	20082	N/A	t	2.1397	2.4118	1.8750	1.8750
10894	2596	20082	N/A	t	2.5515	2.1765	3.8750	3.8750
10895	2538	20083	N/A	t	3.0225	2.7500	3.3083	3.0000
10897	2544	20083	N/A	t	2.2721	1.2500	2.9231	2.1691
10898	2546	20083	N/A	t	2.5023	1.2500	2.9792	2.7500
10899	2549	20083	N/A	t	2.7021	1.7500	3.0952	2.8269
10901	2551	20083	N/A	t	2.2403	1.8750	3.1207	1.6538
10902	2562	20083	N/A	t	2.2756	2.2500	2.5000	1.8750
10905	2556	20083	N/A	t	2.6014	1.0000	2.6875	1.4167
10906	2557	20083	N/A	t	2.5246	3.0000	3.1442	1.9500
10908	2559	20083	N/A	t	2.4767	2.5357	3.4327	1.4615
10909	2597	20083	N/A	t	2.4205	3.0000	3.0000	2.2500
10911	2567	20083	N/A	t	2.4688	1.5000	2.7500	2.3750
10912	2568	20083	N/A	t	2.6053	3.0000	3.0000	2.8750
10913	2572	20083	N/A	t	2.8333	3.0000	2.7500	3.0000
10915	2575	20083	N/A	t	2.7813	1.1250	4.0000	2.2500
10916	2577	20083	N/A	t	1.8974	1.5000	2.0833	1.0000
10917	2578	20083	N/A	t	1.8355	2.2500	2.2500	1.3750
10919	2582	20083	N/A	t	2.2558	2.6250	1.7500	2.3750
10920	2583	20083	N/A	t	2.4792	3.0000	3.5000	1.7500
10921	2584	20083	N/A	t	2.1500	1.5000	2.7500	2.1250
10923	2586	20083	N/A	t	2.5897	5.0000	3.5833	2.5000
10924	2587	20083	N/A	t	1.9615	2.0000	2.2500	1.0000
10925	2590	20083	N/A	t	2.5897	3.0000	2.8333	2.6250
10927	2592	20083	N/A	t	2.0303	1.0000	1.4167	2.5000
10928	2593	20083	N/A	t	2.6859	2.7500	3.5833	2.3750
10930	2538	20091	N/A	t	3.1667	4.5000	3.3083	3.4800
10931	2539	20091	N/A	t	2.5451	2.5000	3.4643	2.7264
10932	2541	20091	N/A	t	3.1294	2.5000	3.3226	3.0246
10933	2542	20091	N/A	t	2.0763	2.0000	2.2656	1.8679
10935	2544	20091	N/A	t	2.3960	3.5625	2.9231	2.5326
10936	2545	20091	N/A	t	2.4979	2.5500	3.1667	2.7721
10938	2598	20091	N/A	t	1.7000	1.7000	0.0000	2.0000
10939	2549	20091	N/A	t	2.7188	2.8000	3.0952	2.8421
10940	2550	20091	N/A	t	2.5000	2.3125	2.1591	2.4286
10942	2548	20091	N/A	t	2.5471	2.7031	3.0417	2.3409
10943	2551	20091	N/A	t	2.4130	3.3000	3.1207	1.7632
10944	2562	20091	N/A	t	2.4183	3.0625	3.2500	1.8250
10946	2552	20091	N/A	t	2.2742	2.6429	2.4762	2.0455
10947	2553	20091	N/A	t	2.6609	3.0417	2.7500	2.9605
10948	2554	20091	N/A	t	2.8375	3.7692	3.5870	2.6184
10950	2556	20091	N/A	t	2.7259	3.3393	2.9113	1.5313
10951	2557	20091	N/A	t	2.6006	2.7500	3.1442	2.1316
10952	2558	20091	N/A	t	2.3833	2.8000	2.3646	1.9545
10954	2560	20091	N/A	t	2.0893	2.0500	2.2813	1.9219
10955	2597	20091	N/A	t	2.4803	2.5625	3.4615	2.0000
10956	2561	20091	N/A	t	1.9278	2.0000	2.4405	1.6250
10958	2601	20091	N/A	t	2.5000	2.5000	3.0000	2.7500
10959	2563	20091	N/A	t	2.0561	2.1167	2.5833	1.4167
10960	2602	20091	N/A	t	2.6500	2.6500	3.0000	0.0000
10962	2565	20091	N/A	t	2.4151	2.4342	2.7500	2.3500
10963	2603	20091	N/A	t	2.0417	2.0417	2.5000	2.0000
10965	2567	20091	N/A	t	2.6339	3.0469	3.5000	2.3250
10966	2568	20091	N/A	t	2.8113	3.3333	3.0000	2.8750
10967	2569	20091	N/A	t	2.1100	2.3158	2.7500	2.1250
10968	2604	20091	N/A	t	2.1667	2.1667	2.5000	0.0000
10970	2570	20091	N/A	t	2.0200	1.9844	2.2500	1.0000
10971	2606	20091	N/A	t	2.4722	2.4722	3.0000	2.2500
10973	2572	20091	N/A	t	2.7206	2.4500	3.1250	2.5000
10974	2607	20091	N/A	t	2.7083	2.7083	2.7500	2.2500
10975	2608	20091	N/A	t	1.6346	1.6346	0.0000	1.5000
10977	2574	20091	N/A	t	2.6447	2.3750	3.3750	2.5833
10978	2575	20091	N/A	t	2.7455	2.6563	3.6667	2.5500
10979	2576	20091	N/A	t	2.0613	2.0000	2.4167	2.0500
10981	2578	20091	N/A	t	1.8070	1.7500	2.1667	1.5250
10982	2579	20091	N/A	t	2.4440	2.3553	3.2500	2.3250
10984	2581	20091	N/A	t	2.5750	2.4375	3.5000	1.9250
10985	2582	20091	N/A	t	2.8545	5.0000	2.8333	3.2500
10986	2583	20091	N/A	t	2.3682	2.1579	3.2500	1.6500
10988	2584	20091	N/A	t	2.2232	2.4063	2.8333	2.2750
10989	2610	20091	N/A	t	2.0556	2.0556	2.7500	1.7500
10990	2585	20091	N/A	t	2.2227	2.2083	2.5000	2.8333
10992	2587	20091	N/A	t	1.9958	2.0625	2.3750	1.4844
10993	2588	20091	N/A	t	2.1840	2.3553	2.5833	2.3750
10994	2589	20091	N/A	t	2.2123	2.1842	2.9167	1.8500
10996	2611	20091	N/A	t	1.8472	1.8472	2.2500	1.5000
10997	2591	20091	N/A	t	2.1708	2.6765	2.3611	1.8000
10998	2592	20091	N/A	t	2.3000	2.8235	1.8472	2.5000
11000	2594	20091	N/A	t	2.1780	2.4250	2.3611	2.4500
11001	2595	20091	N/A	t	2.2500	2.4844	2.0833	2.1250
11003	2612	20091	N/A	t	1.5735	1.5735	1.0000	1.0000
11004	2613	20091	N/A	t	1.6471	1.6471	1.2500	1.5000
11005	2614	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
11006	2615	20091	N/A	t	2.2353	2.2353	2.5000	3.0000
11008	2617	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
11009	2618	20091	N/A	t	2.7500	2.7500	2.7500	5.0000
11011	2620	20091	N/A	t	1.8088	1.8088	2.2500	2.7500
11012	2621	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
11013	2622	20091	N/A	t	1.6912	1.6912	2.7500	1.0000
11015	2624	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
11016	2625	20091	N/A	t	2.1912	2.1912	2.5000	2.5000
11017	2626	20091	N/A	t	1.6765	1.6765	2.2500	1.0000
11019	2628	20091	N/A	t	1.4559	1.4559	1.5000	1.0000
11020	2629	20091	N/A	t	3.0147	3.0147	5.0000	2.7500
11021	2630	20091	N/A	t	1.9265	1.9265	2.5000	2.0000
11023	2632	20091	N/A	t	1.9412	1.9412	2.2500	1.7500
11024	2633	20091	N/A	t	1.4412	1.4412	1.0000	1.5000
11025	2634	20091	N/A	t	2.7941	2.7941	2.7500	5.0000
11027	2636	20091	N/A	t	1.4706	1.4706	1.2500	1.5000
11028	2637	20091	N/A	t	1.6176	1.6176	1.7500	2.5000
11030	2639	20091	N/A	t	2.3529	2.3529	2.7500	2.7500
11031	2640	20091	N/A	t	1.8529	1.8529	1.5000	2.0000
11032	2641	20091	N/A	t	2.3088	2.3088	2.7500	3.0000
11034	2643	20091	N/A	t	1.7941	1.7941	1.7500	1.7500
11035	2644	20091	N/A	t	1.3529	1.3529	1.0000	1.2500
11036	2645	20091	N/A	t	1.9118	1.9118	2.0000	2.0000
11038	2647	20091	N/A	t	1.8088	1.8088	2.2500	1.5000
11041	2650	20091	N/A	t	2.1765	2.1765	2.7500	1.2500
11044	2653	20091	N/A	t	1.7500	1.7500	1.0000	2.0000
11045	2654	20091	N/A	t	1.5147	1.5147	2.0000	1.0000
11046	2655	20091	N/A	t	2.3971	2.3971	2.7500	2.0000
11048	2657	20091	N/A	t	1.5882	1.5882	2.2500	1.0000
11049	2658	20091	N/A	t	2.1471	2.1471	2.5000	3.0000
11051	2660	20091	N/A	t	1.2647	1.2647	1.7500	1.0000
11052	2661	20091	N/A	t	2.2941	2.2941	3.0000	2.0000
11053	2662	20091	N/A	t	2.1765	2.1765	2.7500	2.5000
11055	2664	20091	N/A	t	1.9853	1.9853	3.0000	1.2500
11056	2665	20091	N/A	t	1.7647	1.7647	2.2500	1.5000
11057	2666	20091	N/A	t	1.4265	1.4265	1.2500	1.5000
11059	2668	20091	N/A	t	2.1618	2.1618	2.2500	1.0000
11060	2669	20091	N/A	t	1.2000	1.2000	1.0000	1.0000
11061	2670	20091	N/A	t	1.2647	1.2647	1.0000	1.5000
11063	2672	20091	N/A	t	1.7206	1.7206	2.2500	1.0000
11064	2673	20091	N/A	t	1.8382	1.8382	1.7500	2.0000
11065	2674	20091	N/A	t	2.0294	2.0294	3.0000	1.0000
11067	2676	20091	N/A	t	2.2500	2.2500	2.2500	2.7500
11068	2677	20091	N/A	t	1.2353	1.2353	1.5000	1.0000
11070	2679	20091	N/A	t	2.3971	2.3971	2.0000	2.2500
11072	2681	20091	N/A	t	3.1912	3.1912	5.0000	2.5000
11042	2651	20091	N/A	t	5.0000	5.0000	5.0000	5.0000
11074	2683	20091	N/A	t	2.0735	2.0735	3.0000	1.7500
11075	2684	20091	N/A	t	1.5882	1.5882	1.5000	1.7500
11076	2685	20091	N/A	t	1.5441	1.5441	1.5000	1.2500
11078	2687	20091	N/A	t	2.0441	2.0441	2.7500	1.7500
11079	2688	20091	N/A	t	2.1324	2.1324	2.7500	2.0000
11080	2689	20091	N/A	t	1.7206	1.7206	2.2500	2.0000
11082	2691	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
11083	2692	20091	N/A	t	1.8971	1.8971	2.2500	2.7500
11084	2693	20091	N/A	t	2.1324	2.1324	2.7500	1.0000
11086	2695	20091	N/A	t	1.7059	1.7059	2.5000	1.5000
11087	2696	20091	N/A	t	2.0147	2.0147	2.5000	1.2500
11088	2697	20091	N/A	t	2.6618	2.6618	5.0000	1.0000
11090	2699	20091	N/A	t	2.2500	2.2500	3.0000	3.0000
11091	2700	20091	N/A	t	1.8088	1.8088	2.2500	1.7500
11093	2702	20091	N/A	t	1.8971	1.8971	3.0000	1.7500
11094	2703	20091	N/A	t	2.0588	2.0588	2.5000	2.0000
11095	2704	20091	N/A	t	2.8676	2.8676	3.0000	4.0000
11097	2706	20091	N/A	t	2.1471	2.1471	2.5000	2.0000
11098	2707	20091	N/A	t	1.5147	1.5147	2.0000	1.1250
11099	2538	20092	N/A	t	3.1407	3.4167	3.5069	3.2838
11101	2543	20092	N/A	t	2.4154	1.7500	3.0577	2.0263
11102	2544	20092	N/A	t	2.3607	2.0000	2.9231	2.5326
11104	2546	20092	N/A	t	2.5079	2.5000	2.9792	2.6346
11105	2598	20092	N/A	t	1.9375	2.0781	0.0000	2.0568
11106	2549	20092	N/A	t	2.6250	1.9375	3.0952	2.7600
11108	2547	20092	N/A	t	2.5581	2.0000	2.6635	2.2500
11109	2548	20092	N/A	t	2.6045	3.1875	3.0417	2.3450
11110	2551	20092	N/A	t	2.3692	2.4167	3.1207	1.8790
11112	2599	20092	N/A	t	2.3182	2.5417	2.2500	2.5000
11113	2552	20092	N/A	t	2.2027	1.8333	2.4762	1.9632
11114	2553	20092	N/A	t	2.5905	2.2500	2.7500	2.6371
11116	2555	20092	N/A	t	2.4056	1.7917	2.9643	2.2700
11117	2556	20092	N/A	t	2.8194	3.9286	2.8750	1.5313
11118	2557	20092	N/A	t	2.5443	1.7000	3.1442	2.1300
11120	2559	20092	N/A	t	2.5671	2.3333	3.4914	1.9324
11121	2560	20092	N/A	t	2.0938	2.1250	2.2813	2.0400
11123	2561	20092	N/A	t	2.0023	2.3750	2.4405	1.8897
11124	2600	20092	N/A	t	2.8194	2.7083	3.7500	2.3750
11125	2601	20092	N/A	t	2.7569	3.0139	4.0000	2.8750
11127	2602	20092	N/A	t	2.2721	1.9737	3.0000	1.0000
11128	2564	20092	N/A	t	1.8090	1.9737	2.2639	1.5313
11129	2565	20092	N/A	t	2.4965	2.7237	3.1250	2.2188
11131	2566	20092	N/A	t	2.5169	3.3421	3.6827	2.7500
11132	2567	20092	N/A	t	2.5704	2.7778	3.1250	2.9531
11133	2568	20092	N/A	t	2.9472	3.3472	3.2500	3.2188
11135	2604	20092	N/A	t	2.2344	2.2941	2.7500	2.5000
11136	2605	20092	N/A	t	2.2230	2.4405	2.5000	2.5192
11137	2570	20092	N/A	t	2.0870	2.2632	2.2917	1.1406
11139	2571	20092	N/A	t	2.6507	3.3833	3.2500	2.2500
11140	2572	20092	N/A	t	2.7955	3.0500	3.0625	2.5000
11142	2608	20092	N/A	t	2.1250	2.9583	2.5000	2.7885
11143	2573	20092	N/A	t	2.2743	2.6974	2.4444	2.3125
11144	2708	20092	N/A	t	3.1333	3.1333	3.0000	2.2500
11146	2575	20092	N/A	t	2.7601	2.8056	3.7500	2.6538
11147	2576	20092	N/A	t	2.3623	3.4605	2.6190	2.2115
11148	2577	20092	N/A	t	1.8090	1.9844	1.9444	1.3906
11150	2578	20092	N/A	t	1.9493	3.1000	2.3056	2.8281
11151	2579	20092	N/A	t	2.4261	2.8438	3.2500	2.9531
11152	2580	20092	N/A	t	2.4891	3.1719	2.8810	2.5577
11154	2582	20092	N/A	t	2.9007	3.0417	2.8750	3.1875
11155	2583	20092	N/A	t	2.3521	2.2969	3.2500	2.0156
11156	2609	20092	N/A	t	2.1544	2.1316	2.9063	2.0833
11158	2610	20092	N/A	t	2.0735	2.0938	2.6563	2.0833
11159	2585	20092	N/A	t	2.3299	3.0250	2.5833	3.1842
11161	2587	20092	N/A	t	2.1007	2.7500	2.3750	2.0968
11162	2588	20092	N/A	t	2.2222	2.3289	2.5278	2.3281
11163	2589	20092	N/A	t	2.2717	2.8684	2.9306	2.6094
11165	2710	20092	N/A	t	2.1842	2.1842	2.7500	2.2500
11166	2611	20092	N/A	t	1.5878	1.3421	1.7500	1.2250
11167	2591	20092	N/A	t	2.4367	3.5000	2.3810	2.5385
11169	2593	20092	N/A	t	2.4595	2.1548	3.2500	2.5250
11170	2594	20092	N/A	t	2.2967	2.7344	2.3611	2.6094
11171	2595	20092	N/A	t	2.4848	3.2188	2.0278	2.4063
11173	2612	20092	N/A	t	1.5662	1.5588	1.5000	1.0000
11174	2613	20092	N/A	t	1.8015	1.9559	1.6250	2.0000
11177	2616	20092	N/A	t	1.7823	2.0893	2.3750	1.7500
11178	2617	20092	N/A	t	1.8986	1.9000	2.3750	1.5000
11180	2619	20092	N/A	t	2.2426	2.2206	2.3750	2.6250
11181	2620	20092	N/A	t	2.0074	2.2059	2.6250	2.6250
11183	2622	20092	N/A	t	1.7941	1.8971	2.8750	1.1250
11184	2623	20092	N/A	t	2.1029	2.1176	2.8750	2.2500
11185	2624	20092	N/A	t	2.6290	2.2143	3.8750	2.7500
11187	2626	20092	N/A	t	1.7794	1.8824	2.3750	1.2500
11188	2627	20092	N/A	t	1.4191	1.4412	1.3750	1.1250
11189	2628	20092	N/A	t	1.6250	1.7941	2.0000	1.0000
11191	2630	20092	N/A	t	2.1486	2.3375	3.7500	2.1250
11192	2631	20092	N/A	t	1.7206	1.7059	1.8750	2.0000
11193	2632	20092	N/A	t	1.9191	1.8971	2.6250	1.3750
11195	2634	20092	N/A	t	2.4779	2.1618	2.8750	3.1250
11196	2635	20092	N/A	t	2.1544	2.0882	2.3750	2.2500
11197	2636	20092	N/A	t	1.6176	1.7647	1.3750	1.5000
11199	2638	20092	N/A	t	1.7647	1.8824	1.8750	1.7500
11200	2639	20092	N/A	t	2.2868	2.2206	2.7500	2.6250
11202	2641	20092	N/A	t	2.0588	1.8088	2.5000	2.2500
11203	2642	20092	N/A	t	2.5662	2.1618	4.0000	2.7500
11204	2643	20092	N/A	t	2.0441	2.2941	2.3750	2.3750
11206	2645	20092	N/A	t	1.8676	1.8235	2.3750	1.5000
11207	2646	20092	N/A	t	1.6250	1.7206	2.0000	1.6250
11208	2647	20092	N/A	t	2.3871	3.0893	3.1250	2.1250
11210	2649	20092	N/A	t	2.3162	2.0735	3.0000	2.8750
11211	2650	20092	N/A	t	2.0809	1.9853	2.8750	1.2500
11212	2651	20092	N/A	t	1.8382	1.6912	2.5000	1.0000
11214	2653	20092	N/A	t	1.6875	1.6324	1.3125	1.7500
11215	2654	20092	N/A	t	1.6618	1.8088	2.5000	1.1250
11216	2655	20092	N/A	t	2.2647	2.1324	2.7500	2.0000
11218	2657	20092	N/A	t	1.7279	1.8676	2.5000	1.0000
11219	2658	20092	N/A	t	2.1103	2.0735	2.7500	2.6250
11220	2659	20092	N/A	t	1.7574	2.0000	2.0000	2.1250
11222	2661	20092	N/A	t	2.1757	2.0750	2.8750	2.0000
11223	2662	20092	N/A	t	2.3382	2.5000	2.6250	2.6250
11224	2663	20092	N/A	t	1.5147	1.5588	2.0000	1.0000
11226	2665	20092	N/A	t	2.1029	2.4412	3.6250	1.6250
11227	2666	20092	N/A	t	1.6838	1.9412	2.1250	2.0000
11229	2668	20092	N/A	t	2.1471	2.1324	2.5000	1.5000
11230	2669	20092	N/A	t	1.2500	1.2941	1.1563	1.0000
11231	2670	20092	N/A	t	1.3088	1.3529	1.3750	1.2500
11233	2672	20092	N/A	t	2.0956	2.4706	2.6250	1.5000
11234	2673	20092	N/A	t	2.0441	2.2500	2.3750	2.1250
11235	2674	20092	N/A	t	1.9559	1.8824	2.7500	1.1250
11237	2676	20092	N/A	t	2.2903	2.3393	2.3750	2.7500
11238	2677	20092	N/A	t	1.4265	1.6176	1.6250	1.0000
11240	2679	20092	N/A	t	2.1765	1.9559	2.3750	2.3750
11241	2680	20092	N/A	t	2.0441	1.7059	2.7500	2.0000
11242	2681	20092	N/A	t	2.6985	2.2059	4.0000	2.3750
11243	2682	20092	N/A	t	1.3162	1.2941	1.2500	1.0000
11245	2684	20092	N/A	t	1.9265	2.2647	2.1250	1.8750
11246	2685	20092	N/A	t	2.0368	2.5294	3.2500	1.5000
11248	2687	20092	N/A	t	2.0882	2.1324	2.7500	2.0000
11249	2688	20092	N/A	t	2.4412	2.7500	3.8750	1.8750
11250	2689	20092	N/A	t	1.7365	1.7500	2.3750	1.6250
11252	2691	20092	N/A	t	2.3676	2.3971	2.5000	2.5000
11253	2692	20092	N/A	t	2.5441	3.1912	3.6250	2.8750
11254	2693	20092	N/A	t	2.3971	2.6618	3.8750	1.2500
11256	2695	20092	N/A	t	1.8382	1.9706	2.5000	1.7500
11257	2696	20092	N/A	t	1.9559	1.8971	2.3750	1.1250
11259	2698	20092	N/A	t	2.1471	1.9559	2.8750	1.5000
11260	2699	20092	N/A	t	2.2759	2.3125	3.0000	2.7500
11261	2700	20092	N/A	t	1.7500	1.6912	2.5000	1.5000
11263	2702	20092	N/A	t	2.0588	2.2206	2.8750	2.0000
11264	2703	20092	N/A	t	2.3162	2.5735	3.7500	2.0000
11265	2704	20092	N/A	t	2.4706	2.0735	3.0000	3.0000
11267	2706	20092	N/A	t	2.5147	2.8824	2.6250	2.1250
11268	2707	20092	N/A	t	1.4779	1.4412	2.2500	1.0625
11269	2538	20093	N/A	t	3.0898	1.9250	3.5069	3.2838
11271	2543	20093	N/A	t	2.3942	1.5000	3.0577	1.9878
11272	2544	20093	N/A	t	2.3607	1.8750	2.9231	2.5326
11273	2546	20093	N/A	t	2.5659	5.0000	2.9792	2.7636
11275	2550	20093	N/A	t	2.3451	1.5000	2.1591	2.1744
11276	2547	20093	N/A	t	2.5259	1.0000	2.6635	2.1830
11278	2551	20093	N/A	t	2.3455	3.2500	3.1207	1.8790
11279	2552	20093	N/A	t	2.1987	2.1250	2.4762	1.9632
11280	2554	20093	N/A	t	2.8662	2.6250	3.6207	2.5341
11282	2556	20093	N/A	t	2.8686	3.5000	2.8750	1.5313
11283	2559	20093	N/A	t	2.5373	2.0000	3.4914	1.9324
11284	2597	20093	N/A	t	2.5395	1.2500	3.1579	2.8462
11286	2565	20093	N/A	t	2.4199	1.5000	2.8571	2.2188
11287	2603	20093	N/A	t	2.2692	2.0000	2.5769	2.7500
11288	2567	20093	N/A	t	2.7208	4.5000	3.3696	2.9531
11290	2604	20093	N/A	t	2.4714	5.0000	2.7500	3.3333
11291	2605	20093	N/A	t	2.2560	2.5000	2.5000	2.5192
11292	2606	20093	N/A	t	2.3625	1.7500	2.7188	2.3750
11294	2607	20093	N/A	t	2.5347	2.7500	2.7500	2.3654
11295	2608	20093	N/A	t	2.1855	2.7500	2.5938	2.7885
11296	2574	20093	N/A	t	2.6928	2.0000	3.5192	2.6719
11298	2577	20093	N/A	t	1.7767	1.5000	1.9444	1.3906
11299	2578	20093	N/A	t	1.9201	3.1250	2.3056	2.9091
11301	2581	20093	N/A	t	2.5856	1.7500	3.1957	2.8289
11302	2583	20093	N/A	t	2.3636	2.5000	3.2174	2.0156
11303	2584	20093	N/A	t	2.4660	2.6250	3.1310	2.4531
11305	2588	20093	N/A	t	2.1667	1.5000	2.5278	2.3281
11306	2590	20093	N/A	t	2.8734	2.7500	3.0595	3.0938
11307	2611	20093	N/A	t	1.6000	3.3750	1.7500	2.0962
11309	2592	20093	N/A	t	2.2283	1.7500	1.8472	2.5000
11310	2593	20093	N/A	t	2.4416	3.5000	3.2500	2.8906
10681	2537	20052	N/A	t	2.8479	2.2105	3.0417	2.7902
10685	2542	20052	N/A	t	1.9929	2.0556	2.1250	1.1250
10632	2535	20001	N/A	t	1.8841	1.8889	1.5000	1.5000
10635	2535	20011	N/A	t	2.3857	2.9375	2.5227	3.0781
10638	2535	20021	N/A	t	2.7050	3.0500	2.5227	3.3500
10643	2537	20022	N/A	t	2.3824	2.5147	2.6250	2.6250
10646	2537	20031	N/A	t	2.4717	2.6316	2.6667	2.5750
10650	2536	20032	N/A	t	2.5524	2.3438	3.0000	2.9063
10654	2536	20033	N/A	t	2.5341	2.2500	3.0000	2.9063
10658	2536	20041	N/A	t	2.6429	3.0417	3.0000	3.1200
10662	2540	20041	N/A	t	1.7059	1.7059	2.5000	1.0000
10689	2542	20053	N/A	t	1.9756	1.8750	2.1538	1.1250
10666	2539	20042	N/A	t	2.7418	3.9375	3.5096	2.9167
10669	2537	20043	N/A	t	2.9531	1.5000	3.0417	3.4643
10673	2536	20051	N/A	t	2.5294	2.2895	3.0000	2.6887
10677	2540	20051	N/A	t	1.9900	2.1316	2.5000	1.4038
10692	2541	20061	N/A	t	2.9279	3.9375	3.5000	2.2500
10696	2545	20061	N/A	t	1.8676	1.8676	2.7500	2.2500
10700	2537	20062	N/A	t	2.7950	3.0000	3.0417	2.7610
10704	2542	20062	N/A	t	2.1184	2.2917	2.2656	1.9091
10708	2546	20062	N/A	t	2.2279	2.2059	3.0000	2.2500
10712	2541	20063	N/A	t	3.0599	3.0000	3.4000	2.4231
10719	2539	20071	N/A	t	2.6520	3.2500	3.4643	3.0690
10716	2546	20063	N/A	t	2.2566	2.5000	3.0000	2.2500
10723	2543	20071	N/A	t	2.6550	2.9375	3.5000	2.2750
10727	2549	20071	N/A	t	2.3333	2.3333	2.2500	3.0000
10730	2548	20071	N/A	t	2.1102	2.3684	2.9167	1.9250
10738	2558	20071	N/A	t	1.4853	1.4853	1.0000	1.0000
10735	2555	20071	N/A	t	2.2059	2.2059	3.0000	1.7500
10746	2542	20072	N/A	t	2.1071	1.7500	2.2656	2.0058
10749	2545	20072	N/A	t	2.3867	3.3158	3.1905	2.6923
10753	2547	20072	N/A	t	2.2979	2.5000	2.6635	1.6923
10757	2553	20072	N/A	t	2.3162	2.5588	2.2500	1.8750
10761	2557	20072	N/A	t	2.4632	2.9706	3.8750	1.7500
11311	2612	20093	N/A	t	1.5655	1.5625	1.5833	1.0000
11312	2617	20093	N/A	t	1.8056	1.3750	1.9167	1.5000
11314	2622	20093	N/A	t	1.9167	2.7500	2.8333	1.1250
11315	2624	20093	N/A	t	2.5676	2.2500	3.8750	2.7500
10631	2535	19991	N/A	t	5.0000	5.0000	5.0000	0.0000
11316	2629	20093	N/A	t	2.8526	2.5000	3.4167	2.7500
11318	2632	20093	N/A	t	1.9615	2.2500	2.5000	1.3750
11319	2634	20093	N/A	t	2.4487	2.2500	2.6667	3.1250
11320	2635	20093	N/A	t	2.1346	2.0000	2.2500	2.2500
11322	2637	20093	N/A	t	1.8846	1.0000	1.7500	3.7500
11323	2638	20093	N/A	t	1.7628	1.7500	1.8333	1.7500
11325	2644	20093	N/A	t	1.6250	1.7500	1.6250	1.3750
11326	2645	20093	N/A	t	1.7750	1.2500	2.3750	1.5000
11327	2647	20093	N/A	t	2.2647	1.0000	3.1250	2.1250
11329	2649	20093	N/A	t	2.2703	3.3750	3.0000	3.1250
11330	2650	20093	N/A	t	2.0705	2.0000	2.5833	1.2500
11331	2652	20093	N/A	t	2.1987	1.5000	2.6667	1.8750
11333	2662	20093	N/A	t	2.2949	2.0000	2.4167	2.6250
11334	2663	20093	N/A	t	1.4563	1.1250	2.0000	1.0625
11335	2664	20093	N/A	t	2.4744	2.7500	3.5833	1.8750
11337	2669	20093	N/A	t	1.2162	1.0000	1.0962	1.0000
11338	2670	20093	N/A	t	1.2692	1.0000	1.2500	1.2500
11339	2672	20093	N/A	t	2.2115	3.0000	2.7500	1.5000
11341	2674	20093	N/A	t	1.8974	1.5000	2.3333	1.1250
11342	2676	20093	N/A	t	2.3542	2.7500	2.5000	2.7500
11343	2678	20093	N/A	t	1.9295	2.0000	2.1667	2.1250
11345	2680	20093	N/A	t	2.0385	2.0000	2.5000	2.0000
11346	2681	20093	N/A	t	2.6090	2.0000	3.3333	2.3750
11348	2683	20093	N/A	t	2.3333	2.2500	3.4167	2.0000
11349	2685	20093	N/A	t	1.9038	1.0000	2.5000	1.5000
11350	2688	20093	N/A	t	2.4487	2.5000	3.4167	1.8750
11352	2691	20093	N/A	t	2.3036	2.0313	2.5000	2.5000
11353	2692	20093	N/A	t	2.4744	2.0000	3.0833	2.8750
11354	2693	20093	N/A	t	2.3462	2.0000	3.2500	1.2500
11356	2695	20093	N/A	t	1.7905	1.2500	2.5000	1.7500
11357	2696	20093	N/A	t	1.9615	2.0000	2.2500	1.1250
11358	2697	20093	N/A	t	2.5256	5.0000	4.1667	1.2500
11360	2699	20093	N/A	t	2.6765	5.0000	4.0000	2.7500
11361	2700	20093	N/A	t	1.7500	1.7500	2.2500	1.5000
11362	2703	20093	N/A	t	2.2115	1.5000	3.0000	2.0000
11364	2705	20093	N/A	t	1.7756	1.0000	1.9167	1.7500
11365	2706	20093	N/A	t	2.4808	2.2500	2.5000	2.1250
11367	2541	20101	N/A	t	3.0000	3.0357	3.3226	2.9824
11368	2542	20101	N/A	t	2.0634	1.5000	2.2656	1.8482
11369	2543	20101	N/A	t	2.4243	2.7500	3.0577	2.1604
11371	2546	20101	N/A	t	2.5382	2.2083	2.9792	2.7276
11372	2598	20101	N/A	t	2.5306	3.5833	0.0000	2.5608
11373	2549	20101	N/A	t	2.6719	3.0625	3.0952	2.9338
11375	2547	20101	N/A	t	2.5760	5.0000	2.6635	2.1830
11376	2548	20101	N/A	t	2.6062	2.9375	3.0417	2.2545
11378	2562	20101	N/A	t	2.3750	2.1667	3.1316	2.2581
11379	2599	20101	N/A	t	2.2959	2.2500	2.2500	2.1923
11380	2552	20101	N/A	t	2.2898	2.8333	2.4762	2.0969
11382	2554	20101	N/A	t	2.9956	3.8500	3.6207	2.8214
11383	2555	20101	N/A	t	2.4190	2.5000	2.9643	2.3041
11384	2556	20101	N/A	t	2.8477	3.1250	3.0473	1.6447
11386	2558	20101	N/A	t	2.2750	2.0000	2.3646	1.9620
11387	2559	20101	N/A	t	2.6093	3.0000	3.4914	2.1683
11388	2560	20101	N/A	t	2.0469	1.8026	2.2813	1.9375
11390	2561	20101	N/A	t	2.1329	2.9167	2.4405	2.2449
11391	2600	20101	N/A	t	2.5441	1.8833	3.5000	1.7692
11392	2601	20101	N/A	t	2.6625	2.4605	3.4861	2.7885
11394	2602	20101	N/A	t	2.2170	2.1184	3.0000	1.7750
11395	2711	20101	N/A	t	2.9167	2.9167	2.7500	3.0000
11397	2565	20101	N/A	t	2.5057	2.8750	2.8571	2.6705
10765	2561	20072	N/A	t	1.6912	1.6618	2.3750	1.1250
10953	2559	20091	N/A	t	2.6139	3.4167	3.4914	1.7500
10767	2542	20073	N/A	t	2.1071	0.0000	2.2656	2.0058
11033	2642	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
10768	2543	20073	N/A	t	2.5933	2.3571	3.5000	2.2750
10771	2549	20073	N/A	t	3.1026	2.1250	3.6250	4.0000
10774	2551	20073	N/A	t	2.1090	1.7500	3.0833	1.5000
10957	2600	20091	N/A	t	2.9306	2.9306	5.0000	1.7500
10779	2539	20081	N/A	t	2.6061	2.7917	3.4643	2.8000
10782	2543	20081	N/A	t	2.6042	2.6471	3.1875	2.2692
10786	2549	20081	N/A	t	2.8611	2.2333	3.3333	3.0833
10790	2551	20081	N/A	t	2.1591	2.2813	2.9891	1.4000
10793	2553	20081	N/A	t	2.3942	2.7500	2.5000	1.8750
10797	2557	20081	N/A	t	2.3448	2.2237	3.1875	1.9500
10801	2561	20081	N/A	t	1.8160	2.0395	2.4167	1.1750
10805	2566	20081	N/A	t	2.0294	2.0294	3.0000	2.2500
10809	2570	20081	N/A	t	2.0882	2.0882	2.0000	1.0000
10813	2574	20081	N/A	t	3.1471	3.1471	5.0000	2.5000
10961	2564	20091	N/A	t	1.7500	1.8421	2.1667	1.1750
10817	2578	20081	N/A	t	1.6765	1.6765	2.2500	1.0000
10820	2581	20081	N/A	t	2.0882	2.0882	2.7500	1.0000
10824	2585	20081	N/A	t	3.0588	3.0588	2.7500	5.0000
10828	2589	20081	N/A	t	2.2941	2.2941	3.0000	2.2500
10964	2566	20091	N/A	t	2.3233	2.1316	3.4375	2.0750
10832	2593	20081	N/A	t	2.3824	2.3824	3.0000	2.0000
10836	2538	20082	N/A	t	3.0301	3.0769	3.3083	3.0000
10839	2542	20082	N/A	t	2.0763	1.8750	2.2656	1.8679
10843	2546	20082	N/A	t	2.5381	2.8500	2.9792	2.7500
10847	2548	20082	N/A	t	2.5236	2.9500	3.0417	2.4113
10850	2552	20082	N/A	t	2.1667	2.3289	2.4762	1.7308
10854	2556	20082	N/A	t	2.7266	2.0313	3.0543	1.4167
10858	2560	20082	N/A	t	2.0978	2.1563	2.2143	2.1000
10862	2564	20082	N/A	t	1.6985	1.6029	2.2500	1.1250
10866	2568	20082	N/A	t	2.5588	2.7206	3.0000	2.8750
10869	2571	20082	N/A	t	2.0809	2.1324	2.5000	2.3750
10873	2575	20082	N/A	t	3.0735	3.3676	4.0000	2.2500
10877	2579	20082	N/A	t	2.1176	2.0882	2.6250	1.8750
10881	2583	20082	N/A	t	2.3952	1.8824	3.7500	1.7500
10885	2587	20082	N/A	t	1.9559	2.0294	2.3750	1.0000
10888	2590	20082	N/A	t	2.5294	2.5735	2.7500	2.6250
10892	2594	20082	N/A	t	2.0956	2.3676	2.6250	2.2500
10896	2539	20083	N/A	t	2.5451	2.0000	3.4643	2.7264
10900	2547	20083	N/A	t	2.4917	2.1667	2.6635	2.2568
10969	2605	20091	N/A	t	1.9375	1.9375	0.0000	3.0000
10903	2553	20083	N/A	t	2.5616	2.7500	2.7500	2.9423
10972	2571	20091	N/A	t	2.4434	3.0921	3.3333	2.0250
10904	2554	20083	N/A	t	2.7571	2.7500	3.3750	2.4423
10907	2558	20083	N/A	t	2.3000	3.7500	2.3646	1.8654
10910	2566	20083	N/A	t	2.4167	2.7500	3.5833	2.1250
10914	2574	20083	N/A	t	2.7692	2.7500	3.5000	3.2500
10918	2579	20083	N/A	t	2.4872	5.0000	3.4167	1.8750
10922	2585	20083	N/A	t	2.2297	1.6563	2.2500	3.1250
10926	2591	20083	N/A	t	1.9709	2.3611	1.8333	1.5000
10929	2594	20083	N/A	t	2.0513	1.7500	2.3333	2.2500
10934	2543	20091	N/A	t	2.5045	1.9231	3.0577	2.1827
10937	2546	20091	N/A	t	2.5085	2.5000	2.9792	2.6750
10941	2547	20091	N/A	t	2.5704	2.7500	2.6635	2.3163
10945	2599	20091	N/A	t	2.0500	2.0500	2.2500	2.0000
10949	2555	20091	N/A	t	2.4321	2.5000	2.9643	2.2344
10976	2573	20091	N/A	t	2.1226	2.1316	2.3333	2.2000
10980	2577	20091	N/A	t	1.7589	1.4412	2.0833	1.2500
10983	2580	20091	N/A	t	2.2830	2.5526	2.8333	1.8250
10987	2609	20091	N/A	t	2.1833	2.1833	3.0000	1.5000
10991	2586	20091	N/A	t	2.5647	2.5132	3.4375	2.6000
10995	2590	20091	N/A	t	2.6830	2.8971	3.1944	2.7750
10999	2593	20091	N/A	t	2.5802	2.2857	3.5833	2.5250
11002	2596	20091	N/A	t	2.6276	2.8000	3.5833	3.5833
11037	2646	20091	N/A	t	1.5294	1.5294	1.7500	1.5000
11007	2616	20091	N/A	t	1.5294	1.5294	1.7500	1.7500
11010	2619	20091	N/A	t	2.2647	2.2647	2.0000	2.7500
11014	2623	20091	N/A	t	2.0882	2.0882	2.7500	2.5000
11018	2627	20091	N/A	t	1.3971	1.3971	1.0000	1.0000
11022	2631	20091	N/A	t	1.7353	1.7353	2.0000	1.7500
11062	2671	20091	N/A	t	1.2647	1.2647	1.0000	1.0000
11026	2635	20091	N/A	t	2.2206	2.2206	2.0000	2.5000
11029	2638	20091	N/A	t	1.6471	1.6471	2.0000	1.7500
11039	2648	20091	N/A	t	2.7059	2.7059	5.0000	2.0000
11066	2675	20091	N/A	t	1.3529	1.3529	1.0000	1.5000
11040	2649	20091	N/A	t	2.5588	2.5588	3.0000	3.0000
11043	2652	20091	N/A	t	2.1912	2.1912	2.5000	1.7500
11069	2678	20091	N/A	t	2.0735	2.0735	2.2500	2.2500
11047	2656	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
11050	2659	20091	N/A	t	1.5147	1.5147	1.2500	1.5000
11054	2663	20091	N/A	t	1.4706	1.4706	2.0000	1.0000
11058	2667	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
11073	2682	20091	N/A	t	1.3382	1.3382	1.2500	1.0000
11077	2686	20091	N/A	t	1.3824	1.3824	1.2500	1.0000
11081	2690	20091	N/A	t	1.8971	1.8971	3.0000	2.0000
11085	2694	20091	N/A	t	2.4265	2.4265	3.0000	2.7500
11089	2698	20091	N/A	t	2.3382	2.3382	3.0000	1.7500
11092	2701	20091	N/A	t	2.3088	2.3088	2.7500	2.2500
11096	2705	20091	N/A	t	1.6176	1.6176	1.7500	1.7500
11100	2541	20092	N/A	t	3.0171	2.0357	3.3226	3.0224
11103	2545	20092	N/A	t	2.4675	2.2500	3.1667	2.7500
11107	2550	20092	N/A	t	2.3736	1.8750	2.1591	2.2250
11111	2562	20092	N/A	t	2.4286	2.4583	3.1316	2.2237
11115	2554	20092	N/A	t	2.8817	3.1538	3.7500	2.5341
11119	2558	20092	N/A	t	2.3143	1.9000	2.3646	1.9485
11122	2597	20092	N/A	t	2.6111	2.9219	3.1579	2.8462
11126	2563	20092	N/A	t	2.2857	3.4265	2.6111	2.4219
11130	2603	20092	N/A	t	2.3182	3.0417	2.7500	3.0000
11134	2569	20092	N/A	t	2.2992	2.8906	3.1250	2.2188
11138	2606	20092	N/A	t	2.4122	2.3553	2.7188	2.5833
11141	2607	20092	N/A	t	2.5000	2.3684	2.7500	2.3654
11145	2574	20092	N/A	t	2.7468	3.0375	3.5192	2.6719
11149	2709	20092	N/A	t	2.2500	2.2500	3.0000	2.5000
11153	2581	20092	N/A	t	2.6604	3.2250	3.3750	3.0781
11157	2584	20092	N/A	t	2.4533	3.1316	3.1944	2.4531
11160	2586	20092	N/A	t	2.5507	2.8947	3.3804	3.1250
11164	2590	20092	N/A	t	2.8800	3.4605	3.0595	3.0938
11168	2592	20092	N/A	t	2.2500	2.0938	1.8472	2.5000
11172	2596	20092	N/A	t	2.5692	2.3906	3.5833	3.6000
11344	2679	20093	N/A	t	2.0577	1.2500	2.0000	2.3750
11175	2614	20092	N/A	t	1.9118	1.9265	2.3750	1.8750
11347	2682	20093	N/A	t	1.2688	1.0000	1.2500	1.0000
11176	2615	20092	N/A	t	2.2353	2.2353	2.5000	2.8750
11179	2618	20092	N/A	t	2.3088	1.8676	2.3750	3.6250
11182	2621	20092	N/A	t	1.5000	1.5147	1.8750	1.2500
11186	2625	20092	N/A	t	1.9926	1.7941	2.5000	2.1250
11190	2629	20092	N/A	t	2.9044	2.7941	3.8750	2.7500
11194	2633	20092	N/A	t	1.4338	1.4265	1.5000	1.2500
11198	2637	20092	N/A	t	2.0147	2.4118	2.1250	3.7500
11201	2640	20092	N/A	t	1.9632	2.0735	2.2500	1.7500
11205	2644	20092	N/A	t	1.6029	1.8529	1.6250	1.3750
11209	2648	20092	N/A	t	2.3162	1.9265	3.7500	2.2500
11213	2652	20092	N/A	t	2.3015	2.4118	3.2500	1.8750
11217	2656	20092	N/A	t	1.8382	2.1912	2.1250	1.5000
11351	2689	20093	N/A	t	1.7381	1.7500	2.1667	1.6250
11221	2660	20092	N/A	t	1.5147	1.7647	2.0000	1.0000
11225	2664	20092	N/A	t	2.4338	2.8824	4.0000	1.8750
11228	2667	20092	N/A	t	2.2794	2.2206	2.5000	2.6250
11232	2671	20092	N/A	t	1.4338	1.6029	1.1250	1.0000
11236	2675	20092	N/A	t	1.3971	1.4412	1.3750	1.3750
11239	2678	20092	N/A	t	1.9191	1.7647	2.2500	2.1250
11355	2694	20093	N/A	t	2.1857	1.3750	3.0000	2.8750
11244	2683	20092	N/A	t	2.3456	2.6176	4.0000	2.0000
11247	2686	20092	N/A	t	1.3824	1.3824	1.2500	1.0000
11251	2690	20092	N/A	t	2.1397	2.3824	3.0000	1.7500
11255	2694	20092	N/A	t	2.3534	2.2500	3.0000	2.8750
11258	2697	20092	N/A	t	2.1618	1.6618	3.7500	1.2500
11262	2701	20092	N/A	t	2.7941	3.2794	3.8750	3.6250
11266	2705	20092	N/A	t	1.8897	2.1618	2.3750	1.7500
11270	2541	20093	N/A	t	2.9985	2.0000	3.3226	3.0224
11274	2598	20093	N/A	t	1.9194	1.7500	0.0000	2.0568
11277	2548	20093	N/A	t	2.5803	1.5000	3.0417	2.2972
11281	2555	20093	N/A	t	2.3844	1.7500	2.9643	2.2700
11285	2601	20093	N/A	t	2.7561	2.7500	3.5833	2.8750
11289	2568	20093	N/A	t	2.9219	2.7222	3.1000	3.2188
11293	2571	20093	N/A	t	2.6133	2.2500	2.9891	2.2500
11297	2575	20093	N/A	t	2.7110	1.5000	3.7500	2.6538
11300	2579	20093	N/A	t	2.3885	1.5000	3.2500	2.7237
11304	2586	20093	N/A	t	2.5000	1.8750	3.3804	2.9474
11308	2591	20093	N/A	t	2.5353	5.0000	2.3810	3.0000
11313	2618	20093	N/A	t	2.2692	2.0000	2.2500	3.6250
11317	2631	20093	N/A	t	1.6603	1.2500	1.6667	2.0000
11321	2636	20093	N/A	t	1.6000	1.5000	1.3750	1.5000
11324	2641	20093	N/A	t	2.1154	2.5000	2.5000	2.2500
11328	2648	20093	N/A	t	2.6603	5.0000	4.1667	2.2500
11332	2653	20093	N/A	t	1.6284	1.2500	1.2885	1.7500
11336	2665	20093	N/A	t	1.9615	1.0000	2.7500	1.6250
11359	2698	20093	N/A	t	2.2564	3.0000	2.9167	1.5000
11340	2673	20093	N/A	t	1.9250	1.2500	2.3750	2.1250
11363	2704	20093	N/A	t	2.5385	3.0000	3.0000	3.0000
11370	2544	20101	N/A	t	2.3429	2.1250	2.9231	2.4279
11374	2550	20101	N/A	t	2.3905	2.7656	2.1591	2.3347
11377	2551	20101	N/A	t	2.4316	2.9583	3.1207	2.0349
11381	2553	20101	N/A	t	2.5289	2.1250	2.7500	2.4628
11385	2557	20101	N/A	t	2.6088	2.9500	3.1442	2.3919
11389	2597	20101	N/A	t	2.7397	3.4531	3.1579	2.6875
11393	2563	20101	N/A	t	2.3077	2.4000	2.6111	2.3553
11396	2564	20101	N/A	t	1.7472	1.5000	2.2639	1.4919
10652	2538	20032	N/A	t	2.3400	2.2143	2.2500	2.5000
11366	2538	20101	N/A	t	3.1306	4.0500	3.3681	3.4133
10742	2537	20072	N/A	t	2.7805	2.0000	3.0417	2.7610
11071	2680	20091	N/A	t	5.0000	5.0000	5.0000	5.0000
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

