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

SELECT pg_catalog.setval('classes_classid_seq', 13137, true);


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

SELECT pg_catalog.setval('persons_personid_seq', 2016, true);


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

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 38075, true);


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

SELECT pg_catalog.setval('students_studentid_seq', 2006, true);


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

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 8580, true);


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
11336	19991	98	TFQ1	418
11337	19991	116	WBC	919
11338	19991	117	11	3557
11339	19991	94	MHQ3	3983
11340	19991	81	MHW	6800
11341	19991	55	TFR2	9661
11342	19991	106	MTHFX6	9764
11343	20001	33	TFR3	12225
11344	20001	108	MTHFW3	35242
11345	20001	110	MTHFI	37302
11346	20001	102	MHR-S	41562
11347	20001	2	HMXY	44901
11348	20002	109	MHW2	35238
11349	20002	118	TFQ	35271
11350	20002	111	MTHFD	37331
11351	20002	3	TFXY	44911
11352	20002	5	MHX1	44913
11353	20003	118	X3-2	35181
11354	20003	95	X1-1	38511
11355	20011	34	TFW-3	11676
11356	20011	119	MHX	35252
11357	20011	103	TFY2	40385
11358	20011	6	TFR	44922
11359	20011	5	W1	44944
11360	20012	113	MHX3	13972
11361	20012	103	MHU1	40344
11362	20012	11	MHY	44919
11363	20012	19	TFR	44921
11364	20012	24	TFY	44939
11365	20012	114	TFZ	45440
11366	20013	39	X6-D	14922
11367	20013	11	X3	44906
11368	20021	8	TFY	44920
11369	20021	6	TFW	44922
11370	20021	7	MHXY	44925
11371	20021	120	TFV	44931
11372	20021	114	MHW	45405
11373	20021	41	TFX2	12350
11374	20021	106	MTHFU1	35138
11375	20021	98	TFY1	39648
11376	20021	81	MHY	41805
11377	20021	1	MHVW	44901
11378	20021	41	TFV6	12389
11379	20021	106	MTHFW4	35161
11380	20021	94	MHV1	38510
11381	20021	81	TFR	41807
11382	20021	1	MHXY	44902
11383	20022	19	TFX	44918
11384	20022	9	TFV	44925
11385	20022	27	TFW	44927
11386	20022	70	TFR2	33729
11387	20022	107	MTHFV1	35165
11388	20022	95	MHX	38533
11389	20022	100	MHW2	39648
11390	20022	2	MHRU	44900
11391	20022	71	MHR	34200
11392	20022	107	MTHFW3	35173
11393	20022	100	MHV	39646
11394	20022	82	TFU	41814
11395	20022	2	MHXY	44901
11396	20031	121	MHW2	16602
11397	20031	17	MHX	54566
11398	20031	20	WSVX2	54582
11399	20031	14	TFVW	54603
11400	20031	122	MHY	54604
11401	20031	123	MHW	14482
11402	20031	63	MHV	15620
11403	20031	109	TFU2	39320
11404	20031	110	MTHFX	41352
11405	20031	93	MHU1	46314
11406	20031	2	TFVW	54555
11407	20031	34	TFV-2	13921
11408	20031	108	MTHFW1	39247
11409	20031	110	MTHFD	41419
11410	20031	93	TFY2	46310
11411	20031	3	MHXY	54560
11412	20031	43	MHW2	14467
11413	20031	106	MTHFX8	39221
11414	20031	82	TFR	41908
11415	20031	1	MHRU	54550
11416	20031	88	(1)	62806
11417	20031	41	TFQ2	14425
11418	20031	106	MTHFW6	39211
11419	20031	82	MHQ	41905
11420	20031	103	MHX2	44662
11421	20031	1	TFRU	54553
11422	20032	20	WSVX2	54595
11423	20032	42	TFW1	14435
11424	20032	73	MTHW	38073
11425	20032	119	MHX	39321
11426	20032	94	TFX2	45813
11427	20032	3	FTRU	54560
11428	20032	5	MHU	54561
11429	20032	109	TFV1	39278
11430	20032	119	MHW	39320
11431	20032	111	MTHFV	41488
11432	20032	95	TFX1	45839
11433	20032	5	MHX	54562
11434	20032	42	TFU2	14432
11435	20032	107	MTHFR3	39215
11436	20032	81	MHW	41902
11437	20032	102	MHU	45213
11438	20032	2	TFVW	54558
11439	20032	107	MTHFW2	39236
11440	20032	98	WSR2	42601
11441	20032	102	TFQ	45220
11442	20032	94	TFR3	45801
11443	20032	1	MHRU	54552
11444	20033	110	Y3	41355
11445	20033	111	Y3	41362
11446	20033	43	X3A	14411
11447	20033	98	X1-1	42451
11448	20033	108	Z1-2	39183
11449	20041	62	MHX1	15613
11450	20041	119	TFW	39305
11451	20041	7	HMRU	54555
11452	20041	8	TFR	54569
11453	20041	6	TFU	54572
11454	20041	112	MHV	70025
11455	20041	36	TFR-1	13856
11456	20041	35	WIJK	15505
11457	20041	109	MHW2	39395
11458	20041	114	TFW	52451
11459	20041	5	MHU	54563
11460	20041	31	MHR1	15507
11461	20041	108	MTHFW2	39255
11462	20041	110	MTHFX	41354
11463	20041	94	MHU5	45761
11464	20041	3	TFRU	54561
11465	20041	41	MHX3	14423
11466	20041	108	MTHFQ2	39369
11467	20041	110	MTHFD	41350
11468	20041	81	MHW	41902
11469	20041	2	TFVW	54557
11470	20041	41	TFQ1	14428
11471	20041	106	MTHFW2	39208
11472	20041	76	MHX	40826
11473	20041	98	TFX2	42471
11474	20041	1	MHRU	54550
11475	20042	113	MHX1	15672
11476	20042	124	TFY	47972
11477	20042	19	MHR	54564
11478	20042	12	TFRU	54573
11479	20042	24	MHU	54597
11480	20042	11	TFV	54598
11481	20042	42	MHW1	14429
11482	20042	55	TFU1	15568
11483	20042	113	MHV3	15668
11484	20042	41	MHR	14401
11485	20042	73	MTHU-2	38052
11486	20042	109	TFU2	39271
11487	20042	119	TFR	39311
11488	20042	110	MTHFI	41352
11489	20042	5	MHX	54561
11490	20042	43	MHV2	14460
11491	20042	119	TFQ	39178
11492	20042	109	TFR	39268
11493	20042	111	MTHFD	41379
11494	20042	42	MHU1	14421
11495	20042	107	MTHFQ2	39209
11496	20042	95	MHR1	45780
11497	20042	93	TFR3	46324
11498	20042	2	MHXY	54557
11499	20043	39	X3-A	16057
11500	20043	111	Y4	41354
11501	20043	84	X4	41905
11502	20043	103	X-5-2	44660
11503	20043	111	Y1	41353
11504	20043	109	X1-1	39196
11505	20043	108	Z1-4	39187
11506	20051	114	MHR	52454
11507	20051	17	MHX	54567
11508	20051	8	TFY	54570
11509	20051	122	MHU	54577
11510	20051	20	WSVX2	54581
11511	20051	27	WRU	54588
11512	20051	21	FR	54592
11513	20051	114	TFU	52455
11514	20051	17	MHU	54566
11515	20051	6	TFW	54573
11516	20051	7	HMXY	54575
11517	20051	112	MHR	69953
11518	20051	113	TFU2	15702
11519	20051	48	MTU	19924
11520	20051	119	TFR	39309
11521	20051	111	MTHFI	41439
11522	20051	94	MHX3	45771
11523	20051	5	TFX	54562
11524	20051	62	TFR1	15564
11525	20051	119	TFQ	39308
11526	20051	93	TFV1	46329
11527	20051	3	MHXY	54559
11528	20051	71	TFX	38890
11529	20051	108	MTHFU1	39242
11530	20051	110	MTHFI	41412
11531	20051	29	WSR	54589
11532	20051	41	TFV2	14437
11533	20051	70	MHV	37502
11534	20051	106	MTHFW4	39212
11535	20051	94	TFQ2	45773
11536	20051	1	MHXY	54551
11537	20051	41	MHU3	14410
11538	20051	71	MHQ	38678
11539	20051	107	MTHFR	39228
11540	20051	98	TFQ3	42463
11541	20051	1	TFVW	54553
11542	20052	76	MHX	40806
11543	20052	115	MHL	52457
11544	20052	115	MHLM	52459
11545	20052	14	TFRU	54570
11546	20052	9	TFW	54573
11547	20052	27	WRU	54575
11548	20052	22	WSVX2	54584
11549	20052	42	MHY	14425
11550	20052	14	HMVW	54568
11551	20052	122	MHU	54571
11552	20052	28	TFV	54576
11553	20052	12	TFXY	54579
11554	20052	21	TR	54580
11555	20052	125	MHTFX	15078
11556	20052	126	MHTFX	15079
11557	20052	60	BMR1	33107
11558	20052	111	MTHFD	41375
11559	20052	103	MHV2	44695
11560	20052	91	MI1	67273
11561	20052	61	MHX1	15613
11562	20052	109	MHV	39215
11563	20052	119	TFV	39279
11564	20052	111	MTHFR	41467
11565	20052	94	MHU2	45759
11566	20052	5	TFU	54561
11567	20052	39	MHR-1	16052
11568	20052	107	MTHFV4	39184
11569	20052	81	TFR	41903
11570	20052	95	TFU1	45811
11571	20052	2	MHXY	54554
11572	20052	108	MTHFX3	39209
11573	20052	110	MTHFV	41353
11574	20052	102	MHQ	44152
11575	20052	2	TFRU	54555
11576	20053	87	MTWHFAB	47950
11577	20053	18	X2	54550
11578	20053	109	X3-2	39181
11579	20053	107	Z3-2	39170
11580	20053	70	X3	37501
11581	20053	109	X2	39179
11582	20061	114	WIJF	52455
11583	20061	114	WIJT1	52456
11584	20061	19	TFX	54565
11585	20061	20	MHXYM2	54582
11586	20061	113	TFZ1	15681
11587	20061	109	MHV	39271
11588	20061	114	WIJT2	52457
11589	20061	6	HMRU	54569
11590	20061	7	TFRU	54574
11591	20061	8	GS2	54603
11592	20061	37	TFX-2	13886
11593	20061	108	MTHFW1	39186
11594	20061	110	MTHFV	41356
11595	20061	93	TFR2	46327
11596	20061	3	MHRU	54557
11597	20061	39	MHX2	16069
11598	20061	111	MTHFV	41382
11599	20061	3	TFXY	54560
11600	20061	5	TFU	54561
11601	20061	29	WSR	54597
11602	20061	41	TFV2	14520
11603	20061	70	MHU	37501
11604	20061	106	MTHFW1	39189
11605	20061	99	TFR	42466
11606	20061	1	MHXY	54551
11607	20061	39	MHR3	16054
11608	20061	106	MTHFQ1	39150
11609	20061	83	MHW	41434
11610	20061	104	TFU	47970
11611	20061	1	TFVW	54553
11612	20061	43	MHV2	14551
11613	20061	106	MTHFX1	39197
11614	20061	76	TFU	40807
11615	20061	105	MHQ	43553
11616	20061	80	TFW	40252
11617	20061	100	MHY2	42478
11618	20061	1	WSRU	54599
11619	20061	41	MHR2	14493
11620	20061	106	MTHFY5	39299
11621	20061	94	TFW2	45853
11622	20061	93	MHV6	46380
11623	20061	41	TFU3	14518
11624	20061	106	MTHFX4	39200
11625	20061	82	MHY	41911
11626	20061	94	TFR3	45763
11627	20061	1	SWRU	54600
11628	20062	115	MHK	52449
11629	20062	115	MHKH	52450
11630	20062	22	W1	54595
11631	20062	36	MHQ-2	13851
11632	20062	42	TFU1	14589
11633	20062	119	TFQ	39314
11634	20062	3	MHXY	54559
11635	20062	24	MHW	54571
11636	20062	100	TFU1	42493
11637	20062	115	MHKM	52451
11638	20062	11	MHY	54565
11639	20062	14	TFVW	54567
11640	20062	9	FTXY	54570
11641	20062	12	MHVW	54573
11642	20062	63	TFX1	15613
11643	20062	108	MTHFR3	39259
11644	20062	111	MTHFY	41440
11645	20062	98	MHV2	42456
11646	20062	5	TFU	54562
11647	20062	119	TFR	39315
11648	20062	81	MHR	41900
11649	20062	100	MHW1	42487
11650	20062	93	TFX2	46335
11651	20062	7	WRUVX	54602
11652	20062	39	MHR1	16054
11653	20062	107	MTHFU5	39212
11654	20062	94	TFV2	45786
11655	20062	93	MHV5	46316
11656	20062	2	TFXY	54558
11657	20062	40	TFX1	14591
11658	20062	62	MHU2	15598
11659	20062	106	MTHFW-1	39184
11660	20062	100	MHX	42489
11661	20062	2	TFRU	54557
11662	20062	36	MHV-2	13859
11663	20062	40	TFV1	14476
11664	20062	47	Z	19918
11665	20062	107	MTHFW1	39201
11666	20062	2	MHRU	54552
11667	20062	41	TFX	14415
11668	20062	107	MTHFV6	39225
11669	20062	98	TFQ1	42460
11670	20062	93	TFR	46328
11671	20062	42	MHR	14417
11672	20062	106	MTHFQ-1	39197
11673	20062	100	MHW2	42488
11674	20062	95	TFV2	45812
11675	20062	107	MTHFQ6	39395
11676	20062	98	TFX1	42466
11677	20062	105	TFW	43616
11678	20063	18	X2	54550
11679	20063	111	Y3	41353
11680	20063	113	X1B	15527
11681	20063	107	Z1-A	39176
11682	20063	110	Y2	41350
11683	20063	110	Y3	41351
11684	20063	107	Z2-C	39175
11685	20063	36	X2-A	13855
11686	20063	127	X1A	15540
11687	20071	114	TFL	52463
11688	20071	114	TFLH	52464
11689	20071	8	TFX3	54561
11690	20071	6	TFRU	54562
11691	20071	19	TFV1	54567
11692	20071	7	MWVWXY	54583
11693	20071	27	WRU2	54585
11694	20071	21	MH	54594
11695	20071	55	MHU1	15574
11696	20071	17	TFU	54566
11697	20071	16	MHV1	54569
11698	20071	20	W2	54571
11699	20071	27	WRU1	54579
11700	20071	21	MQ	54593
11701	20071	112	TFW	70005
11702	20071	119	TFW	39298
11703	20071	109	MHQ	39388
11704	20071	6	TMRU	54563
11705	20071	8	TFX2	54560
11706	20071	17	MHU	54565
11707	20071	19	TFV2	54568
11708	20071	50	MHV1	15526
11709	20071	107	MTHFW2	39228
11710	20071	110	MTHFX	41361
11711	20071	3	TFRU	54576
11712	20071	108	MTHFU2	39237
11713	20071	110	MTHFQ1	41359
11714	20071	93	MHY2	46327
11715	20071	102	TFY	47991
11716	20071	3	MHVW	54574
11717	20071	71	TFU	38606
11718	20071	108	MTHFX	39248
11719	20071	93	TFV1	46370
11720	20071	104	MHV	47978
11721	20071	3	MHRU	54573
11722	20071	128	TFW	15019
11723	20071	108	MTHFU3	39243
11724	20071	104	TFR-1	44162
11725	20071	107	MTHFR2	39410
11726	20071	110	MTHFV	41360
11727	20071	93	TFU2	46331
11728	20071	1	HMXY	54552
11729	20071	73	MHR	38055
11730	20071	108	MTHFU7	39239
11731	20071	110	MTHFI	41357
11732	20071	1	FTXY	54555
11733	20071	63	TFR1	15635
11734	20071	71	TFW	38833
11735	20071	108	MTHFX3	39396
11736	20071	110	MTHFD	41356
11737	20071	71	TFR	38605
11738	20071	108	MTHFW1	39235
11739	20071	74	TFU	52910
11740	20071	43	TFU1	14447
11741	20071	106	MTHFX2	39212
11742	20071	76	TFY	40809
11743	20071	1	HMRU1	54550
11744	20071	43	TFX	14453
11745	20071	70	MHR	37500
11746	20071	106	MTHFW11	39187
11747	20071	100	MHU	42540
11748	20071	1	FTRU	54553
11749	20071	43	TFV	14449
11750	20071	106	MTHFX-6	39342
11751	20071	94	TFR4	45781
11752	20071	1	HMVW	54551
11753	20071	43	TFU2	14448
11754	20071	70	TFV	37508
11755	20071	100	MHR	42539
11756	20071	42	MHW	14433
11757	20071	106	MTHFR3	39218
11758	20071	94	MHU3	45758
11759	20071	74	TFV	52911
11760	20071	82	MHU	41900
11761	20071	93	TFW1	46332
11762	20072	115	MHLW2	52451
11763	20072	129	MHR	40251
11764	20072	115	MHLF	52452
11765	20072	11	MHZ	54570
11766	20072	12	HMVW	54577
11767	20072	28	MHU	54585
11768	20072	23	SRU	54606
11769	20072	36	TFY-1	13875
11770	20072	123	TFW	14462
11771	20072	70	MHW	37503
11772	20072	130	TFV	43031
11773	20072	102	TFX	47972
11774	20072	131	GTH	52932
11775	20072	22	W2	54581
11776	20072	82	TFU	42004
11777	20072	93	TFV5	46332
11778	20072	115	MHLW1	52450
11779	20072	11	MHX2	54569
11780	20072	12	MHVW	54578
11781	20072	23	TFW	54584
11782	20072	14	MHQR2	54609
11783	20072	66	MHX1	26506
11784	20072	130	TFW	43032
11785	20072	115	MHLT	52449
11786	20072	9	MHSUWX	54602
11787	20072	43	MHV3	14437
11788	20072	108	MTHFX	39197
11789	20072	110	MTHFW	41355
11790	20072	5	TFU2	54566
11791	20072	75	MHR	55102
11792	20072	109	TFW1	39211
11793	20072	119	TFY	39260
11794	20072	111	MTHFQ	41357
11795	20072	81	MHR	42009
11796	20072	98	MHX2	42460
11797	20072	70	MHX	37504
11798	20072	109	TFW2	39233
11799	20072	111	MTHFCR	41358
11800	20072	5	TFU	54564
11801	20072	89	MHW	62802
11802	20072	36	TFX-2	13872
11803	20072	109	MHW1	39294
11804	20072	111	MTHFGV	41360
11805	20072	95	MHX1	45814
11806	20072	5	MHU	54563
11807	20072	36	TFR-1	13864
11808	20072	70	TFU	37507
11809	20072	108	MTHFQ	39207
11810	20072	2	MHRU	54556
11811	20072	39	MHU4	16065
11812	20072	109	MHV	39206
11813	20072	119	TFX	39259
11814	20072	111	MTHFW	41361
11815	20072	74	MHX	52911
11816	20072	1	FTRU	54550
11817	20072	45	TFU	14470
11818	20072	109	MHR	39202
11819	20072	123	TFV	14459
11820	20072	119	TFX1	39383
11821	20072	63	MHR	15608
11822	20072	107	MTHFW4	39183
11823	20072	81	TFX	42012
11824	20072	105	MHV	43552
11825	20072	2	TFRU	54559
11826	20072	123	MHU2	14453
11827	20072	107	MTHFW6	39189
11828	20072	93	MHR4	46307
11829	20072	123	MHU	14451
11830	20072	37	TFQ-2	13887
11831	20072	106	MTHFX	39200
11832	20072	98	MHW2	42458
11833	20072	2	TFVW	54560
11834	20072	123	MHR	14450
11835	20072	107	MTHFW2	39171
11836	20072	98	MHU2	42452
11837	20072	40	MHR	14471
11838	20072	107	MTHFW3	39177
11839	20072	83	MHX	41425
11840	20072	103	MHU1	44677
11841	20072	2	TFXY	54561
11842	20072	39	TFX2	16133
11843	20072	107	MTHFV4	39182
11844	20072	98	MHX1	42459
11845	20072	40	TFW	14481
11846	20072	55	MHU	15575
11847	20072	107	MTHFR	39155
11848	20072	95	TFX1	45831
11849	20072	2	MHVW	54557
11850	20072	50	TFR1	15529
11851	20072	55	MHQ	15573
11852	20072	94	TFX1	45796
11853	20072	55	MHV1	15577
11854	20072	107	MTHFR4	39180
11855	20072	81	TFW	42011
11856	20072	100	MHW	42481
11857	20073	44	MTWHFBC	11651
11858	20073	18	X2	54550
11859	20073	127	X2-A	15518
11860	20073	111	MTWHFJ	41354
11861	20073	109	X1-1	39164
11862	20073	109	X3-1	39167
11863	20073	37	X3-A	13862
11864	20073	71	X5	38604
11865	20073	109	X3-2	39206
11866	20073	111	MTWHFQ	41352
11867	20073	107	Z1-4	39180
11868	20073	98	X2-1	42450
11869	20073	107	Z3-1	39186
11870	20073	107	Z1-6	39182
11871	20073	107	Z1-5	39181
11872	20081	132	THV-2	44102
11873	20081	17	THU	54562
11874	20081	6	FWRU	54571
11875	20081	16	WFV2	54578
11876	20081	20	MS2	54584
11877	20081	75	WFW	55101
11878	20081	100	THR1	42483
11879	20081	133	THW	52938
11880	20081	8	WFW	54568
11881	20081	21	MU	54580
11882	20081	20	MS3	54585
11883	20081	23	THV	54609
11884	20081	112	WFR	69950
11885	20081	47	W	19916
11886	20081	134	THX	43031
11887	20081	16	WFV	54577
11888	20081	20	MS4	54586
11889	20081	29	THW3	54602
11890	20081	108	TWHFR	39212
11891	20081	97	THY	43057
11892	20081	114	THQF2	52451
11893	20081	6	FWVW	54572
11894	20081	91	THD/HJ2	67252
11895	20081	70	THY	37505
11896	20081	114	THQW2	52450
11897	20081	7	THVW	54574
11898	20081	8	SUV	54599
11899	20081	62	THW3	15694
11900	20081	109	THV	39301
11901	20081	114	THQF1	52449
11902	20081	6	THRU	54573
11903	20081	112	WFV	69957
11904	20081	114	THQW1	52448
11905	20081	19	THW	54565
11906	20081	23	WFU	54610
11907	20081	108	TWHFU1	39219
11908	20081	111	TWHFGV	41386
11909	20081	99	THW2	42474
11910	20081	2	FWXY	54556
11911	20081	45	THR2	14480
11912	20081	135	THU	15105
11913	20081	19	THW2	54566
11914	20081	111	TWHFQ	41383
11915	20081	7	THXY2	54576
11916	20081	136	THV	13927
11917	20081	66	THU2	26503
11918	20081	108	TWHFX	39226
11919	20081	119	WFV	39347
11920	20081	110	TWHFW	41382
11921	20081	3	WFRU	54561
11922	20081	48	W	19919
11923	20081	71	WFX	38601
11924	20081	107	TWHFW	39209
11925	20081	1	THXY2	54551
11926	20081	89	A	62800
11927	20081	108	TWHFV1	39221
11928	20081	98	WFY2	42471
11929	20081	95	THQ2	45799
11930	20081	36	WFR-4	13872
11931	20081	103	THR-4	44662
11932	20081	3	THXY	54558
11933	20081	40	THY	14496
11934	20081	62	THU2	15618
11935	20081	93	THX1	46320
11936	20081	39	THX4	16137
11937	20081	108	TWHFW2	39229
11938	20081	110	TWHFQ	41378
11939	20081	36	THR-1	13851
11940	20081	91	WFB/WC	67292
11941	20081	49	WFX1	15543
11942	20081	127	THX2	15575
11943	20081	37	THU-1	13881
11944	20081	137	THR	15043
11945	20081	108	TWHFV	39217
11946	20081	39	WFV1	16136
11947	20081	108	TWHFW1	39225
11948	20081	100	THR2	42484
11949	20081	108	TWHFR4	39216
11950	20081	3	WFXY	54559
11951	20081	75	THW	55100
11952	20081	39	WFW2	16113
11953	20081	108	TWHFR2	39214
11954	20081	110	TWHFU	41380
11955	20081	95	THW1	45808
11956	20081	43	WFR1	14463
11957	20081	70	WFU	37507
11958	20081	106	TWHFW2	39167
11959	20081	100	WFX1	42494
11960	20081	1	HTRU	54554
11961	20081	37	THV-1	13882
11962	20081	106	TWHFR7	39277
11963	20081	76	WFU-1	40811
11964	20081	104	THU	44165
11965	20081	40	THU	14489
11966	20081	106	TWHFQ4	39174
11967	20081	95	THR1	45800
11968	20081	1	THXY	54550
11969	20081	43	THV2	14459
11970	20081	106	TWHFU3	39158
11971	20081	82	WFR	42007
11972	20081	94	THX2	45768
11973	20081	1	WFXY2	54553
11974	20081	43	WFX	14467
11975	20081	70	THU	37501
11976	20081	106	TWHFR9	39279
11977	20081	99	WFY	42478
11978	20081	40	WFX1	14501
11979	20081	106	TWHFW3	39168
11980	20081	84	THU	42004
11981	20081	93	WFU3	46330
11982	20081	45	THU	14481
11983	20081	100	THW	42485
11984	20081	43	WFR2	14464
11985	20081	41	WFW2	14434
11986	20081	93	THV3	46313
11987	20081	74	THX	52900
11988	20081	41	THX2	14418
11989	20081	106	TWHFV7	39258
11990	20081	76	THY	40808
11991	20081	94	WFR2	45776
11992	20081	1	WFXY	54552
11993	20081	41	THW2	14413
11994	20081	82	WFW	42008
11995	20081	94	THQ1	45750
11996	20081	41	WFU2	14427
11997	20081	81	WFR	42001
11998	20081	94	WFX1	45791
11999	20081	1	HTQR	54555
12000	20081	41	THR1	14402
12001	20081	106	TWHFW8	39270
12002	20081	94	THU5	45761
12003	20081	42	THW	14446
12004	20081	106	TWHFR2	39152
12005	20081	82	THU	42009
12006	20081	93	WFU1	46328
12007	20081	123	WFV	14477
12008	20081	82	THW	42010
12009	20081	41	WFX2	14438
12010	20081	70	THR	37500
12011	20081	106	TWHFQ	39170
12012	20081	94	THU3	45759
12013	20081	43	WFY	14468
12014	20081	106	TWHFW7	39260
12015	20081	83	WFU	41375
12016	20081	98	THR2	42451
12017	20081	39	THU3	16133
12018	20081	106	TWHFW6	39259
12019	20081	81	WFX	42003
12020	20081	93	THR3	46305
12021	20081	41	WFW4	14436
12022	20081	106	TWHFQ5	39280
12023	20081	41	THR2	14403
12024	20081	100	WFW	42493
12025	20081	42	THV1	14444
12026	20081	106	TWHFR3	39153
12027	20081	39	THY2	16078
12028	20081	43	THQ	14455
12029	20081	138	WFV	40824
12030	20081	105	WFQ1	43583
12031	20081	123	THX	14469
12032	20081	79	THV1	39703
12033	20081	50	WFU3	15547
12034	20081	55	THR2	15664
12035	20081	106	TWHFX2	39187
12036	20081	93	THV6	46345
12037	20081	1	MUVWX	54597
12038	20081	43	THW3	14600
12039	20081	41	WFX5	14607
12040	20081	106	TWHFU2	39157
12041	20081	94	THX3	45769
12042	20081	37	WFY-2	13931
12043	20081	50	THV1	15528
12044	20081	93	THY4	46325
12045	20082	123	THX	14474
12046	20082	40	THW1	14505
12047	20082	119	THR	39281
12048	20082	111	S3L/R4	41472
12049	20082	89	WFA	62804
12050	20082	45	WFV	14496
12051	20082	138	WFW	40816
12052	20082	14	THRU	54566
12053	20082	9	THVW	54570
12054	20082	22	S2	54581
12055	20082	131	GM	56235
12056	20082	113	WFU2	15707
12057	20082	74	THW	52917
12058	20082	11	WFV	54565
12059	20082	21	HV	54579
12060	20082	22	S1	54580
12061	20082	60	MR2A	33109
12062	20082	84	THW	42007
12063	20082	139	THWFY	43021
12064	20082	140	THWFY	43022
12065	20082	22	S4	54583
12066	20082	89	THK	62800
12067	20082	109	WFU2	39310
12068	20082	5	THU2	54561
12069	20082	14	THVW	54567
12070	20082	141	WFIJ	67206
12071	20082	123	THQ1	14536
12072	20082	115	WFLT	52430
12073	20082	11	WFW	54562
12074	20082	9	THYZ	54571
12075	20082	12	WFUV	54575
12076	20082	135	WFU2	15154
12077	20082	94	THV4	45765
12078	20082	14	THXY	54568
12079	20082	40	THV1	14503
12080	20082	81	THR	42008
12081	20082	115	WFLW	52431
12082	20082	5	THU	54559
12083	20082	11	WFX	54563
12084	20082	14	WFVW	54569
12085	20082	41	THV2	14406
12086	20082	123	WFV1	14480
12087	20082	119	THU	39233
12088	20082	109	WFU5	39321
12089	20082	81	WFW	42010
12090	20082	3	HTQR	54609
12091	20082	115	WFLF	52433
12092	20082	39	WFU4	16078
12093	20082	12	WFWX	54576
12094	20082	30	SWX	54588
12095	20082	112	TBA	70009
12096	20082	5	WFU	54560
12097	20082	89	WFV	62829
12098	20082	42	THU1	14429
12099	20082	109	THR1	39274
12100	20082	111	S4L/R1	41386
12101	20082	100	THW2	42475
12102	20082	75	WFW	55100
12103	20082	43	THV1	14450
12104	20082	108	TWHFU1	39213
12105	20082	110	S2L/R4	41439
12106	20082	94	THW3	45768
12107	20082	2	WFXY	54555
12108	20082	111	S5L/R5	41481
12109	20082	82	THY	42003
12110	20082	94	THV2	45763
12111	20082	119	THV	39271
12112	20082	95	THX3	45817
12113	20082	48	X	19904
12114	20082	108	TWHFW	39211
12115	20082	111	S2L/R4	41468
12116	20082	87	THY	47957
12117	20082	35	THX1	15506
12118	20082	109	THW1	39221
12119	20082	111	S1L/R5	41465
12120	20082	103	WFR-2	44731
12121	20082	5	WFU2	54618
12122	20082	37	THR-3	13884
12123	20082	119	THQ	39280
12124	20082	110	S5L/R1	41392
12125	20082	94	THX3	45771
12126	20082	123	WFX	14484
12127	20082	111	S1L/R1	41383
12128	20082	24	THR	54585
12129	20082	109	WFR2	39309
12130	20082	111	S5L/R1	41387
12131	20082	95	WFV2	45826
12132	20082	123	WFV3	14482
12133	20082	108	TWHFR	39212
12134	20082	45	WFQ	14491
12135	20082	109	THQ1	39378
12136	20082	111	S5L/R3	41479
12137	20082	93	WFU2	46319
12138	20082	36	THV-2	13859
12139	20082	107	TWHFU7	39326
12140	20082	98	THR3	42452
12141	20082	103	WFR-4	44733
12142	20082	1	FWVW	54614
12143	20082	73	WFW-1	38078
12144	20082	111	S4L/R3	41475
12145	20082	89	TNQ	62803
12146	20082	41	WFR	14415
12147	20082	49	THR1	15522
12148	20082	107	TWHFW2	39169
12149	20082	94	WFU1	45782
12150	20082	1	HTXY	54550
12151	20082	39	WFV3	16081
12152	20082	107	TWHFQ4	39268
12153	20082	81	WFX	42011
12154	20082	98	WFU2	42464
12155	20082	2	HTVW	54552
12156	20082	142	WFV	14556
12157	20082	107	TWHFQ1	39158
12158	20082	82	THU	42000
12159	20082	100	THR2	42472
12160	20082	2	WFRU	54554
12161	20082	39	THQ1	16050
12162	20082	107	TWHFU3	39173
12163	20082	100	WFQ2	42477
12164	20082	42	THY	14435
12165	20082	73	WFV	38059
12166	20082	107	TWHFQ5	39345
12167	20082	94	WFX1	45795
12168	20082	41	THX2	14411
12169	20082	123	WFR	14477
12170	20082	98	WFU1	42463
12171	20082	2	THRU	54556
12172	20082	61	THW1	15620
12173	20082	107	TWHFV3	39174
12174	20082	76	WFU	40850
12175	20082	2	HTXY	54557
12176	20082	41	WFU	14416
12177	20082	107	TWHFW	39155
12178	20082	81	WFR	42009
12179	20082	93	WFX	46327
12180	20082	36	WFU-1	13867
12181	20082	93	WFV2	46321
12182	20082	143	WFR/WFRUV2	38632
12183	20082	104	MUV	44132
12184	20082	94	THU2	45758
12185	20082	75	WFX	55101
12186	20082	42	THW2	14433
12187	20082	100	WFR2	42479
12188	20082	123	THR	14537
12189	20082	106	TWHFQ1	39232
12190	20082	70	THU	37501
12191	20082	107	TWHFR4	39177
12192	20082	100	WFW	42481
12193	20082	40	WFX1	14513
12194	20082	76	THX	40804
12195	20082	55	WFR1	15580
12196	20082	71	THX	38600
12197	20082	107	TWHFU6	39325
12198	20082	103	WFV-2	44736
12199	20082	39	WFU2	16076
12200	20082	107	TWHFW4	39179
12201	20082	2	THXY	54553
12202	20082	123	WFW	14483
12203	20082	107	TWHFQ3	39171
12204	20082	80	THU	40251
12205	20082	41	THV3	14407
12206	20082	98	WFV2	42466
12207	20082	93	THU1	46303
12208	20082	43	WFR	14457
12209	20082	107	TWHFU5	39181
12210	20082	93	THQ1	46322
12211	20082	123	THR1	14465
12212	20082	70	WFU	37507
12213	20082	100	WFX	42482
12214	20082	105	THV	43563
12215	20082	40	THU2	14515
12216	20082	106	TWHFX	39186
12217	20082	82	WFV	42004
12218	20082	37	WFR-2	13894
12219	20082	100	WFU	42480
12220	20082	42	WFX1	14443
12221	20082	107	TWHFU2	39167
12222	20082	98	WFR1	42461
12223	20082	107	TWHFR3	39172
12224	20082	42	THR1	14427
12225	20082	100	WFR1	42478
12226	20082	39	WFU3	16077
12227	20082	107	TWHFR2	39166
12228	20082	94	WFW1	45791
12229	20082	123	THU	14466
12230	20082	107	TWHFR	39152
12231	20082	76	WFW	40808
12232	20082	41	THW	14408
12233	20082	104	THX	44130
12234	20082	41	WFV	14417
12235	20082	43	WFU	14459
12236	20082	105	THY	43554
12237	20082	62	THX1	15624
12238	20082	71	WFX	38601
12239	20082	107	TWHFW3	39175
12240	20082	105	WFR	43552
12241	20082	94	THR4	45755
12242	20082	100	WFQ1	42476
12243	20082	93	WFV1	46320
12244	20082	36	WFX-2	13879
12245	20082	106	TWHFU	39372
12246	20082	94	THX1	45769
12247	20082	95	THW2	45813
12248	20083	70	X2	37500
12249	20083	113	X4-A	15534
12250	20083	70	X5	37503
12251	20083	71	X2	38601
12252	20083	43	X5	14420
12253	20083	105	X-3C	43554
12254	20083	98	X5-1	42456
12255	20083	130	X2-1	43011
12256	20083	133	X4	52901
12257	20083	70	X4	37502
12258	20083	109	X3	39181
12259	20083	111	MTWHFJ	41366
12260	20083	109	X2	39180
12261	20083	108	Z2-6	39201
12262	20083	108	Z1-6	39197
12263	20083	109	X4	39206
12264	20083	40	X2	14432
12265	20083	109	X4-1	39210
12266	20083	111	MTWHFQ	41364
12267	20083	108	Z2-2	39175
12268	20083	107	Z1-3	39164
12269	20083	37	X4	13861
12270	20083	93	X3-2	46302
12271	20083	110	MTWHFE	41362
12272	20083	108	Z3-5	39204
12273	20083	107	Z2	39165
12274	20083	71	X3	38602
12275	20083	93	X5-1	46305
12276	20083	108	Z3-2	39178
12277	20083	110	MTWHFJ	41363
12278	20083	108	Z1-1	39170
12279	20083	36	X5	13859
12280	20083	130	X1	43000
12281	20083	107	Z1	39161
12282	20083	95	X2	45753
12283	20083	43	X3-B	14419
12284	20083	107	Z3	39168
12285	20083	108	Z3	39176
12286	20083	108	Z3-1	39177
12287	20083	107	Z2-1	39166
12288	20083	108	Z2-4	39199
12289	20091	24	THX	54565
12290	20091	8	WFV	54575
12291	20091	6	THVW	54580
12292	20091	7	FWXY	54583
12293	20091	112	WFW	69988
12294	20091	143	WFQ/WFUV1	38617
12295	20091	63	WFW1	15604
12296	20091	132	THU1	44103
12297	20091	17	THV	54567
12298	20091	19	THW	54571
12299	20091	16	WFX	54587
12300	20091	20	S6	54625
12301	20091	144	TWHFX	43036
12302	20091	145	TWHFX	43037
12303	20091	71	THW	38717
12304	20091	114	THQ	52479
12305	20091	114	THQS2	52483
12306	20091	7	THXY	54585
12307	20091	21	MR	54589
12308	20091	112	WFY	69990
12309	20091	17	THU	54568
12310	20091	19	THX	54572
12311	20091	23	MXY	54592
12312	20091	20	S7	54629
12313	20091	146	THX	53508
12314	20091	17	WFU	54569
12315	20091	19	THR	54570
12316	20091	7	HTVW	54582
12317	20091	16	WFV	54586
12318	20091	37	WFU-1	13892
12319	20091	133	THU	52904
12320	20091	23	WFX	54591
12321	20091	45	WFV1	14606
12322	20091	147	TWHFR	43056
12323	20091	148	TWHFR	43057
12324	20091	2	THVW	54559
12325	20091	19	WFU	54573
12326	20091	43	THW1	14544
12327	20091	40	WFX3	14637
12328	20091	114	THQT	52480
12329	20091	5	WFR	54564
12330	20091	6	FWVW	54579
12331	20091	149	THR	14968
12332	20091	111	S3L/R3	41398
12333	20091	150	WFV	43061
12334	20091	114	THQS1	52482
12335	20091	17	THW	54566
12336	20091	8	THV	54574
12337	20091	98	WFR2	42458
12338	20091	6	THXY	54581
12339	20091	112	WFX	69989
12340	20091	73	THW	38071
12341	20091	109	WFR	39303
12342	20091	119	WFY	39310
12343	20091	3	WFVW	54562
12344	20091	73	WFU	38063
12345	20091	114	THQH	52481
12346	20091	1	HTXY	54552
12347	20091	75	WFV	55104
12348	20091	87	THU	47951
12349	20091	8	SWX	54577
12350	20091	88	WFX	62814
12351	20091	57	WFU1	15575
12352	20091	111	S4L/R2	41402
12353	20091	6	HTXY	54578
12354	20091	7	WFWX	54584
12355	20091	93	THW2	46362
12356	20091	75	WFW	55100
12357	20091	109	WFQ	39302
12358	20091	111	S5L/R3	41408
12359	20091	3	THRU	54560
12360	20091	8	THY	54576
12361	20091	111	S1L/R5	41390
12362	20091	88	THV	62807
12363	20091	50	WFU1	15533
12364	20091	39	THU1	16075
12365	20091	151	WFX	39266
12366	20091	123	THQ	14562
12367	20091	50	THU3	15523
12368	20091	109	WFV	39297
12369	20091	110	S2L/R3	41358
12370	20091	43	WFW2	14556
12371	20091	35	THQ1	15500
12372	20091	57	THR1	15574
12373	20091	107	TWHFV	39388
12374	20091	110	S6L/R2	41381
12375	20091	1	WFRU2	54616
12376	20091	123	THU2	14565
12377	20091	39	THV3	16119
12378	20091	107	TWHFY	39272
12379	20091	110	S5L/R1	41374
12380	20091	63	WFR1	15601
12381	20091	108	TWHFU3	39278
12382	20091	110	S1L/R4	41353
12383	20091	123	THV3	14568
12384	20091	108	TWHFR4	39339
12385	20091	110	S3L/R1	41362
12386	20091	100	THW	42471
12387	20091	43	THW2	14545
12388	20091	108	TWHFQ2	39371
12389	20091	110	S6L/R6	41385
12390	20091	95	THV3	45805
12391	20091	123	THV2	14567
12392	20091	108	TWHFQ3	39372
12393	20091	81	WFR	42001
12394	20091	3	WFXY	54563
12395	20091	43	THR1	14635
12396	20091	35	WFQ1	15504
12397	20091	110	S6L/R4	41383
12398	20091	41	THX5	14502
12399	20091	108	TWHFR1	39277
12400	20091	110	S3L/R4	41365
12401	20091	97	THV	43059
12402	20091	108	TWHFR	39275
12403	20091	110	S3L/R3	41364
12404	20091	98	WFX	42525
12405	20091	3	THXY	54561
12406	20091	63	THR1	15594
12407	20091	107	TWHFX	39271
12408	20091	111	S3L/R2	41397
12409	20091	43	THQ	14539
12410	20091	108	TWHFU	39273
12411	20091	110	S2L/R4	41359
12412	20091	99	THV	42461
12413	20091	127	THY1	15552
12414	20091	110	S6L/R5	41384
12415	20091	2	THRU	54628
12416	20091	127	WFR1	15554
12417	20091	93	THV3	46307
12418	20091	50	THV2	15558
12419	20091	110	S1L/R5	41354
12420	20091	36	WFV-3	13865
12421	20091	108	TWHFQ1	39338
12422	20091	110	S5L/R6	41379
12423	20091	93	WFX2	46357
12424	20091	108	TWHFU2	39276
12425	20091	110	S4L/R1	41368
12426	20091	81	WFX	42003
12427	20091	94	WFY3	45798
12428	20091	41	THX6	14638
12429	20091	50	WFV2	15536
12430	20091	109	WFW	39298
12431	20091	93	THU4	46305
12432	20091	64	THQ1	15666
12433	20091	50	WFV1	15535
12434	20091	57	WFX1	15577
12435	20091	110	S3L/R5	41366
12436	20091	43	WFW4	14558
12437	20091	108	TWHFR5	39340
12438	20091	95	THW1	45806
12439	20091	62	THR1	15665
12440	20091	70	THY	37505
12441	20091	108	TWHFU4	39287
12442	20091	36	WFY-1	13878
12443	20091	107	TWHFR1	39383
12444	20091	110	S6L/R3	41382
12445	20091	99	WFU	42463
12446	20091	95	WFR1	45813
12447	20091	152	NONE	20509
12448	20091	110	S4L/R4	41371
12449	20091	97	WFU	43001
12450	20091	127	THV2	15561
12451	20091	108	TWHFQ	39285
12452	20091	111	S2L/R1	41391
12453	20091	89	WFX	62805
12454	20091	37	WFW-1	13896
12455	20091	63	THV1	15596
12456	20091	108	TWHFR6	39347
12457	20091	108	TWHFR2	39284
12458	20091	94	WFX2	45793
12459	20091	65	THV1	15616
12460	20091	107	TWHFR	39270
12461	20091	110	S5L/R4	41377
12462	20091	134	THU	43031
12463	20091	37	THW-1	13883
12464	20091	95	WFW1	45820
12465	20091	37	WFY-1	13898
12466	20091	39	THW1	16091
12467	20091	110	S3L/R2	41363
12468	20091	36	WFW-4	13864
12469	20091	57	WFV1	15576
12470	20091	94	THV4	45763
12471	20091	39	THV1	16090
12472	20091	109	THX	39300
12473	20091	23	WFY	54550
12474	20091	36	WFR-2	13868
12475	20091	110	S4L/R3	41370
12476	20091	95	THW2	45807
12477	20091	36	THU-3	13938
12478	20091	109	WFU	39385
12479	20091	110	S5L/R5	41378
12480	20091	74	THV	52915
12481	20091	62	WFR1	15668
12482	20091	107	TWHFU	39378
12483	20091	36	WFX-4	13939
12484	20091	50	THW1	15525
12485	20091	111	S1L/R3	41388
12486	20091	50	THX3	15638
12487	20091	109	THY	39296
12488	20091	95	WFY1	45824
12489	20091	36	THV-1	13856
12490	20091	123	THW	14571
12491	20091	39	THX2	16082
12492	20091	110	S2L/R1	41356
12493	20091	108	TWHFU1	39274
12494	20091	110	S2L/R5	41360
12495	20091	87	THQ1	47992
12496	20091	89	THZ	62833
12497	20091	81	WFW	42002
12498	20091	43	THX2	14547
12499	20091	106	TWHFW5	39209
12500	20091	94	WFQ2	45774
12501	20091	1	HTRU	54554
12502	20091	41	THX2	14499
12503	20091	83	WFU	41502
12504	20091	43	THR	14540
12505	20091	70	THU	37501
12506	20091	106	TWHFW4	39174
12507	20091	100	WFX	42475
12508	20091	1	FWRU	54553
12509	20091	41	THV2	14490
12510	20091	106	TWHFQ1	39151
12511	20091	82	THU	42006
12512	20091	1	WFRU	54557
12513	20091	41	WFV2	14513
12514	20091	106	TWHFU3	39163
12515	20091	83	WFW	41503
12516	20091	100	THR2	42469
12517	20091	1	HTVW	54551
12518	20091	41	WFX2	14521
12519	20091	106	TWHFW7	39248
12520	20091	81	THR	42000
12521	20091	93	THU2	46303
12522	20091	41	WFX1	14520
12523	20091	106	TWHFU2	39162
12524	20091	94	THW1	45765
12525	20091	1	FWVW	54555
12526	20091	106	TWHFQ3	39153
12527	20091	82	WFW	42005
12528	20091	100	THR1	42468
12529	20091	42	THW	14530
12530	20091	106	TWHFV2	39167
12531	20091	82	THR	42004
12532	20091	93	WFR2	46317
12533	20091	1	FWXY	54556
12534	20091	70	THR	37500
12535	20091	99	THW	42462
12536	20091	41	WFX3	14522
12537	20091	70	WFW	37509
12538	20091	93	THR	46369
12539	20091	40	THX1	14585
12540	20091	87	WFR	47957
12541	20091	39	THR2	16099
12542	20091	70	WFV	37508
12543	20091	88	WFR	62809
12544	20091	106	TWHFQ5	39249
12545	20091	83	WFX	41504
12546	20091	100	WFR	42473
12547	20091	43	THV	14543
12548	20091	106	TWHFU1	39161
12549	20091	94	WFW2	45790
12550	20091	40	WFX1	14594
12551	20091	106	TWHFV4	39169
12552	20091	76	WFU1	40810
12553	20091	91	WFB/WI2	67207
12554	20091	39	THX3	16054
12555	20091	94	WFX4	45795
12556	20091	42	THY	14531
12557	20091	106	TWHFV6	39242
12558	20091	94	WFX1	45792
12559	20091	40	WFY	14596
12560	20091	100	WFQ1	42472
12561	20091	123	WFW	14578
12562	20091	100	THR3	42515
12563	20091	39	WFV2	16114
12564	20091	100	WFW	42474
12565	20091	93	THV1	46306
12566	20091	123	WFV3	14577
12567	20091	76	WFX	40811
12568	20091	94	WFQ3	45775
12569	20091	40	THX2	14586
12570	20091	93	WFY1	46331
12571	20091	43	WFW1	14555
12572	20091	93	WFY2	46320
12573	20091	41	THU4	14488
12574	20091	106	TWHFW6	39243
12575	20091	94	THQ1	45750
12576	20091	153	WFU	39192
12577	20091	105	WFV1	43584
12578	20091	44	WFY	11656
12579	20091	40	THY	14588
12580	20091	41	THQ	14483
12581	20091	106	TWHFX7	39254
12582	20091	104	THV1	45853
12583	20091	94	THX2	45769
12584	20091	41	THW5	14497
12585	20091	106	TWHFQ	39150
12586	20091	39	THQ1	16098
12587	20091	93	THX3	46314
12588	20091	40	WFV2	14592
12589	20091	100	WFQ2	42522
12590	20091	60	MR2B	33108
12591	20091	70	WFU	37507
12592	20091	102	THX	44146
12593	20091	41	THX3	14500
12594	20091	94	WFX3	45794
12595	20091	42	WFY1	14536
12596	20091	93	WFU1	46319
12597	20091	106	TWHFY1	39180
12598	20091	94	THU1	45756
12599	20091	42	WFY2	14537
12600	20091	42	THR	14525
12601	20091	106	TWHFX6	39244
12602	20091	98	WFV	42460
12603	20091	76	THX1	40806
12604	20091	88	WFU	62810
12605	20091	123	THR	14563
12606	20091	99	WFV	42464
12607	20091	94	WFV4	45788
12608	20091	106	TWHFY2	39203
12609	20091	43	WFX2	14560
12610	20091	70	WFR	37506
12611	20091	100	THQ1	42466
12612	20091	94	WFV3	45787
12613	20091	123	THU3	14611
12614	20091	106	TWHFY3	39204
12615	20092	154	THY	39298
12616	20092	118	THW	39332
12617	20092	11	WFV	54554
12618	20092	9	WFRU	54591
12619	20092	19	WFW	54631
12620	20092	23	MWX	54637
12621	20092	113	THY1	15663
12622	20092	39	WFU2	16144
12623	20092	155	THW	40256
12624	20092	84	WFV	42006
12625	20092	115	THX	52450
12626	20092	115	THXH	52453
12627	20092	9	WFXY	54566
12628	20092	22	SCVMIG	54602
12629	20092	81	WFW	42002
12630	20092	12	THVW	54575
12631	20092	27	MBD	54625
12632	20092	156	WFQ	15001
12633	20092	50	THU1	15531
12634	20092	115	THXW	52452
12635	20092	131	WFW	56273
12636	20092	39	THV	16073
12637	20092	59	MR11A	33100
12638	20092	74	THW	54000
12639	20092	12	FWVW	54572
12640	20092	157	THX	55673
12641	20092	94	THU1	45755
12642	20092	24	THW	54567
12643	20092	11	WFU	54578
12644	20092	35	THR1	15502
12645	20092	3	THVW	54551
12646	20092	11	WFW	54555
12647	20092	23	WFX	54573
12648	20092	5	WFU	54589
12649	20092	29	THQ	54628
12650	20092	137	THX	15026
12651	20092	14	WFVW	54560
12652	20092	11	WFR	54577
12653	20092	75	THY	55115
12654	20092	41	THY1	14408
12655	20092	113	WFV1	15650
12656	20092	79	THV2	39704
12657	20092	83	THU	41483
12658	20092	21	HR	54570
12659	20092	23	THY	54571
12660	20092	22	MACL	54600
12661	20092	43	THV1	14441
12662	20092	115	THXF	52454
12663	20092	123	THR1	14470
12664	20092	45	SDEF	14501
12665	20092	109	THW	39239
12666	20092	81	WFX	42003
12667	20092	23	WFY1	54638
12668	20092	42	WFX	14435
12669	20092	45	THV	14492
12670	20092	158	THW	16135
12671	20092	2	THRU	54579
12672	20092	37	WFW-2	13928
12673	20092	12	HTVW	54563
12674	20092	9	HTRU	54568
12675	20092	42	THV1	14615
12676	20092	94	THX1	45765
12677	20092	14	WFXY	54561
12678	20092	23	MVW	54634
12679	20092	47	Y	19902
12680	20092	109	THW1	39343
12681	20092	111	S3L/R1	41398
12682	20092	94	THV2	45760
12683	20092	26	THX	54569
12684	20092	125	THY	15057
12685	20092	159	WFW	16126
12686	20092	5	THX	54587
12687	20092	23	WFENTREP	54635
12688	20092	91	WFB/WK2	67256
12689	20092	109	THV1	39245
12690	20092	111	S1L/R5	41392
12691	20092	135	THW	14956
12692	20092	97	WFX	43062
12693	20092	93	THQ2	46301
12694	20092	102	THX	44162
12695	20092	14	WFRU	54559
12696	20092	81	THR	42000
12697	20092	14	THXY	54562
12698	20092	98	THY1	42456
12699	20092	35	WFV1	15508
12700	20092	119	WFX	39214
12701	20092	109	WFU2	39334
12702	20092	45	WFU	14495
12703	20092	115	THXT	52451
12704	20092	9	WFVW	54592
12705	20092	43	WFQ	14452
12706	20092	107	TWHFV6	39335
12707	20092	103	THR-1	44670
12708	20092	2	HTXY	54586
12709	20092	108	TWHFX	39230
12710	20092	111	S5L/R2	41409
12711	20092	97	WFR	43002
12712	20092	93	WFV3	46327
12713	20092	109	THU1	39333
12714	20092	111	S2L/R4	41396
12715	20092	23	WFY	54633
12716	20092	36	WFU-3	13878
12717	20092	111	S1L/R4	41389
12718	20092	100	THR1	42472
12719	20092	93	THY1	46319
12720	20092	2	HTVW	54580
12721	20092	50	WFW1	15543
12722	20092	111	S2L/R1	41393
12723	20092	94	THV1	45759
12724	20092	55	WFW1	15573
12725	20092	70	THR	37500
12726	20092	109	THQ	39248
12727	20092	111	S3L/R5	41402
12728	20092	108	TWHFV	39233
12729	20092	111	S5L/R5	41412
12730	20092	82	WFR	42009
12731	20092	2	FWXY	54582
12732	20092	109	WFU1	39253
12733	20092	93	THV5	46307
12734	20092	87	WFY	47951
12735	20092	5	THU	54590
12736	20092	108	TWHFR	39232
12737	20092	95	THY1	45805
12738	20092	108	TWHFX1	39235
12739	20092	94	WFR1	45774
12740	20092	41	THV1	14402
12741	20092	109	WFV1	39255
12742	20092	100	WFW	42478
12743	20092	93	THU2	46305
12744	20092	36	WFW-1	13880
12745	20092	61	THX1	15597
12746	20092	107	TWHFU7	39338
12747	20092	5	THY	54588
12748	20092	43	THW1	14446
12749	20092	60	MR1	33108
12750	20092	109	THX	39240
12751	20092	111	S2L/R3	41395
12752	20092	43	WFU2	14454
12753	20092	123	WFV1	14484
12754	20092	109	THV	39238
12755	20092	2	THXY	54584
12756	20092	63	THQ1	15608
12757	20092	108	TWHFW1	39234
12758	20092	123	THV2	14473
12759	20092	55	THW1	15570
12760	20092	118	THR	39323
12761	20092	109	THU2	39340
12762	20092	94	WFY1	45790
12763	20092	37	WFV-2	13926
12764	20092	73	WFR	38050
12765	20092	100	THR3	42523
12766	20092	108	TWHFU	39231
12767	20092	94	WFV2	45782
12768	20092	50	WFX2	15535
12769	20092	109	THR1	39326
12770	20092	94	THU2	45756
12771	20092	107	TWHFV4	39204
12772	20092	110	S5L/R6	41379
12773	20092	1	FWXY	54553
12774	20092	109	WFU	39244
12775	20092	93	THY2	46320
12776	20092	70	THW	37503
12777	20092	111	S2L/R5	41397
12778	20092	42	WFR2	14429
12779	20092	111	S4L/R5	41407
12780	20092	160	THU	42480
12781	20092	36	THY-2	13870
12782	20092	35	WFX1	15544
12783	20092	107	TWHFU4	39203
12784	20092	1	FWVW	54565
12785	20092	42	WFU1	14430
12786	20092	109	THV2	39254
12787	20092	74	THY	54001
12788	20092	50	THV4	15656
12789	20092	94	WFV3	45783
12790	20092	109	WFW	39257
12791	20092	111	S2L/R2	41394
12792	20092	95	THX1	45803
12793	20092	66	THX1	26506
12794	20092	51	FWX	29251
12795	20092	95	WFR1	45808
12796	20092	40	THU2	14503
12797	20092	110	S6L/R3	41382
12798	20092	36	THR-2	13852
12799	20092	43	THU1	14438
12800	20092	111	S5L/R3	41410
12801	20092	93	WFX2	46330
12802	20092	35	WFR1	15506
12803	20092	70	THV	37502
12804	20092	109	THR3	39339
12805	20092	111	S3L/R4	41401
12806	20092	50	WFR1	15539
12807	20092	109	THR	39250
12808	20092	93	WFV1	46325
12809	20092	50	THV2	15534
12810	20092	111	S3L/R2	41399
12811	20092	123	THX1	14478
12812	20092	109	THR2	39331
12813	20092	111	S5L/R1	41408
12814	20092	93	WFX1	46332
12815	20092	50	WFX1	15545
12816	20092	109	WFR	39251
12817	20092	94	THR2	45753
12818	20092	94	THQ1	45750
12819	20092	35	THV1	15504
12820	20092	70	THY	37505
12821	20092	110	S6L/R2	41381
12822	20092	75	WFW	55101
12823	20092	37	THV-1	13917
12824	20092	95	WFV2	45812
12825	20092	93	THU3	46306
12826	20092	104	WFW	47957
12827	20092	39	THR	16069
12828	20092	70	THU	37501
12829	20092	138	WFU	40812
12830	20092	111	S4L/R4	41406
12831	20092	161	FAB2	41451
12832	20092	70	WFV	37508
12833	20092	111	S5L/R4	41411
12834	20092	87	WFR	47963
12835	20092	43	WFV2	14457
12836	20092	42	THX2	14425
12837	20092	45	WFX	14500
12838	20092	107	TWHFW	39180
12839	20092	100	WFQ1	42475
12840	20092	2	HTRU1	54557
12841	20092	36	WFV-2	13873
12842	20092	107	TWHFW3	39201
12843	20092	98	THY3	42458
12844	20092	2	HTRU2	54550
12845	20092	36	THX-2	13867
12846	20092	41	THU1	14606
12847	20092	107	TWHFW2	39194
12848	20092	93	WFU3	46324
12849	20092	123	WFV2	14485
12850	20092	107	TWHFQ1	39183
12851	20092	105	WFU	43562
12852	20092	107	TWHFV3	39200
12853	20092	94	THW2	45764
12854	20092	93	WFR1	46321
12855	20092	40	WFR	14511
12856	20092	70	WFU	37507
12857	20092	87	WFX	47970
12858	20092	43	WFX	14466
12859	20092	82	THR	42008
12860	20092	95	WFV1	45811
12861	20092	1	THVW	54556
12862	20092	123	WFW1	14487
12863	20092	48	X	19904
12864	20092	39	THQ	16094
12865	20092	79	THW2	39705
12866	20092	94	WFW2	45785
12867	20092	41	WFX1	14417
12868	20092	36	WFU-2	13877
12869	20092	41	WFR	14411
12870	20092	100	WFQ2	42476
12871	20092	107	TWHFQ3	39196
12872	20092	98	WFV2	42461
12873	20092	123	WFR	14481
12874	20092	40	WFU1	14512
12875	20092	106	TWHFW	39174
12876	20092	107	TWHFU2	39192
12877	20092	98	WFV1	42460
12878	20092	41	THX2	14406
12879	20092	81	WFR	42001
12880	20092	39	WFX4	16105
12881	20092	70	WFW	37509
12882	20092	107	TWHFU1	39185
12883	20092	39	THX1	16053
12884	20092	106	TWHFV1	39211
12885	20092	94	WFR3	45776
12886	20092	158	THX	16136
12887	20092	107	TWHFU	39178
12888	20092	98	THV1	42453
12889	20092	99	WFW	42467
12890	20092	43	WFV4	14459
12891	20092	107	TWHFQ4	39209
12892	20092	93	WFU1	46322
12893	20092	39	WFV1	16104
12894	20092	73	WFU	38065
12895	20092	107	TWHFR	39177
12896	20092	93	WFW1	46328
12897	20092	70	WFX	37510
12898	20092	89	WFR	62802
12899	20092	42	WFU2	14431
12900	20092	107	TWHFR2	39191
12901	20092	100	THQ2	42470
12902	20092	39	THW	16074
12903	20092	107	TWHFV1	39186
12904	20092	41	WFU1	14412
12905	20092	107	TWHFR4	39202
12906	20092	98	THU	42452
12907	20092	63	WFV1	15617
12908	20092	39	WFR1	16097
12909	20092	107	TWHFU3	39198
12910	20092	41	WFW1	14415
12911	20092	93	THW2	46316
12912	20092	70	THX	37504
12913	20092	39	WFW	16121
12914	20092	106	TWHFR	39171
12915	20092	83	THX	41485
12916	20092	63	THW3	15664
12917	20092	94	WFU3	45780
12918	20092	79	THV1	39703
12919	20092	83	WFX	41488
12920	20092	93	THW3	46313
12921	20092	41	THX3	14407
12922	20092	105	THY	43560
12923	20092	42	THX1	14424
12924	20092	95	WFU1	45809
12925	20092	83	THW	41484
12926	20092	94	WFR4	45777
12927	20092	107	TWHFW1	39187
12928	20092	99	WFU	42464
12929	20092	71	THX	38794
12930	20092	94	WFX3	45789
12931	20092	100	THQ1	42469
12932	20092	46	WFR	14951
12933	20092	107	TWHFV2	39193
12934	20092	95	WFQ1	45807
12935	20092	93	THU1	46304
12936	20092	43	WFU3	14455
12937	20092	99	WFX	42468
12938	20092	76	WFY	40806
12939	20092	93	THX1	46317
12940	20092	123	WFU1	14482
12941	20092	75	WFV	55100
12942	20092	61	WFU1	15599
12943	20092	107	TWHFW4	39321
12944	20092	93	THV4	46312
12945	20092	57	WFR1	15588
12946	20092	63	WFY1	15620
12947	20092	99	THW	42463
12948	20092	41	WFU3	14414
12949	20092	97	THW1	43003
12950	20092	39	THX2	16078
12951	20092	59	MR11C	33102
12952	20092	36	WFU-1	13875
12953	20092	70	WFR	37506
12954	20092	107	TWHFV5	39329
12955	20092	94	WFU2	45779
12956	20092	41	WFW2	14416
12957	20092	123	WFW2	14488
12958	20092	40	THW	14506
12959	20092	36	THQ-1	13850
12960	20092	106	TWHFV	39173
12961	20092	89	WFU	62803
12962	20092	36	THU-2	13855
12963	20092	39	WFQ1	16096
12964	20092	43	THU2	14439
12965	20092	40	THY2	14510
12966	20092	158	WFX	16127
12967	20092	76	THW	40802
12968	20092	94	THX4	45768
12969	20092	107	TWHFU5	39206
12970	20092	100	THW	42474
12971	20092	41	WFX2	14418
12972	20092	93	THR1	46302
12973	20092	94	WFX1	45787
12974	20092	43	WFW1	14461
12975	20092	106	TWHFQ	39170
12976	20092	103	WFV-1	44684
12977	20092	39	THX3	16081
12978	20092	93	THW1	46315
12979	20092	42	THX3	14426
12980	20092	39	WFY2	16068
12981	20092	104	MCDE1	45817
12982	20092	100	WFR	42477
12983	20092	95	THU2	45796
12984	20092	39	WFU	16103
12985	20093	41	X4A	14406
12986	20093	111	X7-5	41355
12987	20093	93	X3-1	46307
12988	20093	35	X2-A	15501
12989	20093	18	Prac	54551
12990	20093	162	X7-9	41359
12991	20093	94	X3	45753
12992	20093	113	X1-A	15546
12993	20093	70	X5	37504
12994	20093	113	X2-B	15543
12995	20093	133	X4	55651
12996	20093	61	X3-A	15519
12997	20093	109	X2-1	39205
12998	20093	81	X4	42003
12999	20093	71	X3	38602
13000	20093	123	X3A	14431
13001	20093	111	X7-4	41354
13002	20093	98	X1	42451
13003	20093	5	X	54554
13004	20093	108	Z1-4	39195
13005	20093	109	X1-1	39193
13006	20093	103	X-2	44659
13007	20093	109	X4	39182
13008	20093	109	X3	39181
13009	20093	100	X4-1	42461
13010	20093	108	Z2	39172
13011	20093	108	Z3-1	39175
13012	20093	108	Z3-4	39206
13013	20093	109	X4-1	39183
13014	20093	43	X2B	14418
13015	20093	123	X2A	14428
13016	20093	93	X3	46302
13017	20093	23	X	54553
13018	20093	109	X2	39180
13019	20093	103	X5	43556
13020	20093	50	X4-A	15507
13021	20093	41	X3A	14403
13022	20093	108	Z1-1	39173
13023	20093	108	Z2-3	39199
13024	20093	137	X3	14966
13025	20093	163	X-2-2	44653
13026	20093	107	Z1-2	39169
13027	20093	108	Z1	39170
13028	20093	108	Z1-3	39194
13029	20093	108	Z1-5	39196
13030	20093	95	X3	45755
13031	20093	93	X2	46301
13032	20093	108	Z2-2	39177
13033	20093	105	X3	43554
13034	20093	94	X2	45752
13035	20093	40	X4A	14439
13036	20093	100	X3-1	42459
13037	20093	107	Z1	39164
13038	20093	108	Z1-2	39176
13039	20093	108	Z1-6	39197
13040	20093	107	Z2	39165
13041	20093	107	Z1-3	39201
13042	20093	108	Z3-2	39178
13043	20093	100	X3-2	42460
13044	20093	94	X1	45751
13045	20093	107	Z2-1	39168
13046	20093	107	Z2-2	39202
13047	20093	84	X3	42002
13048	20093	39	X1A	16051
13049	20093	102	X2-1	44110
13050	20093	71	X2	38601
13051	20093	107	Z1-1	39167
13052	20093	108	Z1-8	39215
13053	20093	108	Z2-1	39174
13054	20101	17	THU	54569
13055	20101	7	HTVW	54586
13056	20101	16	THY	54592
13057	20101	6	S2	54650
13058	20101	112	WFR	69955
13059	20101	37	WFX-1	13890
13060	20101	102	WFU	44164
13061	20101	17	WFV	54571
13062	20101	21	HR	54593
13063	20101	20	MACL	54614
13064	20101	19	WFX	54576
13065	20101	16	WFY	54591
13066	20101	20	MWSG	54619
13067	20101	112	WFU	69956
13068	20101	164	THD	66665
13069	20101	164	HJ4	66745
13070	20101	70	WFV	37509
13071	20101	82	THX	42012
13072	20101	16	WFX	54590
13073	20101	23	THR	54605
13074	20101	114	WBC	52481
13075	20101	114	WBCH	52483
13076	20101	17	WFW	54572
13077	20101	8	THV	54579
13078	20101	6	HTXY	54582
13079	20101	7	M	54649
13080	20101	114	WBCT	52482
13081	20101	8	THW	54577
13082	20101	7	WFVW	54646
13083	20101	23	THV	54595
13084	20101	114	FBCS2	52528
13085	20101	114	FBC	52530
13086	20101	113	WFQ2	15650
13087	20101	155	THW	40258
13088	20101	19	WFU	54574
13089	20101	16	WFV	54589
13090	20101	20	MCVMIG	54616
13091	20101	112	WFX	70034
13092	20101	123	WFU1	14497
13093	20101	87	WFW1	47967
13094	20101	7	HTRU	54585
13095	20101	113	THV1	15631
13096	20101	70	THW	37504
13097	20101	100	WFR1	42472
13098	20101	3	WFVW	54567
13099	20101	19	THR	54573
13100	20101	17	WFU	54570
13101	20101	19	WFW	54575
13102	20101	26	THX	54596
13103	20101	75	WFY	55106
13104	20101	8	THY	54578
13105	20101	113	THX2	15636
13106	20101	165	THU	39268
13107	20101	111	S4-A	41382
13108	20101	114	FBCS1	52484
13109	20101	20	MNDSG	54617
13110	20101	43	THW1	14465
13111	20101	111	S3-A	41380
13112	20101	95	THV1	45796
13113	20101	79	WFV1	39705
13114	20101	20	MSCL	54618
13115	20101	108	TWHFV1	39249
13116	20101	72	WFX	52379
13117	20101	3	WFRU	54566
13118	20101	35	WFV2	15505
13119	20101	109	THX	39261
13120	20101	100	THR3	42519
13121	20101	166	THU	43030
13122	20101	23	THW	54604
13123	20101	36	THY-1	13862
13124	20101	103	WFQ-2	44665
13125	20101	74	THX	54001
13126	20101	23	WFY	54607
13127	20101	127	THV1	15554
13128	20101	81	WFX	42002
13129	20101	82	THR	42003
13130	20101	107	TWHFY1	39382
13131	20101	110	S3-A	41361
13132	20101	1	FWVW	54555
13133	20101	45	WFV	14519
13134	20101	6	S	54643
13135	20101	137	THQ	15024
13136	20101	56	THX1	15566
13137	20101	6	FWVW	54583
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
1832	2006	9
1832	2007	3
1830	1999	23
1830	2001	18
1830	2002	18
1830	2003	6
\.


--
-- Data for Name: eligpasshalf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalf (studentid, studenttermid, termid, failpercentage) FROM stdin;
1833	7848	20042	0.789473712
1833	8113	20091	0.600000024
1833	8549	20101	0.600000024
1834	7849	20042	0.5625
1841	8456	20092	1
1842	7955	20072	1
1843	7937	20072	0.625
1851	8465	20092	0.571428597
1874	8101	20082	1
1877	8168	20091	0.631578922
1881	8106	20082	1
1886	8491	20092	1
1899	8473	20092	1
1943	8511	20092	1
1992	8541	20092	1
1994	8543	20092	1
1832	7834	20032	0.8125
\.


--
-- Data for Name: eligpasshalfmathcs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalfmathcs (studentid, studenttermid, termid, failpercentage) FROM stdin;
1833	7848	20042	1
1834	7849	20042	1
1836	7867	20052	0.625
1836	7875	20061	0.555555582
1838	7888	20062	0.625
1839	7878	20061	0.625
1840	7932	20072	0.666666687
1841	7933	20072	0.666666687
1841	8456	20092	1
1843	7937	20072	0.666666687
1844	7934	20072	1
1846	7938	20072	0.625
1849	7917	20071	0.625
1851	7943	20072	0.625
1852	7944	20072	0.625
1854	7982	20081	0.555555582
1861	8047	20082	0.625
1861	8314	20092	0.666666687
1862	8148	20091	0.555555582
1862	8471	20092	1
1866	8155	20091	0.555555582
1869	7996	20081	0.625
1870	8056	20082	0.625
1873	8333	20092	0.666666687
1874	8101	20082	1
1876	8062	20082	0.625
1876	8336	20092	0.545454562
1877	8168	20091	0.666666687
1878	8005	20081	0.625
1881	8106	20082	1
1886	8491	20092	1
1888	8074	20082	0.625
1891	8018	20081	1
1895	8140	20091	0.625
1896	8308	20092	0.625
1899	8473	20092	1
1919	8198	20091	0.625
1924	8203	20091	0.625
1925	8374	20092	0.625
1937	8216	20091	0.625
1943	8222	20091	0.625
1943	8511	20092	1
1959	8408	20092	0.625
1960	8409	20092	0.625
1976	8255	20091	0.625
1978	8427	20092	0.625
1980	8429	20092	0.625
1983	8432	20092	0.625
1987	8436	20092	0.625
1988	8437	20092	0.625
1992	8271	20091	0.625
1992	8541	20092	1
1994	8543	20092	1
1996	8445	20092	1
1998	8447	20092	0.625
1832	7834	20032	0.666666687
1830	7819	20012	0.666666687
\.


--
-- Data for Name: eligtwicefail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligtwicefail (studentid, classid, courseid, section, coursename, termid) FROM stdin;
1886	12648	5	WFU	CS 32	20092
1886	13003	5	X	CS 32	20093
1831	11390	2	MHRU	CS 12	20022
1831	11406	2	TFVW	CS 12	20031
1830	11352	5	MHX1	CS 32	20002
1830	11359	5	W1	CS 32	20011
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
1840	ORENSE	ADRIAN	CORDOVA	
1841	VILLARANTE	JAY RICKY	BARRAMEDA	
1842	LUMONGSOD	PIO RYAN	SAGARINO	
1843	TOBIAS	GEORGE HELAMAN	ASTURIAS	
1844	CUNANAN	JENNIFER	DELA CRUZ	
1845	RAGASA	ROGER JOHN	ESTEPA	
1846	MARANAN	KERVIN	CATUNGAL	
1847	DEINLA	REGINALD ELI	ATIENZA	
1848	RAMIREZ	NORBERTO	ALLAREY	II
1849	PUGAL	EDGAR	STA BARBARA	JR
1850	JOVEN	KATHLEEN GRACE	GUERRERO	
1851	ESCALANTE	ED ALBERT	BELARGO	
1852	CONTRERAS	PAUL VINCENT	SALES	
1853	DIRECTO	KAREIN JOY	TOLENTINO	
1854	VALLO	LOVELIA	LAROCO	
1855	DOMINGO	CYROD JOHN	FLORIDA	
1856	SUBA	KEVIN RAINIER	SINOGAYA	
1857	CATAJOY	VINCENT NICHOLAS	RANA	
1858	BATANES	BRYAN MATTHEW	AVENDANO	
1859	BALAGAPO	JOSHUA	KHO	
1860	DOMANTAY	ERIC	AMPARO	JR
1861	JAVIER	JEWEL LEX	TONG	
1862	JUAT	WESLEY	MENDOZA	
1863	ISIDRO	HOMER IRIC	SANTOS	
1864	VILLANUEVA	MARIANNE ANGELIE	OCAMPO	
1865	MAMARIL	VIC ANGELO	DELOS SANTOS	
1866	ARANA	RYAN KRISTOFER	IGMAT	
1867	NICOLAS	DANA ELISA	GAGALAC	
1868	VACALARES	ISAIAH JAMES	VALDES	
1869	SANTILLAN	MA CECILIA		
1870	PINEDA	JAKE ERICKSON	BOTEROS	
1871	LOYOLA	ELIZABETH	CUETO	
1872	BUGAOAN	FRANCIS KEVIN	ALIMORONG	
1873	GALLARDO	FRANCIS JOMER	DE LEON	
1874	ARGARIN	MICHAEL ERICK	STA TERESA	
1875	VILLARUZ	JULIAN	CASTILLO	
1876	FRANCISCO	ARMINA	EUGENIO	
1877	AQUINO	JOSEPH ARMAN	BONGCO	
1878	AME	MARTIN ROMAN LORENZO	ILAGAN	
1879	CELEDONIO	MESSIAH JAN	LEBID	
1880	SABIDONG	JEROME	RONCESVALLES	
1881	FLORENCIO	JOHN CARLO	MAQUILAN	
1882	EPISTOLA	SILVEN VICTOR	DUMALAG	
1883	SANTOS	JOHN ISRAEL	LORENZO	
1884	SANTOS	MARIE JUNNE	CABRAL	
1885	FABIC	JULIAN NICHOLAS	REYES	
1886	TORRES	ERIC	TUQUERO	
1887	CUETO	BENJAMIN	ANGELES	JR
1888	PASCUAL	JEANELLA KLARYS	ESPIRITU	
1889	GAMBA	JOSE NOEL	CARDONES	
1890	REFAMONTE	JARED	MUMAR	
1891	BARITUA	KARESSA ALEXANDRA	ONG	
1892	SEMILLA	STANLEY	TINA	
1893	ANGELES	MARC ARTHUR	PAJE	
1894	SORIAO	HANS CHRISTIAN	BALTAZAR	
1895	DINO	ARVIN	PABINES	
1896	MORALES	NOELYN JOYCE	ROL	
1897	MANALAC	DAVID ROBIN	MANALAC	
1898	SAY	KOHLEN ANGELO	PEREZ	
1899	ADRIANO	JAMES PATRICK	DAVID	
1900	SERRANO	MICHAEL	DIONISIO	
1901	CHOAPECK	MARIE ANTOINETTE	R	
1902	TURLA	ISAIAH EDWARD	G	
1903	MONCADA	DEAN ALVIN	BAJAMONDE	
1904	EVANGELISTA	JOHN EROL	MILANO	
1905	ASIS	KRYSTIAN VIEL	CABUGAO	
1906	CLAVECILLA	VANESSA VIVIEN	FRANCISCO	
1907	RONDON	RYAN ODYLON	GAZMEN	
1908	ARANAS	CHRISTIAN JOY	MARQUEZ	
1909	AGUILAR	JENNIFER	RAMOS	
1910	CUEVAS	SARAH	BERNABE	
1911	PASCUAL	JAYVEE ELJOHN	ACABO	
1912	TORRES	DANAH VERONICA	PADILLA	
1913	BISAIS	APRYL ROSE	LABAYOG	
1914	CHUA	TED GUILLANO	SY	
1915	CRUZ	IVAN KRISTEL	POLICARPIO	
1916	AQUINO	CHLOEBELLE	RAMOS	
1917	YUTUC	DANIEL	LALAGUNA	
1918	DEL ROSARIO	BENJIE	REYES	
1919	RAMOS	ANNA CLARISSA	BEATO	
1920	REYES	CHARMAILENE	CAPILI	
1921	ABANTO	JEANELLE	ESGUERRA	
1922	BONDOC	ROD XANDER	RIVERA	
1923	TACATA	NERISSA MONICA	DE GUZMAN	
1924	RABE	REZELEE	AQUINO	
1925	DECENA	BERLYN ANNE	ARAGON	
1926	DIMLA	KARL LEN MAE	BALDOMERO	
1927	SANCHEZ	ZIV YVES	MONTOYA	
1928	LITIMCO	CZELINA ELLAINE	ONG	
1929	GUILLEN	NEIL DAVID	BALGOS	
1930	SOMOSON	LOU MERLENETTE	BAUTISTA	
1931	TALAVERA	RHIZA MAE	GO	
1932	CANOY	JOHN GABRIEL	ERUM	
1933	CHUA	RALPH JACOB	ANG	
1934	EALA	MARIA AZRIEL THERESE	DESTUA	
1935	AYAG	DANIELLE ANNE	FRANCISCO	
1936	DE VILLA	RACHEL	LUNA	
1937	JAYMALIN	JEAN DOMINIQUE	BERNAL	
1938	LEGASPI	CHARMAINE PAMELA	ABERCA	
1939	LIBUNAO	ARIANNE FRANCESCA	QUIJANO	
1940	REGENCIA	FELIX ARAM	JEREMIAS	
1941	SANTI	NATHAN LEMUEL	GO	
1942	LEONOR	WENDY GENEVA	SANTOS	
1943	LUNA	MARA ISSABEL	SUPLICO	
1944	SIRIBAN	MA LORENA JOY	ASCUTIA	
1945	LEGASPI	MISHAEL MAE	CRUZ	
1946	SUN	HANNAH ERIKA	YAP	
1947	PARRENO	NICOLE ANNE	KAHN	
1948	BULANHAGUI	KEVIN DAVID	BALANAY	
1949	MONCADA	JULIA NINA	SOMERA	
1950	IBANEZ	SEBASTIAN	CANLAS	
1951	COLA	VERNA KATRIN	BEDUYA	
1952	SANTOS	MARIA RUBYLISA	AREVALO	
1953	YECLA	NORVIN	GARCIA	
1954	CASTANEDA	ANNA MANNELLI	ESPIRITU	
1955	FOJAS	EDGAR ALLAN	GO	
1956	DELA CRUZ	EMERY	FABRO	
1957	SADORNAS	JON PERCIVAL	GARCIA	
1958	VILLANUEVA	MARY GRACE	AYENTO	
1959	ESGUERRA	JOSE MARI	MARCELO	
1960	SY	KYLE BENEDICT	GUERRERO	
1961	TORRES	LUIS ANTONIO	PEREZ	
1962	TONG	MAYNARD JEFFERSON	ZHUANG	
1963	DATU	PATRICH PAOLO	BONETE	
1964	PEREA	EMMANUEL	LOYOLA	
1965	BALOY	MICHAEL JOYSON	GERMAR	
1966	REAL	VICTORIA CASSANDRA	RUIVIVAR	
1967	MARTIJA	JASPER	ENRIQUEZ	
1968	OCHAVEZ	ARISA	CAAKBAY	
1969	AMORANTO	PAOLO	SISON	
1970	SAN ANTONIO	JAYVIC	PORTILLO	
1971	SARDONA	CATHERINE LORAINE	FESTIN	
1972	MENESES	ANGELO	CAL	
1973	AUSTRIA	DARRWIN DEAREST	CRISOSTOMO	
1974	BURGOS	ALVIN JOHN	MANLIGUEZ	
1975	MAGNO	JENNY	NARSOLIS	
1976	SAPASAP	RIC JANUS	OLIVER	
1977	QUILAB	FRANCIS MIGUEL	EVANGELISTA	
1978	PINEDA	RIZA RAE	ALDECOA	
1979	TAN	XYRIZ CZAR	PINEDA	
1980	DELAS PENAS	KRISTOFER	EMPUERTO	
1981	MANSOS	JOHN FRANCIS	LLAGAS	
1982	PANOPIO	GIRAH MAY	CHUA	
1983	LEGASPINA	CHRISLENE	BUGARIN	
1984	RIVERA	DON JOSEPH	TIANGCO	
1985	RUBIO	MARY GRACE	TALAN	
1986	LEONOR	CHARLES TIMOTHY	DEL ROSARIO	
1987	CABUHAT	JOHN JOEL	URBISTONDO	
1988	MARANAN	GENIE LINN	PADILLA	
1989	WANG	CASSANDRA LEIGH	LACASTA	
1990	YU	GLADYS JOYCE	OCAP	
1991	TOMACRUZ	ARVIN JOHN	CRUZ	
1992	BALDUEZA	GYZELLE	EVANGELISTA	
1993	BATAC	JOSE EMMANUEL	DE JESUS	
1994	CUETO	JAN COLIN	OJEDA	
1995	RUBI	SHIELA PAULINE JOY	VERGARA	
1996	ALCARAZ	KEN GERARD	TECSON	
1997	DE LOS SANTOS	PAOLO MIGUEL	MACALINDONG	
1998	CHAVEZ	JOE-MAR	ORINDAY	
1999	PERALTA	PAOLO THOMAS	REYES	
2000	SANTOS	ALEXANDREI	GONZALES	
2001	MACAPINLAC	VERONICA	ALCARAZ	
2002	PACAPAC	DIANA MAE	CANLAS	
2003	DUNGCA	JOHN ALPERT	ANCHO	
2004	ZACARIAS	ROEL JEREMIAH	ALCANTARA	
2005	RICIO	DUSTIN EDRIC	LEGARDA	
2006	ARBAS	HARVEY IAN	SOLAYAO	
2007	SALVADOR	RAMON JOSE NILO	DELA VEGA	
2008	DORADO	JOHN PHILIP	URRIZA	
2009	DEATRAS	SHEALTIEL PAUL ROSSNERR	CALUAG	
2010	CAPACILLO	JULES ALBERT	BERINGUELA	
2011	SALAMANCA	KYLA MARIE	G.	
2012	AVE	ARMOND	C.	
2013	CALARANAN	MICHAEL KEVIN	PONTE	
2014	DOCTOR	JET LAWRENCE	PARONE	
2015	ANG	RITZ DANIEL	CATAMPATAN	
2016	FORMES	RAFAEL GERARD	DELA CRUZ	
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
34723	7814	11336	6
34724	7814	11337	7
34725	7814	11338	7
34726	7814	11339	6
34727	7814	11340	4
34728	7814	11341	3
34729	7814	11342	1
34730	7815	11343	4
34731	7815	11344	5
34732	7815	11345	6
34733	7815	11346	4
34734	7815	11347	3
34735	7816	11348	10
34736	7816	11349	11
34737	7816	11350	9
34738	7816	11351	8
34739	7816	11352	11
34740	7817	11353	3
34741	7817	11354	9
34742	7818	11355	7
34743	7818	11356	9
34744	7818	11357	13
34745	7818	11358	10
34747	7819	11360	13
34748	7819	11361	9
34749	7819	11362	11
34750	7819	11363	11
34751	7819	11364	9
34752	7819	11365	11
34753	7820	11366	6
34754	7820	11367	5
34755	7821	11368	9
34756	7821	11369	6
34757	7821	11370	11
34758	7821	11371	9
34759	7821	11372	5
34760	7822	11373	6
34761	7822	11374	9
34762	7822	11375	6
34765	7823	11378	7
34766	7823	11379	6
34767	7823	11380	5
34768	7823	11381	6
34770	7824	11383	9
34771	7824	11384	8
34772	7824	11385	10
34773	7825	11386	5
34774	7825	11387	9
34775	7825	11388	7
34776	7825	11389	7
34778	7826	11391	7
34779	7826	11392	9
34780	7826	11393	3
34781	7826	11394	6
34782	7826	11395	9
34783	7827	11396	14
34784	7827	11397	9
34785	7827	11398	10
34786	7827	11399	5
34787	7827	11400	14
34788	7828	11401	7
34789	7828	11402	14
34790	7828	11403	9
34791	7828	11404	14
34792	7828	11405	5
34794	7829	11407	9
34795	7829	11408	8
34796	7829	11409	9
34797	7829	11410	4
34798	7829	11411	7
34799	7830	11412	12
34800	7830	11413	7
34801	7830	11414	5
34802	7830	11415	9
34803	7830	11416	14
34804	7831	11417	14
34805	7831	11418	9
34806	7831	11419	6
34807	7831	11420	6
34808	7831	11421	12
34809	7832	11422	12
34810	7833	11423	5
34811	7833	11424	4
34812	7833	11425	13
34813	7833	11426	4
34814	7833	11427	9
34793	7828	11406	11
34816	7834	11429	11
34817	7834	11430	9
34818	7834	11431	11
34819	7834	11432	11
34820	7834	11433	11
34821	7835	11434	13
34822	7835	11435	9
34823	7835	11436	9
34824	7835	11437	9
34825	7835	11438	5
34826	7836	11439	9
34827	7836	11440	6
34828	7836	11441	4
34829	7836	11442	2
34830	7836	11443	2
34831	7837	11444	6
34832	7838	11445	8
34833	7839	11446	5
34834	7839	11447	5
34835	7840	11448	10
34836	7841	11449	4
34837	7841	11450	9
34838	7841	11451	8
34839	7841	11452	11
34840	7841	11453	8
34841	7841	11454	9
34842	7842	11455	9
34843	7842	11456	4
34844	7842	11457	9
34845	7842	11458	11
34846	7842	11459	5
34847	7842	11453	11
34848	7843	11460	12
34849	7843	11461	7
34850	7843	11462	11
34851	7843	11463	13
34852	7843	11464	6
34853	7844	11465	12
34854	7844	11466	6
34855	7844	11467	7
34856	7844	11468	7
34857	7844	11469	7
34858	7845	11470	4
34859	7845	11471	7
34860	7845	11472	1
34861	7845	11473	4
34862	7845	11474	1
34863	7846	11475	7
34864	7846	11476	4
34865	7846	11477	8
34866	7846	11478	1
34867	7846	11479	7
34868	7846	11480	9
34869	7847	11481	12
34870	7847	11482	4
34871	7847	11483	5
34872	7847	11477	11
34873	7847	11479	8
34874	7847	11480	9
34875	7848	11484	11
34876	7848	11485	11
34877	7848	11486	11
34878	7848	11487	11
34879	7848	11488	9
34880	7848	11489	11
34881	7849	11490	5
34882	7849	11491	11
34883	7849	11492	11
34884	7849	11493	9
34885	7849	11489	11
34886	7850	11494	9
34887	7850	11495	6
34888	7850	11496	13
34889	7850	11497	5
34890	7850	11498	2
34891	7851	11499	4
34892	7851	11500	7
34893	7852	11501	2
34894	7852	11502	4
34895	7853	11503	14
34896	7854	11504	6
34897	7855	11505	13
34898	7856	11506	6
34899	7856	11507	9
34900	7856	11508	9
34901	7856	11509	6
34902	7856	11510	2
34903	7856	11511	5
34904	7856	11512	6
34905	7857	11513	11
34777	7825	11390	11
34769	7823	11382	6
34906	7857	11514	5
34907	7857	11508	5
34908	7857	11515	6
34763	7822	11376	9
34746	7818	11359	11
34909	7857	11516	6
34910	7857	11517	9
34911	7858	11518	6
34912	7858	11519	5
34913	7858	11520	11
34914	7858	11521	11
34915	7858	11522	3
34916	7858	11523	9
34917	7859	11524	8
34918	7859	11525	11
34919	7859	11526	6
34920	7859	11527	12
34921	7859	11523	9
34922	7859	11517	7
34923	7860	11528	4
34924	7860	11529	8
34925	7860	11530	7
34926	7860	11527	1
34927	7860	11531	7
34928	7861	11532	7
34929	7861	11533	5
34930	7861	11534	4
34931	7861	11535	3
34932	7861	11536	4
34933	7862	11537	6
34934	7862	11538	4
34935	7862	11539	4
34936	7862	11540	8
34937	7862	11541	2
34938	7863	11542	3
34939	7863	11543	14
34940	7863	11544	9
34941	7863	11545	9
34942	7863	11546	12
34943	7863	11547	7
34944	7863	11548	2
34945	7864	11549	8
34946	7864	11550	5
34947	7864	11551	9
34948	7864	11546	6
34949	7864	11552	6
34950	7864	11553	2
34951	7864	11554	3
34952	7865	11555	6
34953	7865	11556	5
34954	7865	11557	5
34955	7865	11558	10
34956	7865	11559	8
34957	7865	11560	7
34958	7866	11561	12
34959	7866	11562	10
34960	7866	11563	4
34961	7866	11564	9
34962	7866	11565	6
34963	7866	11566	5
34964	7867	11567	13
34965	7867	11568	11
34966	7867	11569	9
34967	7867	11570	6
34968	7867	11571	4
34969	7868	11549	8
34970	7868	11572	7
34971	7868	11573	5
34972	7868	11574	4
34973	7868	11575	1
34974	7869	11576	1
34975	7869	11577	2
34976	7870	11578	5
34977	7871	11579	6
34978	7872	11580	3
34979	7872	11581	6
34980	7873	11582	14
34981	7873	11583	8
34982	7873	11584	10
34983	7873	11585	6
34984	7874	11586	2
34985	7874	11587	3
34986	7874	11582	5
34987	7874	11588	5
34988	7874	11589	5
34989	7874	11590	6
34990	7874	11591	1
34991	7875	11592	11
34992	7875	11593	11
34993	7875	11594	8
34994	7875	11595	13
34995	7875	11596	9
34996	7876	11597	4
34997	7876	11598	8
34998	7876	11599	6
34999	7876	11600	9
35000	7876	11601	3
35001	7877	11602	5
35002	7877	11603	5
35003	7877	11604	9
35004	7877	11605	2
35005	7877	11606	5
35006	7878	11607	3
35007	7878	11608	11
35008	7878	11609	2
35009	7878	11610	3
35010	7878	11611	5
35011	7879	11612	2
35012	7879	11613	8
35013	7879	11614	1
35014	7879	11615	3
35015	7879	11611	6
35016	7880	11607	4
35017	7880	11613	9
35018	7880	11616	1
35019	7880	11617	7
35020	7880	11618	7
35021	7881	11619	5
35022	7881	11620	10
35023	7881	11621	5
35024	7881	11622	5
35025	7881	11618	1
35026	7882	11623	7
35027	7882	11624	9
35028	7882	11625	6
35029	7882	11626	3
35030	7882	11627	2
35031	7883	11628	14
35032	7883	11629	14
35033	7883	11630	9
35034	7884	11631	4
35035	7884	11632	7
35036	7884	11633	8
35037	7884	11634	4
35038	7884	11635	12
35039	7885	11636	2
35040	7885	11628	14
35041	7885	11637	8
35042	7885	11638	1
35043	7885	11639	2
35044	7885	11640	4
35045	7885	11641	1
35046	7886	11642	13
35047	7886	11643	9
35048	7886	11644	11
35049	7886	11645	9
35050	7886	11646	9
35051	7887	11647	8
35052	7887	11648	6
35053	7887	11649	9
35054	7887	11650	3
35055	7887	11638	6
35056	7887	11651	5
35057	7888	11652	6
35058	7888	11653	11
35059	7888	11654	4
35060	7888	11655	4
35061	7888	11656	6
35062	7889	11657	8
35063	7889	11658	4
35064	7889	11659	8
35065	7889	11660	5
35066	7889	11661	8
35067	7890	11662	5
35068	7890	11663	3
35069	7890	11664	3
35070	7890	11665	9
35071	7890	11666	4
35072	7891	11667	3
35073	7891	11668	9
35074	7891	11669	6
35075	7891	11670	4
35076	7891	11666	5
35077	7892	11671	5
35078	7892	11672	5
35079	7892	11673	4
35080	7892	11674	7
35081	7892	11661	2
35082	7893	11675	9
35083	7893	11676	3
35084	7893	11677	2
35085	7893	11670	4
35086	7893	11666	3
35087	7894	11678	14
35088	7895	11679	9
35089	7896	11680	4
35090	7897	11681	9
35091	7898	11682	8
35092	7899	11683	7
35093	7900	11684	8
35094	7901	11685	2
35095	7901	11686	4
35096	7902	11687	14
35097	7902	11688	4
35098	7902	11689	7
35099	7902	11690	11
35100	7902	11691	8
35101	7902	11692	12
35102	7902	11693	11
35103	7902	11694	1
35104	7903	11695	8
35105	7903	11696	11
35106	7903	11691	8
35107	7903	11697	12
35108	7903	11698	2
35109	7903	11699	5
35110	7903	11700	14
35111	7903	11701	4
35112	7904	11702	9
35113	7904	11703	9
35114	7904	11687	14
35115	7904	11688	5
35116	7904	11704	9
35117	7904	11692	8
35118	7904	11693	7
35119	7905	11687	14
35120	7905	11688	3
35121	7905	11705	2
35122	7905	11690	9
35123	7905	11706	9
35124	7905	11707	9
35125	7905	11701	8
35126	7906	11708	3
35127	7906	11709	7
35128	7906	11710	11
35129	7906	11711	7
35130	7907	11712	7
35131	7907	11713	7
35132	7907	11714	1
35133	7907	11715	2
35134	7907	11716	7
35135	7908	11717	5
35136	7908	11718	9
35137	7908	11719	2
35138	7908	11720	4
35139	7908	11721	5
35140	7909	11722	4
35141	7909	11723	8
35142	7909	11724	1
35143	7909	11716	8
35144	7910	11725	6
35145	7910	11726	8
35146	7910	11727	2
35147	7910	11728	9
35148	7911	11729	4
35149	7911	11730	4
35150	7911	11731	9
35151	7911	11732	13
35152	7912	11733	6
35153	7912	11734	9
35154	7912	11735	6
35155	7912	11736	6
35156	7912	11716	4
35157	7913	11737	3
35158	7913	11738	8
35159	7913	11713	9
35160	7913	11739	2
35161	7913	11721	8
35162	7914	11740	5
35163	7914	11741	7
35164	7914	11742	1
35165	7914	11719	2
35166	7914	11743	2
35167	7915	11744	1
35168	7915	11745	5
35169	7915	11746	3
35170	7915	11747	11
35171	7915	11748	2
35172	7916	11744	1
35173	7916	11745	5
35174	7916	11746	3
35175	7916	11747	11
35176	7916	11748	2
35177	7917	11749	4
35178	7917	11745	7
35179	7917	11750	11
35180	7917	11751	10
35181	7917	11752	5
35182	7918	11744	1
35183	7918	11745	5
35184	7918	11746	9
35185	7918	11747	8
35186	7918	11748	4
35187	7919	11753	12
35188	7919	11754	7
35189	7919	11750	7
35190	7919	11755	11
35191	7919	11752	2
35192	7920	11744	1
35193	7920	11745	4
35194	7920	11746	8
35195	7920	11747	6
35196	7920	11748	3
35197	7921	11744	2
35198	7921	11745	7
35199	7921	11746	1
35200	7921	11747	5
35201	7921	11748	1
35202	7922	11756	7
35203	7922	11757	9
35204	7922	11758	3
35205	7922	11759	3
35206	7922	11732	5
35207	7923	11744	1
35208	7923	11745	6
35209	7923	11746	3
35210	7923	11747	8
35211	7923	11748	3
35212	7924	11756	4
35213	7924	11757	6
35214	7924	11760	6
35215	7924	11761	1
35216	7924	11732	1
35217	7925	11762	9
35218	7926	11763	11
35219	7926	11764	6
35220	7926	11765	5
35221	7926	11766	2
35222	7926	11767	12
35223	7926	11768	6
35224	7927	11769	4
35225	7927	11770	3
35226	7927	11771	4
35227	7927	11772	8
35228	7927	11773	5
35229	7927	11774	12
35230	7927	11775	12
35231	7928	11776	11
35232	7928	11777	5
35233	7928	11778	10
35234	7928	11779	11
35235	7928	11780	9
35236	7928	11781	12
35237	7928	11782	11
35238	7929	11783	13
35239	7929	11784	6
35240	7929	11785	5
35241	7929	11780	2
35242	7929	11786	2
35243	7929	11782	5
35244	7930	11787	9
35245	7930	11788	13
35246	7930	11789	5
35247	7930	11790	13
35248	7930	11791	7
35249	7931	11792	13
35250	7931	11793	3
35251	7931	11794	7
35252	7931	11795	7
35253	7931	11796	3
35254	7931	11790	8
35255	7932	11797	9
35256	7932	11798	11
35257	7932	11793	8
35258	7932	11799	9
35259	7932	11800	11
35260	7932	11801	2
35261	7933	11802	4
35262	7933	11793	6
35263	7933	11803	11
35264	7933	11804	9
35265	7933	11805	5
35266	7933	11806	11
35267	7934	11807	9
35268	7934	11808	8
35269	7934	11809	11
35270	7934	11804	10
35271	7934	11810	11
35272	7935	11811	12
35273	7935	11812	6
35274	7935	11813	8
35275	7935	11814	10
35276	7935	11815	7
35277	7935	11816	6
35278	7936	11817	6
35279	7936	11797	8
35280	7936	11818	9
35281	7936	11793	4
35282	7936	11814	13
35283	7936	11806	8
35284	7937	11819	2
35285	7937	11803	11
35286	7937	11820	9
35287	7937	11794	11
35288	7937	11806	11
35289	7938	11821	5
35290	7938	11822	11
35291	7938	11823	2
35292	7938	11824	3
35293	7938	11825	4
35294	7939	11826	7
35295	7939	11827	9
35296	7939	11823	4
35297	7939	11828	5
35298	7939	11825	3
35299	7940	11829	8
35300	7940	11827	9
35301	7940	11823	5
35302	7940	11828	6
35303	7940	11825	7
35304	7941	11830	4
35305	7941	11831	8
35306	7941	11776	8
35307	7941	11832	7
35308	7941	11833	6
35309	7942	11834	4
35310	7942	11835	9
35311	7942	11823	6
35312	7942	11836	1
35313	7942	11825	9
35314	7943	11837	13
35315	7943	11838	11
35316	7943	11839	5
35317	7943	11840	6
35318	7943	11841	3
35319	7944	11842	4
35320	7944	11843	11
35321	7944	11795	8
35322	7944	11844	5
35323	7944	11825	5
35324	7945	11826	5
35325	7945	11827	5
35326	7945	11823	5
35327	7945	11828	6
35328	7945	11825	2
35329	7946	11845	4
35330	7946	11846	4
35331	7946	11847	7
35332	7946	11848	2
35333	7946	11849	1
35334	7947	11850	3
35335	7947	11851	3
35336	7947	11827	7
35337	7947	11852	3
35338	7947	11810	3
35339	7948	11853	1
35340	7948	11854	7
35341	7948	11855	4
35342	7948	11856	2
35343	7948	11841	2
35344	7949	11857	3
35345	7950	11858	12
35346	7951	11859	3
35347	7951	11860	9
35348	7952	11861	4
35349	7953	11862	5
35350	7954	11863	6
35351	7954	11864	5
35352	7955	11860	11
35353	7956	11865	4
35354	7956	11866	6
35355	7957	11867	4
35356	7958	11868	3
35357	7959	11869	9
35358	7960	11870	3
35359	7961	11871	5
35360	7962	11872	6
35361	7962	11873	11
35362	7962	11874	7
35363	7962	11875	8
35364	7962	11876	2
35365	7962	11877	9
35366	7963	11878	13
35367	7963	11879	14
35368	7963	11880	13
35369	7963	11881	14
35370	7963	11882	9
35371	7963	11883	9
35372	7963	11884	11
35373	7964	11885	4
35374	7964	11886	6
35375	7964	11887	1
35376	7964	11888	4
35377	7964	11889	1
35378	7965	11890	6
35379	7965	11891	3
35380	7965	11892	11
35381	7965	11893	6
35382	7965	11894	7
35383	7966	11895	5
35384	7966	11896	7
35385	7966	11874	6
35386	7966	11897	3
35387	7966	11898	3
35388	7967	11899	2
35389	7967	11900	9
35390	7967	11901	11
35391	7967	11902	5
35392	7967	11903	6
35393	7968	11904	7
35394	7968	11905	11
35395	7968	11902	3
35396	7968	11906	2
35397	7968	11903	8
35398	7969	11907	8
35399	7969	11908	7
35400	7969	11909	5
35401	7969	11910	2
35402	7970	11911	5
35403	7970	11912	4
35404	7970	11901	8
35405	7970	11910	4
35406	7970	11913	11
35407	7970	11903	6
35408	7971	11914	7
35409	7971	11913	11
35410	7971	11880	7
35411	7971	11902	7
35412	7971	11915	7
35413	7971	11875	6
35414	7972	11916	3
35415	7972	11904	8
35416	7972	11913	8
35417	7972	11902	4
35418	7972	11906	2
35419	7973	11917	12
35420	7973	11918	9
35421	7973	11919	7
35422	7973	11920	6
35423	7973	11921	2
35424	7974	11922	2
35425	7974	11923	4
35426	7974	11924	7
35427	7974	11925	2
35428	7974	11926	7
35429	7975	11927	8
35430	7975	11920	5
35431	7975	11928	4
35432	7975	11929	4
35433	7975	11921	3
35434	7976	11930	9
35435	7976	11927	9
35436	7976	11920	6
35437	7976	11931	8
35438	7976	11932	13
35439	7977	11933	6
35440	7977	11934	9
35441	7977	11920	9
35442	7977	11935	4
35443	7977	11921	7
35444	7978	11936	4
35445	7978	11937	9
35446	7978	11938	9
35447	7978	11921	8
35448	7979	11939	6
35449	7979	11918	10
35450	7979	11920	11
35451	7979	11940	6
35452	7980	11941	3
35453	7980	11942	2
35454	7980	11937	9
35455	7980	11938	7
35456	7980	11921	6
35457	7981	11943	5
35458	7981	11944	7
35459	7981	11945	7
35460	7981	11920	6
35461	7981	11921	7
35462	7982	11946	5
35463	7982	11947	11
35464	7982	11938	9
35465	7982	11948	6
35466	7982	11921	1
35467	7983	11949	8
35468	7983	11919	6
35469	7983	11938	6
35470	7983	11950	9
35471	7983	11951	8
35472	7984	11952	3
35473	7984	11953	7
35474	7984	11954	7
35475	7984	11955	6
35476	7984	11932	2
35477	7985	11956	3
35478	7985	11957	6
35479	7985	11958	9
35480	7985	11959	2
35481	7985	11960	3
35482	7986	11961	4
35483	7986	11962	7
35484	7986	11963	2
35485	7986	11964	5
35486	7986	11925	1
35487	7987	11965	4
35488	7987	11923	6
35489	7987	11966	6
35490	7987	11967	7
35491	7987	11968	6
35492	7988	11969	2
35493	7988	11970	9
35494	7988	11971	3
35495	7988	11972	3
35496	7988	11973	6
35497	7989	11974	7
35498	7989	11975	6
35499	7989	11976	8
35500	7989	11977	11
35501	7989	11968	6
35502	7990	11956	3
35503	7990	11957	9
35504	7990	11958	5
35505	7990	11959	9
35506	7990	11960	8
35507	7991	11978	6
35508	7991	11979	6
35509	7991	11980	4
35510	7991	11981	2
35511	7991	11968	6
35512	7992	11982	7
35513	7992	11923	5
35514	7992	11976	5
35515	7992	11983	9
35516	7992	11968	1
35517	7993	11956	3
35518	7993	11957	7
35519	7993	11958	6
35520	7993	11959	3
35521	7993	11960	6
35522	7994	11984	8
35523	7994	11957	8
35524	7994	11979	8
35525	7994	11959	9
35526	7994	11960	9
35527	7995	11985	4
35528	7995	11970	6
35529	7995	11986	5
35530	7995	11987	4
35531	7995	11973	5
35532	7996	11988	8
35533	7996	11989	11
35534	7996	11990	3
35535	7996	11991	8
35536	7996	11992	7
35537	7997	11993	6
35538	7997	11970	9
35539	7997	11994	5
35540	7997	11995	10
35541	7997	11973	7
35542	7998	11956	4
35543	7998	11957	6
35544	7998	11958	8
35545	7998	11959	3
35546	7998	11960	6
35547	7999	11996	6
35548	7999	11979	5
35549	7999	11997	5
35550	7999	11998	4
35551	7999	11999	1
35552	8000	12000	4
35553	8000	12001	6
35554	8000	11971	4
35555	8000	12002	2
35556	8000	11925	1
35557	8001	12003	6
35558	8001	12004	7
35559	8001	12005	6
35560	8001	12006	2
35561	8001	11968	6
35562	8002	12007	5
35563	8002	11934	4
35564	8002	11962	7
35565	8002	12008	7
35566	8002	11992	1
35567	8003	12009	3
35568	8003	12010	9
35569	8003	12011	8
35570	8003	12012	4
35571	8003	11925	1
35572	8004	12013	6
35573	8004	12014	5
35574	8004	12015	4
35575	8004	12016	6
35576	8004	11968	5
35577	8005	12017	5
35578	8005	12018	11
35579	8005	12019	4
35580	8005	12020	12
35581	8005	11968	5
35582	8006	11996	7
35583	8006	11979	8
35584	8006	11997	7
35585	8006	11998	3
35586	8006	11999	4
35587	8007	12021	6
35588	8007	12010	10
35589	8007	12022	8
35590	8007	12012	3
35591	8007	11925	11
35592	8008	12003	5
35593	8008	12004	8
35594	8008	12005	5
35595	8008	12006	1
35596	8008	11992	5
35597	8009	11996	6
35598	8009	11979	4
35599	8009	11997	8
35600	8009	11998	4
35601	8009	11999	1
35602	8010	12023	4
35603	8010	11970	7
35604	8010	12008	4
35605	8010	12024	8
35606	8010	11973	6
35607	8011	12025	7
35608	8011	12026	9
35609	8011	11994	5
35610	8011	11981	2
35611	8011	11992	6
35612	8012	12027	4
35613	8012	11970	8
35614	8012	12008	5
35615	8012	12024	9
35616	8012	11973	8
35617	8013	12028	3
35618	8013	11970	4
35619	8013	12029	9
35620	8013	12030	4
35621	8013	11973	3
35622	8014	12031	12
35623	8014	11970	1
35624	8014	12032	8
35625	8014	12024	7
35626	8014	11973	5
35627	8015	11996	4
35628	8015	11979	9
35629	8015	11997	9
35630	8015	11998	4
35631	8015	11999	5
35632	8016	12033	1
35633	8016	12034	3
35634	8016	12035	8
35635	8016	12036	3
35636	8016	12037	4
35637	8017	12038	5
35638	8017	12039	5
35639	8017	12040	2
35640	8017	12041	7
35641	8017	12037	5
35642	8018	12042	1
35643	8018	12043	2
35644	8018	12035	11
35645	8018	12044	1
35646	8018	12037	11
35647	8019	12045	8
35648	8019	12046	12
35649	8019	12047	8
35650	8019	12048	10
35651	8019	12049	7
35652	8020	12050	5
35653	8020	12051	6
35654	8020	12052	12
35655	8020	12053	3
35656	8020	12054	12
35657	8020	12055	3
35658	8021	12045	6
35659	8021	12056	14
35660	8021	12057	4
35661	8021	12058	7
35662	8021	12052	9
35663	8021	12059	12
35664	8021	12060	11
35665	8022	12061	7
35666	8022	12062	5
35667	8022	12063	2
35668	8022	12064	2
35669	8022	12059	3
35670	8022	12065	12
35671	8022	12066	7
35672	8023	12047	7
35673	8023	12067	8
35674	8023	12068	5
35675	8023	12069	8
35676	8023	12070	6
35677	8024	12071	2
35678	8024	12072	11
35679	8024	12073	6
35680	8024	12069	8
35681	8024	12074	6
35682	8024	12075	2
35683	8025	12076	7
35684	8025	12077	8
35685	8025	12068	7
35686	8025	12073	7
35687	8025	12078	9
35688	8026	12079	6
35689	8026	12080	6
35690	8026	12081	11
35691	8026	12082	8
35692	8026	12083	12
35693	8026	12084	5
35694	8027	12085	9
35695	8027	12086	13
35696	8027	12087	7
35697	8027	12088	7
35698	8027	12089	3
35699	8027	12090	6
35700	8028	12089	5
35701	8028	12091	11
35702	8028	12068	1
35703	8028	12083	7
35704	8028	12090	5
35705	8029	12092	4
35706	8029	12058	12
35707	8029	12078	5
35708	8029	12053	6
35709	8029	12093	3
35710	8029	12094	12
35711	8029	12095	11
35712	8030	12072	11
35713	8030	12096	8
35714	8030	12058	5
35715	8030	12069	9
35716	8030	12097	5
35717	8031	12098	12
35718	8031	12099	11
35719	8031	12100	8
35720	8031	12101	1
35721	8031	12096	7
35722	8031	12102	5
35723	8032	12103	8
35724	8032	12104	7
35725	8032	12105	9
35726	8032	12106	6
35727	8032	12107	7
35728	8033	12047	7
35729	8033	12088	8
35730	8033	12108	6
35731	8033	12109	3
35732	8033	12110	6
35733	8033	12068	8
35734	8034	12111	10
35735	8034	12108	8
35736	8034	12112	5
35737	8034	12068	11
35738	8034	12090	9
35739	8035	12113	8
35740	8035	12114	13
35741	8035	12115	13
35742	8035	12116	6
35743	8035	12068	9
35744	8036	12117	2
35745	8036	12118	9
35746	8036	12047	8
35747	8036	12119	9
35748	8036	12120	6
35749	8036	12121	13
35750	8037	12122	6
35751	8037	12123	4
35752	8037	12124	7
35753	8037	12125	5
35754	8037	12082	3
35755	8038	12126	4
35756	8038	12087	9
35757	8038	12127	11
35758	8038	12096	13
35759	8038	12128	12
35760	8039	12087	6
35761	8039	12129	11
35762	8039	12130	9
35763	8039	12131	5
35764	8039	12121	7
35765	8040	12132	5
35766	8040	12133	9
35767	8040	12123	11
35768	8040	12108	11
35769	8040	12068	5
35770	8041	12134	4
35771	8041	12135	5
35772	8041	12136	9
35773	8041	12137	1
35774	8041	12082	13
35775	8041	12095	8
35776	8042	12138	3
35777	8042	12139	9
35778	8042	12140	5
35779	8042	12141	5
35780	8042	12142	6
35781	8043	12143	2
35782	8043	12047	6
35783	8043	12129	8
35784	8043	12144	6
35785	8043	12068	9
35786	8043	12145	3
35787	8044	12146	4
35788	8044	12147	5
35789	8044	12148	6
35790	8044	12149	7
35791	8044	12150	3
35792	8045	12151	4
35793	8045	12152	5
35794	8045	12153	2
35795	8045	12154	3
35796	8045	12155	2
35797	8046	12156	6
35798	8046	12157	9
35799	8046	12158	6
35800	8046	12159	9
35801	8046	12160	6
35802	8047	12161	2
35803	8047	12162	11
35804	8047	12080	8
35805	8047	12163	1
35806	8047	12107	5
35807	8048	12164	5
35808	8048	12165	7
35809	8048	12166	8
35810	8048	12167	4
35811	8048	12155	7
35812	8049	12168	7
35813	8049	12169	5
35814	8049	12148	10
35815	8049	12170	2
35816	8049	12171	9
35817	8050	12172	12
35818	8050	12173	9
35819	8050	12174	2
35820	8050	12175	3
35821	8050	12049	3
35822	8051	12176	5
35823	8051	12177	6
35824	8051	12178	7
35825	8051	12179	5
35826	8051	12171	1
35827	8052	12180	5
35828	8052	12146	4
35829	8052	12157	8
35830	8052	12181	2
35831	8052	12171	7
35832	8053	12182	9
35833	8053	12177	7
35834	8053	12183	8
35835	8053	12184	13
35836	8053	12185	9
35837	8054	12186	4
35838	8054	12139	6
35839	8054	12080	7
35840	8054	12187	8
35841	8054	12107	5
35842	8055	12188	3
35843	8055	12189	8
35844	8055	12051	6
35845	8055	12101	2
35846	8055	12160	10
35847	8056	12186	5
35848	8056	12190	10
35849	8056	12191	11
35850	8056	12192	8
35851	8056	12107	5
35852	8057	12193	6
35853	8057	12148	7
35854	8057	12194	2
35855	8057	12137	3
35856	8057	12171	6
35857	8058	12195	8
35858	8058	12196	3
35859	8058	12197	8
35860	8058	12198	5
35861	8058	12155	1
35862	8059	12199	2
35863	8059	12200	6
35864	8059	12159	4
35865	8059	12201	4
35866	8059	12185	6
35867	8060	12202	5
35868	8060	12203	8
35869	8060	12204	7
35870	8060	12170	2
35871	8060	12155	3
35872	8061	12205	8
35873	8061	12166	9
35874	8061	12206	5
35875	8061	12207	2
35876	8061	12107	4
35877	8062	12208	7
35878	8062	12209	11
35879	8062	12210	6
35880	8062	12057	6
35881	8062	12201	8
35882	8063	12211	8
35883	8063	12212	10
35884	8063	12177	3
35885	8063	12213	2
35886	8063	12214	6
35887	8063	12201	8
35888	8064	12215	2
35889	8064	12216	7
35890	8064	12217	5
35891	8064	12140	4
35892	8064	12160	3
35893	8065	12218	5
35894	8065	12196	3
35895	8065	12200	8
35896	8065	12219	6
35897	8065	12107	7
35898	8066	12220	4
35899	8066	12221	13
35900	8066	12217	4
35901	8066	12222	1
35902	8066	12150	2
35903	8067	12202	5
35904	8067	12223	9
35905	8067	12204	7
35906	8067	12170	2
35907	8067	12175	9
35908	8068	12224	4
35909	8068	12196	4
35910	8068	12162	9
35911	8068	12225	5
35912	8068	12155	1
35913	8069	12226	2
35914	8069	12227	6
35915	8069	12228	4
35916	8069	12057	6
35917	8069	12107	5
35918	8070	12229	3
35919	8070	12230	9
35920	8070	12231	4
35921	8070	12219	4
35922	8070	12175	6
35923	8071	12232	5
35924	8071	12190	9
35925	8071	12191	8
35926	8071	12233	7
35927	8071	12107	7
35928	8072	12234	4
35929	8072	12203	3
35930	8072	12080	8
35931	8072	12207	5
35932	8072	12160	3
35933	8073	12235	7
35934	8073	12148	6
35935	8073	12158	7
35936	8073	12236	12
35937	8073	12107	9
35938	8074	12237	3
35939	8074	12238	4
35940	8074	12239	11
35941	8074	12240	7
35942	8074	12171	8
35943	8075	12176	5
35944	8075	12148	7
35945	8075	12225	7
35946	8075	12241	5
35947	8075	12201	8
35948	8076	12143	3
35949	8076	12221	7
35950	8076	12242	11
35951	8076	12243	2
35952	8076	12155	4
35953	8077	12244	2
35954	8077	12245	8
35955	8077	12246	4
35956	8077	12247	5
35957	8077	12142	8
35958	8078	12248	8
35959	8079	12249	4
35960	8079	12250	6
35961	8080	12251	2
35962	8081	12252	2
35963	8082	12253	4
35964	8083	12254	3
35965	8083	12255	5
35966	8083	12256	9
35967	8084	12257	3
35968	8084	12258	6
35969	8085	12259	6
35970	8086	12260	8
35971	8087	12261	8
35972	8088	12262	1
35973	8089	12263	9
35974	8090	12264	11
35975	8090	12258	7
35976	8091	12265	6
35977	8091	12266	8
35978	8092	12267	9
35979	8093	12268	8
35980	8094	12269	4
35981	8094	12270	2
35982	8095	12271	9
35983	8096	12272	9
35984	8097	12273	8
35985	8098	12274	2
35986	8098	12275	1
35987	8099	12276	3
35988	8100	12277	6
35989	8101	12278	11
35990	8102	12279	9
35991	8102	12280	6
35992	8103	12281	9
35993	8104	12282	3
35994	8104	12270	3
35995	8105	12283	3
35996	8105	12284	4
35997	8106	12278	11
35998	8107	12267	5
35999	8108	12276	9
36000	8109	12285	6
36001	8109	12271	7
36002	8110	12286	1
36003	8111	12287	8
36004	8112	12288	4
36005	8113	12289	12
36006	8113	12290	9
36007	8113	12291	11
36008	8113	12292	11
36009	8113	12293	11
36010	8114	12294	7
36011	8115	12295	13
36012	8115	12296	4
36013	8115	12297	11
36014	8115	12298	9
36015	8115	12290	5
36016	8115	12299	5
36017	8115	12300	2
36018	8116	12301	6
36019	8116	12302	4
36020	8116	12300	12
36021	8117	12303	5
36022	8117	12304	5
36023	8117	12305	14
36024	8117	12290	5
36025	8117	12306	4
36026	8117	12307	4
36027	8117	12308	13
36028	8118	12309	11
36029	8118	12310	9
36030	8118	12299	11
36031	8118	12311	2
36032	8118	12312	12
36033	8119	12296	2
36034	8119	12313	4
36035	8119	12314	13
36036	8119	12315	11
36037	8119	12316	5
36038	8119	12317	8
36039	8120	12318	7
36040	8120	12319	13
36041	8120	12315	9
36042	8120	12290	8
36043	8120	12316	5
36044	8120	12320	6
36045	8121	12321	5
36046	8121	12322	2
36047	8121	12323	2
36048	8121	12324	2
36049	8121	12325	8
36050	8122	12326	6
36051	8122	12327	5
36052	8122	12304	13
36053	8122	12328	14
36054	8122	12329	9
36055	8122	12330	8
36056	8122	12308	10
36057	8123	12331	4
36058	8123	12332	13
36059	8123	12290	8
36060	8123	12291	9
36061	8123	12306	4
36062	8124	12333	3
36063	8124	12304	11
36064	8124	12334	14
36065	8124	12335	8
36066	8124	12315	9
36067	8124	12320	4
36068	8124	12312	7
36069	8124	12293	8
36070	8125	12309	9
36071	8125	12336	3
36072	8125	12306	5
36073	8125	12299	6
36074	8125	12307	5
36075	8125	12308	11
36076	8126	12337	7
36077	8126	12304	11
36078	8126	12328	14
36079	8126	12290	5
36080	8126	12338	5
36081	8126	12316	12
36082	8126	12339	11
36083	8127	12340	6
36084	8127	12341	11
36085	8127	12342	10
36086	8127	12304	8
36087	8127	12334	14
36088	8127	12343	4
36089	8128	12344	4
36090	8128	12342	6
36091	8128	12304	7
36092	8128	12345	14
36093	8128	12346	5
36094	8128	12347	4
36095	8129	12348	4
36096	8129	12304	2
36097	8129	12334	14
36098	8129	12349	9
36099	8129	12338	5
36100	8129	12316	7
36101	8129	12350	11
36102	8129	12308	9
36103	8130	12351	5
36104	8130	12303	6
36105	8130	12304	11
36106	8130	12334	14
36107	8130	12329	9
36108	8130	12330	9
36109	8130	12339	9
36110	8131	12341	13
36111	8131	12342	11
36112	8131	12352	10
36113	8131	12353	9
36114	8131	12354	9
36115	8132	12355	3
36116	8132	12338	4
36117	8132	12311	4
36118	8132	12356	7
36119	8132	12308	11
36120	8133	12357	11
36121	8133	12358	11
36122	8133	12359	2
36123	8133	12360	6
36124	8133	12292	12
36125	8134	12361	8
36126	8134	12329	6
36127	8134	12330	9
36128	8134	12311	4
36129	8134	12362	4
36130	8134	12308	11
36131	8135	12363	13
36132	8135	12304	11
36133	8135	12328	14
36134	8135	12290	8
36135	8135	12338	3
36136	8135	12316	5
36137	8135	12339	8
36138	8136	12342	10
36139	8136	12304	11
36140	8136	12345	14
36141	8136	12290	6
36142	8136	12291	6
36143	8136	12306	5
36144	8136	12339	11
36145	8137	12364	6
36146	8137	12365	8
36147	8137	12304	5
36148	8137	12334	14
36149	8137	12329	3
36150	8137	12291	4
36151	8138	12366	2
36152	8138	12367	5
36153	8138	12368	11
36154	8138	12369	8
36155	8138	12324	4
36156	8139	12370	5
36157	8139	12304	6
36158	8139	12305	14
36159	8139	12290	3
36160	8139	12353	2
36161	8139	12316	6
36162	8139	12339	8
36163	8140	12371	4
36164	8140	12372	4
36165	8140	12373	11
36166	8140	12374	9
36167	8140	12375	4
36168	8141	12376	4
36169	8141	12377	3
36170	8141	12378	9
36171	8141	12379	9
36172	8141	12375	8
36173	8142	12380	3
36174	8142	12381	7
36175	8142	12382	8
36176	8142	12324	2
36177	8143	12383	2
36178	8143	12384	9
36179	8143	12385	3
36180	8143	12386	11
36181	8144	12387	5
36182	8144	12388	5
36183	8144	12389	5
36184	8144	12390	5
36185	8144	12343	2
36186	8145	12391	2
36187	8145	12392	9
36188	8145	12385	7
36189	8145	12393	7
36190	8145	12394	7
36191	8146	12395	3
36192	8146	12396	2
36193	8146	12373	7
36194	8146	12397	7
36195	8146	12375	5
36196	8147	12398	1
36197	8147	12399	9
36198	8147	12400	7
36199	8147	12401	3
36200	8147	12394	5
36201	8148	12402	11
36202	8148	12403	8
36203	8148	12404	2
36204	8148	12405	6
36205	8149	12406	5
36206	8149	12407	9
36207	8149	12408	11
36208	8149	12393	9
36209	8150	12409	3
36210	8150	12410	9
36211	8150	12411	7
36212	8150	12412	3
36213	8150	12343	7
36214	8151	12396	3
36215	8151	12413	3
36216	8151	12373	7
36217	8151	12414	8
36218	8151	12415	13
36219	8152	12396	3
36220	8152	12416	3
36221	8152	12389	7
36222	8152	12417	1
36223	8152	12415	9
36224	8153	12418	4
36225	8153	12381	7
36226	8153	12419	7
36227	8153	12343	1
36228	8154	12420	8
36229	8154	12421	9
36230	8154	12422	7
36231	8154	12423	3
36232	8154	12375	6
36233	8155	12424	11
36234	8155	12425	9
36235	8155	12426	8
36236	8155	12427	7
36237	8155	12405	3
36238	8156	12428	2
36239	8156	12429	7
36240	8156	12430	11
36241	8156	12431	3
36242	8156	12324	5
36243	8157	12432	12
36244	8157	12373	8
36245	8157	12414	9
36246	8157	12415	6
36247	8158	12433	2
36248	8158	12434	1
36249	8158	12384	13
36250	8158	12435	7
36251	8158	12324	3
36252	8159	12436	1
36253	8159	12437	7
36254	8159	12400	6
36255	8159	12438	5
36256	8159	12394	7
36257	8160	12439	5
36258	8160	12440	5
36259	8160	12441	9
36260	8160	12382	9
36261	8160	12324	2
36262	8161	12442	7
36263	8161	12443	9
36264	8161	12403	5
36265	8161	12405	9
36266	8162	12388	5
36267	8162	12444	9
36268	8162	12445	1
36269	8162	12446	5
36270	8162	12359	4
36271	8163	12447	2
36272	8163	12448	3
36273	8163	12449	3
36274	8163	12359	2
36275	8163	12329	4
36276	8164	12450	2
36277	8164	12451	5
36278	8164	12452	5
36279	8164	12343	4
36280	8164	12453	3
36281	8165	12454	3
36282	8165	12455	3
36283	8165	12456	8
36284	8165	12403	7
36285	8165	12394	9
36286	8166	12455	4
36287	8166	12457	9
36288	8166	12385	7
36289	8166	12458	8
36290	8166	12405	7
36291	8167	12459	4
36292	8167	12460	8
36293	8167	12461	9
36294	8167	12405	5
36295	8168	12388	11
36296	8168	12425	11
36297	8168	12462	12
36298	8168	12405	12
36299	8168	12329	11
36300	8169	12463	3
36301	8169	12451	7
36302	8169	12397	9
36303	8169	12464	5
36304	8169	12359	3
36305	8170	12465	4
36306	8170	12384	9
36307	8170	12385	5
36308	8170	12346	3
36309	8171	12466	3
36310	8171	12399	9
36311	8171	12467	6
36312	8171	12343	7
36313	8172	12468	2
36314	8172	12465	4
36315	8172	12384	8
36316	8172	12385	6
36317	8172	12346	4
36318	8173	12469	4
36319	8173	12456	9
36320	8173	12400	6
36321	8173	12464	2
36322	8173	12324	6
36323	8174	12454	3
36324	8174	12437	9
36325	8174	12385	9
36326	8174	12470	4
36327	8174	12394	8
36328	8175	12471	3
36329	8175	12472	9
36330	8175	12403	7
36331	8175	12473	1
36332	8175	12343	5
36333	8175	12329	6
36334	8176	12436	1
36335	8176	12437	9
36336	8176	12400	6
36337	8176	12438	6
36338	8176	12394	8
36339	8177	12474	6
36340	8177	12388	8
36341	8177	12475	7
36342	8177	12476	5
36343	8177	12359	2
36344	8178	12477	5
36345	8178	12478	11
36346	8178	12479	8
36347	8178	12480	4
36348	8178	12394	9
36349	8179	12396	2
36350	8179	12481	2
36351	8179	12482	6
36352	8179	12444	7
36353	8179	12324	3
36354	8180	12483	4
36355	8180	12484	4
36356	8180	12341	11
36357	8180	12485	8
36358	8180	12359	6
36359	8181	12486	7
36360	8181	12487	10
36361	8181	12435	8
36362	8181	12488	7
36363	8181	12343	7
36364	8182	12489	3
36365	8182	12456	13
36366	8182	12444	9
36367	8182	12431	3
36368	8182	12343	8
36369	8183	12490	4
36370	8183	12491	3
36371	8183	12478	7
36372	8183	12492	9
36373	8183	12426	8
36374	8183	12343	8
36375	8184	12493	7
36376	8184	12494	9
36377	8184	12495	12
36378	8184	12343	7
36379	8184	12496	4
36380	8185	12407	9
36381	8185	12403	9
36382	8185	12497	5
36383	8185	12324	9
36384	8186	12498	5
36385	8186	12499	1
36386	8186	12426	4
36387	8186	12500	7
36388	8186	12501	1
36389	8187	12502	5
36390	8187	12499	2
36391	8187	12503	3
36392	8187	12458	6
36393	8187	12501	3
36394	8188	12504	4
36395	8188	12505	8
36396	8188	12506	6
36397	8188	12507	1
36398	8188	12508	3
36399	8189	12509	5
36400	8189	12510	7
36401	8189	12511	5
36402	8189	12476	3
36403	8189	12512	9
36404	8190	12513	5
36405	8190	12514	4
36406	8190	12515	1
36407	8190	12516	1
36408	8190	12517	4
36409	8191	12518	4
36410	8191	12519	6
36411	8191	12520	7
36412	8191	12521	2
36413	8191	12512	3
36414	8192	12522	6
36415	8192	12523	8
36416	8192	12520	6
36417	8192	12524	3
36418	8192	12525	11
36419	8193	12364	5
36420	8193	12526	5
36421	8193	12527	5
36422	8193	12528	8
36423	8193	12512	8
36424	8194	12529	3
36425	8194	12530	6
36426	8194	12531	2
36427	8194	12532	1
36428	8194	12533	8
36429	8195	12504	3
36430	8195	12505	4
36431	8195	12506	4
36432	8195	12507	1
36433	8195	12508	2
36434	8196	12364	4
36435	8196	12534	2
36436	8196	12510	8
36437	8196	12535	1
36438	8196	12512	1
36439	8197	12536	3
36440	8197	12537	6
36441	8197	12514	8
36442	8197	12538	1
36443	8197	12517	7
36444	8198	12504	3
36445	8198	12505	5
36446	8198	12506	11
36447	8198	12507	6
36448	8198	12508	8
36449	8199	12522	5
36450	8199	12523	7
36451	8199	12520	7
36452	8199	12524	2
36453	8199	12525	7
36454	8200	12504	3
36455	8200	12505	6
36456	8200	12506	6
36457	8200	12507	1
36458	8200	12508	1
36459	8201	12522	5
36460	8201	12523	1
36461	8201	12520	4
36462	8201	12524	3
36463	8201	12525	1
36464	8202	12529	4
36465	8202	12530	3
36466	8202	12531	3
36467	8202	12532	3
36468	8202	12533	1
36469	8203	12539	4
36470	8203	12514	11
36471	8203	12515	6
36472	8203	12540	5
36473	8203	12517	8
36474	8204	12541	2
36475	8204	12542	5
36476	8204	12514	7
36477	8204	12517	5
36478	8204	12543	3
36479	8205	12471	1
36480	8205	12544	5
36481	8205	12545	1
36482	8205	12546	8
36483	8205	12346	4
36484	8206	12547	5
36485	8206	12548	6
36486	8206	12520	6
36487	8206	12549	2
36488	8206	12346	4
36489	8207	12550	6
36490	8207	12551	1
36491	8207	12552	2
36492	8207	12346	3
36493	8207	12553	3
36494	8208	12522	6
36495	8208	12523	8
36496	8208	12520	7
36497	8208	12524	3
36498	8208	12525	11
36499	8209	12522	6
36500	8209	12523	5
36501	8209	12520	7
36502	8209	12524	5
36503	8209	12525	7
36504	8210	12554	3
36505	8210	12499	2
36506	8210	12503	2
36507	8210	12555	5
36508	8210	12501	3
36509	8211	12529	4
36510	8211	12530	4
36511	8211	12531	1
36512	8211	12532	1
36513	8211	12533	7
36514	8212	12529	3
36515	8212	12530	5
36516	8212	12531	3
36517	8212	12532	2
36518	8212	12533	4
36519	8213	12556	7
36520	8213	12557	8
36521	8213	12511	4
36522	8213	12558	4
36523	8213	12512	8
36524	8214	12559	4
36525	8214	12499	3
36526	8214	12552	3
36527	8214	12560	8
36528	8214	12501	5
36529	8215	12522	5
36530	8215	12523	8
36531	8215	12520	4
36532	8215	12524	4
36533	8215	12525	9
36534	8216	12561	3
36535	8216	12542	5
36536	8216	12514	11
36537	8216	12562	6
36538	8216	12517	8
36539	8217	12563	5
36540	8217	12514	4
36541	8217	12426	7
36542	8217	12564	1
36543	8217	12517	4
36544	8218	12498	5
36545	8218	12499	1
36546	8218	12393	4
36547	8218	12565	1
36548	8218	12501	2
36549	8219	12566	5
36550	8219	12514	5
36551	8219	12515	2
36552	8219	12546	6
36553	8219	12517	5
36554	8220	12498	4
36555	8220	12499	4
36556	8220	12567	2
36557	8220	12568	2
36558	8220	12501	3
36559	8221	12569	3
36560	8221	12499	6
36561	8221	12545	7
36562	8221	12570	1
36563	8221	12501	3
36564	8222	12571	4
36565	8222	12514	11
36566	8222	12567	2
36567	8222	12572	5
36568	8222	12517	5
36569	8223	12573	6
36570	8223	12534	6
36571	8223	12574	9
36572	8223	12575	5
36573	8223	12512	9
36574	8224	12522	6
36575	8224	12523	8
36576	8224	12520	6
36577	8224	12524	5
36578	8224	12525	2
36579	8225	12522	6
36580	8225	12523	6
36581	8225	12520	4
36582	8225	12524	7
36583	8225	12525	1
36584	8226	12513	5
36585	8226	12514	7
36586	8226	12393	7
36587	8226	12562	5
36588	8226	12517	4
36589	8227	12556	7
36590	8227	12576	1
36591	8227	12527	4
36592	8227	12577	3
36593	8227	12517	5
36594	8228	12504	3
36595	8228	12505	4
36596	8228	12506	5
36597	8228	12507	1
36598	8228	12508	1
36599	8229	12522	5
36600	8229	12523	8
36601	8229	12520	8
36602	8229	12524	6
36603	8229	12525	5
36604	8230	12578	3
36605	8230	12579	3
36606	8230	12499	4
36607	8230	12545	2
36608	8230	12501	2
36609	8231	12529	4
36610	8231	12530	6
36611	8231	12531	3
36612	8231	12532	1
36613	8231	12533	1
36614	8232	12580	5
36615	8232	12581	7
36616	8232	12531	1
36617	8232	12582	5
36618	8232	12512	9
36619	8233	12504	4
36620	8233	12505	5
36621	8233	12506	2
36622	8233	12507	2
36623	8233	12508	3
36624	8234	12529	2
36625	8234	12530	4
36626	8234	12531	1
36627	8234	12532	1
36628	8234	12533	1
36629	8235	12509	5
36630	8235	12534	4
36631	8235	12510	9
36632	8235	12583	6
36633	8235	12512	5
36634	8236	12584	3
36635	8236	12534	7
36636	8236	12585	8
36637	8236	12464	2
36638	8236	12512	7
36639	8237	12504	2
36640	8237	12505	4
36641	8237	12506	5
36642	8237	12507	1
36643	8237	12508	1
36644	8238	12504	4
36645	8238	12505	5
36646	8238	12506	9
36647	8238	12507	2
36648	8238	12508	2
36649	8239	12504	3
36650	8239	12505	5
36651	8239	12506	6
36652	8239	12507	2
36653	8239	12508	3
36654	8240	12586	3
36655	8240	12499	2
36656	8240	12552	5
36657	8240	12587	1
36658	8240	12501	3
36659	8241	12522	7
36660	8241	12523	6
36661	8241	12520	7
36662	8241	12524	6
36663	8241	12525	6
36664	8242	12561	9
36665	8242	12514	6
36666	8242	12426	3
36667	8242	12560	9
36668	8242	12517	1
36669	8243	12550	5
36670	8243	12576	1
36671	8243	12520	1
36672	8243	12560	1
36673	8243	12517	1
36674	8244	12588	4
36675	8244	12514	1
36676	8244	12497	2
36677	8244	12589	1
36678	8244	12517	3
36679	8245	12541	3
36680	8245	12514	1
36681	8245	12515	4
36682	8245	12589	2
36683	8245	12517	1
36684	8246	12559	4
36685	8246	12590	4
36686	8246	12514	6
36687	8246	12497	3
36688	8246	12517	1
36689	8247	12588	4
36690	8247	12591	5
36691	8247	12499	4
36692	8247	12592	4
36693	8247	12501	5
36694	8248	12593	4
36695	8248	12544	9
36696	8248	12497	4
36697	8248	12594	5
36698	8248	12512	1
36699	8249	12595	5
36700	8249	12499	1
36701	8249	12426	2
36702	8249	12596	2
36703	8249	12501	3
36704	8250	12326	5
36705	8250	12597	6
36706	8250	12426	6
36707	8250	12598	5
36708	8250	12512	8
36709	8251	12529	3
36710	8251	12530	3
36711	8251	12531	1
36712	8251	12532	1
36713	8251	12533	1
36714	8252	12522	6
36715	8252	12523	6
36716	8252	12520	5
36717	8252	12524	3
36718	8252	12525	6
36719	8253	12599	8
36720	8253	12514	5
36721	8253	12515	2
36722	8253	12560	10
36723	8253	12517	6
36724	8254	12522	6
36725	8254	12523	9
36726	8254	12520	7
36727	8254	12524	2
36728	8254	12525	7
36729	8255	12522	6
36730	8255	12523	11
36731	8255	12520	8
36732	8255	12524	6
36733	8255	12525	7
36734	8256	12600	5
36735	8256	12505	3
36736	8256	12601	2
36737	8256	12602	1
36738	8256	12512	1
36739	8257	12504	3
36740	8257	12505	7
36741	8257	12506	9
36742	8257	12507	1
36743	8257	12508	4
36744	8258	12550	5
36745	8258	12499	3
36746	8258	12603	2
36747	8258	12501	4
36748	8258	12604	3
36749	8259	12605	3
36750	8259	12505	6
36751	8259	12506	3
36752	8259	12507	2
36753	8259	12508	2
36754	8260	12504	5
36755	8260	12505	4
36756	8260	12506	2
36757	8260	12507	1
36758	8260	12508	1
36759	8261	12504	4
36760	8261	12505	6
36761	8261	12506	8
36762	8261	12507	2
36763	8261	12508	4
36764	8262	12504	4
36765	8262	12505	7
36766	8262	12506	8
36767	8262	12507	2
36768	8262	12508	5
36769	8263	12561	5
36770	8263	12514	6
36771	8263	12531	1
36772	8263	12606	1
36773	8263	12517	5
36774	8264	12529	3
36775	8264	12530	9
36776	8264	12531	2
36777	8264	12532	1
36778	8264	12533	5
36779	8265	12579	6
36780	8265	12514	6
36781	8265	12607	6
36782	8265	12517	6
36783	8265	12356	8
36784	8266	12529	4
36785	8266	12530	6
36786	8266	12531	2
36787	8266	12532	2
36788	8266	12533	8
36789	8267	12504	5
36790	8267	12505	8
36791	8267	12506	8
36792	8267	12507	4
36793	8267	12508	1
36794	8268	12504	4
36795	8268	12505	8
36796	8268	12506	9
36797	8268	12507	3
36798	8268	12508	8
36799	8269	12529	3
36800	8269	12530	7
36801	8269	12531	3
36802	8269	12532	1
36803	8269	12533	3
36804	8270	12522	6
36805	8270	12523	7
36806	8270	12520	6
36807	8270	12524	3
36808	8270	12525	2
36809	8271	12509	4
36810	8271	12608	11
36811	8271	12520	6
36812	8271	12577	4
36813	8271	12512	1
36814	8272	12522	4
36815	8272	12523	9
36816	8272	12520	7
36817	8272	12524	6
36818	8272	12525	4
36819	8273	12529	5
36820	8273	12530	9
36821	8273	12531	4
36822	8273	12532	1
36823	8273	12533	9
36824	8274	12609	4
36825	8274	12610	5
36826	8274	12514	6
36827	8274	12611	1
36828	8274	12517	4
36829	8275	12536	4
36830	8275	12514	8
36831	8275	12531	3
36832	8275	12612	9
36833	8275	12517	6
36834	8276	12529	3
36835	8276	12530	9
36836	8276	12531	1
36837	8276	12532	3
36838	8276	12533	4
36839	8277	12504	3
36840	8277	12505	6
36841	8277	12506	7
36842	8277	12507	4
36843	8277	12508	5
36844	8278	12522	7
36845	8278	12523	9
36846	8278	12520	7
36847	8278	12524	6
36848	8278	12525	10
36849	8279	12613	5
36850	8279	12519	4
36851	8279	12558	2
36852	8279	12375	4
36853	8279	12362	2
36854	8280	12371	3
36855	8280	12367	6
36856	8280	12614	7
36857	8280	12375	5
36858	8280	12356	6
36859	8281	12395	1
36860	8281	12597	5
36861	8281	12527	5
36862	8281	12311	2
36863	8281	12375	1
36864	8282	12615	11
36865	8282	12616	10
36866	8282	12617	7
36867	8282	12618	11
36868	8282	12619	9
36869	8282	12620	1
36870	8283	12621	6
36871	8283	12622	4
36872	8283	12623	3
36873	8283	12624	2
36874	8283	12625	3
36875	8283	12626	14
36876	8283	12627	1
36877	8283	12628	11
36878	8284	12629	6
36879	8284	12625	3
36880	8284	12626	14
36881	8284	12617	5
36882	8284	12630	4
36883	8284	12618	2
36884	8284	12631	4
36885	8285	12632	4
36886	8285	12633	3
36887	8285	12625	4
36888	8285	12634	14
36889	8285	12635	9
36890	8286	12636	3
36891	8286	12637	5
36892	8286	12638	2
36893	8286	12639	7
36894	8286	12640	10
36895	8287	12641	7
36896	8287	12627	5
36897	8287	12642	7
36898	8287	12639	7
36899	8287	12643	9
36900	8288	12644	13
36901	8288	12645	4
36902	8288	12646	4
36903	8288	12647	7
36904	8288	12648	9
36905	8288	12649	3
36906	8289	12650	2
36907	8289	12651	7
36908	8289	12642	13
36909	8289	12652	7
36910	8289	12653	3
36911	8290	12654	8
36912	8290	12625	3
36913	8290	12626	14
36914	8290	12651	7
36915	8290	12630	1
36916	8290	12618	1
36917	8290	12631	7
36918	8291	12655	13
36919	8291	12656	8
36920	8291	12657	5
36921	8291	12642	13
36922	8291	12658	5
36923	8291	12659	2
36924	8291	12660	12
36925	8292	12661	9
36926	8292	12625	11
36927	8292	12662	14
36928	8292	12627	5
36929	8292	12639	8
36930	8293	12663	10
36931	8293	12664	6
36932	8293	12651	6
36933	8293	12627	6
36934	8293	12659	2
36935	8293	12630	7
36936	8293	12643	13
36937	8294	12665	7
36938	8294	12666	7
36939	8294	12625	4
36940	8294	12626	14
36941	8294	12617	6
36942	8294	12648	9
36943	8294	12667	8
36944	8295	12668	3
36945	8295	12669	4
36946	8295	12670	3
36947	8295	12625	11
36948	8295	12662	14
36949	8295	12646	7
36950	8295	12671	9
36951	8296	12672	4
36952	8296	12625	5
36953	8296	12634	14
36954	8296	12617	6
36955	8296	12673	4
36956	8296	12674	3
36957	8296	12647	4
36958	8297	12675	9
36959	8297	12676	5
36960	8297	12646	7
36961	8297	12677	7
36962	8297	12642	4
36963	8297	12678	4
36964	8298	12679	12
36965	8298	12680	11
36966	8298	12681	8
36967	8298	12682	9
36968	8298	12683	12
36969	8298	12667	5
36970	8299	12684	2
36971	8299	12685	2
36972	8299	12643	9
36973	8299	12686	6
36974	8299	12687	4
36975	8299	12688	2
36976	8300	12689	7
36977	8300	12690	11
36978	8300	12642	13
36979	8300	12674	13
36980	8300	12683	13
36981	8301	12691	1
36982	8301	12692	2
36983	8301	12693	5
36984	8301	12643	8
36985	8301	12687	3
36986	8302	12654	13
36987	8302	12694	4
36988	8302	12617	5
36989	8302	12695	5
36990	8302	12673	2
36991	8302	12674	7
36992	8303	12696	9
36993	8303	12697	7
36994	8303	12627	3
36995	8303	12630	4
36996	8303	12652	8
36997	8303	12631	7
36998	8304	12698	4
36999	8304	12646	3
37000	8304	12677	9
37001	8304	12642	6
37002	8305	12699	6
37003	8305	12700	9
37004	8305	12701	5
37005	8305	12645	7
37006	8305	12686	11
37007	8306	12702	8
37008	8306	12625	5
37009	8306	12703	14
37010	8306	12677	7
37011	8306	12630	5
37012	8306	12652	6
37013	8306	12704	8
37014	8307	12705	8
37015	8307	12706	7
37016	8307	12681	7
37017	8307	12707	9
37018	8307	12708	9
37019	8308	12709	11
37020	8308	12710	9
37021	8308	12711	3
37022	8308	12712	2
37023	8308	12671	9
37024	8309	12713	8
37025	8309	12714	6
37026	8309	12629	11
37027	8309	12645	8
37028	8309	12715	11
37029	8310	12716	3
37030	8310	12713	9
37031	8310	12717	6
37032	8310	12718	7
37033	8310	12719	3
37034	8310	12720	1
37035	8311	12721	4
37036	8311	12665	8
37037	8311	12722	3
37038	8311	12723	4
37039	8311	12686	5
37040	8311	12678	6
37041	8312	12724	3
37042	8312	12725	8
37043	8312	12726	11
37044	8312	12727	9
37045	8312	12686	7
37046	8312	12715	3
37047	8313	12728	9
37048	8313	12729	9
37049	8313	12730	6
37050	8313	12731	5
37051	8313	12678	11
37052	8314	12700	10
37053	8314	12732	11
37054	8314	12717	8
37055	8314	12733	4
37056	8314	12734	4
37057	8314	12735	11
37058	8315	12736	5
37059	8315	12710	7
37060	8315	12737	5
37061	8315	12735	9
37062	8315	12715	11
37063	8316	12738	10
37064	8316	12739	5
37065	8316	12645	8
37066	8316	12648	11
37067	8316	12667	8
37068	8317	12740	5
37069	8317	12741	11
37070	8317	12722	8
37071	8317	12648	7
37072	8317	12667	6
37073	8318	12728	9
37074	8318	12742	4
37075	8318	12743	2
37076	8318	12731	5
37077	8318	12678	9
37078	8319	12744	8
37079	8319	12745	6
37080	8319	12746	7
37081	8319	12645	5
37082	8319	12747	7
37083	8319	12678	8
37084	8320	12748	8
37085	8320	12749	9
37086	8320	12750	7
37087	8320	12751	7
37088	8320	12648	1
37089	8320	12678	4
37090	8321	12752	5
37091	8321	12753	3
37092	8321	12754	6
37093	8321	12729	8
37094	8321	12755	8
37095	8321	12715	8
37096	8322	12756	13
37097	8322	12757	9
37098	8322	12722	11
37099	8322	12648	7
37100	8322	12667	8
37101	8323	12758	7
37102	8323	12759	9
37103	8323	12700	9
37104	8323	12760	13
37105	8323	12761	8
37106	8323	12762	10
37107	8324	12763	3
37108	8324	12764	8
37109	8324	12765	8
37110	8324	12645	6
37111	8324	12686	7
37112	8324	12678	7
37113	8325	12766	7
37114	8325	12767	9
37115	8325	12645	7
37116	8325	12747	6
37117	8325	12678	11
37118	8326	12768	4
37119	8326	12769	9
37120	8326	12729	10
37121	8326	12770	5
37122	8326	12686	8
37123	8326	12667	6
37124	8327	12771	9
37125	8327	12772	11
37126	8327	12773	6
37127	8327	12653	4
37128	8328	12700	9
37129	8328	12774	11
37130	8328	12722	9
37131	8328	12775	4
37132	8328	12645	9
37133	8328	12686	7
37134	8329	12776	6
37135	8329	12728	10
37136	8329	12777	5
37137	8329	12770	6
37138	8329	12648	9
37139	8330	12700	10
37140	8330	12754	6
37141	8330	12710	11
37142	8330	12696	6
37143	8330	12767	10
37144	8330	12747	8
37145	8331	12778	8
37146	8331	12701	2
37147	8331	12779	4
37148	8331	12780	6
37149	8331	12667	5
37150	8332	12781	2
37151	8332	12782	4
37152	8332	12783	9
37153	8332	12784	7
37154	8333	12785	3
37155	8333	12786	9
37156	8333	12787	1
37157	8333	12735	11
37158	8333	12715	11
37159	8334	12788	5
37160	8334	12713	13
37161	8334	12714	8
37162	8334	12789	3
37163	8334	12747	9
37164	8334	12715	11
37165	8335	12700	9
37166	8335	12790	9
37167	8335	12791	8
37168	8335	12792	6
37169	8335	12735	11
37170	8336	12793	3
37171	8336	12794	5
37172	8336	12766	9
37173	8336	12795	9
37174	8336	12747	11
37175	8336	12715	11
37176	8337	12796	6
37177	8337	12757	9
37178	8337	12797	6
37179	8337	12696	11
37180	8337	12747	9
37181	8338	12798	2
37182	8338	12799	4
37183	8338	12726	13
37184	8338	12800	9
37185	8338	12648	9
37186	8338	12667	6
37187	8339	12786	8
37188	8339	12727	6
37189	8339	12718	4
37190	8339	12801	2
37191	8339	12708	7
37192	8339	12678	6
37193	8340	12802	5
37194	8340	12803	10
37195	8340	12804	11
37196	8340	12805	7
37197	8340	12686	9
37198	8340	12667	7
37199	8341	12806	3
37200	8341	12807	7
37201	8341	12805	5
37202	8341	12731	4
37203	8341	12678	8
37204	8342	12769	9
37205	8342	12805	9
37206	8342	12808	3
37207	8342	12645	8
37208	8342	12747	9
37209	8342	12678	11
37210	8343	12809	4
37211	8343	12774	9
37212	8343	12751	7
37213	8343	12666	6
37214	8343	12747	9
37215	8343	12715	11
37216	8344	12810	8
37217	8344	12642	3
37218	8344	12647	9
37219	8344	12652	9
37220	8344	12649	2
37221	8344	12715	11
37222	8345	12811	6
37223	8345	12812	6
37224	8345	12813	9
37225	8345	12814	4
37226	8345	12735	6
37227	8345	12667	6
37228	8346	12815	5
37229	8346	12816	9
37230	8346	12810	8
37231	8346	12817	4
37232	8346	12686	8
37233	8346	12715	11
37234	8347	12812	6
37235	8347	12710	11
37236	8347	12818	10
37237	8347	12814	4
37238	8347	12747	11
37239	8347	12667	6
37240	8348	12819	4
37241	8348	12820	3
37242	8348	12680	8
37243	8348	12821	7
37244	8348	12784	5
37245	8348	12715	7
37246	8349	12766	2
37247	8349	12690	4
37248	8349	12645	1
37249	8349	12686	2
37250	8349	12822	3
37251	8350	12823	6
37252	8350	12665	7
37253	8350	12730	8
37254	8350	12824	11
37255	8350	12648	11
37256	8350	12667	14
37257	8351	12777	8
37258	8351	12825	1
37259	8351	12826	3
37260	8351	12747	7
37261	8351	12667	7
37262	8352	12827	6
37263	8352	12828	4
37264	8352	12738	6
37265	8352	12829	5
37266	8352	12830	7
37267	8352	12831	5
37268	8353	12832	9
37269	8353	12833	7
37270	8353	12834	7
37271	8353	12735	9
37272	8353	12678	8
37273	8354	12758	9
37274	8354	12774	4
37275	8354	12751	11
37276	8354	12735	9
37277	8354	12715	8
37278	8355	12835	2
37279	8355	12758	2
37280	8355	12681	6
37281	8355	12747	11
37282	8355	12667	6
37283	8356	12836	4
37284	8356	12837	4
37285	8356	12838	5
37286	8356	12839	1
37287	8356	12840	1
37288	8357	12841	3
37289	8357	12842	5
37290	8357	12666	8
37291	8357	12843	1
37292	8357	12844	7
37293	8358	12845	3
37294	8358	12846	5
37295	8358	12847	7
37296	8358	12848	1
37297	8358	12731	6
37298	8359	12849	6
37299	8359	12850	7
37300	8359	12851	4
37301	8359	12671	8
37302	8359	12822	4
37303	8360	12672	4
37304	8360	12852	9
37305	8360	12853	5
37306	8360	12854	1
37307	8360	12671	12
37308	8361	12836	5
37309	8361	12855	4
37310	8361	12856	3
37311	8361	12842	7
37312	8361	12857	4
37313	8361	12671	3
37314	8362	12858	4
37315	8362	12850	5
37316	8362	12859	3
37317	8362	12860	4
37318	8362	12861	6
37319	8363	12862	6
37320	8363	12863	5
37321	8363	12850	8
37322	8363	12808	2
37323	8363	12671	7
37324	8364	12864	3
37325	8364	12852	9
37326	8364	12865	6
37327	8364	12866	2
37328	8364	12755	7
37329	8365	12867	3
37330	8365	12802	3
37331	8365	12847	5
37332	8365	12848	1
37333	8365	12840	2
37334	8366	12868	3
37335	8366	12869	3
37336	8366	12842	9
37337	8366	12870	3
37338	8366	12671	2
37339	8367	12622	2
37340	8367	12871	9
37341	8367	12666	5
37342	8367	12872	4
37343	8367	12755	5
37344	8368	12873	7
37345	8368	12874	4
37346	8368	12875	8
37347	8368	12801	3
37348	8368	12840	13
37349	8369	12858	3
37350	8369	12876	7
37351	8369	12859	4
37352	8369	12877	1
37353	8369	12720	4
37354	8370	12878	4
37355	8370	12847	7
37356	8370	12879	6
37357	8370	12848	1
37358	8370	12840	3
37359	8371	12880	2
37360	8371	12881	4
37361	8371	12876	4
37362	8371	12854	1
37363	8371	12720	2
37364	8372	12823	1
37365	8372	12882	7
37366	8372	12696	7
37367	8372	12826	3
37368	8372	12755	1
37369	8373	12883	4
37370	8373	12884	8
37371	8373	12865	11
37372	8373	12885	4
37373	8373	12844	8
37374	8374	12835	2
37375	8374	12886	3
37376	8374	12887	11
37377	8374	12888	1
37378	8374	12889	2
37379	8374	12731	6
37380	8375	12890	3
37381	8375	12891	4
37382	8375	12629	4
37383	8375	12892	2
37384	8375	12844	6
37385	8376	12893	3
37386	8376	12894	6
37387	8376	12895	9
37388	8376	12896	1
37389	8376	12720	1
37390	8377	12864	2
37391	8377	12897	2
37392	8377	12842	5
37393	8377	12840	1
37394	8377	12898	2
37395	8378	12899	5
37396	8378	12828	7
37397	8378	12900	9
37398	8378	12901	3
37399	8378	12861	2
37400	8379	12902	3
37401	8379	12881	6
37402	8379	12903	8
37403	8379	12839	3
37404	8379	12708	5
37405	8380	12904	4
37406	8380	12905	3
37407	8380	12865	6
37408	8380	12906	5
37409	8380	12731	3
37410	8381	12907	4
37411	8381	12908	3
37412	8381	12783	7
37413	8381	12866	2
37414	8381	12755	11
37415	8382	12908	3
37416	8382	12909	4
37417	8382	12865	5
37418	8382	12696	7
37419	8382	12755	4
37420	8383	12910	5
37421	8383	12856	6
37422	8383	12903	8
37423	8383	12911	2
37424	8383	12755	7
37425	8384	12858	3
37426	8384	12912	7
37427	8384	12842	9
37428	8384	12885	2
37429	8384	12844	3
37430	8385	12858	3
37431	8385	12876	6
37432	8385	12859	4
37433	8385	12872	4
37434	8385	12720	3
37435	8386	12835	2
37436	8386	12913	3
37437	8386	12914	9
37438	8386	12915	4
37439	8386	12731	8
37440	8387	12916	3
37441	8387	12771	9
37442	8387	12917	4
37443	8387	12826	4
37444	8387	12755	9
37445	8388	12876	6
37446	8388	12918	4
37447	8388	12919	2
37448	8388	12839	6
37449	8388	12755	3
37450	8389	12744	4
37451	8389	12852	8
37452	8389	12879	3
37453	8389	12920	3
37454	8389	12840	1
37455	8390	12921	3
37456	8390	12838	6
37457	8390	12919	1
37458	8390	12922	4
37459	8390	12844	4
37460	8391	12923	12
37461	8391	12838	10
37462	8391	12879	8
37463	8391	12924	6
37464	8391	12844	8
37465	8392	12897	4
37466	8392	12884	7
37467	8392	12925	1
37468	8392	12926	3
37469	8392	12844	7
37470	8393	12858	4
37471	8393	12927	9
37472	8393	12928	2
37473	8393	12854	1
37474	8393	12671	8
37475	8394	12902	4
37476	8394	12881	6
37477	8394	12903	9
37478	8394	12839	1
37479	8394	12708	2
37480	8395	12858	3
37481	8395	12746	8
37482	8395	12859	3
37483	8395	12877	1
37484	8395	12720	1
37485	8396	12672	3
37486	8396	12929	4
37487	8396	12852	10
37488	8396	12930	4
37489	8396	12671	5
37490	8397	12827	5
37491	8397	12909	3
37492	8397	12629	3
37493	8397	12931	4
37494	8397	12720	3
37495	8398	12867	3
37496	8398	12847	9
37497	8398	12879	3
37498	8398	12848	1
37499	8398	12840	2
37500	8399	12902	3
37501	8399	12832	6
37502	8399	12876	8
37503	8399	12814	4
37504	8399	12708	5
37505	8400	12932	4
37506	8400	12933	7
37507	8400	12934	9
37508	8400	12935	4
37509	8400	12755	4
37510	8401	12936	4
37511	8401	12852	8
37512	8401	12696	6
37513	8401	12839	1
37514	8401	12755	1
37515	8402	12852	9
37516	8402	12919	3
37517	8402	12931	2
37518	8402	12848	4
37519	8402	12671	6
37520	8403	12855	3
37521	8403	12847	8
37522	8403	12937	1
37523	8403	12694	3
37524	8403	12840	8
37525	8404	12753	2
37526	8404	12783	6
37527	8404	12938	1
37528	8404	12931	9
37529	8404	12708	1
37530	8405	12862	6
37531	8405	12699	2
37532	8405	12850	8
37533	8405	12879	6
37534	8405	12939	3
37535	8405	12671	5
37536	8406	12862	5
37537	8406	12850	7
37538	8406	12879	9
37539	8406	12851	6
37540	8406	12671	8
37541	8407	12940	2
37542	8407	12927	5
37543	8407	12854	1
37544	8407	12844	1
37545	8407	12941	6
37546	8408	12867	4
37547	8408	12847	11
37548	8408	12879	8
37549	8408	12892	1
37550	8408	12840	7
37551	8409	12878	3
37552	8409	12802	2
37553	8409	12847	11
37554	8409	12848	1
37555	8409	12840	4
37556	8410	12942	1
37557	8410	12912	3
37558	8410	12943	9
37559	8410	12930	1
37560	8410	12844	7
37561	8411	12942	4
37562	8411	12912	4
37563	8411	12943	8
37564	8411	12944	3
37565	8411	12840	9
37566	8412	12945	2
37567	8412	12820	9
37568	8412	12903	8
37569	8412	12896	2
37570	8412	12671	5
37571	8413	12946	3
37572	8413	12842	2
37573	8413	12708	1
37574	8413	12941	4
37575	8413	12688	1
37576	8414	12936	2
37577	8414	12897	3
37578	8414	12852	4
37579	8414	12947	1
37580	8414	12844	1
37581	8415	12948	5
37582	8415	12852	2
37583	8415	12949	9
37584	8415	12840	1
37585	8415	12649	1
37586	8416	12950	4
37587	8416	12951	7
37588	8416	12820	8
37589	8416	12852	9
37590	8416	12844	5
37591	8417	12921	3
37592	8417	12943	9
37593	8417	12730	6
37594	8417	12924	4
37595	8417	12844	6
37596	8418	12952	5
37597	8418	12764	5
37598	8418	12842	7
37599	8418	12839	2
37600	8418	12671	2
37601	8419	12913	3
37602	8419	12953	2
37603	8419	12954	4
37604	8419	12955	2
37605	8419	12844	2
37606	8420	12956	5
37607	8420	12850	7
37608	8420	12730	6
37609	8420	12872	7
37610	8420	12671	12
37611	8421	12957	5
37612	8421	12783	4
37613	8421	12696	6
37614	8421	12839	1
37615	8421	12755	1
37616	8422	12858	4
37617	8422	12876	6
37618	8422	12859	3
37619	8422	12877	1
37620	8422	12720	5
37621	8423	12958	4
37622	8423	12852	8
37623	8423	12889	2
37624	8423	12814	1
37625	8423	12844	7
37626	8424	12959	3
37627	8424	12858	3
37628	8424	12876	7
37629	8424	12877	1
37630	8424	12720	3
37631	8425	12902	5
37632	8425	12881	6
37633	8425	12960	9
37634	8425	12839	1
37635	8425	12708	6
37636	8426	12869	4
37637	8426	12842	2
37638	8426	12666	2
37639	8426	12671	1
37640	8426	12961	2
37641	8427	12962	4
37642	8427	12963	3
37643	8427	12847	11
37644	8427	12848	1
37645	8427	12731	6
37646	8428	12964	5
37647	8428	12842	8
37648	8428	12666	6
37649	8428	12718	5
37650	8428	12755	5
37651	8429	12867	5
37652	8429	12847	11
37653	8429	12892	1
37654	8429	12840	4
37655	8429	12653	2
37656	8430	12867	5
37657	8430	12847	2
37658	8430	12879	4
37659	8430	12892	1
37660	8430	12840	1
37661	8431	12867	4
37662	8431	12847	8
37663	8431	12879	6
37664	8431	12848	2
37665	8431	12840	6
37666	8432	12878	4
37667	8432	12847	11
37668	8432	12879	7
37669	8432	12892	2
37670	8432	12840	4
37671	8433	12965	3
37672	8433	12966	2
37673	8433	12852	7
37674	8433	12967	4
37675	8433	12968	4
37676	8433	12844	2
37677	8434	12957	7
37678	8434	12803	8
37679	8434	12746	9
37680	8434	12839	4
37681	8434	12755	3
37682	8435	12956	5
37683	8435	12969	8
37684	8435	12666	6
37685	8435	12872	5
37686	8435	12755	8
37687	8436	12823	1
37688	8436	12783	11
37689	8436	12696	8
37690	8436	12970	9
37691	8436	12708	9
37692	8437	12867	6
37693	8437	12847	11
37694	8437	12892	2
37695	8437	12840	3
37696	8437	12653	4
37697	8438	12971	6
37698	8438	12847	13
37699	8438	12739	4
37700	8438	12972	5
37701	8438	12708	9
37702	8439	12823	1
37703	8439	12746	7
37704	8439	12696	8
37705	8439	12973	2
37706	8439	12755	5
37707	8440	12974	5
37708	8440	12876	6
37709	8440	12859	6
37710	8440	12872	4
37711	8440	12720	1
37712	8441	12940	2
37713	8441	12975	7
37714	8441	12976	2
37715	8441	12930	2
37716	8441	12671	3
37717	8442	12835	4
37718	8442	12881	5
37719	8442	12876	8
37720	8442	12839	3
37721	8442	12720	2
37722	8443	12823	3
37723	8443	12783	13
37724	8443	12970	8
37725	8443	12762	7
37726	8443	12755	7
37727	8444	12977	2
37728	8444	12852	8
37729	8444	12978	3
37730	8444	12844	2
37731	8444	12688	1
37732	8445	12979	5
37733	8445	12980	3
37734	8445	12903	11
37735	8445	12839	4
37736	8445	12844	11
37737	8446	12902	3
37738	8446	12909	8
37739	8446	12879	7
37740	8446	12981	4
37741	8446	12755	6
37742	8447	12845	3
37743	8447	12867	4
37744	8447	12847	11
37745	8447	12848	1
37746	8447	12840	5
37747	8448	12880	3
37748	8448	12881	6
37749	8448	12876	9
37750	8448	12854	1
37751	8448	12861	5
37752	8449	12897	5
37753	8449	12847	9
37754	8449	12982	3
37755	8449	12693	5
37756	8449	12708	4
37757	8450	12897	8
37758	8450	12927	8
37759	8450	12982	11
37760	8450	12983	4
37761	8450	12708	6
37762	8451	12984	1
37763	8451	12927	7
37764	8451	12770	1
37765	8451	12708	1
37766	8451	12649	1
37767	8452	12985	6
37768	8452	12986	5
37769	8452	12987	3
37770	8453	12988	5
37771	8454	12989	3
37772	8455	12990	4
37773	8455	12991	5
37774	8456	12989	11
37775	8457	12992	13
37776	8457	12993	4
37777	8458	12989	3
37778	8459	12989	1
37779	8460	12989	3
37780	8461	12994	3
37781	8461	12995	11
37782	8462	12985	4
37783	8462	12996	7
37784	8463	12997	7
37785	8463	12998	8
37786	8464	12999	4
37787	8465	13000	3
37788	8465	13001	11
37789	8466	13002	7
37790	8466	12987	3
37791	8467	12987	2
37792	8467	13003	13
37793	8468	13004	8
37794	8469	13005	2
37795	8469	13006	4
37796	8470	13007	5
37797	8470	13003	5
37798	8471	13008	11
37799	8471	13009	10
37800	8472	13010	7
37801	8472	13001	9
37802	8473	13003	11
37803	8474	13011	7
37804	8475	13003	4
37805	8476	13008	2
37806	8476	13001	9
37807	8477	13012	8
37808	8478	13013	8
37809	8479	13014	6
37810	8479	12999	4
37811	8480	12998	3
37812	8481	13015	5
37813	8481	13016	1
37814	8482	13017	11
37815	8482	13003	2
37816	8483	13017	3
37817	8484	13005	5
37818	8484	13017	3
37819	8485	13018	9
37820	8485	12991	5
37821	8486	13015	7
37822	8486	13013	8
37823	8487	13019	4
37824	8487	13017	5
37825	8488	13020	3
37826	8488	13006	3
37827	8489	13001	8
37828	8490	13013	4
37829	8490	13017	11
37830	8491	13003	11
37831	8492	13021	4
37832	8493	13017	11
37833	8493	13003	5
37834	8494	12999	2
37835	8494	13011	4
37836	8495	12999	5
37837	8495	13004	1
37838	8496	13022	5
37839	8497	13023	8
37840	8498	13024	8
37841	8498	13025	4
37842	8499	13026	7
37843	8500	13027	2
37844	8501	13004	6
37845	8502	13028	6
37846	8503	13029	5
37847	8504	13030	4
37848	8504	13031	2
37849	8505	13010	1
37850	8506	13032	4
37851	8507	13032	7
37852	8508	13033	3
37853	8508	13034	5
37854	8509	13035	1
37855	8509	12991	3
37856	8510	13036	1
37857	8511	13037	11
37858	8512	13017	11
37859	8512	13003	4
37860	8513	13038	5
37861	8514	13026	3
37862	8515	13039	2
37863	8516	13028	5
37864	8517	13017	2
37865	8517	13003	1
37866	8518	13040	8
37867	8519	13041	1
37868	8520	13039	1
37869	8521	13042	1
37870	8522	13011	9
37871	8523	13043	1
37872	8523	13044	3
37873	8524	13029	3
37874	8525	13004	8
37875	8526	13010	5
37876	8527	13042	2
37877	8528	13038	5
37878	8529	13045	5
37879	8530	13017	1
37880	8530	13003	1
37881	8531	13046	6
37882	8532	13045	1
37883	8533	13040	7
37884	8534	13029	4
37885	8535	13039	7
37886	8535	13047	2
37887	8536	13037	5
37888	8537	13046	5
37889	8538	13048	2
37890	8538	13049	3
37891	8539	13050	2
37892	8540	13010	5
37893	8541	13037	11
37894	8542	13004	9
37895	8543	13051	11
37896	8544	13032	4
37897	8545	13041	3
37898	8546	13052	9
37899	8547	13032	1
37900	8548	13053	6
37901	8549	13054	11
37902	8549	13055	5
37903	8549	13056	11
37904	8549	13057	6
37905	8549	13058	11
37906	8550	13059	14
37907	8550	13060	14
37908	8550	13061	7
37909	8550	13062	4
37910	8550	13058	10
37911	8551	13063	3
37912	8552	13061	6
37913	8552	13064	11
37914	8552	13065	5
37915	8552	13066	4
37916	8552	13067	13
37917	8553	13065	4
37918	8553	13063	3
37919	8553	13068	14
37920	8553	13069	6
37921	8553	13058	9
37922	8554	13070	4
37923	8554	13071	2
37924	8554	13054	11
37925	8554	13072	5
37926	8554	13073	4
37927	8554	13066	3
37928	8555	13074	11
37929	8555	13075	14
37930	8555	13076	9
37931	8555	13077	8
37932	8555	13078	8
37933	8555	13072	11
37934	8555	13079	9
37935	8556	13074	5
37936	8556	13080	14
37937	8556	13064	11
37938	8556	13081	8
37939	8556	13082	7
37940	8557	13061	6
37941	8557	13064	11
37942	8557	13065	6
37943	8557	13062	3
37944	8557	13083	9
37945	8557	13066	4
37946	8558	13084	14
37947	8558	13085	11
37948	8559	13086	7
37949	8559	13087	8
37950	8559	13066	3
37951	8559	13058	11
37952	8560	13084	14
37953	8560	13085	11
37954	8560	13088	11
37955	8560	13089	3
37956	8560	13073	6
37957	8560	13090	1
37958	8560	13091	9
37959	8561	13092	2
37960	8561	13093	7
37961	8561	13061	8
37962	8561	13081	8
37963	8561	13078	2
37964	8561	13094	7
37965	8562	13095	5
37966	8562	13096	2
37967	8562	13097	10
37968	8562	13098	3
37969	8562	13099	13
37970	8562	13067	8
37971	8563	13100	9
37972	8563	13101	6
37973	8563	13072	6
37974	8563	13102	5
37975	8563	13063	7
37976	8563	13103	11
37977	8564	13076	3
37978	8564	13064	8
37979	8564	13104	6
37980	8564	13055	4
37981	8564	13065	8
37982	8564	13062	1
37983	8565	13105	3
37984	8565	13074	11
37985	8565	13075	14
37986	8565	13077	8
37987	8565	13056	11
37988	8565	13067	11
37989	8566	13076	7
37990	8566	13077	9
37991	8566	13094	6
37992	8566	13102	4
37993	8566	13058	9
37994	8567	13106	11
37995	8567	13107	2
37996	8567	13084	14
37997	8567	13085	11
37998	8567	13099	6
37999	8567	13057	12
38000	8567	13067	8
38001	8568	13076	6
38002	8568	13081	11
38003	8568	13094	6
38004	8568	13102	6
38005	8568	13067	9
38006	8569	13108	14
38007	8569	13085	5
38008	8569	13076	5
38009	8569	13064	2
38010	8569	13065	6
38011	8569	13102	13
38012	8569	13063	7
38013	8570	13074	11
38014	8570	13080	14
38015	8570	13061	9
38016	8570	13088	11
38017	8570	13065	8
38018	8570	13102	4
38019	8570	13109	2
38020	8570	13091	6
38021	8571	13076	5
38022	8571	13064	3
38023	8571	13104	6
38024	8571	13055	4
38025	8571	13065	2
38026	8571	13062	5
38027	8571	13102	5
38028	8572	13110	5
38029	8572	13111	11
38030	8572	13112	8
38031	8572	13102	13
38032	8572	13057	5
38033	8572	13058	11
38034	8573	13113	6
38035	8573	13100	11
38036	8573	13099	9
38037	8573	13056	8
38038	8573	13083	9
38039	8573	13114	3
38040	8574	13115	9
38041	8574	13116	3
38042	8574	13117	2
38043	8574	13073	2
38044	8575	13118	4
38045	8575	13119	9
38046	8575	13120	8
38047	8575	13121	4
38048	8575	13117	7
38049	8575	13122	9
38050	8576	13123	4
38051	8576	13124	9
38052	8576	13125	7
38053	8576	13122	12
38054	8576	13126	5
38055	8576	13058	8
38056	8577	13127	6
38057	8577	13128	5
38058	8577	13129	3
38059	8577	13098	5
38060	8577	13122	6
38061	8577	13067	8
38062	8578	13130	8
38063	8578	13131	9
38064	8578	13132	9
38065	8578	13122	9
38066	8579	13133	4
38067	8579	13077	2
38068	8579	13094	2
38069	8579	13056	5
38070	8579	13102	3
38071	8579	13134	2
38072	8580	13135	4
38073	8580	13136	5
38074	8580	13077	11
38075	8580	13137	8
34815	7833	11428	5
34764	7822	11377	11
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
1830	1840	199938944	1
1831	1841	200258957	1
1832	1842	200261631	1
1833	1843	200302684	1
1834	1844	200306538	1
1835	1845	200427046	1
1836	1846	200505277	1
1837	1847	200571597	1
1838	1848	200604764	1
1839	1849	200611321	1
1840	1850	200618693	1
1841	1851	200645172	1
1842	1852	200678578	1
1843	1853	200678652	1
1844	1854	200660742	1
1845	1855	200660849	1
1846	1856	200702110	1
1847	1857	200716081	1
1848	1858	200722129	1
1849	1859	200727064	1
1850	1860	200729866	1
1851	1861	200737513	1
1852	1862	200742060	1
1853	1863	200746440	1
1854	1864	200746691	1
1855	1865	200750610	1
1856	1866	200776104	1
1857	1867	200703789	1
1858	1868	200801494	1
1859	1869	200804269	1
1860	1870	200805213	1
1861	1871	200806725	1
1862	1872	200807619	1
1863	1873	200810012	1
1864	1874	200810449	1
1865	1875	200812434	1
1866	1876	200816057	1
1867	1877	200816182	1
1868	1878	200818798	1
1869	1879	200820492	1
1870	1880	200820845	1
1871	1881	200822195	1
1872	1882	200824411	1
1873	1883	200826125	1
1874	1884	200826132	1
1875	1885	200829462	1
1876	1886	200831088	1
1877	1887	200835065	1
1878	1888	200838847	1
1879	1889	200850304	1
1880	1890	200854833	1
1881	1891	200859513	1
1882	1892	200861979	1
1883	1893	200863141	1
1884	1894	200863910	1
1885	1895	200863943	1
1886	1896	200867820	1
1887	1897	200867969	1
1888	1898	200869234	1
1889	1899	200878505	1
1890	1900	200878522	1
1891	1901	200879055	1
1892	1902	200751702	1
1893	1903	200649333	1
1894	1904	200704149	1
1895	1905	200800722	1
1896	1906	200800992	1
1897	1907	200802019	1
1898	1908	200805994	1
1899	1909	200810511	1
1900	1910	200810842	1
1901	1911	200815563	1
1902	1912	200816422	1
1903	1913	200817653	1
1904	1914	200850077	1
1905	1915	200852284	1
1906	1916	200865811	1
1907	1917	200900039	1
1908	1918	200900138	1
1909	1919	200900163	1
1910	1920	200900184	1
1911	1921	200900407	1
1912	1922	200900495	1
1913	1923	200900643	1
1914	1924	200900790	1
1915	1925	200901056	1
1916	1926	200903933	1
1917	1927	200904996	1
1918	1928	200905558	1
1919	1929	200906611	1
1920	1930	200906984	1
1921	1931	200907623	1
1922	1932	200909509	1
1923	1933	200910151	1
1924	1934	200910605	1
1925	1935	200911631	1
1926	1936	200911675	1
1927	1937	200911724	1
1928	1938	200911734	1
1929	1939	200911738	1
1930	1940	200911827	1
1931	1941	200912221	1
1932	1942	200912581	1
1933	1943	200912820	1
1934	1944	200912874	1
1935	1945	200912972	1
1936	1946	200913084	1
1937	1947	200913146	1
1938	1948	200913757	1
1939	1949	200913846	1
1940	1950	200913901	1
1941	1951	200914214	1
1942	1952	200914369	1
1943	1953	200914550	1
1944	1954	200915033	1
1945	1955	200920483	1
1946	1956	200920633	1
1947	1957	200921105	1
1948	1958	200921634	1
1949	1959	200922056	1
1950	1960	200922763	1
1951	1961	200922784	1
1952	1962	200922882	1
1953	1963	200924554	1
1954	1964	200925215	1
1955	1965	200925241	1
1956	1966	200925249	1
1957	1967	200925556	1
1958	1968	200925562	1
1959	1969	200926277	1
1960	1970	200926328	1
1961	1971	200926380	1
1962	1972	200926385	1
1963	1973	200929259	1
1964	1974	200929277	1
1965	1975	200929367	1
1966	1976	200929381	1
1967	1977	200929428	1
1968	1978	200929656	1
1969	1979	200930017	1
1970	1980	200932205	1
1971	1981	200933686	1
1972	1982	200935632	1
1973	1983	200936633	1
1974	1984	200937320	1
1975	1985	200939122	1
1976	1986	200940273	1
1977	1987	200942368	1
1978	1988	200942606	1
1979	1989	200945214	1
1980	1990	200945219	1
1981	1991	200950378	1
1982	1992	200950655	1
1983	1993	200950663	1
1984	1994	200951345	1
1985	1995	200951383	1
1986	1996	200952820	1
1987	1997	200952936	1
1988	1998	200953322	1
1989	1999	200953427	1
1990	2000	200953449	1
1991	2001	200953589	1
1992	2002	200953593	1
1993	2003	200953879	1
1994	2004	200953979	1
1995	2005	200954553	1
1996	2006	200955605	1
1997	2007	200957922	1
1998	2008	200960039	1
1999	2009	200962443	1
2000	2010	200978170	1
2001	2011	200978810	1
2002	2012	200978939	1
2003	2013	200819985	1
2004	2014	200824759	1
2005	2015	200865810	1
2006	2016	200804221	1
\.


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentterms (studenttermid, studentid, termid, ineligibilities, issettled, cwa, gwa, mathgwa, csgwa) FROM stdin;
7828	1831	20031	N/A	t	2.8207	3.1250	3.0000	3.8333
7825	1831	20022	N/A	t	2.7132	3.0000	3.0000	3.2500
7842	1832	20041	N/A	t	3.0247	3.2917	3.0417	3.2500
7823	1832	20021	N/A	t	2.2500	2.2500	2.2500	2.2500
7816	1830	20002	N/A	t	2.3136	3.8235	2.6250	3.0500
7817	1830	20003	N/A	t	2.3074	2.2500	2.4474	3.0500
7819	1830	20012	N/A	t	2.6951	4.2000	2.5227	3.5300
7820	1830	20013	N/A	t	2.6563	2.1250	2.5227	3.3661
7824	1830	20022	N/A	t	2.7146	3.2500	2.5227	3.3316
7827	1830	20031	N/A	t	2.7370	3.0000	2.5227	3.2802
7830	1833	20031	N/A	t	2.5000	2.5000	2.5000	3.0000
7831	1834	20031	N/A	t	2.5909	2.5909	3.0000	0.0000
7832	1830	20032	N/A	t	2.7370	0.0000	2.5227	3.2802
7834	1832	20032	N/A	t	2.9710	4.6250	3.0476	3.1346
7835	1833	20032	N/A	t	2.6600	2.7857	2.7500	2.5000
7836	1834	20032	N/A	t	2.2500	2.0294	3.0000	1.2500
7838	1832	20033	N/A	t	2.9589	2.7500	3.0476	3.1346
7839	1833	20033	N/A	t	2.5323	2.0000	2.7500	2.5000
7840	1834	20033	N/A	t	2.5152	4.0000	3.3333	1.2500
7843	1833	20041	N/A	t	2.7273	3.1923	2.6667	2.4000
7844	1834	20041	N/A	t	2.4844	2.4167	3.0625	1.8750
7846	1831	20042	N/A	t	2.5758	2.2500	3.0000	2.8581
7847	1832	20042	N/A	t	3.0354	2.9000	3.0417	3.4643
7848	1833	20042	N/A	t	3.2000	4.5789	3.3333	3.0000
7850	1835	20042	N/A	t	1.9032	2.1429	2.3750	1.1250
7851	1831	20043	N/A	t	2.5495	2.1786	3.0000	2.8581
7853	1833	20043	N/A	t	3.2000	0.0000	3.3333	3.0000
7854	1834	20043	N/A	t	2.7188	2.2500	3.3793	2.9167
7855	1835	20043	N/A	t	1.9032	0.0000	2.3750	1.1250
7857	1832	20051	N/A	t	2.9250	2.7500	3.0417	3.0625
7858	1833	20051	N/A	t	3.1349	3.2237	3.5417	3.0000
7859	1834	20051	N/A	t	2.7039	3.1000	3.5313	2.9375
7861	1836	20051	N/A	t	1.8824	1.8824	1.7500	1.7500
7862	1837	20051	N/A	t	1.9265	1.9265	1.7500	1.2500
7863	1831	20052	N/A	t	2.4981	2.2500	3.0000	2.6250
7865	1833	20052	N/A	t	3.0395	2.6579	3.5417	3.0000
7866	1835	20052	N/A	t	2.1439	2.6250	2.6071	1.5156
7867	1836	20052	N/A	t	2.5161	3.2857	3.3750	1.7500
7869	1832	20053	N/A	t	2.7785	1.1250	3.0417	2.7119
7870	1833	20053	N/A	t	3.0077	2.0000	3.3704	3.0000
7871	1836	20053	N/A	t	2.4792	2.2500	3.0000	1.7500
7873	1832	20061	N/A	t	2.7911	3.0000	3.0417	2.7500
7874	1835	20061	N/A	t	2.0402	1.7143	2.4688	1.6000
7876	1837	20061	N/A	t	2.0647	2.2794	2.1538	1.8281
7877	1838	20061	N/A	t	2.1618	2.1618	3.0000	2.0000
7878	1839	20061	N/A	t	2.5735	2.5735	5.0000	2.0000
7880	1841	20061	N/A	t	2.2500	2.2500	3.0000	2.5000
7881	1842	20061	N/A	t	2.4118	2.4118	4.0000	1.0000
7882	1843	20061	N/A	t	2.2059	2.2059	3.0000	1.2500
7884	1834	20062	N/A	t	2.6236	2.1538	3.4643	2.6406
7885	1835	20062	N/A	t	1.9476	1.5000	2.4688	1.4865
7886	1836	20062	N/A	t	3.0634	3.5333	3.4000	2.4231
7888	1838	20062	N/A	t	2.5221	2.8824	4.0000	2.1250
7889	1839	20062	N/A	t	2.5074	2.4412	3.8750	2.3750
7890	1840	20062	N/A	t	1.9706	2.0735	2.8750	2.0000
7892	1842	20062	N/A	t	2.1618	1.9118	3.0000	1.1250
7893	1843	20062	N/A	t	2.0735	1.9412	3.0000	1.3750
7894	1835	20063	N/A	t	1.9476	0.0000	2.4688	1.4865
7896	1837	20063	N/A	t	2.1044	1.7500	2.2656	1.9091
7897	1839	20063	N/A	t	2.5705	3.0000	3.5833	2.3750
7898	1840	20063	N/A	t	2.0526	2.7500	2.8750	2.0000
7900	1842	20063	N/A	t	2.2372	2.7500	2.9167	1.1250
7901	1843	20063	N/A	t	1.9875	1.5000	3.0000	1.3750
7903	1835	20071	N/A	t	2.0407	2.5833	2.4688	1.7959
7904	1836	20071	N/A	t	2.9888	2.7083	3.3226	2.5568
7905	1837	20071	N/A	t	2.1624	2.4167	2.2656	2.1397
7907	1839	20071	N/A	t	2.4052	2.0658	3.3125	2.4250
7908	1840	20071	N/A	t	2.0714	2.1111	2.9167	2.0000
7909	1841	20071	N/A	t	2.2406	2.2000	2.9167	2.4500
7911	1845	20071	N/A	t	2.1667	2.1667	1.7500	0.0000
7913	1843	20071	N/A	t	2.1102	2.3684	2.9167	1.9250
7914	1846	20071	N/A	t	1.7059	1.7059	2.5000	1.2500
7919	1851	20071	N/A	t	2.7679	2.7679	2.5000	1.2500
7920	1852	20071	N/A	t	1.9559	1.9559	2.7500	1.5000
7921	1853	20071	N/A	t	1.4853	1.4853	1.0000	1.0000
7922	1854	20071	N/A	t	2.2059	2.2059	3.0000	2.0000
7923	1855	20071	N/A	t	1.7647	1.7647	1.5000	1.5000
7924	1856	20071	N/A	t	1.7206	1.7206	2.2500	1.0000
7925	1832	20072	N/A	t	2.7988	3.0000	3.0417	2.7610
7926	1834	20072	N/A	t	2.5768	2.5500	3.4643	2.7763
7927	1835	20072	N/A	t	2.0265	1.9500	2.4688	1.7959
7928	1836	20072	N/A	t	3.1589	4.0000	3.3226	3.0726
7929	1837	20072	N/A	t	2.1071	1.7500	2.2656	2.0058
7930	1838	20072	N/A	t	2.6208	2.4500	3.5000	2.2750
7931	1839	20072	N/A	t	2.3547	2.1719	3.0761	2.5000
7933	1841	20072	N/A	t	2.4826	3.1579	3.1190	3.0385
7934	1844	20072	N/A	t	3.2803	4.0694	3.6250	4.0000
7935	1845	20072	N/A	t	2.5446	2.8281	2.1591	2.2500
7937	1843	20072	N/A	t	2.4967	3.9219	3.2262	2.6346
7938	1846	20072	N/A	t	2.1618	2.6176	3.7500	1.5000
7939	1847	20072	N/A	t	2.1618	2.2500	2.2500	1.3750
7941	1849	20072	N/A	t	2.8603	2.4412	3.8750	2.1250
7942	1850	20072	N/A	t	2.2500	2.2941	3.0000	2.3750
7943	1851	20072	N/A	t	2.8929	3.0179	3.7500	1.3750
7945	1853	20072	N/A	t	1.6985	1.9118	1.5000	1.1250
7946	1854	20072	N/A	t	1.9779	1.7500	2.7500	1.5000
7947	1855	20072	N/A	t	1.7794	1.7941	2.0000	1.5000
7949	1835	20073	N/A	t	2.0148	1.5000	2.4688	1.7959
7952	1839	20073	N/A	t	2.3312	1.7500	2.9231	2.5000
7953	1841	20073	N/A	t	2.4633	2.0000	2.9792	3.0385
7955	1842	20073	N/A	t	2.4383	5.0000	2.6635	1.6923
7956	1843	20073	N/A	t	2.4573	2.0357	3.0417	2.6346
7958	1848	20073	N/A	t	2.2500	1.5000	2.2500	1.8750
7959	1849	20073	N/A	t	2.8782	3.0000	3.5833	2.1250
7960	1851	20073	N/A	t	2.6818	1.5000	3.0000	1.3750
7961	1852	20073	N/A	t	2.4038	2.0000	3.2500	1.7500
7963	1836	20081	N/A	t	3.1983	3.6667	3.3226	3.0608
7964	1837	20081	N/A	t	2.0620	1.5500	2.2656	1.8750
7966	1839	20081	N/A	t	2.2690	1.9500	2.9231	2.1932
7967	1840	20081	N/A	t	2.4389	2.7000	3.1667	2.5625
7968	1841	20081	N/A	t	2.4861	2.6000	2.9792	2.8523
7970	1845	20081	N/A	t	2.5598	2.5833	2.1591	3.0000
7971	1842	20081	N/A	t	2.5208	2.8553	2.6635	2.3661
7972	1843	20081	N/A	t	2.4533	2.0000	3.0417	2.3409
7974	1857	20081	N/A	t	1.9265	1.9265	2.5000	1.2500
7975	1847	20081	N/A	t	2.1085	2.0132	2.4167	1.4250
7977	1849	20081	N/A	t	2.7723	2.5294	3.5833	2.2750
7978	1850	20081	N/A	t	2.3950	2.7031	3.0000	2.5250
7979	1851	20081	N/A	t	2.9583	3.5667	3.2500	1.3750
7981	1853	20081	N/A	t	1.9387	2.3684	1.8333	1.6750
7982	1854	20081	N/A	t	2.2830	2.8289	3.5000	1.3000
7983	1855	20081	N/A	t	2.0802	2.6184	2.2500	2.1000
7985	1858	20081	N/A	t	2.0294	2.0294	3.0000	1.5000
7986	1859	20081	N/A	t	1.7941	1.7941	2.5000	1.0000
7987	1860	20081	N/A	t	2.2059	2.2059	2.2500	2.2500
7989	1862	20081	N/A	t	2.9265	2.9265	2.7500	2.2500
7990	1863	20081	N/A	t	2.3971	2.3971	2.0000	2.7500
7991	1864	20081	N/A	t	1.9853	1.9853	2.2500	2.2500
7993	1866	20081	N/A	t	2.0294	2.0294	2.2500	2.2500
7994	1867	20081	N/A	t	2.8382	2.8382	2.7500	3.0000
7995	1868	20081	N/A	t	1.9853	1.9853	2.2500	2.0000
7997	1870	20081	N/A	t	2.7794	2.7794	3.0000	2.5000
7998	1871	20081	N/A	t	2.1765	2.1765	2.7500	2.2500
7999	1872	20081	N/A	t	1.8235	1.8235	2.0000	1.0000
8001	1874	20081	N/A	t	2.1471	2.1471	2.5000	2.2500
8002	1875	20081	N/A	t	2.0147	2.0147	2.5000	1.0000
8004	1877	20081	N/A	t	2.0441	2.0441	2.0000	2.0000
8005	1878	20081	N/A	t	3.0179	3.0179	5.0000	2.0000
8006	1879	20081	N/A	t	2.2647	2.2647	2.7500	1.7500
8008	1881	20081	N/A	t	2.0441	2.0441	2.7500	2.0000
8009	1882	20081	N/A	t	1.8824	1.8824	1.7500	1.0000
8010	1883	20081	N/A	t	2.2353	2.2353	2.5000	2.2500
8012	1885	20081	N/A	t	2.4853	2.4853	2.7500	2.7500
8013	1886	20081	N/A	t	1.8824	1.8824	1.7500	1.5000
8014	1887	20081	N/A	t	1.9107	1.9107	1.0000	2.0000
8016	1889	20081	N/A	t	1.8235	1.8235	2.7500	1.7500
8017	1890	20081	N/A	t	1.8676	1.8676	1.2500	2.0000
8018	1891	20081	N/A	t	2.9265	2.9265	5.0000	5.0000
8020	1834	20082	N/A	t	2.5688	1.8125	3.4643	2.7264
8021	1836	20082	N/A	t	3.1855	2.9000	3.3226	3.1467
8023	1838	20082	N/A	t	2.5808	2.4500	3.0577	2.3026
8024	1839	20082	N/A	t	2.3000	2.4583	2.9231	2.1691
8025	1840	20082	N/A	t	2.4690	2.6500	3.1667	2.6000
8027	1844	20082	N/A	t	2.7429	2.3438	3.0952	2.8269
8028	1845	20082	N/A	t	2.5363	2.4688	2.1591	2.3947
8029	1842	20082	N/A	t	2.5180	2.5000	2.6635	2.2568
8031	1846	20082	N/A	t	2.2711	2.6563	3.2212	1.6538
8032	1857	20082	N/A	t	2.2786	2.6111	2.5000	1.8750
8034	1848	20082	N/A	t	2.5530	3.2941	2.7500	2.9423
8035	1849	20082	N/A	t	2.7577	2.6667	3.5833	2.4423
8036	1850	20082	N/A	t	2.4167	2.4844	2.9643	2.5250
8038	1852	20082	N/A	t	2.5037	3.4250	3.1630	1.9500
8039	1853	20082	N/A	t	2.1739	2.9531	2.3452	1.8654
8040	1854	20082	N/A	t	2.4706	3.4444	3.5870	1.4615
8042	1892	20082	N/A	t	2.2500	2.2500	3.0000	2.2500
8043	1856	20082	N/A	t	1.9097	2.1711	2.4405	1.5962
8044	1858	20082	N/A	t	2.0294	2.0294	2.6250	1.5000
8046	1860	20082	N/A	t	2.4044	2.6029	2.6250	2.2500
8047	1861	20082	N/A	t	2.3676	2.7059	4.0000	2.1250
8048	1862	20082	N/A	t	2.6397	2.3529	2.7500	2.3750
8050	1864	20082	N/A	t	1.9839	1.9821	2.6250	1.8750
8051	1865	20082	N/A	t	2.0368	1.9853	2.1250	1.0000
8053	1867	20082	N/A	t	2.8065	2.7679	2.6250	3.0000
8054	1868	20082	N/A	t	2.1176	2.2500	2.2500	2.0000
8055	1869	20082	N/A	t	2.7721	2.3971	3.8750	3.2500
8057	1871	20082	N/A	t	2.0956	2.0147	2.6250	2.2500
8058	1872	20082	N/A	t	1.9559	2.0882	2.3750	1.0000
8059	1873	20082	N/A	t	1.7868	1.8971	2.2500	1.3750
8061	1875	20082	N/A	t	2.1324	2.2500	2.7500	1.3750
8062	1876	20082	N/A	t	2.6397	3.1912	3.8750	1.8750
8063	1877	20082	N/A	t	2.1959	2.3250	1.7500	2.3750
8065	1879	20082	N/A	t	2.2647	2.2647	2.7500	2.1250
8066	1880	20082	N/A	t	2.3879	1.4375	2.7500	3.1250
8067	1881	20082	N/A	t	2.2353	2.4265	2.8750	2.5000
8069	1883	20082	N/A	t	2.0882	1.9412	2.3750	2.1250
8070	1884	20082	N/A	t	2.2279	2.1618	3.0000	2.2500
8072	1886	20082	N/A	t	1.8676	1.8529	1.6250	1.5000
8073	1887	20082	N/A	t	2.2143	2.5179	1.6250	2.5000
8074	1888	20082	N/A	t	2.6765	2.9706	4.0000	2.3750
8076	1890	20082	N/A	t	2.1397	2.4118	1.8750	1.8750
8077	1891	20082	N/A	t	2.5515	2.1765	3.8750	3.8750
8078	1833	20083	N/A	t	3.0225	2.7500	3.3083	3.0000
8080	1839	20083	N/A	t	2.2721	1.2500	2.9231	2.1691
8081	1841	20083	N/A	t	2.5023	1.2500	2.9792	2.7500
8082	1844	20083	N/A	t	2.7021	1.7500	3.0952	2.8269
8084	1846	20083	N/A	t	2.2403	1.8750	3.1207	1.6538
8085	1857	20083	N/A	t	2.2756	2.2500	2.5000	1.8750
8088	1851	20083	N/A	t	2.6014	1.0000	2.6875	1.4167
8089	1852	20083	N/A	t	2.5246	3.0000	3.1442	1.9500
8091	1854	20083	N/A	t	2.4767	2.5357	3.4327	1.4615
8092	1892	20083	N/A	t	2.4205	3.0000	3.0000	2.2500
8094	1862	20083	N/A	t	2.4688	1.5000	2.7500	2.3750
8095	1863	20083	N/A	t	2.6053	3.0000	3.0000	2.8750
8096	1867	20083	N/A	t	2.8333	3.0000	2.7500	3.0000
8098	1870	20083	N/A	t	2.7813	1.1250	4.0000	2.2500
8099	1872	20083	N/A	t	1.8974	1.5000	2.0833	1.0000
8100	1873	20083	N/A	t	1.8355	2.2500	2.2500	1.3750
8102	1877	20083	N/A	t	2.2558	2.6250	1.7500	2.3750
8103	1878	20083	N/A	t	2.4792	3.0000	3.5000	1.7500
8104	1879	20083	N/A	t	2.1500	1.5000	2.7500	2.1250
8106	1881	20083	N/A	t	2.5897	5.0000	3.5833	2.5000
8107	1882	20083	N/A	t	1.9615	2.0000	2.2500	1.0000
8108	1885	20083	N/A	t	2.5897	3.0000	2.8333	2.6250
8110	1887	20083	N/A	t	2.0303	1.0000	1.4167	2.5000
8111	1888	20083	N/A	t	2.6859	2.7500	3.5833	2.3750
8113	1833	20091	N/A	t	3.1667	4.5000	3.3083	3.4800
8114	1834	20091	N/A	t	2.5451	2.5000	3.4643	2.7264
8115	1836	20091	N/A	t	3.1294	2.5000	3.3226	3.0246
8116	1837	20091	N/A	t	2.0763	2.0000	2.2656	1.8679
8118	1839	20091	N/A	t	2.3960	3.5625	2.9231	2.5326
8119	1840	20091	N/A	t	2.4979	2.5500	3.1667	2.7721
8121	1893	20091	N/A	t	1.7000	1.7000	0.0000	2.0000
8122	1844	20091	N/A	t	2.7188	2.8000	3.0952	2.8421
8123	1845	20091	N/A	t	2.5000	2.3125	2.1591	2.4286
8125	1843	20091	N/A	t	2.5471	2.7031	3.0417	2.3409
8126	1846	20091	N/A	t	2.4130	3.3000	3.1207	1.7632
8127	1857	20091	N/A	t	2.4183	3.0625	3.2500	1.8250
8129	1847	20091	N/A	t	2.2742	2.6429	2.4762	2.0455
8130	1848	20091	N/A	t	2.6609	3.0417	2.7500	2.9605
8131	1849	20091	N/A	t	2.8375	3.7692	3.5870	2.6184
8133	1851	20091	N/A	t	2.7259	3.3393	2.9113	1.5313
8134	1852	20091	N/A	t	2.6006	2.7500	3.1442	2.1316
8135	1853	20091	N/A	t	2.3833	2.8000	2.3646	1.9545
8137	1855	20091	N/A	t	2.0893	2.0500	2.2813	1.9219
8138	1892	20091	N/A	t	2.4803	2.5625	3.4615	2.0000
8139	1856	20091	N/A	t	1.9278	2.0000	2.4405	1.6250
8141	1896	20091	N/A	t	2.5000	2.5000	3.0000	2.7500
8142	1858	20091	N/A	t	2.0561	2.1167	2.5833	1.4167
8143	1897	20091	N/A	t	2.6500	2.6500	3.0000	0.0000
8145	1860	20091	N/A	t	2.4151	2.4342	2.7500	2.3500
8146	1898	20091	N/A	t	2.0417	2.0417	2.5000	2.0000
8148	1862	20091	N/A	t	2.6339	3.0469	3.5000	2.3250
8149	1863	20091	N/A	t	2.8113	3.3333	3.0000	2.8750
8150	1864	20091	N/A	t	2.1100	2.3158	2.7500	2.1250
8151	1899	20091	N/A	t	2.1667	2.1667	2.5000	0.0000
8153	1865	20091	N/A	t	2.0200	1.9844	2.2500	1.0000
8154	1901	20091	N/A	t	2.4722	2.4722	3.0000	2.2500
8156	1867	20091	N/A	t	2.7206	2.4500	3.1250	2.5000
8157	1902	20091	N/A	t	2.7083	2.7083	2.7500	2.2500
8158	1903	20091	N/A	t	1.6346	1.6346	0.0000	1.5000
8160	1869	20091	N/A	t	2.6447	2.3750	3.3750	2.5833
8161	1870	20091	N/A	t	2.7455	2.6563	3.6667	2.5500
8162	1871	20091	N/A	t	2.0613	2.0000	2.4167	2.0500
8164	1873	20091	N/A	t	1.8070	1.7500	2.1667	1.5250
8165	1874	20091	N/A	t	2.4440	2.3553	3.2500	2.3250
8167	1876	20091	N/A	t	2.5750	2.4375	3.5000	1.9250
8168	1877	20091	N/A	t	2.8545	5.0000	2.8333	3.2500
8169	1878	20091	N/A	t	2.3682	2.1579	3.2500	1.6500
8171	1879	20091	N/A	t	2.2232	2.4063	2.8333	2.2750
8172	1905	20091	N/A	t	2.0556	2.0556	2.7500	1.7500
8173	1880	20091	N/A	t	2.2227	2.2083	2.5000	2.8333
8175	1882	20091	N/A	t	1.9958	2.0625	2.3750	1.4844
8176	1883	20091	N/A	t	2.1840	2.3553	2.5833	2.3750
8177	1884	20091	N/A	t	2.2123	2.1842	2.9167	1.8500
8179	1906	20091	N/A	t	1.8472	1.8472	2.2500	1.5000
8180	1886	20091	N/A	t	2.1708	2.6765	2.3611	1.8000
8181	1887	20091	N/A	t	2.3000	2.8235	1.8472	2.5000
8183	1889	20091	N/A	t	2.1780	2.4250	2.3611	2.4500
8184	1890	20091	N/A	t	2.2500	2.4844	2.0833	2.1250
8186	1907	20091	N/A	t	1.5735	1.5735	1.0000	1.0000
8187	1908	20091	N/A	t	1.6471	1.6471	1.2500	1.5000
8188	1909	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
8189	1910	20091	N/A	t	2.2353	2.2353	2.5000	3.0000
8191	1912	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
8192	1913	20091	N/A	t	2.7500	2.7500	2.7500	5.0000
8194	1915	20091	N/A	t	1.8088	1.8088	2.2500	2.7500
8195	1916	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
8196	1917	20091	N/A	t	1.6912	1.6912	2.7500	1.0000
8198	1919	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
8199	1920	20091	N/A	t	2.1912	2.1912	2.5000	2.5000
8200	1921	20091	N/A	t	1.6765	1.6765	2.2500	1.0000
8202	1923	20091	N/A	t	1.4559	1.4559	1.5000	1.0000
8203	1924	20091	N/A	t	3.0147	3.0147	5.0000	2.7500
8204	1925	20091	N/A	t	1.9265	1.9265	2.5000	2.0000
8206	1927	20091	N/A	t	1.9412	1.9412	2.2500	1.7500
8207	1928	20091	N/A	t	1.4412	1.4412	1.0000	1.5000
8208	1929	20091	N/A	t	2.7941	2.7941	2.7500	5.0000
8210	1931	20091	N/A	t	1.4706	1.4706	1.2500	1.5000
8211	1932	20091	N/A	t	1.6176	1.6176	1.7500	2.5000
8213	1934	20091	N/A	t	2.3529	2.3529	2.7500	2.7500
8214	1935	20091	N/A	t	1.8529	1.8529	1.5000	2.0000
8215	1936	20091	N/A	t	2.3088	2.3088	2.7500	3.0000
8217	1938	20091	N/A	t	1.7941	1.7941	1.7500	1.7500
8218	1939	20091	N/A	t	1.3529	1.3529	1.0000	1.2500
8219	1940	20091	N/A	t	1.9118	1.9118	2.0000	2.0000
8221	1942	20091	N/A	t	1.8088	1.8088	2.2500	1.5000
8224	1945	20091	N/A	t	2.1765	2.1765	2.7500	1.2500
8225	1946	20091	N/A	t	1.9853	1.9853	2.2500	1.0000
8227	1948	20091	N/A	t	1.7500	1.7500	1.0000	2.0000
8228	1949	20091	N/A	t	1.5147	1.5147	2.0000	1.0000
8229	1950	20091	N/A	t	2.3971	2.3971	2.7500	2.0000
8231	1952	20091	N/A	t	1.5882	1.5882	2.2500	1.0000
8232	1953	20091	N/A	t	2.1471	2.1471	2.5000	3.0000
8234	1955	20091	N/A	t	1.2647	1.2647	1.7500	1.0000
8235	1956	20091	N/A	t	2.2941	2.2941	3.0000	2.0000
8236	1957	20091	N/A	t	2.1765	2.1765	2.7500	2.5000
8238	1959	20091	N/A	t	1.9853	1.9853	3.0000	1.2500
8239	1960	20091	N/A	t	1.7647	1.7647	2.2500	1.5000
8240	1961	20091	N/A	t	1.4265	1.4265	1.2500	1.5000
8242	1963	20091	N/A	t	2.1618	2.1618	2.2500	1.0000
8243	1964	20091	N/A	t	1.2000	1.2000	1.0000	1.0000
8244	1965	20091	N/A	t	1.2647	1.2647	1.0000	1.5000
8246	1967	20091	N/A	t	1.7206	1.7206	2.2500	1.0000
8247	1968	20091	N/A	t	1.8382	1.8382	1.7500	2.0000
8248	1969	20091	N/A	t	2.0294	2.0294	3.0000	1.0000
8250	1971	20091	N/A	t	2.2500	2.2500	2.2500	2.7500
8251	1972	20091	N/A	t	1.2353	1.2353	1.5000	1.0000
8253	1974	20091	N/A	t	2.3971	2.3971	2.0000	2.2500
8254	1975	20091	N/A	t	2.3824	2.3824	3.0000	2.5000
8255	1976	20091	N/A	t	3.1912	3.1912	5.0000	2.5000
8257	1978	20091	N/A	t	2.0735	2.0735	3.0000	1.7500
8258	1979	20091	N/A	t	1.5882	1.5882	1.5000	1.7500
8259	1980	20091	N/A	t	1.5441	1.5441	1.5000	1.2500
8261	1982	20091	N/A	t	2.0441	2.0441	2.7500	1.7500
8262	1983	20091	N/A	t	2.1324	2.1324	2.7500	2.0000
8263	1984	20091	N/A	t	1.7206	1.7206	2.2500	2.0000
8265	1986	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
8266	1987	20091	N/A	t	1.8971	1.8971	2.2500	2.7500
8267	1988	20091	N/A	t	2.1324	2.1324	2.7500	1.0000
8269	1990	20091	N/A	t	1.7059	1.7059	2.5000	1.5000
8270	1991	20091	N/A	t	2.0147	2.0147	2.5000	1.2500
8271	1992	20091	N/A	t	2.6618	2.6618	5.0000	1.0000
8273	1994	20091	N/A	t	2.2500	2.2500	3.0000	3.0000
8274	1995	20091	N/A	t	1.8088	1.8088	2.2500	1.7500
8276	1997	20091	N/A	t	1.8971	1.8971	3.0000	1.7500
8277	1998	20091	N/A	t	2.0588	2.0588	2.5000	2.0000
8278	1999	20091	N/A	t	2.8676	2.8676	3.0000	4.0000
8280	2001	20091	N/A	t	2.1471	2.1471	2.5000	2.0000
8281	2002	20091	N/A	t	1.5147	1.5147	2.0000	1.1250
8282	1833	20092	N/A	t	3.1407	3.4167	3.5069	3.2838
8284	1838	20092	N/A	t	2.4154	1.7500	3.0577	2.0263
8285	1839	20092	N/A	t	2.3607	2.0000	2.9231	2.5326
8287	1841	20092	N/A	t	2.5079	2.5000	2.9792	2.6346
8288	1893	20092	N/A	t	1.9375	2.0781	0.0000	2.0568
8289	1844	20092	N/A	t	2.6250	1.9375	3.0952	2.7600
8291	1842	20092	N/A	t	2.5581	2.0000	2.6635	2.2500
8292	1843	20092	N/A	t	2.6045	3.1875	3.0417	2.3450
8293	1846	20092	N/A	t	2.3692	2.4167	3.1207	1.8790
8295	1894	20092	N/A	t	2.3182	2.5417	2.2500	2.5000
8296	1847	20092	N/A	t	2.2027	1.8333	2.4762	1.9632
8297	1848	20092	N/A	t	2.5905	2.2500	2.7500	2.6371
8299	1850	20092	N/A	t	2.4056	1.7917	2.9643	2.2700
8300	1851	20092	N/A	t	2.8194	3.9286	2.8750	1.5313
8301	1852	20092	N/A	t	2.5443	1.7000	3.1442	2.1300
8303	1854	20092	N/A	t	2.5671	2.3333	3.4914	1.9324
8304	1855	20092	N/A	t	2.0938	2.1250	2.2813	2.0400
8306	1856	20092	N/A	t	2.0023	2.3750	2.4405	1.8897
8307	1895	20092	N/A	t	2.8194	2.7083	3.7500	2.3750
8308	1896	20092	N/A	t	2.7569	3.0139	4.0000	2.8750
8310	1897	20092	N/A	t	2.2721	1.9737	3.0000	1.0000
8311	1859	20092	N/A	t	1.8090	1.9737	2.2639	1.5313
8312	1860	20092	N/A	t	2.4965	2.7237	3.1250	2.2188
8314	1861	20092	N/A	t	2.5169	3.3421	3.6827	2.7500
8315	1862	20092	N/A	t	2.5704	2.7778	3.1250	2.9531
8316	1863	20092	N/A	t	2.9472	3.3472	3.2500	3.2188
8318	1899	20092	N/A	t	2.2344	2.2941	2.7500	2.5000
8319	1900	20092	N/A	t	2.2230	2.4405	2.5000	2.5192
8320	1865	20092	N/A	t	2.0870	2.2632	2.2917	1.1406
8322	1866	20092	N/A	t	2.6507	3.3833	3.2500	2.2500
8323	1867	20092	N/A	t	2.7955	3.0500	3.0625	2.5000
8325	1903	20092	N/A	t	2.1250	2.9583	2.5000	2.7885
8326	1868	20092	N/A	t	2.2743	2.6974	2.4444	2.3125
8327	2003	20092	N/A	t	3.1333	3.1333	3.0000	2.2500
8329	1870	20092	N/A	t	2.7601	2.8056	3.7500	2.6538
8330	1871	20092	N/A	t	2.3623	3.4605	2.6190	2.2115
8331	1872	20092	N/A	t	1.8090	1.9844	1.9444	1.3906
8333	1873	20092	N/A	t	1.9493	3.1000	2.3056	2.8281
8334	1874	20092	N/A	t	2.4261	2.8438	3.2500	2.9531
8335	1875	20092	N/A	t	2.4891	3.1719	2.8810	2.5577
8337	1877	20092	N/A	t	2.9007	3.0417	2.8750	3.1875
8338	1878	20092	N/A	t	2.3521	2.2969	3.2500	2.0156
8339	1904	20092	N/A	t	2.1544	2.1316	2.9063	2.0833
8341	1905	20092	N/A	t	2.0735	2.0938	2.6563	2.0833
8342	1880	20092	N/A	t	2.3299	3.0250	2.5833	3.1842
8344	1882	20092	N/A	t	2.1007	2.7500	2.3750	2.0968
8345	1883	20092	N/A	t	2.2222	2.3289	2.5278	2.3281
8346	1884	20092	N/A	t	2.2717	2.8684	2.9306	2.6094
8348	2005	20092	N/A	t	2.1842	2.1842	2.7500	2.2500
8349	1906	20092	N/A	t	1.5878	1.3421	1.7500	1.2250
8350	1886	20092	N/A	t	2.4367	3.5000	2.3810	2.5385
8352	1888	20092	N/A	t	2.4595	2.1548	3.2500	2.5250
8353	1889	20092	N/A	t	2.2967	2.7344	2.3611	2.6094
8354	1890	20092	N/A	t	2.4848	3.2188	2.0278	2.4063
8356	1907	20092	N/A	t	1.5662	1.5588	1.5000	1.0000
8357	1908	20092	N/A	t	1.8015	1.9559	1.6250	2.0000
8360	1911	20092	N/A	t	1.7823	2.0893	2.3750	1.7500
8361	1912	20092	N/A	t	1.8986	1.9000	2.3750	1.5000
8363	1914	20092	N/A	t	2.2426	2.2206	2.3750	2.6250
8364	1915	20092	N/A	t	2.0074	2.2059	2.6250	2.6250
8366	1917	20092	N/A	t	1.7941	1.8971	2.8750	1.1250
8367	1918	20092	N/A	t	2.1029	2.1176	2.8750	2.2500
8368	1919	20092	N/A	t	2.6290	2.2143	3.8750	2.7500
8370	1921	20092	N/A	t	1.7794	1.8824	2.3750	1.2500
8371	1922	20092	N/A	t	1.4191	1.4412	1.3750	1.1250
8372	1923	20092	N/A	t	1.6250	1.7941	2.0000	1.0000
8374	1925	20092	N/A	t	2.1486	2.3375	3.7500	2.1250
8375	1926	20092	N/A	t	1.7206	1.7059	1.8750	2.0000
8376	1927	20092	N/A	t	1.9191	1.8971	2.6250	1.3750
8378	1929	20092	N/A	t	2.4779	2.1618	2.8750	3.1250
8379	1930	20092	N/A	t	2.1544	2.0882	2.3750	2.2500
8380	1931	20092	N/A	t	1.6176	1.7647	1.3750	1.5000
8382	1933	20092	N/A	t	1.7647	1.8824	1.8750	1.7500
8383	1934	20092	N/A	t	2.2868	2.2206	2.7500	2.6250
8385	1936	20092	N/A	t	2.0588	1.8088	2.5000	2.2500
8386	1937	20092	N/A	t	2.5662	2.1618	4.0000	2.7500
8387	1938	20092	N/A	t	2.0441	2.2941	2.3750	2.3750
8389	1940	20092	N/A	t	1.8676	1.8235	2.3750	1.5000
8390	1941	20092	N/A	t	1.6250	1.7206	2.0000	1.6250
8391	1942	20092	N/A	t	2.3871	3.0893	3.1250	2.1250
8393	1944	20092	N/A	t	2.3162	2.0735	3.0000	2.8750
8394	1945	20092	N/A	t	2.0809	1.9853	2.8750	1.2500
8395	1946	20092	N/A	t	1.8382	1.6912	2.5000	1.0000
8397	1948	20092	N/A	t	1.6875	1.6324	1.3125	1.7500
8398	1949	20092	N/A	t	1.6618	1.8088	2.5000	1.1250
8399	1950	20092	N/A	t	2.2647	2.1324	2.7500	2.0000
8401	1952	20092	N/A	t	1.7279	1.8676	2.5000	1.0000
8402	1953	20092	N/A	t	2.1103	2.0735	2.7500	2.6250
8403	1954	20092	N/A	t	1.7574	2.0000	2.0000	2.1250
8405	1956	20092	N/A	t	2.1757	2.0750	2.8750	2.0000
8406	1957	20092	N/A	t	2.3382	2.5000	2.6250	2.6250
8407	1958	20092	N/A	t	1.5147	1.5588	2.0000	1.0000
8409	1960	20092	N/A	t	2.1029	2.4412	3.6250	1.6250
8410	1961	20092	N/A	t	1.6838	1.9412	2.1250	2.0000
8412	1963	20092	N/A	t	2.1471	2.1324	2.5000	1.5000
8413	1964	20092	N/A	t	1.2500	1.2941	1.1563	1.0000
8414	1965	20092	N/A	t	1.3088	1.3529	1.3750	1.2500
8416	1967	20092	N/A	t	2.0956	2.4706	2.6250	1.5000
8417	1968	20092	N/A	t	2.0441	2.2500	2.3750	2.1250
8418	1969	20092	N/A	t	1.9559	1.8824	2.7500	1.1250
8420	1971	20092	N/A	t	2.2903	2.3393	2.3750	2.7500
8421	1972	20092	N/A	t	1.4265	1.6176	1.6250	1.0000
8423	1974	20092	N/A	t	2.1765	1.9559	2.3750	2.3750
8424	1975	20092	N/A	t	2.0441	1.7059	2.7500	2.0000
8425	1976	20092	N/A	t	2.6985	2.2059	4.0000	2.3750
8426	1977	20092	N/A	t	1.3162	1.2941	1.2500	1.0000
8428	1979	20092	N/A	t	1.9265	2.2647	2.1250	1.8750
8429	1980	20092	N/A	t	2.0368	2.5294	3.2500	1.5000
8431	1982	20092	N/A	t	2.0882	2.1324	2.7500	2.0000
8432	1983	20092	N/A	t	2.4412	2.7500	3.8750	1.8750
8433	1984	20092	N/A	t	1.7365	1.7500	2.3750	1.6250
8435	1986	20092	N/A	t	2.3676	2.3971	2.5000	2.5000
8436	1987	20092	N/A	t	2.5441	3.1912	3.6250	2.8750
8437	1988	20092	N/A	t	2.3971	2.6618	3.8750	1.2500
8439	1990	20092	N/A	t	1.8382	1.9706	2.5000	1.7500
8440	1991	20092	N/A	t	1.9559	1.8971	2.3750	1.1250
8442	1993	20092	N/A	t	2.1471	1.9559	2.8750	1.5000
8443	1994	20092	N/A	t	2.2759	2.3125	3.0000	2.7500
8444	1995	20092	N/A	t	1.7500	1.6912	2.5000	1.5000
8446	1997	20092	N/A	t	2.0588	2.2206	2.8750	2.0000
8447	1998	20092	N/A	t	2.3162	2.5735	3.7500	2.0000
8448	1999	20092	N/A	t	2.4706	2.0735	3.0000	3.0000
8450	2001	20092	N/A	t	2.5147	2.8824	2.6250	2.1250
8451	2002	20092	N/A	t	1.4779	1.4412	2.2500	1.0625
8452	1833	20093	N/A	t	3.0898	1.9250	3.5069	3.2838
8454	1838	20093	N/A	t	2.3942	1.5000	3.0577	1.9878
8455	1839	20093	N/A	t	2.3607	1.8750	2.9231	2.5326
8456	1841	20093	N/A	t	2.5659	5.0000	2.9792	2.7636
8458	1845	20093	N/A	t	2.3451	1.5000	2.1591	2.1744
8459	1842	20093	N/A	t	2.5259	1.0000	2.6635	2.1830
8461	1846	20093	N/A	t	2.3455	3.2500	3.1207	1.8790
8462	1847	20093	N/A	t	2.1987	2.1250	2.4762	1.9632
8463	1849	20093	N/A	t	2.8662	2.6250	3.6207	2.5341
8465	1851	20093	N/A	t	2.8686	3.5000	2.8750	1.5313
8466	1854	20093	N/A	t	2.5373	2.0000	3.4914	1.9324
8467	1892	20093	N/A	t	2.5395	1.2500	3.1579	2.8462
8469	1860	20093	N/A	t	2.4199	1.5000	2.8571	2.2188
8470	1898	20093	N/A	t	2.2692	2.0000	2.5769	2.7500
8471	1862	20093	N/A	t	2.7208	4.5000	3.3696	2.9531
8473	1899	20093	N/A	t	2.4714	5.0000	2.7500	3.3333
8474	1900	20093	N/A	t	2.2560	2.5000	2.5000	2.5192
8475	1901	20093	N/A	t	2.3625	1.7500	2.7188	2.3750
8477	1902	20093	N/A	t	2.5347	2.7500	2.7500	2.3654
8478	1903	20093	N/A	t	2.1855	2.7500	2.5938	2.7885
8479	1869	20093	N/A	t	2.6928	2.0000	3.5192	2.6719
8481	1872	20093	N/A	t	1.7767	1.5000	1.9444	1.3906
8482	1873	20093	N/A	t	1.9201	3.1250	2.3056	2.9091
8484	1876	20093	N/A	t	2.5856	1.7500	3.1957	2.8289
8485	1878	20093	N/A	t	2.3636	2.5000	3.2174	2.0156
8486	1879	20093	N/A	t	2.4660	2.6250	3.1310	2.4531
8488	1883	20093	N/A	t	2.1667	1.5000	2.5278	2.3281
8489	1885	20093	N/A	t	2.8734	2.7500	3.0595	3.0938
8490	1906	20093	N/A	t	1.6000	3.3750	1.7500	2.0962
8492	1887	20093	N/A	t	2.2283	1.7500	1.8472	2.5000
8493	1888	20093	N/A	t	2.4416	3.5000	3.2500	2.8906
7833	1831	20032	N/A	t	2.6492	2.1563	3.0000	3.2813
7864	1832	20052	N/A	t	2.8479	2.2105	3.0417	2.7902
7814	1830	19991	N/A	t	1.8804	1.8804	1.0000	0.0000
7868	1837	20052	N/A	t	1.9929	2.0556	2.1250	1.1250
7815	1830	20001	N/A	t	1.8841	1.8889	1.5000	1.5000
7821	1830	20021	N/A	t	2.7050	3.0500	2.5227	3.3500
7826	1832	20022	N/A	t	2.3824	2.5147	2.6250	2.6250
7829	1832	20031	N/A	t	2.4717	2.6316	2.6667	2.5750
7837	1831	20033	N/A	t	2.5341	2.2500	3.0000	2.9063
7841	1831	20041	N/A	t	2.6429	3.0417	3.0000	3.1200
7845	1835	20041	N/A	t	1.7059	1.7059	2.5000	1.0000
7872	1837	20053	N/A	t	1.9756	1.8750	2.1538	1.1250
7849	1834	20042	N/A	t	2.7418	3.9375	3.5096	2.9167
7852	1832	20043	N/A	t	2.9531	1.5000	3.0417	3.4643
7856	1831	20051	N/A	t	2.5294	2.2895	3.0000	2.6887
7860	1835	20051	N/A	t	1.9900	2.1316	2.5000	1.4038
7875	1836	20061	N/A	t	2.9279	3.9375	3.5000	2.2500
7879	1840	20061	N/A	t	1.8676	1.8676	2.7500	2.2500
7883	1832	20062	N/A	t	2.7950	3.0000	3.0417	2.7610
7887	1837	20062	N/A	t	2.1184	2.2917	2.2656	1.9091
7891	1841	20062	N/A	t	2.2279	2.2059	3.0000	2.2500
7895	1836	20063	N/A	t	3.0599	3.0000	3.4000	2.4231
7902	1834	20071	N/A	t	2.6520	3.2500	3.4643	3.0690
7899	1841	20063	N/A	t	2.2566	2.5000	3.0000	2.2500
7906	1838	20071	N/A	t	2.6550	2.9375	3.5000	2.2750
7910	1844	20071	N/A	t	2.3333	2.3333	2.2500	3.0000
7912	1842	20071	N/A	t	2.2457	2.2632	2.7500	1.3750
7915	1847	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
8494	1907	20093	N/A	t	1.5655	1.5625	1.5833	1.0000
8495	1912	20093	N/A	t	1.8056	1.3750	1.9167	1.5000
7916	1848	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
8496	1913	20093	N/A	t	2.2692	2.0000	2.2500	3.6250
8497	1917	20093	N/A	t	1.9167	2.7500	2.8333	1.1250
8498	1919	20093	N/A	t	2.5676	2.2500	3.8750	2.7500
8499	1924	20093	N/A	t	2.8526	2.5000	3.4167	2.7500
8500	1926	20093	N/A	t	1.6603	1.2500	1.6667	2.0000
8501	1927	20093	N/A	t	1.9615	2.2500	2.5000	1.3750
8502	1929	20093	N/A	t	2.4487	2.2500	2.6667	3.1250
8503	1930	20093	N/A	t	2.1346	2.0000	2.2500	2.2500
8504	1931	20093	N/A	t	1.6000	1.5000	1.3750	1.5000
8505	1932	20093	N/A	t	1.8846	1.0000	1.7500	3.7500
8506	1933	20093	N/A	t	1.7628	1.7500	1.8333	1.7500
8507	1936	20093	N/A	t	2.1154	2.5000	2.5000	2.2500
8508	1939	20093	N/A	t	1.6250	1.7500	1.6250	1.3750
8509	1940	20093	N/A	t	1.7750	1.2500	2.3750	1.5000
8510	1942	20093	N/A	t	2.2647	1.0000	3.1250	2.1250
8511	1943	20093	N/A	t	2.6603	5.0000	4.1667	2.2500
8512	1944	20093	N/A	t	2.2703	3.3750	3.0000	3.1250
8513	1945	20093	N/A	t	2.0705	2.0000	2.5833	1.2500
8514	1947	20093	N/A	t	2.1987	1.5000	2.6667	1.8750
8515	1948	20093	N/A	t	1.6284	1.2500	1.2885	1.7500
8516	1957	20093	N/A	t	2.2949	2.0000	2.4167	2.6250
8517	1958	20093	N/A	t	1.4563	1.1250	2.0000	1.0625
8518	1959	20093	N/A	t	2.4744	2.7500	3.5833	1.8750
8520	1964	20093	N/A	t	1.2162	1.0000	1.0962	1.0000
8521	1965	20093	N/A	t	1.2692	1.0000	1.2500	1.2500
8522	1967	20093	N/A	t	2.2115	3.0000	2.7500	1.5000
8524	1969	20093	N/A	t	1.8974	1.5000	2.3333	1.1250
8525	1971	20093	N/A	t	2.3542	2.7500	2.5000	2.7500
8526	1973	20093	N/A	t	1.9295	2.0000	2.1667	2.1250
8528	1975	20093	N/A	t	2.0385	2.0000	2.5000	2.0000
8529	1976	20093	N/A	t	2.6090	2.0000	3.3333	2.3750
8530	1977	20093	N/A	t	1.2688	1.0000	1.2500	1.0000
8532	1980	20093	N/A	t	1.9038	1.0000	2.5000	1.5000
8533	1983	20093	N/A	t	2.4487	2.5000	3.4167	1.8750
8535	1986	20093	N/A	t	2.3036	2.0313	2.5000	2.5000
8536	1987	20093	N/A	t	2.4744	2.0000	3.0833	2.8750
8537	1988	20093	N/A	t	2.3462	2.0000	3.2500	1.2500
8539	1990	20093	N/A	t	1.7905	1.2500	2.5000	1.7500
8540	1991	20093	N/A	t	1.9615	2.0000	2.2500	1.1250
8541	1992	20093	N/A	t	2.5256	5.0000	4.1667	1.2500
8543	1994	20093	N/A	t	2.6765	5.0000	4.0000	2.7500
8544	1995	20093	N/A	t	1.7500	1.7500	2.2500	1.5000
8545	1998	20093	N/A	t	2.2115	1.5000	3.0000	2.0000
8547	2000	20093	N/A	t	1.7756	1.0000	1.9167	1.7500
8548	2001	20093	N/A	t	2.4808	2.2500	2.5000	2.1250
8550	1836	20101	N/A	t	3.0000	3.0357	3.3226	2.9824
8551	1837	20101	N/A	t	2.0634	1.5000	2.2656	1.8482
8552	1838	20101	N/A	t	2.4243	2.7500	3.0577	2.1604
8554	1841	20101	N/A	t	2.5382	2.2083	2.9792	2.7276
8555	1893	20101	N/A	t	2.5306	3.5833	0.0000	2.5608
8556	1844	20101	N/A	t	2.6719	3.0625	3.0952	2.9338
8558	1842	20101	N/A	t	2.5760	5.0000	2.6635	2.1830
8559	1843	20101	N/A	t	2.6062	2.9375	3.0417	2.2545
8560	1846	20101	N/A	t	2.4316	2.9583	3.1207	2.0349
8562	1894	20101	N/A	t	2.2959	2.2500	2.2500	2.1923
8563	1847	20101	N/A	t	2.2898	2.8333	2.4762	2.0969
8564	1848	20101	N/A	t	2.5289	2.1250	2.7500	2.4628
8566	1850	20101	N/A	t	2.4190	2.5000	2.9643	2.3041
8567	1851	20101	N/A	t	2.8477	3.1250	3.0473	1.6447
8569	1853	20101	N/A	t	2.2750	2.0000	2.3646	1.9620
8570	1854	20101	N/A	t	2.6093	3.0000	3.4914	2.1683
8571	1855	20101	N/A	t	2.0469	1.8026	2.2813	1.9375
8573	1856	20101	N/A	t	2.1329	2.9167	2.4405	2.2449
8574	1895	20101	N/A	t	2.5441	1.8833	3.5000	1.7692
8575	1896	20101	N/A	t	2.6625	2.4605	3.4861	2.7885
8577	1897	20101	N/A	t	2.2170	2.1184	3.0000	1.7750
8578	2006	20101	N/A	t	2.9167	2.9167	2.7500	3.0000
8579	1859	20101	N/A	t	1.7472	1.5000	2.2639	1.4919
7917	1849	20071	N/A	t	3.2794	3.2794	5.0000	2.0000
8109	1886	20083	N/A	t	1.9709	2.3611	1.8333	1.5000
7918	1850	20071	N/A	t	2.2059	2.2059	3.0000	1.7500
7932	1840	20072	N/A	t	2.3867	3.3158	3.1905	2.6923
7936	1842	20072	N/A	t	2.2979	2.5000	2.6635	1.6923
7940	1848	20072	N/A	t	2.3162	2.5588	2.2500	1.8750
7944	1852	20072	N/A	t	2.4632	2.9706	3.8750	1.7500
7948	1856	20072	N/A	t	1.6912	1.6618	2.3750	1.1250
8112	1889	20083	N/A	t	2.0513	1.7500	2.3333	2.2500
7950	1837	20073	N/A	t	2.1071	0.0000	2.2656	2.0058
8117	1838	20091	N/A	t	2.5045	1.9231	3.0577	2.1827
7951	1838	20073	N/A	t	2.5933	2.3571	3.5000	2.2750
7954	1844	20073	N/A	t	3.1026	2.1250	3.6250	4.0000
7957	1846	20073	N/A	t	2.1090	1.7500	3.0833	1.5000
7962	1834	20081	N/A	t	2.6061	2.7917	3.4643	2.8000
7965	1838	20081	N/A	t	2.6042	2.6471	3.1875	2.2692
7969	1844	20081	N/A	t	2.8611	2.2333	3.3333	3.0833
7973	1846	20081	N/A	t	2.1591	2.2813	2.9891	1.4000
7976	1848	20081	N/A	t	2.3942	2.7500	2.5000	1.8750
7980	1852	20081	N/A	t	2.3448	2.2237	3.1875	1.9500
7984	1856	20081	N/A	t	1.8160	2.0395	2.4167	1.1750
7988	1861	20081	N/A	t	2.0294	2.0294	3.0000	2.2500
7992	1865	20081	N/A	t	2.0882	2.0882	2.0000	1.0000
8120	1841	20091	N/A	t	2.5085	2.5000	2.9792	2.6750
7996	1869	20081	N/A	t	3.1471	3.1471	5.0000	2.5000
8124	1842	20091	N/A	t	2.5704	2.7500	2.6635	2.3163
8000	1873	20081	N/A	t	1.6765	1.6765	2.2500	1.0000
8003	1876	20081	N/A	t	2.0882	2.0882	2.7500	1.0000
8007	1880	20081	N/A	t	3.0588	3.0588	2.7500	5.0000
8011	1884	20081	N/A	t	2.2941	2.2941	3.0000	2.2500
8128	1894	20091	N/A	t	2.0500	2.0500	2.2500	2.0000
8015	1888	20081	N/A	t	2.3824	2.3824	3.0000	2.0000
8019	1833	20082	N/A	t	3.0301	3.0769	3.3083	3.0000
8022	1837	20082	N/A	t	2.0763	1.8750	2.2656	1.8679
8026	1841	20082	N/A	t	2.5381	2.8500	2.9792	2.7500
8030	1843	20082	N/A	t	2.5236	2.9500	3.0417	2.4113
8033	1847	20082	N/A	t	2.1667	2.3289	2.4762	1.7308
8037	1851	20082	N/A	t	2.7266	2.0313	3.0543	1.4167
8041	1855	20082	N/A	t	2.0978	2.1563	2.2143	2.1000
8045	1859	20082	N/A	t	1.6985	1.6029	2.2500	1.1250
8049	1863	20082	N/A	t	2.5588	2.7206	3.0000	2.8750
8052	1866	20082	N/A	t	2.0809	2.1324	2.5000	2.3750
8056	1870	20082	N/A	t	3.0735	3.3676	4.0000	2.2500
8060	1874	20082	N/A	t	2.1176	2.0882	2.6250	1.8750
8064	1878	20082	N/A	t	2.3952	1.8824	3.7500	1.7500
8068	1882	20082	N/A	t	1.9559	2.0294	2.3750	1.0000
8071	1885	20082	N/A	t	2.5294	2.5735	2.7500	2.6250
8075	1889	20082	N/A	t	2.0956	2.3676	2.6250	2.2500
8079	1834	20083	N/A	t	2.5451	2.0000	3.4643	2.7264
8083	1842	20083	N/A	t	2.4917	2.1667	2.6635	2.2568
8132	1850	20091	N/A	t	2.4321	2.5000	2.9643	2.2344
8086	1848	20083	N/A	t	2.5616	2.7500	2.7500	2.9423
8136	1854	20091	N/A	t	2.6139	3.4167	3.4914	1.7500
8087	1849	20083	N/A	t	2.7571	2.7500	3.3750	2.4423
8090	1853	20083	N/A	t	2.3000	3.7500	2.3646	1.8654
8093	1861	20083	N/A	t	2.4167	2.7500	3.5833	2.1250
8097	1869	20083	N/A	t	2.7692	2.7500	3.5000	3.2500
8101	1874	20083	N/A	t	2.4872	5.0000	3.4167	1.8750
8105	1880	20083	N/A	t	2.2297	1.6563	2.2500	3.1250
8201	1922	20091	N/A	t	1.3971	1.3971	1.0000	1.0000
8140	1895	20091	N/A	t	2.9306	2.9306	5.0000	1.7500
8144	1859	20091	N/A	t	1.7500	1.8421	2.1667	1.1750
8147	1861	20091	N/A	t	2.3233	2.1316	3.4375	2.0750
8152	1900	20091	N/A	t	1.9375	1.9375	0.0000	3.0000
8155	1866	20091	N/A	t	2.4434	3.0921	3.3333	2.0250
8159	1868	20091	N/A	t	2.1226	2.1316	2.3333	2.2000
8163	1872	20091	N/A	t	1.7589	1.4412	2.0833	1.2500
8166	1875	20091	N/A	t	2.2830	2.5526	2.8333	1.8250
8170	1904	20091	N/A	t	2.1833	2.1833	3.0000	1.5000
8174	1881	20091	N/A	t	2.5647	2.5132	3.4375	2.6000
8178	1885	20091	N/A	t	2.6830	2.8971	3.1944	2.7750
8182	1888	20091	N/A	t	2.5802	2.2857	3.5833	2.5250
8185	1891	20091	N/A	t	2.6276	2.8000	3.5833	3.5833
8245	1966	20091	N/A	t	1.2647	1.2647	1.0000	1.0000
8190	1911	20091	N/A	t	1.5294	1.5294	1.7500	1.7500
8193	1914	20091	N/A	t	2.2647	2.2647	2.0000	2.7500
8197	1918	20091	N/A	t	2.0882	2.0882	2.7500	2.5000
8205	1926	20091	N/A	t	1.7353	1.7353	2.0000	1.7500
8223	1944	20091	N/A	t	2.5588	2.5588	3.0000	3.0000
8209	1930	20091	N/A	t	2.2206	2.2206	2.0000	2.5000
8212	1933	20091	N/A	t	1.6471	1.6471	2.0000	1.7500
8216	1937	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
8220	1941	20091	N/A	t	1.5294	1.5294	1.7500	1.5000
8226	1947	20091	N/A	t	2.1912	2.1912	2.5000	1.7500
8222	1943	20091	N/A	t	2.7059	2.7059	5.0000	2.0000
8256	1977	20091	N/A	t	1.3382	1.3382	1.2500	1.0000
8230	1951	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
8233	1954	20091	N/A	t	1.5147	1.5147	1.2500	1.5000
8237	1958	20091	N/A	t	1.4706	1.4706	2.0000	1.0000
8241	1962	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
8249	1970	20091	N/A	t	1.3529	1.3529	1.0000	1.5000
8252	1973	20091	N/A	t	2.0735	2.0735	2.2500	2.2500
8260	1981	20091	N/A	t	1.3824	1.3824	1.2500	1.0000
8264	1985	20091	N/A	t	1.8971	1.8971	3.0000	2.0000
8268	1989	20091	N/A	t	2.4265	2.4265	3.0000	2.7500
8272	1993	20091	N/A	t	2.3382	2.3382	3.0000	1.7500
8275	1996	20091	N/A	t	2.3088	2.3088	2.7500	2.2500
8279	2000	20091	N/A	t	1.6176	1.6176	1.7500	1.7500
8283	1836	20092	N/A	t	3.0171	2.0357	3.3226	3.0224
8286	1840	20092	N/A	t	2.4675	2.2500	3.1667	2.7500
8290	1845	20092	N/A	t	2.3736	1.8750	2.1591	2.2250
8294	1857	20092	N/A	t	2.4286	2.4583	3.1316	2.2237
8298	1849	20092	N/A	t	2.8817	3.1538	3.7500	2.5341
8302	1853	20092	N/A	t	2.3143	1.9000	2.3646	1.9485
8305	1892	20092	N/A	t	2.6111	2.9219	3.1579	2.8462
8309	1858	20092	N/A	t	2.2857	3.4265	2.6111	2.4219
8313	1898	20092	N/A	t	2.3182	3.0417	2.7500	3.0000
8317	1864	20092	N/A	t	2.2992	2.8906	3.1250	2.2188
8321	1901	20092	N/A	t	2.4122	2.3553	2.7188	2.5833
8324	1902	20092	N/A	t	2.5000	2.3684	2.7500	2.3654
8328	1869	20092	N/A	t	2.7468	3.0375	3.5192	2.6719
8332	2004	20092	N/A	t	2.2500	2.2500	3.0000	2.5000
8336	1876	20092	N/A	t	2.6604	3.2250	3.3750	3.0781
8340	1879	20092	N/A	t	2.4533	3.1316	3.1944	2.4531
8343	1881	20092	N/A	t	2.5507	2.8947	3.3804	3.1250
8347	1885	20092	N/A	t	2.8800	3.4605	3.0595	3.0938
8351	1887	20092	N/A	t	2.2500	2.0938	1.8472	2.5000
8355	1891	20092	N/A	t	2.5692	2.3906	3.5833	3.6000
8531	1978	20093	N/A	t	2.3333	2.2500	3.4167	2.0000
8358	1909	20092	N/A	t	1.9118	1.9265	2.3750	1.8750
8534	1984	20093	N/A	t	1.7381	1.7500	2.1667	1.6250
8359	1910	20092	N/A	t	2.2353	2.2353	2.5000	2.8750
8362	1913	20092	N/A	t	2.3088	1.8676	2.3750	3.6250
8365	1916	20092	N/A	t	1.5000	1.5147	1.8750	1.2500
8369	1920	20092	N/A	t	1.9926	1.7941	2.5000	2.1250
8373	1924	20092	N/A	t	2.9044	2.7941	3.8750	2.7500
8377	1928	20092	N/A	t	1.4338	1.4265	1.5000	1.2500
8381	1932	20092	N/A	t	2.0147	2.4118	2.1250	3.7500
8384	1935	20092	N/A	t	1.9632	2.0735	2.2500	1.7500
8388	1939	20092	N/A	t	1.6029	1.8529	1.6250	1.3750
8392	1943	20092	N/A	t	2.3162	1.9265	3.7500	2.2500
8396	1947	20092	N/A	t	2.3015	2.4118	3.2500	1.8750
8400	1951	20092	N/A	t	1.8382	2.1912	2.1250	1.5000
8538	1989	20093	N/A	t	2.1857	1.3750	3.0000	2.8750
8404	1955	20092	N/A	t	1.5147	1.7647	2.0000	1.0000
8542	1993	20093	N/A	t	2.2564	3.0000	2.9167	1.5000
8408	1959	20092	N/A	t	2.4338	2.8824	4.0000	1.8750
8411	1962	20092	N/A	t	2.2794	2.2206	2.5000	2.6250
8415	1966	20092	N/A	t	1.4338	1.6029	1.1250	1.0000
8419	1970	20092	N/A	t	1.3971	1.4412	1.3750	1.3750
8422	1973	20092	N/A	t	1.9191	1.7647	2.2500	2.1250
8427	1978	20092	N/A	t	2.3456	2.6176	4.0000	2.0000
8430	1981	20092	N/A	t	1.3824	1.3824	1.2500	1.0000
8434	1985	20092	N/A	t	2.1397	2.3824	3.0000	1.7500
8438	1989	20092	N/A	t	2.3534	2.2500	3.0000	2.8750
8441	1992	20092	N/A	t	2.1618	1.6618	3.7500	1.2500
8445	1996	20092	N/A	t	2.7941	3.2794	3.8750	3.6250
8449	2000	20092	N/A	t	1.8897	2.1618	2.3750	1.7500
8453	1836	20093	N/A	t	2.9985	2.0000	3.3226	3.0224
8457	1893	20093	N/A	t	1.9194	1.7500	0.0000	2.0568
8460	1843	20093	N/A	t	2.5803	1.5000	3.0417	2.2972
8464	1850	20093	N/A	t	2.3844	1.7500	2.9643	2.2700
8468	1896	20093	N/A	t	2.7561	2.7500	3.5833	2.8750
8472	1863	20093	N/A	t	2.9219	2.7222	3.1000	3.2188
8476	1866	20093	N/A	t	2.6133	2.2500	2.9891	2.2500
8546	1999	20093	N/A	t	2.5385	3.0000	3.0000	3.0000
8480	1870	20093	N/A	t	2.7110	1.5000	3.7500	2.6538
8483	1874	20093	N/A	t	2.3885	1.5000	3.2500	2.7237
8487	1881	20093	N/A	t	2.5000	1.8750	3.3804	2.9474
8491	1886	20093	N/A	t	2.5353	5.0000	2.3810	3.0000
8519	1960	20093	N/A	t	1.9615	1.0000	2.7500	1.6250
8523	1968	20093	N/A	t	1.9250	1.2500	2.3750	2.1250
8527	1974	20093	N/A	t	2.0577	1.2500	2.0000	2.3750
8549	1833	20101	N/A	t	3.1624	3.8500	3.5069	3.3520
8553	1839	20101	N/A	t	2.3429	2.1250	2.9231	2.4279
8557	1845	20101	N/A	t	2.3905	2.7656	2.1591	2.3347
8561	1857	20101	N/A	t	2.3750	2.1667	3.1316	2.2581
8565	1849	20101	N/A	t	2.9956	3.8500	3.6207	2.8214
8568	1852	20101	N/A	t	2.6088	2.9500	3.1442	2.3919
8572	1892	20101	N/A	t	2.7397	3.4531	3.1579	2.6875
8576	1858	20101	N/A	t	2.3077	2.4000	2.6111	2.3553
8580	1860	20101	N/A	t	2.5057	2.8750	2.8571	2.6705
7822	1831	20021	N/A	t	3.0882	3.0882	3.0000	5.0000
7818	1830	20011	N/A	t	2.5036	3.6250	2.5227	3.5938
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

