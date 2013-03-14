--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.studentterms DROP CONSTRAINT studentterms_termid_fkey;
ALTER TABLE ONLY public.studentterms DROP CONSTRAINT studentterms_studentid_fkey;
ALTER TABLE ONLY public.students DROP CONSTRAINT students_personid_fkey;
ALTER TABLE ONLY public.students DROP CONSTRAINT students_curriculumid_fkey;
ALTER TABLE ONLY public.studentineligibilities DROP CONSTRAINT studentineligibilities_ineligibilityid_fkey;
ALTER TABLE ONLY public.studentclasses DROP CONSTRAINT studentclasses_studenttermid_fkey;
ALTER TABLE ONLY public.studentclasses DROP CONSTRAINT studentclasses_gradeid_fkey;
ALTER TABLE ONLY public.studentclasses DROP CONSTRAINT studentclasses_classid_fkey;
ALTER TABLE ONLY public.instructors DROP CONSTRAINT instructors_personid_fkey;
ALTER TABLE ONLY public.instructorclasses DROP CONSTRAINT instructorclasses_instructorid_fkey;
ALTER TABLE ONLY public.instructorclasses DROP CONSTRAINT instructorclasses_classid_fkey;
ALTER TABLE ONLY public.classes DROP CONSTRAINT classes_termid_fkey;
ALTER TABLE ONLY public.terms DROP CONSTRAINT terms_pkey;
ALTER TABLE ONLY public.studentterms DROP CONSTRAINT studentterms_pkey;
ALTER TABLE ONLY public.students DROP CONSTRAINT students_pkey;
ALTER TABLE ONLY public.studentclasses DROP CONSTRAINT studentclasses_pkey;
ALTER TABLE ONLY public.requirements DROP CONSTRAINT requirements_pkey;
ALTER TABLE ONLY public.persons DROP CONSTRAINT persons_pkey;
ALTER TABLE ONLY public.instructors DROP CONSTRAINT instructors_pkey;
ALTER TABLE ONLY public.instructorclasses DROP CONSTRAINT instructorclasses_pkey;
ALTER TABLE ONLY public.ineligibilities DROP CONSTRAINT ineligibilities_pkey;
ALTER TABLE ONLY public.grades DROP CONSTRAINT grades_pkey;
ALTER TABLE ONLY public.curricula DROP CONSTRAINT curricula_pkey;
ALTER TABLE ONLY public.courses DROP CONSTRAINT courses_pkey;
ALTER TABLE ONLY public.classes DROP CONSTRAINT classes_pkey;
ALTER TABLE public.terms ALTER COLUMN termid DROP DEFAULT;
ALTER TABLE public.studentterms ALTER COLUMN studenttermid DROP DEFAULT;
ALTER TABLE public.students ALTER COLUMN studentid DROP DEFAULT;
ALTER TABLE public.studentclasses ALTER COLUMN studentclassid DROP DEFAULT;
ALTER TABLE public.requirements ALTER COLUMN requirementid DROP DEFAULT;
ALTER TABLE public.persons ALTER COLUMN personid DROP DEFAULT;
ALTER TABLE public.instructors ALTER COLUMN instructorid DROP DEFAULT;
ALTER TABLE public.instructorclasses ALTER COLUMN instructorclassid DROP DEFAULT;
ALTER TABLE public.grades ALTER COLUMN gradeid DROP DEFAULT;
ALTER TABLE public.curricula ALTER COLUMN curriculumid DROP DEFAULT;
ALTER TABLE public.courses ALTER COLUMN courseid DROP DEFAULT;
ALTER TABLE public.classes ALTER COLUMN classid DROP DEFAULT;
DROP VIEW public.viewclasses;
DROP SEQUENCE public.terms_termid_seq;
DROP TABLE public.terms;
DROP SEQUENCE public.studentterms_studenttermid_seq;
DROP TABLE public.studentterms;
DROP SEQUENCE public.students_studentid_seq;
DROP TABLE public.students;
DROP TABLE public.studentineligibilities;
DROP SEQUENCE public.studentclasses_studentclassid_seq;
DROP TABLE public.studentclasses;
DROP SEQUENCE public.requirements_requirementid_seq;
DROP TABLE public.requirements;
DROP SEQUENCE public.persons_personid_seq;
DROP TABLE public.persons;
DROP SEQUENCE public.instructors_instructorid_seq;
DROP TABLE public.instructors;
DROP SEQUENCE public.instructorclasses_instructorclassid_seq;
DROP TABLE public.instructorclasses;
DROP TABLE public.ineligibilities;
DROP SEQUENCE public.grades_gradeid_seq;
DROP TABLE public.grades;
DROP TABLE public.eligtwicefailcourses;
DROP TABLE public.eligtwicefail;
DROP TABLE public.eligpasshalfmathcs;
DROP TABLE public.eligpasshalf;
DROP TABLE public.elig24unitspassing;
DROP SEQUENCE public.curricula_curriculumid_seq;
DROP TABLE public.curricula;
DROP SEQUENCE public.courses_courseid_seq;
DROP TABLE public.courses;
DROP SEQUENCE public.classes_classid_seq;
DROP TABLE public.classes;
DROP FUNCTION public.xovermsee_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xovermsee_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public.xoverfe_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xoverfe_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public.xovercs197_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xovercs197_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns2_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns2_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns1_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns1_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public.xcwa69(p_studentid integer, p_termid integer);
DROP FUNCTION public.xcwa69(p_studenttermid integer);
DROP FUNCTION public.mathgwa(p_studentid integer);
DROP FUNCTION public.gwa(p_studentid integer, p_termid integer);
DROP FUNCTION public.gwa(p_studenttermid integer);
DROP FUNCTION public.f_loadstudents_andineligible_year(p_termid integer, p_year character varying, p_yearid integer);
DROP FUNCTION public.f_loadstudents_andineligible_nosum(p_termid integer, p_year character varying);
DROP FUNCTION public.f_loadelig_twicefailsubjects(p_termid integer);
DROP FUNCTION public.f_getall_eligtwicefail();
DROP FUNCTION public.f_getall_eligpasshalfmathcs();
DROP FUNCTION public.f_getall_eligpasshalf();
DROP FUNCTION public.f_getall_24unitspassed();
DROP FUNCTION public.f_elig_twicefailsubjects(p_termid integer);
DROP FUNCTION public.f_elig_passhalfpersem(p_termid integer);
DROP FUNCTION public.f_elig_passhalf_mathcs_persem(p_termid integer);
DROP FUNCTION public.f_elig_24unitspassed_singleyear(p_year integer);
DROP FUNCTION public.f_elig_24unitspassed(p_year integer);
DROP FUNCTION public.csgwa(p_studentid integer);
DROP TYPE public.t_loadstudents_andineligible;
DROP TYPE public.t_elig_twicefailsubjects;
DROP TYPE public.t_elig_passhalfpersem;
DROP TYPE public.t_elig_passhalf_mathcs_persem;
DROP TYPE public.t_elig_24unitspassed;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

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
-- Name: f_elig_passhalf_mathcs_persem(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalf_mathcs_persem(p_termid integer) RETURNS SETOF t_elig_passhalf_mathcs_persem
    LANGUAGE sql
    AS $_$
	SELECT studentid, studenttermid, termid, failpercentage
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
		WHERE termid = $1) AS temp
	WHERE failpercentage > 0.5;
$_$;


ALTER FUNCTION public.f_elig_passhalf_mathcs_persem(p_termid integer) OWNER TO postgres;

--
-- Name: f_elig_passhalfpersem(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalfpersem(p_termid integer) RETURNS SETOF t_elig_passhalfpersem
    LANGUAGE sql
    AS $_$
	SELECT studentid, studenttermid, termid, failpercentage
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
		WHERE termid = $1) AS temp
	WHERE failpercentage > 0.5;
$_$;


ALTER FUNCTION public.f_elig_passhalfpersem(p_termid integer) OWNER TO postgres;

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
-- Name: viewclasses; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW viewclasses AS
    SELECT courses.coursename, grades.gradevalue, courses.credits, students.studentid, terms.termid, courses.domain, persons.lastname, persons.firstname, persons.middlename, grades.gradeid, students.studentno FROM (((((((students JOIN persons USING (personid)) JOIN studentterms USING (studentid)) JOIN terms USING (termid)) JOIN studentclasses USING (studenttermid)) JOIN grades USING (gradeid)) JOIN classes USING (classid)) JOIN courses USING (courseid));


ALTER TABLE public.viewclasses OWNER TO postgres;

--
-- Name: classid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY classes ALTER COLUMN classid SET DEFAULT nextval('classes_classid_seq'::regclass);


--
-- Name: courseid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY courses ALTER COLUMN courseid SET DEFAULT nextval('courses_courseid_seq'::regclass);


--
-- Name: curriculumid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY curricula ALTER COLUMN curriculumid SET DEFAULT nextval('curricula_curriculumid_seq'::regclass);


--
-- Name: gradeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY grades ALTER COLUMN gradeid SET DEFAULT nextval('grades_gradeid_seq'::regclass);


--
-- Name: instructorclassid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY instructorclasses ALTER COLUMN instructorclassid SET DEFAULT nextval('instructorclasses_instructorclassid_seq'::regclass);


--
-- Name: instructorid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY instructors ALTER COLUMN instructorid SET DEFAULT nextval('instructors_instructorid_seq'::regclass);


--
-- Name: personid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persons ALTER COLUMN personid SET DEFAULT nextval('persons_personid_seq'::regclass);


--
-- Name: requirementid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requirements ALTER COLUMN requirementid SET DEFAULT nextval('requirements_requirementid_seq'::regclass);


--
-- Name: studentclassid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentclasses ALTER COLUMN studentclassid SET DEFAULT nextval('studentclasses_studentclassid_seq'::regclass);


--
-- Name: studentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY students ALTER COLUMN studentid SET DEFAULT nextval('students_studentid_seq'::regclass);


--
-- Name: studenttermid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY studentterms ALTER COLUMN studenttermid SET DEFAULT nextval('studentterms_studenttermid_seq'::regclass);


--
-- Name: termid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY terms ALTER COLUMN termid SET DEFAULT nextval('terms_termid_seq'::regclass);


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: classes_classid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('classes_classid_seq', 13137, true);


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO courses VALUES (1, 'CS 11', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (2, 'CS 12', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (3, 'CS 21', 4, 'MAJ', NULL);
INSERT INTO courses VALUES (4, 'CS 30', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (5, 'CS 32', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (6, 'CS 140', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (7, 'CS 150', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (8, 'CS 135', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (9, 'CS 165', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (10, 'CS 191', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (11, 'CS 130', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (12, 'CS 192', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (13, 'CS 194', 1, 'MAJ', NULL);
INSERT INTO courses VALUES (14, 'CS 145', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (15, 'CS 153', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (16, 'CS 180', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (17, 'CS 131', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (18, 'CS 195', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (19, 'CS 133', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (20, 'CS 198', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (21, 'CS 196', 1, 'MAJ', NULL);
INSERT INTO courses VALUES (22, 'CS 199', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (23, 'CS 197', 3, 'C197', NULL);
INSERT INTO courses VALUES (24, 'CS 120', 3, 'CSE', NULL);
INSERT INTO courses VALUES (27, 'CS 173', 3, 'CSE', NULL);
INSERT INTO courses VALUES (28, 'CS 174', 3, 'CSE', NULL);
INSERT INTO courses VALUES (29, 'CS 175', 3, 'CSE', NULL);
INSERT INTO courses VALUES (30, 'CS 176', 3, 'CSE', NULL);
INSERT INTO courses VALUES (25, 'CS 171', 3, 'CSE', NULL);
INSERT INTO courses VALUES (26, 'CS 172', 3, 'CSE', NULL);
INSERT INTO courses VALUES (31, 'Comm 1', 3, 'AH', 'E');
INSERT INTO courses VALUES (32, 'Comm 2', 3, 'AH', 'E');
INSERT INTO courses VALUES (33, 'Hum 1', 3, 'AH', NULL);
INSERT INTO courses VALUES (34, 'Hum 2', 3, 'AH', NULL);
INSERT INTO courses VALUES (35, 'Aral Pil 12', 3, 'AH', 'P');
INSERT INTO courses VALUES (36, 'Art Stud 1', 3, 'AH', NULL);
INSERT INTO courses VALUES (37, 'Art Stud 2', 3, 'AH', NULL);
INSERT INTO courses VALUES (38, 'BC 10', 3, 'AH', NULL);
INSERT INTO courses VALUES (39, 'Comm 3', 3, 'AH', 'E');
INSERT INTO courses VALUES (40, 'CW 10', 3, 'AH', 'E');
INSERT INTO courses VALUES (41, 'Eng 1', 3, 'AH', 'E');
INSERT INTO courses VALUES (42, 'Eng 10', 3, 'AH', 'E');
INSERT INTO courses VALUES (43, 'Eng 11', 3, 'AH', 'E');
INSERT INTO courses VALUES (44, 'L Arch 1', 3, 'AH', NULL);
INSERT INTO courses VALUES (45, 'Eng 30', 3, 'AH', 'E');
INSERT INTO courses VALUES (46, 'EL 50', 3, 'AH', NULL);
INSERT INTO courses VALUES (47, 'FA 28', 3, 'AH', 'P');
INSERT INTO courses VALUES (48, 'FA 30', 3, 'AH', NULL);
INSERT INTO courses VALUES (49, 'Fil 25', 3, 'AH', NULL);
INSERT INTO courses VALUES (50, 'Fil 40', 3, 'AH', 'P');
INSERT INTO courses VALUES (51, 'Film 10', 3, 'AH', NULL);
INSERT INTO courses VALUES (52, 'Film 12', 3, 'AH', 'P');
INSERT INTO courses VALUES (53, 'Humad 1', 3, 'AH', 'P');
INSERT INTO courses VALUES (54, 'J 18', 3, 'AH', NULL);
INSERT INTO courses VALUES (55, 'Kom 1', 3, 'AH', 'E');
INSERT INTO courses VALUES (56, 'Kom 2', 3, 'AH', 'E');
INSERT INTO courses VALUES (57, 'MPs 10', 3, 'AH', 'P');
INSERT INTO courses VALUES (58, 'MuD 1', 3, 'AH', NULL);
INSERT INTO courses VALUES (59, 'MuL 9', 3, 'AH', 'P');
INSERT INTO courses VALUES (60, 'MuL 13', 3, 'AH', NULL);
INSERT INTO courses VALUES (61, 'Pan Pil 12', 3, 'AH', 'P');
INSERT INTO courses VALUES (62, 'Pan Pil 17', 3, 'AH', 'P');
INSERT INTO courses VALUES (63, 'Pan Pil 19', 3, 'AH', 'P');
INSERT INTO courses VALUES (64, 'Pan Pil 40', 3, 'AH', 'P');
INSERT INTO courses VALUES (65, 'Pan Pil 50', 3, 'AH', 'P');
INSERT INTO courses VALUES (66, 'SEA 30', 3, 'AH', NULL);
INSERT INTO courses VALUES (67, 'Theatre 10', 3, 'AH', NULL);
INSERT INTO courses VALUES (68, 'Theatre 11', 3, 'AH', 'P');
INSERT INTO courses VALUES (69, 'Theatre 12', 3, 'AH', NULL);
INSERT INTO courses VALUES (70, 'Bio 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (71, 'Chem 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (72, 'EEE 10', 3, 'MST', NULL);
INSERT INTO courses VALUES (73, 'Env Sci 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (74, 'ES 10', 3, 'MST', NULL);
INSERT INTO courses VALUES (75, 'GE 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (76, 'Geol 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (77, 'L Arch 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (78, 'Math 2', 3, 'MST', NULL);
INSERT INTO courses VALUES (79, 'MBB 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (80, 'MS 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (81, 'Nat Sci 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (82, 'Nat Sci 2', 3, 'MST', NULL);
INSERT INTO courses VALUES (83, 'Physics 10', 3, 'MST', NULL);
INSERT INTO courses VALUES (84, 'STS', 3, 'MST', NULL);
INSERT INTO courses VALUES (85, 'FN 1', 3, 'MST', NULL);
INSERT INTO courses VALUES (86, 'CE 10', 3, 'MST', NULL);
INSERT INTO courses VALUES (87, 'Anthro 10', 3, 'SSP', NULL);
INSERT INTO courses VALUES (88, 'Archaeo 2', 3, 'SSP', NULL);
INSERT INTO courses VALUES (89, 'Arkiyoloji 1', 3, 'SSP', 'P');
INSERT INTO courses VALUES (90, 'CE 10', 3, 'SSP', NULL);
INSERT INTO courses VALUES (91, 'Econ 11', 3, 'SSP', NULL);
INSERT INTO courses VALUES (92, 'Econ 31', 3, 'SSP', NULL);
INSERT INTO courses VALUES (93, 'Geog 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES (94, 'Kas 1', 3, 'SSP', 'P');
INSERT INTO courses VALUES (95, 'Kas 2', 3, 'SSP', NULL);
INSERT INTO courses VALUES (96, 'L Arch 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES (97, 'Lingg 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES (98, 'Philo 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES (99, 'Philo 10', 3, 'SSP', NULL);
INSERT INTO courses VALUES (100, 'Philo 11', 3, 'SSP', NULL);
INSERT INTO courses VALUES (101, 'SEA 30', 3, 'SSP', 'P');
INSERT INTO courses VALUES (102, 'Soc Sci 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES (103, 'Soc Sci 2', 3, 'SSP', NULL);
INSERT INTO courses VALUES (104, 'Soc Sci 3', 3, 'SSP', NULL);
INSERT INTO courses VALUES (105, 'Socio 10', 3, 'SSP', 'P');
INSERT INTO courses VALUES (106, 'Math 17', 5, 'MAJ', NULL);
INSERT INTO courses VALUES (107, 'Math 53', 5, 'MAJ', NULL);
INSERT INTO courses VALUES (108, 'Math 54', 5, 'MAJ', NULL);
INSERT INTO courses VALUES (109, 'Math 55', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (110, 'Physics 71', 4, 'MAJ', NULL);
INSERT INTO courses VALUES (111, 'Physics 72', 4, 'MAJ', NULL);
INSERT INTO courses VALUES (112, 'Stat 130', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (113, 'PI 100', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (114, 'EEE 8', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (115, 'EEE 9', 3, 'MAJ', NULL);
INSERT INTO courses VALUES (116, 'P E 2F', 3, 'FE', NULL);
INSERT INTO courses VALUES (117, 'MS', 3, 'FE', NULL);
INSERT INTO courses VALUES (118, 'Math 114', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (119, 'Math 157', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (120, 'CS 160', 3, 'CSE', NULL);
INSERT INTO courses VALUES (121, 'BA 101', 3, 'FE', NULL);
INSERT INTO courses VALUES (122, 'CS 155', 3, 'CSE', NULL);
INSERT INTO courses VALUES (123, 'Eng 12', 3, 'FE', NULL);
INSERT INTO courses VALUES (124, 'Anthro 185', 3, 'FE', NULL);
INSERT INTO courses VALUES (125, 'Span 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (126, 'Span 11', 3, 'FE', NULL);
INSERT INTO courses VALUES (127, 'Humanidades 1', 3, 'FE', NULL);
INSERT INTO courses VALUES (128, 'Russ 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (129, 'MS 102', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (130, 'Hapon 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (131, 'ES 204', 3, 'FE', NULL);
INSERT INTO courses VALUES (132, 'Psych 101', 3, 'FE', NULL);
INSERT INTO courses VALUES (133, 'ES 21', 3, 'FE', NULL);
INSERT INTO courses VALUES (134, 'Hapon 11', 3, 'FE', NULL);
INSERT INTO courses VALUES (135, 'French 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (136, 'Art Stud 194', 3, 'FE', NULL);
INSERT INTO courses VALUES (137, 'Ital 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (138, 'Geol 11', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (139, 'Hapon 12', 3, 'FE', NULL);
INSERT INTO courses VALUES (140, 'Hapon 13', 3, 'FE', NULL);
INSERT INTO courses VALUES (141, 'Econ 102', 3, 'FE', NULL);
INSERT INTO courses VALUES (142, 'CW 180', 3, 'FE', NULL);
INSERT INTO courses VALUES (143, 'Chem 16', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (144, 'Hapon 100', 3, 'FE', NULL);
INSERT INTO courses VALUES (145, 'Hapon 101', 3, 'FE', NULL);
INSERT INTO courses VALUES (146, 'EnE 31', 3, 'FE', NULL);
INSERT INTO courses VALUES (147, 'Intsik 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (148, 'Intsik 11', 3, 'FE', NULL);
INSERT INTO courses VALUES (149, 'French 11', 3, 'FE', NULL);
INSERT INTO courses VALUES (150, 'Koreyano 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (151, 'Math 197', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (152, 'VC 50', 3, 'FE', NULL);
INSERT INTO courses VALUES (153, 'Math 14', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (154, 'Math 121.1', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (155, 'MS 101', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (156, 'German 10', 3, 'FE', NULL);
INSERT INTO courses VALUES (157, 'IE 3', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (158, 'Theater 12', 3, 'FE', NULL);
INSERT INTO courses VALUES (159, 'Theater 11', 3, 'FE', NULL);
INSERT INTO courses VALUES (160, 'Philo 100', 3, 'FE', NULL);
INSERT INTO courses VALUES (161, 'Physics 71.1', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (162, 'Physics 73', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (163, 'POLSC 14', 3, 'FE', NULL);
INSERT INTO courses VALUES (164, 'Econ 100.1', 3, 'FE', NULL);
INSERT INTO courses VALUES (165, 'Math 109', 3, 'MSEE', NULL);
INSERT INTO courses VALUES (166, 'Thai 10', 3, 'FE', NULL);


--
-- Name: courses_courseid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('courses_courseid_seq', 1, false);


--
-- Data for Name: curricula; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO curricula VALUES (1, 'new');
INSERT INTO curricula VALUES (2, 'old');


--
-- Name: curricula_curriculumid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('curricula_curriculumid_seq', 4, true);


--
-- Data for Name: elig24unitspassing; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: eligpasshalf; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: eligpasshalfmathcs; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: eligtwicefail; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: eligtwicefailcourses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO eligtwicefailcourses VALUES (106);
INSERT INTO eligtwicefailcourses VALUES (107);
INSERT INTO eligtwicefailcourses VALUES (108);
INSERT INTO eligtwicefailcourses VALUES (109);
INSERT INTO eligtwicefailcourses VALUES (1);
INSERT INTO eligtwicefailcourses VALUES (2);
INSERT INTO eligtwicefailcourses VALUES (3);
INSERT INTO eligtwicefailcourses VALUES (5);


--
-- Data for Name: grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO grades VALUES (1, '1.00', 1.00);
INSERT INTO grades VALUES (2, '1.25', 1.25);
INSERT INTO grades VALUES (3, '1.50', 1.50);
INSERT INTO grades VALUES (4, '1.75', 1.75);
INSERT INTO grades VALUES (5, '2.00', 2.00);
INSERT INTO grades VALUES (6, '2.25', 2.25);
INSERT INTO grades VALUES (7, '2.50', 2.50);
INSERT INTO grades VALUES (8, '2.75', 2.75);
INSERT INTO grades VALUES (9, '3.00', 3.00);
INSERT INTO grades VALUES (10, '4.00', 4.00);
INSERT INTO grades VALUES (11, '5.00', 5.00);
INSERT INTO grades VALUES (12, 'INC', -1.00);
INSERT INTO grades VALUES (13, 'DRP', 0.00);
INSERT INTO grades VALUES (14, 'NG', -2.00);


--
-- Name: grades_gradeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('grades_gradeid_seq', 26, true);


--
-- Data for Name: ineligibilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO ineligibilities VALUES (1, 'Twice Fail Subject');
INSERT INTO ineligibilities VALUES (2, '50% Passing Subjects');
INSERT INTO ineligibilities VALUES (3, '50% Passing CS/Math');
INSERT INTO ineligibilities VALUES (4, '24 Units Passing per Year');


--
-- Data for Name: instructorclasses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: instructorclasses_instructorclassid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('instructorclasses_instructorclassid_seq', 95, true);


--
-- Data for Name: instructors; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: instructors_instructorid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('instructors_instructorid_seq', 10, true);


--
-- Data for Name: persons; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: persons_personid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('persons_personid_seq', 2016, true);


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: requirements_requirementid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('requirements_requirementid_seq', 1, false);


--
-- Data for Name: studentclasses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: studentclasses_studentclassid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 38075, true);


--
-- Data for Name: studentineligibilities; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: students_studentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('students_studentid_seq', 2006, true);


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: studentterms_studenttermid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 8580, true);


--
-- Data for Name: terms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO terms VALUES (20091, '1st Semester 2009-2010', '2009-2010', '1st');
INSERT INTO terms VALUES (20092, '2nd Semester 2009-2010', '2009-2010', '2nd');
INSERT INTO terms VALUES (20093, 'Summer Semester 2009-2010', '2009-2010', 'Sum');
INSERT INTO terms VALUES (20101, '1st Semester 2010-2011', '2010-2011', '1st');
INSERT INTO terms VALUES (20102, '2nd Semester 2010-2011', '2010-2011', '2nd');
INSERT INTO terms VALUES (20103, 'Summer Semester 2010-2011', '2010-2011', 'Sum');
INSERT INTO terms VALUES (20111, '1st Semester 2011-2012', '2011-2012', '1st');
INSERT INTO terms VALUES (20112, '2nd Semester 2011-2012', '2011-2012', '2nd');
INSERT INTO terms VALUES (20113, 'Summer Semester 2011-2012', '2011-2012', 'Sum');
INSERT INTO terms VALUES (20121, '1st Semester 2012-2013', '2012-2013', '1st');
INSERT INTO terms VALUES (20122, '2nd Semester 2012-2013', '2012-2013', '2nd');
INSERT INTO terms VALUES (20123, 'Summer Semester 2012-2013', '2012-2013', 'Sum');
INSERT INTO terms VALUES (20081, '1st Semester 2008-2009', '2008-2009', '1st');
INSERT INTO terms VALUES (20082, '2nd Semester 2008-2009', '2008-2009', '2nd');
INSERT INTO terms VALUES (20083, 'Summer 2008-2009', '2008-2009', 'Sum');
INSERT INTO terms VALUES (20131, '1st Semester 2013-2014', '2013-2014', '1st');
INSERT INTO terms VALUES (20132, '2nd Semester 2013-2014', '2013-2014', '2nd');
INSERT INTO terms VALUES (20133, 'Summer 2013-2014', '2013-2014', 'Sum');
INSERT INTO terms VALUES (19991, '1st Semester 1999-2000', '1999-2000', '1st');
INSERT INTO terms VALUES (20001, '1st Semester 2000-2001', '2000-2001', '1st');
INSERT INTO terms VALUES (20002, '2nd Semester 2000-2001', '2000-2001', '2nd');
INSERT INTO terms VALUES (20003, 'Summer 2000-2001', '2000-2001', 'Sum');
INSERT INTO terms VALUES (20011, '1st Semester 2001-2002', '2001-2002', '1st');
INSERT INTO terms VALUES (20012, '2nd Semester 2001-2002', '2001-2002', '2nd');
INSERT INTO terms VALUES (20013, 'Summer 2001-2002', '2001-2002', 'Sum');
INSERT INTO terms VALUES (20021, '1st Semester 2002-2003', '2002-2003', '1st');
INSERT INTO terms VALUES (20022, '2nd Semester 2002-2003', '2002-2003', '2nd');
INSERT INTO terms VALUES (20031, '1st Semester 2003-2004', '2003-2004', '1st');
INSERT INTO terms VALUES (20032, '2nd Semester 2003-2004', '2003-2004', '2nd');
INSERT INTO terms VALUES (20033, 'Summer 2003-2004', '2003-2004', 'Sum');
INSERT INTO terms VALUES (20041, '1st Semester 2004-2005', '2004-2005', '1st');
INSERT INTO terms VALUES (20042, '2nd Semester 2004-2005', '2004-2005', '2nd');
INSERT INTO terms VALUES (20043, 'Summer 2004-2005', '2004-2005', 'Sum');
INSERT INTO terms VALUES (20051, '1st Semester 2005-2006', '2005-2006', '1st');
INSERT INTO terms VALUES (20052, '2nd Semester 2005-2006', '2005-2006', '2nd');
INSERT INTO terms VALUES (20053, 'Summer 2005-2006', '2005-2006', 'Sum');
INSERT INTO terms VALUES (20061, '1st Semester 2006-2007', '2006-2007', '1st');
INSERT INTO terms VALUES (20062, '2nd Semester 2006-2007', '2006-2007', '2nd');
INSERT INTO terms VALUES (20063, 'Summer 2006-2007', '2006-2007', 'Sum');
INSERT INTO terms VALUES (20071, '1st Semester 2007-2008', '2007-2008', '1st');
INSERT INTO terms VALUES (20072, '2nd Semester 2007-2008', '2007-2008', '2nd');
INSERT INTO terms VALUES (20073, 'Summer 2007-2008', '2007-2008', 'Sum');


--
-- Name: terms_termid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('terms_termid_seq', 1, false);


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
-- Name: classes; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE classes FROM PUBLIC;
REVOKE ALL ON TABLE classes FROM postgres;
GRANT ALL ON TABLE classes TO postgres;


--
-- Name: courses; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE courses FROM PUBLIC;
REVOKE ALL ON TABLE courses FROM postgres;
GRANT ALL ON TABLE courses TO postgres;


--
-- Name: curricula; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE curricula FROM PUBLIC;
REVOKE ALL ON TABLE curricula FROM postgres;
GRANT ALL ON TABLE curricula TO postgres;


--
-- Name: elig24unitspassing; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE elig24unitspassing FROM PUBLIC;
REVOKE ALL ON TABLE elig24unitspassing FROM postgres;
GRANT ALL ON TABLE elig24unitspassing TO postgres;


--
-- Name: eligpasshalf; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE eligpasshalf FROM PUBLIC;
REVOKE ALL ON TABLE eligpasshalf FROM postgres;
GRANT ALL ON TABLE eligpasshalf TO postgres;


--
-- Name: eligpasshalfmathcs; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE eligpasshalfmathcs FROM PUBLIC;
REVOKE ALL ON TABLE eligpasshalfmathcs FROM postgres;
GRANT ALL ON TABLE eligpasshalfmathcs TO postgres;


--
-- Name: eligtwicefail; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE eligtwicefail FROM PUBLIC;
REVOKE ALL ON TABLE eligtwicefail FROM postgres;
GRANT ALL ON TABLE eligtwicefail TO postgres;


--
-- Name: eligtwicefailcourses; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE eligtwicefailcourses FROM PUBLIC;
REVOKE ALL ON TABLE eligtwicefailcourses FROM postgres;
GRANT ALL ON TABLE eligtwicefailcourses TO postgres;


--
-- Name: grades; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE grades FROM PUBLIC;
REVOKE ALL ON TABLE grades FROM postgres;
GRANT ALL ON TABLE grades TO postgres;


--
-- Name: ineligibilities; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ineligibilities FROM PUBLIC;
REVOKE ALL ON TABLE ineligibilities FROM postgres;
GRANT ALL ON TABLE ineligibilities TO postgres;


--
-- Name: instructorclasses; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE instructorclasses FROM PUBLIC;
REVOKE ALL ON TABLE instructorclasses FROM postgres;
GRANT ALL ON TABLE instructorclasses TO postgres;


--
-- Name: instructors; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE instructors FROM PUBLIC;
REVOKE ALL ON TABLE instructors FROM postgres;
GRANT ALL ON TABLE instructors TO postgres;


--
-- Name: persons; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE persons FROM PUBLIC;
REVOKE ALL ON TABLE persons FROM postgres;
GRANT ALL ON TABLE persons TO postgres;


--
-- Name: requirements; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE requirements FROM PUBLIC;
REVOKE ALL ON TABLE requirements FROM postgres;
GRANT ALL ON TABLE requirements TO postgres;


--
-- Name: studentclasses; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE studentclasses FROM PUBLIC;
REVOKE ALL ON TABLE studentclasses FROM postgres;
GRANT ALL ON TABLE studentclasses TO postgres;


--
-- Name: studentineligibilities; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE studentineligibilities FROM PUBLIC;
REVOKE ALL ON TABLE studentineligibilities FROM postgres;
GRANT ALL ON TABLE studentineligibilities TO postgres;


--
-- Name: students; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE students FROM PUBLIC;
REVOKE ALL ON TABLE students FROM postgres;
GRANT ALL ON TABLE students TO postgres;


--
-- Name: studentterms; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE studentterms FROM PUBLIC;
REVOKE ALL ON TABLE studentterms FROM postgres;
GRANT ALL ON TABLE studentterms TO postgres;


--
-- Name: terms; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE terms FROM PUBLIC;
REVOKE ALL ON TABLE terms FROM postgres;
GRANT ALL ON TABLE terms TO postgres;


--
-- Name: viewclasses; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE viewclasses FROM PUBLIC;
REVOKE ALL ON TABLE viewclasses FROM postgres;
GRANT ALL ON TABLE viewclasses TO postgres;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES  TO postgres;


--
-- PostgreSQL database dump complete
--

