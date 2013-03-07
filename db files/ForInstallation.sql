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
-- Name: alltimecwa(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION alltimecwa(p_studentid integer) RETURNS numeric
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
		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--first 5 ah denom
	SELECT COALESCE(SUM(y),0) into ahd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--ah fail numer
	SELECT COALESCE(SUM(x*y), 0) into ahf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'AH' AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	--ah fail denom
	SELECT COALESCE(SUM(y), 0) into ahdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'AH' AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	--first 4 mst numer
	SELECT COALESCE(SUM(x*y), 0) into mst FROM
	(SELECT v.gradevalue as x, v.credits as y, v.coursename
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 4) as sss;

	--first 4 mst denom
	SELECT COALESCE(SUM(y), 0) into mstd FROM
	(SELECT v.gradevalue as x, v.credits as y, v.coursename
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 4) as sss;

	--ns1 and ns2 corrections
	IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename
								FROM viewclasses v 
								WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10
								ORDER BY v.termid ASC
								LIMIT 4) as sss WHERE coursename IN ('Nat Sci 1', 'Chem 1', 'Physics 10')) > 2 THEN
		SELECT xns1_correction($1, $2) into mst;
		SELECT xns1_dcorrection($1, $2) into mstd;
	ELSE 
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename
								FROM viewclasses v 
								WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10
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
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	--mst fails denom
	SELECT COALESCE(SUM(y), 0) into mstdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	--first 5 ssp numer
	SELECT COALESCE(SUM(x*y), 0) into ssp FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--first 5 ssp denom
	SELECT COALESCE(SUM(y), 0) into sspd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--ssp fails numer
	SELECT COALESCE(SUM(x*y), 0) into sspf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	--ssp fails denom
	SELECT COALESCE(SUM(y), 0) into sspdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	--maj pass+fail numer
	SELECT COALESCE(SUM(x*y), 0) into maj FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid <= 11) as sss;

	--maj pass+fail denom
	SELECT COALESCE(SUM(y), 0) into majd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid <= 11) as sss;

	--first 3 ele numer
	SELECT COALESCE(SUM(x*y), 0) into ele FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 3) as sss;
	
	--first 3 ele denom
	SELECT COALESCE(SUM(y), 0) into eled FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10
		ORDER BY v.termid ASC
		LIMIT 3) as sss;

	--overflowing electives correction
	IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
								FROM viewclasses v
								WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10
								ORDER BY v.termid ASC
								LIMIT 3) as sss WHERE sss.domain = 'C197') > 2 THEN
		SELECT xovercs197_correction($1, $2) INTO ele;
		SELECT xovercs197_dcorrection($1, $2) INTO eled;
	ELSE
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
									FROM viewclasses v
									WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10
									ORDER BY v.termid ASC
									LIMIT 3) as sss WHERE sss.domain = 'MSEE') > 2 THEN
			SELECT xovermsee_correction($1, $2) INTO ele;
			SELECT xovermsee_dcorrection($1, $2) INTO eled;
		ELSE
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
									FROM viewclasses v
									WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10
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
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	--ele fails denom
	SELECT COALESCE(SUM(y),0) into elef FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND (v.gradeid = 11 OR v.gradeid = 10)) as sss;

	numer = (ah + ahf + mst + mstf + ssp + sspf + maj + ele);
	denom = (ahd + ahdf + mstd + mstdf + sspd + sspdf + majd + eled);
	IF denom = 0 THEN RETURN 0; END IF;
	cwa = numer / denom;

	RETURN round(cwa,4);	


END;
$_$;


ALTER FUNCTION public.alltimecwa(p_studentid integer) OWNER TO postgres;

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
-- Name: classes_classid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('classes_classid_seq', 11335, true);


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

SELECT pg_catalog.setval('persons_personid_seq', 1839, true);


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

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 34722, true);


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

SELECT pg_catalog.setval('students_studentid_seq', 1829, true);


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

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 7813, true);


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

COPY classes (classid, termid, courseid, section, classcode) FROM stdin;
9534	19991	98	TFQ1	418
9535	19991	116	WBC	919
9536	19991	117	11	3557
9537	19991	94	MHQ3	3983
9538	19991	81	MHW	6800
9539	19991	55	TFR2	9661
9540	19991	106	MTHFX6	9764
9541	20001	33	TFR3	12225
9542	20001	108	MTHFW3	35242
9543	20001	110	MTHFI	37302
9544	20001	102	MHR-S	41562
9545	20001	2	HMXY	44901
9546	20002	109	MHW2	35238
9547	20002	118	TFQ	35271
9548	20002	111	MTHFD	37331
9549	20002	3	TFXY	44911
9550	20002	5	MHX1	44913
9551	20003	118	X3-2	35181
9552	20003	95	X1-1	38511
9553	20011	34	TFW-3	11676
9554	20011	119	MHX	35252
9555	20011	103	TFY2	40385
9556	20011	6	TFR	44922
9557	20011	5	W1	44944
9558	20012	113	MHX3	13972
9559	20012	103	MHU1	40344
9560	20012	11	MHY	44919
9561	20012	19	TFR	44921
9562	20012	24	TFY	44939
9563	20012	114	TFZ	45440
9564	20013	39	X6-D	14922
9565	20013	11	X3	44906
9566	20021	8	TFY	44920
9567	20021	6	TFW	44922
9568	20021	7	MHXY	44925
9569	20021	120	TFV	44931
9570	20021	114	MHW	45405
9571	20021	41	TFX2	12350
9572	20021	106	MTHFU1	35138
9573	20021	98	TFY1	39648
9574	20021	81	MHY	41805
9575	20021	1	MHVW	44901
9576	20021	41	TFV6	12389
9577	20021	106	MTHFW4	35161
9578	20021	94	MHV1	38510
9579	20021	81	TFR	41807
9580	20021	1	MHXY	44902
9581	20022	19	TFX	44918
9582	20022	9	TFV	44925
9583	20022	27	TFW	44927
9584	20022	70	TFR2	33729
9585	20022	107	MTHFV1	35165
9586	20022	95	MHX	38533
9587	20022	100	MHW2	39648
9588	20022	2	MHRU	44900
9589	20022	71	MHR	34200
9590	20022	107	MTHFW3	35173
9591	20022	100	MHV	39646
9592	20022	82	TFU	41814
9593	20022	2	MHXY	44901
9594	20031	121	MHW2	16602
9595	20031	17	MHX	54566
9596	20031	20	WSVX2	54582
9597	20031	14	TFVW	54603
9598	20031	122	MHY	54604
9599	20031	123	MHW	14482
9600	20031	63	MHV	15620
9601	20031	109	TFU2	39320
9602	20031	110	MTHFX	41352
9603	20031	93	MHU1	46314
9604	20031	2	TFVW	54555
9605	20031	34	TFV-2	13921
9606	20031	108	MTHFW1	39247
9607	20031	110	MTHFD	41419
9608	20031	93	TFY2	46310
9609	20031	3	MHXY	54560
9610	20031	43	MHW2	14467
9611	20031	106	MTHFX8	39221
9612	20031	82	TFR	41908
9613	20031	1	MHRU	54550
9614	20031	88	(1)	62806
9615	20031	41	TFQ2	14425
9616	20031	106	MTHFW6	39211
9617	20031	82	MHQ	41905
9618	20031	103	MHX2	44662
9619	20031	1	TFRU	54553
9620	20032	20	WSVX2	54595
9621	20032	42	TFW1	14435
9622	20032	73	MTHW	38073
9623	20032	119	MHX	39321
9624	20032	94	TFX2	45813
9625	20032	3	FTRU	54560
9626	20032	5	MHU	54561
9627	20032	109	TFV1	39278
9628	20032	119	MHW	39320
9629	20032	111	MTHFV	41488
9630	20032	95	TFX1	45839
9631	20032	5	MHX	54562
9632	20032	42	TFU2	14432
9633	20032	107	MTHFR3	39215
9634	20032	81	MHW	41902
9635	20032	102	MHU	45213
9636	20032	2	TFVW	54558
9637	20032	107	MTHFW2	39236
9638	20032	98	WSR2	42601
9639	20032	102	TFQ	45220
9640	20032	94	TFR3	45801
9641	20032	1	MHRU	54552
9642	20033	110	Y3	41355
9643	20033	111	Y3	41362
9644	20033	43	X3A	14411
9645	20033	98	X1-1	42451
9646	20033	108	Z1-2	39183
9647	20041	62	MHX1	15613
9648	20041	119	TFW	39305
9649	20041	7	HMRU	54555
9650	20041	8	TFR	54569
9651	20041	6	TFU	54572
9652	20041	112	MHV	70025
9653	20041	36	TFR-1	13856
9654	20041	35	WIJK	15505
9655	20041	109	MHW2	39395
9656	20041	114	TFW	52451
9657	20041	5	MHU	54563
9658	20041	31	MHR1	15507
9659	20041	108	MTHFW2	39255
9660	20041	110	MTHFX	41354
9661	20041	94	MHU5	45761
9662	20041	3	TFRU	54561
9663	20041	41	MHX3	14423
9664	20041	108	MTHFQ2	39369
9665	20041	110	MTHFD	41350
9666	20041	81	MHW	41902
9667	20041	2	TFVW	54557
9668	20041	41	TFQ1	14428
9669	20041	106	MTHFW2	39208
9670	20041	76	MHX	40826
9671	20041	98	TFX2	42471
9672	20041	1	MHRU	54550
9673	20042	113	MHX1	15672
9674	20042	124	TFY	47972
9675	20042	19	MHR	54564
9676	20042	12	TFRU	54573
9677	20042	24	MHU	54597
9678	20042	11	TFV	54598
9679	20042	42	MHW1	14429
9680	20042	55	TFU1	15568
9681	20042	113	MHV3	15668
9682	20042	41	MHR	14401
9683	20042	73	MTHU-2	38052
9684	20042	109	TFU2	39271
9685	20042	119	TFR	39311
9686	20042	110	MTHFI	41352
9687	20042	5	MHX	54561
9688	20042	43	MHV2	14460
9689	20042	119	TFQ	39178
9690	20042	109	TFR	39268
9691	20042	111	MTHFD	41379
9692	20042	42	MHU1	14421
9693	20042	107	MTHFQ2	39209
9694	20042	95	MHR1	45780
9695	20042	93	TFR3	46324
9696	20042	2	MHXY	54557
9697	20043	39	X3-A	16057
9698	20043	111	Y4	41354
9699	20043	84	X4	41905
9700	20043	103	X-5-2	44660
9701	20043	111	Y1	41353
9702	20043	109	X1-1	39196
9703	20043	108	Z1-4	39187
9704	20051	114	MHR	52454
9705	20051	17	MHX	54567
9706	20051	8	TFY	54570
9707	20051	122	MHU	54577
9708	20051	20	WSVX2	54581
9709	20051	27	WRU	54588
9710	20051	21	FR	54592
9711	20051	114	TFU	52455
9712	20051	17	MHU	54566
9713	20051	6	TFW	54573
9714	20051	7	HMXY	54575
9715	20051	112	MHR	69953
9716	20051	113	TFU2	15702
9717	20051	48	MTU	19924
9718	20051	119	TFR	39309
9719	20051	111	MTHFI	41439
9720	20051	94	MHX3	45771
9721	20051	5	TFX	54562
9722	20051	62	TFR1	15564
9723	20051	119	TFQ	39308
9724	20051	93	TFV1	46329
9725	20051	3	MHXY	54559
9726	20051	71	TFX	38890
9727	20051	108	MTHFU1	39242
9728	20051	110	MTHFI	41412
9729	20051	29	WSR	54589
9730	20051	41	TFV2	14437
9731	20051	70	MHV	37502
9732	20051	106	MTHFW4	39212
9733	20051	94	TFQ2	45773
9734	20051	1	MHXY	54551
9735	20051	41	MHU3	14410
9736	20051	71	MHQ	38678
9737	20051	107	MTHFR	39228
9738	20051	98	TFQ3	42463
9739	20051	1	TFVW	54553
9740	20052	76	MHX	40806
9741	20052	115	MHL	52457
9742	20052	115	MHLM	52459
9743	20052	14	TFRU	54570
9744	20052	9	TFW	54573
9745	20052	27	WRU	54575
9746	20052	22	WSVX2	54584
9747	20052	42	MHY	14425
9748	20052	14	HMVW	54568
9749	20052	122	MHU	54571
9750	20052	28	TFV	54576
9751	20052	12	TFXY	54579
9752	20052	21	TR	54580
9753	20052	125	MHTFX	15078
9754	20052	126	MHTFX	15079
9755	20052	60	BMR1	33107
9756	20052	111	MTHFD	41375
9757	20052	103	MHV2	44695
9758	20052	91	MI1	67273
9759	20052	61	MHX1	15613
9760	20052	109	MHV	39215
9761	20052	119	TFV	39279
9762	20052	111	MTHFR	41467
9763	20052	94	MHU2	45759
9764	20052	5	TFU	54561
9765	20052	39	MHR-1	16052
9766	20052	107	MTHFV4	39184
9767	20052	81	TFR	41903
9768	20052	95	TFU1	45811
9769	20052	2	MHXY	54554
9770	20052	108	MTHFX3	39209
9771	20052	110	MTHFV	41353
9772	20052	102	MHQ	44152
9773	20052	2	TFRU	54555
9774	20053	87	MTWHFAB	47950
9775	20053	18	X2	54550
9776	20053	109	X3-2	39181
9777	20053	107	Z3-2	39170
9778	20053	70	X3	37501
9779	20053	109	X2	39179
9780	20061	114	WIJF	52455
9781	20061	114	WIJT1	52456
9782	20061	19	TFX	54565
9783	20061	20	MHXYM2	54582
9784	20061	113	TFZ1	15681
9785	20061	109	MHV	39271
9786	20061	114	WIJT2	52457
9787	20061	6	HMRU	54569
9788	20061	7	TFRU	54574
9789	20061	8	GS2	54603
9790	20061	37	TFX-2	13886
9791	20061	108	MTHFW1	39186
9792	20061	110	MTHFV	41356
9793	20061	93	TFR2	46327
9794	20061	3	MHRU	54557
9795	20061	39	MHX2	16069
9796	20061	111	MTHFV	41382
9797	20061	3	TFXY	54560
9798	20061	5	TFU	54561
9799	20061	29	WSR	54597
9800	20061	41	TFV2	14520
9801	20061	70	MHU	37501
9802	20061	106	MTHFW1	39189
9803	20061	99	TFR	42466
9804	20061	1	MHXY	54551
9805	20061	39	MHR3	16054
9806	20061	106	MTHFQ1	39150
9807	20061	83	MHW	41434
9808	20061	104	TFU	47970
9809	20061	1	TFVW	54553
9810	20061	43	MHV2	14551
9811	20061	106	MTHFX1	39197
9812	20061	76	TFU	40807
9813	20061	105	MHQ	43553
9814	20061	80	TFW	40252
9815	20061	100	MHY2	42478
9816	20061	1	WSRU	54599
9817	20061	41	MHR2	14493
9818	20061	106	MTHFY5	39299
9819	20061	94	TFW2	45853
9820	20061	93	MHV6	46380
9821	20061	41	TFU3	14518
9822	20061	106	MTHFX4	39200
9823	20061	82	MHY	41911
9824	20061	94	TFR3	45763
9825	20061	1	SWRU	54600
9826	20062	115	MHK	52449
9827	20062	115	MHKH	52450
9828	20062	22	W1	54595
9829	20062	36	MHQ-2	13851
9830	20062	42	TFU1	14589
9831	20062	119	TFQ	39314
9832	20062	3	MHXY	54559
9833	20062	24	MHW	54571
9834	20062	100	TFU1	42493
9835	20062	115	MHKM	52451
9836	20062	11	MHY	54565
9837	20062	14	TFVW	54567
9838	20062	9	FTXY	54570
9839	20062	12	MHVW	54573
9840	20062	63	TFX1	15613
9841	20062	108	MTHFR3	39259
9842	20062	111	MTHFY	41440
9843	20062	98	MHV2	42456
9844	20062	5	TFU	54562
9845	20062	119	TFR	39315
9846	20062	81	MHR	41900
9847	20062	100	MHW1	42487
9848	20062	93	TFX2	46335
9849	20062	7	WRUVX	54602
9850	20062	39	MHR1	16054
9851	20062	107	MTHFU5	39212
9852	20062	94	TFV2	45786
9853	20062	93	MHV5	46316
9854	20062	2	TFXY	54558
9855	20062	40	TFX1	14591
9856	20062	62	MHU2	15598
9857	20062	106	MTHFW-1	39184
9858	20062	100	MHX	42489
9859	20062	2	TFRU	54557
9860	20062	36	MHV-2	13859
9861	20062	40	TFV1	14476
9862	20062	47	Z	19918
9863	20062	107	MTHFW1	39201
9864	20062	2	MHRU	54552
9865	20062	41	TFX	14415
9866	20062	107	MTHFV6	39225
9867	20062	98	TFQ1	42460
9868	20062	93	TFR	46328
9869	20062	42	MHR	14417
9870	20062	106	MTHFQ-1	39197
9871	20062	100	MHW2	42488
9872	20062	95	TFV2	45812
9873	20062	107	MTHFQ6	39395
9874	20062	98	TFX1	42466
9875	20062	105	TFW	43616
9876	20063	18	X2	54550
9877	20063	111	Y3	41353
9878	20063	113	X1B	15527
9879	20063	107	Z1-A	39176
9880	20063	110	Y2	41350
9881	20063	110	Y3	41351
9882	20063	107	Z2-C	39175
9883	20063	36	X2-A	13855
9884	20063	127	X1A	15540
9885	20071	114	TFL	52463
9886	20071	114	TFLH	52464
9887	20071	8	TFX3	54561
9888	20071	6	TFRU	54562
9889	20071	19	TFV1	54567
9890	20071	7	MWVWXY	54583
9891	20071	27	WRU2	54585
9892	20071	21	MH	54594
9893	20071	55	MHU1	15574
9894	20071	17	TFU	54566
9895	20071	16	MHV1	54569
9896	20071	20	W2	54571
9897	20071	27	WRU1	54579
9898	20071	21	MQ	54593
9899	20071	112	TFW	70005
9900	20071	119	TFW	39298
9901	20071	109	MHQ	39388
9902	20071	6	TMRU	54563
9903	20071	8	TFX2	54560
9904	20071	17	MHU	54565
9905	20071	19	TFV2	54568
9906	20071	50	MHV1	15526
9907	20071	107	MTHFW2	39228
9908	20071	110	MTHFX	41361
9909	20071	3	TFRU	54576
9910	20071	108	MTHFU2	39237
9911	20071	110	MTHFQ1	41359
9912	20071	93	MHY2	46327
9913	20071	102	TFY	47991
9914	20071	3	MHVW	54574
9915	20071	71	TFU	38606
9916	20071	108	MTHFX	39248
9917	20071	93	TFV1	46370
9918	20071	104	MHV	47978
9919	20071	3	MHRU	54573
9920	20071	128	TFW	15019
9921	20071	108	MTHFU3	39243
9922	20071	104	TFR-1	44162
9923	20071	107	MTHFR2	39410
9924	20071	110	MTHFV	41360
9925	20071	93	TFU2	46331
9926	20071	1	HMXY	54552
9927	20071	73	MHR	38055
9928	20071	108	MTHFU7	39239
9929	20071	110	MTHFI	41357
9930	20071	1	FTXY	54555
9931	20071	63	TFR1	15635
9932	20071	71	TFW	38833
9933	20071	108	MTHFX3	39396
9934	20071	110	MTHFD	41356
9935	20071	71	TFR	38605
9936	20071	108	MTHFW1	39235
9937	20071	74	TFU	52910
9938	20071	43	TFU1	14447
9939	20071	106	MTHFX2	39212
9940	20071	76	TFY	40809
9941	20071	1	HMRU1	54550
9942	20071	43	TFX	14453
9943	20071	70	MHR	37500
9944	20071	106	MTHFW11	39187
9945	20071	100	MHU	42540
9946	20071	1	FTRU	54553
9947	20071	43	TFV	14449
9948	20071	106	MTHFX-6	39342
9949	20071	94	TFR4	45781
9950	20071	1	HMVW	54551
9951	20071	43	TFU2	14448
9952	20071	70	TFV	37508
9953	20071	100	MHR	42539
9954	20071	42	MHW	14433
9955	20071	106	MTHFR3	39218
9956	20071	94	MHU3	45758
9957	20071	74	TFV	52911
9958	20071	82	MHU	41900
9959	20071	93	TFW1	46332
9960	20072	115	MHLW2	52451
9961	20072	129	MHR	40251
9962	20072	115	MHLF	52452
9963	20072	11	MHZ	54570
9964	20072	12	HMVW	54577
9965	20072	28	MHU	54585
9966	20072	23	SRU	54606
9967	20072	36	TFY-1	13875
9968	20072	123	TFW	14462
9969	20072	70	MHW	37503
9970	20072	130	TFV	43031
9971	20072	102	TFX	47972
9972	20072	131	GTH	52932
9973	20072	22	W2	54581
9974	20072	82	TFU	42004
9975	20072	93	TFV5	46332
9976	20072	115	MHLW1	52450
9977	20072	11	MHX2	54569
9978	20072	12	MHVW	54578
9979	20072	23	TFW	54584
9980	20072	14	MHQR2	54609
9981	20072	66	MHX1	26506
9982	20072	130	TFW	43032
9983	20072	115	MHLT	52449
9984	20072	9	MHSUWX	54602
9985	20072	43	MHV3	14437
9986	20072	108	MTHFX	39197
9987	20072	110	MTHFW	41355
9988	20072	5	TFU2	54566
9989	20072	75	MHR	55102
9990	20072	109	TFW1	39211
9991	20072	119	TFY	39260
9992	20072	111	MTHFQ	41357
9993	20072	81	MHR	42009
9994	20072	98	MHX2	42460
9995	20072	70	MHX	37504
9996	20072	109	TFW2	39233
9997	20072	111	MTHFCR	41358
9998	20072	5	TFU	54564
9999	20072	89	MHW	62802
10000	20072	36	TFX-2	13872
10001	20072	109	MHW1	39294
10002	20072	111	MTHFGV	41360
10003	20072	95	MHX1	45814
10004	20072	5	MHU	54563
10005	20072	36	TFR-1	13864
10006	20072	70	TFU	37507
10007	20072	108	MTHFQ	39207
10008	20072	2	MHRU	54556
10009	20072	39	MHU4	16065
10010	20072	109	MHV	39206
10011	20072	119	TFX	39259
10012	20072	111	MTHFW	41361
10013	20072	74	MHX	52911
10014	20072	1	FTRU	54550
10015	20072	45	TFU	14470
10016	20072	109	MHR	39202
10017	20072	123	TFV	14459
10018	20072	119	TFX1	39383
10019	20072	63	MHR	15608
10020	20072	107	MTHFW4	39183
10021	20072	81	TFX	42012
10022	20072	105	MHV	43552
10023	20072	2	TFRU	54559
10024	20072	123	MHU2	14453
10025	20072	107	MTHFW6	39189
10026	20072	93	MHR4	46307
10027	20072	123	MHU	14451
10028	20072	37	TFQ-2	13887
10029	20072	106	MTHFX	39200
10030	20072	98	MHW2	42458
10031	20072	2	TFVW	54560
10032	20072	123	MHR	14450
10033	20072	107	MTHFW2	39171
10034	20072	98	MHU2	42452
10035	20072	40	MHR	14471
10036	20072	107	MTHFW3	39177
10037	20072	83	MHX	41425
10038	20072	103	MHU1	44677
10039	20072	2	TFXY	54561
10040	20072	39	TFX2	16133
10041	20072	107	MTHFV4	39182
10042	20072	98	MHX1	42459
10043	20072	40	TFW	14481
10044	20072	55	MHU	15575
10045	20072	107	MTHFR	39155
10046	20072	95	TFX1	45831
10047	20072	2	MHVW	54557
10048	20072	50	TFR1	15529
10049	20072	55	MHQ	15573
10050	20072	94	TFX1	45796
10051	20072	55	MHV1	15577
10052	20072	107	MTHFR4	39180
10053	20072	81	TFW	42011
10054	20072	100	MHW	42481
10055	20073	44	MTWHFBC	11651
10056	20073	18	X2	54550
10057	20073	127	X2-A	15518
10058	20073	111	MTWHFJ	41354
10059	20073	109	X1-1	39164
10060	20073	109	X3-1	39167
10061	20073	37	X3-A	13862
10062	20073	71	X5	38604
10063	20073	109	X3-2	39206
10064	20073	111	MTWHFQ	41352
10065	20073	107	Z1-4	39180
10066	20073	98	X2-1	42450
10067	20073	107	Z3-1	39186
10068	20073	107	Z1-6	39182
10069	20073	107	Z1-5	39181
10070	20081	132	THV-2	44102
10071	20081	17	THU	54562
10072	20081	6	FWRU	54571
10073	20081	16	WFV2	54578
10074	20081	20	MS2	54584
10075	20081	75	WFW	55101
10076	20081	100	THR1	42483
10077	20081	133	THW	52938
10078	20081	8	WFW	54568
10079	20081	21	MU	54580
10080	20081	20	MS3	54585
10081	20081	23	THV	54609
10082	20081	112	WFR	69950
10083	20081	47	W	19916
10084	20081	134	THX	43031
10085	20081	16	WFV	54577
10086	20081	20	MS4	54586
10087	20081	29	THW3	54602
10088	20081	108	TWHFR	39212
10089	20081	97	THY	43057
10090	20081	114	THQF2	52451
10091	20081	6	FWVW	54572
10092	20081	91	THD/HJ2	67252
10093	20081	70	THY	37505
10094	20081	114	THQW2	52450
10095	20081	7	THVW	54574
10096	20081	8	SUV	54599
10097	20081	62	THW3	15694
10098	20081	109	THV	39301
10099	20081	114	THQF1	52449
10100	20081	6	THRU	54573
10101	20081	112	WFV	69957
10102	20081	114	THQW1	52448
10103	20081	19	THW	54565
10104	20081	23	WFU	54610
10105	20081	108	TWHFU1	39219
10106	20081	111	TWHFGV	41386
10107	20081	99	THW2	42474
10108	20081	2	FWXY	54556
10109	20081	45	THR2	14480
10110	20081	135	THU	15105
10111	20081	19	THW2	54566
10112	20081	111	TWHFQ	41383
10113	20081	7	THXY2	54576
10114	20081	136	THV	13927
10115	20081	66	THU2	26503
10116	20081	108	TWHFX	39226
10117	20081	119	WFV	39347
10118	20081	110	TWHFW	41382
10119	20081	3	WFRU	54561
10120	20081	48	W	19919
10121	20081	71	WFX	38601
10122	20081	107	TWHFW	39209
10123	20081	1	THXY2	54551
10124	20081	89	A	62800
10125	20081	108	TWHFV1	39221
10126	20081	98	WFY2	42471
10127	20081	95	THQ2	45799
10128	20081	36	WFR-4	13872
10129	20081	103	THR-4	44662
10130	20081	3	THXY	54558
10131	20081	40	THY	14496
10132	20081	62	THU2	15618
10133	20081	93	THX1	46320
10134	20081	39	THX4	16137
10135	20081	108	TWHFW2	39229
10136	20081	110	TWHFQ	41378
10137	20081	36	THR-1	13851
10138	20081	91	WFB/WC	67292
10139	20081	49	WFX1	15543
10140	20081	127	THX2	15575
10141	20081	37	THU-1	13881
10142	20081	137	THR	15043
10143	20081	108	TWHFV	39217
10144	20081	39	WFV1	16136
10145	20081	108	TWHFW1	39225
10146	20081	100	THR2	42484
10147	20081	108	TWHFR4	39216
10148	20081	3	WFXY	54559
10149	20081	75	THW	55100
10150	20081	39	WFW2	16113
10151	20081	108	TWHFR2	39214
10152	20081	110	TWHFU	41380
10153	20081	95	THW1	45808
10154	20081	43	WFR1	14463
10155	20081	70	WFU	37507
10156	20081	106	TWHFW2	39167
10157	20081	100	WFX1	42494
10158	20081	1	HTRU	54554
10159	20081	37	THV-1	13882
10160	20081	106	TWHFR7	39277
10161	20081	76	WFU-1	40811
10162	20081	104	THU	44165
10163	20081	40	THU	14489
10164	20081	106	TWHFQ4	39174
10165	20081	95	THR1	45800
10166	20081	1	THXY	54550
10167	20081	43	THV2	14459
10168	20081	106	TWHFU3	39158
10169	20081	82	WFR	42007
10170	20081	94	THX2	45768
10171	20081	1	WFXY2	54553
10172	20081	43	WFX	14467
10173	20081	70	THU	37501
10174	20081	106	TWHFR9	39279
10175	20081	99	WFY	42478
10176	20081	40	WFX1	14501
10177	20081	106	TWHFW3	39168
10178	20081	84	THU	42004
10179	20081	93	WFU3	46330
10180	20081	45	THU	14481
10181	20081	100	THW	42485
10182	20081	43	WFR2	14464
10183	20081	41	WFW2	14434
10184	20081	93	THV3	46313
10185	20081	74	THX	52900
10186	20081	41	THX2	14418
10187	20081	106	TWHFV7	39258
10188	20081	76	THY	40808
10189	20081	94	WFR2	45776
10190	20081	1	WFXY	54552
10191	20081	41	THW2	14413
10192	20081	82	WFW	42008
10193	20081	94	THQ1	45750
10194	20081	41	WFU2	14427
10195	20081	81	WFR	42001
10196	20081	94	WFX1	45791
10197	20081	1	HTQR	54555
10198	20081	41	THR1	14402
10199	20081	106	TWHFW8	39270
10200	20081	94	THU5	45761
10201	20081	42	THW	14446
10202	20081	106	TWHFR2	39152
10203	20081	82	THU	42009
10204	20081	93	WFU1	46328
10205	20081	123	WFV	14477
10206	20081	82	THW	42010
10207	20081	41	WFX2	14438
10208	20081	70	THR	37500
10209	20081	106	TWHFQ	39170
10210	20081	94	THU3	45759
10211	20081	43	WFY	14468
10212	20081	106	TWHFW7	39260
10213	20081	83	WFU	41375
10214	20081	98	THR2	42451
10215	20081	39	THU3	16133
10216	20081	106	TWHFW6	39259
10217	20081	81	WFX	42003
10218	20081	93	THR3	46305
10219	20081	41	WFW4	14436
10220	20081	106	TWHFQ5	39280
10221	20081	41	THR2	14403
10222	20081	100	WFW	42493
10223	20081	42	THV1	14444
10224	20081	106	TWHFR3	39153
10225	20081	39	THY2	16078
10226	20081	43	THQ	14455
10227	20081	138	WFV	40824
10228	20081	105	WFQ1	43583
10229	20081	123	THX	14469
10230	20081	79	THV1	39703
10231	20081	50	WFU3	15547
10232	20081	55	THR2	15664
10233	20081	106	TWHFX2	39187
10234	20081	93	THV6	46345
10235	20081	1	MUVWX	54597
10236	20081	43	THW3	14600
10237	20081	41	WFX5	14607
10238	20081	106	TWHFU2	39157
10239	20081	94	THX3	45769
10240	20081	37	WFY-2	13931
10241	20081	50	THV1	15528
10242	20081	93	THY4	46325
10243	20082	123	THX	14474
10244	20082	40	THW1	14505
10245	20082	119	THR	39281
10246	20082	111	S3L/R4	41472
10247	20082	89	WFA	62804
10248	20082	45	WFV	14496
10249	20082	138	WFW	40816
10250	20082	14	THRU	54566
10251	20082	9	THVW	54570
10252	20082	22	S2	54581
10253	20082	131	GM	56235
10254	20082	113	WFU2	15707
10255	20082	74	THW	52917
10256	20082	11	WFV	54565
10257	20082	21	HV	54579
10258	20082	22	S1	54580
10259	20082	60	MR2A	33109
10260	20082	84	THW	42007
10261	20082	139	THWFY	43021
10262	20082	140	THWFY	43022
10263	20082	22	S4	54583
10264	20082	89	THK	62800
10265	20082	109	WFU2	39310
10266	20082	5	THU2	54561
10267	20082	14	THVW	54567
10268	20082	141	WFIJ	67206
10269	20082	123	THQ1	14536
10270	20082	115	WFLT	52430
10271	20082	11	WFW	54562
10272	20082	9	THYZ	54571
10273	20082	12	WFUV	54575
10274	20082	135	WFU2	15154
10275	20082	94	THV4	45765
10276	20082	14	THXY	54568
10277	20082	40	THV1	14503
10278	20082	81	THR	42008
10279	20082	115	WFLW	52431
10280	20082	5	THU	54559
10281	20082	11	WFX	54563
10282	20082	14	WFVW	54569
10283	20082	41	THV2	14406
10284	20082	123	WFV1	14480
10285	20082	119	THU	39233
10286	20082	109	WFU5	39321
10287	20082	81	WFW	42010
10288	20082	3	HTQR	54609
10289	20082	115	WFLF	52433
10290	20082	39	WFU4	16078
10291	20082	12	WFWX	54576
10292	20082	30	SWX	54588
10293	20082	112	TBA	70009
10294	20082	5	WFU	54560
10295	20082	89	WFV	62829
10296	20082	42	THU1	14429
10297	20082	109	THR1	39274
10298	20082	111	S4L/R1	41386
10299	20082	100	THW2	42475
10300	20082	75	WFW	55100
10301	20082	43	THV1	14450
10302	20082	108	TWHFU1	39213
10303	20082	110	S2L/R4	41439
10304	20082	94	THW3	45768
10305	20082	2	WFXY	54555
10306	20082	111	S5L/R5	41481
10307	20082	82	THY	42003
10308	20082	94	THV2	45763
10309	20082	119	THV	39271
10310	20082	95	THX3	45817
10311	20082	48	X	19904
10312	20082	108	TWHFW	39211
10313	20082	111	S2L/R4	41468
10314	20082	87	THY	47957
10315	20082	35	THX1	15506
10316	20082	109	THW1	39221
10317	20082	111	S1L/R5	41465
10318	20082	103	WFR-2	44731
10319	20082	5	WFU2	54618
10320	20082	37	THR-3	13884
10321	20082	119	THQ	39280
10322	20082	110	S5L/R1	41392
10323	20082	94	THX3	45771
10324	20082	123	WFX	14484
10325	20082	111	S1L/R1	41383
10326	20082	24	THR	54585
10327	20082	109	WFR2	39309
10328	20082	111	S5L/R1	41387
10329	20082	95	WFV2	45826
10330	20082	123	WFV3	14482
10331	20082	108	TWHFR	39212
10332	20082	45	WFQ	14491
10333	20082	109	THQ1	39378
10334	20082	111	S5L/R3	41479
10335	20082	93	WFU2	46319
10336	20082	36	THV-2	13859
10337	20082	107	TWHFU7	39326
10338	20082	98	THR3	42452
10339	20082	103	WFR-4	44733
10340	20082	1	FWVW	54614
10341	20082	73	WFW-1	38078
10342	20082	111	S4L/R3	41475
10343	20082	89	TNQ	62803
10344	20082	41	WFR	14415
10345	20082	49	THR1	15522
10346	20082	107	TWHFW2	39169
10347	20082	94	WFU1	45782
10348	20082	1	HTXY	54550
10349	20082	39	WFV3	16081
10350	20082	107	TWHFQ4	39268
10351	20082	81	WFX	42011
10352	20082	98	WFU2	42464
10353	20082	2	HTVW	54552
10354	20082	142	WFV	14556
10355	20082	107	TWHFQ1	39158
10356	20082	82	THU	42000
10357	20082	100	THR2	42472
10358	20082	2	WFRU	54554
10359	20082	39	THQ1	16050
10360	20082	107	TWHFU3	39173
10361	20082	100	WFQ2	42477
10362	20082	42	THY	14435
10363	20082	73	WFV	38059
10364	20082	107	TWHFQ5	39345
10365	20082	94	WFX1	45795
10366	20082	41	THX2	14411
10367	20082	123	WFR	14477
10368	20082	98	WFU1	42463
10369	20082	2	THRU	54556
10370	20082	61	THW1	15620
10371	20082	107	TWHFV3	39174
10372	20082	76	WFU	40850
10373	20082	2	HTXY	54557
10374	20082	41	WFU	14416
10375	20082	107	TWHFW	39155
10376	20082	81	WFR	42009
10377	20082	93	WFX	46327
10378	20082	36	WFU-1	13867
10379	20082	93	WFV2	46321
10380	20082	143	WFR/WFRUV2	38632
10381	20082	104	MUV	44132
10382	20082	94	THU2	45758
10383	20082	75	WFX	55101
10384	20082	42	THW2	14433
10385	20082	100	WFR2	42479
10386	20082	123	THR	14537
10387	20082	106	TWHFQ1	39232
10388	20082	70	THU	37501
10389	20082	107	TWHFR4	39177
10390	20082	100	WFW	42481
10391	20082	40	WFX1	14513
10392	20082	76	THX	40804
10393	20082	55	WFR1	15580
10394	20082	71	THX	38600
10395	20082	107	TWHFU6	39325
10396	20082	103	WFV-2	44736
10397	20082	39	WFU2	16076
10398	20082	107	TWHFW4	39179
10399	20082	2	THXY	54553
10400	20082	123	WFW	14483
10401	20082	107	TWHFQ3	39171
10402	20082	80	THU	40251
10403	20082	41	THV3	14407
10404	20082	98	WFV2	42466
10405	20082	93	THU1	46303
10406	20082	43	WFR	14457
10407	20082	107	TWHFU5	39181
10408	20082	93	THQ1	46322
10409	20082	123	THR1	14465
10410	20082	70	WFU	37507
10411	20082	100	WFX	42482
10412	20082	105	THV	43563
10413	20082	40	THU2	14515
10414	20082	106	TWHFX	39186
10415	20082	82	WFV	42004
10416	20082	37	WFR-2	13894
10417	20082	100	WFU	42480
10418	20082	42	WFX1	14443
10419	20082	107	TWHFU2	39167
10420	20082	98	WFR1	42461
10421	20082	107	TWHFR3	39172
10422	20082	42	THR1	14427
10423	20082	100	WFR1	42478
10424	20082	39	WFU3	16077
10425	20082	107	TWHFR2	39166
10426	20082	94	WFW1	45791
10427	20082	123	THU	14466
10428	20082	107	TWHFR	39152
10429	20082	76	WFW	40808
10430	20082	41	THW	14408
10431	20082	104	THX	44130
10432	20082	41	WFV	14417
10433	20082	43	WFU	14459
10434	20082	105	THY	43554
10435	20082	62	THX1	15624
10436	20082	71	WFX	38601
10437	20082	107	TWHFW3	39175
10438	20082	105	WFR	43552
10439	20082	94	THR4	45755
10440	20082	100	WFQ1	42476
10441	20082	93	WFV1	46320
10442	20082	36	WFX-2	13879
10443	20082	106	TWHFU	39372
10444	20082	94	THX1	45769
10445	20082	95	THW2	45813
10446	20083	70	X2	37500
10447	20083	113	X4-A	15534
10448	20083	70	X5	37503
10449	20083	71	X2	38601
10450	20083	43	X5	14420
10451	20083	105	X-3C	43554
10452	20083	98	X5-1	42456
10453	20083	130	X2-1	43011
10454	20083	133	X4	52901
10455	20083	70	X4	37502
10456	20083	109	X3	39181
10457	20083	111	MTWHFJ	41366
10458	20083	109	X2	39180
10459	20083	108	Z2-6	39201
10460	20083	108	Z1-6	39197
10461	20083	109	X4	39206
10462	20083	40	X2	14432
10463	20083	109	X4-1	39210
10464	20083	111	MTWHFQ	41364
10465	20083	108	Z2-2	39175
10466	20083	107	Z1-3	39164
10467	20083	37	X4	13861
10468	20083	93	X3-2	46302
10469	20083	110	MTWHFE	41362
10470	20083	108	Z3-5	39204
10471	20083	107	Z2	39165
10472	20083	71	X3	38602
10473	20083	93	X5-1	46305
10474	20083	108	Z3-2	39178
10475	20083	110	MTWHFJ	41363
10476	20083	108	Z1-1	39170
10477	20083	36	X5	13859
10478	20083	130	X1	43000
10479	20083	107	Z1	39161
10480	20083	95	X2	45753
10481	20083	43	X3-B	14419
10482	20083	107	Z3	39168
10483	20083	108	Z3	39176
10484	20083	108	Z3-1	39177
10485	20083	107	Z2-1	39166
10486	20083	108	Z2-4	39199
10487	20091	24	THX	54565
10488	20091	8	WFV	54575
10489	20091	6	THVW	54580
10490	20091	7	FWXY	54583
10491	20091	112	WFW	69988
10492	20091	143	WFQ/WFUV1	38617
10493	20091	63	WFW1	15604
10494	20091	132	THU1	44103
10495	20091	17	THV	54567
10496	20091	19	THW	54571
10497	20091	16	WFX	54587
10498	20091	20	S6	54625
10499	20091	144	TWHFX	43036
10500	20091	145	TWHFX	43037
10501	20091	71	THW	38717
10502	20091	114	THQ	52479
10503	20091	114	THQS2	52483
10504	20091	7	THXY	54585
10505	20091	21	MR	54589
10506	20091	112	WFY	69990
10507	20091	17	THU	54568
10508	20091	19	THX	54572
10509	20091	23	MXY	54592
10510	20091	20	S7	54629
10511	20091	146	THX	53508
10512	20091	17	WFU	54569
10513	20091	19	THR	54570
10514	20091	7	HTVW	54582
10515	20091	16	WFV	54586
10516	20091	37	WFU-1	13892
10517	20091	133	THU	52904
10518	20091	23	WFX	54591
10519	20091	45	WFV1	14606
10520	20091	147	TWHFR	43056
10521	20091	148	TWHFR	43057
10522	20091	2	THVW	54559
10523	20091	19	WFU	54573
10524	20091	43	THW1	14544
10525	20091	40	WFX3	14637
10526	20091	114	THQT	52480
10527	20091	5	WFR	54564
10528	20091	6	FWVW	54579
10529	20091	149	THR	14968
10530	20091	111	S3L/R3	41398
10531	20091	150	WFV	43061
10532	20091	114	THQS1	52482
10533	20091	17	THW	54566
10534	20091	8	THV	54574
10535	20091	98	WFR2	42458
10536	20091	6	THXY	54581
10537	20091	112	WFX	69989
10538	20091	73	THW	38071
10539	20091	109	WFR	39303
10540	20091	119	WFY	39310
10541	20091	3	WFVW	54562
10542	20091	73	WFU	38063
10543	20091	114	THQH	52481
10544	20091	1	HTXY	54552
10545	20091	75	WFV	55104
10546	20091	87	THU	47951
10547	20091	8	SWX	54577
10548	20091	88	WFX	62814
10549	20091	57	WFU1	15575
10550	20091	111	S4L/R2	41402
10551	20091	6	HTXY	54578
10552	20091	7	WFWX	54584
10553	20091	93	THW2	46362
10554	20091	75	WFW	55100
10555	20091	109	WFQ	39302
10556	20091	111	S5L/R3	41408
10557	20091	3	THRU	54560
10558	20091	8	THY	54576
10559	20091	111	S1L/R5	41390
10560	20091	88	THV	62807
10561	20091	50	WFU1	15533
10562	20091	39	THU1	16075
10563	20091	151	WFX	39266
10564	20091	123	THQ	14562
10565	20091	50	THU3	15523
10566	20091	109	WFV	39297
10567	20091	110	S2L/R3	41358
10568	20091	43	WFW2	14556
10569	20091	35	THQ1	15500
10570	20091	57	THR1	15574
10571	20091	107	TWHFV	39388
10572	20091	110	S6L/R2	41381
10573	20091	1	WFRU2	54616
10574	20091	123	THU2	14565
10575	20091	39	THV3	16119
10576	20091	107	TWHFY	39272
10577	20091	110	S5L/R1	41374
10578	20091	63	WFR1	15601
10579	20091	108	TWHFU3	39278
10580	20091	110	S1L/R4	41353
10581	20091	123	THV3	14568
10582	20091	108	TWHFR4	39339
10583	20091	110	S3L/R1	41362
10584	20091	100	THW	42471
10585	20091	43	THW2	14545
10586	20091	108	TWHFQ2	39371
10587	20091	110	S6L/R6	41385
10588	20091	95	THV3	45805
10589	20091	123	THV2	14567
10590	20091	108	TWHFQ3	39372
10591	20091	81	WFR	42001
10592	20091	3	WFXY	54563
10593	20091	43	THR1	14635
10594	20091	35	WFQ1	15504
10595	20091	110	S6L/R4	41383
10596	20091	41	THX5	14502
10597	20091	108	TWHFR1	39277
10598	20091	110	S3L/R4	41365
10599	20091	97	THV	43059
10600	20091	108	TWHFR	39275
10601	20091	110	S3L/R3	41364
10602	20091	98	WFX	42525
10603	20091	3	THXY	54561
10604	20091	63	THR1	15594
10605	20091	107	TWHFX	39271
10606	20091	111	S3L/R2	41397
10607	20091	43	THQ	14539
10608	20091	108	TWHFU	39273
10609	20091	110	S2L/R4	41359
10610	20091	99	THV	42461
10611	20091	127	THY1	15552
10612	20091	110	S6L/R5	41384
10613	20091	2	THRU	54628
10614	20091	127	WFR1	15554
10615	20091	93	THV3	46307
10616	20091	50	THV2	15558
10617	20091	110	S1L/R5	41354
10618	20091	36	WFV-3	13865
10619	20091	108	TWHFQ1	39338
10620	20091	110	S5L/R6	41379
10621	20091	93	WFX2	46357
10622	20091	108	TWHFU2	39276
10623	20091	110	S4L/R1	41368
10624	20091	81	WFX	42003
10625	20091	94	WFY3	45798
10626	20091	41	THX6	14638
10627	20091	50	WFV2	15536
10628	20091	109	WFW	39298
10629	20091	93	THU4	46305
10630	20091	64	THQ1	15666
10631	20091	50	WFV1	15535
10632	20091	57	WFX1	15577
10633	20091	110	S3L/R5	41366
10634	20091	43	WFW4	14558
10635	20091	108	TWHFR5	39340
10636	20091	95	THW1	45806
10637	20091	62	THR1	15665
10638	20091	70	THY	37505
10639	20091	108	TWHFU4	39287
10640	20091	36	WFY-1	13878
10641	20091	107	TWHFR1	39383
10642	20091	110	S6L/R3	41382
10643	20091	99	WFU	42463
10644	20091	95	WFR1	45813
10645	20091	152	NONE	20509
10646	20091	110	S4L/R4	41371
10647	20091	97	WFU	43001
10648	20091	127	THV2	15561
10649	20091	108	TWHFQ	39285
10650	20091	111	S2L/R1	41391
10651	20091	89	WFX	62805
10652	20091	37	WFW-1	13896
10653	20091	63	THV1	15596
10654	20091	108	TWHFR6	39347
10655	20091	108	TWHFR2	39284
10656	20091	94	WFX2	45793
10657	20091	65	THV1	15616
10658	20091	107	TWHFR	39270
10659	20091	110	S5L/R4	41377
10660	20091	134	THU	43031
10661	20091	37	THW-1	13883
10662	20091	95	WFW1	45820
10663	20091	37	WFY-1	13898
10664	20091	39	THW1	16091
10665	20091	110	S3L/R2	41363
10666	20091	36	WFW-4	13864
10667	20091	57	WFV1	15576
10668	20091	94	THV4	45763
10669	20091	39	THV1	16090
10670	20091	109	THX	39300
10671	20091	23	WFY	54550
10672	20091	36	WFR-2	13868
10673	20091	110	S4L/R3	41370
10674	20091	95	THW2	45807
10675	20091	36	THU-3	13938
10676	20091	109	WFU	39385
10677	20091	110	S5L/R5	41378
10678	20091	74	THV	52915
10679	20091	62	WFR1	15668
10680	20091	107	TWHFU	39378
10681	20091	36	WFX-4	13939
10682	20091	50	THW1	15525
10683	20091	111	S1L/R3	41388
10684	20091	50	THX3	15638
10685	20091	109	THY	39296
10686	20091	95	WFY1	45824
10687	20091	36	THV-1	13856
10688	20091	123	THW	14571
10689	20091	39	THX2	16082
10690	20091	110	S2L/R1	41356
10691	20091	108	TWHFU1	39274
10692	20091	110	S2L/R5	41360
10693	20091	87	THQ1	47992
10694	20091	89	THZ	62833
10695	20091	81	WFW	42002
10696	20091	43	THX2	14547
10697	20091	106	TWHFW5	39209
10698	20091	94	WFQ2	45774
10699	20091	1	HTRU	54554
10700	20091	41	THX2	14499
10701	20091	83	WFU	41502
10702	20091	43	THR	14540
10703	20091	70	THU	37501
10704	20091	106	TWHFW4	39174
10705	20091	100	WFX	42475
10706	20091	1	FWRU	54553
10707	20091	41	THV2	14490
10708	20091	106	TWHFQ1	39151
10709	20091	82	THU	42006
10710	20091	1	WFRU	54557
10711	20091	41	WFV2	14513
10712	20091	106	TWHFU3	39163
10713	20091	83	WFW	41503
10714	20091	100	THR2	42469
10715	20091	1	HTVW	54551
10716	20091	41	WFX2	14521
10717	20091	106	TWHFW7	39248
10718	20091	81	THR	42000
10719	20091	93	THU2	46303
10720	20091	41	WFX1	14520
10721	20091	106	TWHFU2	39162
10722	20091	94	THW1	45765
10723	20091	1	FWVW	54555
10724	20091	106	TWHFQ3	39153
10725	20091	82	WFW	42005
10726	20091	100	THR1	42468
10727	20091	42	THW	14530
10728	20091	106	TWHFV2	39167
10729	20091	82	THR	42004
10730	20091	93	WFR2	46317
10731	20091	1	FWXY	54556
10732	20091	70	THR	37500
10733	20091	99	THW	42462
10734	20091	41	WFX3	14522
10735	20091	70	WFW	37509
10736	20091	93	THR	46369
10737	20091	40	THX1	14585
10738	20091	87	WFR	47957
10739	20091	39	THR2	16099
10740	20091	70	WFV	37508
10741	20091	88	WFR	62809
10742	20091	106	TWHFQ5	39249
10743	20091	83	WFX	41504
10744	20091	100	WFR	42473
10745	20091	43	THV	14543
10746	20091	106	TWHFU1	39161
10747	20091	94	WFW2	45790
10748	20091	40	WFX1	14594
10749	20091	106	TWHFV4	39169
10750	20091	76	WFU1	40810
10751	20091	91	WFB/WI2	67207
10752	20091	39	THX3	16054
10753	20091	94	WFX4	45795
10754	20091	42	THY	14531
10755	20091	106	TWHFV6	39242
10756	20091	94	WFX1	45792
10757	20091	40	WFY	14596
10758	20091	100	WFQ1	42472
10759	20091	123	WFW	14578
10760	20091	100	THR3	42515
10761	20091	39	WFV2	16114
10762	20091	100	WFW	42474
10763	20091	93	THV1	46306
10764	20091	123	WFV3	14577
10765	20091	76	WFX	40811
10766	20091	94	WFQ3	45775
10767	20091	40	THX2	14586
10768	20091	93	WFY1	46331
10769	20091	43	WFW1	14555
10770	20091	93	WFY2	46320
10771	20091	41	THU4	14488
10772	20091	106	TWHFW6	39243
10773	20091	94	THQ1	45750
10774	20091	153	WFU	39192
10775	20091	105	WFV1	43584
10776	20091	44	WFY	11656
10777	20091	40	THY	14588
10778	20091	41	THQ	14483
10779	20091	106	TWHFX7	39254
10780	20091	104	THV1	45853
10781	20091	94	THX2	45769
10782	20091	41	THW5	14497
10783	20091	106	TWHFQ	39150
10784	20091	39	THQ1	16098
10785	20091	93	THX3	46314
10786	20091	40	WFV2	14592
10787	20091	100	WFQ2	42522
10788	20091	60	MR2B	33108
10789	20091	70	WFU	37507
10790	20091	102	THX	44146
10791	20091	41	THX3	14500
10792	20091	94	WFX3	45794
10793	20091	42	WFY1	14536
10794	20091	93	WFU1	46319
10795	20091	106	TWHFY1	39180
10796	20091	94	THU1	45756
10797	20091	42	WFY2	14537
10798	20091	42	THR	14525
10799	20091	106	TWHFX6	39244
10800	20091	98	WFV	42460
10801	20091	76	THX1	40806
10802	20091	88	WFU	62810
10803	20091	123	THR	14563
10804	20091	99	WFV	42464
10805	20091	94	WFV4	45788
10806	20091	106	TWHFY2	39203
10807	20091	43	WFX2	14560
10808	20091	70	WFR	37506
10809	20091	100	THQ1	42466
10810	20091	94	WFV3	45787
10811	20091	123	THU3	14611
10812	20091	106	TWHFY3	39204
10813	20092	154	THY	39298
10814	20092	118	THW	39332
10815	20092	11	WFV	54554
10816	20092	9	WFRU	54591
10817	20092	19	WFW	54631
10818	20092	23	MWX	54637
10819	20092	113	THY1	15663
10820	20092	39	WFU2	16144
10821	20092	155	THW	40256
10822	20092	84	WFV	42006
10823	20092	115	THX	52450
10824	20092	115	THXH	52453
10825	20092	9	WFXY	54566
10826	20092	22	SCVMIG	54602
10827	20092	81	WFW	42002
10828	20092	12	THVW	54575
10829	20092	27	MBD	54625
10830	20092	156	WFQ	15001
10831	20092	50	THU1	15531
10832	20092	115	THXW	52452
10833	20092	131	WFW	56273
10834	20092	39	THV	16073
10835	20092	59	MR11A	33100
10836	20092	74	THW	54000
10837	20092	12	FWVW	54572
10838	20092	157	THX	55673
10839	20092	94	THU1	45755
10840	20092	24	THW	54567
10841	20092	11	WFU	54578
10842	20092	35	THR1	15502
10843	20092	3	THVW	54551
10844	20092	11	WFW	54555
10845	20092	23	WFX	54573
10846	20092	5	WFU	54589
10847	20092	29	THQ	54628
10848	20092	137	THX	15026
10849	20092	14	WFVW	54560
10850	20092	11	WFR	54577
10851	20092	75	THY	55115
10852	20092	41	THY1	14408
10853	20092	113	WFV1	15650
10854	20092	79	THV2	39704
10855	20092	83	THU	41483
10856	20092	21	HR	54570
10857	20092	23	THY	54571
10858	20092	22	MACL	54600
10859	20092	43	THV1	14441
10860	20092	115	THXF	52454
10861	20092	123	THR1	14470
10862	20092	45	SDEF	14501
10863	20092	109	THW	39239
10864	20092	81	WFX	42003
10865	20092	23	WFY1	54638
10866	20092	42	WFX	14435
10867	20092	45	THV	14492
10868	20092	158	THW	16135
10869	20092	2	THRU	54579
10870	20092	37	WFW-2	13928
10871	20092	12	HTVW	54563
10872	20092	9	HTRU	54568
10873	20092	42	THV1	14615
10874	20092	94	THX1	45765
10875	20092	14	WFXY	54561
10876	20092	23	MVW	54634
10877	20092	47	Y	19902
10878	20092	109	THW1	39343
10879	20092	111	S3L/R1	41398
10880	20092	94	THV2	45760
10881	20092	26	THX	54569
10882	20092	125	THY	15057
10883	20092	159	WFW	16126
10884	20092	5	THX	54587
10885	20092	23	WFENTREP	54635
10886	20092	91	WFB/WK2	67256
10887	20092	109	THV1	39245
10888	20092	111	S1L/R5	41392
10889	20092	135	THW	14956
10890	20092	97	WFX	43062
10891	20092	93	THQ2	46301
10892	20092	102	THX	44162
10893	20092	14	WFRU	54559
10894	20092	81	THR	42000
10895	20092	14	THXY	54562
10896	20092	98	THY1	42456
10897	20092	35	WFV1	15508
10898	20092	119	WFX	39214
10899	20092	109	WFU2	39334
10900	20092	45	WFU	14495
10901	20092	115	THXT	52451
10902	20092	9	WFVW	54592
10903	20092	43	WFQ	14452
10904	20092	107	TWHFV6	39335
10905	20092	103	THR-1	44670
10906	20092	2	HTXY	54586
10907	20092	108	TWHFX	39230
10908	20092	111	S5L/R2	41409
10909	20092	97	WFR	43002
10910	20092	93	WFV3	46327
10911	20092	109	THU1	39333
10912	20092	111	S2L/R4	41396
10913	20092	23	WFY	54633
10914	20092	36	WFU-3	13878
10915	20092	111	S1L/R4	41389
10916	20092	100	THR1	42472
10917	20092	93	THY1	46319
10918	20092	2	HTVW	54580
10919	20092	50	WFW1	15543
10920	20092	111	S2L/R1	41393
10921	20092	94	THV1	45759
10922	20092	55	WFW1	15573
10923	20092	70	THR	37500
10924	20092	109	THQ	39248
10925	20092	111	S3L/R5	41402
10926	20092	108	TWHFV	39233
10927	20092	111	S5L/R5	41412
10928	20092	82	WFR	42009
10929	20092	2	FWXY	54582
10930	20092	109	WFU1	39253
10931	20092	93	THV5	46307
10932	20092	87	WFY	47951
10933	20092	5	THU	54590
10934	20092	108	TWHFR	39232
10935	20092	95	THY1	45805
10936	20092	108	TWHFX1	39235
10937	20092	94	WFR1	45774
10938	20092	41	THV1	14402
10939	20092	109	WFV1	39255
10940	20092	100	WFW	42478
10941	20092	93	THU2	46305
10942	20092	36	WFW-1	13880
10943	20092	61	THX1	15597
10944	20092	107	TWHFU7	39338
10945	20092	5	THY	54588
10946	20092	43	THW1	14446
10947	20092	60	MR1	33108
10948	20092	109	THX	39240
10949	20092	111	S2L/R3	41395
10950	20092	43	WFU2	14454
10951	20092	123	WFV1	14484
10952	20092	109	THV	39238
10953	20092	2	THXY	54584
10954	20092	63	THQ1	15608
10955	20092	108	TWHFW1	39234
10956	20092	123	THV2	14473
10957	20092	55	THW1	15570
10958	20092	118	THR	39323
10959	20092	109	THU2	39340
10960	20092	94	WFY1	45790
10961	20092	37	WFV-2	13926
10962	20092	73	WFR	38050
10963	20092	100	THR3	42523
10964	20092	108	TWHFU	39231
10965	20092	94	WFV2	45782
10966	20092	50	WFX2	15535
10967	20092	109	THR1	39326
10968	20092	94	THU2	45756
10969	20092	107	TWHFV4	39204
10970	20092	110	S5L/R6	41379
10971	20092	1	FWXY	54553
10972	20092	109	WFU	39244
10973	20092	93	THY2	46320
10974	20092	70	THW	37503
10975	20092	111	S2L/R5	41397
10976	20092	42	WFR2	14429
10977	20092	111	S4L/R5	41407
10978	20092	160	THU	42480
10979	20092	36	THY-2	13870
10980	20092	35	WFX1	15544
10981	20092	107	TWHFU4	39203
10982	20092	1	FWVW	54565
10983	20092	42	WFU1	14430
10984	20092	109	THV2	39254
10985	20092	74	THY	54001
10986	20092	50	THV4	15656
10987	20092	94	WFV3	45783
10988	20092	109	WFW	39257
10989	20092	111	S2L/R2	41394
10990	20092	95	THX1	45803
10991	20092	66	THX1	26506
10992	20092	51	FWX	29251
10993	20092	95	WFR1	45808
10994	20092	40	THU2	14503
10995	20092	110	S6L/R3	41382
10996	20092	36	THR-2	13852
10997	20092	43	THU1	14438
10998	20092	111	S5L/R3	41410
10999	20092	93	WFX2	46330
11000	20092	35	WFR1	15506
11001	20092	70	THV	37502
11002	20092	109	THR3	39339
11003	20092	111	S3L/R4	41401
11004	20092	50	WFR1	15539
11005	20092	109	THR	39250
11006	20092	93	WFV1	46325
11007	20092	50	THV2	15534
11008	20092	111	S3L/R2	41399
11009	20092	123	THX1	14478
11010	20092	109	THR2	39331
11011	20092	111	S5L/R1	41408
11012	20092	93	WFX1	46332
11013	20092	50	WFX1	15545
11014	20092	109	WFR	39251
11015	20092	94	THR2	45753
11016	20092	94	THQ1	45750
11017	20092	35	THV1	15504
11018	20092	70	THY	37505
11019	20092	110	S6L/R2	41381
11020	20092	75	WFW	55101
11021	20092	37	THV-1	13917
11022	20092	95	WFV2	45812
11023	20092	93	THU3	46306
11024	20092	104	WFW	47957
11025	20092	39	THR	16069
11026	20092	70	THU	37501
11027	20092	138	WFU	40812
11028	20092	111	S4L/R4	41406
11029	20092	161	FAB2	41451
11030	20092	70	WFV	37508
11031	20092	111	S5L/R4	41411
11032	20092	87	WFR	47963
11033	20092	43	WFV2	14457
11034	20092	42	THX2	14425
11035	20092	45	WFX	14500
11036	20092	107	TWHFW	39180
11037	20092	100	WFQ1	42475
11038	20092	2	HTRU1	54557
11039	20092	36	WFV-2	13873
11040	20092	107	TWHFW3	39201
11041	20092	98	THY3	42458
11042	20092	2	HTRU2	54550
11043	20092	36	THX-2	13867
11044	20092	41	THU1	14606
11045	20092	107	TWHFW2	39194
11046	20092	93	WFU3	46324
11047	20092	123	WFV2	14485
11048	20092	107	TWHFQ1	39183
11049	20092	105	WFU	43562
11050	20092	107	TWHFV3	39200
11051	20092	94	THW2	45764
11052	20092	93	WFR1	46321
11053	20092	40	WFR	14511
11054	20092	70	WFU	37507
11055	20092	87	WFX	47970
11056	20092	43	WFX	14466
11057	20092	82	THR	42008
11058	20092	95	WFV1	45811
11059	20092	1	THVW	54556
11060	20092	123	WFW1	14487
11061	20092	48	X	19904
11062	20092	39	THQ	16094
11063	20092	79	THW2	39705
11064	20092	94	WFW2	45785
11065	20092	41	WFX1	14417
11066	20092	36	WFU-2	13877
11067	20092	41	WFR	14411
11068	20092	100	WFQ2	42476
11069	20092	107	TWHFQ3	39196
11070	20092	98	WFV2	42461
11071	20092	123	WFR	14481
11072	20092	40	WFU1	14512
11073	20092	106	TWHFW	39174
11074	20092	107	TWHFU2	39192
11075	20092	98	WFV1	42460
11076	20092	41	THX2	14406
11077	20092	81	WFR	42001
11078	20092	39	WFX4	16105
11079	20092	70	WFW	37509
11080	20092	107	TWHFU1	39185
11081	20092	39	THX1	16053
11082	20092	106	TWHFV1	39211
11083	20092	94	WFR3	45776
11084	20092	158	THX	16136
11085	20092	107	TWHFU	39178
11086	20092	98	THV1	42453
11087	20092	99	WFW	42467
11088	20092	43	WFV4	14459
11089	20092	107	TWHFQ4	39209
11090	20092	93	WFU1	46322
11091	20092	39	WFV1	16104
11092	20092	73	WFU	38065
11093	20092	107	TWHFR	39177
11094	20092	93	WFW1	46328
11095	20092	70	WFX	37510
11096	20092	89	WFR	62802
11097	20092	42	WFU2	14431
11098	20092	107	TWHFR2	39191
11099	20092	100	THQ2	42470
11100	20092	39	THW	16074
11101	20092	107	TWHFV1	39186
11102	20092	41	WFU1	14412
11103	20092	107	TWHFR4	39202
11104	20092	98	THU	42452
11105	20092	63	WFV1	15617
11106	20092	39	WFR1	16097
11107	20092	107	TWHFU3	39198
11108	20092	41	WFW1	14415
11109	20092	93	THW2	46316
11110	20092	70	THX	37504
11111	20092	39	WFW	16121
11112	20092	106	TWHFR	39171
11113	20092	83	THX	41485
11114	20092	63	THW3	15664
11115	20092	94	WFU3	45780
11116	20092	79	THV1	39703
11117	20092	83	WFX	41488
11118	20092	93	THW3	46313
11119	20092	41	THX3	14407
11120	20092	105	THY	43560
11121	20092	42	THX1	14424
11122	20092	95	WFU1	45809
11123	20092	83	THW	41484
11124	20092	94	WFR4	45777
11125	20092	107	TWHFW1	39187
11126	20092	99	WFU	42464
11127	20092	71	THX	38794
11128	20092	94	WFX3	45789
11129	20092	100	THQ1	42469
11130	20092	46	WFR	14951
11131	20092	107	TWHFV2	39193
11132	20092	95	WFQ1	45807
11133	20092	93	THU1	46304
11134	20092	43	WFU3	14455
11135	20092	99	WFX	42468
11136	20092	76	WFY	40806
11137	20092	93	THX1	46317
11138	20092	123	WFU1	14482
11139	20092	75	WFV	55100
11140	20092	61	WFU1	15599
11141	20092	107	TWHFW4	39321
11142	20092	93	THV4	46312
11143	20092	57	WFR1	15588
11144	20092	63	WFY1	15620
11145	20092	99	THW	42463
11146	20092	41	WFU3	14414
11147	20092	97	THW1	43003
11148	20092	39	THX2	16078
11149	20092	59	MR11C	33102
11150	20092	36	WFU-1	13875
11151	20092	70	WFR	37506
11152	20092	107	TWHFV5	39329
11153	20092	94	WFU2	45779
11154	20092	41	WFW2	14416
11155	20092	123	WFW2	14488
11156	20092	40	THW	14506
11157	20092	36	THQ-1	13850
11158	20092	106	TWHFV	39173
11159	20092	89	WFU	62803
11160	20092	36	THU-2	13855
11161	20092	39	WFQ1	16096
11162	20092	43	THU2	14439
11163	20092	40	THY2	14510
11164	20092	158	WFX	16127
11165	20092	76	THW	40802
11166	20092	94	THX4	45768
11167	20092	107	TWHFU5	39206
11168	20092	100	THW	42474
11169	20092	41	WFX2	14418
11170	20092	93	THR1	46302
11171	20092	94	WFX1	45787
11172	20092	43	WFW1	14461
11173	20092	106	TWHFQ	39170
11174	20092	103	WFV-1	44684
11175	20092	39	THX3	16081
11176	20092	93	THW1	46315
11177	20092	42	THX3	14426
11178	20092	39	WFY2	16068
11179	20092	104	MCDE1	45817
11180	20092	100	WFR	42477
11181	20092	95	THU2	45796
11182	20092	39	WFU	16103
11183	20093	41	X4A	14406
11184	20093	111	X7-5	41355
11185	20093	93	X3-1	46307
11186	20093	35	X2-A	15501
11187	20093	18	Prac	54551
11188	20093	162	X7-9	41359
11189	20093	94	X3	45753
11190	20093	113	X1-A	15546
11191	20093	70	X5	37504
11192	20093	113	X2-B	15543
11193	20093	133	X4	55651
11194	20093	61	X3-A	15519
11195	20093	109	X2-1	39205
11196	20093	81	X4	42003
11197	20093	71	X3	38602
11198	20093	123	X3A	14431
11199	20093	111	X7-4	41354
11200	20093	98	X1	42451
11201	20093	5	X	54554
11202	20093	108	Z1-4	39195
11203	20093	109	X1-1	39193
11204	20093	103	X-2	44659
11205	20093	109	X4	39182
11206	20093	109	X3	39181
11207	20093	100	X4-1	42461
11208	20093	108	Z2	39172
11209	20093	108	Z3-1	39175
11210	20093	108	Z3-4	39206
11211	20093	109	X4-1	39183
11212	20093	43	X2B	14418
11213	20093	123	X2A	14428
11214	20093	93	X3	46302
11215	20093	23	X	54553
11216	20093	109	X2	39180
11217	20093	103	X5	43556
11218	20093	50	X4-A	15507
11219	20093	41	X3A	14403
11220	20093	108	Z1-1	39173
11221	20093	108	Z2-3	39199
11222	20093	137	X3	14966
11223	20093	163	X-2-2	44653
11224	20093	107	Z1-2	39169
11225	20093	108	Z1	39170
11226	20093	108	Z1-3	39194
11227	20093	108	Z1-5	39196
11228	20093	95	X3	45755
11229	20093	93	X2	46301
11230	20093	108	Z2-2	39177
11231	20093	105	X3	43554
11232	20093	94	X2	45752
11233	20093	40	X4A	14439
11234	20093	100	X3-1	42459
11235	20093	107	Z1	39164
11236	20093	108	Z1-2	39176
11237	20093	108	Z1-6	39197
11238	20093	107	Z2	39165
11239	20093	107	Z1-3	39201
11240	20093	108	Z3-2	39178
11241	20093	100	X3-2	42460
11242	20093	94	X1	45751
11243	20093	107	Z2-1	39168
11244	20093	107	Z2-2	39202
11245	20093	84	X3	42002
11246	20093	39	X1A	16051
11247	20093	102	X2-1	44110
11248	20093	71	X2	38601
11249	20093	107	Z1-1	39167
11250	20093	108	Z1-8	39215
11251	20093	108	Z2-1	39174
11252	20101	17	THU	54569
11253	20101	7	HTVW	54586
11254	20101	16	THY	54592
11255	20101	6	S2	54650
11256	20101	112	WFR	69955
11257	20101	37	WFX-1	13890
11258	20101	102	WFU	44164
11259	20101	17	WFV	54571
11260	20101	21	HR	54593
11261	20101	20	MACL	54614
11262	20101	19	WFX	54576
11263	20101	16	WFY	54591
11264	20101	20	MWSG	54619
11265	20101	112	WFU	69956
11266	20101	164	THD	66665
11267	20101	164	HJ4	66745
11268	20101	70	WFV	37509
11269	20101	82	THX	42012
11270	20101	16	WFX	54590
11271	20101	23	THR	54605
11272	20101	114	WBC	52481
11273	20101	114	WBCH	52483
11274	20101	17	WFW	54572
11275	20101	8	THV	54579
11276	20101	6	HTXY	54582
11277	20101	7	M	54649
11278	20101	114	WBCT	52482
11279	20101	8	THW	54577
11280	20101	7	WFVW	54646
11281	20101	23	THV	54595
11282	20101	114	FBCS2	52528
11283	20101	114	FBC	52530
11284	20101	113	WFQ2	15650
11285	20101	155	THW	40258
11286	20101	19	WFU	54574
11287	20101	16	WFV	54589
11288	20101	20	MCVMIG	54616
11289	20101	112	WFX	70034
11290	20101	123	WFU1	14497
11291	20101	87	WFW1	47967
11292	20101	7	HTRU	54585
11293	20101	113	THV1	15631
11294	20101	70	THW	37504
11295	20101	100	WFR1	42472
11296	20101	3	WFVW	54567
11297	20101	19	THR	54573
11298	20101	17	WFU	54570
11299	20101	19	WFW	54575
11300	20101	26	THX	54596
11301	20101	75	WFY	55106
11302	20101	8	THY	54578
11303	20101	113	THX2	15636
11304	20101	165	THU	39268
11305	20101	111	S4-A	41382
11306	20101	114	FBCS1	52484
11307	20101	20	MNDSG	54617
11308	20101	43	THW1	14465
11309	20101	111	S3-A	41380
11310	20101	95	THV1	45796
11311	20101	79	WFV1	39705
11312	20101	20	MSCL	54618
11313	20101	108	TWHFV1	39249
11314	20101	72	WFX	52379
11315	20101	3	WFRU	54566
11316	20101	35	WFV2	15505
11317	20101	109	THX	39261
11318	20101	100	THR3	42519
11319	20101	166	THU	43030
11320	20101	23	THW	54604
11321	20101	36	THY-1	13862
11322	20101	103	WFQ-2	44665
11323	20101	74	THX	54001
11324	20101	23	WFY	54607
11325	20101	127	THV1	15554
11326	20101	81	WFX	42002
11327	20101	82	THR	42003
11328	20101	107	TWHFY1	39382
11329	20101	110	S3-A	41361
11330	20101	1	FWVW	54555
11331	20101	45	WFV	14519
11332	20101	6	S	54643
11333	20101	137	THQ	15024
11334	20101	56	THX1	15566
11335	20101	6	FWVW	54583
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
945	1999	23
945	2001	21
945	2002	18
945	2003	6
947	2006	9
947	2007	3
948	2004	13
948	2008	12
948	2009	22
948	2010	6
949	2005	12
949	2006	13
949	2007	22
949	2009	3
951	2006	23
951	2008	18
951	2010	4
952	2009	6
952	2010	3
953	2010	9
954	2010	12
956	2010	15
957	2010	0
958	2010	9
959	2010	9
960	2010	13
961	2010	12
962	2010	15
963	2010	16
964	2009	22
964	2010	6
965	2010	15
966	2009	13
966	2010	10
967	2010	12
968	2010	15
969	2010	15
970	2010	19
971	2010	15
972	2010	18
973	2010	15
974	2010	18
975	2010	9
992	2009	15
1001	2009	23
1007	2008	22
1007	2010	9
1008	2010	12
1009	2010	13
1010	2010	15
1011	2010	19
1012	2010	19
1118	2009	11
1119	2009	14
1120	2009	19
1121	2010	15
\.


--
-- Data for Name: eligpasshalf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalf (studentid, studenttermid, termid, failpercentage) FROM stdin;
947	3999	20032	0.8125
948	4013	20042	0.789473712
948	4278	20091	0.600000024
948	4714	20101	0.600000024
949	4014	20042	0.5625
956	4621	20093	1
957	4120	20073	1
958	4102	20072	0.625
966	4630	20093	0.571428597
989	4266	20083	1
992	4333	20091	0.631578922
996	4271	20083	1
1001	4656	20093	1
1014	4638	20093	1
1058	4676	20093	1
1107	4706	20093	1
1109	4708	20093	1
\.


--
-- Data for Name: eligpasshalfmathcs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalfmathcs (studentid, studenttermid, termid, failpercentage) FROM stdin;
945	3984	20012	0.666666687
947	3999	20032	0.666666687
948	4013	20042	1
949	4014	20042	1
951	4032	20052	0.625
951	4040	20061	0.555555582
953	4053	20062	0.625
954	4043	20061	0.625
955	4097	20072	0.666666687
956	4098	20072	0.666666687
956	4621	20093	1
958	4102	20072	0.666666687
959	4099	20072	1
961	4103	20072	0.625
964	4082	20071	0.625
966	4108	20072	0.625
967	4109	20072	0.625
969	4147	20081	0.555555582
976	4212	20082	0.625
976	4479	20092	0.666666687
977	4313	20091	0.555555582
977	4636	20093	1
981	4320	20091	0.555555582
984	4161	20081	0.625
985	4221	20082	0.625
988	4498	20092	0.666666687
989	4266	20083	1
991	4227	20082	0.625
991	4501	20092	0.545454562
992	4333	20091	0.666666687
993	4170	20081	0.625
996	4271	20083	1
1001	4656	20093	1
1003	4239	20082	0.625
1006	4183	20081	1
1010	4305	20091	0.625
1011	4473	20092	0.625
1014	4638	20093	1
1034	4363	20091	0.625
1039	4368	20091	0.625
1040	4539	20092	0.625
1052	4381	20091	0.625
1058	4387	20091	0.625
1058	4676	20093	1
1074	4573	20092	0.625
1075	4574	20092	0.625
1091	4420	20091	0.625
1093	4592	20092	0.625
1095	4594	20092	0.625
1098	4597	20092	0.625
1102	4601	20092	0.625
1103	4602	20092	0.625
1107	4436	20091	0.625
1107	4706	20093	1
1109	4708	20093	1
1111	4610	20092	1
1113	4612	20092	0.625
\.


--
-- Data for Name: eligtwicefail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligtwicefail (studentid, classid, courseid, section, coursename, termid) FROM stdin;
1001	3638	5	WFU	CS 32	20092
1001	3993	5	X	CS 32	20093
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
1663	ORENSE	ADRIAN	CORDOVA	
1664	VILLARANTE	JAY RICKY	BARRAMEDA	
1665	LUMONGSOD	PIO RYAN	SAGARINO	
1666	TOBIAS	GEORGE HELAMAN	ASTURIAS	
1667	CUNANAN	JENNIFER	DELA CRUZ	
1668	RAGASA	ROGER JOHN	ESTEPA	
1669	MARANAN	KERVIN	CATUNGAL	
1670	DEINLA	REGINALD ELI	ATIENZA	
1671	RAMIREZ	NORBERTO	ALLAREY	II
1672	PUGAL	EDGAR	STA BARBARA	JR
1673	JOVEN	KATHLEEN GRACE	GUERRERO	
1674	ESCALANTE	ED ALBERT	BELARGO	
1675	CONTRERAS	PAUL VINCENT	SALES	
1676	DIRECTO	KAREIN JOY	TOLENTINO	
1677	VALLO	LOVELIA	LAROCO	
1678	DOMINGO	CYROD JOHN	FLORIDA	
1679	SUBA	KEVIN RAINIER	SINOGAYA	
1680	CATAJOY	VINCENT NICHOLAS	RANA	
1681	BATANES	BRYAN MATTHEW	AVENDANO	
1682	BALAGAPO	JOSHUA	KHO	
1683	DOMANTAY	ERIC	AMPARO	JR
1684	JAVIER	JEWEL LEX	TONG	
1685	JUAT	WESLEY	MENDOZA	
1686	ISIDRO	HOMER IRIC	SANTOS	
1687	VILLANUEVA	MARIANNE ANGELIE	OCAMPO	
1688	MAMARIL	VIC ANGELO	DELOS SANTOS	
1689	ARANA	RYAN KRISTOFER	IGMAT	
1690	NICOLAS	DANA ELISA	GAGALAC	
1691	VACALARES	ISAIAH JAMES	VALDES	
1692	SANTILLAN	MA CECILIA		
1693	PINEDA	JAKE ERICKSON	BOTEROS	
1694	LOYOLA	ELIZABETH	CUETO	
1695	BUGAOAN	FRANCIS KEVIN	ALIMORONG	
1696	GALLARDO	FRANCIS JOMER	DE LEON	
1697	ARGARIN	MICHAEL ERICK	STA TERESA	
1698	VILLARUZ	JULIAN	CASTILLO	
1699	FRANCISCO	ARMINA	EUGENIO	
1700	AQUINO	JOSEPH ARMAN	BONGCO	
1701	AME	MARTIN ROMAN LORENZO	ILAGAN	
1702	CELEDONIO	MESSIAH JAN	LEBID	
1703	SABIDONG	JEROME	RONCESVALLES	
1704	FLORENCIO	JOHN CARLO	MAQUILAN	
1705	EPISTOLA	SILVEN VICTOR	DUMALAG	
1706	SANTOS	JOHN ISRAEL	LORENZO	
1707	SANTOS	MARIE JUNNE	CABRAL	
1708	FABIC	JULIAN NICHOLAS	REYES	
1709	TORRES	ERIC	TUQUERO	
1710	CUETO	BENJAMIN	ANGELES	JR
1711	PASCUAL	JEANELLA KLARYS	ESPIRITU	
1712	GAMBA	JOSE NOEL	CARDONES	
1713	REFAMONTE	JARED	MUMAR	
1714	BARITUA	KARESSA ALEXANDRA	ONG	
1715	SEMILLA	STANLEY	TINA	
1716	ANGELES	MARC ARTHUR	PAJE	
1717	SORIAO	HANS CHRISTIAN	BALTAZAR	
1718	DINO	ARVIN	PABINES	
1719	MORALES	NOELYN JOYCE	ROL	
1720	MANALAC	DAVID ROBIN	MANALAC	
1721	SAY	KOHLEN ANGELO	PEREZ	
1722	ADRIANO	JAMES PATRICK	DAVID	
1723	SERRANO	MICHAEL	DIONISIO	
1724	CHOAPECK	MARIE ANTOINETTE	R	
1725	TURLA	ISAIAH EDWARD	G	
1726	MONCADA	DEAN ALVIN	BAJAMONDE	
1727	EVANGELISTA	JOHN EROL	MILANO	
1728	ASIS	KRYSTIAN VIEL	CABUGAO	
1729	CLAVECILLA	VANESSA VIVIEN	FRANCISCO	
1730	RONDON	RYAN ODYLON	GAZMEN	
1731	ARANAS	CHRISTIAN JOY	MARQUEZ	
1732	AGUILAR	JENNIFER	RAMOS	
1733	CUEVAS	SARAH	BERNABE	
1734	PASCUAL	JAYVEE ELJOHN	ACABO	
1735	TORRES	DANAH VERONICA	PADILLA	
1736	BISAIS	APRYL ROSE	LABAYOG	
1737	CHUA	TED GUILLANO	SY	
1738	CRUZ	IVAN KRISTEL	POLICARPIO	
1739	AQUINO	CHLOEBELLE	RAMOS	
1740	YUTUC	DANIEL	LALAGUNA	
1741	DEL ROSARIO	BENJIE	REYES	
1742	RAMOS	ANNA CLARISSA	BEATO	
1743	REYES	CHARMAILENE	CAPILI	
1744	ABANTO	JEANELLE	ESGUERRA	
1745	BONDOC	ROD XANDER	RIVERA	
1746	TACATA	NERISSA MONICA	DE GUZMAN	
1747	RABE	REZELEE	AQUINO	
1748	DECENA	BERLYN ANNE	ARAGON	
1749	DIMLA	KARL LEN MAE	BALDOMERO	
1750	SANCHEZ	ZIV YVES	MONTOYA	
1751	LITIMCO	CZELINA ELLAINE	ONG	
1752	GUILLEN	NEIL DAVID	BALGOS	
1753	SOMOSON	LOU MERLENETTE	BAUTISTA	
1754	TALAVERA	RHIZA MAE	GO	
1755	CANOY	JOHN GABRIEL	ERUM	
1756	CHUA	RALPH JACOB	ANG	
1757	EALA	MARIA AZRIEL THERESE	DESTUA	
1758	AYAG	DANIELLE ANNE	FRANCISCO	
1759	DE VILLA	RACHEL	LUNA	
1760	JAYMALIN	JEAN DOMINIQUE	BERNAL	
1761	LEGASPI	CHARMAINE PAMELA	ABERCA	
1762	LIBUNAO	ARIANNE FRANCESCA	QUIJANO	
1763	REGENCIA	FELIX ARAM	JEREMIAS	
1764	SANTI	NATHAN LEMUEL	GO	
1765	LEONOR	WENDY GENEVA	SANTOS	
1766	LUNA	MARA ISSABEL	SUPLICO	
1767	SIRIBAN	MA LORENA JOY	ASCUTIA	
1768	LEGASPI	MISHAEL MAE	CRUZ	
1769	SUN	HANNAH ERIKA	YAP	
1770	PARRENO	NICOLE ANNE	KAHN	
1771	BULANHAGUI	KEVIN DAVID	BALANAY	
1772	MONCADA	JULIA NINA	SOMERA	
1773	IBANEZ	SEBASTIAN	CANLAS	
1774	COLA	VERNA KATRIN	BEDUYA	
1775	SANTOS	MARIA RUBYLISA	AREVALO	
1776	YECLA	NORVIN	GARCIA	
1777	CASTANEDA	ANNA MANNELLI	ESPIRITU	
1778	FOJAS	EDGAR ALLAN	GO	
1779	DELA CRUZ	EMERY	FABRO	
1780	SADORNAS	JON PERCIVAL	GARCIA	
1781	VILLANUEVA	MARY GRACE	AYENTO	
1782	ESGUERRA	JOSE MARI	MARCELO	
1783	SY	KYLE BENEDICT	GUERRERO	
1784	TORRES	LUIS ANTONIO	PEREZ	
1785	TONG	MAYNARD JEFFERSON	ZHUANG	
1786	DATU	PATRICH PAOLO	BONETE	
1787	PEREA	EMMANUEL	LOYOLA	
1788	BALOY	MICHAEL JOYSON	GERMAR	
1789	REAL	VICTORIA CASSANDRA	RUIVIVAR	
1790	MARTIJA	JASPER	ENRIQUEZ	
1791	OCHAVEZ	ARISA	CAAKBAY	
1792	AMORANTO	PAOLO	SISON	
1793	SAN ANTONIO	JAYVIC	PORTILLO	
1794	SARDONA	CATHERINE LORAINE	FESTIN	
1795	MENESES	ANGELO	CAL	
1796	AUSTRIA	DARRWIN DEAREST	CRISOSTOMO	
1797	BURGOS	ALVIN JOHN	MANLIGUEZ	
1798	MAGNO	JENNY	NARSOLIS	
1799	SAPASAP	RIC JANUS	OLIVER	
1800	QUILAB	FRANCIS MIGUEL	EVANGELISTA	
1801	PINEDA	RIZA RAE	ALDECOA	
1802	TAN	XYRIZ CZAR	PINEDA	
1803	DELAS PENAS	KRISTOFER	EMPUERTO	
1804	MANSOS	JOHN FRANCIS	LLAGAS	
1805	PANOPIO	GIRAH MAY	CHUA	
1806	LEGASPINA	CHRISLENE	BUGARIN	
1807	RIVERA	DON JOSEPH	TIANGCO	
1808	RUBIO	MARY GRACE	TALAN	
1809	LEONOR	CHARLES TIMOTHY	DEL ROSARIO	
1810	CABUHAT	JOHN JOEL	URBISTONDO	
1811	MARANAN	GENIE LINN	PADILLA	
1812	WANG	CASSANDRA LEIGH	LACASTA	
1813	YU	GLADYS JOYCE	OCAP	
1814	TOMACRUZ	ARVIN JOHN	CRUZ	
1815	BALDUEZA	GYZELLE	EVANGELISTA	
1816	BATAC	JOSE EMMANUEL	DE JESUS	
1817	CUETO	JAN COLIN	OJEDA	
1818	RUBI	SHIELA PAULINE JOY	VERGARA	
1819	ALCARAZ	KEN GERARD	TECSON	
1820	DE LOS SANTOS	PAOLO MIGUEL	MACALINDONG	
1821	CHAVEZ	JOE-MAR	ORINDAY	
1822	PERALTA	PAOLO THOMAS	REYES	
1823	SANTOS	ALEXANDREI	GONZALES	
1824	MACAPINLAC	VERONICA	ALCARAZ	
1825	PACAPAC	DIANA MAE	CANLAS	
1826	DUNGCA	JOHN ALPERT	ANCHO	
1827	ZACARIAS	ROEL JEREMIAH	ALCANTARA	
1828	RICIO	DUSTIN EDRIC	LEGARDA	
1829	ARBAS	HARVEY IAN	SOLAYAO	
1830	SALVADOR	RAMON JOSE NILO	DELA VEGA	
1831	DORADO	JOHN PHILIP	URRIZA	
1832	DEATRAS	SHEALTIEL PAUL ROSSNERR	CALUAG	
1833	CAPACILLO	JULES ALBERT	BERINGUELA	
1834	SALAMANCA	KYLA MARIE	G.	
1835	AVE	ARMOND	C.	
1836	CALARANAN	MICHAEL KEVIN	PONTE	
1837	DOCTOR	JET LAWRENCE	PARONE	
1838	ANG	RITZ DANIEL	CATAMPATAN	
1839	FORMES	RAFAEL GERARD	DELA CRUZ	
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
31370	7047	9534	6
31371	7047	9535	7
31372	7047	9536	7
31373	7047	9537	6
31374	7047	9538	4
31375	7047	9539	3
31376	7047	9540	1
31377	7048	9541	4
31378	7048	9542	5
31379	7048	9543	6
31380	7048	9544	4
31381	7048	9545	3
31382	7049	9546	10
31383	7049	9547	11
31384	7049	9548	9
31385	7049	9549	8
31386	7049	9550	11
31387	7050	9551	3
31388	7050	9552	9
31389	7051	9553	7
31390	7051	9554	9
31391	7051	9555	13
31392	7051	9556	10
31393	7051	9557	6
31394	7052	9558	13
31395	7052	9559	9
31396	7052	9560	11
31397	7052	9561	11
31398	7052	9562	9
31399	7052	9563	11
31400	7053	9564	6
31401	7053	9565	5
31402	7054	9566	9
31403	7054	9567	6
31404	7054	9568	11
31405	7054	9569	9
31406	7054	9570	5
31407	7055	9571	6
31408	7055	9572	9
31409	7055	9573	6
31410	7055	9574	8
31411	7055	9575	3
31412	7056	9576	7
31413	7056	9577	6
31414	7056	9578	5
31415	7056	9579	6
31416	7056	9580	6
31417	7057	9581	9
31418	7057	9582	8
31419	7057	9583	10
31420	7058	9584	5
31421	7058	9585	9
31422	7058	9586	7
31423	7058	9587	7
31424	7058	9588	11
31425	7059	9589	7
31426	7059	9590	9
31427	7059	9591	3
31428	7059	9592	6
31429	7059	9593	9
31430	7060	9594	14
31431	7060	9595	9
31432	7060	9596	10
31433	7060	9597	5
31434	7060	9598	14
31435	7061	9599	7
31436	7061	9600	14
31437	7061	9601	9
31438	7061	9602	14
31439	7061	9603	5
31440	7061	9604	5
31441	7062	9605	9
31442	7062	9606	8
31443	7062	9607	9
31444	7062	9608	4
31445	7062	9609	7
31446	7063	9610	12
31447	7063	9611	7
31448	7063	9612	5
31449	7063	9613	9
31450	7063	9614	14
31451	7064	9615	14
31452	7064	9616	9
31453	7064	9617	6
31454	7064	9618	6
31455	7064	9619	12
31456	7065	9620	12
31457	7066	9621	5
31458	7066	9622	4
31459	7066	9623	13
31460	7066	9624	4
31461	7066	9625	9
31462	7066	9626	9
31463	7067	9627	11
31464	7067	9628	9
31465	7067	9629	11
31466	7067	9630	11
31467	7067	9631	11
31468	7068	9632	13
31469	7068	9633	9
31470	7068	9634	9
31471	7068	9635	9
31472	7068	9636	5
31473	7069	9637	9
31474	7069	9638	6
31475	7069	9639	4
31476	7069	9640	2
31477	7069	9641	2
31478	7070	9642	6
31479	7071	9643	8
31480	7072	9644	5
31481	7072	9645	5
31482	7073	9646	10
31483	7074	9647	4
31484	7074	9648	9
31485	7074	9649	8
31486	7074	9650	11
31487	7074	9651	8
31488	7074	9652	9
31489	7075	9653	9
31490	7075	9654	4
31491	7075	9655	9
31492	7075	9656	11
31493	7075	9657	9
31494	7075	9651	11
31495	7076	9658	12
31496	7076	9659	7
31497	7076	9660	11
31498	7076	9661	13
31499	7076	9662	6
31500	7077	9663	12
31501	7077	9664	6
31502	7077	9665	7
31503	7077	9666	7
31504	7077	9667	7
31505	7078	9668	4
31506	7078	9669	7
31507	7078	9670	1
31508	7078	9671	4
31509	7078	9672	1
31510	7079	9673	7
31511	7079	9674	4
31512	7079	9675	8
31513	7079	9676	1
31514	7079	9677	7
31515	7079	9678	9
31516	7080	9679	12
31517	7080	9680	4
31518	7080	9681	5
31519	7080	9675	11
31520	7080	9677	8
31521	7080	9678	9
31522	7081	9682	11
31523	7081	9683	11
31524	7081	9684	11
31525	7081	9685	11
31526	7081	9686	9
31527	7081	9687	11
31528	7082	9688	5
31529	7082	9689	11
31530	7082	9690	11
31531	7082	9691	9
31532	7082	9687	11
31533	7083	9692	9
31534	7083	9693	6
31535	7083	9694	13
31536	7083	9695	5
31537	7083	9696	2
31538	7084	9697	4
31539	7084	9698	7
31540	7085	9699	2
31541	7085	9700	4
31542	7086	9701	14
31543	7087	9702	6
31544	7088	9703	13
31545	7089	9704	6
31546	7089	9705	9
31547	7089	9706	9
31548	7089	9707	6
31549	7089	9708	2
31550	7089	9709	5
31551	7089	9710	6
31552	7090	9711	11
31553	7090	9712	5
31554	7090	9706	5
31555	7090	9713	6
31556	7090	9714	6
31557	7090	9715	9
31558	7091	9716	6
31559	7091	9717	5
31560	7091	9718	11
31561	7091	9719	11
31562	7091	9720	3
31563	7091	9721	9
31564	7092	9722	8
31565	7092	9723	11
31566	7092	9724	6
31567	7092	9725	12
31568	7092	9721	9
31569	7092	9715	7
31570	7093	9726	4
31571	7093	9727	8
31572	7093	9728	7
31573	7093	9725	1
31574	7093	9729	7
31575	7094	9730	7
31576	7094	9731	5
31577	7094	9732	4
31578	7094	9733	3
31579	7094	9734	4
31580	7095	9735	6
31581	7095	9736	4
31582	7095	9737	4
31583	7095	9738	8
31584	7095	9739	2
31585	7096	9740	3
31586	7096	9741	14
31587	7096	9742	9
31588	7096	9743	9
31589	7096	9744	12
31590	7096	9745	7
31591	7096	9746	2
31592	7097	9747	8
31593	7097	9748	5
31594	7097	9749	9
31595	7097	9744	6
31596	7097	9750	6
31597	7097	9751	2
31598	7097	9752	3
31599	7098	9753	6
31600	7098	9754	5
31601	7098	9755	5
31602	7098	9756	10
31603	7098	9757	8
31604	7098	9758	7
31605	7099	9759	12
31606	7099	9760	10
31607	7099	9761	4
31608	7099	9762	9
31609	7099	9763	6
31610	7099	9764	5
31611	7100	9765	13
31612	7100	9766	11
31613	7100	9767	9
31614	7100	9768	6
31615	7100	9769	4
31616	7101	9747	8
31617	7101	9770	7
31618	7101	9771	5
31619	7101	9772	4
31620	7101	9773	1
31621	7102	9774	1
31622	7102	9775	2
31623	7103	9776	5
31624	7104	9777	6
31625	7105	9778	3
31626	7105	9779	6
31627	7106	9780	14
31628	7106	9781	8
31629	7106	9782	10
31630	7106	9783	6
31631	7107	9784	2
31632	7107	9785	3
31633	7107	9780	5
31634	7107	9786	5
31635	7107	9787	5
31636	7107	9788	6
31637	7107	9789	1
31638	7108	9790	11
31639	7108	9791	11
31640	7108	9792	8
31641	7108	9793	13
31642	7108	9794	9
31643	7109	9795	4
31644	7109	9796	8
31645	7109	9797	6
31646	7109	9798	9
31647	7109	9799	3
31648	7110	9800	5
31649	7110	9801	5
31650	7110	9802	9
31651	7110	9803	2
31652	7110	9804	5
31653	7111	9805	3
31654	7111	9806	11
31655	7111	9807	2
31656	7111	9808	3
31657	7111	9809	5
31658	7112	9810	2
31659	7112	9811	8
31660	7112	9812	1
31661	7112	9813	3
31662	7112	9809	6
31663	7113	9805	4
31664	7113	9811	9
31665	7113	9814	1
31666	7113	9815	7
31667	7113	9816	7
31668	7114	9817	5
31669	7114	9818	10
31670	7114	9819	5
31671	7114	9820	5
31672	7114	9816	1
31673	7115	9821	7
31674	7115	9822	9
31675	7115	9823	6
31676	7115	9824	3
31677	7115	9825	2
31678	7116	9826	14
31679	7116	9827	14
31680	7116	9828	9
31681	7117	9829	4
31682	7117	9830	7
31683	7117	9831	8
31684	7117	9832	4
31685	7117	9833	12
31686	7118	9834	2
31687	7118	9826	14
31688	7118	9835	8
31689	7118	9836	1
31690	7118	9837	2
31691	7118	9838	4
31692	7118	9839	1
31693	7119	9840	13
31694	7119	9841	9
31695	7119	9842	11
31696	7119	9843	9
31697	7119	9844	9
31698	7120	9845	8
31699	7120	9846	6
31700	7120	9847	9
31701	7120	9848	3
31702	7120	9836	6
31703	7120	9849	5
31704	7121	9850	6
31705	7121	9851	11
31706	7121	9852	4
31707	7121	9853	4
31708	7121	9854	6
31709	7122	9855	8
31710	7122	9856	4
31711	7122	9857	8
31712	7122	9858	5
31713	7122	9859	8
31714	7123	9860	5
31715	7123	9861	3
31716	7123	9862	3
31717	7123	9863	9
31718	7123	9864	4
31719	7124	9865	3
31720	7124	9866	9
31721	7124	9867	6
31722	7124	9868	4
31723	7124	9864	5
31724	7125	9869	5
31725	7125	9870	5
31726	7125	9871	4
31727	7125	9872	7
31728	7125	9859	2
31729	7126	9873	9
31730	7126	9874	3
31731	7126	9875	2
31732	7126	9868	4
31733	7126	9864	3
31734	7127	9876	14
31735	7128	9877	9
31736	7129	9878	4
31737	7130	9879	9
31738	7131	9880	8
31739	7132	9881	7
31740	7133	9882	8
31741	7134	9883	2
31742	7134	9884	4
31743	7135	9885	14
31744	7135	9886	4
31745	7135	9887	7
31746	7135	9888	11
31747	7135	9889	8
31748	7135	9890	12
31749	7135	9891	11
31750	7135	9892	1
31751	7136	9893	8
31752	7136	9894	11
31753	7136	9889	8
31754	7136	9895	12
31755	7136	9896	2
31756	7136	9897	5
31757	7136	9898	14
31758	7136	9899	4
31759	7137	9900	9
31760	7137	9901	9
31761	7137	9885	14
31762	7137	9886	5
31763	7137	9902	9
31764	7137	9890	8
31765	7137	9891	7
31766	7138	9885	14
31767	7138	9886	3
31768	7138	9903	2
31769	7138	9888	9
31770	7138	9904	9
31771	7138	9905	9
31772	7138	9899	8
31773	7139	9906	3
31774	7139	9907	7
31775	7139	9908	11
31776	7139	9909	7
31777	7140	9910	7
31778	7140	9911	7
31779	7140	9912	1
31780	7140	9913	2
31781	7140	9914	7
31782	7141	9915	5
31783	7141	9916	9
31784	7141	9917	2
31785	7141	9918	4
31786	7141	9919	5
31787	7142	9920	4
31788	7142	9921	8
31789	7142	9922	1
31790	7142	9914	8
31791	7143	9923	6
31792	7143	9924	8
31793	7143	9925	2
31794	7143	9926	9
31795	7144	9927	4
31796	7144	9928	4
31797	7144	9929	9
31798	7144	9930	13
31799	7145	9931	6
31800	7145	9932	9
31801	7145	9933	6
31802	7145	9934	6
31803	7145	9914	4
31804	7146	9935	3
31805	7146	9936	8
31806	7146	9911	9
31807	7146	9937	2
31808	7146	9919	8
31809	7147	9938	5
31810	7147	9939	7
31811	7147	9940	1
31812	7147	9917	2
31813	7147	9941	2
31814	7148	9942	1
31815	7148	9943	5
31816	7148	9944	3
31817	7148	9945	11
31818	7148	9946	2
31819	7149	9942	1
31820	7149	9943	5
31821	7149	9944	3
31822	7149	9945	11
31823	7149	9946	2
31824	7150	9947	4
31825	7150	9943	7
31826	7150	9948	11
31827	7150	9949	10
31828	7150	9950	5
31829	7151	9942	1
31830	7151	9943	5
31831	7151	9944	9
31832	7151	9945	8
31833	7151	9946	4
31834	7152	9951	12
31835	7152	9952	7
31836	7152	9948	7
31837	7152	9953	11
31838	7152	9950	2
31839	7153	9942	1
31840	7153	9943	4
31841	7153	9944	8
31842	7153	9945	6
31843	7153	9946	3
31844	7154	9942	2
31845	7154	9943	7
31846	7154	9944	1
31847	7154	9945	5
31848	7154	9946	1
31849	7155	9954	7
31850	7155	9955	9
31851	7155	9956	3
31852	7155	9957	3
31853	7155	9930	5
31854	7156	9942	1
31855	7156	9943	6
31856	7156	9944	3
31857	7156	9945	8
31858	7156	9946	3
31859	7157	9954	4
31860	7157	9955	6
31861	7157	9958	6
31862	7157	9959	1
31863	7157	9930	1
31864	7158	9960	9
31865	7159	9961	11
31866	7159	9962	6
31867	7159	9963	5
31868	7159	9964	2
31869	7159	9965	12
31870	7159	9966	6
31871	7160	9967	4
31872	7160	9968	3
31873	7160	9969	4
31874	7160	9970	8
31875	7160	9971	5
31876	7160	9972	12
31877	7160	9973	12
31878	7161	9974	11
31879	7161	9975	5
31880	7161	9976	10
31881	7161	9977	11
31882	7161	9978	9
31883	7161	9979	12
31884	7161	9980	11
31885	7162	9981	13
31886	7162	9982	6
31887	7162	9983	5
31888	7162	9978	2
31889	7162	9984	2
31890	7162	9980	5
31891	7163	9985	9
31892	7163	9986	13
31893	7163	9987	5
31894	7163	9988	13
31895	7163	9989	7
31896	7164	9990	13
31897	7164	9991	3
31898	7164	9992	7
31899	7164	9993	7
31900	7164	9994	3
31901	7164	9988	8
31902	7165	9995	9
31903	7165	9996	11
31904	7165	9991	8
31905	7165	9997	9
31906	7165	9998	11
31907	7165	9999	2
31908	7166	10000	4
31909	7166	9991	6
31910	7166	10001	11
31911	7166	10002	9
31912	7166	10003	5
31913	7166	10004	11
31914	7167	10005	9
31915	7167	10006	8
31916	7167	10007	11
31917	7167	10002	10
31918	7167	10008	11
31919	7168	10009	12
31920	7168	10010	6
31921	7168	10011	8
31922	7168	10012	10
31923	7168	10013	7
31924	7168	10014	6
31925	7169	10015	6
31926	7169	9995	8
31927	7169	10016	9
31928	7169	9991	4
31929	7169	10012	13
31930	7169	10004	8
31931	7170	10017	2
31932	7170	10001	11
31933	7170	10018	9
31934	7170	9992	11
31935	7170	10004	11
31936	7171	10019	5
31937	7171	10020	11
31938	7171	10021	2
31939	7171	10022	3
31940	7171	10023	4
31941	7172	10024	7
31942	7172	10025	9
31943	7172	10021	4
31944	7172	10026	5
31945	7172	10023	3
31946	7173	10027	8
31947	7173	10025	9
31948	7173	10021	5
31949	7173	10026	6
31950	7173	10023	7
31951	7174	10028	4
31952	7174	10029	8
31953	7174	9974	8
31954	7174	10030	7
31955	7174	10031	6
31956	7175	10032	4
31957	7175	10033	9
31958	7175	10021	6
31959	7175	10034	1
31960	7175	10023	9
31961	7176	10035	13
31962	7176	10036	11
31963	7176	10037	5
31964	7176	10038	6
31965	7176	10039	3
31966	7177	10040	4
31967	7177	10041	11
31968	7177	9993	8
31969	7177	10042	5
31970	7177	10023	5
31971	7178	10024	5
31972	7178	10025	5
31973	7178	10021	5
31974	7178	10026	6
31975	7178	10023	2
31976	7179	10043	4
31977	7179	10044	4
31978	7179	10045	7
31979	7179	10046	2
31980	7179	10047	1
31981	7180	10048	3
31982	7180	10049	3
31983	7180	10025	7
31984	7180	10050	3
31985	7180	10008	3
31986	7181	10051	1
31987	7181	10052	7
31988	7181	10053	4
31989	7181	10054	2
31990	7181	10039	2
31991	7182	10055	3
31992	7183	10056	12
31993	7184	10057	3
31994	7184	10058	9
31995	7185	10059	4
31996	7186	10060	5
31997	7187	10061	6
31998	7187	10062	5
31999	7188	10058	11
32000	7189	10063	4
32001	7189	10064	6
32002	7190	10065	4
32003	7191	10066	3
32004	7192	10067	9
32005	7193	10068	3
32006	7194	10069	5
32007	7195	10070	6
32008	7195	10071	11
32009	7195	10072	7
32010	7195	10073	8
32011	7195	10074	2
32012	7195	10075	9
32013	7196	10076	13
32014	7196	10077	14
32015	7196	10078	13
32016	7196	10079	14
32017	7196	10080	9
32018	7196	10081	9
32019	7196	10082	11
32020	7197	10083	4
32021	7197	10084	6
32022	7197	10085	1
32023	7197	10086	4
32024	7197	10087	1
32025	7198	10088	6
32026	7198	10089	3
32027	7198	10090	11
32028	7198	10091	6
32029	7198	10092	7
32030	7199	10093	5
32031	7199	10094	7
32032	7199	10072	6
32033	7199	10095	3
32034	7199	10096	3
32035	7200	10097	2
32036	7200	10098	9
32037	7200	10099	11
32038	7200	10100	5
32039	7200	10101	6
32040	7201	10102	7
32041	7201	10103	11
32042	7201	10100	3
32043	7201	10104	2
32044	7201	10101	8
32045	7202	10105	8
32046	7202	10106	7
32047	7202	10107	5
32048	7202	10108	2
32049	7203	10109	5
32050	7203	10110	4
32051	7203	10099	8
32052	7203	10108	4
32053	7203	10111	11
32054	7203	10101	6
32055	7204	10112	7
32056	7204	10111	11
32057	7204	10078	7
32058	7204	10100	7
32059	7204	10113	7
32060	7204	10073	6
32061	7205	10114	3
32062	7205	10102	8
32063	7205	10111	8
32064	7205	10100	4
32065	7205	10104	2
32066	7206	10115	12
32067	7206	10116	9
32068	7206	10117	7
32069	7206	10118	6
32070	7206	10119	2
32071	7207	10120	2
32072	7207	10121	4
32073	7207	10122	7
32074	7207	10123	2
32075	7207	10124	7
32076	7208	10125	8
32077	7208	10118	5
32078	7208	10126	4
32079	7208	10127	4
32080	7208	10119	3
32081	7209	10128	9
32082	7209	10125	9
32083	7209	10118	6
32084	7209	10129	8
32085	7209	10130	13
32086	7210	10131	6
32087	7210	10132	9
32088	7210	10118	9
32089	7210	10133	4
32090	7210	10119	7
32091	7211	10134	4
32092	7211	10135	9
32093	7211	10136	9
32094	7211	10119	8
32095	7212	10137	6
32096	7212	10116	10
32097	7212	10118	11
32098	7212	10138	6
32099	7213	10139	3
32100	7213	10140	2
32101	7213	10135	9
32102	7213	10136	7
32103	7213	10119	6
32104	7214	10141	5
32105	7214	10142	7
32106	7214	10143	7
32107	7214	10118	6
32108	7214	10119	7
32109	7215	10144	5
32110	7215	10145	11
32111	7215	10136	9
32112	7215	10146	6
32113	7215	10119	1
32114	7216	10147	8
32115	7216	10117	6
32116	7216	10136	6
32117	7216	10148	9
32118	7216	10149	8
32119	7217	10150	3
32120	7217	10151	7
32121	7217	10152	7
32122	7217	10153	6
32123	7217	10130	2
32124	7218	10154	3
32125	7218	10155	6
32126	7218	10156	9
32127	7218	10157	2
32128	7218	10158	3
32129	7219	10159	4
32130	7219	10160	7
32131	7219	10161	2
32132	7219	10162	5
32133	7219	10123	1
32134	7220	10163	4
32135	7220	10121	6
32136	7220	10164	6
32137	7220	10165	7
32138	7220	10166	6
32139	7221	10167	2
32140	7221	10168	9
32141	7221	10169	3
32142	7221	10170	3
32143	7221	10171	6
32144	7222	10172	7
32145	7222	10173	6
32146	7222	10174	8
32147	7222	10175	11
32148	7222	10166	6
32149	7223	10154	3
32150	7223	10155	9
32151	7223	10156	5
32152	7223	10157	9
32153	7223	10158	8
32154	7224	10176	6
32155	7224	10177	6
32156	7224	10178	4
32157	7224	10179	2
32158	7224	10166	6
32159	7225	10180	7
32160	7225	10121	5
32161	7225	10174	5
32162	7225	10181	9
32163	7225	10166	1
32164	7226	10154	3
32165	7226	10155	7
32166	7226	10156	6
32167	7226	10157	3
32168	7226	10158	6
32169	7227	10182	8
32170	7227	10155	8
32171	7227	10177	8
32172	7227	10157	9
32173	7227	10158	9
32174	7228	10183	4
32175	7228	10168	6
32176	7228	10184	5
32177	7228	10185	4
32178	7228	10171	5
32179	7229	10186	8
32180	7229	10187	11
32181	7229	10188	3
32182	7229	10189	8
32183	7229	10190	7
32184	7230	10191	6
32185	7230	10168	9
32186	7230	10192	5
32187	7230	10193	10
32188	7230	10171	7
32189	7231	10154	4
32190	7231	10155	6
32191	7231	10156	8
32192	7231	10157	3
32193	7231	10158	6
32194	7232	10194	6
32195	7232	10177	5
32196	7232	10195	5
32197	7232	10196	4
32198	7232	10197	1
32199	7233	10198	4
32200	7233	10199	6
32201	7233	10169	4
32202	7233	10200	2
32203	7233	10123	1
32204	7234	10201	6
32205	7234	10202	7
32206	7234	10203	6
32207	7234	10204	2
32208	7234	10166	6
32209	7235	10205	5
32210	7235	10132	4
32211	7235	10160	7
32212	7235	10206	7
32213	7235	10190	1
32214	7236	10207	3
32215	7236	10208	9
32216	7236	10209	8
32217	7236	10210	4
32218	7236	10123	1
32219	7237	10211	6
32220	7237	10212	5
32221	7237	10213	4
32222	7237	10214	6
32223	7237	10166	5
32224	7238	10215	5
32225	7238	10216	11
32226	7238	10217	4
32227	7238	10218	12
32228	7238	10166	5
32229	7239	10194	7
32230	7239	10177	8
32231	7239	10195	7
32232	7239	10196	3
32233	7239	10197	4
32234	7240	10219	6
32235	7240	10208	10
32236	7240	10220	8
32237	7240	10210	3
32238	7240	10123	11
32239	7241	10201	5
32240	7241	10202	8
32241	7241	10203	5
32242	7241	10204	1
32243	7241	10190	5
32244	7242	10194	6
32245	7242	10177	4
32246	7242	10195	8
32247	7242	10196	4
32248	7242	10197	1
32249	7243	10221	4
32250	7243	10168	7
32251	7243	10206	4
32252	7243	10222	8
32253	7243	10171	6
32254	7244	10223	7
32255	7244	10224	9
32256	7244	10192	5
32257	7244	10179	2
32258	7244	10190	6
32259	7245	10225	4
32260	7245	10168	8
32261	7245	10206	5
32262	7245	10222	9
32263	7245	10171	8
32264	7246	10226	3
32265	7246	10168	4
32266	7246	10227	9
32267	7246	10228	4
32268	7246	10171	3
32269	7247	10229	12
32270	7247	10168	1
32271	7247	10230	8
32272	7247	10222	7
32273	7247	10171	5
32274	7248	10194	4
32275	7248	10177	9
32276	7248	10195	9
32277	7248	10196	4
32278	7248	10197	5
32279	7249	10231	1
32280	7249	10232	3
32281	7249	10233	8
32282	7249	10234	3
32283	7249	10235	4
32284	7250	10236	5
32285	7250	10237	5
32286	7250	10238	2
32287	7250	10239	7
32288	7250	10235	5
32289	7251	10240	1
32290	7251	10241	2
32291	7251	10233	11
32292	7251	10242	1
32293	7251	10235	11
32294	7252	10243	8
32295	7252	10244	12
32296	7252	10245	8
32297	7252	10246	10
32298	7252	10247	7
32299	7253	10248	5
32300	7253	10249	6
32301	7253	10250	12
32302	7253	10251	3
32303	7253	10252	12
32304	7253	10253	3
32305	7254	10243	6
32306	7254	10254	14
32307	7254	10255	4
32308	7254	10256	7
32309	7254	10250	9
32310	7254	10257	12
32311	7254	10258	11
32312	7255	10259	7
32313	7255	10260	5
32314	7255	10261	2
32315	7255	10262	2
32316	7255	10257	3
32317	7255	10263	12
32318	7255	10264	7
32319	7256	10245	7
32320	7256	10265	8
32321	7256	10266	5
32322	7256	10267	8
32323	7256	10268	6
32324	7257	10269	2
32325	7257	10270	11
32326	7257	10271	6
32327	7257	10267	8
32328	7257	10272	6
32329	7257	10273	2
32330	7258	10274	7
32331	7258	10275	8
32332	7258	10266	7
32333	7258	10271	7
32334	7258	10276	9
32335	7259	10277	6
32336	7259	10278	6
32337	7259	10279	11
32338	7259	10280	8
32339	7259	10281	12
32340	7259	10282	5
32341	7260	10283	9
32342	7260	10284	13
32343	7260	10285	7
32344	7260	10286	7
32345	7260	10287	3
32346	7260	10288	6
32347	7261	10287	5
32348	7261	10289	11
32349	7261	10266	1
32350	7261	10281	7
32351	7261	10288	5
32352	7262	10290	4
32353	7262	10256	12
32354	7262	10276	5
32355	7262	10251	6
32356	7262	10291	3
32357	7262	10292	12
32358	7262	10293	11
32359	7263	10270	11
32360	7263	10294	8
32361	7263	10256	5
32362	7263	10267	9
32363	7263	10295	5
32364	7264	10296	12
32365	7264	10297	11
32366	7264	10298	8
32367	7264	10299	1
32368	7264	10294	7
32369	7264	10300	5
32370	7265	10301	8
32371	7265	10302	7
32372	7265	10303	9
32373	7265	10304	6
32374	7265	10305	7
32375	7266	10245	7
32376	7266	10286	8
32377	7266	10306	6
32378	7266	10307	3
32379	7266	10308	6
32380	7266	10266	8
32381	7267	10309	10
32382	7267	10306	8
32383	7267	10310	5
32384	7267	10266	11
32385	7267	10288	9
32386	7268	10311	8
32387	7268	10312	13
32388	7268	10313	13
32389	7268	10314	6
32390	7268	10266	9
32391	7269	10315	2
32392	7269	10316	9
32393	7269	10245	8
32394	7269	10317	9
32395	7269	10318	6
32396	7269	10319	13
32397	7270	10320	6
32398	7270	10321	4
32399	7270	10322	7
32400	7270	10323	5
32401	7270	10280	3
32402	7271	10324	4
32403	7271	10285	9
32404	7271	10325	11
32405	7271	10294	13
32406	7271	10326	12
32407	7272	10285	6
32408	7272	10327	11
32409	7272	10328	9
32410	7272	10329	5
32411	7272	10319	7
32412	7273	10330	5
32413	7273	10331	9
32414	7273	10321	11
32415	7273	10306	11
32416	7273	10266	5
32417	7274	10332	4
32418	7274	10333	5
32419	7274	10334	9
32420	7274	10335	1
32421	7274	10280	13
32422	7274	10293	8
32423	7275	10336	3
32424	7275	10337	9
32425	7275	10338	5
32426	7275	10339	5
32427	7275	10340	6
32428	7276	10341	2
32429	7276	10245	6
32430	7276	10327	8
32431	7276	10342	6
32432	7276	10266	9
32433	7276	10343	3
32434	7277	10344	4
32435	7277	10345	5
32436	7277	10346	6
32437	7277	10347	7
32438	7277	10348	3
32439	7278	10349	4
32440	7278	10350	5
32441	7278	10351	2
32442	7278	10352	3
32443	7278	10353	2
32444	7279	10354	6
32445	7279	10355	9
32446	7279	10356	6
32447	7279	10357	9
32448	7279	10358	6
32449	7280	10359	2
32450	7280	10360	11
32451	7280	10278	8
32452	7280	10361	1
32453	7280	10305	5
32454	7281	10362	5
32455	7281	10363	7
32456	7281	10364	8
32457	7281	10365	4
32458	7281	10353	7
32459	7282	10366	7
32460	7282	10367	5
32461	7282	10346	10
32462	7282	10368	2
32463	7282	10369	9
32464	7283	10370	12
32465	7283	10371	9
32466	7283	10372	2
32467	7283	10373	3
32468	7283	10247	3
32469	7284	10374	5
32470	7284	10375	6
32471	7284	10376	7
32472	7284	10377	5
32473	7284	10369	1
32474	7285	10378	5
32475	7285	10344	4
32476	7285	10355	8
32477	7285	10379	2
32478	7285	10369	7
32479	7286	10380	9
32480	7286	10375	7
32481	7286	10381	8
32482	7286	10382	13
32483	7286	10383	9
32484	7287	10384	4
32485	7287	10337	6
32486	7287	10278	7
32487	7287	10385	8
32488	7287	10305	5
32489	7288	10386	3
32490	7288	10387	8
32491	7288	10249	6
32492	7288	10299	2
32493	7288	10358	10
32494	7289	10384	5
32495	7289	10388	10
32496	7289	10389	11
32497	7289	10390	8
32498	7289	10305	5
32499	7290	10391	6
32500	7290	10346	7
32501	7290	10392	2
32502	7290	10335	3
32503	7290	10369	6
32504	7291	10393	8
32505	7291	10394	3
32506	7291	10395	8
32507	7291	10396	5
32508	7291	10353	1
32509	7292	10397	2
32510	7292	10398	6
32511	7292	10357	4
32512	7292	10399	4
32513	7292	10383	6
32514	7293	10400	5
32515	7293	10401	8
32516	7293	10402	7
32517	7293	10368	2
32518	7293	10353	3
32519	7294	10403	8
32520	7294	10364	9
32521	7294	10404	5
32522	7294	10405	2
32523	7294	10305	4
32524	7295	10406	7
32525	7295	10407	11
32526	7295	10408	6
32527	7295	10255	6
32528	7295	10399	8
32529	7296	10409	8
32530	7296	10410	10
32531	7296	10375	3
32532	7296	10411	2
32533	7296	10412	6
32534	7296	10399	8
32535	7297	10413	2
32536	7297	10414	7
32537	7297	10415	5
32538	7297	10338	4
32539	7297	10358	3
32540	7298	10416	5
32541	7298	10394	3
32542	7298	10398	8
32543	7298	10417	6
32544	7298	10305	7
32545	7299	10418	4
32546	7299	10419	13
32547	7299	10415	4
32548	7299	10420	1
32549	7299	10348	2
32550	7300	10400	5
32551	7300	10421	9
32552	7300	10402	7
32553	7300	10368	2
32554	7300	10373	9
32555	7301	10422	4
32556	7301	10394	4
32557	7301	10360	9
32558	7301	10423	5
32559	7301	10353	1
32560	7302	10424	2
32561	7302	10425	6
32562	7302	10426	4
32563	7302	10255	6
32564	7302	10305	5
32565	7303	10427	3
32566	7303	10428	9
32567	7303	10429	4
32568	7303	10417	4
32569	7303	10373	6
32570	7304	10430	5
32571	7304	10388	9
32572	7304	10389	8
32573	7304	10431	7
32574	7304	10305	7
32575	7305	10432	4
32576	7305	10401	3
32577	7305	10278	8
32578	7305	10405	5
32579	7305	10358	3
32580	7306	10433	7
32581	7306	10346	6
32582	7306	10356	7
32583	7306	10434	12
32584	7306	10305	9
32585	7307	10435	3
32586	7307	10436	4
32587	7307	10437	11
32588	7307	10438	7
32589	7307	10369	8
32590	7308	10374	5
32591	7308	10346	7
32592	7308	10423	7
32593	7308	10439	5
32594	7308	10399	8
32595	7309	10341	3
32596	7309	10419	7
32597	7309	10440	11
32598	7309	10441	2
32599	7309	10353	4
32600	7310	10442	2
32601	7310	10443	8
32602	7310	10444	4
32603	7310	10445	5
32604	7310	10340	8
32605	7311	10446	8
32606	7312	10447	4
32607	7312	10448	6
32608	7313	10449	2
32609	7314	10450	2
32610	7315	10451	4
32611	7316	10452	3
32612	7316	10453	5
32613	7316	10454	9
32614	7317	10455	3
32615	7317	10456	6
32616	7318	10457	6
32617	7319	10458	8
32618	7320	10459	8
32619	7321	10460	1
32620	7322	10461	9
32621	7323	10462	11
32622	7323	10456	7
32623	7324	10463	6
32624	7324	10464	8
32625	7325	10465	9
32626	7326	10466	8
32627	7327	10467	4
32628	7327	10468	2
32629	7328	10469	9
32630	7329	10470	9
32631	7330	10471	8
32632	7331	10472	2
32633	7331	10473	1
32634	7332	10474	3
32635	7333	10475	6
32636	7334	10476	11
32637	7335	10477	9
32638	7335	10478	6
32639	7336	10479	9
32640	7337	10480	3
32641	7337	10468	3
32642	7338	10481	3
32643	7338	10482	4
32644	7339	10476	11
32645	7340	10465	5
32646	7341	10474	9
32647	7342	10483	6
32648	7342	10469	7
32649	7343	10484	1
32650	7344	10485	8
32651	7345	10486	4
32652	7346	10487	12
32653	7346	10488	9
32654	7346	10489	11
32655	7346	10490	11
32656	7346	10491	11
32657	7347	10492	7
32658	7348	10493	13
32659	7348	10494	4
32660	7348	10495	11
32661	7348	10496	9
32662	7348	10488	5
32663	7348	10497	5
32664	7348	10498	2
32665	7349	10499	6
32666	7349	10500	4
32667	7349	10498	12
32668	7350	10501	5
32669	7350	10502	5
32670	7350	10503	14
32671	7350	10488	5
32672	7350	10504	4
32673	7350	10505	4
32674	7350	10506	13
32675	7351	10507	11
32676	7351	10508	9
32677	7351	10497	11
32678	7351	10509	2
32679	7351	10510	12
32680	7352	10494	2
32681	7352	10511	4
32682	7352	10512	13
32683	7352	10513	11
32684	7352	10514	5
32685	7352	10515	8
32686	7353	10516	7
32687	7353	10517	13
32688	7353	10513	9
32689	7353	10488	8
32690	7353	10514	5
32691	7353	10518	6
32692	7354	10519	5
32693	7354	10520	2
32694	7354	10521	2
32695	7354	10522	2
32696	7354	10523	8
32697	7355	10524	6
32698	7355	10525	5
32699	7355	10502	13
32700	7355	10526	14
32701	7355	10527	9
32702	7355	10528	8
32703	7355	10506	10
32704	7356	10529	4
32705	7356	10530	13
32706	7356	10488	8
32707	7356	10489	9
32708	7356	10504	4
32709	7357	10531	3
32710	7357	10502	11
32711	7357	10532	14
32712	7357	10533	8
32713	7357	10513	9
32714	7357	10518	4
32715	7357	10510	7
32716	7357	10491	8
32717	7358	10507	9
32718	7358	10534	3
32719	7358	10504	5
32720	7358	10497	6
32721	7358	10505	5
32722	7358	10506	11
32723	7359	10535	7
32724	7359	10502	11
32725	7359	10526	14
32726	7359	10488	5
32727	7359	10536	5
32728	7359	10514	12
32729	7359	10537	11
32730	7360	10538	6
32731	7360	10539	11
32732	7360	10540	10
32733	7360	10502	8
32734	7360	10532	14
32735	7360	10541	4
32736	7361	10542	4
32737	7361	10540	6
32738	7361	10502	7
32739	7361	10543	14
32740	7361	10544	5
32741	7361	10545	4
32742	7362	10546	4
32743	7362	10502	2
32744	7362	10532	14
32745	7362	10547	9
32746	7362	10536	5
32747	7362	10514	7
32748	7362	10548	11
32749	7362	10506	9
32750	7363	10549	5
32751	7363	10501	6
32752	7363	10502	11
32753	7363	10532	14
32754	7363	10527	9
32755	7363	10528	9
32756	7363	10537	9
32757	7364	10539	13
32758	7364	10540	11
32759	7364	10550	10
32760	7364	10551	9
32761	7364	10552	9
32762	7365	10553	3
32763	7365	10536	4
32764	7365	10509	4
32765	7365	10554	7
32766	7365	10506	11
32767	7366	10555	11
32768	7366	10556	11
32769	7366	10557	2
32770	7366	10558	6
32771	7366	10490	12
32772	7367	10559	8
32773	7367	10527	6
32774	7367	10528	9
32775	7367	10509	4
32776	7367	10560	4
32777	7367	10506	11
32778	7368	10561	13
32779	7368	10502	11
32780	7368	10526	14
32781	7368	10488	8
32782	7368	10536	3
32783	7368	10514	5
32784	7368	10537	8
32785	7369	10540	10
32786	7369	10502	11
32787	7369	10543	14
32788	7369	10488	6
32789	7369	10489	6
32790	7369	10504	5
32791	7369	10537	11
32792	7370	10562	6
32793	7370	10563	8
32794	7370	10502	5
32795	7370	10532	14
32796	7370	10527	3
32797	7370	10489	4
32798	7371	10564	2
32799	7371	10565	5
32800	7371	10566	11
32801	7371	10567	8
32802	7371	10522	4
32803	7372	10568	5
32804	7372	10502	6
32805	7372	10503	14
32806	7372	10488	3
32807	7372	10551	2
32808	7372	10514	6
32809	7372	10537	8
32810	7373	10569	4
32811	7373	10570	4
32812	7373	10571	11
32813	7373	10572	9
32814	7373	10573	4
32815	7374	10574	4
32816	7374	10575	3
32817	7374	10576	9
32818	7374	10577	9
32819	7374	10573	8
32820	7375	10578	3
32821	7375	10579	7
32822	7375	10580	8
32823	7375	10522	2
32824	7376	10581	2
32825	7376	10582	9
32826	7376	10583	3
32827	7376	10584	11
32828	7377	10585	5
32829	7377	10586	5
32830	7377	10587	5
32831	7377	10588	5
32832	7377	10541	2
32833	7378	10589	2
32834	7378	10590	9
32835	7378	10583	7
32836	7378	10591	7
32837	7378	10592	7
32838	7379	10593	3
32839	7379	10594	2
32840	7379	10571	7
32841	7379	10595	7
32842	7379	10573	5
32843	7380	10596	1
32844	7380	10597	9
32845	7380	10598	7
32846	7380	10599	3
32847	7380	10592	5
32848	7381	10600	11
32849	7381	10601	8
32850	7381	10602	2
32851	7381	10603	6
32852	7382	10604	5
32853	7382	10605	9
32854	7382	10606	11
32855	7382	10591	9
32856	7383	10607	3
32857	7383	10608	9
32858	7383	10609	7
32859	7383	10610	3
32860	7383	10541	7
32861	7384	10594	3
32862	7384	10611	3
32863	7384	10571	7
32864	7384	10612	8
32865	7384	10613	13
32866	7385	10594	3
32867	7385	10614	3
32868	7385	10587	7
32869	7385	10615	1
32870	7385	10613	9
32871	7386	10616	4
32872	7386	10579	7
32873	7386	10617	7
32874	7386	10541	1
32875	7387	10618	8
32876	7387	10619	9
32877	7387	10620	7
32878	7387	10621	3
32879	7387	10573	6
32880	7388	10622	11
32881	7388	10623	9
32882	7388	10624	8
32883	7388	10625	7
32884	7388	10603	3
32885	7389	10626	2
32886	7389	10627	7
32887	7389	10628	11
32888	7389	10629	3
32889	7389	10522	5
32890	7390	10630	12
32891	7390	10571	8
32892	7390	10612	9
32893	7390	10613	6
32894	7391	10631	2
32895	7391	10632	1
32896	7391	10582	13
32897	7391	10633	7
32898	7391	10522	3
32899	7392	10634	1
32900	7392	10635	7
32901	7392	10598	6
32902	7392	10636	5
32903	7392	10592	7
32904	7393	10637	5
32905	7393	10638	5
32906	7393	10639	9
32907	7393	10580	9
32908	7393	10522	2
32909	7394	10640	7
32910	7394	10641	9
32911	7394	10601	5
32912	7394	10603	9
32913	7395	10586	5
32914	7395	10642	9
32915	7395	10643	1
32916	7395	10644	5
32917	7395	10557	4
32918	7396	10645	2
32919	7396	10646	3
32920	7396	10647	3
32921	7396	10557	2
32922	7396	10527	4
32923	7397	10648	2
32924	7397	10649	5
32925	7397	10650	5
32926	7397	10541	4
32927	7397	10651	3
32928	7398	10652	3
32929	7398	10653	3
32930	7398	10654	8
32931	7398	10601	7
32932	7398	10592	9
32933	7399	10653	4
32934	7399	10655	9
32935	7399	10583	7
32936	7399	10656	8
32937	7399	10603	7
32938	7400	10657	4
32939	7400	10658	8
32940	7400	10659	9
32941	7400	10603	5
32942	7401	10586	11
32943	7401	10623	11
32944	7401	10660	12
32945	7401	10603	12
32946	7401	10527	11
32947	7402	10661	3
32948	7402	10649	7
32949	7402	10595	9
32950	7402	10662	5
32951	7402	10557	3
32952	7403	10663	4
32953	7403	10582	9
32954	7403	10583	5
32955	7403	10544	3
32956	7404	10664	3
32957	7404	10597	9
32958	7404	10665	6
32959	7404	10541	7
32960	7405	10666	2
32961	7405	10663	4
32962	7405	10582	8
32963	7405	10583	6
32964	7405	10544	4
32965	7406	10667	4
32966	7406	10654	9
32967	7406	10598	6
32968	7406	10662	2
32969	7406	10522	6
32970	7407	10652	3
32971	7407	10635	9
32972	7407	10583	9
32973	7407	10668	4
32974	7407	10592	8
32975	7408	10669	3
32976	7408	10670	9
32977	7408	10601	7
32978	7408	10671	1
32979	7408	10541	5
32980	7408	10527	6
32981	7409	10634	1
32982	7409	10635	9
32983	7409	10598	6
32984	7409	10636	6
32985	7409	10592	8
32986	7410	10672	6
32987	7410	10586	8
32988	7410	10673	7
32989	7410	10674	5
32990	7410	10557	2
32991	7411	10675	5
32992	7411	10676	11
32993	7411	10677	8
32994	7411	10678	4
32995	7411	10592	9
32996	7412	10594	2
32997	7412	10679	2
32998	7412	10680	6
32999	7412	10642	7
33000	7412	10522	3
33001	7413	10681	4
33002	7413	10682	4
33003	7413	10539	11
33004	7413	10683	8
33005	7413	10557	6
33006	7414	10684	7
33007	7414	10685	10
33008	7414	10633	8
33009	7414	10686	7
33010	7414	10541	7
33011	7415	10687	3
33012	7415	10654	13
33013	7415	10642	9
33014	7415	10629	3
33015	7415	10541	8
33016	7416	10688	4
33017	7416	10689	3
33018	7416	10676	7
33019	7416	10690	9
33020	7416	10624	8
33021	7416	10541	8
33022	7417	10691	7
33023	7417	10692	9
33024	7417	10693	12
33025	7417	10541	7
33026	7417	10694	4
33027	7418	10605	9
33028	7418	10601	9
33029	7418	10695	5
33030	7418	10522	9
33031	7419	10696	5
33032	7419	10697	1
33033	7419	10624	4
33034	7419	10698	7
33035	7419	10699	1
33036	7420	10700	5
33037	7420	10697	2
33038	7420	10701	3
33039	7420	10656	6
33040	7420	10699	3
33041	7421	10702	4
33042	7421	10703	8
33043	7421	10704	6
33044	7421	10705	1
33045	7421	10706	3
33046	7422	10707	5
33047	7422	10708	7
33048	7422	10709	5
33049	7422	10674	3
33050	7422	10710	9
33051	7423	10711	5
33052	7423	10712	4
33053	7423	10713	1
33054	7423	10714	1
33055	7423	10715	4
33056	7424	10716	4
33057	7424	10717	6
33058	7424	10718	7
33059	7424	10719	2
33060	7424	10710	3
33061	7425	10720	6
33062	7425	10721	8
33063	7425	10718	6
33064	7425	10722	3
33065	7425	10723	11
33066	7426	10562	5
33067	7426	10724	5
33068	7426	10725	5
33069	7426	10726	8
33070	7426	10710	8
33071	7427	10727	3
33072	7427	10728	6
33073	7427	10729	2
33074	7427	10730	1
33075	7427	10731	8
33076	7428	10702	3
33077	7428	10703	4
33078	7428	10704	4
33079	7428	10705	1
33080	7428	10706	2
33081	7429	10562	4
33082	7429	10732	2
33083	7429	10708	8
33084	7429	10733	1
33085	7429	10710	1
33086	7430	10734	3
33087	7430	10735	6
33088	7430	10712	8
33089	7430	10736	1
33090	7430	10715	7
33091	7431	10702	3
33092	7431	10703	5
33093	7431	10704	11
33094	7431	10705	6
33095	7431	10706	8
33096	7432	10720	5
33097	7432	10721	7
33098	7432	10718	7
33099	7432	10722	2
33100	7432	10723	7
33101	7433	10702	3
33102	7433	10703	6
33103	7433	10704	6
33104	7433	10705	1
33105	7433	10706	1
33106	7434	10720	5
33107	7434	10721	1
33108	7434	10718	4
33109	7434	10722	3
33110	7434	10723	1
33111	7435	10727	4
33112	7435	10728	3
33113	7435	10729	3
33114	7435	10730	3
33115	7435	10731	1
33116	7436	10737	4
33117	7436	10712	11
33118	7436	10713	6
33119	7436	10738	5
33120	7436	10715	8
33121	7437	10739	2
33122	7437	10740	5
33123	7437	10712	7
33124	7437	10715	5
33125	7437	10741	3
33126	7438	10669	1
33127	7438	10742	5
33128	7438	10743	1
33129	7438	10744	8
33130	7438	10544	4
33131	7439	10745	5
33132	7439	10746	6
33133	7439	10718	6
33134	7439	10747	2
33135	7439	10544	4
33136	7440	10748	6
33137	7440	10749	1
33138	7440	10750	2
33139	7440	10544	3
33140	7440	10751	3
33141	7441	10720	6
33142	7441	10721	8
33143	7441	10718	7
33144	7441	10722	3
33145	7441	10723	11
33146	7442	10720	6
33147	7442	10721	5
33148	7442	10718	7
33149	7442	10722	5
33150	7442	10723	7
33151	7443	10752	3
33152	7443	10697	2
33153	7443	10701	2
33154	7443	10753	5
33155	7443	10699	3
33156	7444	10727	4
33157	7444	10728	4
33158	7444	10729	1
33159	7444	10730	1
33160	7444	10731	7
33161	7445	10727	3
33162	7445	10728	5
33163	7445	10729	3
33164	7445	10730	2
33165	7445	10731	4
33166	7446	10754	7
33167	7446	10755	8
33168	7446	10709	4
33169	7446	10756	4
33170	7446	10710	8
33171	7447	10757	4
33172	7447	10697	3
33173	7447	10750	3
33174	7447	10758	8
33175	7447	10699	5
33176	7448	10720	5
33177	7448	10721	8
33178	7448	10718	4
33179	7448	10722	4
33180	7448	10723	9
33181	7449	10759	3
33182	7449	10740	5
33183	7449	10712	11
33184	7449	10760	6
33185	7449	10715	8
33186	7450	10761	5
33187	7450	10712	4
33188	7450	10624	7
33189	7450	10762	1
33190	7450	10715	4
33191	7451	10696	5
33192	7451	10697	1
33193	7451	10591	4
33194	7451	10763	1
33195	7451	10699	2
33196	7452	10764	5
33197	7452	10712	5
33198	7452	10713	2
33199	7452	10744	6
33200	7452	10715	5
33201	7453	10696	4
33202	7453	10697	4
33203	7453	10765	2
33204	7453	10766	2
33205	7453	10699	3
33206	7454	10767	3
33207	7454	10697	6
33208	7454	10743	7
33209	7454	10768	1
33210	7454	10699	3
33211	7455	10769	4
33212	7455	10712	11
33213	7455	10765	2
33214	7455	10770	5
33215	7455	10715	5
33216	7456	10771	6
33217	7456	10732	6
33218	7456	10772	9
33219	7456	10773	5
33220	7456	10710	9
33221	7457	10720	6
33222	7457	10721	8
33223	7457	10718	6
33224	7457	10722	5
33225	7457	10723	2
33226	7458	10720	6
33227	7458	10721	6
33228	7458	10718	4
33229	7458	10722	7
33230	7458	10723	1
33231	7459	10711	5
33232	7459	10712	7
33233	7459	10591	7
33234	7459	10760	5
33235	7459	10715	4
33236	7460	10754	7
33237	7460	10774	1
33238	7460	10725	4
33239	7460	10775	3
33240	7460	10715	5
33241	7461	10702	3
33242	7461	10703	4
33243	7461	10704	5
33244	7461	10705	1
33245	7461	10706	1
33246	7462	10720	5
33247	7462	10721	8
33248	7462	10718	8
33249	7462	10722	6
33250	7462	10723	5
33251	7463	10776	3
33252	7463	10777	3
33253	7463	10697	4
33254	7463	10743	2
33255	7463	10699	2
33256	7464	10727	4
33257	7464	10728	6
33258	7464	10729	3
33259	7464	10730	1
33260	7464	10731	1
33261	7465	10778	5
33262	7465	10779	7
33263	7465	10729	1
33264	7465	10780	5
33265	7465	10710	9
33266	7466	10702	4
33267	7466	10703	5
33268	7466	10704	2
33269	7466	10705	2
33270	7466	10706	3
33271	7467	10727	2
33272	7467	10728	4
33273	7467	10729	1
33274	7467	10730	1
33275	7467	10731	1
33276	7468	10707	5
33277	7468	10732	4
33278	7468	10708	9
33279	7468	10781	6
33280	7468	10710	5
33281	7469	10782	3
33282	7469	10732	7
33283	7469	10783	8
33284	7469	10662	2
33285	7469	10710	7
33286	7470	10702	2
33287	7470	10703	4
33288	7470	10704	5
33289	7470	10705	1
33290	7470	10706	1
33291	7471	10702	4
33292	7471	10703	5
33293	7471	10704	9
33294	7471	10705	2
33295	7471	10706	2
33296	7472	10702	3
33297	7472	10703	5
33298	7472	10704	6
33299	7472	10705	2
33300	7472	10706	3
33301	7473	10784	3
33302	7473	10697	2
33303	7473	10750	5
33304	7473	10785	1
33305	7473	10699	3
33306	7474	10720	7
33307	7474	10721	6
33308	7474	10718	7
33309	7474	10722	6
33310	7474	10723	6
33311	7475	10759	9
33312	7475	10712	6
33313	7475	10624	3
33314	7475	10758	9
33315	7475	10715	1
33316	7476	10748	5
33317	7476	10774	1
33318	7476	10718	1
33319	7476	10758	1
33320	7476	10715	1
33321	7477	10786	4
33322	7477	10712	1
33323	7477	10695	2
33324	7477	10787	1
33325	7477	10715	3
33326	7478	10739	3
33327	7478	10712	1
33328	7478	10713	4
33329	7478	10787	2
33330	7478	10715	1
33331	7479	10757	4
33332	7479	10788	4
33333	7479	10712	6
33334	7479	10695	3
33335	7479	10715	1
33336	7480	10786	4
33337	7480	10789	5
33338	7480	10697	4
33339	7480	10790	4
33340	7480	10699	5
33341	7481	10791	4
33342	7481	10742	9
33343	7481	10695	4
33344	7481	10792	5
33345	7481	10710	1
33346	7482	10793	5
33347	7482	10697	1
33348	7482	10624	2
33349	7482	10794	2
33350	7482	10699	3
33351	7483	10524	5
33352	7483	10795	6
33353	7483	10624	6
33354	7483	10796	5
33355	7483	10710	8
33356	7484	10727	3
33357	7484	10728	3
33358	7484	10729	1
33359	7484	10730	1
33360	7484	10731	1
33361	7485	10720	6
33362	7485	10721	6
33363	7485	10718	5
33364	7485	10722	3
33365	7485	10723	6
33366	7486	10797	8
33367	7486	10712	5
33368	7486	10713	2
33369	7486	10758	10
33370	7486	10715	6
33371	7487	10720	6
33372	7487	10721	9
33373	7487	10718	7
33374	7487	10722	2
33375	7487	10723	7
33376	7488	10720	6
33377	7488	10721	11
33378	7488	10718	8
33379	7488	10722	6
33380	7488	10723	7
33381	7489	10798	5
33382	7489	10703	3
33383	7489	10799	2
33384	7489	10800	1
33385	7489	10710	1
33386	7490	10702	3
33387	7490	10703	7
33388	7490	10704	9
33389	7490	10705	1
33390	7490	10706	4
33391	7491	10748	5
33392	7491	10697	3
33393	7491	10801	2
33394	7491	10699	4
33395	7491	10802	3
33396	7492	10803	3
33397	7492	10703	6
33398	7492	10704	3
33399	7492	10705	2
33400	7492	10706	2
33401	7493	10702	5
33402	7493	10703	4
33403	7493	10704	2
33404	7493	10705	1
33405	7493	10706	1
33406	7494	10702	4
33407	7494	10703	6
33408	7494	10704	8
33409	7494	10705	2
33410	7494	10706	4
33411	7495	10702	4
33412	7495	10703	7
33413	7495	10704	8
33414	7495	10705	2
33415	7495	10706	5
33416	7496	10759	5
33417	7496	10712	6
33418	7496	10729	1
33419	7496	10804	1
33420	7496	10715	5
33421	7497	10727	3
33422	7497	10728	9
33423	7497	10729	2
33424	7497	10730	1
33425	7497	10731	5
33426	7498	10777	6
33427	7498	10712	6
33428	7498	10805	6
33429	7498	10715	6
33430	7498	10554	8
33431	7499	10727	4
33432	7499	10728	6
33433	7499	10729	2
33434	7499	10730	2
33435	7499	10731	8
33436	7500	10702	5
33437	7500	10703	8
33438	7500	10704	8
33439	7500	10705	4
33440	7500	10706	1
33441	7501	10702	4
33442	7501	10703	8
33443	7501	10704	9
33444	7501	10705	3
33445	7501	10706	8
33446	7502	10727	3
33447	7502	10728	7
33448	7502	10729	3
33449	7502	10730	1
33450	7502	10731	3
33451	7503	10720	6
33452	7503	10721	7
33453	7503	10718	6
33454	7503	10722	3
33455	7503	10723	2
33456	7504	10707	4
33457	7504	10806	11
33458	7504	10718	6
33459	7504	10775	4
33460	7504	10710	1
33461	7505	10720	4
33462	7505	10721	9
33463	7505	10718	7
33464	7505	10722	6
33465	7505	10723	4
33466	7506	10727	5
33467	7506	10728	9
33468	7506	10729	4
33469	7506	10730	1
33470	7506	10731	9
33471	7507	10807	4
33472	7507	10808	5
33473	7507	10712	6
33474	7507	10809	1
33475	7507	10715	4
33476	7508	10734	4
33477	7508	10712	8
33478	7508	10729	3
33479	7508	10810	9
33480	7508	10715	6
33481	7509	10727	3
33482	7509	10728	9
33483	7509	10729	1
33484	7509	10730	3
33485	7509	10731	4
33486	7510	10702	3
33487	7510	10703	6
33488	7510	10704	7
33489	7510	10705	4
33490	7510	10706	5
33491	7511	10720	7
33492	7511	10721	9
33493	7511	10718	7
33494	7511	10722	6
33495	7511	10723	10
33496	7512	10811	5
33497	7512	10717	4
33498	7512	10756	2
33499	7512	10573	4
33500	7512	10560	2
33501	7513	10569	3
33502	7513	10565	6
33503	7513	10812	7
33504	7513	10573	5
33505	7513	10554	6
33506	7514	10593	1
33507	7514	10795	5
33508	7514	10725	5
33509	7514	10509	2
33510	7514	10573	1
33511	7515	10813	11
33512	7515	10814	10
33513	7515	10815	7
33514	7515	10816	11
33515	7515	10817	9
33516	7515	10818	1
33517	7516	10819	6
33518	7516	10820	4
33519	7516	10821	3
33520	7516	10822	2
33521	7516	10823	3
33522	7516	10824	14
33523	7516	10825	1
33524	7516	10826	11
33525	7517	10827	6
33526	7517	10823	3
33527	7517	10824	14
33528	7517	10815	5
33529	7517	10828	4
33530	7517	10816	2
33531	7517	10829	4
33532	7518	10830	4
33533	7518	10831	3
33534	7518	10823	4
33535	7518	10832	14
33536	7518	10833	9
33537	7519	10834	3
33538	7519	10835	5
33539	7519	10836	2
33540	7519	10837	7
33541	7519	10838	10
33542	7520	10839	7
33543	7520	10825	5
33544	7520	10840	7
33545	7520	10837	7
33546	7520	10841	9
33547	7521	10842	13
33548	7521	10843	4
33549	7521	10844	4
33550	7521	10845	7
33551	7521	10846	9
33552	7521	10847	3
33553	7522	10848	2
33554	7522	10849	7
33555	7522	10840	13
33556	7522	10850	7
33557	7522	10851	3
33558	7523	10852	8
33559	7523	10823	3
33560	7523	10824	14
33561	7523	10849	7
33562	7523	10828	1
33563	7523	10816	1
33564	7523	10829	7
33565	7524	10853	13
33566	7524	10854	8
33567	7524	10855	5
33568	7524	10840	13
33569	7524	10856	5
33570	7524	10857	2
33571	7524	10858	12
33572	7525	10859	9
33573	7525	10823	11
33574	7525	10860	14
33575	7525	10825	5
33576	7525	10837	8
33577	7526	10861	10
33578	7526	10862	6
33579	7526	10849	6
33580	7526	10825	6
33581	7526	10857	2
33582	7526	10828	7
33583	7526	10841	13
33584	7527	10863	7
33585	7527	10864	7
33586	7527	10823	4
33587	7527	10824	14
33588	7527	10815	6
33589	7527	10846	9
33590	7527	10865	8
33591	7528	10866	3
33592	7528	10867	4
33593	7528	10868	3
33594	7528	10823	11
33595	7528	10860	14
33596	7528	10844	7
33597	7528	10869	9
33598	7529	10870	4
33599	7529	10823	5
33600	7529	10832	14
33601	7529	10815	6
33602	7529	10871	4
33603	7529	10872	3
33604	7529	10845	4
33605	7530	10873	9
33606	7530	10874	5
33607	7530	10844	7
33608	7530	10875	7
33609	7530	10840	4
33610	7530	10876	4
33611	7531	10877	12
33612	7531	10878	11
33613	7531	10879	8
33614	7531	10880	9
33615	7531	10881	12
33616	7531	10865	5
33617	7532	10882	2
33618	7532	10883	2
33619	7532	10841	9
33620	7532	10884	6
33621	7532	10885	4
33622	7532	10886	2
33623	7533	10887	7
33624	7533	10888	11
33625	7533	10840	13
33626	7533	10872	13
33627	7533	10881	13
33628	7534	10889	1
33629	7534	10890	2
33630	7534	10891	5
33631	7534	10841	8
33632	7534	10885	3
33633	7535	10852	13
33634	7535	10892	4
33635	7535	10815	5
33636	7535	10893	5
33637	7535	10871	2
33638	7535	10872	7
33639	7536	10894	9
33640	7536	10895	7
33641	7536	10825	3
33642	7536	10828	4
33643	7536	10850	8
33644	7536	10829	7
33645	7537	10896	4
33646	7537	10844	3
33647	7537	10875	9
33648	7537	10840	6
33649	7538	10897	6
33650	7538	10898	9
33651	7538	10899	5
33652	7538	10843	7
33653	7538	10884	11
33654	7539	10900	8
33655	7539	10823	5
33656	7539	10901	14
33657	7539	10875	7
33658	7539	10828	5
33659	7539	10850	6
33660	7539	10902	8
33661	7540	10903	8
33662	7540	10904	7
33663	7540	10879	7
33664	7540	10905	9
33665	7540	10906	9
33666	7541	10907	11
33667	7541	10908	9
33668	7541	10909	3
33669	7541	10910	2
33670	7541	10869	9
33671	7542	10911	8
33672	7542	10912	6
33673	7542	10827	11
33674	7542	10843	8
33675	7542	10913	11
33676	7543	10914	3
33677	7543	10911	9
33678	7543	10915	6
33679	7543	10916	7
33680	7543	10917	3
33681	7543	10918	1
33682	7544	10919	4
33683	7544	10863	8
33684	7544	10920	3
33685	7544	10921	4
33686	7544	10884	5
33687	7544	10876	6
33688	7545	10922	3
33689	7545	10923	8
33690	7545	10924	11
33691	7545	10925	9
33692	7545	10884	7
33693	7545	10913	3
33694	7546	10926	9
33695	7546	10927	9
33696	7546	10928	6
33697	7546	10929	5
33698	7546	10876	11
33699	7547	10898	10
33700	7547	10930	11
33701	7547	10915	8
33702	7547	10931	4
33703	7547	10932	4
33704	7547	10933	11
33705	7548	10934	5
33706	7548	10908	7
33707	7548	10935	5
33708	7548	10933	9
33709	7548	10913	11
33710	7549	10936	10
33711	7549	10937	5
33712	7549	10843	8
33713	7549	10846	11
33714	7549	10865	8
33715	7550	10938	5
33716	7550	10939	11
33717	7550	10920	8
33718	7550	10846	7
33719	7550	10865	6
33720	7551	10926	9
33721	7551	10940	4
33722	7551	10941	2
33723	7551	10929	5
33724	7551	10876	9
33725	7552	10942	8
33726	7552	10943	6
33727	7552	10944	7
33728	7552	10843	5
33729	7552	10945	7
33730	7552	10876	8
33731	7553	10946	8
33732	7553	10947	9
33733	7553	10948	7
33734	7553	10949	7
33735	7553	10846	1
33736	7553	10876	4
33737	7554	10950	5
33738	7554	10951	3
33739	7554	10952	6
33740	7554	10927	8
33741	7554	10953	8
33742	7554	10913	8
33743	7555	10954	13
33744	7555	10955	9
33745	7555	10920	11
33746	7555	10846	7
33747	7555	10865	8
33748	7556	10956	7
33749	7556	10957	9
33750	7556	10898	9
33751	7556	10958	13
33752	7556	10959	8
33753	7556	10960	10
33754	7557	10961	3
33755	7557	10962	8
33756	7557	10963	8
33757	7557	10843	6
33758	7557	10884	7
33759	7557	10876	7
33760	7558	10964	7
33761	7558	10965	9
33762	7558	10843	7
33763	7558	10945	6
33764	7558	10876	11
33765	7559	10966	4
33766	7559	10967	9
33767	7559	10927	10
33768	7559	10968	5
33769	7559	10884	8
33770	7559	10865	6
33771	7560	10969	9
33772	7560	10970	11
33773	7560	10971	6
33774	7560	10851	4
33775	7561	10898	9
33776	7561	10972	11
33777	7561	10920	9
33778	7561	10973	4
33779	7561	10843	9
33780	7561	10884	7
33781	7562	10974	6
33782	7562	10926	10
33783	7562	10975	5
33784	7562	10968	6
33785	7562	10846	9
33786	7563	10898	10
33787	7563	10952	6
33788	7563	10908	11
33789	7563	10894	6
33790	7563	10965	10
33791	7563	10945	8
33792	7564	10976	8
33793	7564	10899	2
33794	7564	10977	4
33795	7564	10978	6
33796	7564	10865	5
33797	7565	10979	2
33798	7565	10980	4
33799	7565	10981	9
33800	7565	10982	7
33801	7566	10983	3
33802	7566	10984	9
33803	7566	10985	1
33804	7566	10933	11
33805	7566	10913	11
33806	7567	10986	5
33807	7567	10911	13
33808	7567	10912	8
33809	7567	10987	3
33810	7567	10945	9
33811	7567	10913	11
33812	7568	10898	9
33813	7568	10988	9
33814	7568	10989	8
33815	7568	10990	6
33816	7568	10933	11
33817	7569	10991	3
33818	7569	10992	5
33819	7569	10964	9
33820	7569	10993	9
33821	7569	10945	11
33822	7569	10913	11
33823	7570	10994	6
33824	7570	10955	9
33825	7570	10995	6
33826	7570	10894	11
33827	7570	10945	9
33828	7571	10996	2
33829	7571	10997	4
33830	7571	10924	13
33831	7571	10998	9
33832	7571	10846	9
33833	7571	10865	6
33834	7572	10984	8
33835	7572	10925	6
33836	7572	10916	4
33837	7572	10999	2
33838	7572	10906	7
33839	7572	10876	6
33840	7573	11000	5
33841	7573	11001	10
33842	7573	11002	11
33843	7573	11003	7
33844	7573	10884	9
33845	7573	10865	7
33846	7574	11004	3
33847	7574	11005	7
33848	7574	11003	5
33849	7574	10929	4
33850	7574	10876	8
33851	7575	10967	9
33852	7575	11003	9
33853	7575	11006	3
33854	7575	10843	8
33855	7575	10945	9
33856	7575	10876	11
33857	7576	11007	4
33858	7576	10972	9
33859	7576	10949	7
33860	7576	10864	6
33861	7576	10945	9
33862	7576	10913	11
33863	7577	11008	8
33864	7577	10840	3
33865	7577	10845	9
33866	7577	10850	9
33867	7577	10847	2
33868	7577	10913	11
33869	7578	11009	6
33870	7578	11010	6
33871	7578	11011	9
33872	7578	11012	4
33873	7578	10933	6
33874	7578	10865	6
33875	7579	11013	5
33876	7579	11014	9
33877	7579	11008	8
33878	7579	11015	4
33879	7579	10884	8
33880	7579	10913	11
33881	7580	11010	6
33882	7580	10908	11
33883	7580	11016	10
33884	7580	11012	4
33885	7580	10945	11
33886	7580	10865	6
33887	7581	11017	4
33888	7581	11018	3
33889	7581	10878	8
33890	7581	11019	7
33891	7581	10982	5
33892	7581	10913	7
33893	7582	10964	2
33894	7582	10888	4
33895	7582	10843	1
33896	7582	10884	2
33897	7582	11020	3
33898	7583	11021	6
33899	7583	10863	7
33900	7583	10928	8
33901	7583	11022	11
33902	7583	10846	11
33903	7583	10865	14
33904	7584	10975	8
33905	7584	11023	1
33906	7584	11024	3
33907	7584	10945	7
33908	7584	10865	7
33909	7585	11025	6
33910	7585	11026	4
33911	7585	10936	6
33912	7585	11027	5
33913	7585	11028	7
33914	7585	11029	5
33915	7586	11030	9
33916	7586	11031	7
33917	7586	11032	7
33918	7586	10933	9
33919	7586	10876	8
33920	7587	10956	9
33921	7587	10972	4
33922	7587	10949	11
33923	7587	10933	9
33924	7587	10913	8
33925	7588	11033	2
33926	7588	10956	2
33927	7588	10879	6
33928	7588	10945	11
33929	7588	10865	6
33930	7589	11034	4
33931	7589	11035	4
33932	7589	11036	5
33933	7589	11037	1
33934	7589	11038	1
33935	7590	11039	3
33936	7590	11040	5
33937	7590	10864	8
33938	7590	11041	1
33939	7590	11042	7
33940	7591	11043	3
33941	7591	11044	5
33942	7591	11045	7
33943	7591	11046	1
33944	7591	10929	6
33945	7592	11047	6
33946	7592	11048	7
33947	7592	11049	4
33948	7592	10869	8
33949	7592	11020	4
33950	7593	10870	4
33951	7593	11050	9
33952	7593	11051	5
33953	7593	11052	1
33954	7593	10869	12
33955	7594	11034	5
33956	7594	11053	4
33957	7594	11054	3
33958	7594	11040	7
33959	7594	11055	4
33960	7594	10869	3
33961	7595	11056	4
33962	7595	11048	5
33963	7595	11057	3
33964	7595	11058	4
33965	7595	11059	6
33966	7596	11060	6
33967	7596	11061	5
33968	7596	11048	8
33969	7596	11006	2
33970	7596	10869	7
33971	7597	11062	3
33972	7597	11050	9
33973	7597	11063	6
33974	7597	11064	2
33975	7597	10953	7
33976	7598	11065	3
33977	7598	11000	3
33978	7598	11045	5
33979	7598	11046	1
33980	7598	11038	2
33981	7599	11066	3
33982	7599	11067	3
33983	7599	11040	9
33984	7599	11068	3
33985	7599	10869	2
33986	7600	10820	2
33987	7600	11069	9
33988	7600	10864	5
33989	7600	11070	4
33990	7600	10953	5
33991	7601	11071	7
33992	7601	11072	4
33993	7601	11073	8
33994	7601	10999	3
33995	7601	11038	13
33996	7602	11056	3
33997	7602	11074	7
33998	7602	11057	4
33999	7602	11075	1
34000	7602	10918	4
34001	7603	11076	4
34002	7603	11045	7
34003	7603	11077	6
34004	7603	11046	1
34005	7603	11038	3
34006	7604	11078	2
34007	7604	11079	4
34008	7604	11074	4
34009	7604	11052	1
34010	7604	10918	2
34011	7605	11021	1
34012	7605	11080	7
34013	7605	10894	7
34014	7605	11024	3
34015	7605	10953	1
34016	7606	11081	4
34017	7606	11082	8
34018	7606	11063	11
34019	7606	11083	4
34020	7606	11042	8
34021	7607	11033	2
34022	7607	11084	3
34023	7607	11085	11
34024	7607	11086	1
34025	7607	11087	2
34026	7607	10929	6
34027	7608	11088	3
34028	7608	11089	4
34029	7608	10827	4
34030	7608	11090	2
34031	7608	11042	6
34032	7609	11091	3
34033	7609	11092	6
34034	7609	11093	9
34035	7609	11094	1
34036	7609	10918	1
34037	7610	11062	2
34038	7610	11095	2
34039	7610	11040	5
34040	7610	11038	1
34041	7610	11096	2
34042	7611	11097	5
34043	7611	11026	7
34044	7611	11098	9
34045	7611	11099	3
34046	7611	11059	2
34047	7612	11100	3
34048	7612	11079	6
34049	7612	11101	8
34050	7612	11037	3
34051	7612	10906	5
34052	7613	11102	4
34053	7613	11103	3
34054	7613	11063	6
34055	7613	11104	5
34056	7613	10929	3
34057	7614	11105	4
34058	7614	11106	3
34059	7614	10981	7
34060	7614	11064	2
34061	7614	10953	11
34062	7615	11106	3
34063	7615	11107	4
34064	7615	11063	5
34065	7615	10894	7
34066	7615	10953	4
34067	7616	11108	5
34068	7616	11054	6
34069	7616	11101	8
34070	7616	11109	2
34071	7616	10953	7
34072	7617	11056	3
34073	7617	11110	7
34074	7617	11040	9
34075	7617	11083	2
34076	7617	11042	3
34077	7618	11056	3
34078	7618	11074	6
34079	7618	11057	4
34080	7618	11070	4
34081	7618	10918	3
34082	7619	11033	2
34083	7619	11111	3
34084	7619	11112	9
34085	7619	11113	4
34086	7619	10929	8
34087	7620	11114	3
34088	7620	10969	9
34089	7620	11115	4
34090	7620	11024	4
34091	7620	10953	9
34092	7621	11074	6
34093	7621	11116	4
34094	7621	11117	2
34095	7621	11037	6
34096	7621	10953	3
34097	7622	10942	4
34098	7622	11050	8
34099	7622	11077	3
34100	7622	11118	3
34101	7622	11038	1
34102	7623	11119	3
34103	7623	11036	6
34104	7623	11117	1
34105	7623	11120	4
34106	7623	11042	4
34107	7624	11121	12
34108	7624	11036	10
34109	7624	11077	8
34110	7624	11122	6
34111	7624	11042	8
34112	7625	11095	4
34113	7625	11082	7
34114	7625	11123	1
34115	7625	11124	3
34116	7625	11042	7
34117	7626	11056	4
34118	7626	11125	9
34119	7626	11126	2
34120	7626	11052	1
34121	7626	10869	8
34122	7627	11100	4
34123	7627	11079	6
34124	7627	11101	9
34125	7627	11037	1
34126	7627	10906	2
34127	7628	11056	3
34128	7628	10944	8
34129	7628	11057	3
34130	7628	11075	1
34131	7628	10918	1
34132	7629	10870	3
34133	7629	11127	4
34134	7629	11050	10
34135	7629	11128	4
34136	7629	10869	5
34137	7630	11025	5
34138	7630	11107	3
34139	7630	10827	3
34140	7630	11129	4
34141	7630	10918	3
34142	7631	11065	3
34143	7631	11045	9
34144	7631	11077	3
34145	7631	11046	1
34146	7631	11038	2
34147	7632	11100	3
34148	7632	11030	6
34149	7632	11074	8
34150	7632	11012	4
34151	7632	10906	5
34152	7633	11130	4
34153	7633	11131	7
34154	7633	11132	9
34155	7633	11133	4
34156	7633	10953	4
34157	7634	11134	4
34158	7634	11050	8
34159	7634	10894	6
34160	7634	11037	1
34161	7634	10953	1
34162	7635	11050	9
34163	7635	11117	3
34164	7635	11129	2
34165	7635	11046	4
34166	7635	10869	6
34167	7636	11053	3
34168	7636	11045	8
34169	7636	11135	1
34170	7636	10892	3
34171	7636	11038	8
34172	7637	10951	2
34173	7637	10981	6
34174	7637	11136	1
34175	7637	11129	9
34176	7637	10906	1
34177	7638	11060	6
34178	7638	10897	2
34179	7638	11048	8
34180	7638	11077	6
34181	7638	11137	3
34182	7638	10869	5
34183	7639	11060	5
34184	7639	11048	7
34185	7639	11077	9
34186	7639	11049	6
34187	7639	10869	8
34188	7640	11138	2
34189	7640	11125	5
34190	7640	11052	1
34191	7640	11042	1
34192	7640	11139	6
34193	7641	11065	4
34194	7641	11045	11
34195	7641	11077	8
34196	7641	11090	1
34197	7641	11038	7
34198	7642	11076	3
34199	7642	11000	2
34200	7642	11045	11
34201	7642	11046	1
34202	7642	11038	4
34203	7643	11140	1
34204	7643	11110	3
34205	7643	11141	9
34206	7643	11128	1
34207	7643	11042	7
34208	7644	11140	4
34209	7644	11110	4
34210	7644	11141	8
34211	7644	11142	3
34212	7644	11038	9
34213	7645	11143	2
34214	7645	11018	9
34215	7645	11101	8
34216	7645	11094	2
34217	7645	10869	5
34218	7646	11144	3
34219	7646	11040	2
34220	7646	10906	1
34221	7646	11139	4
34222	7646	10886	1
34223	7647	11134	2
34224	7647	11095	3
34225	7647	11050	4
34226	7647	11145	1
34227	7647	11042	1
34228	7648	11146	5
34229	7648	11050	2
34230	7648	11147	9
34231	7648	11038	1
34232	7648	10847	1
34233	7649	11148	4
34234	7649	11149	7
34235	7649	11018	8
34236	7649	11050	9
34237	7649	11042	5
34238	7650	11119	3
34239	7650	11141	9
34240	7650	10928	6
34241	7650	11122	4
34242	7650	11042	6
34243	7651	11150	5
34244	7651	10962	5
34245	7651	11040	7
34246	7651	11037	2
34247	7651	10869	2
34248	7652	11111	3
34249	7652	11151	2
34250	7652	11152	4
34251	7652	11153	2
34252	7652	11042	2
34253	7653	11154	5
34254	7653	11048	7
34255	7653	10928	6
34256	7653	11070	7
34257	7653	10869	12
34258	7654	11155	5
34259	7654	10981	4
34260	7654	10894	6
34261	7654	11037	1
34262	7654	10953	1
34263	7655	11056	4
34264	7655	11074	6
34265	7655	11057	3
34266	7655	11075	1
34267	7655	10918	5
34268	7656	11156	4
34269	7656	11050	8
34270	7656	11087	2
34271	7656	11012	1
34272	7656	11042	7
34273	7657	11157	3
34274	7657	11056	3
34275	7657	11074	7
34276	7657	11075	1
34277	7657	10918	3
34278	7658	11100	5
34279	7658	11079	6
34280	7658	11158	9
34281	7658	11037	1
34282	7658	10906	6
34283	7659	11067	4
34284	7659	11040	2
34285	7659	10864	2
34286	7659	10869	1
34287	7659	11159	2
34288	7660	11160	4
34289	7660	11161	3
34290	7660	11045	11
34291	7660	11046	1
34292	7660	10929	6
34293	7661	11162	5
34294	7661	11040	8
34295	7661	10864	6
34296	7661	10916	5
34297	7661	10953	5
34298	7662	11065	5
34299	7662	11045	11
34300	7662	11090	1
34301	7662	11038	4
34302	7662	10851	2
34303	7663	11065	5
34304	7663	11045	2
34305	7663	11077	4
34306	7663	11090	1
34307	7663	11038	1
34308	7664	11065	4
34309	7664	11045	8
34310	7664	11077	6
34311	7664	11046	2
34312	7664	11038	6
34313	7665	11076	4
34314	7665	11045	11
34315	7665	11077	7
34316	7665	11090	2
34317	7665	11038	4
34318	7666	11163	3
34319	7666	11164	2
34320	7666	11050	7
34321	7666	11165	4
34322	7666	11166	4
34323	7666	11042	2
34324	7667	11155	7
34325	7667	11001	8
34326	7667	10944	9
34327	7667	11037	4
34328	7667	10953	3
34329	7668	11154	5
34330	7668	11167	8
34331	7668	10864	6
34332	7668	11070	5
34333	7668	10953	8
34334	7669	11021	1
34335	7669	10981	11
34336	7669	10894	8
34337	7669	11168	9
34338	7669	10906	9
34339	7670	11065	6
34340	7670	11045	11
34341	7670	11090	2
34342	7670	11038	3
34343	7670	10851	4
34344	7671	11169	6
34345	7671	11045	13
34346	7671	10937	4
34347	7671	11170	5
34348	7671	10906	9
34349	7672	11021	1
34350	7672	10944	7
34351	7672	10894	8
34352	7672	11171	2
34353	7672	10953	5
34354	7673	11172	5
34355	7673	11074	6
34356	7673	11057	6
34357	7673	11070	4
34358	7673	10918	1
34359	7674	11138	2
34360	7674	11173	7
34361	7674	11174	2
34362	7674	11128	2
34363	7674	10869	3
34364	7675	11033	4
34365	7675	11079	5
34366	7675	11074	8
34367	7675	11037	3
34368	7675	10918	2
34369	7676	11021	3
34370	7676	10981	13
34371	7676	11168	8
34372	7676	10960	7
34373	7676	10953	7
34374	7677	11175	2
34375	7677	11050	8
34376	7677	11176	3
34377	7677	11042	2
34378	7677	10886	1
34379	7678	11177	5
34380	7678	11178	3
34381	7678	11101	11
34382	7678	11037	4
34383	7678	11042	11
34384	7679	11100	3
34385	7679	11107	8
34386	7679	11077	7
34387	7679	11179	4
34388	7679	10953	6
34389	7680	11043	3
34390	7680	11065	4
34391	7680	11045	11
34392	7680	11046	1
34393	7680	11038	5
34394	7681	11078	3
34395	7681	11079	6
34396	7681	11074	9
34397	7681	11052	1
34398	7681	11059	5
34399	7682	11095	5
34400	7682	11045	9
34401	7682	11180	3
34402	7682	10891	5
34403	7682	10906	4
34404	7683	11095	8
34405	7683	11125	8
34406	7683	11180	11
34407	7683	11181	4
34408	7683	10906	6
34409	7684	11182	1
34410	7684	11125	7
34411	7684	10968	1
34412	7684	10906	1
34413	7684	10847	1
34414	7685	11183	6
34415	7685	11184	5
34416	7685	11185	3
34417	7686	11186	5
34418	7687	11187	3
34419	7688	11188	4
34420	7688	11189	5
34421	7689	11187	11
34422	7690	11190	13
34423	7690	11191	4
34424	7691	11187	3
34425	7692	11187	1
34426	7693	11187	3
34427	7694	11192	3
34428	7694	11193	11
34429	7695	11183	4
34430	7695	11194	7
34431	7696	11195	7
34432	7696	11196	8
34433	7697	11197	4
34434	7698	11198	3
34435	7698	11199	11
34436	7699	11200	7
34437	7699	11185	3
34438	7700	11185	2
34439	7700	11201	13
34440	7701	11202	8
34441	7702	11203	2
34442	7702	11204	4
34443	7703	11205	5
34444	7703	11201	5
34445	7704	11206	11
34446	7704	11207	10
34447	7705	11208	7
34448	7705	11199	9
34449	7706	11201	11
34450	7707	11209	7
34451	7708	11201	4
34452	7709	11206	2
34453	7709	11199	9
34454	7710	11210	8
34455	7711	11211	8
34456	7712	11212	6
34457	7712	11197	4
34458	7713	11196	3
34459	7714	11213	5
34460	7714	11214	1
34461	7715	11215	11
34462	7715	11201	2
34463	7716	11215	3
34464	7717	11203	5
34465	7717	11215	3
34466	7718	11216	9
34467	7718	11189	5
34468	7719	11213	7
34469	7719	11211	8
34470	7720	11217	4
34471	7720	11215	5
34472	7721	11218	3
34473	7721	11204	3
34474	7722	11199	8
34475	7723	11211	4
34476	7723	11215	11
34477	7724	11201	11
34478	7725	11219	4
34479	7726	11215	11
34480	7726	11201	5
34481	7727	11197	2
34482	7727	11209	4
34483	7728	11197	5
34484	7728	11202	1
34485	7729	11220	5
34486	7730	11221	8
34487	7731	11222	8
34488	7731	11223	4
34489	7732	11224	7
34490	7733	11225	2
34491	7734	11202	6
34492	7735	11226	6
34493	7736	11227	5
34494	7737	11228	4
34495	7737	11229	2
34496	7738	11208	1
34497	7739	11230	4
34498	7740	11230	7
34499	7741	11231	3
34500	7741	11232	5
34501	7742	11233	1
34502	7742	11189	3
34503	7743	11234	1
34504	7744	11235	11
34505	7745	11215	11
34506	7745	11201	4
34507	7746	11236	5
34508	7747	11224	3
34509	7748	11237	2
34510	7749	11226	5
34511	7750	11215	2
34512	7750	11201	1
34513	7751	11238	8
34514	7752	11239	1
34515	7753	11237	1
34516	7754	11240	1
34517	7755	11209	9
34518	7756	11241	1
34519	7756	11242	3
34520	7757	11227	3
34521	7758	11202	8
34522	7759	11208	5
34523	7760	11240	2
34524	7761	11236	5
34525	7762	11243	5
34526	7763	11215	1
34527	7763	11201	1
34528	7764	11244	6
34529	7765	11243	1
34530	7766	11238	7
34531	7767	11227	4
34532	7768	11237	7
34533	7768	11245	2
34534	7769	11235	5
34535	7770	11244	5
34536	7771	11246	2
34537	7771	11247	3
34538	7772	11248	2
34539	7773	11208	5
34540	7774	11235	11
34541	7775	11202	9
34542	7776	11249	11
34543	7777	11230	4
34544	7778	11239	3
34545	7779	11250	9
34546	7780	11230	1
34547	7781	11251	6
34548	7782	11252	11
34549	7782	11253	5
34550	7782	11254	11
34551	7782	11255	6
34552	7782	11256	11
34553	7783	11257	14
34554	7783	11258	14
34555	7783	11259	7
34556	7783	11260	4
34557	7783	11256	10
34558	7784	11261	3
34559	7785	11259	6
34560	7785	11262	11
34561	7785	11263	5
34562	7785	11264	4
34563	7785	11265	13
34564	7786	11263	4
34565	7786	11261	3
34566	7786	11266	14
34567	7786	11267	6
34568	7786	11256	9
34569	7787	11268	4
34570	7787	11269	2
34571	7787	11252	11
34572	7787	11270	5
34573	7787	11271	4
34574	7787	11264	3
34575	7788	11272	11
34576	7788	11273	14
34577	7788	11274	9
34578	7788	11275	8
34579	7788	11276	8
34580	7788	11270	11
34581	7788	11277	9
34582	7789	11272	5
34583	7789	11278	14
34584	7789	11262	11
34585	7789	11279	8
34586	7789	11280	7
34587	7790	11259	6
34588	7790	11262	11
34589	7790	11263	6
34590	7790	11260	3
34591	7790	11281	9
34592	7790	11264	4
34593	7791	11282	14
34594	7791	11283	11
34595	7792	11284	7
34596	7792	11285	8
34597	7792	11264	3
34598	7792	11256	11
34599	7793	11282	14
34600	7793	11283	11
34601	7793	11286	11
34602	7793	11287	3
34603	7793	11271	6
34604	7793	11288	1
34605	7793	11289	9
34606	7794	11290	2
34607	7794	11291	7
34608	7794	11259	8
34609	7794	11279	8
34610	7794	11276	2
34611	7794	11292	7
34612	7795	11293	5
34613	7795	11294	2
34614	7795	11295	10
34615	7795	11296	3
34616	7795	11297	13
34617	7795	11265	8
34618	7796	11298	9
34619	7796	11299	6
34620	7796	11270	6
34621	7796	11300	5
34622	7796	11261	7
34623	7796	11301	11
34624	7797	11274	3
34625	7797	11262	8
34626	7797	11302	6
34627	7797	11253	4
34628	7797	11263	8
34629	7797	11260	1
34630	7798	11303	3
34631	7798	11272	11
34632	7798	11273	14
34633	7798	11275	8
34634	7798	11254	11
34635	7798	11265	11
34636	7799	11274	7
34637	7799	11275	9
34638	7799	11292	6
34639	7799	11300	4
34640	7799	11256	9
34641	7800	11304	11
34642	7800	11305	2
34643	7800	11282	14
34644	7800	11283	11
34645	7800	11297	6
34646	7800	11255	12
34647	7800	11265	8
34648	7801	11274	6
34649	7801	11279	11
34650	7801	11292	6
34651	7801	11300	6
34652	7801	11265	9
34653	7802	11306	14
34654	7802	11283	5
34655	7802	11274	5
34656	7802	11262	2
34657	7802	11263	6
34658	7802	11300	13
34659	7802	11261	7
34660	7803	11272	11
34661	7803	11278	14
34662	7803	11259	9
34663	7803	11286	11
34664	7803	11263	8
34665	7803	11300	4
34666	7803	11307	2
34667	7803	11289	6
34668	7804	11274	5
34669	7804	11262	3
34670	7804	11302	6
34671	7804	11253	4
34672	7804	11263	2
34673	7804	11260	5
34674	7804	11300	5
34675	7805	11308	5
34676	7805	11309	11
34677	7805	11310	8
34678	7805	11300	13
34679	7805	11255	5
34680	7805	11256	11
34681	7806	11311	6
34682	7806	11298	11
34683	7806	11297	9
34684	7806	11254	8
34685	7806	11281	9
34686	7806	11312	3
34687	7807	11313	9
34688	7807	11314	3
34689	7807	11315	2
34690	7807	11271	2
34691	7808	11316	4
34692	7808	11317	9
34693	7808	11318	8
34694	7808	11319	4
34695	7808	11315	7
34696	7808	11320	9
34697	7809	11321	4
34698	7809	11322	9
34699	7809	11323	7
34700	7809	11320	12
34701	7809	11324	5
34702	7809	11256	8
34703	7810	11325	6
34704	7810	11326	5
34705	7810	11327	3
34706	7810	11296	5
34707	7810	11320	6
34708	7810	11265	8
34709	7811	11328	8
34710	7811	11329	9
34711	7811	11330	9
34712	7811	11320	9
34713	7812	11331	4
34714	7812	11275	2
34715	7812	11292	2
34716	7812	11254	5
34717	7812	11300	3
34718	7812	11332	2
34719	7813	11333	4
34720	7813	11334	5
34721	7813	11275	11
34722	7813	11335	8
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
1653	1663	199938944	1
1654	1664	200258957	1
1655	1665	200261631	1
1656	1666	200302684	1
1657	1667	200306538	1
1658	1668	200427046	1
1659	1669	200505277	1
1660	1670	200571597	1
1661	1671	200604764	1
1662	1672	200611321	1
1663	1673	200618693	1
1664	1674	200645172	1
1665	1675	200678578	1
1666	1676	200678652	1
1667	1677	200660742	1
1668	1678	200660849	1
1669	1679	200702110	1
1670	1680	200716081	1
1671	1681	200722129	1
1672	1682	200727064	1
1673	1683	200729866	1
1674	1684	200737513	1
1675	1685	200742060	1
1676	1686	200746440	1
1677	1687	200746691	1
1678	1688	200750610	1
1679	1689	200776104	1
1680	1690	200703789	1
1681	1691	200801494	1
1682	1692	200804269	1
1683	1693	200805213	1
1684	1694	200806725	1
1685	1695	200807619	1
1686	1696	200810012	1
1687	1697	200810449	1
1688	1698	200812434	1
1689	1699	200816057	1
1690	1700	200816182	1
1691	1701	200818798	1
1692	1702	200820492	1
1693	1703	200820845	1
1694	1704	200822195	1
1695	1705	200824411	1
1696	1706	200826125	1
1697	1707	200826132	1
1698	1708	200829462	1
1699	1709	200831088	1
1700	1710	200835065	1
1701	1711	200838847	1
1702	1712	200850304	1
1703	1713	200854833	1
1704	1714	200859513	1
1705	1715	200861979	1
1706	1716	200863141	1
1707	1717	200863910	1
1708	1718	200863943	1
1709	1719	200867820	1
1710	1720	200867969	1
1711	1721	200869234	1
1712	1722	200878505	1
1713	1723	200878522	1
1714	1724	200879055	1
1715	1725	200751702	1
1716	1726	200649333	1
1717	1727	200704149	1
1718	1728	200800722	1
1719	1729	200800992	1
1720	1730	200802019	1
1721	1731	200805994	1
1722	1732	200810511	1
1723	1733	200810842	1
1724	1734	200815563	1
1725	1735	200816422	1
1726	1736	200817653	1
1727	1737	200850077	1
1728	1738	200852284	1
1729	1739	200865811	1
1730	1740	200900039	1
1731	1741	200900138	1
1732	1742	200900163	1
1733	1743	200900184	1
1734	1744	200900407	1
1735	1745	200900495	1
1736	1746	200900643	1
1737	1747	200900790	1
1738	1748	200901056	1
1739	1749	200903933	1
1740	1750	200904996	1
1741	1751	200905558	1
1742	1752	200906611	1
1743	1753	200906984	1
1744	1754	200907623	1
1745	1755	200909509	1
1746	1756	200910151	1
1747	1757	200910605	1
1748	1758	200911631	1
1749	1759	200911675	1
1750	1760	200911724	1
1751	1761	200911734	1
1752	1762	200911738	1
1753	1763	200911827	1
1754	1764	200912221	1
1755	1765	200912581	1
1756	1766	200912820	1
1757	1767	200912874	1
1758	1768	200912972	1
1759	1769	200913084	1
1760	1770	200913146	1
1761	1771	200913757	1
1762	1772	200913846	1
1763	1773	200913901	1
1764	1774	200914214	1
1765	1775	200914369	1
1766	1776	200914550	1
1767	1777	200915033	1
1768	1778	200920483	1
1769	1779	200920633	1
1770	1780	200921105	1
1771	1781	200921634	1
1772	1782	200922056	1
1773	1783	200922763	1
1774	1784	200922784	1
1775	1785	200922882	1
1776	1786	200924554	1
1777	1787	200925215	1
1778	1788	200925241	1
1779	1789	200925249	1
1780	1790	200925556	1
1781	1791	200925562	1
1782	1792	200926277	1
1783	1793	200926328	1
1784	1794	200926380	1
1785	1795	200926385	1
1786	1796	200929259	1
1787	1797	200929277	1
1788	1798	200929367	1
1789	1799	200929381	1
1790	1800	200929428	1
1791	1801	200929656	1
1792	1802	200930017	1
1793	1803	200932205	1
1794	1804	200933686	1
1795	1805	200935632	1
1796	1806	200936633	1
1797	1807	200937320	1
1798	1808	200939122	1
1799	1809	200940273	1
1800	1810	200942368	1
1801	1811	200942606	1
1802	1812	200945214	1
1803	1813	200945219	1
1804	1814	200950378	1
1805	1815	200950655	1
1806	1816	200950663	1
1807	1817	200951345	1
1808	1818	200951383	1
1809	1819	200952820	1
1810	1820	200952936	1
1811	1821	200953322	1
1812	1822	200953427	1
1813	1823	200953449	1
1814	1824	200953589	1
1815	1825	200953593	1
1816	1826	200953879	1
1817	1827	200953979	1
1818	1828	200954553	1
1819	1829	200955605	1
1820	1830	200957922	1
1821	1831	200960039	1
1822	1832	200962443	1
1823	1833	200978170	1
1824	1834	200978810	1
1825	1835	200978939	1
1826	1836	200819985	1
1827	1837	200824759	1
1828	1838	200865810	1
1829	1839	200804221	1
\.


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentterms (studenttermid, studentid, termid, ineligibilities, issettled, cwa, gwa, mathgwa, csgwa) FROM stdin;
7049	1653	20002	N/A	t	2.3136	3.8235	2.6250	3.0500
7050	1653	20003	N/A	t	2.3074	2.2500	2.4474	3.0500
7052	1653	20012	N/A	t	2.6951	4.2000	2.5227	3.5300
7053	1653	20013	N/A	t	2.6563	2.1250	2.5227	3.3661
7055	1654	20021	N/A	t	2.4265	2.4265	3.0000	1.5000
7056	1655	20021	N/A	t	2.2500	2.2500	2.2500	2.2500
7057	1653	20022	N/A	t	2.7146	3.2500	2.5227	3.3316
7058	1654	20022	N/A	t	2.7132	3.0000	3.0000	3.2500
7060	1653	20031	N/A	t	2.7370	3.0000	2.5227	3.2802
7061	1654	20031	N/A	t	2.6250	2.3750	3.0000	2.8333
7063	1656	20031	N/A	t	2.5000	2.5000	2.5000	3.0000
7064	1657	20031	N/A	t	2.5909	2.5909	3.0000	0.0000
7065	1653	20032	N/A	t	2.7370	0.0000	2.5227	3.2802
7067	1655	20032	N/A	t	2.9710	4.6250	3.0476	3.1346
7068	1656	20032	N/A	t	2.6600	2.7857	2.7500	2.5000
7069	1657	20032	N/A	t	2.2500	2.0294	3.0000	1.2500
7071	1655	20033	N/A	t	2.9589	2.7500	3.0476	3.1346
7072	1656	20033	N/A	t	2.5323	2.0000	2.7500	2.5000
7073	1657	20033	N/A	t	2.5152	4.0000	3.3333	1.2500
7075	1655	20041	N/A	t	3.0577	3.4583	3.0417	3.4079
7076	1656	20041	N/A	t	2.7273	3.1923	2.6667	2.4000
7077	1657	20041	N/A	t	2.4844	2.4167	3.0625	1.8750
7079	1654	20042	N/A	t	2.5758	2.2500	3.0000	2.8581
7080	1655	20042	N/A	t	3.0354	2.9000	3.0417	3.4643
7081	1656	20042	N/A	t	3.2000	4.5789	3.3333	3.0000
7083	1658	20042	N/A	t	1.9032	2.1429	2.3750	1.1250
7084	1654	20043	N/A	t	2.5495	2.1786	3.0000	2.8581
7086	1656	20043	N/A	t	3.2000	0.0000	3.3333	3.0000
7087	1657	20043	N/A	t	2.7188	2.2500	3.3793	2.9167
7088	1658	20043	N/A	t	1.9032	0.0000	2.3750	1.1250
7090	1655	20051	N/A	t	2.9250	2.7500	3.0417	3.0625
7091	1656	20051	N/A	t	3.1349	3.2237	3.5417	3.0000
7092	1657	20051	N/A	t	2.7039	3.1000	3.5313	2.9375
7094	1659	20051	N/A	t	1.8824	1.8824	1.7500	1.7500
7095	1660	20051	N/A	t	1.9265	1.9265	1.7500	1.2500
7096	1654	20052	N/A	t	2.4981	2.2500	3.0000	2.6250
7098	1656	20052	N/A	t	3.0395	2.6579	3.5417	3.0000
7099	1658	20052	N/A	t	2.1439	2.6250	2.6071	1.5156
7100	1659	20052	N/A	t	2.5161	3.2857	3.3750	1.7500
7102	1655	20053	N/A	t	2.7785	1.1250	3.0417	2.7119
7103	1656	20053	N/A	t	3.0077	2.0000	3.3704	3.0000
7104	1659	20053	N/A	t	2.4792	2.2500	3.0000	1.7500
7106	1655	20061	N/A	t	2.7911	3.0000	3.0417	2.7500
7107	1658	20061	N/A	t	2.0402	1.7143	2.4688	1.6000
7109	1660	20061	N/A	t	2.0647	2.2794	2.1538	1.8281
7110	1661	20061	N/A	t	2.1618	2.1618	3.0000	2.0000
7111	1662	20061	N/A	t	2.5735	2.5735	5.0000	2.0000
7113	1664	20061	N/A	t	2.2500	2.2500	3.0000	2.5000
7114	1665	20061	N/A	t	2.4118	2.4118	4.0000	1.0000
7115	1666	20061	N/A	t	2.2059	2.2059	3.0000	1.2500
7117	1657	20062	N/A	t	2.6236	2.1538	3.4643	2.6406
7118	1658	20062	N/A	t	1.9476	1.5000	2.4688	1.4865
7119	1659	20062	N/A	t	3.0634	3.5333	3.4000	2.4231
7121	1661	20062	N/A	t	2.5221	2.8824	4.0000	2.1250
7122	1662	20062	N/A	t	2.5074	2.4412	3.8750	2.3750
7123	1663	20062	N/A	t	1.9706	2.0735	2.8750	2.0000
7125	1665	20062	N/A	t	2.1618	1.9118	3.0000	1.1250
7126	1666	20062	N/A	t	2.0735	1.9412	3.0000	1.3750
7127	1658	20063	N/A	t	1.9476	0.0000	2.4688	1.4865
7129	1660	20063	N/A	t	2.1044	1.7500	2.2656	1.9091
7130	1662	20063	N/A	t	2.5705	3.0000	3.5833	2.3750
7131	1663	20063	N/A	t	2.0526	2.7500	2.8750	2.0000
7133	1665	20063	N/A	t	2.2372	2.7500	2.9167	1.1250
7134	1666	20063	N/A	t	1.9875	1.5000	3.0000	1.3750
7136	1658	20071	N/A	t	2.0407	2.5833	2.4688	1.7959
7137	1659	20071	N/A	t	2.9888	2.7083	3.3226	2.5568
7138	1660	20071	N/A	t	2.1624	2.4167	2.2656	2.1397
7140	1662	20071	N/A	t	2.4052	2.0658	3.3125	2.4250
7141	1663	20071	N/A	t	2.0714	2.1111	2.9167	2.0000
7142	1664	20071	N/A	t	2.2406	2.2000	2.9167	2.4500
7144	1668	20071	N/A	t	2.1667	2.1667	1.7500	0.0000
7145	1665	20071	N/A	t	2.2457	2.2632	2.7500	1.3750
7147	1669	20071	N/A	t	1.7059	1.7059	2.5000	1.2500
7148	1670	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
7149	1671	20071	N/A	t	2.0735	2.0735	1.5000	1.2500
7150	1672	20071	N/A	t	3.2794	3.2794	5.0000	2.0000
7152	1674	20071	N/A	t	2.7679	2.7679	2.5000	1.2500
7153	1675	20071	N/A	t	1.9559	1.9559	2.7500	1.5000
7155	1677	20071	N/A	t	2.2059	2.2059	3.0000	2.0000
7156	1678	20071	N/A	t	1.7647	1.7647	1.5000	1.5000
7157	1679	20071	N/A	t	1.7206	1.7206	2.2500	1.0000
7159	1657	20072	N/A	t	2.5768	2.5500	3.4643	2.7763
7160	1658	20072	N/A	t	2.0265	1.9500	2.4688	1.7959
7161	1659	20072	N/A	t	3.1589	4.0000	3.3226	3.0726
7163	1661	20072	N/A	t	2.6208	2.4500	3.5000	2.2750
7164	1662	20072	N/A	t	2.3547	2.1719	3.0761	2.5000
7166	1664	20072	N/A	t	2.4826	3.1579	3.1190	3.0385
7167	1667	20072	N/A	t	3.2803	4.0694	3.6250	4.0000
7168	1668	20072	N/A	t	2.5446	2.8281	2.1591	2.2500
7170	1666	20072	N/A	t	2.4967	3.9219	3.2262	2.6346
7171	1669	20072	N/A	t	2.1618	2.6176	3.7500	1.5000
7172	1670	20072	N/A	t	2.1618	2.2500	2.2500	1.3750
7174	1672	20072	N/A	t	2.8603	2.4412	3.8750	2.1250
7175	1673	20072	N/A	t	2.2500	2.2941	3.0000	2.3750
7176	1674	20072	N/A	t	2.8929	3.0179	3.7500	1.3750
7178	1676	20072	N/A	t	1.6985	1.9118	1.5000	1.1250
7179	1677	20072	N/A	t	1.9779	1.7500	2.7500	1.5000
7180	1678	20072	N/A	t	1.7794	1.7941	2.0000	1.5000
7182	1658	20073	N/A	t	2.0148	1.5000	2.4688	1.7959
7185	1662	20073	N/A	t	2.3312	1.7500	2.9231	2.5000
7186	1664	20073	N/A	t	2.4633	2.0000	2.9792	3.0385
7188	1665	20073	N/A	t	2.4383	5.0000	2.6635	1.6923
7189	1666	20073	N/A	t	2.4573	2.0357	3.0417	2.6346
7191	1671	20073	N/A	t	2.2500	1.5000	2.2500	1.8750
7192	1672	20073	N/A	t	2.8782	3.0000	3.5833	2.1250
7193	1674	20073	N/A	t	2.6818	1.5000	3.0000	1.3750
7194	1675	20073	N/A	t	2.4038	2.0000	3.2500	1.7500
7196	1659	20081	N/A	t	3.1983	3.6667	3.3226	3.0608
7197	1660	20081	N/A	t	2.0620	1.5500	2.2656	1.8750
7199	1662	20081	N/A	t	2.2690	1.9500	2.9231	2.1932
7200	1663	20081	N/A	t	2.4389	2.7000	3.1667	2.5625
7201	1664	20081	N/A	t	2.4861	2.6000	2.9792	2.8523
7203	1668	20081	N/A	t	2.5598	2.5833	2.1591	3.0000
7204	1665	20081	N/A	t	2.5208	2.8553	2.6635	2.3661
7205	1666	20081	N/A	t	2.4533	2.0000	3.0417	2.3409
7207	1680	20081	N/A	t	1.9265	1.9265	2.5000	1.2500
7208	1670	20081	N/A	t	2.1085	2.0132	2.4167	1.4250
7210	1672	20081	N/A	t	2.7723	2.5294	3.5833	2.2750
7211	1673	20081	N/A	t	2.3950	2.7031	3.0000	2.5250
7212	1674	20081	N/A	t	2.9583	3.5667	3.2500	1.3750
7214	1676	20081	N/A	t	1.9387	2.3684	1.8333	1.6750
7215	1677	20081	N/A	t	2.2830	2.8289	3.5000	1.3000
7216	1678	20081	N/A	t	2.0802	2.6184	2.2500	2.1000
7218	1681	20081	N/A	t	2.0294	2.0294	3.0000	1.5000
7219	1682	20081	N/A	t	1.7941	1.7941	2.5000	1.0000
7220	1683	20081	N/A	t	2.2059	2.2059	2.2500	2.2500
7222	1685	20081	N/A	t	2.9265	2.9265	2.7500	2.2500
7223	1686	20081	N/A	t	2.3971	2.3971	2.0000	2.7500
7224	1687	20081	N/A	t	1.9853	1.9853	2.2500	2.2500
7226	1689	20081	N/A	t	2.0294	2.0294	2.2500	2.2500
7227	1690	20081	N/A	t	2.8382	2.8382	2.7500	3.0000
7228	1691	20081	N/A	t	1.9853	1.9853	2.2500	2.0000
7230	1693	20081	N/A	t	2.7794	2.7794	3.0000	2.5000
7231	1694	20081	N/A	t	2.1765	2.1765	2.7500	2.2500
7232	1695	20081	N/A	t	1.8235	1.8235	2.0000	1.0000
7234	1697	20081	N/A	t	2.1471	2.1471	2.5000	2.2500
7235	1698	20081	N/A	t	2.0147	2.0147	2.5000	1.0000
7237	1700	20081	N/A	t	2.0441	2.0441	2.0000	2.0000
7238	1701	20081	N/A	t	3.0179	3.0179	5.0000	2.0000
7239	1702	20081	N/A	t	2.2647	2.2647	2.7500	1.7500
7241	1704	20081	N/A	t	2.0441	2.0441	2.7500	2.0000
7242	1705	20081	N/A	t	1.8824	1.8824	1.7500	1.0000
7243	1706	20081	N/A	t	2.2353	2.2353	2.5000	2.2500
7245	1708	20081	N/A	t	2.4853	2.4853	2.7500	2.7500
7246	1709	20081	N/A	t	1.8824	1.8824	1.7500	1.5000
7247	1710	20081	N/A	t	1.9107	1.9107	1.0000	2.0000
7249	1712	20081	N/A	t	1.8235	1.8235	2.7500	1.7500
7250	1713	20081	N/A	t	1.8676	1.8676	1.2500	2.0000
7251	1714	20081	N/A	t	2.9265	2.9265	5.0000	5.0000
7253	1657	20082	N/A	t	2.5688	1.8125	3.4643	2.7264
7254	1659	20082	N/A	t	3.1855	2.9000	3.3226	3.1467
7256	1661	20082	N/A	t	2.5808	2.4500	3.0577	2.3026
7257	1662	20082	N/A	t	2.3000	2.4583	2.9231	2.1691
7258	1663	20082	N/A	t	2.4690	2.6500	3.1667	2.6000
7260	1667	20082	N/A	t	2.7429	2.3438	3.0952	2.8269
7261	1668	20082	N/A	t	2.5363	2.4688	2.1591	2.3947
7262	1665	20082	N/A	t	2.5180	2.5000	2.6635	2.2568
7264	1669	20082	N/A	t	2.2711	2.6563	3.2212	1.6538
7265	1680	20082	N/A	t	2.2786	2.6111	2.5000	1.8750
7267	1671	20082	N/A	t	2.5530	3.2941	2.7500	2.9423
7268	1672	20082	N/A	t	2.7577	2.6667	3.5833	2.4423
7269	1673	20082	N/A	t	2.4167	2.4844	2.9643	2.5250
7271	1675	20082	N/A	t	2.5037	3.4250	3.1630	1.9500
7272	1676	20082	N/A	t	2.1739	2.9531	2.3452	1.8654
7273	1677	20082	N/A	t	2.4706	3.4444	3.5870	1.4615
7275	1715	20082	N/A	t	2.2500	2.2500	3.0000	2.2500
7276	1679	20082	N/A	t	1.9097	2.1711	2.4405	1.5962
7277	1681	20082	N/A	t	2.0294	2.0294	2.6250	1.5000
7279	1683	20082	N/A	t	2.4044	2.6029	2.6250	2.2500
7280	1684	20082	N/A	t	2.3676	2.7059	4.0000	2.1250
7281	1685	20082	N/A	t	2.6397	2.3529	2.7500	2.3750
7283	1687	20082	N/A	t	1.9839	1.9821	2.6250	1.8750
7284	1688	20082	N/A	t	2.0368	1.9853	2.1250	1.0000
7286	1690	20082	N/A	t	2.8065	2.7679	2.6250	3.0000
7287	1691	20082	N/A	t	2.1176	2.2500	2.2500	2.0000
7288	1692	20082	N/A	t	2.7721	2.3971	3.8750	3.2500
7290	1694	20082	N/A	t	2.0956	2.0147	2.6250	2.2500
7291	1695	20082	N/A	t	1.9559	2.0882	2.3750	1.0000
7292	1696	20082	N/A	t	1.7868	1.8971	2.2500	1.3750
7294	1698	20082	N/A	t	2.1324	2.2500	2.7500	1.3750
7295	1699	20082	N/A	t	2.6397	3.1912	3.8750	1.8750
7296	1700	20082	N/A	t	2.1959	2.3250	1.7500	2.3750
7298	1702	20082	N/A	t	2.2647	2.2647	2.7500	2.1250
7299	1703	20082	N/A	t	2.3879	1.4375	2.7500	3.1250
7300	1704	20082	N/A	t	2.2353	2.4265	2.8750	2.5000
7302	1706	20082	N/A	t	2.0882	1.9412	2.3750	2.1250
7303	1707	20082	N/A	t	2.2279	2.1618	3.0000	2.2500
7305	1709	20082	N/A	t	1.8676	1.8529	1.6250	1.5000
7306	1710	20082	N/A	t	2.2143	2.5179	1.6250	2.5000
7307	1711	20082	N/A	t	2.6765	2.9706	4.0000	2.3750
7309	1713	20082	N/A	t	2.1397	2.4118	1.8750	1.8750
7310	1714	20082	N/A	t	2.5515	2.1765	3.8750	3.8750
7311	1656	20083	N/A	t	3.0225	2.7500	3.3083	3.0000
7313	1662	20083	N/A	t	2.2721	1.2500	2.9231	2.1691
7314	1664	20083	N/A	t	2.5023	1.2500	2.9792	2.7500
7315	1667	20083	N/A	t	2.7021	1.7500	3.0952	2.8269
7317	1669	20083	N/A	t	2.2403	1.8750	3.1207	1.6538
7318	1680	20083	N/A	t	2.2756	2.2500	2.5000	1.8750
7321	1674	20083	N/A	t	2.6014	1.0000	2.6875	1.4167
7322	1675	20083	N/A	t	2.5246	3.0000	3.1442	1.9500
7324	1677	20083	N/A	t	2.4767	2.5357	3.4327	1.4615
7325	1715	20083	N/A	t	2.4205	3.0000	3.0000	2.2500
7327	1685	20083	N/A	t	2.4688	1.5000	2.7500	2.3750
7328	1686	20083	N/A	t	2.6053	3.0000	3.0000	2.8750
7329	1690	20083	N/A	t	2.8333	3.0000	2.7500	3.0000
7331	1693	20083	N/A	t	2.7813	1.1250	4.0000	2.2500
7332	1695	20083	N/A	t	1.8974	1.5000	2.0833	1.0000
7333	1696	20083	N/A	t	1.8355	2.2500	2.2500	1.3750
7335	1700	20083	N/A	t	2.2558	2.6250	1.7500	2.3750
7336	1701	20083	N/A	t	2.4792	3.0000	3.5000	1.7500
7337	1702	20083	N/A	t	2.1500	1.5000	2.7500	2.1250
7339	1704	20083	N/A	t	2.5897	5.0000	3.5833	2.5000
7340	1705	20083	N/A	t	1.9615	2.0000	2.2500	1.0000
7341	1708	20083	N/A	t	2.5897	3.0000	2.8333	2.6250
7343	1710	20083	N/A	t	2.0303	1.0000	1.4167	2.5000
7344	1711	20083	N/A	t	2.6859	2.7500	3.5833	2.3750
7346	1656	20091	N/A	t	3.1667	4.5000	3.3083	3.4800
7347	1657	20091	N/A	t	2.5451	2.5000	3.4643	2.7264
7348	1659	20091	N/A	t	3.1294	2.5000	3.3226	3.0246
7349	1660	20091	N/A	t	2.0763	2.0000	2.2656	1.8679
7351	1662	20091	N/A	t	2.3960	3.5625	2.9231	2.5326
7352	1663	20091	N/A	t	2.4979	2.5500	3.1667	2.7721
7354	1716	20091	N/A	t	1.7000	1.7000	0.0000	2.0000
7355	1667	20091	N/A	t	2.7188	2.8000	3.0952	2.8421
7356	1668	20091	N/A	t	2.5000	2.3125	2.1591	2.4286
7358	1666	20091	N/A	t	2.5471	2.7031	3.0417	2.3409
7359	1669	20091	N/A	t	2.4130	3.3000	3.1207	1.7632
7360	1680	20091	N/A	t	2.4183	3.0625	3.2500	1.8250
7362	1670	20091	N/A	t	2.2742	2.6429	2.4762	2.0455
7363	1671	20091	N/A	t	2.6609	3.0417	2.7500	2.9605
7364	1672	20091	N/A	t	2.8375	3.7692	3.5870	2.6184
7366	1674	20091	N/A	t	2.7259	3.3393	2.9113	1.5313
7367	1675	20091	N/A	t	2.6006	2.7500	3.1442	2.1316
7368	1676	20091	N/A	t	2.3833	2.8000	2.3646	1.9545
7370	1678	20091	N/A	t	2.0893	2.0500	2.2813	1.9219
7371	1715	20091	N/A	t	2.4803	2.5625	3.4615	2.0000
7372	1679	20091	N/A	t	1.9278	2.0000	2.4405	1.6250
7374	1719	20091	N/A	t	2.5000	2.5000	3.0000	2.7500
7375	1681	20091	N/A	t	2.0561	2.1167	2.5833	1.4167
7376	1720	20091	N/A	t	2.6500	2.6500	3.0000	0.0000
7378	1683	20091	N/A	t	2.4151	2.4342	2.7500	2.3500
7379	1721	20091	N/A	t	2.0417	2.0417	2.5000	2.0000
7381	1685	20091	N/A	t	2.6339	3.0469	3.5000	2.3250
7382	1686	20091	N/A	t	2.8113	3.3333	3.0000	2.8750
7383	1687	20091	N/A	t	2.1100	2.3158	2.7500	2.1250
7384	1722	20091	N/A	t	2.1667	2.1667	2.5000	0.0000
7386	1688	20091	N/A	t	2.0200	1.9844	2.2500	1.0000
7387	1724	20091	N/A	t	2.4722	2.4722	3.0000	2.2500
7389	1690	20091	N/A	t	2.7206	2.4500	3.1250	2.5000
7390	1725	20091	N/A	t	2.7083	2.7083	2.7500	2.2500
7391	1726	20091	N/A	t	1.6346	1.6346	0.0000	1.5000
7393	1692	20091	N/A	t	2.6447	2.3750	3.3750	2.5833
7394	1693	20091	N/A	t	2.7455	2.6563	3.6667	2.5500
7395	1694	20091	N/A	t	2.0613	2.0000	2.4167	2.0500
7397	1696	20091	N/A	t	1.8070	1.7500	2.1667	1.5250
7398	1697	20091	N/A	t	2.4440	2.3553	3.2500	2.3250
7400	1699	20091	N/A	t	2.5750	2.4375	3.5000	1.9250
7401	1700	20091	N/A	t	2.8545	5.0000	2.8333	3.2500
7402	1701	20091	N/A	t	2.3682	2.1579	3.2500	1.6500
7404	1702	20091	N/A	t	2.2232	2.4063	2.8333	2.2750
7405	1728	20091	N/A	t	2.0556	2.0556	2.7500	1.7500
7406	1703	20091	N/A	t	2.2227	2.2083	2.5000	2.8333
7408	1705	20091	N/A	t	1.9958	2.0625	2.3750	1.4844
7409	1706	20091	N/A	t	2.1840	2.3553	2.5833	2.3750
7410	1707	20091	N/A	t	2.2123	2.1842	2.9167	1.8500
7412	1729	20091	N/A	t	1.8472	1.8472	2.2500	1.5000
7413	1709	20091	N/A	t	2.1708	2.6765	2.3611	1.8000
7414	1710	20091	N/A	t	2.3000	2.8235	1.8472	2.5000
7416	1712	20091	N/A	t	2.1780	2.4250	2.3611	2.4500
7417	1713	20091	N/A	t	2.2500	2.4844	2.0833	2.1250
7419	1730	20091	N/A	t	1.5735	1.5735	1.0000	1.0000
7420	1731	20091	N/A	t	1.6471	1.6471	1.2500	1.5000
7421	1732	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
7422	1733	20091	N/A	t	2.2353	2.2353	2.5000	3.0000
7424	1735	20091	N/A	t	1.8971	1.8971	2.2500	1.5000
7425	1736	20091	N/A	t	2.7500	2.7500	2.7500	5.0000
7427	1738	20091	N/A	t	1.8088	1.8088	2.2500	2.7500
7428	1739	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
7429	1740	20091	N/A	t	1.6912	1.6912	2.7500	1.0000
7431	1742	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
7432	1743	20091	N/A	t	2.1912	2.1912	2.5000	2.5000
7433	1744	20091	N/A	t	1.6765	1.6765	2.2500	1.0000
7435	1746	20091	N/A	t	1.4559	1.4559	1.5000	1.0000
7436	1747	20091	N/A	t	3.0147	3.0147	5.0000	2.7500
7437	1748	20091	N/A	t	1.9265	1.9265	2.5000	2.0000
7439	1750	20091	N/A	t	1.9412	1.9412	2.2500	1.7500
7440	1751	20091	N/A	t	1.4412	1.4412	1.0000	1.5000
7441	1752	20091	N/A	t	2.7941	2.7941	2.7500	5.0000
7443	1754	20091	N/A	t	1.4706	1.4706	1.2500	1.5000
7444	1755	20091	N/A	t	1.6176	1.6176	1.7500	2.5000
7446	1757	20091	N/A	t	2.3529	2.3529	2.7500	2.7500
7447	1758	20091	N/A	t	1.8529	1.8529	1.5000	2.0000
7448	1759	20091	N/A	t	2.3088	2.3088	2.7500	3.0000
7450	1761	20091	N/A	t	1.7941	1.7941	1.7500	1.7500
7452	1763	20091	N/A	t	1.9118	1.9118	2.0000	2.0000
7453	1764	20091	N/A	t	1.5294	1.5294	1.7500	1.5000
7454	1765	20091	N/A	t	1.8088	1.8088	2.2500	1.5000
7457	1768	20091	N/A	t	2.1765	2.1765	2.7500	1.2500
7458	1769	20091	N/A	t	1.9853	1.9853	2.2500	1.0000
7460	1771	20091	N/A	t	1.7500	1.7500	1.0000	2.0000
7461	1772	20091	N/A	t	1.5147	1.5147	2.0000	1.0000
7462	1773	20091	N/A	t	2.3971	2.3971	2.7500	2.0000
7464	1775	20091	N/A	t	1.5882	1.5882	2.2500	1.0000
7465	1776	20091	N/A	t	2.1471	2.1471	2.5000	3.0000
7467	1778	20091	N/A	t	1.2647	1.2647	1.7500	1.0000
7468	1779	20091	N/A	t	2.2941	2.2941	3.0000	2.0000
7469	1780	20091	N/A	t	2.1765	2.1765	2.7500	2.5000
7471	1782	20091	N/A	t	1.9853	1.9853	3.0000	1.2500
7472	1783	20091	N/A	t	1.7647	1.7647	2.2500	1.5000
7473	1784	20091	N/A	t	1.4265	1.4265	1.2500	1.5000
7475	1786	20091	N/A	t	2.1618	2.1618	2.2500	1.0000
7476	1787	20091	N/A	t	1.2000	1.2000	1.0000	1.0000
7477	1788	20091	N/A	t	1.2647	1.2647	1.0000	1.5000
7479	1790	20091	N/A	t	1.7206	1.7206	2.2500	1.0000
7480	1791	20091	N/A	t	1.8382	1.8382	1.7500	2.0000
7481	1792	20091	N/A	t	2.0294	2.0294	3.0000	1.0000
7483	1794	20091	N/A	t	2.2500	2.2500	2.2500	2.7500
7484	1795	20091	N/A	t	1.2353	1.2353	1.5000	1.0000
7486	1797	20091	N/A	t	2.3971	2.3971	2.0000	2.2500
7487	1798	20091	N/A	t	2.3824	2.3824	3.0000	2.5000
7488	1799	20091	N/A	t	3.1912	3.1912	5.0000	2.5000
7490	1801	20091	N/A	t	2.0735	2.0735	3.0000	1.7500
7491	1802	20091	N/A	t	1.5882	1.5882	1.5000	1.7500
7492	1803	20091	N/A	t	1.5441	1.5441	1.5000	1.2500
7494	1805	20091	N/A	t	2.0441	2.0441	2.7500	1.7500
7495	1806	20091	N/A	t	2.1324	2.1324	2.7500	2.0000
7496	1807	20091	N/A	t	1.7206	1.7206	2.2500	2.0000
7498	1809	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
7499	1810	20091	N/A	t	1.8971	1.8971	2.2500	2.7500
7500	1811	20091	N/A	t	2.1324	2.1324	2.7500	1.0000
7502	1813	20091	N/A	t	1.7059	1.7059	2.5000	1.5000
7503	1814	20091	N/A	t	2.0147	2.0147	2.5000	1.2500
7504	1815	20091	N/A	t	2.6618	2.6618	5.0000	1.0000
7506	1817	20091	N/A	t	2.2500	2.2500	3.0000	3.0000
7507	1818	20091	N/A	t	1.8088	1.8088	2.2500	1.7500
7509	1820	20091	N/A	t	1.8971	1.8971	3.0000	1.7500
7510	1821	20091	N/A	t	2.0588	2.0588	2.5000	2.0000
7511	1822	20091	N/A	t	2.8676	2.8676	3.0000	4.0000
7513	1824	20091	N/A	t	2.1471	2.1471	2.5000	2.0000
7514	1825	20091	N/A	t	1.5147	1.5147	2.0000	1.1250
7515	1656	20092	N/A	t	3.1407	3.4167	3.5069	3.2838
7517	1661	20092	N/A	t	2.4154	1.7500	3.0577	2.0263
7518	1662	20092	N/A	t	2.3607	2.0000	2.9231	2.5326
7520	1664	20092	N/A	t	2.5079	2.5000	2.9792	2.6346
7521	1716	20092	N/A	t	1.9375	2.0781	0.0000	2.0568
7522	1667	20092	N/A	t	2.6250	1.9375	3.0952	2.7600
7524	1665	20092	N/A	t	2.5581	2.0000	2.6635	2.2500
7525	1666	20092	N/A	t	2.6045	3.1875	3.0417	2.3450
7526	1669	20092	N/A	t	2.3692	2.4167	3.1207	1.8790
7528	1717	20092	N/A	t	2.3182	2.5417	2.2500	2.5000
7529	1670	20092	N/A	t	2.2027	1.8333	2.4762	1.9632
7530	1671	20092	N/A	t	2.5905	2.2500	2.7500	2.6371
7532	1673	20092	N/A	t	2.4056	1.7917	2.9643	2.2700
7533	1674	20092	N/A	t	2.8194	3.9286	2.8750	1.5313
7534	1675	20092	N/A	t	2.5443	1.7000	3.1442	2.1300
7536	1677	20092	N/A	t	2.5671	2.3333	3.4914	1.9324
7537	1678	20092	N/A	t	2.0938	2.1250	2.2813	2.0400
7539	1679	20092	N/A	t	2.0023	2.3750	2.4405	1.8897
7540	1718	20092	N/A	t	2.8194	2.7083	3.7500	2.3750
7541	1719	20092	N/A	t	2.7569	3.0139	4.0000	2.8750
7543	1720	20092	N/A	t	2.2721	1.9737	3.0000	1.0000
7544	1682	20092	N/A	t	1.8090	1.9737	2.2639	1.5313
7545	1683	20092	N/A	t	2.4965	2.7237	3.1250	2.2188
7547	1684	20092	N/A	t	2.5169	3.3421	3.6827	2.7500
7548	1685	20092	N/A	t	2.5704	2.7778	3.1250	2.9531
7549	1686	20092	N/A	t	2.9472	3.3472	3.2500	3.2188
7551	1722	20092	N/A	t	2.2344	2.2941	2.7500	2.5000
7552	1723	20092	N/A	t	2.2230	2.4405	2.5000	2.5192
7553	1688	20092	N/A	t	2.0870	2.2632	2.2917	1.1406
7555	1689	20092	N/A	t	2.6507	3.3833	3.2500	2.2500
7556	1690	20092	N/A	t	2.7955	3.0500	3.0625	2.5000
7558	1726	20092	N/A	t	2.1250	2.9583	2.5000	2.7885
7559	1691	20092	N/A	t	2.2743	2.6974	2.4444	2.3125
7560	1826	20092	N/A	t	3.1333	3.1333	3.0000	2.2500
7562	1693	20092	N/A	t	2.7601	2.8056	3.7500	2.6538
7563	1694	20092	N/A	t	2.3623	3.4605	2.6190	2.2115
7564	1695	20092	N/A	t	1.8090	1.9844	1.9444	1.3906
7566	1696	20092	N/A	t	1.9493	3.1000	2.3056	2.8281
7567	1697	20092	N/A	t	2.4261	2.8438	3.2500	2.9531
7568	1698	20092	N/A	t	2.4891	3.1719	2.8810	2.5577
7570	1700	20092	N/A	t	2.9007	3.0417	2.8750	3.1875
7571	1701	20092	N/A	t	2.3521	2.2969	3.2500	2.0156
7572	1727	20092	N/A	t	2.1544	2.1316	2.9063	2.0833
7574	1728	20092	N/A	t	2.0735	2.0938	2.6563	2.0833
7575	1703	20092	N/A	t	2.3299	3.0250	2.5833	3.1842
7577	1705	20092	N/A	t	2.1007	2.7500	2.3750	2.0968
7578	1706	20092	N/A	t	2.2222	2.3289	2.5278	2.3281
7579	1707	20092	N/A	t	2.2717	2.8684	2.9306	2.6094
7581	1828	20092	N/A	t	2.1842	2.1842	2.7500	2.2500
7582	1729	20092	N/A	t	1.5878	1.3421	1.7500	1.2250
7583	1709	20092	N/A	t	2.4367	3.5000	2.3810	2.5385
7585	1711	20092	N/A	t	2.4595	2.1548	3.2500	2.5250
7586	1712	20092	N/A	t	2.2967	2.7344	2.3611	2.6094
7587	1713	20092	N/A	t	2.4848	3.2188	2.0278	2.4063
7589	1730	20092	N/A	t	1.5662	1.5588	1.5000	1.0000
7590	1731	20092	N/A	t	1.8015	1.9559	1.6250	2.0000
7593	1734	20092	N/A	t	1.7823	2.0893	2.3750	1.7500
7594	1735	20092	N/A	t	1.8986	1.9000	2.3750	1.5000
7596	1737	20092	N/A	t	2.2426	2.2206	2.3750	2.6250
7597	1738	20092	N/A	t	2.0074	2.2059	2.6250	2.6250
7599	1740	20092	N/A	t	1.7941	1.8971	2.8750	1.1250
7600	1741	20092	N/A	t	2.1029	2.1176	2.8750	2.2500
7601	1742	20092	N/A	t	2.6290	2.2143	3.8750	2.7500
7603	1744	20092	N/A	t	1.7794	1.8824	2.3750	1.2500
7604	1745	20092	N/A	t	1.4191	1.4412	1.3750	1.1250
7605	1746	20092	N/A	t	1.6250	1.7941	2.0000	1.0000
7607	1748	20092	N/A	t	2.1486	2.3375	3.7500	2.1250
7608	1749	20092	N/A	t	1.7206	1.7059	1.8750	2.0000
7609	1750	20092	N/A	t	1.9191	1.8971	2.6250	1.3750
7611	1752	20092	N/A	t	2.4779	2.1618	2.8750	3.1250
7612	1753	20092	N/A	t	2.1544	2.0882	2.3750	2.2500
7613	1754	20092	N/A	t	1.6176	1.7647	1.3750	1.5000
7615	1756	20092	N/A	t	1.7647	1.8824	1.8750	1.7500
7616	1757	20092	N/A	t	2.2868	2.2206	2.7500	2.6250
7618	1759	20092	N/A	t	2.0588	1.8088	2.5000	2.2500
7619	1760	20092	N/A	t	2.5662	2.1618	4.0000	2.7500
7620	1761	20092	N/A	t	2.0441	2.2941	2.3750	2.3750
7622	1763	20092	N/A	t	1.8676	1.8235	2.3750	1.5000
7623	1764	20092	N/A	t	1.6250	1.7206	2.0000	1.6250
7624	1765	20092	N/A	t	2.3871	3.0893	3.1250	2.1250
7626	1767	20092	N/A	t	2.3162	2.0735	3.0000	2.8750
7627	1768	20092	N/A	t	2.0809	1.9853	2.8750	1.2500
7628	1769	20092	N/A	t	1.8382	1.6912	2.5000	1.0000
7630	1771	20092	N/A	t	1.6875	1.6324	1.3125	1.7500
7631	1772	20092	N/A	t	1.6618	1.8088	2.5000	1.1250
7632	1773	20092	N/A	t	2.2647	2.1324	2.7500	2.0000
7634	1775	20092	N/A	t	1.7279	1.8676	2.5000	1.0000
7635	1776	20092	N/A	t	2.1103	2.0735	2.7500	2.6250
7636	1777	20092	N/A	t	1.7574	2.0000	2.0000	2.1250
7638	1779	20092	N/A	t	2.1757	2.0750	2.8750	2.0000
7639	1780	20092	N/A	t	2.3382	2.5000	2.6250	2.6250
7640	1781	20092	N/A	t	1.5147	1.5588	2.0000	1.0000
7642	1783	20092	N/A	t	2.1029	2.4412	3.6250	1.6250
7643	1784	20092	N/A	t	1.6838	1.9412	2.1250	2.0000
7645	1786	20092	N/A	t	2.1471	2.1324	2.5000	1.5000
7646	1787	20092	N/A	t	1.2500	1.2941	1.1563	1.0000
7647	1788	20092	N/A	t	1.3088	1.3529	1.3750	1.2500
7649	1790	20092	N/A	t	2.0956	2.4706	2.6250	1.5000
7650	1791	20092	N/A	t	2.0441	2.2500	2.3750	2.1250
7651	1792	20092	N/A	t	1.9559	1.8824	2.7500	1.1250
7653	1794	20092	N/A	t	2.2903	2.3393	2.3750	2.7500
7654	1795	20092	N/A	t	1.4265	1.6176	1.6250	1.0000
7656	1797	20092	N/A	t	2.1765	1.9559	2.3750	2.3750
7657	1798	20092	N/A	t	2.0441	1.7059	2.7500	2.0000
7658	1799	20092	N/A	t	2.6985	2.2059	4.0000	2.3750
7659	1800	20092	N/A	t	1.3162	1.2941	1.2500	1.0000
7661	1802	20092	N/A	t	1.9265	2.2647	2.1250	1.8750
7662	1803	20092	N/A	t	2.0368	2.5294	3.2500	1.5000
7664	1805	20092	N/A	t	2.0882	2.1324	2.7500	2.0000
7665	1806	20092	N/A	t	2.4412	2.7500	3.8750	1.8750
7666	1807	20092	N/A	t	1.7365	1.7500	2.3750	1.6250
7668	1809	20092	N/A	t	2.3676	2.3971	2.5000	2.5000
7669	1810	20092	N/A	t	2.5441	3.1912	3.6250	2.8750
7670	1811	20092	N/A	t	2.3971	2.6618	3.8750	1.2500
7672	1813	20092	N/A	t	1.8382	1.9706	2.5000	1.7500
7673	1814	20092	N/A	t	1.9559	1.8971	2.3750	1.1250
7675	1816	20092	N/A	t	2.1471	1.9559	2.8750	1.5000
7676	1817	20092	N/A	t	2.2759	2.3125	3.0000	2.7500
7677	1818	20092	N/A	t	1.7500	1.6912	2.5000	1.5000
7679	1820	20092	N/A	t	2.0588	2.2206	2.8750	2.0000
7680	1821	20092	N/A	t	2.3162	2.5735	3.7500	2.0000
7681	1822	20092	N/A	t	2.4706	2.0735	3.0000	3.0000
7683	1824	20092	N/A	t	2.5147	2.8824	2.6250	2.1250
7684	1825	20092	N/A	t	1.4779	1.4412	2.2500	1.0625
7685	1656	20093	N/A	t	3.0898	1.9250	3.5069	3.2838
7687	1661	20093	N/A	t	2.3942	1.5000	3.0577	1.9878
7688	1662	20093	N/A	t	2.3607	1.8750	2.9231	2.5326
7689	1664	20093	N/A	t	2.5659	5.0000	2.9792	2.7636
7691	1668	20093	N/A	t	2.3451	1.5000	2.1591	2.1744
7692	1665	20093	N/A	t	2.5259	1.0000	2.6635	2.1830
7694	1669	20093	N/A	t	2.3455	3.2500	3.1207	1.8790
7695	1670	20093	N/A	t	2.1987	2.1250	2.4762	1.9632
7696	1672	20093	N/A	t	2.8662	2.6250	3.6207	2.5341
7698	1674	20093	N/A	t	2.8686	3.5000	2.8750	1.5313
7699	1677	20093	N/A	t	2.5373	2.0000	3.4914	1.9324
7700	1715	20093	N/A	t	2.5395	1.2500	3.1579	2.8462
7702	1683	20093	N/A	t	2.4199	1.5000	2.8571	2.2188
7703	1721	20093	N/A	t	2.2692	2.0000	2.5769	2.7500
7704	1685	20093	N/A	t	2.7208	4.5000	3.3696	2.9531
7706	1722	20093	N/A	t	2.4714	5.0000	2.7500	3.3333
7707	1723	20093	N/A	t	2.2560	2.5000	2.5000	2.5192
7708	1724	20093	N/A	t	2.3625	1.7500	2.7188	2.3750
7710	1725	20093	N/A	t	2.5347	2.7500	2.7500	2.3654
7711	1726	20093	N/A	t	2.1855	2.7500	2.5938	2.7885
7712	1692	20093	N/A	t	2.6928	2.0000	3.5192	2.6719
7714	1695	20093	N/A	t	1.7767	1.5000	1.9444	1.3906
7715	1696	20093	N/A	t	1.9201	3.1250	2.3056	2.9091
7717	1699	20093	N/A	t	2.5856	1.7500	3.1957	2.8289
7718	1701	20093	N/A	t	2.3636	2.5000	3.2174	2.0156
7719	1702	20093	N/A	t	2.4660	2.6250	3.1310	2.4531
7721	1706	20093	N/A	t	2.1667	1.5000	2.5278	2.3281
7722	1708	20093	N/A	t	2.8734	2.7500	3.0595	3.0938
7723	1729	20093	N/A	t	1.6000	3.3750	1.7500	2.0962
7725	1710	20093	N/A	t	2.2283	1.7500	1.8472	2.5000
7726	1711	20093	N/A	t	2.4416	3.5000	3.2500	2.8906
7097	1655	20052	N/A	t	2.8479	2.2105	3.0417	2.7902
7047	1653	19991	N/A	t	1.8804	1.8804	1.0000	0.0000
7101	1660	20052	N/A	t	1.9929	2.0556	2.1250	1.1250
7048	1653	20001	N/A	t	1.8841	1.8889	1.5000	1.5000
7051	1653	20011	N/A	t	2.3857	2.9375	2.5227	3.0781
7054	1653	20021	N/A	t	2.7050	3.0500	2.5227	3.3500
7059	1655	20022	N/A	t	2.3824	2.5147	2.6250	2.6250
7062	1655	20031	N/A	t	2.4717	2.6316	2.6667	2.5750
7066	1654	20032	N/A	t	2.5524	2.3438	3.0000	2.9063
7070	1654	20033	N/A	t	2.5341	2.2500	3.0000	2.9063
7074	1654	20041	N/A	t	2.6429	3.0417	3.0000	3.1200
7078	1658	20041	N/A	t	1.7059	1.7059	2.5000	1.0000
7105	1660	20053	N/A	t	1.9756	1.8750	2.1538	1.1250
7082	1657	20042	N/A	t	2.7418	3.9375	3.5096	2.9167
7085	1655	20043	N/A	t	2.9531	1.5000	3.0417	3.4643
7089	1654	20051	N/A	t	2.5294	2.2895	3.0000	2.6887
7093	1658	20051	N/A	t	1.9900	2.1316	2.5000	1.4038
7108	1659	20061	N/A	t	2.9279	3.9375	3.5000	2.2500
7112	1663	20061	N/A	t	1.8676	1.8676	2.7500	2.2500
7116	1655	20062	N/A	t	2.7950	3.0000	3.0417	2.7610
7120	1660	20062	N/A	t	2.1184	2.2917	2.2656	1.9091
7124	1664	20062	N/A	t	2.2279	2.2059	3.0000	2.2500
7128	1659	20063	N/A	t	3.0599	3.0000	3.4000	2.4231
7135	1657	20071	N/A	t	2.6520	3.2500	3.4643	3.0690
7132	1664	20063	N/A	t	2.2566	2.5000	3.0000	2.2500
7139	1661	20071	N/A	t	2.6550	2.9375	3.5000	2.2750
7143	1667	20071	N/A	t	2.3333	2.3333	2.2500	3.0000
7146	1666	20071	N/A	t	2.1102	2.3684	2.9167	1.9250
7151	1673	20071	N/A	t	2.2059	2.2059	3.0000	1.7500
7154	1676	20071	N/A	t	1.4853	1.4853	1.0000	1.0000
7158	1655	20072	N/A	t	2.7988	3.0000	3.0417	2.7610
7162	1660	20072	N/A	t	2.1071	1.7500	2.2656	2.0058
7165	1663	20072	N/A	t	2.3867	3.3158	3.1905	2.6923
7169	1665	20072	N/A	t	2.2979	2.5000	2.6635	1.6923
7173	1671	20072	N/A	t	2.3162	2.5588	2.2500	1.8750
7177	1675	20072	N/A	t	2.4632	2.9706	3.8750	1.7500
7727	1730	20093	N/A	t	1.5655	1.5625	1.5833	1.0000
7728	1735	20093	N/A	t	1.8056	1.3750	1.9167	1.5000
7730	1740	20093	N/A	t	1.9167	2.7500	2.8333	1.1250
7731	1742	20093	N/A	t	2.5676	2.2500	3.8750	2.7500
7733	1749	20093	N/A	t	1.6603	1.2500	1.6667	2.0000
7734	1750	20093	N/A	t	1.9615	2.2500	2.5000	1.3750
7735	1752	20093	N/A	t	2.4487	2.2500	2.6667	3.1250
7736	1753	20093	N/A	t	2.1346	2.0000	2.2500	2.2500
7738	1755	20093	N/A	t	1.8846	1.0000	1.7500	3.7500
7739	1756	20093	N/A	t	1.7628	1.7500	1.8333	1.7500
7741	1762	20093	N/A	t	1.6250	1.7500	1.6250	1.3750
7742	1763	20093	N/A	t	1.7750	1.2500	2.3750	1.5000
7743	1765	20093	N/A	t	2.2647	1.0000	3.1250	2.1250
7745	1767	20093	N/A	t	2.2703	3.3750	3.0000	3.1250
7746	1768	20093	N/A	t	2.0705	2.0000	2.5833	1.2500
7747	1770	20093	N/A	t	2.1987	1.5000	2.6667	1.8750
7749	1780	20093	N/A	t	2.2949	2.0000	2.4167	2.6250
7750	1781	20093	N/A	t	1.4563	1.1250	2.0000	1.0625
7752	1783	20093	N/A	t	1.9615	1.0000	2.7500	1.6250
7753	1787	20093	N/A	t	1.2162	1.0000	1.0962	1.0000
7754	1788	20093	N/A	t	1.2692	1.0000	1.2500	1.2500
7755	1790	20093	N/A	t	2.2115	3.0000	2.7500	1.5000
7757	1792	20093	N/A	t	1.8974	1.5000	2.3333	1.1250
7758	1794	20093	N/A	t	2.3542	2.7500	2.5000	2.7500
7760	1797	20093	N/A	t	2.0577	1.2500	2.0000	2.3750
7761	1798	20093	N/A	t	2.0385	2.0000	2.5000	2.0000
7762	1799	20093	N/A	t	2.6090	2.0000	3.3333	2.3750
7764	1801	20093	N/A	t	2.3333	2.2500	3.4167	2.0000
7765	1803	20093	N/A	t	1.9038	1.0000	2.5000	1.5000
7766	1806	20093	N/A	t	2.4487	2.5000	3.4167	1.8750
7768	1809	20093	N/A	t	2.3036	2.0313	2.5000	2.5000
7769	1810	20093	N/A	t	2.4744	2.0000	3.0833	2.8750
7770	1811	20093	N/A	t	2.3462	2.0000	3.2500	1.2500
7772	1813	20093	N/A	t	1.7905	1.2500	2.5000	1.7500
7773	1814	20093	N/A	t	1.9615	2.0000	2.2500	1.1250
7774	1815	20093	N/A	t	2.5256	5.0000	4.1667	1.2500
7776	1817	20093	N/A	t	2.6765	5.0000	4.0000	2.7500
7777	1818	20093	N/A	t	1.7500	1.7500	2.2500	1.5000
7779	1822	20093	N/A	t	2.5385	3.0000	3.0000	3.0000
7780	1823	20093	N/A	t	1.7756	1.0000	1.9167	1.7500
7781	1824	20093	N/A	t	2.4808	2.2500	2.5000	2.1250
7783	1659	20101	N/A	t	3.0000	3.0357	3.3226	2.9824
7784	1660	20101	N/A	t	2.0634	1.5000	2.2656	1.8482
7785	1661	20101	N/A	t	2.4243	2.7500	3.0577	2.1604
7787	1664	20101	N/A	t	2.5382	2.2083	2.9792	2.7276
7788	1716	20101	N/A	t	2.5306	3.5833	0.0000	2.5608
7789	1667	20101	N/A	t	2.6719	3.0625	3.0952	2.9338
7791	1665	20101	N/A	t	2.5760	5.0000	2.6635	2.1830
7792	1666	20101	N/A	t	2.6062	2.9375	3.0417	2.2545
7793	1669	20101	N/A	t	2.4316	2.9583	3.1207	2.0349
7795	1717	20101	N/A	t	2.2959	2.2500	2.2500	2.1923
7796	1670	20101	N/A	t	2.2898	2.8333	2.4762	2.0969
7798	1672	20101	N/A	t	2.9956	3.8500	3.6207	2.8214
7799	1673	20101	N/A	t	2.4190	2.5000	2.9643	2.3041
7800	1674	20101	N/A	t	2.8477	3.1250	3.0473	1.6447
7802	1676	20101	N/A	t	2.2750	2.0000	2.3646	1.9620
7803	1677	20101	N/A	t	2.6093	3.0000	3.4914	2.1683
7804	1678	20101	N/A	t	2.0469	1.8026	2.2813	1.9375
7806	1679	20101	N/A	t	2.1329	2.9167	2.4405	2.2449
7807	1718	20101	N/A	t	2.5441	1.8833	3.5000	1.7692
7808	1719	20101	N/A	t	2.6625	2.4605	3.4861	2.7885
7810	1720	20101	N/A	t	2.2170	2.1184	3.0000	1.7750
7811	1829	20101	N/A	t	2.9167	2.9167	2.7500	3.0000
7812	1682	20101	N/A	t	1.7472	1.5000	2.2639	1.4919
7181	1679	20072	N/A	t	1.6912	1.6618	2.3750	1.1250
7369	1677	20091	N/A	t	2.6139	3.4167	3.4914	1.7500
7183	1660	20073	N/A	t	2.1071	0.0000	2.2656	2.0058
7449	1760	20091	N/A	t	2.9706	2.9706	5.0000	2.7500
7184	1661	20073	N/A	t	2.5933	2.3571	3.5000	2.2750
7187	1667	20073	N/A	t	3.1026	2.1250	3.6250	4.0000
7190	1669	20073	N/A	t	2.1090	1.7500	3.0833	1.5000
7373	1718	20091	N/A	t	2.9306	2.9306	5.0000	1.7500
7195	1657	20081	N/A	t	2.6061	2.7917	3.4643	2.8000
7198	1661	20081	N/A	t	2.6042	2.6471	3.1875	2.2692
7202	1667	20081	N/A	t	2.8611	2.2333	3.3333	3.0833
7206	1669	20081	N/A	t	2.1591	2.2813	2.9891	1.4000
7209	1671	20081	N/A	t	2.3942	2.7500	2.5000	1.8750
7213	1675	20081	N/A	t	2.3448	2.2237	3.1875	1.9500
7217	1679	20081	N/A	t	1.8160	2.0395	2.4167	1.1750
7221	1684	20081	N/A	t	2.0294	2.0294	3.0000	2.2500
7225	1688	20081	N/A	t	2.0882	2.0882	2.0000	1.0000
7229	1692	20081	N/A	t	3.1471	3.1471	5.0000	2.5000
7377	1682	20091	N/A	t	1.7500	1.8421	2.1667	1.1750
7233	1696	20081	N/A	t	1.6765	1.6765	2.2500	1.0000
7236	1699	20081	N/A	t	2.0882	2.0882	2.7500	1.0000
7240	1703	20081	N/A	t	3.0588	3.0588	2.7500	5.0000
7244	1707	20081	N/A	t	2.2941	2.2941	3.0000	2.2500
7380	1684	20091	N/A	t	2.3233	2.1316	3.4375	2.0750
7248	1711	20081	N/A	t	2.3824	2.3824	3.0000	2.0000
7252	1656	20082	N/A	t	3.0301	3.0769	3.3083	3.0000
7255	1660	20082	N/A	t	2.0763	1.8750	2.2656	1.8679
7259	1664	20082	N/A	t	2.5381	2.8500	2.9792	2.7500
7263	1666	20082	N/A	t	2.5236	2.9500	3.0417	2.4113
7266	1670	20082	N/A	t	2.1667	2.3289	2.4762	1.7308
7270	1674	20082	N/A	t	2.7266	2.0313	3.0543	1.4167
7274	1678	20082	N/A	t	2.0978	2.1563	2.2143	2.1000
7278	1682	20082	N/A	t	1.6985	1.6029	2.2500	1.1250
7282	1686	20082	N/A	t	2.5588	2.7206	3.0000	2.8750
7285	1689	20082	N/A	t	2.0809	2.1324	2.5000	2.3750
7289	1693	20082	N/A	t	3.0735	3.3676	4.0000	2.2500
7293	1697	20082	N/A	t	2.1176	2.0882	2.6250	1.8750
7297	1701	20082	N/A	t	2.3952	1.8824	3.7500	1.7500
7301	1705	20082	N/A	t	1.9559	2.0294	2.3750	1.0000
7304	1708	20082	N/A	t	2.5294	2.5735	2.7500	2.6250
7308	1712	20082	N/A	t	2.0956	2.3676	2.6250	2.2500
7312	1657	20083	N/A	t	2.5451	2.0000	3.4643	2.7264
7316	1665	20083	N/A	t	2.4917	2.1667	2.6635	2.2568
7385	1723	20091	N/A	t	1.9375	1.9375	0.0000	3.0000
7319	1671	20083	N/A	t	2.5616	2.7500	2.7500	2.9423
7388	1689	20091	N/A	t	2.4434	3.0921	3.3333	2.0250
7320	1672	20083	N/A	t	2.7571	2.7500	3.3750	2.4423
7323	1676	20083	N/A	t	2.3000	3.7500	2.3646	1.8654
7326	1684	20083	N/A	t	2.4167	2.7500	3.5833	2.1250
7330	1692	20083	N/A	t	2.7692	2.7500	3.5000	3.2500
7334	1697	20083	N/A	t	2.4872	5.0000	3.4167	1.8750
7338	1703	20083	N/A	t	2.2297	1.6563	2.2500	3.1250
7342	1709	20083	N/A	t	1.9709	2.3611	1.8333	1.5000
7345	1712	20083	N/A	t	2.0513	1.7500	2.3333	2.2500
7350	1661	20091	N/A	t	2.5045	1.9231	3.0577	2.1827
7353	1664	20091	N/A	t	2.5085	2.5000	2.9792	2.6750
7357	1665	20091	N/A	t	2.5704	2.7500	2.6635	2.3163
7361	1717	20091	N/A	t	2.0500	2.0500	2.2500	2.0000
7365	1673	20091	N/A	t	2.4321	2.5000	2.9643	2.2344
7392	1691	20091	N/A	t	2.1226	2.1316	2.3333	2.2000
7396	1695	20091	N/A	t	1.7589	1.4412	2.0833	1.2500
7399	1698	20091	N/A	t	2.2830	2.5526	2.8333	1.8250
7403	1727	20091	N/A	t	2.1833	2.1833	3.0000	1.5000
7407	1704	20091	N/A	t	2.5647	2.5132	3.4375	2.6000
7411	1708	20091	N/A	t	2.6830	2.8971	3.1944	2.7750
7415	1711	20091	N/A	t	2.5802	2.2857	3.5833	2.5250
7418	1714	20091	N/A	t	2.6276	2.8000	3.5833	3.5833
7423	1734	20091	N/A	t	1.5294	1.5294	1.7500	1.7500
7426	1737	20091	N/A	t	2.2647	2.2647	2.0000	2.7500
7430	1741	20091	N/A	t	2.0882	2.0882	2.7500	2.5000
7434	1745	20091	N/A	t	1.3971	1.3971	1.0000	1.0000
7478	1789	20091	N/A	t	1.2647	1.2647	1.0000	1.0000
7438	1749	20091	N/A	t	1.7353	1.7353	2.0000	1.7500
7451	1762	20091	N/A	t	1.3529	1.3529	1.0000	1.2500
7442	1753	20091	N/A	t	2.2206	2.2206	2.0000	2.5000
7445	1756	20091	N/A	t	1.6471	1.6471	2.0000	1.7500
7455	1766	20091	N/A	t	2.7059	2.7059	5.0000	2.0000
7482	1793	20091	N/A	t	1.3529	1.3529	1.0000	1.5000
7485	1796	20091	N/A	t	2.0735	2.0735	2.2500	2.2500
7456	1767	20091	N/A	t	2.5588	2.5588	3.0000	3.0000
7459	1770	20091	N/A	t	2.1912	2.1912	2.5000	1.7500
7489	1800	20091	N/A	t	1.3382	1.3382	1.2500	1.0000
7463	1774	20091	N/A	t	1.4853	1.4853	1.7500	1.2500
7466	1777	20091	N/A	t	1.5147	1.5147	1.2500	1.5000
7470	1781	20091	N/A	t	1.4706	1.4706	2.0000	1.0000
7474	1785	20091	N/A	t	2.3382	2.3382	2.2500	2.2500
7493	1804	20091	N/A	t	1.3824	1.3824	1.2500	1.0000
7497	1808	20091	N/A	t	1.8971	1.8971	3.0000	2.0000
7501	1812	20091	N/A	t	2.4265	2.4265	3.0000	2.7500
7505	1816	20091	N/A	t	2.3382	2.3382	3.0000	1.7500
7508	1819	20091	N/A	t	2.3088	2.3088	2.7500	2.2500
7512	1823	20091	N/A	t	1.6176	1.6176	1.7500	1.7500
7516	1659	20092	N/A	t	3.0171	2.0357	3.3226	3.0224
7519	1663	20092	N/A	t	2.4675	2.2500	3.1667	2.7500
7523	1668	20092	N/A	t	2.3736	1.8750	2.1591	2.2250
7527	1680	20092	N/A	t	2.4286	2.4583	3.1316	2.2237
7531	1672	20092	N/A	t	2.8817	3.1538	3.7500	2.5341
7535	1676	20092	N/A	t	2.3143	1.9000	2.3646	1.9485
7538	1715	20092	N/A	t	2.6111	2.9219	3.1579	2.8462
7542	1681	20092	N/A	t	2.2857	3.4265	2.6111	2.4219
7546	1721	20092	N/A	t	2.3182	3.0417	2.7500	3.0000
7550	1687	20092	N/A	t	2.2992	2.8906	3.1250	2.2188
7554	1724	20092	N/A	t	2.4122	2.3553	2.7188	2.5833
7557	1725	20092	N/A	t	2.5000	2.3684	2.7500	2.3654
7561	1692	20092	N/A	t	2.7468	3.0375	3.5192	2.6719
7565	1827	20092	N/A	t	2.2500	2.2500	3.0000	2.5000
7569	1699	20092	N/A	t	2.6604	3.2250	3.3750	3.0781
7573	1702	20092	N/A	t	2.4533	3.1316	3.1944	2.4531
7576	1704	20092	N/A	t	2.5507	2.8947	3.3804	3.1250
7580	1708	20092	N/A	t	2.8800	3.4605	3.0595	3.0938
7584	1710	20092	N/A	t	2.2500	2.0938	1.8472	2.5000
7588	1714	20092	N/A	t	2.5692	2.3906	3.5833	3.6000
7763	1800	20093	N/A	t	1.2688	1.0000	1.2500	1.0000
7591	1732	20092	N/A	t	1.9118	1.9265	2.3750	1.8750
7767	1807	20093	N/A	t	1.7381	1.7500	2.1667	1.6250
7592	1733	20092	N/A	t	2.2353	2.2353	2.5000	2.8750
7595	1736	20092	N/A	t	2.3088	1.8676	2.3750	3.6250
7598	1739	20092	N/A	t	1.5000	1.5147	1.8750	1.2500
7602	1743	20092	N/A	t	1.9926	1.7941	2.5000	2.1250
7606	1747	20092	N/A	t	2.9044	2.7941	3.8750	2.7500
7610	1751	20092	N/A	t	1.4338	1.4265	1.5000	1.2500
7614	1755	20092	N/A	t	2.0147	2.4118	2.1250	3.7500
7617	1758	20092	N/A	t	1.9632	2.0735	2.2500	1.7500
7621	1762	20092	N/A	t	1.6029	1.8529	1.6250	1.3750
7625	1766	20092	N/A	t	2.3162	1.9265	3.7500	2.2500
7629	1770	20092	N/A	t	2.3015	2.4118	3.2500	1.8750
7633	1774	20092	N/A	t	1.8382	2.1912	2.1250	1.5000
7637	1778	20092	N/A	t	1.5147	1.7647	2.0000	1.0000
7771	1812	20093	N/A	t	2.1857	1.3750	3.0000	2.8750
7641	1782	20092	N/A	t	2.4338	2.8824	4.0000	1.8750
7644	1785	20092	N/A	t	2.2794	2.2206	2.5000	2.6250
7648	1789	20092	N/A	t	1.4338	1.6029	1.1250	1.0000
7652	1793	20092	N/A	t	1.3971	1.4412	1.3750	1.3750
7655	1796	20092	N/A	t	1.9191	1.7647	2.2500	2.1250
7660	1801	20092	N/A	t	2.3456	2.6176	4.0000	2.0000
7663	1804	20092	N/A	t	1.3824	1.3824	1.2500	1.0000
7667	1808	20092	N/A	t	2.1397	2.3824	3.0000	1.7500
7671	1812	20092	N/A	t	2.3534	2.2500	3.0000	2.8750
7674	1815	20092	N/A	t	2.1618	1.6618	3.7500	1.2500
7678	1819	20092	N/A	t	2.7941	3.2794	3.8750	3.6250
7682	1823	20092	N/A	t	1.8897	2.1618	2.3750	1.7500
7686	1659	20093	N/A	t	2.9985	2.0000	3.3226	3.0224
7690	1716	20093	N/A	t	1.9194	1.7500	0.0000	2.0568
7693	1666	20093	N/A	t	2.5803	1.5000	3.0417	2.2972
7697	1673	20093	N/A	t	2.3844	1.7500	2.9643	2.2700
7701	1719	20093	N/A	t	2.7561	2.7500	3.5833	2.8750
7705	1686	20093	N/A	t	2.9219	2.7222	3.1000	3.2188
7709	1689	20093	N/A	t	2.6133	2.2500	2.9891	2.2500
7713	1693	20093	N/A	t	2.7110	1.5000	3.7500	2.6538
7716	1697	20093	N/A	t	2.3885	1.5000	3.2500	2.7237
7720	1704	20093	N/A	t	2.5000	1.8750	3.3804	2.9474
7724	1709	20093	N/A	t	2.5353	5.0000	2.3810	3.0000
7729	1736	20093	N/A	t	2.2692	2.0000	2.2500	3.6250
7732	1747	20093	N/A	t	2.8526	2.5000	3.4167	2.7500
7775	1816	20093	N/A	t	2.2564	3.0000	2.9167	1.5000
7737	1754	20093	N/A	t	1.6000	1.5000	1.3750	1.5000
7740	1759	20093	N/A	t	2.1154	2.5000	2.5000	2.2500
7744	1766	20093	N/A	t	2.6603	5.0000	4.1667	2.2500
7748	1771	20093	N/A	t	1.6284	1.2500	1.2885	1.7500
7751	1782	20093	N/A	t	2.4744	2.7500	3.5833	1.8750
7778	1821	20093	N/A	t	2.2115	1.5000	3.0000	2.0000
7756	1791	20093	N/A	t	1.9250	1.2500	2.3750	2.1250
7759	1796	20093	N/A	t	1.9295	2.0000	2.1667	2.1250
7782	1656	20101	N/A	t	3.1624	3.8500	3.5069	3.3520
7786	1662	20101	N/A	t	2.3429	2.1250	2.9231	2.4279
7790	1668	20101	N/A	t	2.3905	2.7656	2.1591	2.3347
7794	1680	20101	N/A	t	2.3750	2.1667	3.1316	2.2581
7797	1671	20101	N/A	t	2.5289	2.1250	2.7500	2.4628
7801	1675	20101	N/A	t	2.6088	2.9500	3.1442	2.3919
7805	1715	20101	N/A	t	2.7397	3.4531	3.1579	2.6875
7809	1681	20101	N/A	t	2.3077	2.4000	2.6111	2.3553
7813	1683	20101	N/A	t	2.5057	2.8750	2.8571	2.6705
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

