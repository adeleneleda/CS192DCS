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







BEGIN



SELECT COALESCE(SUM(gradevalue * credits) / SUM(credits), 0) into x



FROM viewclasses



WHERE studentid = $1 AND coursename like 'CS%' AND gradeid <= 11;





RETURN round(x,4);



END$_$;


ALTER FUNCTION public.csgwa(p_studentid integer) OWNER TO postgres;

--
-- Name: cwaproto4(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cwaproto4(p_studentid integer) RETURNS numeric
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







	CREATE TEMPORARY TABLE first5ahPass AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 5;



	CREATE TEMPORARY TABLE ahFails AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v

		WHERE v.studentid = $1 AND v.domain = 'AH' AND (v.gradeid = 11 OR v.gradeid = 10);



	CREATE TEMPORARY TABLE first4mstPass AS

		SELECT v.gradevalue as x, v.credits as y, v.coursename

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 4;



	CREATE TEMPORARY TABLE mstFails AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v

		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND (v.gradeid = 11 OR v.gradeid = 10);



	CREATE TEMPORARY TABLE first5sspPass AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 5;



	CREATE TEMPORARY TABLE sspFails AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v

		WHERE v.studentid = $1 AND v.domain = 'SSP' AND (v.gradeid = 11 OR v.gradeid = 10);



	CREATE TEMPORARY TABLE majors AS 

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid <= 11;



	CREATE TEMPORARY TABLE first3elePass AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v

		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 3;



	CREATE TEMPORARY TABLE eleFails AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v

		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND (v.gradeid = 11 OR v.gradeid = 10);

		



	IF (SELECT COUNT(*) FROM first5ahPass) <> 0 THEN

		SELECT SUM(x * y) into ah FROM first5ahPass;

		SELECT SUM(y) into ahd FROM first5ahPass;

	END IF;



	IF (SELECT COUNT(*) FROM ahFails) <> 0 THEN

		SELECT SUM(x * y) into ahf FROM ahFails;

		SELECT SUM(y) into ahdf FROM ahFails;

	END IF;



	IF (SELECT COUNT(*) FROM first4mstPass) <> 0 THEN

		SELECT SUM(x * y) into mst FROM first4mstPass;

		SELECT SUM(y) into mstd FROM first4mstPass;



		IF (SELECT COUNT(*) FROM first4mstPass WHERE coursename IN ('nat sci 1', 'chem 1', 'physics 10')) > 2 THEN 

			SELECT ns1_correction($1) into mst; 

			SELECT ns1_dcorrection($1) into mstd;

		END IF;

		

		IF (SELECT COUNT(*) FROM first4mstPass WHERE coursename IN ('nat sci 2', 'bio 1', 'geol 1')) > 2 THEN 

			SELECT ns2_correction($1) into mst; 

			SELECT ns2_dcorrection($1) into mstd;

		END IF;

		

	END IF;



	IF (SELECT COUNT(*) FROM mstFails) <> 0 THEN

		SELECT SUM(x * y) into mstf FROM mstFails;

		SELECT SUM(y) into mstdf FROM mstFails;

	END IF;



	IF (SELECT COUNT(*) FROM first5sspPass) <> 0 THEN

		SELECT SUM(x * y) into ssp FROM first5sspPass;

		SELECT SUM(y) into sspd FROM first5sspPass;

	END IF;

	

	IF (SELECT COUNT(*) FROM sspFails) <> 0 THEN

		SELECT SUM(x * y) into sspf FROM sspFails;

		SELECT SUM(y) into sspdf FROM sspFails;

	END IF;



	IF (SELECT COUNT(*) FROM majors) <> 0 THEN

		SELECT SUM(x * y) into maj FROM majors;

		SELECT SUM(y) into majd FROM majors;

	END IF;



	IF (SELECT COUNT(*) FROM first3elePass) <> 0 THEN

		SELECT SUM(x * y) into ele FROM first3elePass;

		SELECT SUM(y) into eled FROM first3elePass;



		IF (SELECT COUNT(*) FROM first3elePass WHERE v.domain = 'C197') > 2 THEN

			SELECT overcs197_correction($1) INTO ele;

			SELECT overcs197_dcorrection($1) INTO eled;

		END IF;



		IF (SELECT COUNT(*) FROM first3ele WHERE v.domain = 'MSEE') > 2 THEN

			SELECT overMSEE_correction($1) INTO ele;

			SELECT overMSEE_dcorrection($1) INTO eled;

		END if;



		IF (SELECT COUNT(*) FROM first3ele WHERE v.domain = 'FE') > 2 THEN

			SELECT overFE_correction($1) INTO ele;

			SELECT overFE_dcorrection($1) INTO eled; 

		END IF;

	END IF;



	IF (SELECT COUNT(*) FROM eleFails) <> 0 THEN

		SELECT SUM(x * y) into elef FROM eleFails;

		SELECT SUM(y) into eledf FROM eleFails;

	END IF;


	DROP TABLE first5ahPass;

	DROP TABLE ahFails;

	DROP TABLE first4mstPass;

	DROP TABLE mstFails;

	DROP TABLE first5sspPass;

	DROP TABLE sspFails;

	DROP TABLE majors;

	DROP TABLE first3elePass;

	DROP TABLE eleFails;


	numer = (ah + ahf + mst + mstf + ssp + sspf + maj + ele);
	denom = (ahd + ahdf + mstd + mstdf + sspd + sspdf + majd + eled);
	IF denom = 0 THEN RETURN 0; END IF;
	cwa = numer / denom;

	RETURN round(cwa,4);	



END;$_$;


ALTER FUNCTION public.cwaproto4(p_studentid integer) OWNER TO postgres;

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







BEGIN



SELECT COALESCE(SUM(gradevalue * credits) / SUM(credits),0) into x



FROM viewclasses



WHERE studentid = $1 AND coursename like 'Math%' AND (coursename <> 'Math 1' AND coursename <> 'Math 2') AND gradeid <= 11;



RETURN round(x,4);



END$_$;


ALTER FUNCTION public.mathgwa(p_studentid integer) OWNER TO postgres;

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
		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--first 5 ah denom
	SELECT COALESCE(SUM(y),0) into ahd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--ah fail numer
	SELECT COALESCE(SUM(x*y), 0) into ahf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'AH' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

	--ah fail denom
	SELECT COALESCE(SUM(y), 0) into ahdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'AH' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

	--first 4 mst numer
	SELECT COALESCE(SUM(x*y), 0) into mst FROM
	(SELECT v.gradevalue as x, v.credits as y, v.coursename
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 4) as sss;

	--first 4 mst denom
	SELECT COALESCE(SUM(y), 0) into mstd FROM
	(SELECT v.gradevalue as x, v.credits as y, v.coursename
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 4) as sss;

	--ns1 and ns2 corrections
	IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename
								FROM viewclasses v 
								WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2
								ORDER BY v.termid ASC
								LIMIT 4) as sss WHERE coursename IN ('Nat Sci 1', 'Chem 1', 'Physics 10')) > 2 THEN
		SELECT xns1_correction($1, $2) into mst;
		SELECT xns1_dcorrection($1, $2) into mstd;
	ELSE 
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename
								FROM viewclasses v 
								WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2
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
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

	--mst fails denom
	SELECT COALESCE(SUM(y), 0) into mstdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

	--first 5 ssp numer
	SELECT COALESCE(SUM(x*y), 0) into ssp FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--first 5 ssp denom
	SELECT COALESCE(SUM(y), 0) into sspd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 5) as sss;

	--ssp fails numer
	SELECT COALESCE(SUM(x*y), 0) into sspf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

	--ssp fails denom
	SELECT COALESCE(SUM(y), 0) into sspdf FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND v.domain = 'SSP' AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

	--maj pass+fail numer
	SELECT COALESCE(SUM(x*y), 0) into maj FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid <= 11 AND v.termid < $2) as sss;

	--maj pass+fail denom
	SELECT COALESCE(SUM(y), 0) into majd FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v 
		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid <= 11 AND v.termid < $2) as sss;

	--first 3 ele numer
	SELECT COALESCE(SUM(x*y), 0) into ele FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 3) as sss;
	
	--first 3 ele denom
	SELECT COALESCE(SUM(y), 0) into eled FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2
		ORDER BY v.termid ASC
		LIMIT 3) as sss;

	--overflowing electives correction
	IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
								FROM viewclasses v
								WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2
								ORDER BY v.termid ASC
								LIMIT 3) as sss WHERE sss.domain = 'C197') > 2 THEN
		SELECT xovercs197_correction($1, $2) INTO ele;
		SELECT xovercs197_dcorrection($1, $2) INTO eled;
	ELSE
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
									FROM viewclasses v
									WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2
									ORDER BY v.termid ASC
									LIMIT 3) as sss WHERE sss.domain = 'MSEE') > 2 THEN
			SELECT xoverMSEE_correction($1, $2) INTO ele;
			SELECT xoverMSEE_dcorrection($1, $2) INTO eled;
		ELSE
		IF (SELECT COUNT(*) FROM (SELECT v.gradevalue as x, v.credits as y, v.domain
									FROM viewclasses v
									WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2
									ORDER BY v.termid ASC
									LIMIT 3) as sss WHERE sss.domain = 'FE') > 2 THEN
			SELECT xoverFE_correction($1, $2) INTO ele;
			SELECT xoverFE_dcorrection($1, $2) INTO eled;
		END IF;
		END IF;
	END IF;

	--ele fails numer
	SELECT COALESCE(SUM(x*y),0) into elef FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

	--ele fails denom
	SELECT COALESCE(SUM(y),0) into elef FROM
	(SELECT v.gradevalue as x, v.credits as y
		FROM viewclasses v
		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND (v.gradeid = 11 OR v.gradeid = 10) AND v.termid < $2) as sss;

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







-- 	CREATE TEMPORARY TABLE allmstPass AS



-- 		SELECT v.gradevalue as x, v.credits as y, v.coursename



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(x * y) into ns1group_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherMST_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;







-- 	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')) != 0 THEN



-- 		SELECT SUM(x * y) into otherMST_credits



-- 		FROM allmstPass



-- 		WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



-- 		LIMIT 2;



-- 	END IF;



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







-- 	CREATE TEMPORARY TABLE allmstPass AS



-- 		SELECT v.gradevalue as x, v.credits as y, v.coursename



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(y) into ns1group_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;

	



	SELECT COALESCE(SUM(y),0) into otherMST_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



	LIMIT 2;







-- 	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')) != 0 THEN



-- 		SELECT SUM(y) into otherMST_units



-- 		FROM allmstPass



-- 		WHERE coursename NOT IN ('Nat Sci 1', 'Chem 1', 'Physics 10')



-- 		LIMIT 2;



-- 	END IF;







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







-- 	CREATE TEMPORARY TABLE allmstPass AS



-- 		SELECT v.gradevalue as x, v.credits as y, v.coursename



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(x * y) into ns2group_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherMST_credits



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;







-- 	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')) != 0 THEN



-- 		SELECT SUM(x * y) into otherMST_credits



-- 		FROM allmstPass



-- 		WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



-- 		LIMIT 2;



-- 	END IF;







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







-- 	CREATE TEMPORARY TABLE allmstPass AS



-- 		SELECT v.gradevalue as x, v.credits as y, v.coursename



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(y) into ns2group_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss 



	WHERE coursename IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;

	



	SELECT COALESCE(SUM(y),0) into otherMST_units



	FROM (SELECT v.gradevalue as x, v.credits as y, v.coursename



		FROM viewclasses v 



		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'Math 2' AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



	LIMIT 2;







-- 	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')) != 0 THEN



-- 		SELECT SUM(y) into otherMST_units



-- 		FROM allmstPass



-- 		WHERE coursename NOT IN ('Nat Sci 2', 'Bio 1', 'Geol 1')



-- 		LIMIT 2;



-- 	END IF;







	return ns2group_units + otherMST_units;







END;$_$;


ALTER FUNCTION public.xns2_dcorrection(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xoverFE_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "xoverFE_correction"(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



FEgroup_credits numeric DEFAULT 0;



otherELE_credits numeric DEFAULT 0;







BEGIN



-- 	CREATE TEMPORARY TABLE allelePass AS 



-- 	SELECT v.gradevalue as x, v.credits as y



-- 	FROM viewclasses v 



-- 	WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10



-- 	ORDER BY v.termid ASC;







	SELECT SUM(x * y) into FEgroup_credits



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain = 'FE'



	LIMIT 1;





	SELECT COALESCE(SUM(x * y),0) into otherELE_credits



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain <> 'FE'



	LIMIT 2;







-- 	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN



-- 		SELECT SUM(x * y) into otherELE_credits



-- 		FROM allelePass



-- 		WHERE v.domain <> 'FE'



-- 		LIMIT 2;



-- 	END IF;







	return FEgroup_credits + otherELE_credits;



END$_$;


ALTER FUNCTION public."xoverFE_correction"(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xoverFE_dcorrection(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "xoverFE_dcorrection"(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



FEgroup_units numeric DEFAULT 0;



otherELE_units numeric DEFAULT 0;







BEGIN



-- 	CREATE TEMPORARY TABLE allelePass AS 

-- 

-- 		SELECT v.gradevalue as x, v.credits as y

-- 

-- 		FROM viewclasses v 

-- 

-- 		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

-- 

-- 		ORDER BY v.termid ASC;







	SELECT SUM(y) into FEgroup_units



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain = 'FE'



	LIMIT 1;





	SELECT COALESCE(SUM(y),0) into otherELE_units



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain <> 'FE'



	LIMIT 2;







-- 	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN



-- 		SELECT SUM(y) into otherELE_units



-- 		FROM allelePass



-- 		WHERE v.domain <> 'FE'



-- 		LIMIT 2;



-- 	END IF;







	return FEgroup_units + otherELE_units;



END$_$;


ALTER FUNCTION public."xoverFE_dcorrection"(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xoverMSEE_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "xoverMSEE_correction"(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



MSEEgroup_credits numeric DEFAULT 0;



otherELE_credits numeric DEFAULT 0;







BEGIN



-- 	CREATE TEMPORARY TABLE allelePass AS 



-- 		SELECT v.gradevalue as x, v.credits as y



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(x * y) into MSEEgroup_credits



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain = 'MSEE'



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherELE_credits



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain <> 'MSEE'



	LIMIT 1;







-- 	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN



-- 		SELECT SUM(x * y) into otherELE_credits



-- 		FROM allelePass



-- 		WHERE v.domain <> 'MSEE'



-- 		LIMIT 1;



-- 	END IF;







	return MSEEgroup_credits + otherELE_credits;



END$_$;


ALTER FUNCTION public."xoverMSEE_correction"(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xoverMSEE_dcorrection(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "xoverMSEE_dcorrection"(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



MSEEgroup_units numeric DEFAULT 0;



otherELE_units numeric DEFAULT 0;







BEGIN



-- 	CREATE TEMPORARY TABLE allelePass AS 



-- 		SELECT v.gradevalue as x, v.credits as y



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(y) into MSEEgroup_units



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain = 'MSEE'



	LIMIT 2;





	SELECT COALESCE(SUM(y),0) into otherELE_units



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain <> 'MSEE'



	LIMIT 1;







-- 	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN



-- 		SELECT SUM(y) into otherELE_units



-- 		FROM allelePass



-- 		WHERE v.domain <> 'MSEE'



-- 		LIMIT 1;



-- 	END IF;







	return MSEEgroup_units + otherELE_units;



END$_$;


ALTER FUNCTION public."xoverMSEE_dcorrection"(p_studentid integer, p_termid integer) OWNER TO postgres;

--
-- Name: xovercs197_correction(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xovercs197_correction(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE



CSEgroup_credits numeric DEFAULT 0;



otherELE_credits numeric DEFAULT 0;







BEGIN



-- 	CREATE TEMPORARY TABLE allelePass AS 



-- 		SELECT v.gradevalue as x, v.credits as y



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(x * y) into CSEgroup_credits



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain = 'C197'



	LIMIT 2;





	SELECT COALESCE(SUM(x * y),0) into otherELE_credits



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain <> 'C197'



	LIMIT 1;







-- 	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN



-- 		SELECT SUM(x * y) into otherELE_credits



-- 		FROM allelePass



-- 		WHERE v.domain <> 'C197'



-- 		LIMIT 1;



-- 	END IF;







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



-- 	CREATE TEMPORARY TABLE allelePass AS 



-- 		SELECT v.gradevalue as x, v.credits as y



-- 		FROM viewclasses v 



-- 		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10



-- 		ORDER BY v.termid ASC;







	SELECT SUM(y) into CSEgroup_units



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain = 'C197'



	LIMIT 2;





	SELECT COALESCE(SUM(y),0) into otherELE_units



	FROM (SELECT v.gradevalue as x, v.credits as y



		FROM viewclasses v 



		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10 AND v.termid < $2



		ORDER BY v.termid ASC) as sss



	WHERE v.domain <> 'C197'



	LIMIT 1;







-- 	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN



-- 		SELECT SUM(y) into otherELE_units



-- 		FROM allelePass



-- 		WHERE v.domain <> 'C197'



-- 		LIMIT 1;



-- 	END IF;







	return CSEgroup_units + otherELE_units;



END$_$;


ALTER FUNCTION public.xovercs197_dcorrection(p_studentid integer, p_termid integer) OWNER TO postgres;

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

SELECT pg_catalog.setval('classes_classid_seq', 2325, true);


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

SELECT pg_catalog.setval('persons_personid_seq', 954, true);


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

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 17957, true);


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

SELECT pg_catalog.setval('students_studentid_seq', 944, true);


--
-- Name: studentterms; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE studentterms (
    studenttermid integer NOT NULL,
    studentid integer,
    termid integer,
    ineligibilities character varying,
    issettled boolean
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

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 3978, true);


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
1	20101	1	FWXY	12340
2	20101	91	THUV	12341
3	20101	41	THW	12342
4	20101	83	WFWX	12343
5	20101	104	THZ	12344
6	20101	1	THW	12345
7	20101	96	WFWX	12346
8	20101	42	WFY	12347
9	20101	76	THUV	12348
10	20101	104	WFWU	12349
11	20102	2	FWXY	12340
12	20102	39	THUV	12341
13	20102	105	THW	12342
14	20102	92	WFWX	12343
15	20102	84	THZ	12344
16	20102	2	THW	12345
17	20102	43	WFWX	12346
18	20102	105	WFY	12347
19	20102	93	THUV	12348
20	20102	94	WFWU	12349
21	20103	106	TWTHFU	12350
22	20111	5	FWXY	12351
23	20111	3	THUV	12352
24	20111	4	THW	12353
25	20111	36	WFWX	12354
26	20111	48	THZ	12355
27	20111	107	WFW	12356
28	20111	5	THW	12357
29	20111	3	WFWX	12358
30	20111	4	WFY	12359
31	20111	37	THUV	12360
32	20111	45	WFWU	12361
33	20111	106	THU	12362
34	20112	8	FWXY	12363
35	20112	6	THUV	12364
36	20112	7	THW	12365
38	20112	98	THZ	12367
39	20112	108	THY	12368
40	20112	107	WFWX	12369
41	20112	8	WFY	12370
42	20112	6	THUV	12371
43	20112	7	WFWU	12372
44	20112	108	THU	12373
45	20112	48	WUV	12374
46	20121	109	FWXY	12375
47	20121	80	THUV	12376
48	20121	16	THW	12377
49	20121	10	WFWX	12378
50	20121	9	THZ	12379
51	20121	110	THY	12380
52	20121	109	WFWX	12381
53	20121	110	WFY	12382
54	20121	9	THUV	12383
55	20121	10	WFWU	12384
56	20121	16	THU	12385
57	20121	85	WUV	12386
58	20111	1	THUV	54532
59	20111	104	TWHFR	39068
60	20111	91	WFW	46290
61	20111	76	THX1	40624
62	20111	41	WFU1	14310
68	20121	3	WFUV	54558
69	20121	106	TWHFX-1	39268
70	20121	5	THR	54564
71	20121	4	THX	54562
72	20121	96	WFW-2	18920
73	20121	1	THUV	54564
74	20121	104	TWHFX1	39343
75	20121	84	WFX2	46489
76	20121	44	THW	41927
77	20121	42	WFW1	14572
37	20111	1	WFWX	12366
63	20112	2	WFQR	54582
64	20112	105	THVWFU8	39192
65	20112	80	WFX	46325
66	20112	92	THW	41824
67	20112	37	THU-2	15230
78	20111	104	THU	11123
79	20111	91	THU	11124
80	20111	1	THU	11125
81	20112	105	THU	11123
82	20112	98	THU	11124
83	20112	2	THU	11125
84	20121	105	THU	11123
85	20121	76	THU	11124
86	20121	3	THU	11125
87	20101	104	THU	11125
88	20101	1	THU	11125
89	20102	105	THU	11125
90	20102	2	THU	11125
91	20111	106	THU	11125
92	20111	3	THU	11125
93	20121	106	THU	11125
94	20121	3	THU	11125
95	19991	96	TFQ1	418
96	19991	111	WBC	919
97	19991	112	11	3557
98	19991	92	MHQ3	3983
99	19991	81	MHW	6800
100	19991	55	TFR2	9661
101	19991	104	MTHFX6	9764
102	20001	33	TFR3	12225
103	20001	106	MTHFW3	35242
104	20001	108	MTHFI	37302
105	20001	100	MHR-S	41562
106	20001	2	HMXY	44901
107	20002	107	MHW2	35238
108	20002	113	TFQ	35271
109	20002	109	MTHFD	37331
110	20002	3	TFXY	44911
111	20002	5	MHX1	44913
112	20003	113	X3-2	35181
113	20003	93	X1-1	38511
114	20011	34	TFW-3	11676
115	20011	114	MHX	35252
116	20011	101	TFY2	40385
117	20011	6	TFR	44922
118	20011	5	W1	44944
119	20012	115	MHX3	13972
120	20012	101	MHU1	40344
121	20012	11	MHY	44919
122	20012	19	TFR	44921
123	20012	24	TFY	44939
124	20012	116	TFZ	45440
125	20013	39	X6-D	14922
126	20013	11	X3	44906
127	20021	8	TFY	44920
128	20021	6	TFW	44922
129	20021	7	MHXY	44925
130	20021	117	TFV	44931
131	20021	116	MHW	45405
132	20021	41	TFX2	12350
133	20021	104	MTHFU1	35138
134	20021	96	TFY1	39648
135	20021	81	MHY	41805
136	20021	1	MHVW	44901
137	20021	41	TFV6	12389
138	20021	104	MTHFW4	35161
139	20021	92	MHV1	38510
140	20021	81	TFR	41807
141	20021	1	MHXY	44902
142	20022	19	TFX	44918
143	20022	9	TFV	44925
144	20022	27	TFW	44927
145	20022	70	TFR2	33729
146	20022	105	MTHFV1	35165
147	20022	93	MHX	38533
148	20022	98	MHW2	39648
149	20022	2	MHRU	44900
150	20022	71	MHR	34200
151	20022	105	MTHFW3	35173
152	20022	98	MHV	39646
153	20022	82	TFU	41814
154	20022	2	MHXY	44901
155	20031	118	MHW2	16602
156	20121	1	WFV	86236
157	20031	17	MHX	54566
158	20031	20	WSVX2	54582
159	20031	14	TFVW	54603
160	20031	119	MHY	54604
161	20031	120	MHW	14482
162	20031	63	MHV	15620
163	20031	107	TFU2	39320
164	20031	108	MTHFX	41352
165	20031	91	MHU1	46314
166	20031	2	TFVW	54555
167	20031	34	TFV-2	13921
168	20031	106	MTHFW1	39247
169	20031	108	MTHFD	41419
170	20031	91	TFY2	46310
171	20031	3	MHXY	54560
172	20031	43	MHW2	14467
173	20031	104	MTHFX8	39221
174	20031	82	TFR	41908
175	20031	1	MHRU	54550
176	20031	87	(1)	62806
177	20031	41	TFQ2	14425
178	20031	104	MTHFW6	39211
179	20031	82	MHQ	41905
180	20031	101	MHX2	44662
181	20031	1	TFRU	54553
182	20032	20	WSVX2	54595
183	20032	42	TFW1	14435
184	20032	73	MTHW	38073
185	20032	114	MHX	39321
186	20032	92	TFX2	45813
187	20032	3	FTRU	54560
188	20032	5	MHU	54561
189	20032	107	TFV1	39278
190	20032	114	MHW	39320
191	20032	109	MTHFV	41488
192	20032	93	TFX1	45839
193	20032	5	MHX	54562
194	20032	42	TFU2	14432
195	20032	105	MTHFR3	39215
196	20032	81	MHW	41902
197	20032	100	MHU	45213
198	20032	2	TFVW	54558
199	20032	105	MTHFW2	39236
200	20032	96	WSR2	42601
201	20032	100	TFQ	45220
202	20032	92	TFR3	45801
203	20032	1	MHRU	54552
204	20033	108	Y3	41355
205	20033	109	Y3	41362
206	20033	43	X3A	14411
207	20033	96	X1-1	42451
208	20033	106	Z1-2	39183
209	20041	62	MHX1	15613
210	20041	114	TFW	39305
211	20041	7	HMRU	54555
212	20041	8	TFR	54569
213	20041	6	TFU	54572
214	20041	110	MHV	70025
215	20041	36	TFR-1	13856
216	20041	35	WIJK	15505
217	20041	107	MHW2	39395
218	20041	116	TFW	52451
219	20041	5	MHU	54563
220	20041	31	MHR1	15507
221	20041	106	MTHFW2	39255
222	20041	108	MTHFX	41354
223	20041	92	MHU5	45761
224	20041	3	TFRU	54561
225	20041	41	MHX3	14423
226	20041	106	MTHFQ2	39369
227	20041	108	MTHFD	41350
228	20041	81	MHW	41902
229	20041	2	TFVW	54557
230	20041	41	TFQ1	14428
231	20041	104	MTHFW2	39208
232	20041	76	MHX	40826
233	20041	96	TFX2	42471
234	20041	1	MHRU	54550
235	20042	115	MHX1	15672
236	20042	121	TFY	47972
237	20042	19	MHR	54564
238	20042	12	TFRU	54573
239	20042	24	MHU	54597
240	20042	11	TFV	54598
241	20042	42	MHW1	14429
242	20042	55	TFU1	15568
243	20042	115	MHV3	15668
244	20042	41	MHR	14401
245	20042	73	MTHU-2	38052
246	20042	107	TFU2	39271
247	20042	114	TFR	39311
248	20042	108	MTHFI	41352
249	20042	5	MHX	54561
250	20042	43	MHV2	14460
251	20042	114	TFQ	39178
252	20042	107	TFR	39268
253	20042	109	MTHFD	41379
254	20042	42	MHU1	14421
255	20042	105	MTHFQ2	39209
256	20042	93	MHR1	45780
257	20042	91	TFR3	46324
258	20042	2	MHXY	54557
259	20043	39	X3-A	16057
260	20043	109	Y4	41354
261	20043	84	X4	41905
262	20043	101	X-5-2	44660
263	20043	109	Y1	41353
264	20043	107	X1-1	39196
265	20043	106	Z1-4	39187
266	20051	116	MHR	52454
267	20051	17	MHX	54567
268	20051	8	TFY	54570
269	20051	119	MHU	54577
270	20051	20	WSVX2	54581
271	20051	27	WRU	54588
272	20051	21	FR	54592
273	20051	116	TFU	52455
274	20051	17	MHU	54566
275	20051	6	TFW	54573
276	20051	7	HMXY	54575
277	20051	110	MHR	69953
278	20051	115	TFU2	15702
279	20051	48	MTU	19924
280	20051	114	TFR	39309
281	20051	109	MTHFI	41439
282	20051	92	MHX3	45771
283	20051	5	TFX	54562
284	20051	62	TFR1	15564
285	20051	114	TFQ	39308
286	20051	91	TFV1	46329
287	20051	3	MHXY	54559
288	20051	71	TFX	38890
289	20051	106	MTHFU1	39242
290	20051	108	MTHFI	41412
291	20051	29	WSR	54589
292	20051	41	TFV2	14437
293	20051	70	MHV	37502
294	20051	104	MTHFW4	39212
295	20051	92	TFQ2	45773
296	20051	1	MHXY	54551
297	20051	41	MHU3	14410
298	20051	71	MHQ	38678
299	20051	105	MTHFR	39228
300	20051	96	TFQ3	42463
301	20051	1	TFVW	54553
302	20052	76	MHX	40806
303	20052	122	MHL	52457
304	20052	122	MHLM	52459
305	20052	14	TFRU	54570
306	20052	9	TFW	54573
307	20052	27	WRU	54575
308	20052	22	WSVX2	54584
309	20052	42	MHY	14425
310	20052	14	HMVW	54568
311	20052	119	MHU	54571
312	20052	28	TFV	54576
313	20052	12	TFXY	54579
314	20052	21	TR	54580
315	20052	123	MHTFX	15078
316	20052	124	MHTFX	15079
317	20052	60	BMR1	33107
318	20052	109	MTHFD	41375
319	20052	101	MHV2	44695
320	20052	89	MI1	67273
321	20052	61	MHX1	15613
322	20052	107	MHV	39215
323	20052	114	TFV	39279
324	20052	109	MTHFR	41467
325	20052	92	MHU2	45759
326	20052	5	TFU	54561
327	20052	39	MHR-1	16052
328	20052	105	MTHFV4	39184
329	20052	81	TFR	41903
330	20052	93	TFU1	45811
331	20052	2	MHXY	54554
332	20052	106	MTHFX3	39209
333	20052	108	MTHFV	41353
334	20052	100	MHQ	44152
335	20052	2	TFRU	54555
336	20053	86	MTWHFAB	47950
337	20053	18	X2	54550
338	20053	107	X3-2	39181
339	20053	105	Z3-2	39170
340	20053	70	X3	37501
341	20053	107	X2	39179
342	20061	116	WIJF	52455
343	20061	116	WIJT1	52456
344	20061	19	TFX	54565
345	20061	20	MHXYM2	54582
346	20061	115	TFZ1	15681
347	20061	107	MHV	39271
348	20061	116	WIJT2	52457
349	20061	6	HMRU	54569
350	20061	7	TFRU	54574
351	20061	8	GS2	54603
352	20061	37	TFX-2	13886
353	20061	106	MTHFW1	39186
354	20061	108	MTHFV	41356
355	20061	91	TFR2	46327
356	20061	3	MHRU	54557
357	20061	39	MHX2	16069
358	20061	109	MTHFV	41382
359	20061	3	TFXY	54560
360	20061	5	TFU	54561
361	20061	29	WSR	54597
362	20061	41	TFV2	14520
363	20061	70	MHU	37501
364	20061	104	MTHFW1	39189
365	20061	97	TFR	42466
366	20061	1	MHXY	54551
367	20061	39	MHR3	16054
368	20061	104	MTHFQ1	39150
369	20061	83	MHW	41434
370	20061	102	TFU	47970
371	20061	1	TFVW	54553
372	20061	43	MHV2	14551
373	20061	104	MTHFX1	39197
374	20061	76	TFU	40807
375	20061	103	MHQ	43553
376	20061	80	TFW	40252
377	20061	98	MHY2	42478
378	20061	1	WSRU	54599
379	20061	41	MHR2	14493
380	20061	104	MTHFY5	39299
381	20061	92	TFW2	45853
382	20061	91	MHV6	46380
383	20061	41	TFU3	14518
384	20061	104	MTHFX4	39200
385	20061	82	MHY	41911
386	20061	92	TFR3	45763
387	20061	1	SWRU	54600
388	20062	122	MHK	52449
389	20062	122	MHKH	52450
390	20062	22	W1	54595
391	20062	36	MHQ-2	13851
392	20062	42	TFU1	14589
393	20062	114	TFQ	39314
394	20062	3	MHXY	54559
395	20062	24	MHW	54571
396	20062	98	TFU1	42493
397	20062	122	MHKM	52451
398	20062	11	MHY	54565
399	20062	14	TFVW	54567
400	20062	9	FTXY	54570
401	20062	12	MHVW	54573
402	20062	63	TFX1	15613
403	20062	106	MTHFR3	39259
404	20062	109	MTHFY	41440
405	20062	96	MHV2	42456
406	20062	5	TFU	54562
407	20062	114	TFR	39315
408	20062	81	MHR	41900
409	20062	98	MHW1	42487
410	20062	91	TFX2	46335
411	20062	7	WRUVX	54602
412	20062	39	MHR1	16054
413	20062	105	MTHFU5	39212
414	20062	92	TFV2	45786
415	20062	91	MHV5	46316
416	20062	2	TFXY	54558
417	20062	40	TFX1	14591
418	20062	62	MHU2	15598
419	20062	104	MTHFW-1	39184
420	20062	98	MHX	42489
421	20062	2	TFRU	54557
422	20062	36	MHV-2	13859
423	20062	40	TFV1	14476
424	20062	47	Z	19918
425	20062	105	MTHFW1	39201
426	20062	2	MHRU	54552
427	20062	41	TFX	14415
428	20062	105	MTHFV6	39225
429	20062	96	TFQ1	42460
430	20062	91	TFR	46328
431	20062	42	MHR	14417
432	20062	104	MTHFQ-1	39197
433	20062	98	MHW2	42488
434	20062	93	TFV2	45812
435	20062	105	MTHFQ6	39395
436	20062	96	TFX1	42466
437	20062	103	TFW	43616
438	20063	18	X2	54550
439	20063	109	Y3	41353
440	20063	115	X1B	15527
441	20063	105	Z1-A	39176
442	20063	108	Y2	41350
443	20063	108	Y3	41351
444	20063	105	Z2-C	39175
445	20063	36	X2-A	13855
446	20063	125	X1A	15540
447	20071	116	TFL	52463
448	20071	116	TFLH	52464
449	20071	8	TFX3	54561
450	20071	6	TFRU	54562
451	20071	19	TFV1	54567
452	20071	7	MWVWXY	54583
453	20071	27	WRU2	54585
454	20071	21	MH	54594
455	20071	55	MHU1	15574
456	20071	17	TFU	54566
457	20071	16	MHV1	54569
458	20071	20	W2	54571
459	20071	27	WRU1	54579
460	20071	21	MQ	54593
461	20071	110	TFW	70005
462	20071	114	TFW	39298
463	20071	107	MHQ	39388
464	20071	6	TMRU	54563
465	20071	8	TFX2	54560
466	20071	17	MHU	54565
467	20071	19	TFV2	54568
468	20071	50	MHV1	15526
469	20071	105	MTHFW2	39228
470	20071	108	MTHFX	41361
471	20071	3	TFRU	54576
472	20071	106	MTHFU2	39237
473	20071	108	MTHFQ1	41359
474	20071	91	MHY2	46327
475	20071	100	TFY	47991
476	20071	3	MHVW	54574
477	20071	71	TFU	38606
478	20071	106	MTHFX	39248
479	20071	91	TFV1	46370
480	20071	102	MHV	47978
481	20071	3	MHRU	54573
482	20071	126	TFW	15019
483	20071	106	MTHFU3	39243
484	20071	102	TFR-1	44162
485	20071	105	MTHFR2	39410
486	20071	108	MTHFV	41360
487	20071	91	TFU2	46331
488	20071	1	HMXY	54552
489	20071	73	MHR	38055
490	20071	106	MTHFU7	39239
491	20071	108	MTHFI	41357
492	20071	1	FTXY	54555
493	20071	63	TFR1	15635
494	20071	71	TFW	38833
495	20071	106	MTHFX3	39396
496	20071	108	MTHFD	41356
497	20071	71	TFR	38605
498	20071	106	MTHFW1	39235
499	20071	74	TFU	52910
500	20071	43	TFU1	14447
501	20071	104	MTHFX2	39212
502	20071	76	TFY	40809
503	20071	1	HMRU1	54550
504	20071	43	TFX	14453
505	20071	70	MHR	37500
506	20071	104	MTHFW11	39187
507	20071	98	MHU	42540
508	20071	1	FTRU	54553
509	20071	43	TFV	14449
510	20071	104	MTHFX-6	39342
511	20071	92	TFR4	45781
512	20071	1	HMVW	54551
513	20071	43	TFU2	14448
514	20071	70	TFV	37508
515	20071	98	MHR	42539
516	20071	42	MHW	14433
517	20071	104	MTHFR3	39218
518	20071	92	MHU3	45758
519	20071	74	TFV	52911
520	20071	82	MHU	41900
521	20071	91	TFW1	46332
522	20072	122	MHLW2	52451
523	20072	127	MHR	40251
524	20072	122	MHLF	52452
525	20072	11	MHZ	54570
526	20072	12	HMVW	54577
527	20072	28	MHU	54585
528	20072	23	SRU	54606
529	20072	36	TFY-1	13875
530	20072	120	TFW	14462
531	20072	70	MHW	37503
532	20072	128	TFV	43031
533	20072	100	TFX	47972
534	20072	129	GTH	52932
535	20072	22	W2	54581
536	20072	82	TFU	42004
537	20072	91	TFV5	46332
538	20072	122	MHLW1	52450
539	20072	11	MHX2	54569
540	20072	12	MHVW	54578
541	20072	23	TFW	54584
542	20072	14	MHQR2	54609
543	20072	66	MHX1	26506
544	20072	128	TFW	43032
545	20072	122	MHLT	52449
546	20072	9	MHSUWX	54602
547	20072	43	MHV3	14437
548	20072	106	MTHFX	39197
549	20072	108	MTHFW	41355
550	20072	5	TFU2	54566
551	20072	75	MHR	55102
552	20072	107	TFW1	39211
553	20072	114	TFY	39260
554	20072	109	MTHFQ	41357
555	20072	81	MHR	42009
556	20072	96	MHX2	42460
557	20072	70	MHX	37504
558	20072	107	TFW2	39233
559	20072	109	MTHFCR	41358
560	20072	5	TFU	54564
561	20072	88	MHW	62802
562	20072	36	TFX-2	13872
563	20072	107	MHW1	39294
564	20072	109	MTHFGV	41360
565	20072	93	MHX1	45814
566	20072	5	MHU	54563
567	20072	36	TFR-1	13864
568	20072	70	TFU	37507
569	20072	106	MTHFQ	39207
570	20072	2	MHRU	54556
571	20072	39	MHU4	16065
572	20072	107	MHV	39206
573	20072	114	TFX	39259
574	20072	109	MTHFW	41361
575	20072	74	MHX	52911
576	20072	1	FTRU	54550
577	20072	45	TFU	14470
578	20072	107	MHR	39202
579	20072	120	TFV	14459
580	20072	114	TFX1	39383
581	20072	63	MHR	15608
582	20072	105	MTHFW4	39183
583	20072	81	TFX	42012
584	20072	103	MHV	43552
585	20072	2	TFRU	54559
586	20072	120	MHU2	14453
587	20072	105	MTHFW6	39189
588	20072	91	MHR4	46307
589	20072	120	MHU	14451
590	20072	37	TFQ-2	13887
591	20072	104	MTHFX	39200
592	20072	96	MHW2	42458
593	20072	2	TFVW	54560
594	20072	120	MHR	14450
595	20072	105	MTHFW2	39171
596	20072	96	MHU2	42452
597	20072	40	MHR	14471
598	20072	105	MTHFW3	39177
599	20072	83	MHX	41425
600	20072	101	MHU1	44677
601	20072	2	TFXY	54561
602	20072	39	TFX2	16133
603	20072	105	MTHFV4	39182
604	20072	96	MHX1	42459
605	20072	40	TFW	14481
606	20072	55	MHU	15575
607	20072	105	MTHFR	39155
608	20072	93	TFX1	45831
609	20072	2	MHVW	54557
610	20072	50	TFR1	15529
611	20072	55	MHQ	15573
612	20072	92	TFX1	45796
613	20072	55	MHV1	15577
614	20072	105	MTHFR4	39180
615	20072	81	TFW	42011
616	20072	98	MHW	42481
617	20073	44	MTWHFBC	11651
618	20073	18	X2	54550
619	20073	125	X2-A	15518
620	20073	109	MTWHFJ	41354
621	20073	107	X1-1	39164
622	20073	107	X3-1	39167
623	20073	37	X3-A	13862
624	20073	71	X5	38604
625	20073	107	X3-2	39206
626	20073	109	MTWHFQ	41352
627	20073	105	Z1-4	39180
628	20073	96	X2-1	42450
629	20073	105	Z3-1	39186
630	20073	105	Z1-6	39182
631	20073	105	Z1-5	39181
632	20081	130	THV-2	44102
633	20081	17	THU	54562
634	20081	6	FWRU	54571
635	20081	16	WFV2	54578
636	20081	20	MS2	54584
637	20081	75	WFW	55101
638	20081	98	THR1	42483
639	20081	131	THW	52938
640	20081	8	WFW	54568
641	20081	20	MS3	54585
642	20081	23	THV	54609
643	20081	110	WFR	69950
644	20081	47	W	19916
645	20081	132	THX	43031
646	20081	16	WFV	54577
647	20081	20	MS4	54586
648	20081	29	THW3	54602
649	20081	106	TWHFR	39212
650	20081	95	THY	43057
651	20081	116	THQF2	52451
652	20081	6	FWVW	54572
653	20081	89	THD/HJ2	67252
654	20081	70	THY	37505
655	20081	116	THQW2	52450
656	20081	7	THVW	54574
657	20081	8	SUV	54599
658	20081	62	THW3	15694
659	20081	107	THV	39301
660	20081	116	THQF1	52449
661	20081	6	THRU	54573
662	20081	110	WFV	69957
663	20081	116	THQW1	52448
664	20081	19	THW	54565
665	20081	23	WFU	54610
666	20081	106	TWHFU1	39219
667	20081	109	TWHFGV	41386
668	20081	97	THW2	42474
669	20081	2	FWXY	54556
670	20081	45	THR2	14480
671	20081	133	THU	15105
672	20081	19	THW2	54566
673	20081	109	TWHFQ	41383
674	20081	7	THXY2	54576
675	20081	134	THV	13927
676	20081	66	THU2	26503
677	20081	106	TWHFX	39226
678	20081	114	WFV	39347
679	20081	108	TWHFW	41382
680	20081	3	WFRU	54561
681	20081	48	W	19919
682	20081	71	WFX	38601
683	20081	105	TWHFW	39209
684	20081	1	THXY2	54551
685	20081	88	A	62800
686	20081	106	TWHFV1	39221
687	20081	96	WFY2	42471
688	20081	93	THQ2	45799
689	20081	36	WFR-4	13872
690	20081	101	THR-4	44662
691	20081	3	THXY	54558
692	20081	40	THY	14496
693	20081	62	THU2	15618
694	20081	91	THX1	46320
695	20081	39	THX4	16137
696	20081	106	TWHFW2	39229
697	20081	108	TWHFQ	41378
698	20081	36	THR-1	13851
699	20081	89	WFB/WC	67292
700	20081	49	WFX1	15543
701	20081	125	THX2	15575
702	20081	37	THU-1	13881
703	20081	135	THR	15043
704	20081	106	TWHFV	39217
705	20081	39	WFV1	16136
706	20081	106	TWHFW1	39225
707	20081	98	THR2	42484
708	20081	106	TWHFR4	39216
709	20081	3	WFXY	54559
710	20081	75	THW	55100
711	20081	39	WFW2	16113
712	20081	106	TWHFR2	39214
713	20081	108	TWHFU	41380
714	20081	93	THW1	45808
715	20081	43	WFR1	14463
716	20081	70	WFU	37507
717	20081	104	TWHFW2	39167
718	20081	98	WFX1	42494
719	20081	1	HTRU	54554
720	20081	37	THV-1	13882
721	20081	104	TWHFR7	39277
722	20081	76	WFU-1	40811
723	20081	102	THU	44165
724	20081	40	THU	14489
725	20081	104	TWHFQ4	39174
726	20081	93	THR1	45800
727	20081	1	THXY	54550
728	20081	43	THV2	14459
729	20081	104	TWHFU3	39158
730	20081	82	WFR	42007
731	20081	92	THX2	45768
732	20081	1	WFXY2	54553
733	20081	43	WFX	14467
734	20081	70	THU	37501
735	20081	104	TWHFR9	39279
736	20081	97	WFY	42478
737	20081	40	WFX1	14501
738	20081	104	TWHFW3	39168
739	20081	84	THU	42004
740	20081	91	WFU3	46330
741	20081	45	THU	14481
742	20081	98	THW	42485
743	20081	43	WFR2	14464
744	20081	41	WFW2	14434
745	20081	91	THV3	46313
746	20081	74	THX	52900
747	20081	41	THX2	14418
748	20081	104	TWHFV7	39258
749	20081	76	THY	40808
750	20081	92	WFR2	45776
751	20081	1	WFXY	54552
752	20081	41	THW2	14413
753	20081	82	WFW	42008
754	20081	92	THQ1	45750
755	20081	41	WFU2	14427
756	20081	81	WFR	42001
757	20081	92	WFX1	45791
758	20081	1	HTQR	54555
759	20081	41	THR1	14402
760	20081	104	TWHFW8	39270
761	20081	92	THU5	45761
762	20081	42	THW	14446
763	20081	104	TWHFR2	39152
764	20081	82	THU	42009
765	20081	91	WFU1	46328
766	20081	120	WFV	14477
767	20081	82	THW	42010
768	20081	41	WFX2	14438
769	20081	70	THR	37500
770	20081	104	TWHFQ	39170
771	20081	92	THU3	45759
772	20081	43	WFY	14468
773	20081	104	TWHFW7	39260
774	20081	83	WFU	41375
775	20081	96	THR2	42451
776	20081	39	THU3	16133
777	20081	104	TWHFW6	39259
778	20081	81	WFX	42003
779	20081	91	THR3	46305
780	20081	41	WFW4	14436
781	20081	104	TWHFQ5	39280
782	20081	41	THR2	14403
783	20081	98	WFW	42493
784	20081	42	THV1	14444
785	20081	104	TWHFR3	39153
786	20081	39	THY2	16078
787	20081	43	THQ	14455
788	20081	136	WFV	40824
789	20081	103	WFQ1	43583
790	20081	120	THX	14469
791	20081	79	THV1	39703
792	20081	50	WFU3	15547
793	20081	55	THR2	15664
794	20081	104	TWHFX2	39187
795	20081	91	THV6	46345
796	20081	1	MUVWX	54597
797	20081	43	THW3	14600
798	20081	41	WFX5	14607
799	20081	104	TWHFU2	39157
800	20081	92	THX3	45769
801	20081	37	WFY-2	13931
802	20081	50	THV1	15528
803	20081	91	THY4	46325
804	20082	120	THX	14474
805	20082	40	THW1	14505
806	20082	114	THR	39281
807	20082	109	S3L/R4	41472
808	20082	88	WFA	62804
809	20082	45	WFV	14496
810	20082	136	WFW	40816
811	20082	14	THRU	54566
812	20082	9	THVW	54570
813	20082	22	S2	54581
814	20082	129	GM	56235
815	20082	115	WFU2	15707
816	20082	74	THW	52917
817	20082	11	WFV	54565
818	20082	21	HV	54579
819	20082	22	S1	54580
820	20082	60	MR2A	33109
821	20082	84	THW	42007
822	20082	137	THWFY	43021
823	20082	138	THWFY	43022
824	20082	22	S4	54583
825	20082	88	THK	62800
826	20082	107	WFU2	39310
827	20082	5	THU2	54561
828	20082	14	THVW	54567
829	20082	139	WFIJ	67206
830	20082	120	THQ1	14536
831	20082	122	WFLT	52430
832	20082	11	WFW	54562
833	20082	9	THYZ	54571
834	20082	12	WFUV	54575
835	20082	133	WFU2	15154
836	20082	92	THV4	45765
837	20082	14	THXY	54568
838	20082	40	THV1	14503
839	20082	81	THR	42008
840	20082	122	WFLW	52431
841	20082	5	THU	54559
842	20082	11	WFX	54563
843	20082	14	WFVW	54569
844	20082	41	THV2	14406
845	20082	120	WFV1	14480
846	20082	114	THU	39233
847	20082	107	WFU5	39321
848	20082	81	WFW	42010
849	20082	3	HTQR	54609
850	20082	122	WFLF	52433
851	20082	39	WFU4	16078
852	20082	12	WFWX	54576
853	20082	30	SWX	54588
854	20082	110	TBA	70009
855	20082	5	WFU	54560
856	20082	88	WFV	62829
857	20082	42	THU1	14429
858	20082	107	THR1	39274
859	20082	109	S4L/R1	41386
860	20082	98	THW2	42475
861	20082	75	WFW	55100
862	20082	43	THV1	14450
863	20082	106	TWHFU1	39213
864	20082	108	S2L/R4	41439
865	20082	92	THW3	45768
866	20082	2	WFXY	54555
867	20082	109	S5L/R5	41481
868	20082	82	THY	42003
869	20082	92	THV2	45763
870	20082	114	THV	39271
871	20082	93	THX3	45817
872	20082	48	X	19904
873	20082	106	TWHFW	39211
874	20082	109	S2L/R4	41468
875	20082	86	THY	47957
876	20082	35	THX1	15506
877	20082	107	THW1	39221
878	20082	109	S1L/R5	41465
879	20082	101	WFR-2	44731
880	20082	5	WFU2	54618
881	20082	37	THR-3	13884
882	20082	114	THQ	39280
883	20082	108	S5L/R1	41392
884	20082	92	THX3	45771
885	20082	120	WFX	14484
886	20082	109	S1L/R1	41383
887	20082	24	THR	54585
888	20082	107	WFR2	39309
889	20082	109	S5L/R1	41387
890	20082	93	WFV2	45826
891	20082	120	WFV3	14482
892	20082	106	TWHFR	39212
893	20082	45	WFQ	14491
894	20082	107	THQ1	39378
895	20082	109	S5L/R3	41479
896	20082	91	WFU2	46319
897	20082	36	THV-2	13859
898	20082	105	TWHFU7	39326
899	20082	96	THR3	42452
900	20082	101	WFR-4	44733
901	20082	1	FWVW	54614
902	20082	73	WFW-1	38078
903	20082	109	S4L/R3	41475
904	20082	88	TNQ	62803
905	20082	41	WFR	14415
906	20082	49	THR1	15522
907	20082	105	TWHFW2	39169
908	20082	92	WFU1	45782
909	20082	1	HTXY	54550
910	20082	39	WFV3	16081
911	20082	105	TWHFQ4	39268
912	20082	81	WFX	42011
913	20082	96	WFU2	42464
914	20082	2	HTVW	54552
915	20082	140	WFV	14556
916	20082	105	TWHFQ1	39158
917	20082	82	THU	42000
918	20082	98	THR2	42472
919	20082	2	WFRU	54554
920	20082	39	THQ1	16050
921	20082	105	TWHFU3	39173
922	20082	98	WFQ2	42477
923	20082	42	THY	14435
924	20082	73	WFV	38059
925	20082	105	TWHFQ5	39345
926	20082	92	WFX1	45795
927	20082	41	THX2	14411
928	20082	120	WFR	14477
929	20082	96	WFU1	42463
930	20082	2	THRU	54556
931	20082	61	THW1	15620
932	20082	105	TWHFV3	39174
933	20082	76	WFU	40850
934	20082	2	HTXY	54557
935	20082	41	WFU	14416
936	20082	105	TWHFW	39155
937	20082	81	WFR	42009
938	20082	91	WFX	46327
939	20082	36	WFU-1	13867
940	20082	91	WFV2	46321
941	19991	98	TFQ1	418
942	19991	116	WBC	919
943	19991	117	11	3557
944	19991	94	MHQ3	3983
945	19991	106	MTHFX6	9764
946	20001	108	MTHFW3	35242
947	20001	110	MTHFI	37302
948	20001	102	MHR-S	41562
949	20002	109	MHW2	35238
950	20002	118	TFQ	35271
951	20002	111	MTHFD	37331
952	20003	118	X3-2	35181
953	20003	95	X1-1	38511
954	20011	119	MHX	35252
955	20011	103	TFY2	40385
956	20012	113	MHX3	13972
957	20012	103	MHU1	40344
958	20012	114	TFZ	45440
959	20021	120	TFV	44931
960	20021	114	MHW	45405
961	20021	106	MTHFU1	35138
962	20021	98	TFY1	39648
963	20021	106	MTHFW4	35161
964	20021	94	MHV1	38510
965	20022	107	MTHFV1	35165
966	20022	95	MHX	38533
967	20022	100	MHW2	39648
968	20022	107	MTHFW3	35173
969	20022	100	MHV	39646
970	20031	121	MHW2	16602
971	20031	122	MHY	54604
972	20031	123	MHW	14482
973	20031	109	TFU2	39320
974	20031	110	MTHFX	41352
975	20031	93	MHU1	46314
976	20031	108	MTHFW1	39247
977	20031	110	MTHFD	41419
978	20031	93	TFY2	46310
979	20031	106	MTHFX8	39221
980	20031	88	(1)	62806
981	20031	106	MTHFW6	39211
982	20031	103	MHX2	44662
983	20032	119	MHX	39321
984	20032	94	TFX2	45813
985	20032	109	TFV1	39278
986	20032	119	MHW	39320
987	20032	111	MTHFV	41488
988	20032	95	TFX1	45839
989	20032	107	MTHFR3	39215
990	20032	102	MHU	45213
991	20032	107	MTHFW2	39236
992	20032	98	WSR2	42601
993	20032	102	TFQ	45220
994	20032	94	TFR3	45801
995	20033	110	Y3	41355
996	20033	111	Y3	41362
997	20033	98	X1-1	42451
998	20033	108	Z1-2	39183
999	20041	119	TFW	39305
1000	20041	112	MHV	70025
1001	20041	109	MHW2	39395
1002	20041	114	TFW	52451
1003	20041	108	MTHFW2	39255
1004	20041	110	MTHFX	41354
1005	20041	94	MHU5	45761
1006	20041	108	MTHFQ2	39369
1007	20041	110	MTHFD	41350
1008	20041	106	MTHFW2	39208
1009	20041	98	TFX2	42471
1010	20042	113	MHX1	15672
1011	20042	124	TFY	47972
1012	20042	113	MHV3	15668
1013	20042	109	TFU2	39271
1014	20042	119	TFR	39311
1015	20042	110	MTHFI	41352
1016	20042	119	TFQ	39178
1017	20042	109	TFR	39268
1018	20042	111	MTHFD	41379
1019	20042	107	MTHFQ2	39209
1020	20042	95	MHR1	45780
1021	20042	93	TFR3	46324
1022	20043	111	Y4	41354
1023	20043	103	X-5-2	44660
1024	20043	111	Y1	41353
1025	20043	109	X1-1	39196
1026	20043	108	Z1-4	39187
1027	20051	114	MHR	52454
1028	20051	122	MHU	54577
1029	20051	114	TFU	52455
1030	20051	112	MHR	69953
1031	20051	113	TFU2	15702
1032	20051	119	TFR	39309
1033	20051	111	MTHFI	41439
1034	20051	94	MHX3	45771
1035	20051	119	TFQ	39308
1036	20051	93	TFV1	46329
1037	20051	108	MTHFU1	39242
1038	20051	110	MTHFI	41412
1039	20051	106	MTHFW4	39212
1040	20051	94	TFQ2	45773
1041	20051	107	MTHFR	39228
1042	20051	98	TFQ3	42463
1043	20052	115	MHL	52457
1044	20052	115	MHLM	52459
1045	20052	122	MHU	54571
1046	20052	125	MHTFX	15078
1047	20052	126	MHTFX	15079
1048	20052	111	MTHFD	41375
1049	20052	103	MHV2	44695
1050	20052	91	MI1	67273
1051	20052	109	MHV	39215
1052	20052	119	TFV	39279
1053	20052	111	MTHFR	41467
1054	20052	94	MHU2	45759
1055	20052	107	MTHFV4	39184
1056	20052	95	TFU1	45811
1057	20052	108	MTHFX3	39209
1058	20052	110	MTHFV	41353
1059	20052	102	MHQ	44152
1060	20053	87	MTWHFAB	47950
1061	20053	109	X3-2	39181
1062	20053	107	Z3-2	39170
1063	20053	109	X2	39179
1064	20061	114	WIJF	52455
1065	20061	114	WIJT1	52456
1066	20061	113	TFZ1	15681
1067	20061	109	MHV	39271
1068	20061	114	WIJT2	52457
1069	20061	108	MTHFW1	39186
1070	20061	110	MTHFV	41356
1071	20061	93	TFR2	46327
1072	20061	111	MTHFV	41382
1073	20061	106	MTHFW1	39189
1074	20061	99	TFR	42466
1075	20061	106	MTHFQ1	39150
1076	20061	104	TFU	47970
1077	20061	106	MTHFX1	39197
1078	20061	105	MHQ	43553
1079	20061	100	MHY2	42478
1080	20061	106	MTHFY5	39299
1081	20061	94	TFW2	45853
1082	20061	93	MHV6	46380
1083	20061	106	MTHFX4	39200
1084	20061	94	TFR3	45763
1085	20062	115	MHK	52449
1086	20062	115	MHKH	52450
1087	20062	119	TFQ	39314
1088	20062	100	TFU1	42493
1089	20062	115	MHKM	52451
1090	20062	108	MTHFR3	39259
1091	20062	111	MTHFY	41440
1092	20062	98	MHV2	42456
1093	20062	119	TFR	39315
1094	20062	100	MHW1	42487
1095	20062	93	TFX2	46335
1096	20062	107	MTHFU5	39212
1097	20062	94	TFV2	45786
1098	20062	93	MHV5	46316
1099	20062	106	MTHFW-1	39184
1100	20062	100	MHX	42489
1101	20062	107	MTHFW1	39201
1102	20062	107	MTHFV6	39225
1103	20062	98	TFQ1	42460
1104	20062	93	TFR	46328
1105	20062	106	MTHFQ-1	39197
1106	20062	100	MHW2	42488
1107	20062	95	TFV2	45812
1108	20062	107	MTHFQ6	39395
1109	20062	98	TFX1	42466
1110	20062	105	TFW	43616
1111	20063	111	Y3	41353
1112	20063	113	X1B	15527
1113	20063	107	Z1-A	39176
1114	20063	110	Y2	41350
1115	20063	110	Y3	41351
1116	20063	107	Z2-C	39175
1117	20063	127	X1A	15540
1118	20071	114	TFL	52463
1119	20071	114	TFLH	52464
1120	20071	112	TFW	70005
1121	20071	119	TFW	39298
1122	20071	109	MHQ	39388
1123	20071	107	MTHFW2	39228
1124	20071	110	MTHFX	41361
1125	20071	108	MTHFU2	39237
1126	20071	110	MTHFQ1	41359
1127	20071	93	MHY2	46327
1128	20071	102	TFY	47991
1129	20071	108	MTHFX	39248
1130	20071	93	TFV1	46370
1131	20071	104	MHV	47978
1132	20071	128	TFW	15019
1133	20071	108	MTHFU3	39243
1134	20071	104	TFR-1	44162
1135	20071	107	MTHFR2	39410
1136	20071	110	MTHFV	41360
1137	20071	93	TFU2	46331
1138	20071	108	MTHFU7	39239
1139	20071	110	MTHFI	41357
1140	20071	108	MTHFX3	39396
1141	20071	110	MTHFD	41356
1142	20071	108	MTHFW1	39235
1143	20071	106	MTHFX2	39212
1144	20071	106	MTHFW11	39187
1145	20071	100	MHU	42540
1146	20071	106	MTHFX-6	39342
1147	20071	94	TFR4	45781
1148	20071	100	MHR	42539
1149	20071	106	MTHFR3	39218
1150	20071	94	MHU3	45758
1151	20071	93	TFW1	46332
1152	20072	115	MHLW2	52451
1153	20072	129	MHR	40251
1154	20072	115	MHLF	52452
1155	20072	123	TFW	14462
1156	20072	130	TFV	43031
1157	20072	102	TFX	47972
1158	20072	131	GTH	52932
1159	20072	93	TFV5	46332
1160	20072	115	MHLW1	52450
1161	20072	130	TFW	43032
1162	20072	115	MHLT	52449
1163	20072	108	MTHFX	39197
1164	20072	110	MTHFW	41355
1165	20072	109	TFW1	39211
1166	20072	119	TFY	39260
1167	20072	111	MTHFQ	41357
1168	20072	98	MHX2	42460
1169	20072	109	TFW2	39233
1170	20072	111	MTHFCR	41358
1171	20072	89	MHW	62802
1172	20072	109	MHW1	39294
1173	20072	111	MTHFGV	41360
1174	20072	95	MHX1	45814
1175	20072	108	MTHFQ	39207
1176	20072	109	MHV	39206
1177	20072	119	TFX	39259
1178	20072	111	MTHFW	41361
1179	20072	109	MHR	39202
1180	20072	123	TFV	14459
1181	20072	119	TFX1	39383
1182	20072	107	MTHFW4	39183
1183	20072	105	MHV	43552
1184	20072	123	MHU2	14453
1185	20072	107	MTHFW6	39189
1186	20072	93	MHR4	46307
1187	20072	123	MHU	14451
1188	20072	106	MTHFX	39200
1189	20072	98	MHW2	42458
1190	20072	123	MHR	14450
1191	20072	107	MTHFW2	39171
1192	20072	98	MHU2	42452
1193	20072	107	MTHFW3	39177
1194	20072	103	MHU1	44677
1195	20072	107	MTHFV4	39182
1196	20072	98	MHX1	42459
1197	20072	107	MTHFR	39155
1198	20072	95	TFX1	45831
1199	20072	94	TFX1	45796
1200	20072	107	MTHFR4	39180
1201	20072	100	MHW	42481
1202	20073	127	X2-A	15518
1203	20073	111	MTWHFJ	41354
1204	20073	109	X1-1	39164
1205	20073	109	X3-1	39167
1206	20073	109	X3-2	39206
1207	20073	111	MTWHFQ	41352
1208	20073	107	Z1-4	39180
1209	20073	98	X2-1	42450
1210	20073	107	Z3-1	39186
1211	20073	107	Z1-6	39182
1212	20073	107	Z1-5	39181
1213	20081	132	THV-2	44102
1214	20081	100	THR1	42483
1215	20081	133	THW	52938
1216	20081	112	WFR	69950
1217	20081	134	THX	43031
1218	20081	108	TWHFR	39212
1219	20081	97	THY	43057
1220	20081	114	THQF2	52451
1221	20081	91	THD/HJ2	67252
1222	20081	114	THQW2	52450
1223	20081	109	THV	39301
1224	20081	114	THQF1	52449
1225	20081	112	WFV	69957
1226	20081	114	THQW1	52448
1227	20081	108	TWHFU1	39219
1228	20081	111	TWHFGV	41386
1229	20081	99	THW2	42474
1230	20081	135	THU	15105
1231	20081	111	TWHFQ	41383
1232	20081	136	THV	13927
1233	20081	108	TWHFX	39226
1234	20081	119	WFV	39347
1235	20081	110	TWHFW	41382
1236	20081	107	TWHFW	39209
1237	20081	89	A	62800
1238	20081	108	TWHFV1	39221
1239	20081	98	WFY2	42471
1240	20081	95	THQ2	45799
1241	20081	103	THR-4	44662
1242	20081	93	THX1	46320
1243	20081	108	TWHFW2	39229
1244	20081	110	TWHFQ	41378
1245	20081	91	WFB/WC	67292
1246	20081	127	THX2	15575
1247	20081	137	THR	15043
1248	20081	108	TWHFV	39217
1249	20081	108	TWHFW1	39225
1250	20081	100	THR2	42484
1251	20081	108	TWHFR4	39216
1252	20081	108	TWHFR2	39214
1253	20081	110	TWHFU	41380
1254	20081	95	THW1	45808
1255	20081	106	TWHFW2	39167
1256	20081	100	WFX1	42494
1257	20081	106	TWHFR7	39277
1258	20081	104	THU	44165
1259	20081	106	TWHFQ4	39174
1260	20081	95	THR1	45800
1261	20081	106	TWHFU3	39158
1262	20081	94	THX2	45768
1263	20081	106	TWHFR9	39279
1264	20081	99	WFY	42478
1265	20081	106	TWHFW3	39168
1266	20081	93	WFU3	46330
1267	20081	100	THW	42485
1268	20081	93	THV3	46313
1269	20081	106	TWHFV7	39258
1270	20081	94	WFR2	45776
1271	20081	94	THQ1	45750
1272	20081	94	WFX1	45791
1273	20081	106	TWHFW8	39270
1274	20081	94	THU5	45761
1275	20081	106	TWHFR2	39152
1276	20081	93	WFU1	46328
1277	20081	123	WFV	14477
1278	20081	106	TWHFQ	39170
1279	20081	94	THU3	45759
1280	20081	106	TWHFW7	39260
1281	20081	98	THR2	42451
1282	20081	106	TWHFW6	39259
1283	20081	93	THR3	46305
1284	20081	106	TWHFQ5	39280
1285	20081	100	WFW	42493
1286	20081	106	TWHFR3	39153
1287	20081	138	WFV	40824
1288	20081	105	WFQ1	43583
1289	20081	123	THX	14469
1290	20081	106	TWHFX2	39187
1291	20081	93	THV6	46345
1292	20081	106	TWHFU2	39157
1293	20081	94	THX3	45769
1294	20081	93	THY4	46325
1295	20082	123	THX	14474
1296	20082	119	THR	39281
1297	20082	111	S3L/R4	41472
1298	20082	89	WFA	62804
1299	20082	138	WFW	40816
1300	20082	131	GM	56235
1301	20082	113	WFU2	15707
1302	20082	139	THWFY	43021
1303	20082	140	THWFY	43022
1304	20082	89	THK	62800
1305	20082	109	WFU2	39310
1306	20082	141	WFIJ	67206
1307	20082	123	THQ1	14536
1308	20082	115	WFLT	52430
1309	20082	135	WFU2	15154
1310	20082	94	THV4	45765
1311	20082	115	WFLW	52431
1312	20082	123	WFV1	14480
1313	20082	119	THU	39233
1314	20082	109	WFU5	39321
1315	20082	115	WFLF	52433
1316	20082	112	TBA	70009
1317	20082	89	WFV	62829
1318	20082	109	THR1	39274
1319	20082	111	S4L/R1	41386
1320	20082	100	THW2	42475
1321	20082	108	TWHFU1	39213
1322	20082	110	S2L/R4	41439
1323	20082	94	THW3	45768
1324	20082	111	S5L/R5	41481
1325	20082	94	THV2	45763
1326	20082	119	THV	39271
1327	20082	95	THX3	45817
1328	20082	108	TWHFW	39211
1329	20082	111	S2L/R4	41468
1330	20082	87	THY	47957
1331	20082	109	THW1	39221
1332	20082	111	S1L/R5	41465
1333	20082	103	WFR-2	44731
1334	20082	119	THQ	39280
1335	20082	110	S5L/R1	41392
1336	20082	94	THX3	45771
1337	20082	123	WFX	14484
1338	20082	111	S1L/R1	41383
1339	20082	109	WFR2	39309
1340	20082	111	S5L/R1	41387
1341	20082	95	WFV2	45826
1342	20082	123	WFV3	14482
1343	20082	108	TWHFR	39212
1344	20082	109	THQ1	39378
1345	20082	111	S5L/R3	41479
1346	20082	93	WFU2	46319
1347	20082	107	TWHFU7	39326
1348	20082	98	THR3	42452
1349	20082	103	WFR-4	44733
1350	20082	111	S4L/R3	41475
1351	20082	89	TNQ	62803
1352	20082	107	TWHFW2	39169
1353	20082	94	WFU1	45782
1354	20082	107	TWHFQ4	39268
1355	20082	98	WFU2	42464
1356	20082	142	WFV	14556
1357	20082	107	TWHFQ1	39158
1358	20082	100	THR2	42472
1359	20082	107	TWHFU3	39173
1360	20082	100	WFQ2	42477
1361	20082	107	TWHFQ5	39345
1362	20082	94	WFX1	45795
1363	20082	123	WFR	14477
1364	20082	98	WFU1	42463
1365	20082	107	TWHFV3	39174
1366	20082	107	TWHFW	39155
1367	20082	93	WFX	46327
1368	20082	93	WFV2	46321
1369	20082	143	WFR/WFRUV2	38632
1370	20082	104	MUV	44132
1371	20082	94	THU2	45758
1372	20082	75	WFX	55101
1373	20082	42	THW2	14433
1374	20082	100	WFR2	42479
1375	20082	123	THR	14537
1376	20082	106	TWHFQ1	39232
1377	20082	70	THU	37501
1378	20082	107	TWHFR4	39177
1379	20082	100	WFW	42481
1380	20082	40	WFX1	14513
1381	20082	76	THX	40804
1382	20082	55	WFR1	15580
1383	20082	71	THX	38600
1384	20082	107	TWHFU6	39325
1385	20082	103	WFV-2	44736
1386	20082	39	WFU2	16076
1387	20082	107	TWHFW4	39179
1388	20082	2	THXY	54553
1389	20082	123	WFW	14483
1390	20082	107	TWHFQ3	39171
1391	20082	80	THU	40251
1392	20082	41	THV3	14407
1393	20082	98	WFV2	42466
1394	20082	93	THU1	46303
1395	20082	43	WFR	14457
1396	20082	107	TWHFU5	39181
1397	20082	93	THQ1	46322
1398	20082	123	THR1	14465
1399	20082	70	WFU	37507
1400	20082	100	WFX	42482
1401	20082	105	THV	43563
1402	20082	40	THU2	14515
1403	20082	106	TWHFX	39186
1404	20082	82	WFV	42004
1405	20082	37	WFR-2	13894
1406	20082	100	WFU	42480
1407	20082	42	WFX1	14443
1408	20082	107	TWHFU2	39167
1409	20082	98	WFR1	42461
1410	20082	107	TWHFR3	39172
1411	20082	42	THR1	14427
1412	20082	100	WFR1	42478
1413	20082	39	WFU3	16077
1414	20082	107	TWHFR2	39166
1415	20082	94	WFW1	45791
1416	20082	123	THU	14466
1417	20082	107	TWHFR	39152
1418	20082	76	WFW	40808
1419	20082	41	THW	14408
1420	20082	104	THX	44130
1421	20082	41	WFV	14417
1422	20082	43	WFU	14459
1423	20082	105	THY	43554
1424	20082	62	THX1	15624
1425	20082	71	WFX	38601
1426	20082	107	TWHFW3	39175
1427	20082	105	WFR	43552
1428	20082	94	THR4	45755
1429	20082	100	WFQ1	42476
1430	20082	93	WFV1	46320
1431	20082	36	WFX-2	13879
1432	20082	106	TWHFU	39372
1433	20082	94	THX1	45769
1434	20082	95	THW2	45813
1435	20083	70	X2	37500
1436	20083	113	X4-A	15534
1437	20083	70	X5	37503
1438	20083	71	X2	38601
1439	20083	43	X5	14420
1440	20083	105	X-3C	43554
1441	20083	98	X5-1	42456
1442	20083	130	X2-1	43011
1443	20083	133	X4	52901
1444	20083	70	X4	37502
1445	20083	109	X3	39181
1446	20083	111	MTWHFJ	41366
1447	20083	109	X2	39180
1448	20083	108	Z2-6	39201
1449	20083	108	Z1-6	39197
1450	20083	109	X4	39206
1451	20083	40	X2	14432
1452	20083	109	X4-1	39210
1453	20083	111	MTWHFQ	41364
1454	20083	108	Z2-2	39175
1455	20083	107	Z1-3	39164
1456	20083	37	X4	13861
1457	20083	93	X3-2	46302
1458	20083	110	MTWHFE	41362
1459	20083	108	Z3-5	39204
1460	20083	107	Z2	39165
1461	20083	71	X3	38602
1462	20083	93	X5-1	46305
1463	20083	108	Z3-2	39178
1464	20083	110	MTWHFJ	41363
1465	20083	108	Z1-1	39170
1466	20083	36	X5	13859
1467	20083	130	X1	43000
1468	20083	107	Z1	39161
1469	20083	95	X2	45753
1470	20083	43	X3-B	14419
1471	20083	107	Z3	39168
1472	20083	108	Z3	39176
1473	20083	108	Z3-1	39177
1474	20083	107	Z2-1	39166
1475	20083	108	Z2-4	39199
1476	20091	24	THX	54565
1477	20091	8	WFV	54575
1478	20091	6	THVW	54580
1479	20091	7	FWXY	54583
1480	20091	112	WFW	69988
1481	20091	143	WFQ/WFUV1	38617
1482	20091	63	WFW1	15604
1483	20091	132	THU1	44103
1484	20091	17	THV	54567
1485	20091	19	THW	54571
1486	20091	16	WFX	54587
1487	20091	20	S6	54625
1488	20091	144	TWHFX	43036
1489	20091	145	TWHFX	43037
1490	20091	71	THW	38717
1491	20091	114	THQ	52479
1492	20091	114	THQS2	52483
1493	20091	7	THXY	54585
1494	20091	21	MR	54589
1495	20091	112	WFY	69990
1496	20091	17	THU	54568
1497	20091	19	THX	54572
1498	20091	23	MXY	54592
1499	20091	20	S7	54629
1500	20091	146	THX	53508
1501	20091	17	WFU	54569
1502	20091	19	THR	54570
1503	20091	7	HTVW	54582
1504	20091	16	WFV	54586
1505	20091	37	WFU-1	13892
1506	20091	133	THU	52904
1507	20091	23	WFX	54591
1508	20091	45	WFV1	14606
1509	20091	147	TWHFR	43056
1510	20091	148	TWHFR	43057
1511	20091	2	THVW	54559
1512	20091	19	WFU	54573
1513	20091	43	THW1	14544
1514	20091	40	WFX3	14637
1515	20091	114	THQT	52480
1516	20091	5	WFR	54564
1517	20091	6	FWVW	54579
1518	20091	149	THR	14968
1519	20091	111	S3L/R3	41398
1520	20091	150	WFV	43061
1521	20091	114	THQS1	52482
1522	20091	17	THW	54566
1523	20091	8	THV	54574
1524	20091	98	WFR2	42458
1525	20091	6	THXY	54581
1526	20091	112	WFX	69989
1527	20091	73	THW	38071
1528	20091	109	WFR	39303
1529	20091	119	WFY	39310
1530	20091	3	WFVW	54562
1531	20091	73	WFU	38063
1532	20091	114	THQH	52481
1533	20091	1	HTXY	54552
1534	20091	75	WFV	55104
1535	20091	87	THU	47951
1536	20091	8	SWX	54577
1537	20091	88	WFX	62814
1538	20091	57	WFU1	15575
1539	20091	111	S4L/R2	41402
1540	20091	6	HTXY	54578
1541	20091	7	WFWX	54584
1542	20091	93	THW2	46362
1543	20091	75	WFW	55100
1544	20091	109	WFQ	39302
1545	20091	111	S5L/R3	41408
1546	20091	3	THRU	54560
1547	20091	8	THY	54576
1548	20091	111	S1L/R5	41390
1549	20091	88	THV	62807
1550	20091	50	WFU1	15533
1551	20091	39	THU1	16075
1552	20091	151	WFX	39266
1553	20091	123	THQ	14562
1554	20091	50	THU3	15523
1555	20091	109	WFV	39297
1556	20091	110	S2L/R3	41358
1557	20091	43	WFW2	14556
1558	20091	35	THQ1	15500
1559	20091	57	THR1	15574
1560	20091	107	TWHFV	39388
1561	20091	110	S6L/R2	41381
1562	20091	1	WFRU2	54616
1563	20091	123	THU2	14565
1564	20091	39	THV3	16119
1565	20091	107	TWHFY	39272
1566	20091	110	S5L/R1	41374
1567	20091	63	WFR1	15601
1568	20091	108	TWHFU3	39278
1569	20091	110	S1L/R4	41353
1570	20091	123	THV3	14568
1571	20091	108	TWHFR4	39339
1572	20091	110	S3L/R1	41362
1573	20091	100	THW	42471
1574	20091	43	THW2	14545
1575	20091	108	TWHFQ2	39371
1576	20091	110	S6L/R6	41385
1577	20091	95	THV3	45805
1578	20091	123	THV2	14567
1579	20091	108	TWHFQ3	39372
1580	20091	81	WFR	42001
1581	20091	3	WFXY	54563
1582	20091	43	THR1	14635
1583	20091	35	WFQ1	15504
1584	20091	110	S6L/R4	41383
1585	20091	41	THX5	14502
1586	20091	108	TWHFR1	39277
1587	20091	110	S3L/R4	41365
1588	20091	97	THV	43059
1589	20091	108	TWHFR	39275
1590	20091	110	S3L/R3	41364
1591	20091	98	WFX	42525
1592	20091	3	THXY	54561
1593	20091	63	THR1	15594
1594	20091	107	TWHFX	39271
1595	20091	111	S3L/R2	41397
1596	20091	43	THQ	14539
1597	20091	108	TWHFU	39273
1598	20091	110	S2L/R4	41359
1599	20091	99	THV	42461
1600	20091	127	THY1	15552
1601	20091	110	S6L/R5	41384
1602	20091	2	THRU	54628
1603	20091	127	WFR1	15554
1604	20091	93	THV3	46307
1605	20091	50	THV2	15558
1606	20091	110	S1L/R5	41354
1607	20091	36	WFV-3	13865
1608	20091	108	TWHFQ1	39338
1609	20091	110	S5L/R6	41379
1610	20091	93	WFX2	46357
1611	20091	108	TWHFU2	39276
1612	20091	110	S4L/R1	41368
1613	20091	81	WFX	42003
1614	20091	94	WFY3	45798
1615	20091	41	THX6	14638
1616	20091	50	WFV2	15536
1617	20091	109	WFW	39298
1618	20091	93	THU4	46305
1619	20091	64	THQ1	15666
1620	20091	50	WFV1	15535
1621	20091	57	WFX1	15577
1622	20091	110	S3L/R5	41366
1623	20091	43	WFW4	14558
1624	20091	108	TWHFR5	39340
1625	20091	95	THW1	45806
1626	20091	62	THR1	15665
1627	20091	70	THY	37505
1628	20091	108	TWHFU4	39287
1629	20091	36	WFY-1	13878
1630	20091	107	TWHFR1	39383
1631	20091	110	S6L/R3	41382
1632	20091	99	WFU	42463
1633	20091	95	WFR1	45813
1634	20091	152	NONE	20509
1635	20091	110	S4L/R4	41371
1636	20091	97	WFU	43001
1637	20091	127	THV2	15561
1638	20091	108	TWHFQ	39285
1639	20091	111	S2L/R1	41391
1640	20091	89	WFX	62805
1641	20091	37	WFW-1	13896
1642	20091	63	THV1	15596
1643	20091	108	TWHFR6	39347
1644	20091	108	TWHFR2	39284
1645	20091	94	WFX2	45793
1646	20091	65	THV1	15616
1647	20091	107	TWHFR	39270
1648	20091	110	S5L/R4	41377
1649	20091	134	THU	43031
1650	20091	37	THW-1	13883
1651	20091	95	WFW1	45820
1652	20091	37	WFY-1	13898
1653	20091	39	THW1	16091
1654	20091	110	S3L/R2	41363
1655	20091	36	WFW-4	13864
1656	20091	57	WFV1	15576
1657	20091	94	THV4	45763
1658	20091	39	THV1	16090
1659	20091	109	THX	39300
1660	20091	23	WFY	54550
1661	20091	36	WFR-2	13868
1662	20091	110	S4L/R3	41370
1663	20091	95	THW2	45807
1664	20091	36	THU-3	13938
1665	20091	109	WFU	39385
1666	20091	110	S5L/R5	41378
1667	20091	74	THV	52915
1668	20091	62	WFR1	15668
1669	20091	107	TWHFU	39378
1670	20091	36	WFX-4	13939
1671	20091	50	THW1	15525
1672	20091	111	S1L/R3	41388
1673	20091	50	THX3	15638
1674	20091	109	THY	39296
1675	20091	95	WFY1	45824
1676	20091	36	THV-1	13856
1677	20091	123	THW	14571
1678	20091	39	THX2	16082
1679	20091	110	S2L/R1	41356
1680	20091	108	TWHFU1	39274
1681	20091	110	S2L/R5	41360
1682	20091	87	THQ1	47992
1683	20091	89	THZ	62833
1684	20091	81	WFW	42002
1685	20091	43	THX2	14547
1686	20091	106	TWHFW5	39209
1687	20091	94	WFQ2	45774
1688	20091	1	HTRU	54554
1689	20091	41	THX2	14499
1690	20091	83	WFU	41502
1691	20091	43	THR	14540
1692	20091	70	THU	37501
1693	20091	106	TWHFW4	39174
1694	20091	100	WFX	42475
1695	20091	1	FWRU	54553
1696	20091	41	THV2	14490
1697	20091	106	TWHFQ1	39151
1698	20091	82	THU	42006
1699	20091	1	WFRU	54557
1700	20091	41	WFV2	14513
1701	20091	106	TWHFU3	39163
1702	20091	83	WFW	41503
1703	20091	100	THR2	42469
1704	20091	1	HTVW	54551
1705	20091	41	WFX2	14521
1706	20091	106	TWHFW7	39248
1707	20091	81	THR	42000
1708	20091	93	THU2	46303
1709	20091	41	WFX1	14520
1710	20091	106	TWHFU2	39162
1711	20091	94	THW1	45765
1712	20091	1	FWVW	54555
1713	20091	106	TWHFQ3	39153
1714	20091	82	WFW	42005
1715	20091	100	THR1	42468
1716	20091	42	THW	14530
1717	20091	106	TWHFV2	39167
1718	20091	82	THR	42004
1719	20091	93	WFR2	46317
1720	20091	1	FWXY	54556
1721	20091	70	THR	37500
1722	20091	99	THW	42462
1723	20091	41	WFX3	14522
1724	20091	70	WFW	37509
1725	20091	93	THR	46369
1726	20091	40	THX1	14585
1727	20091	87	WFR	47957
1728	20091	39	THR2	16099
1729	20091	70	WFV	37508
1730	20091	88	WFR	62809
1731	20091	106	TWHFQ5	39249
1732	20091	83	WFX	41504
1733	20091	100	WFR	42473
1734	20091	43	THV	14543
1735	20091	106	TWHFU1	39161
1736	20091	94	WFW2	45790
1737	20091	40	WFX1	14594
1738	20091	106	TWHFV4	39169
1739	20091	76	WFU1	40810
1740	20091	91	WFB/WI2	67207
1741	20091	39	THX3	16054
1742	20091	94	WFX4	45795
1743	20091	42	THY	14531
1744	20091	106	TWHFV6	39242
1745	20091	94	WFX1	45792
1746	20091	40	WFY	14596
1747	20091	100	WFQ1	42472
1748	20091	123	WFW	14578
1749	20091	100	THR3	42515
1750	20091	39	WFV2	16114
1751	20091	100	WFW	42474
1752	20091	93	THV1	46306
1753	20091	123	WFV3	14577
1754	20091	76	WFX	40811
1755	20091	94	WFQ3	45775
1756	20091	40	THX2	14586
1757	20091	93	WFY1	46331
1758	20091	43	WFW1	14555
1759	20091	93	WFY2	46320
1760	20091	41	THU4	14488
1761	20091	106	TWHFW6	39243
1762	20091	94	THQ1	45750
1763	20091	153	WFU	39192
1764	20091	105	WFV1	43584
1765	20091	44	WFY	11656
1766	20091	40	THY	14588
1767	20091	41	THQ	14483
1768	20091	106	TWHFX7	39254
1769	20091	104	THV1	45853
1770	20091	94	THX2	45769
1771	20091	41	THW5	14497
1772	20091	106	TWHFQ	39150
1773	20091	39	THQ1	16098
1774	20091	93	THX3	46314
1775	20091	40	WFV2	14592
1776	20091	100	WFQ2	42522
1777	20091	60	MR2B	33108
1778	20091	70	WFU	37507
1779	20091	102	THX	44146
1780	20091	41	THX3	14500
1781	20091	94	WFX3	45794
1782	20091	42	WFY1	14536
1783	20091	93	WFU1	46319
1784	20091	106	TWHFY1	39180
1785	20091	94	THU1	45756
1786	20091	42	WFY2	14537
1787	20091	42	THR	14525
1788	20091	106	TWHFX6	39244
1789	20091	98	WFV	42460
1790	20091	76	THX1	40806
1791	20091	88	WFU	62810
1792	20091	123	THR	14563
1793	20091	99	WFV	42464
1794	20091	94	WFV4	45788
1795	20091	106	TWHFY2	39203
1796	20091	43	WFX2	14560
1797	20091	70	WFR	37506
1798	20091	100	THQ1	42466
1799	20091	94	WFV3	45787
1800	20091	123	THU3	14611
1801	20091	106	TWHFY3	39204
1802	20092	154	THY	39298
1803	20092	118	THW	39332
1804	20092	11	WFV	54554
1805	20092	9	WFRU	54591
1806	20092	19	WFW	54631
1807	20092	23	MWX	54637
1808	20092	113	THY1	15663
1809	20092	39	WFU2	16144
1810	20092	155	THW	40256
1811	20092	84	WFV	42006
1812	20092	115	THX	52450
1813	20092	115	THXH	52453
1814	20092	9	WFXY	54566
1815	20092	22	SCVMIG	54602
1816	20092	81	WFW	42002
1817	20092	12	THVW	54575
1818	20092	27	MBD	54625
1819	20092	156	WFQ	15001
1820	20092	50	THU1	15531
1821	20092	115	THXW	52452
1822	20092	131	WFW	56273
1823	20092	39	THV	16073
1824	20092	59	MR11A	33100
1825	20092	74	THW	54000
1826	20092	12	FWVW	54572
1827	20092	157	THX	55673
1828	20092	94	THU1	45755
1829	20092	24	THW	54567
1830	20092	11	WFU	54578
1831	20092	35	THR1	15502
1832	20092	3	THVW	54551
1833	20092	11	WFW	54555
1834	20092	23	WFX	54573
1835	20092	5	WFU	54589
1836	20092	29	THQ	54628
1837	20092	137	THX	15026
1838	20092	14	WFVW	54560
1839	20092	11	WFR	54577
1840	20092	75	THY	55115
1841	20092	41	THY1	14408
1842	20092	113	WFV1	15650
1843	20092	79	THV2	39704
1844	20092	83	THU	41483
1845	20092	21	HR	54570
1846	20092	23	THY	54571
1847	20092	22	MACL	54600
1848	20092	43	THV1	14441
1849	20092	115	THXF	52454
1850	20092	123	THR1	14470
1851	20092	45	SDEF	14501
1852	20092	109	THW	39239
1853	20092	81	WFX	42003
1854	20092	23	WFY1	54638
1855	20092	42	WFX	14435
1856	20092	45	THV	14492
1857	20092	158	THW	16135
1858	20092	2	THRU	54579
1859	20092	37	WFW-2	13928
1860	20092	12	HTVW	54563
1861	20092	9	HTRU	54568
1862	20092	42	THV1	14615
1863	20092	94	THX1	45765
1864	20092	14	WFXY	54561
1865	20092	23	MVW	54634
1866	20092	47	Y	19902
1867	20092	109	THW1	39343
1868	20092	111	S3L/R1	41398
1869	20092	94	THV2	45760
1870	20092	26	THX	54569
1871	20092	125	THY	15057
1872	20092	159	WFW	16126
1873	20092	5	THX	54587
1874	20092	23	WFENTREP	54635
1875	20092	91	WFB/WK2	67256
1876	20092	109	THV1	39245
1877	20092	111	S1L/R5	41392
1878	20092	135	THW	14956
1879	20092	97	WFX	43062
1880	20092	93	THQ2	46301
1881	20092	102	THX	44162
1882	20092	14	WFRU	54559
1883	20092	81	THR	42000
1884	20092	14	THXY	54562
1885	20092	98	THY1	42456
1886	20092	35	WFV1	15508
1887	20092	119	WFX	39214
1888	20092	109	WFU2	39334
1889	20092	45	WFU	14495
1890	20092	115	THXT	52451
1891	20092	9	WFVW	54592
1892	20092	43	WFQ	14452
1893	20092	107	TWHFV6	39335
1894	20092	103	THR-1	44670
1895	20092	2	HTXY	54586
1896	20092	108	TWHFX	39230
1897	20092	111	S5L/R2	41409
1898	20092	97	WFR	43002
1899	20092	93	WFV3	46327
1900	20092	109	THU1	39333
1901	20092	111	S2L/R4	41396
1902	20092	23	WFY	54633
1903	20092	36	WFU-3	13878
1904	20092	111	S1L/R4	41389
1905	20092	100	THR1	42472
1906	20092	93	THY1	46319
1907	20092	2	HTVW	54580
1908	20092	50	WFW1	15543
1909	20092	111	S2L/R1	41393
1910	20092	94	THV1	45759
1911	20092	55	WFW1	15573
1912	20092	70	THR	37500
1913	20092	109	THQ	39248
1914	20092	111	S3L/R5	41402
1915	20092	108	TWHFV	39233
1916	20092	111	S5L/R5	41412
1917	20092	82	WFR	42009
1918	20092	2	FWXY	54582
1919	20092	109	WFU1	39253
1920	20092	93	THV5	46307
1921	20092	87	WFY	47951
1922	20092	5	THU	54590
1923	20092	108	TWHFR	39232
1924	20092	95	THY1	45805
1925	20092	108	TWHFX1	39235
1926	20092	94	WFR1	45774
1927	20092	41	THV1	14402
1928	20092	109	WFV1	39255
1929	20092	100	WFW	42478
1930	20092	93	THU2	46305
1931	20092	36	WFW-1	13880
1932	20092	61	THX1	15597
1933	20092	107	TWHFU7	39338
1934	20092	5	THY	54588
1935	20092	43	THW1	14446
1936	20092	60	MR1	33108
1937	20092	109	THX	39240
1938	20092	111	S2L/R3	41395
1939	20092	43	WFU2	14454
1940	20092	123	WFV1	14484
1941	20092	109	THV	39238
1942	20092	2	THXY	54584
1943	20092	63	THQ1	15608
1944	20092	108	TWHFW1	39234
1945	20092	123	THV2	14473
1946	20092	55	THW1	15570
1947	20092	118	THR	39323
1948	20092	109	THU2	39340
1949	20092	94	WFY1	45790
1950	20092	37	WFV-2	13926
1951	20092	73	WFR	38050
1952	20092	100	THR3	42523
1953	20092	108	TWHFU	39231
1954	20092	94	WFV2	45782
1955	20092	50	WFX2	15535
1956	20092	109	THR1	39326
1957	20092	94	THU2	45756
1958	20092	107	TWHFV4	39204
1959	20092	110	S5L/R6	41379
1960	20092	1	FWXY	54553
1961	20092	109	WFU	39244
1962	20092	93	THY2	46320
1963	20092	70	THW	37503
1964	20092	111	S2L/R5	41397
1965	20092	42	WFR2	14429
1966	20092	111	S4L/R5	41407
1967	20092	160	THU	42480
1968	20092	36	THY-2	13870
1969	20092	35	WFX1	15544
1970	20092	107	TWHFU4	39203
1971	20092	1	FWVW	54565
1972	20092	42	WFU1	14430
1973	20092	109	THV2	39254
1974	20092	74	THY	54001
1975	20092	50	THV4	15656
1976	20092	94	WFV3	45783
1977	20092	109	WFW	39257
1978	20092	111	S2L/R2	41394
1979	20092	95	THX1	45803
1980	20092	66	THX1	26506
1981	20092	51	FWX	29251
1982	20092	95	WFR1	45808
1983	20092	40	THU2	14503
1984	20092	110	S6L/R3	41382
1985	20092	36	THR-2	13852
1986	20092	43	THU1	14438
1987	20092	111	S5L/R3	41410
1988	20092	93	WFX2	46330
1989	20092	35	WFR1	15506
1990	20092	70	THV	37502
1991	20092	109	THR3	39339
1992	20092	111	S3L/R4	41401
1993	20092	50	WFR1	15539
1994	20092	109	THR	39250
1995	20092	93	WFV1	46325
1996	20092	50	THV2	15534
1997	20092	111	S3L/R2	41399
1998	20092	123	THX1	14478
1999	20092	109	THR2	39331
2000	20092	111	S5L/R1	41408
2001	20092	93	WFX1	46332
2002	20092	50	WFX1	15545
2003	20092	109	WFR	39251
2004	20092	94	THR2	45753
2005	20092	94	THQ1	45750
2006	20092	35	THV1	15504
2007	20092	70	THY	37505
2008	20092	110	S6L/R2	41381
2009	20092	75	WFW	55101
2010	20092	37	THV-1	13917
2011	20092	95	WFV2	45812
2012	20092	93	THU3	46306
2013	20092	104	WFW	47957
2014	20092	39	THR	16069
2015	20092	70	THU	37501
2016	20092	138	WFU	40812
2017	20092	111	S4L/R4	41406
2018	20092	161	FAB2	41451
2019	20092	70	WFV	37508
2020	20092	111	S5L/R4	41411
2021	20092	87	WFR	47963
2022	20092	43	WFV2	14457
2023	20092	42	THX2	14425
2024	20092	45	WFX	14500
2025	20092	107	TWHFW	39180
2026	20092	100	WFQ1	42475
2027	20092	2	HTRU1	54557
2028	20092	36	WFV-2	13873
2029	20092	107	TWHFW3	39201
2030	20092	98	THY3	42458
2031	20092	2	HTRU2	54550
2032	20092	36	THX-2	13867
2033	20092	41	THU1	14606
2034	20092	107	TWHFW2	39194
2035	20092	93	WFU3	46324
2036	20092	123	WFV2	14485
2037	20092	107	TWHFQ1	39183
2038	20092	105	WFU	43562
2039	20092	107	TWHFV3	39200
2040	20092	94	THW2	45764
2041	20092	93	WFR1	46321
2042	20092	40	WFR	14511
2043	20092	70	WFU	37507
2044	20092	87	WFX	47970
2045	20092	43	WFX	14466
2046	20092	82	THR	42008
2047	20092	95	WFV1	45811
2048	20092	1	THVW	54556
2049	20092	123	WFW1	14487
2050	20092	48	X	19904
2051	20092	39	THQ	16094
2052	20092	79	THW2	39705
2053	20092	94	WFW2	45785
2054	20092	41	WFX1	14417
2055	20092	36	WFU-2	13877
2056	20092	41	WFR	14411
2057	20092	100	WFQ2	42476
2058	20092	107	TWHFQ3	39196
2059	20092	98	WFV2	42461
2060	20092	123	WFR	14481
2061	20092	40	WFU1	14512
2062	20092	106	TWHFW	39174
2063	20092	107	TWHFU2	39192
2064	20092	98	WFV1	42460
2065	20092	41	THX2	14406
2066	20092	81	WFR	42001
2067	20092	39	WFX4	16105
2068	20092	70	WFW	37509
2069	20092	107	TWHFU1	39185
2070	20092	39	THX1	16053
2071	20092	106	TWHFV1	39211
2072	20092	94	WFR3	45776
2073	20092	158	THX	16136
2074	20092	107	TWHFU	39178
2075	20092	98	THV1	42453
2076	20092	99	WFW	42467
2077	20092	43	WFV4	14459
2078	20092	107	TWHFQ4	39209
2079	20092	93	WFU1	46322
2080	20092	39	WFV1	16104
2081	20092	73	WFU	38065
2082	20092	107	TWHFR	39177
2083	20092	93	WFW1	46328
2084	20092	70	WFX	37510
2085	20092	89	WFR	62802
2086	20092	42	WFU2	14431
2087	20092	107	TWHFR2	39191
2088	20092	100	THQ2	42470
2089	20092	39	THW	16074
2090	20092	107	TWHFV1	39186
2091	20092	41	WFU1	14412
2092	20092	107	TWHFR4	39202
2093	20092	98	THU	42452
2094	20092	63	WFV1	15617
2095	20092	39	WFR1	16097
2096	20092	107	TWHFU3	39198
2097	20092	41	WFW1	14415
2098	20092	93	THW2	46316
2099	20092	70	THX	37504
2100	20092	39	WFW	16121
2101	20092	106	TWHFR	39171
2102	20092	83	THX	41485
2103	20092	63	THW3	15664
2104	20092	94	WFU3	45780
2105	20092	79	THV1	39703
2106	20092	83	WFX	41488
2107	20092	93	THW3	46313
2108	20092	41	THX3	14407
2109	20092	105	THY	43560
2110	20092	42	THX1	14424
2111	20092	95	WFU1	45809
2112	20092	83	THW	41484
2113	20092	94	WFR4	45777
2114	20092	107	TWHFW1	39187
2115	20092	99	WFU	42464
2116	20092	71	THX	38794
2117	20092	94	WFX3	45789
2118	20092	100	THQ1	42469
2119	20092	46	WFR	14951
2120	20092	107	TWHFV2	39193
2121	20092	95	WFQ1	45807
2122	20092	93	THU1	46304
2123	20092	43	WFU3	14455
2124	20092	99	WFX	42468
2125	20092	76	WFY	40806
2126	20092	93	THX1	46317
2127	20092	123	WFU1	14482
2128	20092	75	WFV	55100
2129	20092	61	WFU1	15599
2130	20092	107	TWHFW4	39321
2131	20092	93	THV4	46312
2132	20092	57	WFR1	15588
2133	20092	63	WFY1	15620
2134	20092	99	THW	42463
2135	20092	41	WFU3	14414
2136	20092	97	THW1	43003
2137	20092	39	THX2	16078
2138	20092	59	MR11C	33102
2139	20092	36	WFU-1	13875
2140	20092	70	WFR	37506
2141	20092	107	TWHFV5	39329
2142	20092	94	WFU2	45779
2143	20092	41	WFW2	14416
2144	20092	123	WFW2	14488
2145	20092	40	THW	14506
2146	20092	36	THQ-1	13850
2147	20092	106	TWHFV	39173
2148	20092	89	WFU	62803
2149	20092	36	THU-2	13855
2150	20092	39	WFQ1	16096
2151	20092	43	THU2	14439
2152	20092	40	THY2	14510
2153	20092	158	WFX	16127
2154	20092	76	THW	40802
2155	20092	94	THX4	45768
2156	20092	107	TWHFU5	39206
2157	20092	100	THW	42474
2158	20092	41	WFX2	14418
2159	20092	93	THR1	46302
2160	20092	94	WFX1	45787
2161	20092	43	WFW1	14461
2162	20092	106	TWHFQ	39170
2163	20092	103	WFV-1	44684
2164	20092	39	THX3	16081
2165	20092	93	THW1	46315
2166	20092	42	THX3	14426
2167	20092	39	WFY2	16068
2168	20092	104	MCDE1	45817
2169	20092	100	WFR	42477
2170	20092	95	THU2	45796
2171	20092	39	WFU	16103
2172	20093	41	X4A	14406
2173	20093	111	X7-5	41355
2174	20093	93	X3-1	46307
2175	20093	35	X2-A	15501
2176	20093	18	Prac	54551
2177	20093	162	X7-9	41359
2178	20093	94	X3	45753
2179	20093	113	X1-A	15546
2180	20093	70	X5	37504
2181	20093	113	X2-B	15543
2182	20093	133	X4	55651
2183	20093	61	X3-A	15519
2184	20093	109	X2-1	39205
2185	20093	81	X4	42003
2186	20093	71	X3	38602
2187	20093	123	X3A	14431
2188	20093	111	X7-4	41354
2189	20093	98	X1	42451
2190	20093	5	X	54554
2191	20093	108	Z1-4	39195
2192	20093	109	X1-1	39193
2193	20093	103	X-2	44659
2194	20093	109	X4	39182
2195	20093	109	X3	39181
2196	20093	100	X4-1	42461
2197	20093	108	Z2	39172
2198	20093	108	Z3-1	39175
2199	20093	108	Z3-4	39206
2200	20093	109	X4-1	39183
2201	20093	43	X2B	14418
2202	20093	123	X2A	14428
2203	20093	93	X3	46302
2204	20093	23	X	54553
2205	20093	109	X2	39180
2206	20093	103	X5	43556
2207	20093	50	X4-A	15507
2208	20093	41	X3A	14403
2209	20093	108	Z1-1	39173
2210	20093	108	Z2-3	39199
2211	20093	137	X3	14966
2212	20093	163	X-2-2	44653
2213	20093	107	Z1-2	39169
2214	20093	108	Z1	39170
2215	20093	108	Z1-3	39194
2216	20093	108	Z1-5	39196
2217	20093	95	X3	45755
2218	20093	93	X2	46301
2219	20093	108	Z2-2	39177
2220	20093	105	X3	43554
2221	20093	94	X2	45752
2222	20093	40	X4A	14439
2223	20093	100	X3-1	42459
2224	20093	107	Z1	39164
2225	20093	108	Z1-2	39176
2226	20093	108	Z1-6	39197
2227	20093	107	Z2	39165
2228	20093	107	Z1-3	39201
2229	20093	108	Z3-2	39178
2230	20093	100	X3-2	42460
2231	20093	94	X1	45751
2232	20093	107	Z2-1	39168
2233	20093	107	Z2-2	39202
2234	20093	84	X3	42002
2235	20093	39	X1A	16051
2236	20093	102	X2-1	44110
2237	20093	71	X2	38601
2238	20093	107	Z1-1	39167
2239	20093	108	Z1-8	39215
2240	20093	108	Z2-1	39174
2241	20101	17	THU	54569
2242	20101	7	HTVW	54586
2243	20101	16	THY	54592
2244	20101	6	S2	54650
2245	20101	112	WFR	69955
2246	20101	37	WFX-1	13890
2247	20101	102	WFU	44164
2248	20101	17	WFV	54571
2249	20101	21	HR	54593
2250	20101	20	MACL	54614
2251	20101	19	WFX	54576
2252	20101	16	WFY	54591
2253	20101	20	MWSG	54619
2254	20101	112	WFU	69956
2255	20101	164	THD	66665
2256	20101	164	HJ4	66745
2257	20101	70	WFV	37509
2258	20101	82	THX	42012
2259	20101	16	WFX	54590
2260	20101	23	THR	54605
2261	20101	114	WBC	52481
2262	20101	114	WBCH	52483
2263	20101	17	WFW	54572
2264	20101	8	THV	54579
2265	20101	6	HTXY	54582
2266	20101	7	M	54649
2267	20101	114	WBCT	52482
2268	20101	8	THW	54577
2269	20101	7	WFVW	54646
2270	20101	23	THV	54595
2271	20101	114	FBCS2	52528
2272	20101	114	FBC	52530
2273	20101	113	WFQ2	15650
2274	20101	155	THW	40258
2275	20101	19	WFU	54574
2276	20101	16	WFV	54589
2277	20101	20	MCVMIG	54616
2278	20101	112	WFX	70034
2279	20101	123	WFU1	14497
2280	20101	87	WFW1	47967
2281	20101	7	HTRU	54585
2282	20101	113	THV1	15631
2283	20101	70	THW	37504
2284	20101	100	WFR1	42472
2285	20101	3	WFVW	54567
2286	20101	19	THR	54573
2287	20101	17	WFU	54570
2288	20101	19	WFW	54575
2289	20101	26	THX	54596
2290	20101	75	WFY	55106
2291	20101	8	THY	54578
2292	20101	113	THX2	15636
2293	20101	165	THU	39268
2294	20101	111	S4-A	41382
2295	20101	114	FBCS1	52484
2296	20101	20	MNDSG	54617
2297	20101	43	THW1	14465
2298	20101	111	S3-A	41380
2299	20101	95	THV1	45796
2300	20101	79	WFV1	39705
2301	20101	20	MSCL	54618
2302	20101	108	TWHFV1	39249
2303	20101	72	WFX	52379
2304	20101	3	WFRU	54566
2305	20101	35	WFV2	15505
2306	20101	109	THX	39261
2307	20101	100	THR3	42519
2308	20101	166	THU	43030
2309	20101	23	THW	54604
2310	20101	36	THY-1	13862
2311	20101	103	WFQ-2	44665
2312	20101	74	THX	54001
2313	20101	23	WFY	54607
2314	20101	127	THV1	15554
2315	20101	81	WFX	42002
2316	20101	82	THR	42003
2317	20101	107	TWHFY1	39382
2318	20101	110	S3-A	41361
2319	20101	1	FWVW	54555
2320	20101	45	WFV	14519
2321	20101	6	S	54643
2322	20101	137	THQ	15024
2323	20101	56	THX1	15566
2324	20101	6	FWVW	54583
2325	20081	21	MU	54580
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
1	2009	0
2	2009	0
3	2009	0
4	2009	0
5	2009	0
6	2009	0
7	2009	0
8	2009	0
9	2009	0
10	2009	0
11	2010	23
11	2012	13
12	2012	13
13	2012	19
14	2012	19
15	2010	17
15	2012	19
16	2012	19
17	2012	19
18	2012	19
19	2012	19
20	2012	19
21	2011	21
21	2012	18
22	2012	15
23	2012	10
24	2012	18
25	2012	18
26	2012	15
27	2012	0
28	2012	15
29	2012	18
30	2012	18
31	2012	15
32	2012	15
33	2012	15
34	2012	15
35	2012	15
36	2012	15
37	2012	15
38	2012	15
39	2012	15
40	2012	15
41	2012	18
42	2012	12
43	2012	18
44	2012	15
45	2012	15
46	2012	18
47	2012	18
48	2012	12
49	2012	8
50	2012	15
51	2012	18
52	2012	15
53	2012	11
54	2012	15
55	2012	10
56	2011	15
56	2012	7
57	2010	12
57	2011	0
58	2003	6
60	2006	12
60	2007	6
61	2012	3
62	2004	23
62	2008	21
62	2009	22
62	2010	6
63	2005	19
63	2006	16
63	2009	3
65	2008	21
65	2010	4
66	2009	6
66	2010	3
67	2010	9
68	2010	12
70	2010	15
71	2010	0
72	2010	9
73	2010	9
74	2010	13
75	2010	12
76	2010	15
77	2010	16
78	2009	22
78	2010	6
79	2010	15
80	2009	13
80	2010	10
81	2010	12
82	2010	15
83	2010	15
84	2010	19
85	2010	15
86	2010	18
87	2010	15
88	2010	18
89	2010	9
106	2009	15
115	2009	23
121	2010	9
122	2010	12
123	2010	13
124	2010	15
125	2010	19
126	2010	19
232	2009	11
233	2009	14
234	2009	19
235	2010	15
236	1999	23
236	2001	21
236	2002	18
236	2003	6
238	2006	9
238	2007	3
239	2004	13
239	2008	12
239	2009	22
239	2010	6
240	2005	12
240	2006	13
240	2007	22
240	2009	3
242	2006	23
242	2008	18
242	2010	4
243	2009	6
243	2010	3
244	2010	9
245	2010	12
247	2010	15
248	2010	0
249	2010	9
250	2010	9
251	2010	13
252	2010	12
253	2010	15
254	2010	16
255	2009	22
255	2010	6
256	2010	15
257	2009	13
257	2010	10
258	2010	12
259	2010	15
260	2010	15
261	2010	19
262	2010	15
263	2010	18
264	2010	15
265	2010	18
266	2010	9
283	2009	15
292	2009	23
298	2008	22
298	2010	9
299	2010	12
300	2010	13
301	2010	15
302	2010	19
408	2009	11
409	2009	14
410	2009	19
411	2010	15
412	2003	6
414	2006	9
414	2007	3
415	2004	13
415	2008	12
415	2009	22
415	2010	6
416	2005	12
416	2006	13
416	2007	22
416	2009	3
418	2006	23
418	2008	18
418	2010	4
419	2009	6
419	2010	3
420	2010	9
421	2010	12
423	2010	15
424	2010	0
425	2010	9
426	2010	9
427	2010	13
428	2010	12
429	2010	15
430	2010	16
431	2009	22
431	2010	6
432	2010	15
433	2009	13
433	2010	10
434	2010	12
435	2010	15
436	2010	15
437	2010	19
438	2010	15
439	2010	18
440	2010	15
441	2010	18
442	2010	9
459	2009	15
468	2009	23
474	2008	22
474	2010	9
475	2010	12
476	2010	13
477	2010	15
478	2010	19
479	2010	19
585	2009	11
586	2009	14
587	2009	19
588	2010	15
589	1999	23
589	2001	21
589	2002	18
589	2003	6
591	2006	9
591	2007	3
592	2004	13
592	2008	12
592	2009	22
592	2010	6
593	2005	12
593	2006	13
593	2007	22
593	2009	3
595	2006	23
595	2008	18
595	2010	4
596	2009	6
596	2010	3
597	2010	9
598	2010	12
600	2010	15
601	2010	0
602	2010	9
603	2010	9
604	2010	13
605	2010	12
606	2010	15
607	2010	16
608	2009	22
608	2010	6
609	2010	15
610	2009	13
610	2010	10
611	2010	12
612	2010	15
613	2010	15
614	2010	19
615	2010	15
616	2010	18
617	2010	15
618	2010	18
619	2010	9
636	2009	15
645	2009	23
651	2008	22
651	2010	9
652	2010	12
653	2010	13
654	2010	15
655	2010	19
656	2010	19
762	2009	11
763	2009	14
764	2009	19
765	2010	15
766	1999	23
766	2001	21
766	2002	18
766	2003	6
768	2006	9
768	2007	3
769	2004	13
769	2008	12
769	2009	22
769	2010	6
770	2005	12
770	2006	13
770	2007	22
770	2009	3
772	2006	23
772	2008	18
772	2010	4
773	2009	6
773	2010	3
774	2010	9
775	2010	12
777	2010	15
778	2010	0
779	2010	9
780	2010	9
781	2010	13
782	2010	12
783	2010	15
784	2010	16
785	2009	22
785	2010	6
786	2010	15
787	2009	13
787	2010	10
788	2010	12
789	2010	15
790	2010	15
791	2010	19
792	2010	15
793	2010	18
794	2010	15
795	2010	18
796	2010	9
813	2009	15
822	2009	23
828	2008	22
828	2010	9
829	2010	12
830	2010	13
831	2010	15
832	2010	19
833	2010	19
939	2009	11
940	2009	14
941	2009	19
942	2010	15
943	2003	6
944	2003	9
\.


--
-- Data for Name: eligpasshalf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalf (studentid, studenttermid, termid, failpercentage) FROM stdin;
11	11	20101	0.800000012
15	15	20101	0.600000024
15	25	20102	0.600000024
27	92	20121	1
49	144	20121	0.555555582
57	156	20111	1
57	157	20112	1
60	179	20032	0.800000012
62	193	20042	0.71875
62	458	20091	0.600000024
62	894	20101	0.600000024
63	194	20042	0.629629612
70	801	20093	1
71	300	20073	1
72	282	20072	0.600000024
80	810	20093	0.571428597
103	446	20083	1
106	513	20091	0.631578922
110	451	20083	1
115	836	20093	1
128	818	20093	1
172	856	20093	1
221	886	20093	1
223	888	20093	1
238	946	20032	0.8125
239	960	20042	0.789473712
239	1225	20091	0.600000024
239	1658	20101	0.600000024
240	961	20042	0.5625
247	1566	20093	1
248	1067	20073	1
249	1049	20072	0.625
257	1575	20093	0.571428597
280	1213	20083	1
283	1279	20091	0.631578922
287	1218	20083	1
292	1600	20093	1
304	1582	20093	1
348	1620	20093	1
397	1650	20093	1
399	1652	20093	1
414	1696	20032	0.8125
415	1710	20042	0.789473712
415	1975	20091	0.600000024
415	2411	20101	0.600000024
416	1711	20042	0.5625
423	2318	20093	1
424	1817	20073	1
425	1799	20072	0.625
433	2327	20093	0.571428597
456	1963	20083	1
459	2030	20091	0.631578922
463	1968	20083	1
468	2353	20093	1
481	2335	20093	1
525	2373	20093	1
574	2403	20093	1
576	2405	20093	1
591	2463	20032	0.8125
592	2477	20042	0.789473712
592	2742	20091	0.600000024
592	3178	20101	0.600000024
593	2478	20042	0.5625
600	3085	20093	1
601	2584	20073	1
602	2566	20072	0.625
610	3094	20093	0.571428597
633	2730	20083	1
636	2797	20091	0.631578922
640	2735	20083	1
645	3120	20093	1
658	3102	20093	1
702	3140	20093	1
751	3170	20093	1
753	3172	20093	1
768	3230	20032	0.8125
769	3244	20042	0.789473712
769	3509	20091	0.600000024
769	3945	20101	0.600000024
770	3245	20042	0.5625
777	3852	20093	1
778	3351	20073	1
779	3333	20072	0.625
787	3861	20093	0.571428597
810	3497	20083	1
813	3564	20091	0.631578922
817	3502	20083	1
822	3887	20093	1
835	3869	20093	1
879	3907	20093	1
928	3937	20093	1
930	3939	20093	1
\.


--
-- Data for Name: eligpasshalfmathcs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligpasshalfmathcs (studentid, studenttermid, termid, failpercentage) FROM stdin;
23	88	20121	0.533333361
27	92	20121	1
49	144	20121	0.666666687
55	150	20121	0.533333361
57	156	20111	1
57	157	20112	1
58	163	20012	0.666666687
60	179	20032	0.823529422
62	193	20042	0.736842096
62	203	20051	0.666666687
63	194	20042	0.823529422
65	212	20052	0.625
65	220	20061	0.526315808
67	233	20062	0.625
68	223	20061	0.625
69	277	20072	0.647058845
70	278	20072	0.647058845
70	801	20093	1
71	300	20073	1
72	282	20072	0.699999988
73	279	20072	0.8125
75	283	20072	0.625
75	376	20082	0.571428597
78	262	20071	0.625
80	288	20072	0.625
81	289	20072	0.625
83	327	20081	0.526315808
90	392	20082	0.625
90	659	20092	0.666666687
91	493	20091	0.555555582
91	816	20093	1
95	500	20091	0.555555582
98	341	20081	0.625
99	401	20082	0.625
102	678	20092	0.666666687
103	446	20083	1
105	407	20082	0.625
105	681	20092	0.545454562
106	513	20091	0.666666687
107	350	20081	0.625
110	451	20083	1
115	836	20093	1
117	419	20082	0.625
120	363	20081	1
124	485	20091	0.625
125	653	20092	0.625
128	818	20093	1
148	543	20091	0.625
153	548	20091	0.625
154	719	20092	0.625
166	561	20091	0.625
172	567	20091	0.625
172	856	20093	1
188	753	20092	0.625
189	754	20092	0.625
205	600	20091	0.625
207	772	20092	0.625
209	774	20092	0.625
212	777	20092	0.625
216	781	20092	0.625
217	782	20092	0.625
221	616	20091	0.625
221	886	20093	1
223	888	20093	1
225	790	20092	1
227	792	20092	0.625
236	931	20012	0.666666687
238	946	20032	0.666666687
239	960	20042	1
240	961	20042	1
242	979	20052	0.625
242	987	20061	0.555555582
244	1000	20062	0.625
245	990	20061	0.625
246	1044	20072	0.666666687
247	1045	20072	0.666666687
247	1566	20093	1
249	1049	20072	0.666666687
250	1046	20072	1
252	1050	20072	0.625
255	1029	20071	0.625
257	1055	20072	0.625
258	1056	20072	0.625
260	1094	20081	0.555555582
267	1159	20082	0.625
267	1424	20092	0.666666687
268	1259	20091	0.555555582
268	1580	20093	1
272	1266	20091	0.555555582
275	1108	20081	0.625
276	1168	20082	0.625
279	1443	20092	0.666666687
280	1213	20083	1
282	1174	20082	0.625
282	1446	20092	0.545454562
283	1279	20091	0.666666687
284	1117	20081	0.625
287	1218	20083	1
292	1600	20093	1
294	1186	20082	0.625
297	1130	20081	1
301	1252	20091	0.625
304	1582	20093	1
324	1309	20091	0.625
329	1314	20091	0.625
330	1484	20092	0.625
342	1327	20091	0.625
348	1333	20091	0.625
348	1620	20093	1
364	1518	20092	0.625
365	1519	20092	0.625
381	1366	20091	0.625
383	1537	20092	0.625
385	1539	20092	0.625
388	1542	20092	0.625
392	1546	20092	0.625
393	1547	20092	0.625
397	1382	20091	0.625
397	1650	20093	1
399	1652	20093	1
401	1555	20092	1
403	1557	20092	0.625
414	1696	20032	0.666666687
415	1710	20042	1
416	1711	20042	1
418	1729	20052	0.625
418	1737	20061	0.555555582
420	1750	20062	0.625
421	1740	20061	0.625
422	1794	20072	0.666666687
423	1795	20072	0.666666687
423	2318	20093	1
425	1799	20072	0.666666687
426	1796	20072	1
428	1800	20072	0.625
431	1779	20071	0.625
433	1805	20072	0.625
434	1806	20072	0.625
436	1844	20081	0.555555582
443	1909	20082	0.625
443	2176	20092	0.666666687
444	2010	20091	0.555555582
444	2333	20093	1
448	2017	20091	0.555555582
451	1858	20081	0.625
452	1918	20082	0.625
455	2195	20092	0.666666687
456	1963	20083	1
458	1924	20082	0.625
458	2198	20092	0.545454562
459	2030	20091	0.666666687
460	1867	20081	0.625
463	1968	20083	1
468	2353	20093	1
470	1936	20082	0.625
473	1880	20081	1
477	2002	20091	0.625
478	2170	20092	0.625
481	2335	20093	1
501	2060	20091	0.625
506	2065	20091	0.625
507	2236	20092	0.625
519	2078	20091	0.625
525	2084	20091	0.625
525	2373	20093	1
541	2270	20092	0.625
542	2271	20092	0.625
558	2117	20091	0.625
560	2289	20092	0.625
562	2291	20092	0.625
565	2294	20092	0.625
569	2298	20092	0.625
570	2299	20092	0.625
574	2133	20091	0.625
574	2403	20093	1
576	2405	20093	1
578	2307	20092	1
580	2309	20092	0.625
589	2448	20012	0.666666687
591	2463	20032	0.666666687
592	2477	20042	1
593	2478	20042	1
595	2496	20052	0.625
595	2504	20061	0.555555582
597	2517	20062	0.625
598	2507	20061	0.625
599	2561	20072	0.666666687
600	2562	20072	0.666666687
600	3085	20093	1
602	2566	20072	0.666666687
603	2563	20072	1
605	2567	20072	0.625
608	2546	20071	0.625
610	2572	20072	0.625
611	2573	20072	0.625
613	2611	20081	0.555555582
620	2676	20082	0.625
620	2943	20092	0.666666687
621	2777	20091	0.555555582
621	3100	20093	1
625	2784	20091	0.555555582
628	2625	20081	0.625
629	2685	20082	0.625
632	2962	20092	0.666666687
633	2730	20083	1
635	2691	20082	0.625
635	2965	20092	0.545454562
636	2797	20091	0.666666687
637	2634	20081	0.625
640	2735	20083	1
645	3120	20093	1
647	2703	20082	0.625
650	2647	20081	1
654	2769	20091	0.625
655	2937	20092	0.625
658	3102	20093	1
678	2827	20091	0.625
683	2832	20091	0.625
684	3003	20092	0.625
696	2845	20091	0.625
702	2851	20091	0.625
702	3140	20093	1
718	3037	20092	0.625
719	3038	20092	0.625
735	2884	20091	0.625
737	3056	20092	0.625
739	3058	20092	0.625
742	3061	20092	0.625
746	3065	20092	0.625
747	3066	20092	0.625
751	2900	20091	0.625
751	3170	20093	1
753	3172	20093	1
755	3074	20092	1
757	3076	20092	0.625
766	3215	20012	0.666666687
768	3230	20032	0.666666687
769	3244	20042	1
770	3245	20042	1
772	3263	20052	0.625
772	3271	20061	0.555555582
774	3284	20062	0.625
775	3274	20061	0.625
776	3328	20072	0.666666687
777	3329	20072	0.666666687
777	3852	20093	1
779	3333	20072	0.666666687
780	3330	20072	1
782	3334	20072	0.625
785	3313	20071	0.625
787	3339	20072	0.625
788	3340	20072	0.625
790	3378	20081	0.555555582
797	3443	20082	0.625
797	3710	20092	0.666666687
798	3544	20091	0.555555582
798	3867	20093	1
802	3551	20091	0.555555582
805	3392	20081	0.625
806	3452	20082	0.625
809	3729	20092	0.666666687
810	3497	20083	1
812	3458	20082	0.625
812	3732	20092	0.545454562
813	3564	20091	0.666666687
814	3401	20081	0.625
817	3502	20083	1
822	3887	20093	1
824	3470	20082	0.625
827	3414	20081	1
831	3536	20091	0.625
832	3704	20092	0.625
835	3869	20093	1
855	3594	20091	0.625
860	3599	20091	0.625
861	3770	20092	0.625
873	3612	20091	0.625
879	3618	20091	0.625
879	3907	20093	1
895	3804	20092	0.625
896	3805	20092	0.625
912	3651	20091	0.625
914	3823	20092	0.625
916	3825	20092	0.625
919	3828	20092	0.625
923	3832	20092	0.625
924	3833	20092	0.625
928	3667	20091	0.625
928	3937	20093	1
930	3939	20093	1
932	3841	20092	1
934	3843	20092	0.625
\.


--
-- Data for Name: eligtwicefail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligtwicefail (studentid, classid, courseid, section, coursename, termid) FROM stdin;
57	92	3	THU	CS 21	20111
57	94	3	THU	CS 21	20121
57	91	106	THU	Math 17	20111
57	93	106	THU	Math 17	20121
60	985	109	TFV1	Math 55	20032
60	191	109	MTHFV	Math 55	20032
62	1013	109	TFU2	Math 55	20042
62	281	109	MTHFI	Math 55	20051
72	554	109	MTHFQ	Math 55	20072
72	1172	109	MHW1	Math 55	20072
75	1182	107	MTHFW4	Math 53	20072
75	858	107	THR1	Math 53	20082
115	1835	5	WFU	CS 32	20092
115	2190	5	X	CS 32	20093
292	1835	5	WFU	CS 32	20092
292	2190	5	X	CS 32	20093
468	1835	5	WFU	CS 32	20092
468	2190	5	X	CS 32	20093
645	1835	5	WFU	CS 32	20092
645	2190	5	X	CS 32	20093
822	1835	5	WFU	CS 32	20092
822	2190	5	X	CS 32	20093
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
2	1	1
3	2	2
4	3	3
5	4	4
6	5	5
7	6	6
8	7	7
9	8	8
10	9	9
11	10	10
12	11	1
13	12	2
14	13	3
15	14	4
16	15	5
17	16	6
18	17	7
19	18	8
20	19	9
21	20	10
22	21	1
23	22	2
24	23	3
25	24	4
26	25	5
27	26	6
28	27	7
29	28	8
30	29	9
31	30	10
32	31	1
33	32	1
34	33	1
35	34	1
36	35	1
37	36	1
38	37	10
39	38	10
40	39	10
41	40	10
42	41	10
43	42	10
44	43	1
45	44	2
46	45	3
47	46	1
48	47	1
49	48	1
50	49	5
51	50	6
52	51	7
53	52	8
54	53	9
55	54	10
56	55	1
57	56	2
58	57	3
59	58	1
60	59	2
61	60	3
62	61	1
63	62	1
64	63	1
65	64	5
66	65	6
67	66	7
68	67	8
69	68	9
70	69	10
71	70	1
72	71	2
73	72	3
74	73	10
75	74	10
76	75	10
77	76	4
78	77	5
79	68	1
80	69	2
81	70	3
82	71	4
83	72	5
84	73	6
85	74	7
86	75	8
87	76	9
88	77	10
89	78	1
90	79	2
91	80	3
92	81	4
93	82	1
94	83	1
95	84	1
\.


--
-- Data for Name: instructors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY instructors (instructorid, personid) FROM stdin;
1	41
2	42
3	43
4	44
5	45
6	46
7	47
8	48
9	49
10	50
\.


--
-- Data for Name: persons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY persons (personid, lastname, firstname, middlename, pedigree) FROM stdin;
1	Balatico	Juan Carlito	Sales	
2	Quilala	Magdalena Marie	Aquilina	
3	Terrado	Ramon Bienvenido	Ispado	Jr.
4	Kilayko	Evangeline Donita	Pilar	
5	Cutiongco	Honey Girl	Lim	
6	Orongan	Christina Maria	Coral	
7	Castillote	Aileen Kristina	Esteban	
8	Balandra	Gomburza Carlos	Matalino	
9	Cabrera	Ferdinand Jose	Manalo	
10	Balandra	Gomburza Carmelos	Matapang	
11	Reyes	Ernesto Miguel	Contreras	Jr.
12	Torrente	Raymundo Jun-jun	Santos	III
13	Meren	Gil Troy	Mercado	
14	Cortez	Marie Janelle	Sy	
15	Tenor	Karol Kyle	Perez	
16	Sopran	Victoria	Reyes	
17	Bassdar	Ana Marie	Magof	
18	Altolen	Helena	Baradas	
19	Oreomen	Helena	Mariote	
20	Quakerate	Mila	Abad	
21	Caramelo	Delena	Sy	
22	Mintyna	Haru	Lim	
23	Raspberus	Nicole	Chua	
24	Milkire	Mary	Co	
25	Santos	Ren	Kho	
26	Torres	Tristan	Nagoya	
27	Evangelista	Samantha	Shizuku	
28	Festin	Miguel	Oshima	
29	Reyes	Emmanuel	Delos Santos	
30	Forbes	Aaron	Santos	
31	Ompoy	Ray	Santos	
32	Mazo	Joshua	Gillen	
33	Barboza	Jose Elijah	Cruz	
34	Angeles	Flor Marie	Santos	
35	Cordevilla	Julia	Abante	
36	Rodriguez	Nina Baz	Reyes	
37	Soriano	Jayson	Morales	
38	Chiu	Kim Marie	Sy	
39	Flores	Harold	Teh	
40	Encarnacion	Marie Nina	Santos	
41	Agapito	Judd	Alistaire	
42	Bautista	Misael	Gustav	
43	Dela Cruz	Marife	Orias	
44	Adelantar	Mary Anne	Santos	
45	Galang	Pauline Marie	Cayetano	
46	Sales	Venilda	Mendoza	
47	Cayetano	Mar	Roxas	
48	Aquino	Melody	Co	
49	Vera	Heart	Cruz	
50	Fabella	Edgar	Sigid	
51	Gutierrez	Harold	Uy	
52	Perez	Kazzandra	Gregorio	
53	Tan	Maureen	Chu	
54	Olleres	Joy	Florendo	
55	Tamang	Pinky	Garcia	
56	Mendoza	Christopher	Chan	
57	Ferrer	Joseph	Buan	
58	Torio	Benjamin	Macalanda	
59	Miranda	Delilah	De Peralta	
60	Martin	Oliver	Santos	
61	Epler	Jay	Bayquen	
62	Ocampo	Esther	Brown	
63	Queri	Anne	Cicat	
64	Anyayahan	Shekinah	Soto	
65	Malapit	Michael	Tiong	
66	Dela Cruz	Tristan	Agapito	\N
67	Barbera	Krizia	Gedrot	\N
68	ORENSE	ADRIAN	CORDOVA	
69	VILLARANTE	JAY RICKY	BARRAMEDA	
70	LUMONGSOD	PIO RYAN	SAGARINO	
71	dela Cruz	Juan	Reyes	
72	TOBIAS	GEORGE HELAMAN	ASTURIAS	
73	CUNANAN	JENNIFER	DELA CRUZ	
74	RAGASA	ROGER JOHN	ESTEPA	
75	MARANAN	KERVIN	CATUNGAL	
76	DEINLA	REGINALD ELI	ATIENZA	
77	RAMIREZ	NORBERTO	ALLAREY	II
78	PUGAL	EDGAR	STA BARBARA	JR
79	JOVEN	KATHLEEN GRACE	GUERRERO	
80	ESCALANTE	ED ALBERT	BELARGO	
81	CONTRERAS	PAUL VINCENT	SALES	
82	DIRECTO	KAREIN JOY	TOLENTINO	
83	VALLO	LOVELIA	LAROCO	
84	DOMINGO	CYROD JOHN	FLORIDA	
85	SUBA	KEVIN RAINIER	SINOGAYA	
86	CATAJOY	VINCENT NICHOLAS	RANA	
87	BATANES	BRYAN MATTHEW	AVENDANO	
88	BALAGAPO	JOSHUA	KHO	
89	DOMANTAY	ERIC	AMPARO	JR
90	JAVIER	JEWEL LEX	TONG	
91	JUAT	WESLEY	MENDOZA	
92	ISIDRO	HOMER IRIC	SANTOS	
93	VILLANUEVA	MARIANNE ANGELIE	OCAMPO	
94	MAMARIL	VIC ANGELO	DELOS SANTOS	
95	ARANA	RYAN KRISTOFER	IGMAT	
96	NICOLAS	DANA ELISA	GAGALAC	
97	VACALARES	ISAIAH JAMES	VALDES	
98	SANTILLAN	MA CECILIA		
99	PINEDA	JAKE ERICKSON	BOTEROS	
100	LOYOLA	ELIZABETH	CUETO	
101	BUGAOAN	FRANCIS KEVIN	ALIMORONG	
102	GALLARDO	FRANCIS JOMER	DE LEON	
103	ARGARIN	MICHAEL ERICK	STA TERESA	
104	VILLARUZ	JULIAN	CASTILLO	
105	FRANCISCO	ARMINA	EUGENIO	
106	AQUINO	JOSEPH ARMAN	BONGCO	
107	AME	MARTIN ROMAN LORENZO	ILAGAN	
108	CELEDONIO	MESSIAH JAN	LEBID	
109	SABIDONG	JEROME	RONCESVALLES	
110	FLORENCIO	JOHN CARLO	MAQUILAN	
111	EPISTOLA	SILVEN VICTOR	DUMALAG	
112	SANTOS	JOHN ISRAEL	LORENZO	
113	SANTOS	MARIE JUNNE	CABRAL	
114	FABIC	JULIAN NICHOLAS	REYES	
115	TORRES	ERIC	TUQUERO	
116	CUETO	BENJAMIN	ANGELES	JR
117	PASCUAL	JEANELLA KLARYS	ESPIRITU	
118	GAMBA	JOSE NOEL	CARDONES	
119	REFAMONTE	JARED	MUMAR	
120	BARITUA	KARESSA ALEXANDRA	ONG	
121	SEMILLA	STANLEY	TINA	
122	ANGELES	MARC ARTHUR	PAJE	
123	SORIAO	HANS CHRISTIAN	BALTAZAR	
124	DINO	ARVIN	PABINES	
125	MORALES	NOELYN JOYCE	ROL	
126	MANALAC	DAVID ROBIN	MANALAC	
127	SAY	KOHLEN ANGELO	PEREZ	
128	ADRIANO	JAMES PATRICK	DAVID	
129	SERRANO	MICHAEL	DIONISIO	
130	CHOAPECK	MARIE ANTOINETTE	R	
131	TURLA	ISAIAH EDWARD	G	
132	MONCADA	DEAN ALVIN	BAJAMONDE	
133	EVANGELISTA	JOHN EROL	MILANO	
134	ASIS	KRYSTIAN VIEL	CABUGAO	
135	CLAVECILLA	VANESSA VIVIEN	FRANCISCO	
136	RONDON	RYAN ODYLON	GAZMEN	
137	ARANAS	CHRISTIAN JOY	MARQUEZ	
138	AGUILAR	JENNIFER	RAMOS	
139	CUEVAS	SARAH	BERNABE	
140	PASCUAL	JAYVEE ELJOHN	ACABO	
141	TORRES	DANAH VERONICA	PADILLA	
142	BISAIS	APRYL ROSE	LABAYOG	
143	CHUA	TED GUILLANO	SY	
144	CRUZ	IVAN KRISTEL	POLICARPIO	
145	AQUINO	CHLOEBELLE	RAMOS	
146	YUTUC	DANIEL	LALAGUNA	
147	DEL ROSARIO	BENJIE	REYES	
148	RAMOS	ANNA CLARISSA	BEATO	
149	REYES	CHARMAILENE	CAPILI	
150	ABANTO	JEANELLE	ESGUERRA	
151	BONDOC	ROD XANDER	RIVERA	
152	TACATA	NERISSA MONICA	DE GUZMAN	
153	RABE	REZELEE	AQUINO	
154	DECENA	BERLYN ANNE	ARAGON	
155	DIMLA	KARL LEN MAE	BALDOMERO	
156	SANCHEZ	ZIV YVES	MONTOYA	
157	LITIMCO	CZELINA ELLAINE	ONG	
158	GUILLEN	NEIL DAVID	BALGOS	
159	SOMOSON	LOU MERLENETTE	BAUTISTA	
160	TALAVERA	RHIZA MAE	GO	
161	CANOY	JOHN GABRIEL	ERUM	
162	CHUA	RALPH JACOB	ANG	
163	EALA	MARIA AZRIEL THERESE	DESTUA	
164	AYAG	DANIELLE ANNE	FRANCISCO	
165	DE VILLA	RACHEL	LUNA	
166	JAYMALIN	JEAN DOMINIQUE	BERNAL	
167	LEGASPI	CHARMAINE PAMELA	ABERCA	
168	LIBUNAO	ARIANNE FRANCESCA	QUIJANO	
169	REGENCIA	FELIX ARAM	JEREMIAS	
170	SANTI	NATHAN LEMUEL	GO	
171	LEONOR	WENDY GENEVA	SANTOS	
172	LUNA	MARA ISSABEL	SUPLICO	
173	SIRIBAN	MA LORENA JOY	ASCUTIA	
174	LEGASPI	MISHAEL MAE	CRUZ	
175	SUN	HANNAH ERIKA	YAP	
176	PARRENO	NICOLE ANNE	KAHN	
177	BULANHAGUI	KEVIN DAVID	BALANAY	
178	MONCADA	JULIA NINA	SOMERA	
179	IBANEZ	SEBASTIAN	CANLAS	
180	COLA	VERNA KATRIN	BEDUYA	
181	SANTOS	MARIA RUBYLISA	AREVALO	
182	YECLA	NORVIN	GARCIA	
183	CASTANEDA	ANNA MANNELLI	ESPIRITU	
184	FOJAS	EDGAR ALLAN	GO	
185	DELA CRUZ	EMERY	FABRO	
186	SADORNAS	JON PERCIVAL	GARCIA	
187	VILLANUEVA	MARY GRACE	AYENTO	
188	ESGUERRA	JOSE MARI	MARCELO	
189	SY	KYLE BENEDICT	GUERRERO	
190	TORRES	LUIS ANTONIO	PEREZ	
191	TONG	MAYNARD JEFFERSON	ZHUANG	
192	DATU	PATRICH PAOLO	BONETE	
193	PEREA	EMMANUEL	LOYOLA	
194	BALOY	MICHAEL JOYSON	GERMAR	
195	REAL	VICTORIA CASSANDRA	RUIVIVAR	
196	MARTIJA	JASPER	ENRIQUEZ	
197	OCHAVEZ	ARISA	CAAKBAY	
198	AMORANTO	PAOLO	SISON	
199	SAN ANTONIO	JAYVIC	PORTILLO	
200	SARDONA	CATHERINE LORAINE	FESTIN	
201	MENESES	ANGELO	CAL	
202	AUSTRIA	DARRWIN DEAREST	CRISOSTOMO	
203	BURGOS	ALVIN JOHN	MANLIGUEZ	
204	MAGNO	JENNY	NARSOLIS	
205	SAPASAP	RIC JANUS	OLIVER	
206	QUILAB	FRANCIS MIGUEL	EVANGELISTA	
207	PINEDA	RIZA RAE	ALDECOA	
208	TAN	XYRIZ CZAR	PINEDA	
209	DELAS PENAS	KRISTOFER	EMPUERTO	
210	MANSOS	JOHN FRANCIS	LLAGAS	
211	PANOPIO	GIRAH MAY	CHUA	
212	LEGASPINA	CHRISLENE	BUGARIN	
213	RIVERA	DON JOSEPH	TIANGCO	
214	RUBIO	MARY GRACE	TALAN	
215	LEONOR	CHARLES TIMOTHY	DEL ROSARIO	
216	CABUHAT	JOHN JOEL	URBISTONDO	
217	MARANAN	GENIE LINN	PADILLA	
218	WANG	CASSANDRA LEIGH	LACASTA	
219	YU	GLADYS JOYCE	OCAP	
220	TOMACRUZ	ARVIN JOHN	CRUZ	
221	BALDUEZA	GYZELLE	EVANGELISTA	
222	BATAC	JOSE EMMANUEL	DE JESUS	
223	CUETO	JAN COLIN	OJEDA	
224	RUBI	SHIELA PAULINE JOY	VERGARA	
225	ALCARAZ	KEN GERARD	TECSON	
226	DE LOS SANTOS	PAOLO MIGUEL	MACALINDONG	
227	CHAVEZ	JOE-MAR	ORINDAY	
228	PERALTA	PAOLO THOMAS	REYES	
229	SANTOS	ALEXANDREI	GONZALES	
230	MACAPINLAC	VERONICA	ALCARAZ	
231	PACAPAC	DIANA MAE	CANLAS	
232	DUNGCA	JOHN ALPERT	ANCHO	
233	ZACARIAS	ROEL JEREMIAH	ALCANTARA	
234	RICIO	DUSTIN EDRIC	LEGARDA	
235	ARBAS	HARVEY IAN	SOLAYAO	
236	SALVADOR	RAMON JOSE NILO	DELA VEGA	
237	DORADO	JOHN PHILIP	URRIZA	
238	DEATRAS	SHEALTIEL PAUL ROSSNERR	CALUAG	
239	CAPACILLO	JULES ALBERT	BERINGUELA	
240	SALAMANCA	KYLA MARIE	G.	
241	AVE	ARMOND	C.	
242	CALARANAN	MICHAEL KEVIN	PONTE	
243	DOCTOR	JET LAWRENCE	PARONE	
244	ANG	RITZ DANIEL	CATAMPATAN	
245	FORMES	RAFAEL GERARD	DELA CRUZ	
246	CLAVECILLA	ADRIAN	CORDOVA	
247	CLAVECILLA	JAY RICKY	BARRAMEDA	
248	CLAVECILLA	PIO RYAN	SAGARINO	
249	CLAVECILLA	GEORGE HELAMAN	ASTURIAS	
250	CLAVECILLA	JENNIFER	DELA CRUZ	
251	CLAVECILLA	ROGER JOHN	ESTEPA	
252	CLAVECILLA	KERVIN	CATUNGAL	
253	CLAVECILLA	REGINALD ELI	ATIENZA	
254	CLAVECILLA	NORBERTO	ALLAREY	II
255	CLAVECILLA	EDGAR	STA BARBARA	JR
256	CLAVECILLA	KATHLEEN GRACE	GUERRERO	
257	CLAVECILLA	ED ALBERT	BELARGO	
258	CLAVECILLA	PAUL VINCENT	SALES	
259	CLAVECILLA	KAREIN JOY	TOLENTINO	
260	CLAVECILLA	LOVELIA	LAROCO	
261	CLAVECILLA	CYROD JOHN	FLORIDA	
262	CLAVECILLA	KEVIN RAINIER	SINOGAYA	
263	CLAVECILLA	VINCENT NICHOLAS	RANA	
264	CLAVECILLA	BRYAN MATTHEW	AVENDANO	
265	CLAVECILLA	JOSHUA	KHO	
266	CLAVECILLA	ERIC	AMPARO	JR
267	CLAVECILLA	JEWEL LEX	TONG	
268	CLAVECILLA	WESLEY	MENDOZA	
269	CLAVECILLA	HOMER IRIC	SANTOS	
270	CLAVECILLA	MARIANNE ANGELIE	OCAMPO	
271	CLAVECILLA	VIC ANGELO	DELOS SANTOS	
272	CLAVECILLA	RYAN KRISTOFER	IGMAT	
273	CLAVECILLA	DANA ELISA	GAGALAC	
274	CLAVECILLA	ISAIAH JAMES	VALDES	
275	CLAVECILLA	MA CECILIA		
276	CLAVECILLA	JAKE ERICKSON	BOTEROS	
277	CLAVECILLA	ELIZABETH	CUETO	
278	CLAVECILLA	FRANCIS KEVIN	ALIMORONG	
279	CLAVECILLA	FRANCIS JOMER	DE LEON	
280	CLAVECILLA	MICHAEL ERICK	STA TERESA	
281	CLAVECILLA	JULIAN	CASTILLO	
282	CLAVECILLA	ARMINA	EUGENIO	
283	CLAVECILLA	JOSEPH ARMAN	BONGCO	
284	CLAVECILLA	MARTIN ROMAN LORENZO	ILAGAN	
285	CLAVECILLA	MESSIAH JAN	LEBID	
286	CLAVECILLA	JEROME	RONCESVALLES	
287	CLAVECILLA	JOHN CARLO	MAQUILAN	
288	CLAVECILLA	SILVEN VICTOR	DUMALAG	
289	CLAVECILLA	JOHN ISRAEL	LORENZO	
290	CLAVECILLA	MARIE JUNNE	CABRAL	
291	CLAVECILLA	JULIAN NICHOLAS	REYES	
292	CLAVECILLA	ERIC	TUQUERO	
293	CLAVECILLA	BENJAMIN	ANGELES	JR
294	CLAVECILLA	JEANELLA KLARYS	ESPIRITU	
295	CLAVECILLA	JOSE NOEL	CARDONES	
296	CLAVECILLA	JARED	MUMAR	
297	CLAVECILLA	KARESSA ALEXANDRA	ONG	
298	CLAVECILLA	STANLEY	TINA	
299	CLAVECILLA	MARC ARTHUR	PAJE	
300	CLAVECILLA	HANS CHRISTIAN	BALTAZAR	
301	CLAVECILLA	ARVIN	PABINES	
302	CLAVECILLA	NOELYN JOYCE	ROL	
303	CLAVECILLA	DAVID ROBIN	MANALAC	
304	CLAVECILLA	KOHLEN ANGELO	PEREZ	
305	CLAVECILLA	JAMES PATRICK	DAVID	
306	CLAVECILLA	MICHAEL	DIONISIO	
307	CLAVECILLA	MARIE ANTOINETTE	R	
308	CLAVECILLA	ISAIAH EDWARD	G	
309	CLAVECILLA	DEAN ALVIN	BAJAMONDE	
310	CLAVECILLA	JOHN EROL	MILANO	
311	CLAVECILLA	KRYSTIAN VIEL	CABUGAO	
312	CLAVECILLA	RYAN ODYLON	GAZMEN	
313	CLAVECILLA	CHRISTIAN JOY	MARQUEZ	
314	CLAVECILLA	JENNIFER	RAMOS	
315	CLAVECILLA	SARAH	BERNABE	
316	CLAVECILLA	JAYVEE ELJOHN	ACABO	
317	CLAVECILLA	DANAH VERONICA	PADILLA	
318	CLAVECILLA	APRYL ROSE	LABAYOG	
319	CLAVECILLA	TED GUILLANO	SY	
320	CLAVECILLA	IVAN KRISTEL	POLICARPIO	
321	CLAVECILLA	CHLOEBELLE	RAMOS	
322	CLAVECILLA	DANIEL	LALAGUNA	
323	CLAVECILLA	BENJIE	REYES	
324	CLAVECILLA	ANNA CLARISSA	BEATO	
325	CLAVECILLA	CHARMAILENE	CAPILI	
326	CLAVECILLA	JEANELLE	ESGUERRA	
327	CLAVECILLA	ROD XANDER	RIVERA	
328	CLAVECILLA	NERISSA MONICA	DE GUZMAN	
329	CLAVECILLA	REZELEE	AQUINO	
330	CLAVECILLA	BERLYN ANNE	ARAGON	
331	CLAVECILLA	KARL LEN MAE	BALDOMERO	
332	CLAVECILLA	ZIV YVES	MONTOYA	
333	CLAVECILLA	CZELINA ELLAINE	ONG	
334	CLAVECILLA	NEIL DAVID	BALGOS	
335	CLAVECILLA	LOU MERLENETTE	BAUTISTA	
336	CLAVECILLA	RHIZA MAE	GO	
337	CLAVECILLA	JOHN GABRIEL	ERUM	
338	CLAVECILLA	RALPH JACOB	ANG	
339	CLAVECILLA	MARIA AZRIEL THERESE	DESTUA	
340	CLAVECILLA	DANIELLE ANNE	FRANCISCO	
341	CLAVECILLA	RACHEL	LUNA	
342	CLAVECILLA	JEAN DOMINIQUE	BERNAL	
343	CLAVECILLA	CHARMAINE PAMELA	ABERCA	
344	CLAVECILLA	ARIANNE FRANCESCA	QUIJANO	
345	CLAVECILLA	FELIX ARAM	JEREMIAS	
346	CLAVECILLA	NATHAN LEMUEL	GO	
347	CLAVECILLA	WENDY GENEVA	SANTOS	
348	CLAVECILLA	MARA ISSABEL	SUPLICO	
349	CLAVECILLA	MA LORENA JOY	ASCUTIA	
350	CLAVECILLA	MISHAEL MAE	CRUZ	
351	CLAVECILLA	HANNAH ERIKA	YAP	
352	CLAVECILLA	NICOLE ANNE	KAHN	
353	CLAVECILLA	KEVIN DAVID	BALANAY	
354	CLAVECILLA	JULIA NINA	SOMERA	
355	CLAVECILLA	SEBASTIAN	CANLAS	
356	CLAVECILLA	VERNA KATRIN	BEDUYA	
357	CLAVECILLA	MARIA RUBYLISA	AREVALO	
358	CLAVECILLA	NORVIN	GARCIA	
359	CLAVECILLA	ANNA MANNELLI	ESPIRITU	
360	CLAVECILLA	EDGAR ALLAN	GO	
361	CLAVECILLA	EMERY	FABRO	
362	CLAVECILLA	JON PERCIVAL	GARCIA	
363	CLAVECILLA	MARY GRACE	AYENTO	
364	CLAVECILLA	JOSE MARI	MARCELO	
365	CLAVECILLA	KYLE BENEDICT	GUERRERO	
366	CLAVECILLA	LUIS ANTONIO	PEREZ	
367	CLAVECILLA	MAYNARD JEFFERSON	ZHUANG	
368	CLAVECILLA	PATRICH PAOLO	BONETE	
369	CLAVECILLA	EMMANUEL	LOYOLA	
370	CLAVECILLA	MICHAEL JOYSON	GERMAR	
371	CLAVECILLA	VICTORIA CASSANDRA	RUIVIVAR	
372	CLAVECILLA	JASPER	ENRIQUEZ	
373	CLAVECILLA	ARISA	CAAKBAY	
374	CLAVECILLA	PAOLO	SISON	
375	CLAVECILLA	JAYVIC	PORTILLO	
376	CLAVECILLA	CATHERINE LORAINE	FESTIN	
377	CLAVECILLA	ANGELO	CAL	
378	CLAVECILLA	DARRWIN DEAREST	CRISOSTOMO	
379	CLAVECILLA	ALVIN JOHN	MANLIGUEZ	
380	CLAVECILLA	JENNY	NARSOLIS	
381	CLAVECILLA	RIC JANUS	OLIVER	
382	CLAVECILLA	FRANCIS MIGUEL	EVANGELISTA	
383	CLAVECILLA	RIZA RAE	ALDECOA	
384	CLAVECILLA	XYRIZ CZAR	PINEDA	
385	CLAVECILLA	KRISTOFER	EMPUERTO	
386	CLAVECILLA	JOHN FRANCIS	LLAGAS	
387	CLAVECILLA	GIRAH MAY	CHUA	
388	CLAVECILLA	CHRISLENE	BUGARIN	
389	CLAVECILLA	DON JOSEPH	TIANGCO	
390	CLAVECILLA	MARY GRACE	TALAN	
391	CLAVECILLA	CHARLES TIMOTHY	DEL ROSARIO	
392	CLAVECILLA	JOHN JOEL	URBISTONDO	
393	CLAVECILLA	GENIE LINN	PADILLA	
394	CLAVECILLA	CASSANDRA LEIGH	LACASTA	
395	CLAVECILLA	GLADYS JOYCE	OCAP	
396	CLAVECILLA	ARVIN JOHN	CRUZ	
397	CLAVECILLA	GYZELLE	EVANGELISTA	
398	CLAVECILLA	JOSE EMMANUEL	DE JESUS	
399	CLAVECILLA	JAN COLIN	OJEDA	
400	CLAVECILLA	SHIELA PAULINE JOY	VERGARA	
401	CLAVECILLA	KEN GERARD	TECSON	
402	CLAVECILLA	PAOLO MIGUEL	MACALINDONG	
403	CLAVECILLA	JOE-MAR	ORINDAY	
404	CLAVECILLA	PAOLO THOMAS	REYES	
405	CLAVECILLA	ALEXANDREI	GONZALES	
406	CLAVECILLA	VERONICA	ALCARAZ	
407	CLAVECILLA	DIANA MAE	CANLAS	
408	CLAVECILLA	JOHN ALPERT	ANCHO	
409	CLAVECILLA	ROEL JEREMIAH	ALCANTARA	
410	CLAVECILLA	DUSTIN EDRIC	LEGARDA	
411	CLAVECILLA	HARVEY IAN	SOLAYAO	
412	CLAVECILLA	RAMON JOSE NILO	DELA VEGA	
413	CLAVECILLA	JOHN PHILIP	URRIZA	
414	CLAVECILLA	SHEALTIEL PAUL ROSSNERR	CALUAG	
415	CLAVECILLA	JULES ALBERT	BERINGUELA	
416	CLAVECILLA	KYLA MARIE	G.	
417	CLAVECILLA	ARMOND	C.	
418	CLAVECILLA	MICHAEL KEVIN	PONTE	
419	CLAVECILLA	JET LAWRENCE	PARONE	
420	CLAVECILLA	RITZ DANIEL	CATAMPATAN	
421	CLAVECILLA	RAFAEL GERARD	DELA CRUZ	
422	DAVADILLA	ADRIAN	CORDOVA	
423	DAVADILLA	JAY RICKY	BARRAMEDA	
424	DAVADILLA	PIO RYAN	SAGARINO	
425	DAVADILLA	GEORGE HELAMAN	ASTURIAS	
426	DAVADILLA	JENNIFER	DELA CRUZ	
427	DAVADILLA	ROGER JOHN	ESTEPA	
428	DAVADILLA	KERVIN	CATUNGAL	
429	DAVADILLA	REGINALD ELI	ATIENZA	
430	DAVADILLA	NORBERTO	ALLAREY	II
431	DAVADILLA	EDGAR	STA BARBARA	JR
432	DAVADILLA	KATHLEEN GRACE	GUERRERO	
433	DAVADILLA	ED ALBERT	BELARGO	
434	DAVADILLA	PAUL VINCENT	SALES	
435	DAVADILLA	KAREIN JOY	TOLENTINO	
436	DAVADILLA	LOVELIA	LAROCO	
437	DAVADILLA	CYROD JOHN	FLORIDA	
438	DAVADILLA	KEVIN RAINIER	SINOGAYA	
439	DAVADILLA	VINCENT NICHOLAS	RANA	
440	DAVADILLA	BRYAN MATTHEW	AVENDANO	
441	DAVADILLA	JOSHUA	KHO	
442	DAVADILLA	ERIC	AMPARO	JR
443	DAVADILLA	JEWEL LEX	TONG	
444	DAVADILLA	WESLEY	MENDOZA	
445	DAVADILLA	HOMER IRIC	SANTOS	
446	DAVADILLA	MARIANNE ANGELIE	OCAMPO	
447	DAVADILLA	VIC ANGELO	DELOS SANTOS	
448	DAVADILLA	RYAN KRISTOFER	IGMAT	
449	DAVADILLA	DANA ELISA	GAGALAC	
450	DAVADILLA	ISAIAH JAMES	VALDES	
451	DAVADILLA	MA CECILIA		
452	DAVADILLA	JAKE ERICKSON	BOTEROS	
453	DAVADILLA	ELIZABETH	CUETO	
454	DAVADILLA	FRANCIS KEVIN	ALIMORONG	
455	DAVADILLA	FRANCIS JOMER	DE LEON	
456	DAVADILLA	MICHAEL ERICK	STA TERESA	
457	DAVADILLA	JULIAN	CASTILLO	
458	DAVADILLA	ARMINA	EUGENIO	
459	DAVADILLA	JOSEPH ARMAN	BONGCO	
460	DAVADILLA	MARTIN ROMAN LORENZO	ILAGAN	
461	DAVADILLA	MESSIAH JAN	LEBID	
462	DAVADILLA	JEROME	RONCESVALLES	
463	DAVADILLA	JOHN CARLO	MAQUILAN	
464	DAVADILLA	SILVEN VICTOR	DUMALAG	
465	DAVADILLA	JOHN ISRAEL	LORENZO	
466	DAVADILLA	MARIE JUNNE	CABRAL	
467	DAVADILLA	JULIAN NICHOLAS	REYES	
468	DAVADILLA	ERIC	TUQUERO	
469	DAVADILLA	BENJAMIN	ANGELES	JR
470	DAVADILLA	JEANELLA KLARYS	ESPIRITU	
471	DAVADILLA	JOSE NOEL	CARDONES	
472	DAVADILLA	JARED	MUMAR	
473	DAVADILLA	KARESSA ALEXANDRA	ONG	
474	DAVADILLA	STANLEY	TINA	
475	DAVADILLA	MARC ARTHUR	PAJE	
476	DAVADILLA	HANS CHRISTIAN	BALTAZAR	
477	DAVADILLA	ARVIN	PABINES	
478	DAVADILLA	NOELYN JOYCE	ROL	
479	DAVADILLA	DAVID ROBIN	MANALAC	
480	DAVADILLA	KOHLEN ANGELO	PEREZ	
481	DAVADILLA	JAMES PATRICK	DAVID	
482	DAVADILLA	MICHAEL	DIONISIO	
483	DAVADILLA	MARIE ANTOINETTE	R	
484	DAVADILLA	ISAIAH EDWARD	G	
485	DAVADILLA	DEAN ALVIN	BAJAMONDE	
486	DAVADILLA	JOHN EROL	MILANO	
487	DAVADILLA	KRYSTIAN VIEL	CABUGAO	
488	DAVADILLA	VANESSA VIVIEN	FRANCISCO	
489	DAVADILLA	RYAN ODYLON	GAZMEN	
490	DAVADILLA	CHRISTIAN JOY	MARQUEZ	
491	DAVADILLA	JENNIFER	RAMOS	
492	DAVADILLA	SARAH	BERNABE	
493	DAVADILLA	JAYVEE ELJOHN	ACABO	
494	DAVADILLA	DANAH VERONICA	PADILLA	
495	DAVADILLA	APRYL ROSE	LABAYOG	
496	DAVADILLA	TED GUILLANO	SY	
497	DAVADILLA	IVAN KRISTEL	POLICARPIO	
498	DAVADILLA	CHLOEBELLE	RAMOS	
499	DAVADILLA	DANIEL	LALAGUNA	
500	DAVADILLA	BENJIE	REYES	
501	DAVADILLA	ANNA CLARISSA	BEATO	
502	DAVADILLA	CHARMAILENE	CAPILI	
503	DAVADILLA	JEANELLE	ESGUERRA	
504	DAVADILLA	ROD XANDER	RIVERA	
505	DAVADILLA	NERISSA MONICA	DE GUZMAN	
506	DAVADILLA	REZELEE	AQUINO	
507	DAVADILLA	BERLYN ANNE	ARAGON	
508	DAVADILLA	KARL LEN MAE	BALDOMERO	
509	DAVADILLA	ZIV YVES	MONTOYA	
510	DAVADILLA	CZELINA ELLAINE	ONG	
511	DAVADILLA	NEIL DAVID	BALGOS	
512	DAVADILLA	LOU MERLENETTE	BAUTISTA	
513	DAVADILLA	RHIZA MAE	GO	
514	DAVADILLA	JOHN GABRIEL	ERUM	
515	DAVADILLA	RALPH JACOB	ANG	
516	DAVADILLA	MARIA AZRIEL THERESE	DESTUA	
517	DAVADILLA	DANIELLE ANNE	FRANCISCO	
518	DAVADILLA	RACHEL	LUNA	
519	DAVADILLA	JEAN DOMINIQUE	BERNAL	
520	DAVADILLA	CHARMAINE PAMELA	ABERCA	
521	DAVADILLA	ARIANNE FRANCESCA	QUIJANO	
522	DAVADILLA	FELIX ARAM	JEREMIAS	
523	DAVADILLA	NATHAN LEMUEL	GO	
524	DAVADILLA	WENDY GENEVA	SANTOS	
525	DAVADILLA	MARA ISSABEL	SUPLICO	
526	DAVADILLA	MA LORENA JOY	ASCUTIA	
527	DAVADILLA	MISHAEL MAE	CRUZ	
528	DAVADILLA	HANNAH ERIKA	YAP	
529	DAVADILLA	NICOLE ANNE	KAHN	
530	DAVADILLA	KEVIN DAVID	BALANAY	
531	DAVADILLA	JULIA NINA	SOMERA	
532	DAVADILLA	SEBASTIAN	CANLAS	
533	DAVADILLA	VERNA KATRIN	BEDUYA	
534	DAVADILLA	MARIA RUBYLISA	AREVALO	
535	DAVADILLA	NORVIN	GARCIA	
536	DAVADILLA	ANNA MANNELLI	ESPIRITU	
537	DAVADILLA	EDGAR ALLAN	GO	
538	DAVADILLA	EMERY	FABRO	
539	DAVADILLA	JON PERCIVAL	GARCIA	
540	DAVADILLA	MARY GRACE	AYENTO	
541	DAVADILLA	JOSE MARI	MARCELO	
542	DAVADILLA	KYLE BENEDICT	GUERRERO	
543	DAVADILLA	LUIS ANTONIO	PEREZ	
544	DAVADILLA	MAYNARD JEFFERSON	ZHUANG	
545	DAVADILLA	PATRICH PAOLO	BONETE	
546	DAVADILLA	EMMANUEL	LOYOLA	
547	DAVADILLA	MICHAEL JOYSON	GERMAR	
548	DAVADILLA	VICTORIA CASSANDRA	RUIVIVAR	
549	DAVADILLA	JASPER	ENRIQUEZ	
550	DAVADILLA	ARISA	CAAKBAY	
551	DAVADILLA	PAOLO	SISON	
552	DAVADILLA	JAYVIC	PORTILLO	
553	DAVADILLA	CATHERINE LORAINE	FESTIN	
554	DAVADILLA	ANGELO	CAL	
555	DAVADILLA	DARRWIN DEAREST	CRISOSTOMO	
556	DAVADILLA	ALVIN JOHN	MANLIGUEZ	
557	DAVADILLA	JENNY	NARSOLIS	
558	DAVADILLA	RIC JANUS	OLIVER	
559	DAVADILLA	FRANCIS MIGUEL	EVANGELISTA	
560	DAVADILLA	RIZA RAE	ALDECOA	
561	DAVADILLA	XYRIZ CZAR	PINEDA	
562	DAVADILLA	KRISTOFER	EMPUERTO	
563	DAVADILLA	JOHN FRANCIS	LLAGAS	
564	DAVADILLA	GIRAH MAY	CHUA	
565	DAVADILLA	CHRISLENE	BUGARIN	
566	DAVADILLA	DON JOSEPH	TIANGCO	
567	DAVADILLA	MARY GRACE	TALAN	
568	DAVADILLA	CHARLES TIMOTHY	DEL ROSARIO	
569	DAVADILLA	JOHN JOEL	URBISTONDO	
570	DAVADILLA	GENIE LINN	PADILLA	
571	DAVADILLA	CASSANDRA LEIGH	LACASTA	
572	DAVADILLA	GLADYS JOYCE	OCAP	
573	DAVADILLA	ARVIN JOHN	CRUZ	
574	DAVADILLA	GYZELLE	EVANGELISTA	
575	DAVADILLA	JOSE EMMANUEL	DE JESUS	
576	DAVADILLA	JAN COLIN	OJEDA	
577	DAVADILLA	SHIELA PAULINE JOY	VERGARA	
578	DAVADILLA	KEN GERARD	TECSON	
579	DAVADILLA	PAOLO MIGUEL	MACALINDONG	
580	DAVADILLA	JOE-MAR	ORINDAY	
581	DAVADILLA	PAOLO THOMAS	REYES	
582	DAVADILLA	ALEXANDREI	GONZALES	
583	DAVADILLA	VERONICA	ALCARAZ	
584	DAVADILLA	DIANA MAE	CANLAS	
585	DAVADILLA	JOHN ALPERT	ANCHO	
586	DAVADILLA	ROEL JEREMIAH	ALCANTARA	
587	DAVADILLA	DUSTIN EDRIC	LEGARDA	
588	DAVADILLA	HARVEY IAN	SOLAYAO	
589	DAVADILLA	RAMON JOSE NILO	DELA VEGA	
590	DAVADILLA	JOHN PHILIP	URRIZA	
591	DAVADILLA	SHEALTIEL PAUL ROSSNERR	CALUAG	
592	DAVADILLA	JULES ALBERT	BERINGUELA	
593	DAVADILLA	KYLA MARIE	G.	
594	DAVADILLA	ARMOND	C.	
595	DAVADILLA	MICHAEL KEVIN	PONTE	
596	DAVADILLA	JET LAWRENCE	PARONE	
597	DAVADILLA	RITZ DANIEL	CATAMPATAN	
598	DAVADILLA	RAFAEL GERARD	DELA CRUZ	
599	ABACADA	ADRIAN	CORDOVA	
600	ABACADA	JAY RICKY	BARRAMEDA	
601	ABACADA	PIO RYAN	SAGARINO	
602	ABACADA	GEORGE HELAMAN	ASTURIAS	
603	ABACADA	JENNIFER	DELA CRUZ	
604	ABACADA	ROGER JOHN	ESTEPA	
605	ABACADA	KERVIN	CATUNGAL	
606	ABACADA	REGINALD ELI	ATIENZA	
607	ABACADA	NORBERTO	ALLAREY	II
608	ABACADA	EDGAR	STA BARBARA	JR
609	ABACADA	KATHLEEN GRACE	GUERRERO	
610	ABACADA	ED ALBERT	BELARGO	
611	ABACADA	PAUL VINCENT	SALES	
612	ABACADA	KAREIN JOY	TOLENTINO	
613	ABACADA	LOVELIA	LAROCO	
614	ABACADA	CYROD JOHN	FLORIDA	
615	ABACADA	KEVIN RAINIER	SINOGAYA	
616	ABACADA	VINCENT NICHOLAS	RANA	
617	ABACADA	BRYAN MATTHEW	AVENDANO	
618	ABACADA	JOSHUA	KHO	
619	ABACADA	ERIC	AMPARO	JR
620	ABACADA	JEWEL LEX	TONG	
621	ABACADA	WESLEY	MENDOZA	
622	ABACADA	HOMER IRIC	SANTOS	
623	ABACADA	MARIANNE ANGELIE	OCAMPO	
624	ABACADA	VIC ANGELO	DELOS SANTOS	
625	ABACADA	RYAN KRISTOFER	IGMAT	
626	ABACADA	DANA ELISA	GAGALAC	
627	ABACADA	ISAIAH JAMES	VALDES	
628	ABACADA	MA CECILIA		
629	ABACADA	JAKE ERICKSON	BOTEROS	
630	ABACADA	ELIZABETH	CUETO	
631	ABACADA	FRANCIS KEVIN	ALIMORONG	
632	ABACADA	FRANCIS JOMER	DE LEON	
633	ABACADA	MICHAEL ERICK	STA TERESA	
634	ABACADA	JULIAN	CASTILLO	
635	ABACADA	ARMINA	EUGENIO	
636	ABACADA	JOSEPH ARMAN	BONGCO	
637	ABACADA	MARTIN ROMAN LORENZO	ILAGAN	
638	ABACADA	MESSIAH JAN	LEBID	
639	ABACADA	JEROME	RONCESVALLES	
640	ABACADA	JOHN CARLO	MAQUILAN	
641	ABACADA	SILVEN VICTOR	DUMALAG	
642	ABACADA	JOHN ISRAEL	LORENZO	
643	ABACADA	MARIE JUNNE	CABRAL	
644	ABACADA	JULIAN NICHOLAS	REYES	
645	ABACADA	ERIC	TUQUERO	
646	ABACADA	BENJAMIN	ANGELES	JR
647	ABACADA	JEANELLA KLARYS	ESPIRITU	
648	ABACADA	JOSE NOEL	CARDONES	
649	ABACADA	JARED	MUMAR	
650	ABACADA	KARESSA ALEXANDRA	ONG	
651	ABACADA	STANLEY	TINA	
652	ABACADA	MARC ARTHUR	PAJE	
653	ABACADA	HANS CHRISTIAN	BALTAZAR	
654	ABACADA	ARVIN	PABINES	
655	ABACADA	NOELYN JOYCE	ROL	
656	ABACADA	DAVID ROBIN	MANALAC	
657	ABACADA	KOHLEN ANGELO	PEREZ	
658	ABACADA	JAMES PATRICK	DAVID	
659	ABACADA	MICHAEL	DIONISIO	
660	ABACADA	MARIE ANTOINETTE	R	
661	ABACADA	ISAIAH EDWARD	G	
662	ABACADA	DEAN ALVIN	BAJAMONDE	
663	ABACADA	JOHN EROL	MILANO	
664	ABACADA	KRYSTIAN VIEL	CABUGAO	
665	ABACADA	VANESSA VIVIEN	FRANCISCO	
666	ABACADA	RYAN ODYLON	GAZMEN	
667	ABACADA	CHRISTIAN JOY	MARQUEZ	
668	ABACADA	JENNIFER	RAMOS	
669	ABACADA	SARAH	BERNABE	
670	ABACADA	JAYVEE ELJOHN	ACABO	
671	ABACADA	DANAH VERONICA	PADILLA	
672	ABACADA	APRYL ROSE	LABAYOG	
673	ABACADA	TED GUILLANO	SY	
674	ABACADA	IVAN KRISTEL	POLICARPIO	
675	ABACADA	CHLOEBELLE	RAMOS	
676	ABACADA	DANIEL	LALAGUNA	
677	ABACADA	BENJIE	REYES	
678	ABACADA	ANNA CLARISSA	BEATO	
679	ABACADA	CHARMAILENE	CAPILI	
680	ABACADA	JEANELLE	ESGUERRA	
681	ABACADA	ROD XANDER	RIVERA	
682	ABACADA	NERISSA MONICA	DE GUZMAN	
683	ABACADA	REZELEE	AQUINO	
684	ABACADA	BERLYN ANNE	ARAGON	
685	ABACADA	KARL LEN MAE	BALDOMERO	
686	ABACADA	ZIV YVES	MONTOYA	
687	ABACADA	CZELINA ELLAINE	ONG	
688	ABACADA	NEIL DAVID	BALGOS	
689	ABACADA	LOU MERLENETTE	BAUTISTA	
690	ABACADA	RHIZA MAE	GO	
691	ABACADA	JOHN GABRIEL	ERUM	
692	ABACADA	RALPH JACOB	ANG	
693	ABACADA	MARIA AZRIEL THERESE	DESTUA	
694	ABACADA	DANIELLE ANNE	FRANCISCO	
695	ABACADA	RACHEL	LUNA	
696	ABACADA	JEAN DOMINIQUE	BERNAL	
697	ABACADA	CHARMAINE PAMELA	ABERCA	
698	ABACADA	ARIANNE FRANCESCA	QUIJANO	
699	ABACADA	FELIX ARAM	JEREMIAS	
700	ABACADA	NATHAN LEMUEL	GO	
701	ABACADA	WENDY GENEVA	SANTOS	
702	ABACADA	MARA ISSABEL	SUPLICO	
703	ABACADA	MA LORENA JOY	ASCUTIA	
704	ABACADA	MISHAEL MAE	CRUZ	
705	ABACADA	HANNAH ERIKA	YAP	
706	ABACADA	NICOLE ANNE	KAHN	
707	ABACADA	KEVIN DAVID	BALANAY	
708	ABACADA	JULIA NINA	SOMERA	
709	ABACADA	SEBASTIAN	CANLAS	
710	ABACADA	VERNA KATRIN	BEDUYA	
711	ABACADA	MARIA RUBYLISA	AREVALO	
712	ABACADA	NORVIN	GARCIA	
713	ABACADA	ANNA MANNELLI	ESPIRITU	
714	ABACADA	EDGAR ALLAN	GO	
715	ABACADA	EMERY	FABRO	
716	ABACADA	JON PERCIVAL	GARCIA	
717	ABACADA	MARY GRACE	AYENTO	
718	ABACADA	JOSE MARI	MARCELO	
719	ABACADA	KYLE BENEDICT	GUERRERO	
720	ABACADA	LUIS ANTONIO	PEREZ	
721	ABACADA	MAYNARD JEFFERSON	ZHUANG	
722	ABACADA	PATRICH PAOLO	BONETE	
723	ABACADA	EMMANUEL	LOYOLA	
724	ABACADA	MICHAEL JOYSON	GERMAR	
725	ABACADA	VICTORIA CASSANDRA	RUIVIVAR	
726	ABACADA	JASPER	ENRIQUEZ	
727	ABACADA	ARISA	CAAKBAY	
728	ABACADA	PAOLO	SISON	
729	ABACADA	JAYVIC	PORTILLO	
730	ABACADA	CATHERINE LORAINE	FESTIN	
731	ABACADA	ANGELO	CAL	
732	ABACADA	DARRWIN DEAREST	CRISOSTOMO	
733	ABACADA	ALVIN JOHN	MANLIGUEZ	
734	ABACADA	JENNY	NARSOLIS	
735	ABACADA	RIC JANUS	OLIVER	
736	ABACADA	FRANCIS MIGUEL	EVANGELISTA	
737	ABACADA	RIZA RAE	ALDECOA	
738	ABACADA	XYRIZ CZAR	PINEDA	
739	ABACADA	KRISTOFER	EMPUERTO	
740	ABACADA	JOHN FRANCIS	LLAGAS	
741	ABACADA	GIRAH MAY	CHUA	
742	ABACADA	CHRISLENE	BUGARIN	
743	ABACADA	DON JOSEPH	TIANGCO	
744	ABACADA	MARY GRACE	TALAN	
745	ABACADA	CHARLES TIMOTHY	DEL ROSARIO	
746	ABACADA	JOHN JOEL	URBISTONDO	
747	ABACADA	GENIE LINN	PADILLA	
748	ABACADA	CASSANDRA LEIGH	LACASTA	
749	ABACADA	GLADYS JOYCE	OCAP	
750	ABACADA	ARVIN JOHN	CRUZ	
751	ABACADA	GYZELLE	EVANGELISTA	
752	ABACADA	JOSE EMMANUEL	DE JESUS	
753	ABACADA	JAN COLIN	OJEDA	
754	ABACADA	SHIELA PAULINE JOY	VERGARA	
755	ABACADA	KEN GERARD	TECSON	
756	ABACADA	PAOLO MIGUEL	MACALINDONG	
757	ABACADA	JOE-MAR	ORINDAY	
758	ABACADA	PAOLO THOMAS	REYES	
759	ABACADA	ALEXANDREI	GONZALES	
760	ABACADA	VERONICA	ALCARAZ	
761	ABACADA	DIANA MAE	CANLAS	
762	ABACADA	JOHN ALPERT	ANCHO	
763	ABACADA	ROEL JEREMIAH	ALCANTARA	
764	ABACADA	DUSTIN EDRIC	LEGARDA	
765	ABACADA	HARVEY IAN	SOLAYAO	
766	ABACADA	RAMON JOSE NILO	DELA VEGA	
767	ABACADA	JOHN PHILIP	URRIZA	
768	ABACADA	SHEALTIEL PAUL ROSSNERR	CALUAG	
769	ABACADA	JULES ALBERT	BERINGUELA	
770	ABACADA	KYLA MARIE	G.	
771	ABACADA	ARMOND	C.	
772	ABACADA	MICHAEL KEVIN	PONTE	
773	ABACADA	JET LAWRENCE	PARONE	
774	ABACADA	RITZ DANIEL	CATAMPATAN	
775	ABACADA	RAFAEL GERARD	DELA CRUZ	
776	LLANES	ADRIAN	CORDOVA	
777	LLANES	JAY RICKY	BARRAMEDA	
778	LLANES	PIO RYAN	SAGARINO	
779	LLANES	GEORGE HELAMAN	ASTURIAS	
780	LLANES	JENNIFER	DELA CRUZ	
781	LLANES	ROGER JOHN	ESTEPA	
782	LLANES	KERVIN	CATUNGAL	
783	LLANES	REGINALD ELI	ATIENZA	
784	LLANES	NORBERTO	ALLAREY	II
785	LLANES	EDGAR	STA BARBARA	JR
786	LLANES	KATHLEEN GRACE	GUERRERO	
787	LLANES	ED ALBERT	BELARGO	
788	LLANES	PAUL VINCENT	SALES	
789	LLANES	KAREIN JOY	TOLENTINO	
790	LLANES	LOVELIA	LAROCO	
791	LLANES	CYROD JOHN	FLORIDA	
792	LLANES	KEVIN RAINIER	SINOGAYA	
793	LLANES	VINCENT NICHOLAS	RANA	
794	LLANES	BRYAN MATTHEW	AVENDANO	
795	LLANES	JOSHUA	KHO	
796	LLANES	ERIC	AMPARO	JR
797	LLANES	JEWEL LEX	TONG	
798	LLANES	WESLEY	MENDOZA	
799	LLANES	HOMER IRIC	SANTOS	
800	LLANES	MARIANNE ANGELIE	OCAMPO	
801	LLANES	VIC ANGELO	DELOS SANTOS	
802	LLANES	RYAN KRISTOFER	IGMAT	
803	LLANES	DANA ELISA	GAGALAC	
804	LLANES	ISAIAH JAMES	VALDES	
805	LLANES	MA CECILIA		
806	LLANES	JAKE ERICKSON	BOTEROS	
807	LLANES	ELIZABETH	CUETO	
808	LLANES	FRANCIS KEVIN	ALIMORONG	
809	LLANES	FRANCIS JOMER	DE LEON	
810	LLANES	MICHAEL ERICK	STA TERESA	
811	LLANES	JULIAN	CASTILLO	
812	LLANES	ARMINA	EUGENIO	
813	LLANES	JOSEPH ARMAN	BONGCO	
814	LLANES	MARTIN ROMAN LORENZO	ILAGAN	
815	LLANES	MESSIAH JAN	LEBID	
816	LLANES	JEROME	RONCESVALLES	
817	LLANES	JOHN CARLO	MAQUILAN	
818	LLANES	SILVEN VICTOR	DUMALAG	
819	LLANES	JOHN ISRAEL	LORENZO	
820	LLANES	MARIE JUNNE	CABRAL	
821	LLANES	JULIAN NICHOLAS	REYES	
822	LLANES	ERIC	TUQUERO	
823	LLANES	BENJAMIN	ANGELES	JR
824	LLANES	JEANELLA KLARYS	ESPIRITU	
825	LLANES	JOSE NOEL	CARDONES	
826	LLANES	JARED	MUMAR	
827	LLANES	KARESSA ALEXANDRA	ONG	
828	LLANES	STANLEY	TINA	
829	LLANES	MARC ARTHUR	PAJE	
830	LLANES	HANS CHRISTIAN	BALTAZAR	
831	LLANES	ARVIN	PABINES	
832	LLANES	NOELYN JOYCE	ROL	
833	LLANES	DAVID ROBIN	MANALAC	
834	LLANES	KOHLEN ANGELO	PEREZ	
835	LLANES	JAMES PATRICK	DAVID	
836	LLANES	MICHAEL	DIONISIO	
837	LLANES	MARIE ANTOINETTE	R	
838	LLANES	ISAIAH EDWARD	G	
839	LLANES	DEAN ALVIN	BAJAMONDE	
840	LLANES	JOHN EROL	MILANO	
841	LLANES	KRYSTIAN VIEL	CABUGAO	
842	LLANES	VANESSA VIVIEN	FRANCISCO	
843	LLANES	RYAN ODYLON	GAZMEN	
844	LLANES	CHRISTIAN JOY	MARQUEZ	
845	LLANES	JENNIFER	RAMOS	
846	LLANES	SARAH	BERNABE	
847	LLANES	JAYVEE ELJOHN	ACABO	
848	LLANES	DANAH VERONICA	PADILLA	
849	LLANES	APRYL ROSE	LABAYOG	
850	LLANES	TED GUILLANO	SY	
851	LLANES	IVAN KRISTEL	POLICARPIO	
852	LLANES	CHLOEBELLE	RAMOS	
853	LLANES	DANIEL	LALAGUNA	
854	LLANES	BENJIE	REYES	
855	LLANES	ANNA CLARISSA	BEATO	
856	LLANES	CHARMAILENE	CAPILI	
857	LLANES	JEANELLE	ESGUERRA	
858	LLANES	ROD XANDER	RIVERA	
859	LLANES	NERISSA MONICA	DE GUZMAN	
860	LLANES	REZELEE	AQUINO	
861	LLANES	BERLYN ANNE	ARAGON	
862	LLANES	KARL LEN MAE	BALDOMERO	
863	LLANES	ZIV YVES	MONTOYA	
864	LLANES	CZELINA ELLAINE	ONG	
865	LLANES	NEIL DAVID	BALGOS	
866	LLANES	LOU MERLENETTE	BAUTISTA	
867	LLANES	RHIZA MAE	GO	
868	LLANES	JOHN GABRIEL	ERUM	
869	LLANES	RALPH JACOB	ANG	
870	LLANES	MARIA AZRIEL THERESE	DESTUA	
871	LLANES	DANIELLE ANNE	FRANCISCO	
872	LLANES	RACHEL	LUNA	
873	LLANES	JEAN DOMINIQUE	BERNAL	
874	LLANES	CHARMAINE PAMELA	ABERCA	
875	LLANES	ARIANNE FRANCESCA	QUIJANO	
876	LLANES	FELIX ARAM	JEREMIAS	
877	LLANES	NATHAN LEMUEL	GO	
878	LLANES	WENDY GENEVA	SANTOS	
879	LLANES	MARA ISSABEL	SUPLICO	
880	LLANES	MA LORENA JOY	ASCUTIA	
881	LLANES	MISHAEL MAE	CRUZ	
882	LLANES	HANNAH ERIKA	YAP	
883	LLANES	NICOLE ANNE	KAHN	
884	LLANES	KEVIN DAVID	BALANAY	
885	LLANES	JULIA NINA	SOMERA	
886	LLANES	SEBASTIAN	CANLAS	
887	LLANES	VERNA KATRIN	BEDUYA	
888	LLANES	MARIA RUBYLISA	AREVALO	
889	LLANES	NORVIN	GARCIA	
890	LLANES	ANNA MANNELLI	ESPIRITU	
891	LLANES	EDGAR ALLAN	GO	
892	LLANES	EMERY	FABRO	
893	LLANES	JON PERCIVAL	GARCIA	
894	LLANES	MARY GRACE	AYENTO	
895	LLANES	JOSE MARI	MARCELO	
896	LLANES	KYLE BENEDICT	GUERRERO	
897	LLANES	LUIS ANTONIO	PEREZ	
898	LLANES	MAYNARD JEFFERSON	ZHUANG	
899	LLANES	PATRICH PAOLO	BONETE	
900	LLANES	EMMANUEL	LOYOLA	
901	LLANES	MICHAEL JOYSON	GERMAR	
902	LLANES	VICTORIA CASSANDRA	RUIVIVAR	
903	LLANES	JASPER	ENRIQUEZ	
904	LLANES	ARISA	CAAKBAY	
905	LLANES	PAOLO	SISON	
906	LLANES	JAYVIC	PORTILLO	
907	LLANES	CATHERINE LORAINE	FESTIN	
908	LLANES	ANGELO	CAL	
909	LLANES	DARRWIN DEAREST	CRISOSTOMO	
910	LLANES	ALVIN JOHN	MANLIGUEZ	
911	LLANES	JENNY	NARSOLIS	
912	LLANES	RIC JANUS	OLIVER	
913	LLANES	FRANCIS MIGUEL	EVANGELISTA	
914	LLANES	RIZA RAE	ALDECOA	
915	LLANES	XYRIZ CZAR	PINEDA	
916	LLANES	KRISTOFER	EMPUERTO	
917	LLANES	JOHN FRANCIS	LLAGAS	
918	LLANES	GIRAH MAY	CHUA	
919	LLANES	CHRISLENE	BUGARIN	
920	LLANES	DON JOSEPH	TIANGCO	
921	LLANES	MARY GRACE	TALAN	
922	LLANES	CHARLES TIMOTHY	DEL ROSARIO	
923	LLANES	JOHN JOEL	URBISTONDO	
924	LLANES	GENIE LINN	PADILLA	
925	LLANES	CASSANDRA LEIGH	LACASTA	
926	LLANES	GLADYS JOYCE	OCAP	
927	LLANES	ARVIN JOHN	CRUZ	
928	LLANES	GYZELLE	EVANGELISTA	
929	LLANES	JOSE EMMANUEL	DE JESUS	
930	LLANES	JAN COLIN	OJEDA	
931	LLANES	SHIELA PAULINE JOY	VERGARA	
932	LLANES	KEN GERARD	TECSON	
933	LLANES	PAOLO MIGUEL	MACALINDONG	
934	LLANES	JOE-MAR	ORINDAY	
935	LLANES	PAOLO THOMAS	REYES	
936	LLANES	ALEXANDREI	GONZALES	
937	LLANES	VERONICA	ALCARAZ	
938	LLANES	DIANA MAE	CANLAS	
939	LLANES	JOHN ALPERT	ANCHO	
940	LLANES	ROEL JEREMIAH	ALCANTARA	
941	LLANES	DUSTIN EDRIC	LEGARDA	
942	LLANES	HARVEY IAN	SOLAYAO	
943	LLANES	RAMON JOSE NILO	DELA VEGA	
944	LLANES	JOHN PHILIP	URRIZA	
945	LLANES	SHEALTIEL PAUL ROSSNERR	CALUAG	
946	LLANES	JULES ALBERT	BERINGUELA	
947	LLANES	KYLA MARIE	G.	
948	LLANES	ARMOND	C.	
949	LLANES	MICHAEL KEVIN	PONTE	
950	LLANES	JET LAWRENCE	PARONE	
951	LLANES	RITZ DANIEL	CATAMPATAN	
952	LLANES	RAFAEL GERARD	DELA CRUZ	
953	LLANTADA	ADRIAN	CORDOVA	
954	LLANTADA	JAY RICKY	BARRAMEDA	
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
1	11	1	1
2	12	1	2
3	13	1	3
4	14	1	4
5	15	1	5
7	12	2	6
8	13	2	7
9	14	2	8
12	12	3	9
13	13	3	9
14	14	3	9
17	12	4	2
18	13	4	3
19	14	4	7
25	15	5	2
26	16	6	2
27	17	6	5
28	18	6	5
29	19	6	1
30	20	6	1
31	16	7	1
32	17	7	5
33	18	7	5
34	19	7	6
35	20	7	2
36	16	8	2
37	17	8	1
38	18	8	1
39	19	8	1
40	20	8	2
41	16	9	1
42	17	9	1
43	18	9	1
44	19	9	1
45	20	9	2
46	16	10	5
47	17	10	5
48	18	10	4
49	19	10	3
50	20	10	2
51	21	11	3
52	22	11	2
53	23	11	2
54	24	11	1
55	25	11	5
56	21	12	2
57	22	12	2
58	23	12	2
59	24	12	3
61	21	13	1
62	22	13	5
63	23	13	8
64	24	13	2
65	25	13	1
66	21	14	2
67	22	14	2
68	23	14	2
69	24	14	1
71	21	15	1
72	22	15	1
73	23	15	1
74	24	15	2
76	26	16	3
77	27	16	1
78	28	16	1
79	29	16	2
80	30	16	1
81	26	17	2
82	27	17	3
83	28	17	4
84	29	17	3
85	30	17	2
86	26	18	1
87	27	18	7
88	28	18	6
89	29	18	5
90	30	18	2
91	26	19	1
92	27	19	2
93	28	19	3
94	29	19	4
95	30	19	5
96	26	20	3
97	27	20	3
98	28	20	5
99	29	20	4
100	30	20	3
101	31	21	1
102	32	21	2
103	33	21	1
104	34	21	1
105	35	21	1
106	36	22	1
107	37	22	2
108	38	22	3
109	39	22	4
110	40	22	1
111	36	23	4
112	37	23	5
113	38	23	6
114	39	23	2
115	40	23	3
116	36	24	3
117	37	24	4
118	38	24	6
119	39	24	7
120	40	24	8
121	36	25	1
122	37	25	2
123	38	25	3
124	39	25	1
125	40	25	2
126	36	26	1
127	37	26	5
128	38	26	4
129	39	26	2
130	40	26	5
131	36	27	3
132	37	27	2
133	38	27	3
134	39	27	2
135	40	27	3
136	41	28	4
137	42	28	3
138	43	28	2
139	44	28	1
140	45	28	1
141	41	29	3
142	42	29	7
143	43	29	3
144	44	29	2
145	45	29	5
146	41	30	1
147	42	30	1
148	43	30	1
149	44	30	2
150	45	30	1
151	41	31	1
152	42	31	2
153	43	31	1
154	44	31	1
155	45	31	4
156	41	32	2
157	42	32	1
158	43	32	4
159	44	32	6
160	45	32	5
161	41	33	4
162	42	33	3
163	43	33	5
164	44	33	3
165	45	33	7
166	46	34	1
167	47	34	2
168	48	34	3
169	49	34	4
170	50	34	1
171	46	35	1
172	47	35	2
173	48	35	3
174	49	35	4
175	50	35	1
176	46	36	1
177	47	36	2
178	48	36	3
179	49	36	4
180	50	36	1
181	46	37	1
182	47	37	2
183	48	37	3
184	49	37	4
185	50	37	1
10	15	2	11
15	15	3	11
20	15	4	11
60	25	12	11
186	46	38	1
187	47	38	2
188	48	38	3
189	49	38	4
190	50	38	1
191	46	39	1
192	47	39	2
193	48	39	3
194	49	39	4
195	50	39	1
196	51	40	1
197	52	40	2
198	53	40	3
199	54	40	4
200	55	40	1
201	51	41	1
202	52	41	2
203	53	41	3
204	54	41	4
205	55	41	1
206	51	42	1
207	52	42	2
208	53	42	3
209	54	42	4
210	55	42	1
211	51	43	1
212	52	43	2
213	53	43	3
214	54	43	4
215	55	43	1
216	51	44	1
217	52	44	2
218	53	44	3
219	54	44	4
220	55	44	1
221	51	45	1
222	52	45	2
223	53	45	3
224	54	45	4
225	55	45	1
226	1	46	1
227	2	46	2
228	3	46	3
229	4	46	4
230	5	46	1
231	1	47	1
232	2	47	2
233	3	47	3
234	4	47	4
235	5	47	1
236	1	48	1
237	2	48	2
238	3	48	3
239	4	48	4
240	5	48	1
243	3	49	3
244	4	49	4
245	5	49	1
248	3	50	3
249	4	50	4
250	5	50	1
251	1	51	1
252	2	51	2
253	3	51	3
254	4	51	4
255	5	51	1
256	6	52	1
257	7	52	2
258	8	52	3
259	9	52	4
260	10	52	1
261	6	53	1
262	7	53	2
263	8	53	3
264	9	53	4
265	10	53	1
266	6	54	1
267	7	54	2
268	8	54	3
269	9	54	4
270	10	54	1
271	6	55	1
272	7	55	2
273	8	55	3
274	9	55	4
275	10	55	1
276	6	56	1
277	7	56	2
278	8	56	3
279	9	56	4
280	10	56	1
281	6	57	1
282	7	57	2
283	8	57	3
284	9	57	4
285	10	57	1
286	66	58	1
287	66	59	1
291	76	63	1
292	76	64	1
293	76	65	1
294	76	66	4
295	76	67	1
296	86	68	2
297	86	69	1
298	86	70	5
299	86	71	4
300	86	72	2
301	67	58	3
302	67	59	6
303	67	60	2
304	67	61	3
305	67	62	2
306	77	63	4
307	77	64	5
308	77	65	2
309	77	66	1
310	77	67	3
311	87	68	7
312	87	69	5
313	87	70	11
314	87	71	9
315	87	72	1
316	68	58	3
317	68	59	9
318	68	60	2
319	68	61	4
320	68	62	7
321	78	63	4
322	78	64	8
323	78	65	2
324	78	66	11
325	78	67	2
326	88	68	5
327	88	69	11
328	88	70	9
329	88	71	11
330	88	72	2
331	69	58	1
332	69	59	1
333	69	60	2
334	69	61	3
335	69	62	1
336	79	63	2
337	79	64	1
338	79	65	4
339	79	66	2
340	79	67	2
341	89	68	4
342	89	69	1
343	89	70	5
344	89	71	5
345	89	72	4
346	70	58	4
347	70	59	2
348	70	60	3
349	70	61	2
350	70	62	2
351	80	63	5
352	80	64	3
353	80	65	4
354	80	66	4
355	80	67	2
356	90	68	5
357	90	69	2
358	90	70	7
359	90	71	6
360	90	72	3
361	71	58	6
362	71	59	8
363	71	60	3
364	71	61	2
365	71	62	4
366	81	63	5
367	81	64	6
368	81	65	4
369	81	66	1
370	81	67	3
241	1	49	12
246	1	50	12
242	2	49	11
247	2	50	11
371	91	68	8
372	91	69	7
373	91	70	11
374	91	71	9
375	91	72	2
376	72	58	7
377	72	59	9
378	72	60	5
379	72	61	7
380	72	62	3
381	82	63	6
382	82	64	9
383	82	65	4
384	82	66	5
385	82	67	7
386	92	68	11
387	92	69	11
388	92	70	11
389	92	71	11
390	92	72	11
391	73	58	3
392	73	59	2
393	73	60	5
394	73	61	2
395	73	62	3
396	83	63	7
397	83	64	3
398	83	65	2
399	83	66	5
400	83	67	3
401	93	68	6
402	93	69	4
403	93	70	6
404	93	71	11
405	93	72	3
406	74	58	5
407	74	59	3
408	74	60	6
409	74	61	2
410	74	62	11
411	84	63	3
412	84	64	4
413	84	65	5
414	84	66	3
415	84	67	2
416	94	68	5
417	94	69	6
418	94	70	7
419	94	71	8
420	94	72	3
421	75	58	7
422	75	59	4
423	75	60	3
424	75	61	3
425	75	62	1
426	85	63	2
427	85	64	3
428	85	65	5
429	85	66	2
430	85	67	3
431	95	68	7
432	95	69	3
433	95	70	6
434	95	71	8
435	95	72	3
436	96	73	5
437	96	74	3
438	96	75	1
439	96	76	3
440	96	77	2
441	97	73	1
442	97	74	1
443	97	75	2
444	97	76	2
445	97	77	1
446	98	73	9
447	98	74	5
448	98	75	3
449	98	76	2
450	98	77	2
451	99	73	7
452	99	74	2
453	99	75	1
454	99	76	3
455	99	77	4
456	100	73	4
457	100	74	6
458	100	75	2
459	100	76	1
460	100	77	3
461	101	73	2
462	101	74	5
463	101	75	3
464	101	76	1
465	101	77	2
466	102	73	7
467	102	74	4
468	102	75	3
469	102	76	1
470	102	77	2
471	103	73	1
472	103	74	3
473	103	75	5
474	103	76	2
475	103	77	6
476	104	73	5
477	104	74	1
478	104	75	2
479	104	76	4
480	104	77	2
481	105	73	1
482	105	74	1
483	105	75	2
484	105	76	3
485	105	77	1
70	25	14	11
75	25	15	11
21	11	5	11
22	12	5	11
6	11	2	11
11	11	3	11
16	11	4	11
23	13	5	11
24	14	5	11
288	66	60	12
289	66	61	12
290	66	62	12
486	106	58	4
487	106	59	3
488	106	60	4
489	106	61	1
490	106	62	3
491	121	63	5
492	121	64	2
493	121	65	5
494	121	66	1
495	121	67	5
496	136	68	7
497	136	69	3
498	136	70	6
499	136	71	6
500	136	72	3
501	107	58	8
502	107	59	7
503	107	60	3
504	107	61	2
505	107	62	2
506	122	63	7
507	122	64	5
508	122	65	2
509	122	66	4
510	122	67	3
511	137	68	7
512	137	69	6
513	137	70	11
514	137	71	11
515	137	72	3
516	108	58	4
517	108	59	2
518	108	60	4
519	108	61	3
520	108	62	1
521	123	63	5
522	123	64	3
523	123	65	2
524	123	66	1
525	123	67	4
526	138	68	6
527	138	69	2
528	138	70	8
529	138	71	7
530	138	72	3
531	109	58	5
532	109	59	1
533	109	60	4
534	109	61	2
535	109	62	2
536	124	63	5
537	124	64	2
538	124	65	2
539	124	66	3
540	124	67	2
541	139	68	6
542	139	69	1
543	139	70	11
544	139	71	4
545	139	72	2
546	110	58	7
547	110	59	3
548	110	60	4
549	110	61	2
550	110	62	2
551	125	63	6
552	125	64	3
553	125	65	4
554	125	66	4
555	125	67	3
556	140	68	7
557	140	69	4
558	140	70	8
559	140	71	11
560	140	72	5
561	111	58	2
562	111	59	1
563	111	60	2
564	111	61	1
565	111	62	1
566	126	63	1
567	126	64	1
568	126	65	3
569	126	66	2
570	126	67	2
571	141	68	4
572	141	69	1
573	141	70	5
574	141	71	4
575	141	72	3
576	112	58	4
577	112	59	3
578	112	60	3
579	112	61	2
580	112	62	3
581	127	63	5
582	127	64	3
583	127	65	2
584	127	66	1
585	127	67	2
586	142	68	5
587	142	69	4
588	142	70	8
589	142	71	6
590	142	72	2
591	113	58	9
592	113	59	8
593	113	60	4
594	113	61	5
595	113	62	3
596	128	63	8
597	128	64	6
598	128	65	3
599	128	66	2
600	128	67	1
601	143	68	9
602	143	69	7
603	143	70	11
604	143	71	11
605	143	72	5
606	114	58	1
607	114	59	2
608	114	60	3
609	114	61	2
610	114	62	1
611	129	63	4
612	129	64	2
613	129	65	3
614	129	66	2
615	129	67	4
616	144	68	11
617	144	69	3
618	144	70	11
619	144	71	11
620	144	72	6
621	115	58	5
622	115	59	4
623	115	60	3
624	115	61	2
625	115	62	4
626	130	63	6
627	130	64	3
628	130	65	1
629	130	66	2
630	130	67	2
631	145	68	6
632	145	69	2
633	145	70	9
634	145	71	11
635	145	72	3
636	116	58	3
637	116	59	2
638	116	60	3
639	116	61	1
640	116	62	3
641	131	63	4
642	131	64	2
643	131	65	1
644	131	66	4
645	131	67	3
646	146	68	5
647	146	69	2
648	146	70	5
649	146	71	4
650	146	72	2
651	117	58	4
652	117	59	3
653	117	60	6
654	117	61	3
655	117	62	2
656	132	63	6
657	132	64	4
658	132	65	3
659	132	66	4
660	132	67	5
661	147	68	8
662	147	69	6
663	147	70	9
664	147	71	11
665	147	72	3
666	118	58	5
667	118	59	2
668	118	60	3
669	118	61	4
670	118	62	5
671	133	63	4
672	133	64	3
673	133	65	4
674	133	66	2
675	133	67	3
676	148	68	11
677	148	69	5
678	148	70	11
679	148	71	7
680	148	72	5
681	119	58	1
682	119	59	1
683	119	60	2
684	119	61	1
685	119	62	1
686	134	63	2
687	134	64	1
688	134	65	2
689	134	66	3
690	134	67	1
691	149	68	4
692	149	69	2
693	149	70	9
694	149	71	11
695	149	72	3
696	120	58	4
697	120	59	5
698	120	60	2
699	120	61	3
700	120	62	4
701	135	63	7
702	135	64	6
703	135	65	4
704	135	66	5
705	135	67	3
706	150	68	7
707	150	69	11
708	150	70	11
709	150	71	9
710	150	72	4
711	151	78	1
712	151	79	1
713	151	80	1
714	152	81	11
715	152	82	1
716	152	83	1
717	153	84	11
718	153	85	1
719	154	87	1
720	154	88	1
721	155	89	1
722	155	90	1
723	156	91	11
724	156	92	11
725	157	93	11
726	157	94	11
727	36	59	11
728	153	86	1
729	158	95	6
730	158	96	7
731	158	97	7
732	158	98	6
733	158	99	4
734	158	100	3
735	158	101	1
736	159	102	4
737	159	103	5
738	159	104	6
739	159	105	4
740	159	106	3
741	160	107	10
742	160	108	11
743	160	109	9
744	160	110	8
745	160	111	11
746	161	112	3
747	161	113	9
748	162	114	7
749	162	115	9
750	162	116	13
751	162	117	10
752	162	118	6
753	163	119	13
754	163	120	9
755	163	121	11
756	163	122	11
757	163	123	9
758	163	124	11
759	164	125	6
760	164	126	5
761	165	127	9
762	165	128	6
763	165	129	11
764	165	130	9
765	165	131	5
766	166	132	6
767	166	133	9
768	166	134	6
769	166	135	8
770	166	136	3
771	167	137	7
772	167	138	6
773	167	139	5
774	167	140	6
775	167	141	6
776	168	142	9
777	168	143	8
778	168	144	10
779	169	145	5
780	169	146	9
781	169	147	7
782	169	148	7
783	169	149	11
784	170	150	7
785	170	151	9
786	170	152	3
787	170	153	6
788	170	154	9
789	172	156	1
790	172	156	14
791	171	155	14
792	171	157	9
793	171	158	10
794	171	159	5
795	171	160	14
796	173	161	7
797	173	162	14
798	173	163	9
799	173	164	14
800	173	165	5
801	173	166	5
802	174	167	9
803	174	168	8
804	174	169	9
805	174	170	4
806	174	171	7
807	175	172	12
808	175	173	7
809	175	174	5
810	175	175	9
811	175	176	14
812	176	177	14
813	176	178	9
814	176	179	6
815	176	180	6
816	176	181	12
817	177	182	12
818	178	183	5
819	178	184	4
820	178	185	13
821	178	186	4
822	178	187	9
823	178	188	9
824	179	189	11
825	179	190	9
826	179	191	11
827	179	192	11
828	179	193	11
829	180	194	13
830	180	195	9
831	180	196	9
832	180	197	9
833	180	198	5
834	181	199	9
835	181	200	6
836	181	201	4
837	181	202	2
838	181	203	2
839	182	204	6
840	183	205	8
841	184	206	5
842	184	207	5
843	185	208	10
844	186	209	4
845	186	210	9
846	186	211	8
847	186	212	11
848	186	213	8
849	186	214	9
850	187	215	9
851	187	216	4
852	187	217	9
853	187	218	11
854	187	219	9
855	187	213	11
856	188	220	12
857	188	221	7
858	188	222	11
859	188	223	13
860	188	224	6
861	189	225	12
862	189	226	6
863	189	227	7
864	189	228	7
865	189	229	7
866	190	230	4
867	190	231	7
868	190	232	1
869	190	233	4
870	190	234	1
871	191	235	7
872	191	236	4
873	191	237	8
874	191	238	1
875	191	239	7
876	191	240	9
877	192	241	12
878	192	242	4
879	192	243	5
880	192	237	11
881	192	239	8
882	192	240	9
883	193	244	11
884	193	245	11
885	193	246	11
886	193	247	11
887	193	248	9
888	193	249	11
889	194	250	5
890	194	251	11
891	194	252	11
892	194	253	9
893	194	249	11
894	195	254	9
895	195	255	6
896	195	256	13
897	195	257	5
898	195	258	2
899	196	259	4
900	196	260	7
901	197	261	2
902	197	262	4
903	198	263	14
904	199	264	6
905	200	265	13
906	201	266	6
907	201	267	9
908	201	268	9
909	201	269	6
910	201	270	2
911	201	271	5
912	201	272	6
913	202	273	11
914	202	274	5
915	202	268	5
916	202	275	6
917	202	276	6
918	202	277	9
919	203	278	6
920	203	279	5
921	203	280	11
922	203	281	11
923	203	282	3
924	203	283	9
925	204	284	8
926	204	285	11
927	204	286	6
928	204	287	12
929	204	283	9
930	204	277	7
931	205	288	4
932	205	289	8
933	205	290	7
934	205	287	1
935	205	291	7
936	206	292	7
937	206	293	5
938	206	294	4
939	206	295	3
940	206	296	4
941	207	297	6
942	207	298	4
943	207	299	4
944	207	300	8
945	207	301	2
946	208	302	3
947	208	303	14
948	208	304	9
949	208	305	9
950	208	306	12
951	208	307	7
952	208	308	2
953	209	309	8
954	209	310	5
955	209	311	9
956	209	306	6
957	209	312	6
958	209	313	2
959	209	314	3
960	210	315	6
961	210	316	5
962	210	317	5
963	210	318	10
964	210	319	8
965	210	320	7
966	211	321	12
967	211	322	10
968	211	323	4
969	211	324	9
970	211	325	6
971	211	326	5
972	212	327	13
973	212	328	11
974	212	329	9
975	212	330	6
976	212	331	4
977	213	309	8
978	213	332	7
979	213	333	5
980	213	334	4
981	213	335	1
982	214	336	1
983	214	337	2
984	215	338	5
985	216	339	6
986	217	340	3
987	217	341	6
988	218	342	14
989	218	343	8
990	218	344	10
991	218	345	6
992	219	346	2
993	219	347	3
994	219	342	5
995	219	348	5
996	219	349	5
997	219	350	6
998	219	351	1
999	220	352	11
1000	220	353	11
1001	220	354	8
1002	220	355	13
1003	220	356	9
1004	221	357	4
1005	221	358	8
1006	221	359	6
1007	221	360	9
1008	221	361	3
1009	222	362	5
1010	222	363	5
1011	222	364	9
1012	222	365	2
1013	222	366	5
1014	223	367	3
1015	223	368	11
1016	223	369	2
1017	223	370	3
1018	223	371	5
1019	224	372	2
1020	224	373	8
1021	224	374	1
1022	224	375	3
1023	224	371	6
1024	225	367	4
1025	225	373	9
1026	225	376	1
1027	225	377	7
1028	225	378	7
1029	226	379	5
1030	226	380	10
1031	226	381	5
1032	226	382	5
1033	226	378	1
1034	227	383	7
1035	227	384	9
1036	227	385	6
1037	227	386	3
1038	227	387	2
1039	228	388	14
1040	228	389	14
1041	228	390	9
1042	229	391	4
1043	229	392	7
1044	229	393	8
1045	229	394	4
1046	229	395	12
1047	230	396	2
1048	230	388	14
1049	230	397	8
1050	230	398	1
1051	230	399	2
1052	230	400	4
1053	230	401	1
1054	231	402	13
1055	231	403	9
1056	231	404	11
1057	231	405	9
1058	231	406	9
1059	232	407	8
1060	232	408	6
1061	232	409	9
1062	232	410	3
1063	232	398	6
1064	232	411	5
1065	233	412	6
1066	233	413	11
1067	233	414	4
1068	233	415	4
1069	233	416	6
1070	234	417	8
1071	234	418	4
1072	234	419	8
1073	234	420	5
1074	234	421	8
1075	235	422	5
1076	235	423	3
1077	235	424	3
1078	235	425	9
1079	235	426	4
1080	236	427	3
1081	236	428	9
1082	236	429	6
1083	236	430	4
1084	236	426	5
1085	237	431	5
1086	237	432	5
1087	237	433	4
1088	237	434	7
1089	237	421	2
1090	238	435	9
1091	238	436	3
1092	238	437	2
1093	238	430	4
1094	238	426	3
1095	239	438	14
1096	240	439	9
1097	241	440	4
1098	242	441	9
1099	243	442	8
1100	244	443	7
1101	245	444	8
1102	246	445	2
1103	246	446	4
1104	247	447	14
1105	247	448	4
1106	247	449	7
1107	247	450	11
1108	247	451	8
1109	247	452	12
1110	247	453	11
1111	247	454	1
1112	248	455	8
1113	248	456	11
1114	248	451	8
1115	248	457	12
1116	248	458	2
1117	248	459	5
1118	248	460	14
1119	248	461	4
1120	249	462	9
1121	249	463	9
1122	249	447	14
1123	249	448	5
1124	249	464	9
1125	249	452	8
1126	249	453	7
1127	250	447	14
1128	250	448	3
1129	250	465	2
1130	250	450	9
1131	250	466	9
1132	250	467	9
1133	250	461	8
1134	251	468	3
1135	251	469	7
1136	251	470	11
1137	251	471	7
1138	252	472	7
1139	252	473	7
1140	252	474	1
1141	252	475	2
1142	252	476	7
1143	253	477	5
1144	253	478	9
1145	253	479	2
1146	253	480	4
1147	253	481	5
1148	254	482	4
1149	254	483	8
1150	254	484	1
1151	254	476	8
1152	255	485	6
1153	255	486	8
1154	255	487	2
1155	255	488	9
1156	256	489	4
1157	256	490	4
1158	256	491	9
1159	256	492	13
1160	257	493	6
1161	257	494	9
1162	257	495	6
1163	257	496	6
1164	257	476	4
1165	258	497	3
1166	258	498	8
1167	258	473	9
1168	258	499	2
1169	258	481	8
1170	259	500	5
1171	259	501	7
1172	259	502	1
1173	259	479	2
1174	259	503	2
1175	260	504	1
1176	260	505	5
1177	260	506	3
1178	260	507	11
1179	260	508	2
1180	261	504	1
1181	261	505	5
1182	261	506	3
1183	261	507	11
1184	261	508	2
1185	262	509	4
1186	262	505	7
1187	262	510	11
1188	262	511	10
1189	262	512	5
1190	263	504	1
1191	263	505	5
1192	263	506	9
1193	263	507	8
1194	263	508	4
1195	264	513	12
1196	264	514	7
1197	264	510	7
1198	264	515	11
1199	264	512	2
1200	265	504	1
1201	265	505	4
1202	265	506	8
1203	265	507	6
1204	265	508	3
1205	266	504	2
1206	266	505	7
1207	266	506	1
1208	266	507	5
1209	266	508	1
1210	267	516	7
1211	267	517	9
1212	267	518	3
1213	267	519	3
1214	267	492	5
1215	268	504	1
1216	268	505	6
1217	268	506	3
1218	268	507	8
1219	268	508	3
1220	269	516	4
1221	269	517	6
1222	269	520	6
1223	269	521	1
1224	269	492	1
1225	270	522	9
1226	271	523	11
1227	271	524	6
1228	271	525	5
1229	271	526	2
1230	271	527	12
1231	271	528	6
1232	272	529	4
1233	272	530	3
1234	272	531	4
1235	272	532	8
1236	272	533	5
1237	272	534	12
1238	272	535	12
1239	273	536	11
1240	273	537	5
1241	273	538	10
1242	273	539	11
1243	273	540	9
1244	273	541	12
1245	273	542	11
1246	274	543	13
1247	274	544	6
1248	274	545	5
1249	274	540	2
1250	274	546	2
1251	274	542	5
1252	275	547	9
1253	275	548	13
1254	275	549	5
1255	275	550	13
1256	275	551	7
1257	276	552	13
1258	276	553	3
1259	276	554	7
1260	276	555	7
1261	276	556	3
1262	276	550	8
1263	277	557	9
1264	277	558	11
1265	277	553	8
1266	277	559	9
1267	277	560	11
1268	277	561	2
1269	278	562	4
1270	278	553	6
1271	278	563	11
1272	278	564	9
1273	278	565	5
1274	278	566	11
1275	279	567	9
1276	279	568	8
1277	279	569	11
1278	279	564	10
1279	279	570	11
1280	280	571	12
1281	280	572	6
1282	280	573	8
1283	280	574	10
1284	280	575	7
1285	280	576	6
1286	281	577	6
1287	281	557	8
1288	281	578	9
1289	281	553	4
1290	281	574	13
1291	281	566	8
1292	282	579	2
1293	282	563	11
1294	282	580	9
1295	282	554	11
1296	282	566	11
1297	283	581	5
1298	283	582	11
1299	283	583	2
1300	283	584	3
1301	283	585	4
1302	284	586	7
1303	284	587	9
1304	284	583	4
1305	284	588	5
1306	284	585	3
1307	285	589	8
1308	285	587	9
1309	285	583	5
1310	285	588	6
1311	285	585	7
1312	286	590	4
1313	286	591	8
1314	286	536	8
1315	286	592	7
1316	286	593	6
1317	287	594	4
1318	287	595	9
1319	287	583	6
1320	287	596	1
1321	287	585	9
1322	288	597	13
1323	288	598	11
1324	288	599	5
1325	288	600	6
1326	288	601	3
1327	289	602	4
1328	289	603	11
1329	289	555	8
1330	289	604	5
1331	289	585	5
1332	290	586	5
1333	290	587	5
1334	290	583	5
1335	290	588	6
1336	290	585	2
1337	291	605	4
1338	291	606	4
1339	291	607	7
1340	291	608	2
1341	291	609	1
1342	292	610	3
1343	292	611	3
1344	292	587	7
1345	292	612	3
1346	292	570	3
1347	293	613	1
1348	293	614	7
1349	293	615	4
1350	293	616	2
1351	293	601	2
1352	294	617	3
1353	295	618	12
1354	296	619	3
1355	296	620	9
1356	297	621	4
1357	298	622	5
1358	299	623	6
1359	299	624	5
1360	300	620	11
1361	301	625	4
1362	301	626	6
1363	302	627	4
1364	303	628	3
1365	304	629	9
1366	305	630	3
1367	306	631	5
1368	307	632	6
1369	307	633	11
1370	307	634	7
1371	307	635	8
1372	307	636	2
1373	307	637	9
1374	308	638	13
1375	308	639	14
1376	308	640	13
1377	308	641	9
1378	308	642	9
1379	308	643	11
1380	309	644	4
1381	309	645	6
1382	309	646	1
1383	309	647	4
1384	309	648	1
1385	310	649	6
1386	310	650	3
1387	310	651	11
1388	310	652	6
1389	310	653	7
1390	311	654	5
1391	311	655	7
1392	311	634	6
1393	311	656	3
1394	311	657	3
1395	312	658	2
1396	312	659	9
1397	312	660	11
1398	312	661	5
1399	312	662	6
1400	313	663	7
1401	313	664	11
1402	313	661	3
1403	313	665	2
1404	313	662	8
1405	314	666	8
1406	314	667	7
1407	314	668	5
1408	314	669	2
1409	315	670	5
1410	315	671	4
1411	315	660	8
1412	315	669	4
1413	315	672	11
1414	315	662	6
1415	316	673	7
1416	316	672	11
1417	316	640	7
1418	316	661	7
1419	316	674	7
1420	316	635	6
1421	317	675	3
1422	317	663	8
1423	317	672	8
1424	317	661	4
1425	317	665	2
1426	318	676	12
1427	318	677	9
1428	318	678	7
1429	318	679	6
1430	318	680	2
1431	319	681	2
1432	319	682	4
1433	319	683	7
1434	319	684	2
1435	319	685	7
1436	320	686	8
1437	320	679	5
1438	320	687	4
1439	320	688	4
1440	320	680	3
1441	321	689	9
1442	321	686	9
1443	321	679	6
1444	321	690	8
1445	321	691	13
1446	322	692	6
1447	322	693	9
1448	322	679	9
1449	322	694	4
1450	322	680	7
1451	323	695	4
1452	323	696	9
1453	323	697	9
1454	323	680	8
1455	324	698	6
1456	324	677	10
1457	324	679	11
1458	324	699	6
1459	325	700	3
1460	325	701	2
1461	325	696	9
1462	325	697	7
1463	325	680	6
1464	326	702	5
1465	326	703	7
1466	326	704	7
1467	326	679	6
1468	326	680	7
1469	327	705	5
1470	327	706	11
1471	327	697	9
1472	327	707	6
1473	327	680	1
1474	328	708	8
1475	328	678	6
1476	328	697	6
1477	328	709	9
1478	328	710	8
1479	329	711	3
1480	329	712	7
1481	329	713	7
1482	329	714	6
1483	329	691	2
1484	330	715	3
1485	330	716	6
1486	330	717	9
1487	330	718	2
1488	330	719	3
1489	331	720	4
1490	331	721	7
1491	331	722	2
1492	331	723	5
1493	331	684	1
1494	332	724	4
1495	332	682	6
1496	332	725	6
1497	332	726	7
1498	332	727	6
1499	333	728	2
1500	333	729	9
1501	333	730	3
1502	333	731	3
1503	333	732	6
1504	334	733	7
1505	334	734	6
1506	334	735	8
1507	334	736	11
1508	334	727	6
1509	335	715	3
1510	335	716	9
1511	335	717	5
1512	335	718	9
1513	335	719	8
1514	336	737	6
1515	336	738	6
1516	336	739	4
1517	336	740	2
1518	336	727	6
1519	337	741	7
1520	337	682	5
1521	337	735	5
1522	337	742	9
1523	337	727	1
1524	338	715	3
1525	338	716	7
1526	338	717	6
1527	338	718	3
1528	338	719	6
1529	339	743	8
1530	339	716	8
1531	339	738	8
1532	339	718	9
1533	339	719	9
1534	340	744	4
1535	340	729	6
1536	340	745	5
1537	340	746	4
1538	340	732	5
1539	341	747	8
1540	341	748	11
1541	341	749	3
1542	341	750	8
1543	341	751	7
1544	342	752	6
1545	342	729	9
1546	342	753	5
1547	342	754	10
1548	342	732	7
1549	343	715	4
1550	343	716	6
1551	343	717	8
1552	343	718	3
1553	343	719	6
1554	344	755	6
1555	344	738	5
1556	344	756	5
1557	344	757	4
1558	344	758	1
1559	345	759	4
1560	345	760	6
1561	345	730	4
1562	345	761	2
1563	345	684	1
1564	346	762	6
1565	346	763	7
1566	346	764	6
1567	346	765	2
1568	346	727	6
1569	347	766	5
1570	347	693	4
1571	347	721	7
1572	347	767	7
1573	347	751	1
1574	348	768	3
1575	348	769	9
1576	348	770	8
1577	348	771	4
1578	348	684	1
1579	349	772	6
1580	349	773	5
1581	349	774	4
1582	349	775	6
1583	349	727	5
1584	350	776	5
1585	350	777	11
1586	350	778	4
1587	350	779	12
1588	350	727	5
1589	351	755	7
1590	351	738	8
1591	351	756	7
1592	351	757	3
1593	351	758	4
1594	352	780	6
1595	352	769	10
1596	352	781	8
1597	352	771	3
1598	352	684	11
1599	353	762	5
1600	353	763	8
1601	353	764	5
1602	353	765	1
1603	353	751	5
1604	354	755	6
1605	354	738	4
1606	354	756	8
1607	354	757	4
1608	354	758	1
1609	355	782	4
1610	355	729	7
1611	355	767	4
1612	355	783	8
1613	355	732	6
1614	356	784	7
1615	356	785	9
1616	356	753	5
1617	356	740	2
1618	356	751	6
1619	357	786	4
1620	357	729	8
1621	357	767	5
1622	357	783	9
1623	357	732	8
1624	358	787	3
1625	358	729	4
1626	358	788	9
1627	358	789	4
1628	358	732	3
1629	359	790	12
1630	359	729	1
1631	359	791	8
1632	359	783	7
1633	359	732	5
1634	360	755	4
1635	360	738	9
1636	360	756	9
1637	360	757	4
1638	360	758	5
1639	361	792	1
1640	361	793	3
1641	361	794	8
1642	361	795	3
1643	361	796	4
1644	362	797	5
1645	362	798	5
1646	362	799	2
1647	362	800	7
1648	362	796	5
1649	363	801	1
1650	363	802	2
1651	363	794	11
1652	363	803	1
1653	363	796	11
1654	364	804	8
1655	364	805	12
1656	364	806	8
1657	364	807	10
1658	364	808	7
1659	365	809	5
1660	365	810	6
1661	365	811	12
1662	365	812	3
1663	365	813	12
1664	365	814	3
1665	366	804	6
1666	366	815	14
1667	366	816	4
1668	366	817	7
1669	366	811	9
1670	366	818	12
1671	366	819	11
1672	367	820	7
1673	367	821	5
1674	367	822	2
1675	367	823	2
1676	367	818	3
1677	367	824	12
1678	367	825	7
1679	368	806	7
1680	368	826	8
1681	368	827	5
1682	368	828	8
1683	368	829	6
1684	369	830	2
1685	369	831	11
1686	369	832	6
1687	369	828	8
1688	369	833	6
1689	369	834	2
1690	370	835	7
1691	370	836	8
1692	370	827	7
1693	370	832	7
1694	370	837	9
1695	371	838	6
1696	371	839	6
1697	371	840	11
1698	371	841	8
1699	371	842	12
1700	371	843	5
1701	372	844	9
1702	372	845	13
1703	372	846	7
1704	372	847	7
1705	372	848	3
1706	372	849	6
1707	373	848	5
1708	373	850	11
1709	373	827	1
1710	373	842	7
1711	373	849	5
1712	374	851	4
1713	374	817	12
1714	374	837	5
1715	374	812	6
1716	374	852	3
1717	374	853	12
1718	374	854	11
1719	375	831	11
1720	375	855	8
1721	375	817	5
1722	375	828	9
1723	375	856	5
1724	376	857	12
1725	376	858	11
1726	376	859	8
1727	376	860	1
1728	376	855	7
1729	376	861	5
1730	377	862	8
1731	377	863	7
1732	377	864	9
1733	377	865	6
1734	377	866	7
1735	378	806	7
1736	378	847	8
1737	378	867	6
1738	378	868	3
1739	378	869	6
1740	378	827	8
1741	379	870	10
1742	379	867	8
1743	379	871	5
1744	379	827	11
1745	379	849	9
1746	380	872	8
1747	380	873	13
1748	380	874	13
1749	380	875	6
1750	380	827	9
1751	381	876	2
1752	381	877	9
1753	381	806	8
1754	381	878	9
1755	381	879	6
1756	381	880	13
1757	382	881	6
1758	382	882	4
1759	382	883	7
1760	382	884	5
1761	382	841	3
1762	383	885	4
1763	383	846	9
1764	383	886	11
1765	383	855	13
1766	383	887	12
1767	384	846	6
1768	384	888	11
1769	384	889	9
1770	384	890	5
1771	384	880	7
1772	385	891	5
1773	385	892	9
1774	385	882	11
1775	385	867	11
1776	385	827	5
1777	386	893	4
1778	386	894	5
1779	386	895	9
1780	386	896	1
1781	386	841	13
1782	386	854	8
1783	387	897	3
1784	387	898	9
1785	387	899	5
1786	387	900	5
1787	387	901	6
1788	388	902	2
1789	388	806	6
1790	388	888	8
1791	388	903	6
1792	388	827	9
1793	388	904	3
1794	389	905	4
1795	389	906	5
1796	389	907	6
1797	389	908	7
1798	389	909	3
1799	390	910	4
1800	390	911	5
1801	390	912	2
1802	390	913	3
1803	390	914	2
1804	391	915	6
1805	391	916	9
1806	391	917	6
1807	391	918	9
1808	391	919	6
1809	392	920	2
1810	392	921	11
1811	392	839	8
1812	392	922	1
1813	392	866	5
1814	393	923	5
1815	393	924	7
1816	393	925	8
1817	393	926	4
1818	393	914	7
1819	394	927	7
1820	394	928	5
1821	394	907	10
1822	394	929	2
1823	394	930	9
1824	395	931	12
1825	395	932	9
1826	395	933	2
1827	395	934	3
1828	395	808	3
1829	396	935	5
1830	396	936	6
1831	396	937	7
1832	396	938	5
1833	396	930	1
1834	397	939	5
1835	397	905	4
1836	397	916	8
1837	397	940	2
1838	397	930	7
1839	158	941	6
1840	158	942	7
1841	158	943	7
1842	158	944	6
1843	158	945	1
1844	159	946	5
1845	159	947	6
1846	159	948	4
1847	160	949	10
1848	160	950	11
1849	160	951	9
1850	161	952	3
1851	161	953	9
1852	162	954	9
1853	162	955	13
1854	163	956	13
1855	163	957	9
1856	163	958	11
1857	165	959	9
1858	165	960	5
1859	166	961	9
1860	166	962	6
1861	167	963	6
1862	167	964	5
1863	169	965	9
1864	169	966	7
1865	169	967	7
1866	170	968	9
1867	170	969	3
1868	171	970	14
1869	171	971	14
1870	173	972	7
1871	173	973	9
1872	173	974	14
1873	173	975	5
1874	174	976	8
1875	174	977	9
1876	174	978	4
1877	175	979	7
1878	175	980	14
1879	176	981	9
1880	176	982	6
1881	178	983	13
1882	178	984	4
1883	179	985	11
1884	179	986	9
1885	179	987	11
1886	179	988	11
1887	180	989	9
1888	180	990	9
1889	181	991	9
1890	181	992	6
1891	181	993	4
1892	181	994	2
1893	182	995	6
1894	183	996	8
1895	184	997	5
1896	185	998	10
1897	186	999	9
1898	186	1000	9
1899	187	1001	9
1900	187	1002	11
1901	188	1003	7
1902	188	1004	11
1903	188	1005	13
1904	189	1006	6
1905	189	1007	7
1906	190	1008	7
1907	190	1009	4
1908	191	1010	7
1909	191	1011	4
1910	192	1012	5
1911	193	1013	11
1912	193	1014	11
1913	193	1015	9
1914	194	1016	11
1915	194	1017	11
1916	194	1018	9
1917	195	1019	6
1918	195	1020	13
1919	195	1021	5
1920	196	1022	7
1921	197	1023	4
1922	198	1024	14
1923	199	1025	6
1924	200	1026	13
1925	201	1027	6
1926	201	1028	6
1927	202	1029	11
1928	202	1030	9
1929	203	1031	6
1930	203	1032	11
1931	203	1033	11
1932	203	1034	3
1933	204	1035	11
1934	204	1036	6
1935	204	1030	7
1936	205	1037	8
1937	205	1038	7
1938	206	1039	4
1939	206	1040	3
1940	207	1041	4
1941	207	1042	8
1942	208	1043	14
1943	208	1044	9
1944	209	1045	9
1945	210	1046	6
1946	210	1047	5
1947	210	1048	10
1948	210	1049	8
1949	210	1050	7
1950	211	1051	10
1951	211	1052	4
1952	211	1053	9
1953	211	1054	6
1954	212	1055	11
1955	212	1056	6
1956	213	1057	7
1957	213	1058	5
1958	213	1059	4
1959	214	1060	1
1960	215	1061	5
1961	216	1062	6
1962	217	1063	6
1963	218	1064	14
1964	218	1065	8
1965	219	1066	2
1966	219	1067	3
1967	219	1064	5
1968	219	1068	5
1969	220	1069	11
1970	220	1070	8
1971	220	1071	13
1972	221	1072	8
1973	222	1073	9
1974	222	1074	2
1975	223	1075	11
1976	223	1076	3
1977	224	1077	8
1978	224	1078	3
1979	225	1077	9
1980	225	1079	7
1981	226	1080	10
1982	226	1081	5
1983	226	1082	5
1984	227	1083	9
1985	227	1084	3
1986	228	1085	14
1987	228	1086	14
1988	229	1087	8
1989	230	1088	2
1990	230	1085	14
1991	230	1089	8
1992	231	1090	9
1993	231	1091	11
1994	231	1092	9
1995	232	1093	8
1996	232	1094	9
1997	232	1095	3
1998	233	1096	11
1999	233	1097	4
2000	233	1098	4
2001	234	1099	8
2002	234	1100	5
2003	235	1101	9
2004	236	1102	9
2005	236	1103	6
2006	236	1104	4
2007	237	1105	5
2008	237	1106	4
2009	237	1107	7
2010	238	1108	9
2011	238	1109	3
2012	238	1110	2
2013	238	1104	4
2014	240	1111	9
2015	241	1112	4
2016	242	1113	9
2017	243	1114	8
2018	244	1115	7
2019	245	1116	8
2020	246	1117	4
2021	247	1118	14
2022	247	1119	4
2023	248	1120	4
2024	249	1121	9
2025	249	1122	9
2026	249	1118	14
2027	249	1119	5
2028	250	1118	14
2029	250	1119	3
2030	250	1120	8
2031	251	1123	7
2032	251	1124	11
2033	252	1125	7
2034	252	1126	7
2035	252	1127	1
2036	252	1128	2
2037	253	1129	9
2038	253	1130	2
2039	253	1131	4
2040	254	1132	4
2041	254	1133	8
2042	254	1134	1
2043	255	1135	6
2044	255	1136	8
2045	255	1137	2
2046	256	1138	4
2047	256	1139	9
2048	257	1140	6
2049	257	1141	6
2050	258	1142	8
2051	258	1126	9
2052	259	1143	7
2053	259	1130	2
2054	260	1144	3
2055	260	1145	11
2056	261	1144	3
2057	261	1145	11
2058	262	1146	11
2059	262	1147	10
2060	263	1144	9
2061	263	1145	8
2062	264	1146	7
2063	264	1148	11
2064	265	1144	8
2065	265	1145	6
2066	266	1144	1
2067	266	1145	5
2068	267	1149	9
2069	267	1150	3
2070	268	1144	3
2071	268	1145	8
2072	269	1149	6
2073	269	1151	1
2074	270	1152	9
2075	271	1153	11
2076	271	1154	6
2077	272	1155	3
2078	272	1156	8
2079	272	1157	5
2080	272	1158	12
2081	273	1159	5
2082	273	1160	10
2083	274	1161	6
2084	274	1162	5
2085	275	1163	13
2086	275	1164	5
2087	276	1165	13
2088	276	1166	3
2089	276	1167	7
2090	276	1168	3
2091	277	1169	11
2092	277	1166	8
2093	277	1170	9
2094	277	1171	2
2095	278	1166	6
2096	278	1172	11
2097	278	1173	9
2098	278	1174	5
2099	279	1175	11
2100	279	1173	10
2101	280	1176	6
2102	280	1177	8
2103	280	1178	10
2104	281	1179	9
2105	281	1166	4
2106	281	1178	13
2107	282	1180	2
2108	282	1172	11
2109	282	1181	9
2110	282	1167	11
2111	283	1182	11
2112	283	1183	3
2113	284	1184	7
2114	284	1185	9
2115	284	1186	5
2116	285	1187	8
2117	285	1185	9
2118	285	1186	6
2119	286	1188	8
2120	286	1189	7
2121	287	1190	4
2122	287	1191	9
2123	287	1192	1
2124	288	1193	11
2125	288	1194	6
2126	289	1195	11
2127	289	1196	5
2128	290	1184	5
2129	290	1185	5
2130	290	1186	6
2131	291	1197	7
2132	291	1198	2
2133	292	1185	7
2134	292	1199	3
2135	293	1200	7
2136	293	1201	2
2137	296	1202	3
2138	296	1203	9
2139	297	1204	4
2140	298	1205	5
2141	300	1203	11
2142	301	1206	4
2143	301	1207	6
2144	302	1208	4
2145	303	1209	3
2146	304	1210	9
2147	305	1211	3
2148	306	1212	5
2149	307	1213	6
2150	308	1214	13
2151	308	1215	14
2152	308	1216	11
2153	309	1217	6
2154	310	1218	6
2155	310	1219	3
2156	310	1220	11
2157	310	1221	7
2158	311	1222	7
2159	312	1223	9
2160	312	1224	11
2161	312	1225	6
2162	313	1226	7
2163	313	1225	8
2164	314	1227	8
2165	314	1228	7
2166	314	1229	5
2167	315	1230	4
2168	315	1224	8
2169	315	1225	6
2170	316	1231	7
2171	317	1232	3
2172	317	1226	8
2173	318	1233	9
2174	318	1234	7
2175	318	1235	6
2176	319	1236	7
2177	319	1237	7
2178	320	1238	8
2179	320	1235	5
2180	320	1239	4
2181	320	1240	4
2182	321	1238	9
2183	321	1235	6
2184	321	1241	8
2185	322	1235	9
2186	322	1242	4
2187	323	1243	9
2188	323	1244	9
2189	324	1233	10
2190	324	1235	11
2191	324	1245	6
2192	325	1246	2
2193	325	1243	9
2194	325	1244	7
2195	326	1247	7
2196	326	1248	7
2197	326	1235	6
2198	327	1249	11
2199	327	1244	9
2200	327	1250	6
2201	328	1251	8
2202	328	1234	6
2203	328	1244	6
2204	329	1252	7
2205	329	1253	7
2206	329	1254	6
2207	330	1255	9
2208	330	1256	2
2209	331	1257	7
2210	331	1258	5
2211	332	1259	6
2212	332	1260	7
2213	333	1261	9
2214	333	1262	3
2215	334	1263	8
2216	334	1264	11
2217	335	1255	5
2218	335	1256	9
2219	336	1265	6
2220	336	1266	2
2221	337	1263	5
2222	337	1267	9
2223	338	1255	6
2224	338	1256	3
2225	339	1265	8
2226	339	1256	9
2227	340	1261	6
2228	340	1268	5
2229	341	1269	11
2230	341	1270	8
2231	342	1261	9
2232	342	1271	10
2233	343	1255	8
2234	343	1256	3
2235	344	1265	5
2236	344	1272	4
2237	345	1273	6
2238	345	1274	2
2239	346	1275	7
2240	346	1276	2
2241	347	1277	5
2242	347	1257	7
2243	348	1278	8
2244	348	1279	4
2245	349	1280	5
2246	349	1281	6
2247	350	1282	11
2248	350	1283	12
2249	351	1265	8
2250	351	1272	3
2251	352	1284	8
2252	352	1279	3
2253	353	1275	8
2254	353	1276	1
2255	354	1265	4
2256	354	1272	4
2257	355	1261	7
2258	355	1285	8
2259	356	1286	9
2260	356	1266	2
2261	357	1261	8
2262	357	1285	9
2263	358	1261	4
2264	358	1287	9
2265	358	1288	4
2266	359	1289	12
2267	359	1261	1
2268	359	1285	7
2269	360	1265	9
2270	360	1272	4
2271	361	1290	8
2272	361	1291	3
2273	362	1292	2
2274	362	1293	7
2275	363	1290	11
2276	363	1294	1
2277	364	1295	8
2278	364	1296	8
2279	364	1297	10
2280	364	1298	7
2281	365	1299	6
2282	365	1300	3
2283	366	1295	6
2284	366	1301	14
2285	367	1302	2
2286	367	1303	2
2287	367	1304	7
2288	368	1296	7
2289	368	1305	8
2290	368	1306	6
2291	369	1307	2
2292	369	1308	11
2293	370	1309	7
2294	370	1310	8
2295	371	1311	11
2296	372	1312	13
2297	372	1313	7
2298	372	1314	7
2299	373	1315	11
2300	374	1316	11
2301	375	1308	11
2302	375	1317	5
2303	376	1318	11
2304	376	1319	8
2305	376	1320	1
2306	377	1321	7
2307	377	1322	9
2308	377	1323	6
2309	378	1296	7
2310	378	1314	8
2311	378	1324	6
2312	378	1325	6
2313	379	1326	10
2314	379	1324	8
2315	379	1327	5
2316	380	1328	13
2317	380	1329	13
2318	380	1330	6
2319	381	1331	9
2320	381	1296	8
2321	381	1332	9
2322	381	1333	6
2323	382	1334	4
2324	382	1335	7
2325	382	1336	5
2326	383	1337	4
2327	383	1313	9
2328	383	1338	11
2329	384	1313	6
2330	384	1339	11
2331	384	1340	9
2332	384	1341	5
2333	385	1342	5
2334	385	1343	9
2335	385	1334	11
2336	385	1324	11
2337	386	1344	5
2338	386	1345	9
2339	386	1346	1
2340	386	1316	8
2341	387	1347	9
2342	387	1348	5
2343	387	1349	5
2344	388	1296	6
2345	388	1339	8
2346	388	1350	6
2347	388	1351	3
2348	389	1352	6
2349	389	1353	7
2350	390	1354	5
2351	390	1355	3
2352	391	1356	6
2353	391	1357	9
2354	391	1358	9
2355	392	1359	11
2356	392	1360	1
2357	393	1361	8
2358	393	1362	4
2359	394	1363	5
2360	394	1352	10
2361	394	1364	2
2362	395	1365	9
2363	395	1298	3
2364	396	1366	6
2365	396	1367	5
2366	397	1357	8
2367	397	1368	2
2368	398	1369	9
2369	398	1366	7
2370	398	1370	8
2371	398	1371	13
2372	398	1372	9
2373	399	1373	4
2374	399	1347	6
2375	399	839	7
2376	399	1374	8
2377	399	866	5
2378	400	1375	3
2379	400	1376	8
2380	400	1299	6
2381	400	1320	2
2382	400	919	10
2383	401	1373	5
2384	401	1377	10
2385	401	1378	11
2386	401	1379	8
2387	401	866	5
2388	402	1380	6
2389	402	1352	7
2390	402	1381	2
2391	402	1346	3
2392	402	930	6
2393	403	1382	8
2394	403	1383	3
2395	403	1384	8
2396	403	1385	5
2397	403	914	1
2398	404	1386	2
2399	404	1387	6
2400	404	1358	4
2401	404	1388	4
2402	404	1372	6
2403	405	1389	5
2404	405	1390	8
2405	405	1391	7
2406	405	1364	2
2407	405	914	3
2408	406	1392	8
2409	406	1361	9
2410	406	1393	5
2411	406	1394	2
2412	406	866	4
2413	407	1395	7
2414	407	1396	11
2415	407	1397	6
2416	407	816	6
2417	407	1388	8
2418	408	1398	8
2419	408	1399	10
2420	408	1366	3
2421	408	1400	2
2422	408	1401	6
2423	408	1388	8
2424	409	1402	2
2425	409	1403	7
2426	409	1404	5
2427	409	1348	4
2428	409	919	3
2429	410	1405	5
2430	410	1383	3
2431	410	1387	8
2432	410	1406	6
2433	410	866	7
2434	411	1407	4
2435	411	1408	13
2436	411	1404	4
2437	411	1409	1
2438	411	909	2
2439	412	1389	5
2440	412	1410	9
2441	412	1391	7
2442	412	1364	2
2443	412	934	9
2444	413	1411	4
2445	413	1383	4
2446	413	1359	9
2447	413	1412	5
2448	413	914	1
2449	414	1413	2
2450	414	1414	6
2451	414	1415	4
2452	414	816	6
2453	414	866	5
2454	415	1416	3
2455	415	1417	9
2456	415	1418	4
2457	415	1406	4
2458	415	934	6
2459	416	1419	5
2460	416	1377	9
2461	416	1378	8
2462	416	1420	7
2463	416	866	7
2464	417	1421	4
2465	417	1390	3
2466	417	839	8
2467	417	1394	5
2468	417	919	3
2469	418	1422	7
2470	418	1352	6
2471	418	917	7
2472	418	1423	12
2473	418	866	9
2474	419	1424	3
2475	419	1425	4
2476	419	1426	11
2477	419	1427	7
2478	419	930	8
2479	420	935	5
2480	420	1352	7
2481	420	1412	7
2482	420	1428	5
2483	420	1388	8
2484	421	902	3
2485	421	1408	7
2486	421	1429	11
2487	421	1430	2
2488	421	914	4
2489	422	1431	2
2490	422	1432	8
2491	422	1433	4
2492	422	1434	5
2493	422	901	8
2494	423	1435	8
2495	424	1436	4
2496	424	1437	6
2497	425	1438	2
2498	426	1439	2
2499	427	1440	4
2500	428	1441	3
2501	428	1442	5
2502	428	1443	9
2503	429	1444	3
2504	429	1445	6
2505	430	1446	6
2506	431	1447	8
2507	432	1448	8
2508	433	1449	1
2509	434	1450	9
2510	435	1451	11
2511	435	1445	7
2512	436	1452	6
2513	436	1453	8
2514	437	1454	9
2515	438	1455	8
2516	439	1456	4
2517	439	1457	2
2518	440	1458	9
2519	441	1459	9
2520	442	1460	8
2521	443	1461	2
2522	443	1462	1
2523	444	1463	3
2524	445	1464	6
2525	446	1465	11
2526	447	1466	9
2527	447	1467	6
2528	448	1468	9
2529	449	1469	3
2530	449	1457	3
2531	450	1470	3
2532	450	1471	4
2533	451	1465	11
2534	452	1454	5
2535	453	1463	9
2536	454	1472	6
2537	454	1458	7
2538	455	1473	1
2539	456	1474	8
2540	457	1475	4
2541	458	1476	12
2542	458	1477	9
2543	458	1478	11
2544	458	1479	11
2545	458	1480	11
2546	459	1481	7
2547	460	1482	13
2548	460	1483	4
2549	460	1484	11
2550	460	1485	9
2551	460	1477	5
2552	460	1486	5
2553	460	1487	2
2554	461	1488	6
2555	461	1489	4
2556	461	1487	12
2557	462	1490	5
2558	462	1491	5
2559	462	1492	14
2560	462	1477	5
2561	462	1493	4
2562	462	1494	4
2563	462	1495	13
2564	463	1496	11
2565	463	1497	9
2566	463	1486	11
2567	463	1498	2
2568	463	1499	12
2569	464	1483	2
2570	464	1500	4
2571	464	1501	13
2572	464	1502	11
2573	464	1503	5
2574	464	1504	8
2575	465	1505	7
2576	465	1506	13
2577	465	1502	9
2578	465	1477	8
2579	465	1503	5
2580	465	1507	6
2581	466	1508	5
2582	466	1509	2
2583	466	1510	2
2584	466	1511	2
2585	466	1512	8
2586	467	1513	6
2587	467	1514	5
2588	467	1491	13
2589	467	1515	14
2590	467	1516	9
2591	467	1517	8
2592	467	1495	10
2593	468	1518	4
2594	468	1519	13
2595	468	1477	8
2596	468	1478	9
2597	468	1493	4
2598	469	1520	3
2599	469	1491	11
2600	469	1521	14
2601	469	1522	8
2602	469	1502	9
2603	469	1507	4
2604	469	1499	7
2605	469	1480	8
2606	470	1496	9
2607	470	1523	3
2608	470	1493	5
2609	470	1486	6
2610	470	1494	5
2611	470	1495	11
2612	471	1524	7
2613	471	1491	11
2614	471	1515	14
2615	471	1477	5
2616	471	1525	5
2617	471	1503	12
2618	471	1526	11
2619	472	1527	6
2620	472	1528	11
2621	472	1529	10
2622	472	1491	8
2623	472	1521	14
2624	472	1530	4
2625	473	1531	4
2626	473	1529	6
2627	473	1491	7
2628	473	1532	14
2629	473	1533	5
2630	473	1534	4
2631	474	1535	4
2632	474	1491	2
2633	474	1521	14
2634	474	1536	9
2635	474	1525	5
2636	474	1503	7
2637	474	1537	11
2638	474	1495	9
2639	475	1538	5
2640	475	1490	6
2641	475	1491	11
2642	475	1521	14
2643	475	1516	9
2644	475	1517	9
2645	475	1526	9
2646	476	1528	13
2647	476	1529	11
2648	476	1539	10
2649	476	1540	9
2650	476	1541	9
2651	477	1542	3
2652	477	1525	4
2653	477	1498	4
2654	477	1543	7
2655	477	1495	11
2656	478	1544	11
2657	478	1545	11
2658	478	1546	2
2659	478	1547	6
2660	478	1479	12
2661	479	1548	8
2662	479	1516	6
2663	479	1517	9
2664	479	1498	4
2665	479	1549	4
2666	479	1495	11
2667	480	1550	13
2668	480	1491	11
2669	480	1515	14
2670	480	1477	8
2671	480	1525	3
2672	480	1503	5
2673	480	1526	8
2674	481	1529	10
2675	481	1491	11
2676	481	1532	14
2677	481	1477	6
2678	481	1478	6
2679	481	1493	5
2680	481	1526	11
2681	482	1551	6
2682	482	1552	8
2683	482	1491	5
2684	482	1521	14
2685	482	1516	3
2686	482	1478	4
2687	483	1553	2
2688	483	1554	5
2689	483	1555	11
2690	483	1556	8
2691	483	1511	4
2692	484	1557	5
2693	484	1491	6
2694	484	1492	14
2695	484	1477	3
2696	484	1540	2
2697	484	1503	6
2698	484	1526	8
2699	485	1558	4
2700	485	1559	4
2701	485	1560	11
2702	485	1561	9
2703	485	1562	4
2704	486	1563	4
2705	486	1564	3
2706	486	1565	9
2707	486	1566	9
2708	486	1562	8
2709	487	1567	3
2710	487	1568	7
2711	487	1569	8
2712	487	1511	2
2713	488	1570	2
2714	488	1571	9
2715	488	1572	3
2716	488	1573	11
2717	489	1574	5
2718	489	1575	5
2719	489	1576	5
2720	489	1577	5
2721	489	1530	2
2722	490	1578	2
2723	490	1579	9
2724	490	1572	7
2725	490	1580	7
2726	490	1581	7
2727	491	1582	3
2728	491	1583	2
2729	491	1560	7
2730	491	1584	7
2731	491	1562	5
2732	492	1585	1
2733	492	1586	9
2734	492	1587	7
2735	492	1588	3
2736	492	1581	5
2737	493	1589	11
2738	493	1590	8
2739	493	1591	2
2740	493	1592	6
2741	494	1593	5
2742	494	1594	9
2743	494	1595	11
2744	494	1580	9
2745	495	1596	3
2746	495	1597	9
2747	495	1598	7
2748	495	1599	3
2749	495	1530	7
2750	496	1583	3
2751	496	1600	3
2752	496	1560	7
2753	496	1601	8
2754	496	1602	13
2755	497	1583	3
2756	497	1603	3
2757	497	1576	7
2758	497	1604	1
2759	497	1602	9
2760	498	1605	4
2761	498	1568	7
2762	498	1606	7
2763	498	1530	1
2764	499	1607	8
2765	499	1608	9
2766	499	1609	7
2767	499	1610	3
2768	499	1562	6
2769	500	1611	11
2770	500	1612	9
2771	500	1613	8
2772	500	1614	7
2773	500	1592	3
2774	501	1615	2
2775	501	1616	7
2776	501	1617	11
2777	501	1618	3
2778	501	1511	5
2779	502	1619	12
2780	502	1560	8
2781	502	1601	9
2782	502	1602	6
2783	503	1620	2
2784	503	1621	1
2785	503	1571	13
2786	503	1622	7
2787	503	1511	3
2788	504	1623	1
2789	504	1624	7
2790	504	1587	6
2791	504	1625	5
2792	504	1581	7
2793	505	1626	5
2794	505	1627	5
2795	505	1628	9
2796	505	1569	9
2797	505	1511	2
2798	506	1629	7
2799	506	1630	9
2800	506	1590	5
2801	506	1592	9
2802	507	1575	5
2803	507	1631	9
2804	507	1632	1
2805	507	1633	5
2806	507	1546	4
2807	508	1634	2
2808	508	1635	3
2809	508	1636	3
2810	508	1546	2
2811	508	1516	4
2812	509	1637	2
2813	509	1638	5
2814	509	1639	5
2815	509	1530	4
2816	509	1640	3
2817	510	1641	3
2818	510	1642	3
2819	510	1643	8
2820	510	1590	7
2821	510	1581	9
2822	511	1642	4
2823	511	1644	9
2824	511	1572	7
2825	511	1645	8
2826	511	1592	7
2827	512	1646	4
2828	512	1647	8
2829	512	1648	9
2830	512	1592	5
2831	513	1575	11
2832	513	1612	11
2833	513	1649	12
2834	513	1592	12
2835	513	1516	11
2836	514	1650	3
2837	514	1638	7
2838	514	1584	9
2839	514	1651	5
2840	514	1546	3
2841	515	1652	4
2842	515	1571	9
2843	515	1572	5
2844	515	1533	3
2845	516	1653	3
2846	516	1586	9
2847	516	1654	6
2848	516	1530	7
2849	517	1655	2
2850	517	1652	4
2851	517	1571	8
2852	517	1572	6
2853	517	1533	4
2854	518	1656	4
2855	518	1643	9
2856	518	1587	6
2857	518	1651	2
2858	518	1511	6
2859	519	1641	3
2860	519	1624	9
2861	519	1572	9
2862	519	1657	4
2863	519	1581	8
2864	520	1658	3
2865	520	1659	9
2866	520	1590	7
2867	520	1660	1
2868	520	1530	5
2869	520	1516	6
2870	521	1623	1
2871	521	1624	9
2872	521	1587	6
2873	521	1625	6
2874	521	1581	8
2875	522	1661	6
2876	522	1575	8
2877	522	1662	7
2878	522	1663	5
2879	522	1546	2
2880	523	1664	5
2881	523	1665	11
2882	523	1666	8
2883	523	1667	4
2884	523	1581	9
2885	524	1583	2
2886	524	1668	2
2887	524	1669	6
2888	524	1631	7
2889	524	1511	3
2890	525	1670	4
2891	525	1671	4
2892	525	1528	11
2893	525	1672	8
2894	525	1546	6
2895	526	1673	7
2896	526	1674	10
2897	526	1622	8
2898	526	1675	7
2899	526	1530	7
2900	527	1676	3
2901	527	1643	13
2902	527	1631	9
2903	527	1618	3
2904	527	1530	8
2905	528	1677	4
2906	528	1678	3
2907	528	1665	7
2908	528	1679	9
2909	528	1613	8
2910	528	1530	8
2911	529	1680	7
2912	529	1681	9
2913	529	1682	12
2914	529	1530	7
2915	529	1683	4
2916	530	1594	9
2917	530	1590	9
2918	530	1684	5
2919	530	1511	9
2920	531	1685	5
2921	531	1686	1
2922	531	1613	4
2923	531	1687	7
2924	531	1688	1
2925	532	1689	5
2926	532	1686	2
2927	532	1690	3
2928	532	1645	6
2929	532	1688	3
2930	533	1691	4
2931	533	1692	8
2932	533	1693	6
2933	533	1694	1
2934	533	1695	3
2935	534	1696	5
2936	534	1697	7
2937	534	1698	5
2938	534	1663	3
2939	534	1699	9
2940	535	1700	5
2941	535	1701	4
2942	535	1702	1
2943	535	1703	1
2944	535	1704	4
2945	536	1705	4
2946	536	1706	6
2947	536	1707	7
2948	536	1708	2
2949	536	1699	3
2950	537	1709	6
2951	537	1710	8
2952	537	1707	6
2953	537	1711	3
2954	537	1712	11
2955	538	1551	5
2956	538	1713	5
2957	538	1714	5
2958	538	1715	8
2959	538	1699	8
2960	539	1716	3
2961	539	1717	6
2962	539	1718	2
2963	539	1719	1
2964	539	1720	8
2965	540	1691	3
2966	540	1692	4
2967	540	1693	4
2968	540	1694	1
2969	540	1695	2
2970	541	1551	4
2971	541	1721	2
2972	541	1697	8
2973	541	1722	1
2974	541	1699	1
2975	542	1723	3
2976	542	1724	6
2977	542	1701	8
2978	542	1725	1
2979	542	1704	7
2980	543	1691	3
2981	543	1692	5
2982	543	1693	11
2983	543	1694	6
2984	543	1695	8
2985	544	1709	5
2986	544	1710	7
2987	544	1707	7
2988	544	1711	2
2989	544	1712	7
2990	545	1691	3
2991	545	1692	6
2992	545	1693	6
2993	545	1694	1
2994	545	1695	1
2995	546	1709	5
2996	546	1710	1
2997	546	1707	4
2998	546	1711	3
2999	546	1712	1
3000	547	1716	4
3001	547	1717	3
3002	547	1718	3
3003	547	1719	3
3004	547	1720	1
3005	548	1726	4
3006	548	1701	11
3007	548	1702	6
3008	548	1727	5
3009	548	1704	8
3010	549	1728	2
3011	549	1729	5
3012	549	1701	7
3013	549	1704	5
3014	549	1730	3
3015	550	1658	1
3016	550	1731	5
3017	550	1732	1
3018	550	1733	8
3019	550	1533	4
3020	551	1734	5
3021	551	1735	6
3022	551	1707	6
3023	551	1736	2
3024	551	1533	4
3025	552	1737	6
3026	552	1738	1
3027	552	1739	2
3028	552	1533	3
3029	552	1740	3
3030	553	1709	6
3031	553	1710	8
3032	553	1707	7
3033	553	1711	3
3034	553	1712	11
3035	554	1709	6
3036	554	1710	5
3037	554	1707	7
3038	554	1711	5
3039	554	1712	7
3040	555	1741	3
3041	555	1686	2
3042	555	1690	2
3043	555	1742	5
3044	555	1688	3
3045	556	1716	4
3046	556	1717	4
3047	556	1718	1
3048	556	1719	1
3049	556	1720	7
3050	557	1716	3
3051	557	1717	5
3052	557	1718	3
3053	557	1719	2
3054	557	1720	4
3055	558	1743	7
3056	558	1744	8
3057	558	1698	4
3058	558	1745	4
3059	558	1699	8
3060	559	1746	4
3061	559	1686	3
3062	559	1739	3
3063	559	1747	8
3064	559	1688	5
3065	560	1709	5
3066	560	1710	8
3067	560	1707	4
3068	560	1711	4
3069	560	1712	9
3070	561	1748	3
3071	561	1729	5
3072	561	1701	11
3073	561	1749	6
3074	561	1704	8
3075	562	1750	5
3076	562	1701	4
3077	562	1613	7
3078	562	1751	1
3079	562	1704	4
3080	563	1685	5
3081	563	1686	1
3082	563	1580	4
3083	563	1752	1
3084	563	1688	2
3085	564	1753	5
3086	564	1701	5
3087	564	1702	2
3088	564	1733	6
3089	564	1704	5
3090	565	1685	4
3091	565	1686	4
3092	565	1754	2
3093	565	1755	2
3094	565	1688	3
3095	566	1756	3
3096	566	1686	6
3097	566	1732	7
3098	566	1757	1
3099	566	1688	3
3100	567	1758	4
3101	567	1701	11
3102	567	1754	2
3103	567	1759	5
3104	567	1704	5
3105	568	1760	6
3106	568	1721	6
3107	568	1761	9
3108	568	1762	5
3109	568	1699	9
3110	569	1709	6
3111	569	1710	8
3112	569	1707	6
3113	569	1711	5
3114	569	1712	2
3115	570	1709	6
3116	570	1710	6
3117	570	1707	4
3118	570	1711	7
3119	570	1712	1
3120	571	1700	5
3121	571	1701	7
3122	571	1580	7
3123	571	1749	5
3124	571	1704	4
3125	572	1743	7
3126	572	1763	1
3127	572	1714	4
3128	572	1764	3
3129	572	1704	5
3130	573	1691	3
3131	573	1692	4
3132	573	1693	5
3133	573	1694	1
3134	573	1695	1
3135	574	1709	5
3136	574	1710	8
3137	574	1707	8
3138	574	1711	6
3139	574	1712	5
3140	575	1765	3
3141	575	1766	3
3142	575	1686	4
3143	575	1732	2
3144	575	1688	2
3145	576	1716	4
3146	576	1717	6
3147	576	1718	3
3148	576	1719	1
3149	576	1720	1
3150	577	1767	5
3151	577	1768	7
3152	577	1718	1
3153	577	1769	5
3154	577	1699	9
3155	578	1691	4
3156	578	1692	5
3157	578	1693	2
3158	578	1694	2
3159	578	1695	3
3160	579	1716	2
3161	579	1717	4
3162	579	1718	1
3163	579	1719	1
3164	579	1720	1
3165	580	1696	5
3166	580	1721	4
3167	580	1697	9
3168	580	1770	6
3169	580	1699	5
3170	581	1771	3
3171	581	1721	7
3172	581	1772	8
3173	581	1651	2
3174	581	1699	7
3175	582	1691	2
3176	582	1692	4
3177	582	1693	5
3178	582	1694	1
3179	582	1695	1
3180	583	1691	4
3181	583	1692	5
3182	583	1693	9
3183	583	1694	2
3184	583	1695	2
3185	584	1691	3
3186	584	1692	5
3187	584	1693	6
3188	584	1694	2
3189	584	1695	3
3190	585	1773	3
3191	585	1686	2
3192	585	1739	5
3193	585	1774	1
3194	585	1688	3
3195	586	1709	7
3196	586	1710	6
3197	586	1707	7
3198	586	1711	6
3199	586	1712	6
3200	587	1748	9
3201	587	1701	6
3202	587	1613	3
3203	587	1747	9
3204	587	1704	1
3205	588	1737	5
3206	588	1763	1
3207	588	1707	1
3208	588	1747	1
3209	588	1704	1
3210	589	1775	4
3211	589	1701	1
3212	589	1684	2
3213	589	1776	1
3214	589	1704	3
3215	590	1728	3
3216	590	1701	1
3217	590	1702	4
3218	590	1776	2
3219	590	1704	1
3220	591	1746	4
3221	591	1777	4
3222	591	1701	6
3223	591	1684	3
3224	591	1704	1
3225	592	1775	4
3226	592	1778	5
3227	592	1686	4
3228	592	1779	4
3229	592	1688	5
3230	593	1780	4
3231	593	1731	9
3232	593	1684	4
3233	593	1781	5
3234	593	1699	1
3235	594	1782	5
3236	594	1686	1
3237	594	1613	2
3238	594	1783	2
3239	594	1688	3
3240	595	1513	5
3241	595	1784	6
3242	595	1613	6
3243	595	1785	5
3244	595	1699	8
3245	596	1716	3
3246	596	1717	3
3247	596	1718	1
3248	596	1719	1
3249	596	1720	1
3250	597	1709	6
3251	597	1710	6
3252	597	1707	5
3253	597	1711	3
3254	597	1712	6
3255	598	1786	8
3256	598	1701	5
3257	598	1702	2
3258	598	1747	10
3259	598	1704	6
3260	599	1709	6
3261	599	1710	9
3262	599	1707	7
3263	599	1711	2
3264	599	1712	7
3265	600	1709	6
3266	600	1710	11
3267	600	1707	8
3268	600	1711	6
3269	600	1712	7
3270	601	1787	5
3271	601	1692	3
3272	601	1788	2
3273	601	1789	1
3274	601	1699	1
3275	602	1691	3
3276	602	1692	7
3277	602	1693	9
3278	602	1694	1
3279	602	1695	4
3280	603	1737	5
3281	603	1686	3
3282	603	1790	2
3283	603	1688	4
3284	603	1791	3
3285	604	1792	3
3286	604	1692	6
3287	604	1693	3
3288	604	1694	2
3289	604	1695	2
3290	605	1691	5
3291	605	1692	4
3292	605	1693	2
3293	605	1694	1
3294	605	1695	1
3295	606	1691	4
3296	606	1692	6
3297	606	1693	8
3298	606	1694	2
3299	606	1695	4
3300	607	1691	4
3301	607	1692	7
3302	607	1693	8
3303	607	1694	2
3304	607	1695	5
3305	608	1748	5
3306	608	1701	6
3307	608	1718	1
3308	608	1793	1
3309	608	1704	5
3310	609	1716	3
3311	609	1717	9
3312	609	1718	2
3313	609	1719	1
3314	609	1720	5
3315	610	1766	6
3316	610	1701	6
3317	610	1794	6
3318	610	1704	6
3319	610	1543	8
3320	611	1716	4
3321	611	1717	6
3322	611	1718	2
3323	611	1719	2
3324	611	1720	8
3325	612	1691	5
3326	612	1692	8
3327	612	1693	8
3328	612	1694	4
3329	612	1695	1
3330	613	1691	4
3331	613	1692	8
3332	613	1693	9
3333	613	1694	3
3334	613	1695	8
3335	614	1716	3
3336	614	1717	7
3337	614	1718	3
3338	614	1719	1
3339	614	1720	3
3340	615	1709	6
3341	615	1710	7
3342	615	1707	6
3343	615	1711	3
3344	615	1712	2
3345	616	1696	4
3346	616	1795	11
3347	616	1707	6
3348	616	1764	4
3349	616	1699	1
3350	617	1709	4
3351	617	1710	9
3352	617	1707	7
3353	617	1711	6
3354	617	1712	4
3355	618	1716	5
3356	618	1717	9
3357	618	1718	4
3358	618	1719	1
3359	618	1720	9
3360	619	1796	4
3361	619	1797	5
3362	619	1701	6
3363	619	1798	1
3364	619	1704	4
3365	620	1723	4
3366	620	1701	8
3367	620	1718	3
3368	620	1799	9
3369	620	1704	6
3370	621	1716	3
3371	621	1717	9
3372	621	1718	1
3373	621	1719	3
3374	621	1720	4
3375	622	1691	3
3376	622	1692	6
3377	622	1693	7
3378	622	1694	4
3379	622	1695	5
3380	623	1709	7
3381	623	1710	9
3382	623	1707	7
3383	623	1711	6
3384	623	1712	10
3385	624	1800	5
3386	624	1706	4
3387	624	1745	2
3388	624	1562	4
3389	624	1549	2
3390	625	1558	3
3391	625	1554	6
3392	625	1801	7
3393	625	1562	5
3394	625	1543	6
3395	626	1582	1
3396	626	1784	5
3397	626	1714	5
3398	626	1498	2
3399	626	1562	1
3400	627	1802	11
3401	627	1803	10
3402	627	1804	7
3403	627	1805	11
3404	627	1806	9
3405	627	1807	1
3406	628	1808	6
3407	628	1809	4
3408	628	1810	3
3409	628	1811	2
3410	628	1812	3
3411	628	1813	14
3412	628	1814	1
3413	628	1815	11
3414	629	1816	6
3415	629	1812	3
3416	629	1813	14
3417	629	1804	5
3418	629	1817	4
3419	629	1805	2
3420	629	1818	4
3421	630	1819	4
3422	630	1820	3
3423	630	1812	4
3424	630	1821	14
3425	630	1822	9
3426	631	1823	3
3427	631	1824	5
3428	631	1825	2
3429	631	1826	7
3430	631	1827	10
3431	632	1828	7
3432	632	1814	5
3433	632	1829	7
3434	632	1826	7
3435	632	1830	9
3436	633	1831	13
3437	633	1832	4
3438	633	1833	4
3439	633	1834	7
3440	633	1835	9
3441	633	1836	3
3442	634	1837	2
3443	634	1838	7
3444	634	1829	13
3445	634	1839	7
3446	634	1840	3
3447	635	1841	8
3448	635	1812	3
3449	635	1813	14
3450	635	1838	7
3451	635	1817	1
3452	635	1805	1
3453	635	1818	7
3454	636	1842	13
3455	636	1843	8
3456	636	1844	5
3457	636	1829	13
3458	636	1845	5
3459	636	1846	2
3460	636	1847	12
3461	637	1848	9
3462	637	1812	11
3463	637	1849	14
3464	637	1814	5
3465	637	1826	8
3466	638	1850	10
3467	638	1851	6
3468	638	1838	6
3469	638	1814	6
3470	638	1846	2
3471	638	1817	7
3472	638	1830	13
3473	639	1852	7
3474	639	1853	7
3475	639	1812	4
3476	639	1813	14
3477	639	1804	6
3478	639	1835	9
3479	639	1854	8
3480	640	1855	3
3481	640	1856	4
3482	640	1857	3
3483	640	1812	11
3484	640	1849	14
3485	640	1833	7
3486	640	1858	9
3487	641	1859	4
3488	641	1812	5
3489	641	1821	14
3490	641	1804	6
3491	641	1860	4
3492	641	1861	3
3493	641	1834	4
3494	642	1862	9
3495	642	1863	5
3496	642	1833	7
3497	642	1864	7
3498	642	1829	4
3499	642	1865	4
3500	643	1866	12
3501	643	1867	11
3502	643	1868	8
3503	643	1869	9
3504	643	1870	12
3505	643	1854	5
3506	644	1871	2
3507	644	1872	2
3508	644	1830	9
3509	644	1873	6
3510	644	1874	4
3511	644	1875	2
3512	645	1876	7
3513	645	1877	11
3514	645	1829	13
3515	645	1861	13
3516	645	1870	13
3517	646	1878	1
3518	646	1879	2
3519	646	1880	5
3520	646	1830	8
3521	646	1874	3
3522	647	1841	13
3523	647	1881	4
3524	647	1804	5
3525	647	1882	5
3526	647	1860	2
3527	647	1861	7
3528	648	1883	9
3529	648	1884	7
3530	648	1814	3
3531	648	1817	4
3532	648	1839	8
3533	648	1818	7
3534	649	1885	4
3535	649	1833	3
3536	649	1864	9
3537	649	1829	6
3538	650	1886	6
3539	650	1887	9
3540	650	1888	5
3541	650	1832	7
3542	650	1873	11
3543	651	1889	8
3544	651	1812	5
3545	651	1890	14
3546	651	1864	7
3547	651	1817	5
3548	651	1839	6
3549	651	1891	8
3550	652	1892	8
3551	652	1893	7
3552	652	1868	7
3553	652	1894	9
3554	652	1895	9
3555	653	1896	11
3556	653	1897	9
3557	653	1898	3
3558	653	1899	2
3559	653	1858	9
3560	654	1900	8
3561	654	1901	6
3562	654	1816	11
3563	654	1832	8
3564	654	1902	11
3565	655	1903	3
3566	655	1900	9
3567	655	1904	6
3568	655	1905	7
3569	655	1906	3
3570	655	1907	1
3571	656	1908	4
3572	656	1852	8
3573	656	1909	3
3574	656	1910	4
3575	656	1873	5
3576	656	1865	6
3577	657	1911	3
3578	657	1912	8
3579	657	1913	11
3580	657	1914	9
3581	657	1873	7
3582	657	1902	3
3583	658	1915	9
3584	658	1916	9
3585	658	1917	6
3586	658	1918	5
3587	658	1865	11
3588	659	1887	10
3589	659	1919	11
3590	659	1904	8
3591	659	1920	4
3592	659	1921	4
3593	659	1922	11
3594	660	1923	5
3595	660	1897	7
3596	660	1924	5
3597	660	1922	9
3598	660	1902	11
3599	661	1925	10
3600	661	1926	5
3601	661	1832	8
3602	661	1835	11
3603	661	1854	8
3604	662	1927	5
3605	662	1928	11
3606	662	1909	8
3607	662	1835	7
3608	662	1854	6
3609	663	1915	9
3610	663	1929	4
3611	663	1930	2
3612	663	1918	5
3613	663	1865	9
3614	664	1931	8
3615	664	1932	6
3616	664	1933	7
3617	664	1832	5
3618	664	1934	7
3619	664	1865	8
3620	665	1935	8
3621	665	1936	9
3622	665	1937	7
3623	665	1938	7
3624	665	1835	1
3625	665	1865	4
3626	666	1939	5
3627	666	1940	3
3628	666	1941	6
3629	666	1916	8
3630	666	1942	8
3631	666	1902	8
3632	667	1943	13
3633	667	1944	9
3634	667	1909	11
3635	667	1835	7
3636	667	1854	8
3637	668	1945	7
3638	668	1946	9
3639	668	1887	9
3640	668	1947	13
3641	668	1948	8
3642	668	1949	10
3643	669	1950	3
3644	669	1951	8
3645	669	1952	8
3646	669	1832	6
3647	669	1873	7
3648	669	1865	7
3649	670	1953	7
3650	670	1954	9
3651	670	1832	7
3652	670	1934	6
3653	670	1865	11
3654	671	1955	4
3655	671	1956	9
3656	671	1916	10
3657	671	1957	5
3658	671	1873	8
3659	671	1854	6
3660	672	1958	9
3661	672	1959	11
3662	672	1960	6
3663	672	1840	4
3664	673	1887	9
3665	673	1961	11
3666	673	1909	9
3667	673	1962	4
3668	673	1832	9
3669	673	1873	7
3670	674	1963	6
3671	674	1915	10
3672	674	1964	5
3673	674	1957	6
3674	674	1835	9
3675	675	1887	10
3676	675	1941	6
3677	675	1897	11
3678	675	1883	6
3679	675	1954	10
3680	675	1934	8
3681	676	1965	8
3682	676	1888	2
3683	676	1966	4
3684	676	1967	6
3685	676	1854	5
3686	677	1968	2
3687	677	1969	4
3688	677	1970	9
3689	677	1971	7
3690	678	1972	3
3691	678	1973	9
3692	678	1974	1
3693	678	1922	11
3694	678	1902	11
3695	679	1975	5
3696	679	1900	13
3697	679	1901	8
3698	679	1976	3
3699	679	1934	9
3700	679	1902	11
3701	680	1887	9
3702	680	1977	9
3703	680	1978	8
3704	680	1979	6
3705	680	1922	11
3706	681	1980	3
3707	681	1981	5
3708	681	1953	9
3709	681	1982	9
3710	681	1934	11
3711	681	1902	11
3712	682	1983	6
3713	682	1944	9
3714	682	1984	6
3715	682	1883	11
3716	682	1934	9
3717	683	1985	2
3718	683	1986	4
3719	683	1913	13
3720	683	1987	9
3721	683	1835	9
3722	683	1854	6
3723	684	1973	8
3724	684	1914	6
3725	684	1905	4
3726	684	1988	2
3727	684	1895	7
3728	684	1865	6
3729	685	1989	5
3730	685	1990	10
3731	685	1991	11
3732	685	1992	7
3733	685	1873	9
3734	685	1854	7
3735	686	1993	3
3736	686	1994	7
3737	686	1992	5
3738	686	1918	4
3739	686	1865	8
3740	687	1956	9
3741	687	1992	9
3742	687	1995	3
3743	687	1832	8
3744	687	1934	9
3745	687	1865	11
3746	688	1996	4
3747	688	1961	9
3748	688	1938	7
3749	688	1853	6
3750	688	1934	9
3751	688	1902	11
3752	689	1997	8
3753	689	1829	3
3754	689	1834	9
3755	689	1839	9
3756	689	1836	2
3757	689	1902	11
3758	690	1998	6
3759	690	1999	6
3760	690	2000	9
3761	690	2001	4
3762	690	1922	6
3763	690	1854	6
3764	691	2002	5
3765	691	2003	9
3766	691	1997	8
3767	691	2004	4
3768	691	1873	8
3769	691	1902	11
3770	692	1999	6
3771	692	1897	11
3772	692	2005	10
3773	692	2001	4
3774	692	1934	11
3775	692	1854	6
3776	693	2006	4
3777	693	2007	3
3778	693	1867	8
3779	693	2008	7
3780	693	1971	5
3781	693	1902	7
3782	694	1953	2
3783	694	1877	4
3784	694	1832	1
3785	694	1873	2
3786	694	2009	3
3787	695	2010	6
3788	695	1852	7
3789	695	1917	8
3790	695	2011	11
3791	695	1835	11
3792	695	1854	14
3793	696	1964	8
3794	696	2012	1
3795	696	2013	3
3796	696	1934	7
3797	696	1854	7
3798	697	2014	6
3799	697	2015	4
3800	697	1925	6
3801	697	2016	5
3802	697	2017	7
3803	697	2018	5
3804	698	2019	9
3805	698	2020	7
3806	698	2021	7
3807	698	1922	9
3808	698	1865	8
3809	699	1945	9
3810	699	1961	4
3811	699	1938	11
3812	699	1922	9
3813	699	1902	8
3814	700	2022	2
3815	700	1945	2
3816	700	1868	6
3817	700	1934	11
3818	700	1854	6
3819	701	2023	4
3820	701	2024	4
3821	701	2025	5
3822	701	2026	1
3823	701	2027	1
3824	702	2028	3
3825	702	2029	5
3826	702	1853	8
3827	702	2030	1
3828	702	2031	7
3829	703	2032	3
3830	703	2033	5
3831	703	2034	7
3832	703	2035	1
3833	703	1918	6
3834	704	2036	6
3835	704	2037	7
3836	704	2038	4
3837	704	1858	8
3838	704	2009	4
3839	705	1859	4
3840	705	2039	9
3841	705	2040	5
3842	705	2041	1
3843	705	1858	12
3844	706	2023	5
3845	706	2042	4
3846	706	2043	3
3847	706	2029	7
3848	706	2044	4
3849	706	1858	3
3850	707	2045	4
3851	707	2037	5
3852	707	2046	3
3853	707	2047	4
3854	707	2048	6
3855	708	2049	6
3856	708	2050	5
3857	708	2037	8
3858	708	1995	2
3859	708	1858	7
3860	709	2051	3
3861	709	2039	9
3862	709	2052	6
3863	709	2053	2
3864	709	1942	7
3865	710	2054	3
3866	710	1989	3
3867	710	2034	5
3868	710	2035	1
3869	710	2027	2
3870	711	2055	3
3871	711	2056	3
3872	711	2029	9
3873	711	2057	3
3874	711	1858	2
3875	712	1809	2
3876	712	2058	9
3877	712	1853	5
3878	712	2059	4
3879	712	1942	5
3880	713	2060	7
3881	713	2061	4
3882	713	2062	8
3883	713	1988	3
3884	713	2027	13
3885	714	2045	3
3886	714	2063	7
3887	714	2046	4
3888	714	2064	1
3889	714	1907	4
3890	715	2065	4
3891	715	2034	7
3892	715	2066	6
3893	715	2035	1
3894	715	2027	3
3895	716	2067	2
3896	716	2068	4
3897	716	2063	4
3898	716	2041	1
3899	716	1907	2
3900	717	2010	1
3901	717	2069	7
3902	717	1883	7
3903	717	2013	3
3904	717	1942	1
3905	718	2070	4
3906	718	2071	8
3907	718	2052	11
3908	718	2072	4
3909	718	2031	8
3910	719	2022	2
3911	719	2073	3
3912	719	2074	11
3913	719	2075	1
3914	719	2076	2
3915	719	1918	6
3916	720	2077	3
3917	720	2078	4
3918	720	1816	4
3919	720	2079	2
3920	720	2031	6
3921	721	2080	3
3922	721	2081	6
3923	721	2082	9
3924	721	2083	1
3925	721	1907	1
3926	722	2051	2
3927	722	2084	2
3928	722	2029	5
3929	722	2027	1
3930	722	2085	2
3931	723	2086	5
3932	723	2015	7
3933	723	2087	9
3934	723	2088	3
3935	723	2048	2
3936	724	2089	3
3937	724	2068	6
3938	724	2090	8
3939	724	2026	3
3940	724	1895	5
3941	725	2091	4
3942	725	2092	3
3943	725	2052	6
3944	725	2093	5
3945	725	1918	3
3946	726	2094	4
3947	726	2095	3
3948	726	1970	7
3949	726	2053	2
3950	726	1942	11
3951	727	2095	3
3952	727	2096	4
3953	727	2052	5
3954	727	1883	7
3955	727	1942	4
3956	728	2097	5
3957	728	2043	6
3958	728	2090	8
3959	728	2098	2
3960	728	1942	7
3961	729	2045	3
3962	729	2099	7
3963	729	2029	9
3964	729	2072	2
3965	729	2031	3
3966	730	2045	3
3967	730	2063	6
3968	730	2046	4
3969	730	2059	4
3970	730	1907	3
3971	731	2022	2
3972	731	2100	3
3973	731	2101	9
3974	731	2102	4
3975	731	1918	8
3976	732	2103	3
3977	732	1958	9
3978	732	2104	4
3979	732	2013	4
3980	732	1942	9
3981	733	2063	6
3982	733	2105	4
3983	733	2106	2
3984	733	2026	6
3985	733	1942	3
3986	734	1931	4
3987	734	2039	8
3988	734	2066	3
3989	734	2107	3
3990	734	2027	1
3991	735	2108	3
3992	735	2025	6
3993	735	2106	1
3994	735	2109	4
3995	735	2031	4
3996	736	2110	12
3997	736	2025	10
3998	736	2066	8
3999	736	2111	6
4000	736	2031	8
4001	737	2084	4
4002	737	2071	7
4003	737	2112	1
4004	737	2113	3
4005	737	2031	7
4006	738	2045	4
4007	738	2114	9
4008	738	2115	2
4009	738	2041	1
4010	738	1858	8
4011	739	2089	4
4012	739	2068	6
4013	739	2090	9
4014	739	2026	1
4015	739	1895	2
4016	740	2045	3
4017	740	1933	8
4018	740	2046	3
4019	740	2064	1
4020	740	1907	1
4021	741	1859	3
4022	741	2116	4
4023	741	2039	10
4024	741	2117	4
4025	741	1858	5
4026	742	2014	5
4027	742	2096	3
4028	742	1816	3
4029	742	2118	4
4030	742	1907	3
4031	743	2054	3
4032	743	2034	9
4033	743	2066	3
4034	743	2035	1
4035	743	2027	2
4036	744	2089	3
4037	744	2019	6
4038	744	2063	8
4039	744	2001	4
4040	744	1895	5
4041	745	2119	4
4042	745	2120	7
4043	745	2121	9
4044	745	2122	4
4045	745	1942	4
4046	746	2123	4
4047	746	2039	8
4048	746	1883	6
4049	746	2026	1
4050	746	1942	1
4051	747	2039	9
4052	747	2106	3
4053	747	2118	2
4054	747	2035	4
4055	747	1858	6
4056	748	2042	3
4057	748	2034	8
4058	748	2124	1
4059	748	1881	3
4060	748	2027	8
4061	749	1940	2
4062	749	1970	6
4063	749	2125	1
4064	749	2118	9
4065	749	1895	1
4066	750	2049	6
4067	750	1886	2
4068	750	2037	8
4069	750	2066	6
4070	750	2126	3
4071	750	1858	5
4072	751	2049	5
4073	751	2037	7
4074	751	2066	9
4075	751	2038	6
4076	751	1858	8
4077	752	2127	2
4078	752	2114	5
4079	752	2041	1
4080	752	2031	1
4081	752	2128	6
4082	753	2054	4
4083	753	2034	11
4084	753	2066	8
4085	753	2079	1
4086	753	2027	7
4087	754	2065	3
4088	754	1989	2
4089	754	2034	11
4090	754	2035	1
4091	754	2027	4
4092	755	2129	1
4093	755	2099	3
4094	755	2130	9
4095	755	2117	1
4096	755	2031	7
4097	756	2129	4
4098	756	2099	4
4099	756	2130	8
4100	756	2131	3
4101	756	2027	9
4102	757	2132	2
4103	757	2007	9
4104	757	2090	8
4105	757	2083	2
4106	757	1858	5
4107	758	2133	3
4108	758	2029	2
4109	758	1895	1
4110	758	2128	4
4111	758	1875	1
4112	759	2123	2
4113	759	2084	3
4114	759	2039	4
4115	759	2134	1
4116	759	2031	1
4117	760	2135	5
4118	760	2039	2
4119	760	2136	9
4120	760	2027	1
4121	760	1836	1
4122	761	2137	4
4123	761	2138	7
4124	761	2007	8
4125	761	2039	9
4126	761	2031	5
4127	762	2108	3
4128	762	2130	9
4129	762	1917	6
4130	762	2111	4
4131	762	2031	6
4132	763	2139	5
4133	763	1951	5
4134	763	2029	7
4135	763	2026	2
4136	763	1858	2
4137	764	2100	3
4138	764	2140	2
4139	764	2141	4
4140	764	2142	2
4141	764	2031	2
4142	765	2143	5
4143	765	2037	7
4144	765	1917	6
4145	765	2059	7
4146	765	1858	12
4147	766	2144	5
4148	766	1970	4
4149	766	1883	6
4150	766	2026	1
4151	766	1942	1
4152	767	2045	4
4153	767	2063	6
4154	767	2046	3
4155	767	2064	1
4156	767	1907	5
4157	768	2145	4
4158	768	2039	8
4159	768	2076	2
4160	768	2001	1
4161	768	2031	7
4162	769	2146	3
4163	769	2045	3
4164	769	2063	7
4165	769	2064	1
4166	769	1907	3
4167	770	2089	5
4168	770	2068	6
4169	770	2147	9
4170	770	2026	1
4171	770	1895	6
4172	771	2056	4
4173	771	2029	2
4174	771	1853	2
4175	771	1858	1
4176	771	2148	2
4177	772	2149	4
4178	772	2150	3
4179	772	2034	11
4180	772	2035	1
4181	772	1918	6
4182	773	2151	5
4183	773	2029	8
4184	773	1853	6
4185	773	1905	5
4186	773	1942	5
4187	774	2054	5
4188	774	2034	11
4189	774	2079	1
4190	774	2027	4
4191	774	1840	2
4192	775	2054	5
4193	775	2034	2
4194	775	2066	4
4195	775	2079	1
4196	775	2027	1
4197	776	2054	4
4198	776	2034	8
4199	776	2066	6
4200	776	2035	2
4201	776	2027	6
4202	777	2065	4
4203	777	2034	11
4204	777	2066	7
4205	777	2079	2
4206	777	2027	4
4207	778	2152	3
4208	778	2153	2
4209	778	2039	7
4210	778	2154	4
4211	778	2155	4
4212	778	2031	2
4213	779	2144	7
4214	779	1990	8
4215	779	1933	9
4216	779	2026	4
4217	779	1942	3
4218	780	2143	5
4219	780	2156	8
4220	780	1853	6
4221	780	2059	5
4222	780	1942	8
4223	781	2010	1
4224	781	1970	11
4225	781	1883	8
4226	781	2157	9
4227	781	1895	9
4228	782	2054	6
4229	782	2034	11
4230	782	2079	2
4231	782	2027	3
4232	782	1840	4
4233	783	2158	6
4234	783	2034	13
4235	783	1926	4
4236	783	2159	5
4237	783	1895	9
4238	784	2010	1
4239	784	1933	7
4240	784	1883	8
4241	784	2160	2
4242	784	1942	5
4243	785	2161	5
4244	785	2063	6
4245	785	2046	6
4246	785	2059	4
4247	785	1907	1
4248	786	2127	2
4249	786	2162	7
4250	786	2163	2
4251	786	2117	2
4252	786	1858	3
4253	787	2022	4
4254	787	2068	5
4255	787	2063	8
4256	787	2026	3
4257	787	1907	2
4258	788	2010	3
4259	788	1970	13
4260	788	2157	8
4261	788	1949	7
4262	788	1942	7
4263	789	2164	2
4264	789	2039	8
4265	789	2165	3
4266	789	2031	2
4267	789	1875	1
4268	790	2166	5
4269	790	2167	3
4270	790	2090	11
4271	790	2026	4
4272	790	2031	11
4273	791	2089	3
4274	791	2096	8
4275	791	2066	7
4276	791	2168	4
4277	791	1942	6
4278	792	2032	3
4279	792	2054	4
4280	792	2034	11
4281	792	2035	1
4282	792	2027	5
4283	793	2067	3
4284	793	2068	6
4285	793	2063	9
4286	793	2041	1
4287	793	2048	5
4288	794	2084	5
4289	794	2034	9
4290	794	2169	3
4291	794	1880	5
4292	794	1895	4
4293	795	2084	8
4294	795	2114	8
4295	795	2169	11
4296	795	2170	4
4297	795	1895	6
4298	796	2171	1
4299	796	2114	7
4300	796	1957	1
4301	796	1895	1
4302	796	1836	1
4303	797	2172	6
4304	797	2173	5
4305	797	2174	3
4306	798	2175	5
4307	799	2176	3
4308	800	2177	4
4309	800	2178	5
4310	801	2176	11
4311	802	2179	13
4312	802	2180	4
4313	803	2176	3
4314	804	2176	1
4315	805	2176	3
4316	806	2181	3
4317	806	2182	11
4318	807	2172	4
4319	807	2183	7
4320	808	2184	7
4321	808	2185	8
4322	809	2186	4
4323	810	2187	3
4324	810	2188	11
4325	811	2189	7
4326	811	2174	3
4327	812	2174	2
4328	812	2190	13
4329	813	2191	8
4330	814	2192	2
4331	814	2193	4
4332	815	2194	5
4333	815	2190	5
4334	816	2195	11
4335	816	2196	10
4336	817	2197	7
4337	817	2188	9
4338	818	2190	11
4339	819	2198	7
4340	820	2190	4
4341	821	2195	2
4342	821	2188	9
4343	822	2199	8
4344	823	2200	8
4345	824	2201	6
4346	824	2186	4
4347	825	2185	3
4348	826	2202	5
4349	826	2203	1
4350	827	2204	11
4351	827	2190	2
4352	828	2204	3
4353	829	2192	5
4354	829	2204	3
4355	830	2205	9
4356	830	2178	5
4357	831	2202	7
4358	831	2200	8
4359	832	2206	4
4360	832	2204	5
4361	833	2207	3
4362	833	2193	3
4363	834	2188	8
4364	835	2200	4
4365	835	2204	11
4366	836	2190	11
4367	837	2208	4
4368	838	2204	11
4369	838	2190	5
4370	839	2186	2
4371	839	2198	4
4372	840	2186	5
4373	840	2191	1
4374	841	2209	5
4375	842	2210	8
4376	843	2211	8
4377	843	2212	4
4378	844	2213	7
4379	845	2214	2
4380	846	2191	6
4381	847	2215	6
4382	848	2216	5
4383	849	2217	4
4384	849	2218	2
4385	850	2197	1
4386	851	2219	4
4387	852	2219	7
4388	853	2220	3
4389	853	2221	5
4390	854	2222	1
4391	854	2178	3
4392	855	2223	1
4393	856	2224	11
4394	857	2204	11
4395	857	2190	4
4396	858	2225	5
4397	859	2213	3
4398	860	2226	2
4399	861	2215	5
4400	862	2204	2
4401	862	2190	1
4402	863	2227	8
4403	864	2228	1
4404	865	2226	1
4405	866	2229	1
4406	867	2198	9
4407	868	2230	1
4408	868	2231	3
4409	869	2216	3
4410	870	2191	8
4411	871	2197	5
4412	872	2229	2
4413	873	2225	5
4414	874	2232	5
4415	875	2204	1
4416	875	2190	1
4417	876	2233	6
4418	877	2232	1
4419	878	2227	7
4420	879	2216	4
4421	880	2226	7
4422	880	2234	2
4423	881	2224	5
4424	882	2233	5
4425	883	2235	2
4426	883	2236	3
4427	884	2237	2
4428	885	2197	5
4429	886	2224	11
4430	887	2191	9
4431	888	2238	11
4432	889	2219	4
4433	890	2228	3
4434	891	2239	9
4435	892	2219	1
4436	893	2240	6
4437	894	2241	11
4438	894	2242	5
4439	894	2243	11
4440	894	2244	6
4441	894	2245	11
4442	895	2246	14
4443	895	2247	14
4444	895	2248	7
4445	895	2249	4
4446	895	2245	10
4447	896	2250	3
4448	897	2248	6
4449	897	2251	11
4450	897	2252	5
4451	897	2253	4
4452	897	2254	13
4453	898	2252	4
4454	898	2250	3
4455	898	2255	14
4456	898	2256	6
4457	898	2245	9
4458	899	2257	4
4459	899	2258	2
4460	899	2241	11
4461	899	2259	5
4462	899	2260	4
4463	899	2253	3
4464	900	2261	11
4465	900	2262	14
4466	900	2263	9
4467	900	2264	8
4468	900	2265	8
4469	900	2259	11
4470	900	2266	9
4471	901	2261	5
4472	901	2267	14
4473	901	2251	11
4474	901	2268	8
4475	901	2269	7
4476	902	2248	6
4477	902	2251	11
4478	902	2252	6
4479	902	2249	3
4480	902	2270	9
4481	902	2253	4
4482	903	2271	14
4483	903	2272	11
4484	904	2273	7
4485	904	2274	8
4486	904	2253	3
4487	904	2245	11
4488	905	2271	14
4489	905	2272	11
4490	905	2275	11
4491	905	2276	3
4492	905	2260	6
4493	905	2277	1
4494	905	2278	9
4495	906	2279	2
4496	906	2280	7
4497	906	2248	8
4498	906	2268	8
4499	906	2265	2
4500	906	2281	7
4501	907	2282	5
4502	907	2283	2
4503	907	2284	10
4504	907	2285	3
4505	907	2286	13
4506	907	2254	8
4507	908	2287	9
4508	908	2288	6
4509	908	2259	6
4510	908	2289	5
4511	908	2250	7
4512	908	2290	11
4513	909	2263	3
4514	909	2251	8
4515	909	2291	6
4516	909	2242	4
4517	909	2252	8
4518	909	2249	1
4519	910	2292	3
4520	910	2261	11
4521	910	2262	14
4522	910	2264	8
4523	910	2243	11
4524	910	2254	11
4525	911	2263	7
4526	911	2264	9
4527	911	2281	6
4528	911	2289	4
4529	911	2245	9
4530	912	2293	11
4531	912	2294	2
4532	912	2271	14
4533	912	2272	11
4534	912	2286	6
4535	912	2244	12
4536	912	2254	8
4537	913	2263	6
4538	913	2268	11
4539	913	2281	6
4540	913	2289	6
4541	913	2254	9
4542	914	2295	14
4543	914	2272	5
4544	914	2263	5
4545	914	2251	2
4546	914	2252	6
4547	914	2289	13
4548	914	2250	7
4549	915	2261	11
4550	915	2267	14
4551	915	2248	9
4552	915	2275	11
4553	915	2252	8
4554	915	2289	4
4555	915	2296	2
4556	915	2278	6
4557	916	2263	5
4558	916	2251	3
4559	916	2291	6
4560	916	2242	4
4561	916	2252	2
4562	916	2249	5
4563	916	2289	5
4564	917	2297	5
4565	917	2298	11
4566	917	2299	8
4567	917	2289	13
4568	917	2244	5
4569	917	2245	11
4570	918	2300	6
4571	918	2287	11
4572	918	2286	9
4573	918	2243	8
4574	918	2270	9
4575	918	2301	3
4576	919	2302	9
4577	919	2303	3
4578	919	2304	2
4579	919	2260	2
4580	920	2305	4
4581	920	2306	9
4582	920	2307	8
4583	920	2308	4
4584	920	2304	7
4585	920	2309	9
4586	921	2310	4
4587	921	2311	9
4588	921	2312	7
4589	921	2309	12
4590	921	2313	5
4591	921	2245	8
4592	922	2314	6
4593	922	2315	5
4594	922	2316	3
4595	922	2285	5
4596	922	2309	6
4597	922	2254	8
4598	923	2317	8
4599	923	2318	9
4600	923	2319	9
4601	923	2309	9
4602	924	2320	4
4603	924	2264	2
4604	924	2281	2
4605	924	2243	5
4606	924	2289	3
4607	924	2321	2
4608	925	2322	4
4609	925	2323	5
4610	925	2264	11
4611	925	2324	8
4612	308	2325	14
4613	926	941	6
4614	926	942	7
4615	926	943	7
4616	926	944	6
4617	926	99	4
4618	926	100	3
4619	926	945	1
4620	927	102	4
4621	927	946	5
4622	927	947	6
4623	927	948	4
4624	927	106	3
4625	928	949	10
4626	928	950	11
4627	928	951	9
4628	928	110	8
4629	928	111	11
4630	929	952	3
4631	929	953	9
4632	930	114	7
4633	930	954	9
4634	930	955	13
4635	930	117	10
4636	930	118	6
4637	931	956	13
4638	931	957	9
4639	931	121	11
4640	931	122	11
4641	931	123	9
4642	931	958	11
4643	932	125	6
4644	932	126	5
4645	933	127	9
4646	933	128	6
4647	933	129	11
4648	933	959	9
4649	933	960	5
4650	934	132	6
4651	934	961	9
4652	934	962	6
4653	934	135	8
4654	934	136	3
4655	935	137	7
4656	935	963	6
4657	935	964	5
4658	935	140	6
4659	935	141	6
4660	936	142	9
4661	936	143	8
4662	936	144	10
4663	937	145	5
4664	937	965	9
4665	937	966	7
4666	937	967	7
4667	937	149	11
4668	938	150	7
4669	938	968	9
4670	938	969	3
4671	938	153	6
4672	938	154	9
4673	939	970	14
4674	939	157	9
4675	939	158	10
4676	939	159	5
4677	939	971	14
4678	940	972	7
4679	940	162	14
4680	940	973	9
4681	940	974	14
4682	940	975	5
4683	940	166	5
4684	941	167	9
4685	941	976	8
4686	941	977	9
4687	941	978	4
4688	941	171	7
4689	942	172	12
4690	942	979	7
4691	942	174	5
4692	942	175	9
4693	942	980	14
4694	943	177	14
4695	943	981	9
4696	943	179	6
4697	943	982	6
4698	943	181	12
4699	944	182	12
4700	945	183	5
4701	945	184	4
4702	945	983	13
4703	945	984	4
4704	945	187	9
4705	945	188	9
4706	946	985	11
4707	946	986	9
4708	946	987	11
4709	946	988	11
4710	946	193	11
4711	947	194	13
4712	947	989	9
4713	947	196	9
4714	947	990	9
4715	947	198	5
4716	948	991	9
4717	948	992	6
4718	948	993	4
4719	948	994	2
4720	948	203	2
4721	949	995	6
4722	950	996	8
4723	951	206	5
4724	951	997	5
4725	952	998	10
4726	953	209	4
4727	953	999	9
4728	953	211	8
4729	953	212	11
4730	953	213	8
4731	953	1000	9
4732	954	215	9
4733	954	216	4
4734	954	1001	9
4735	954	1002	11
4736	954	219	9
4737	954	213	11
4738	955	220	12
4739	955	1003	7
4740	955	1004	11
4741	955	1005	13
4742	955	224	6
4743	956	225	12
4744	956	1006	6
4745	956	1007	7
4746	956	228	7
4747	956	229	7
4748	957	230	4
4749	957	1008	7
4750	957	232	1
4751	957	1009	4
4752	957	234	1
4753	958	1010	7
4754	958	1011	4
4755	958	237	8
4756	958	238	1
4757	958	239	7
4758	958	240	9
4759	959	241	12
4760	959	242	4
4761	959	1012	5
4762	959	237	11
4763	959	239	8
4764	959	240	9
4765	960	244	11
4766	960	245	11
4767	960	1013	11
4768	960	1014	11
4769	960	1015	9
4770	960	249	11
4771	961	250	5
4772	961	1016	11
4773	961	1017	11
4774	961	1018	9
4775	961	249	11
4776	962	254	9
4777	962	1019	6
4778	962	1020	13
4779	962	1021	5
4780	962	258	2
4781	963	259	4
4782	963	1022	7
4783	964	261	2
4784	964	1023	4
4785	965	1024	14
4786	966	1025	6
4787	967	1026	13
4788	968	1027	6
4789	968	267	9
4790	968	268	9
4791	968	1028	6
4792	968	270	2
4793	968	271	5
4794	968	272	6
4795	969	1029	11
4796	969	274	5
4797	969	268	5
4798	969	275	6
4799	969	276	6
4800	969	1030	9
4801	970	1031	6
4802	970	279	5
4803	970	1032	11
4804	970	1033	11
4805	970	1034	3
4806	970	283	9
4807	971	284	8
4808	971	1035	11
4809	971	1036	6
4810	971	287	12
4811	971	283	9
4812	971	1030	7
4813	972	288	4
4814	972	1037	8
4815	972	1038	7
4816	972	287	1
4817	972	291	7
4818	973	292	7
4819	973	293	5
4820	973	1039	4
4821	973	1040	3
4822	973	296	4
4823	974	297	6
4824	974	298	4
4825	974	1041	4
4826	974	1042	8
4827	974	301	2
4828	975	302	3
4829	975	1043	14
4830	975	1044	9
4831	975	305	9
4832	975	306	12
4833	975	307	7
4834	975	308	2
4835	976	309	8
4836	976	310	5
4837	976	1045	9
4838	976	306	6
4839	976	312	6
4840	976	313	2
4841	976	314	3
4842	977	1046	6
4843	977	1047	5
4844	977	317	5
4845	977	1048	10
4846	977	1049	8
4847	977	1050	7
4848	978	321	12
4849	978	1051	10
4850	978	1052	4
4851	978	1053	9
4852	978	1054	6
4853	978	326	5
4854	979	327	13
4855	979	1055	11
4856	979	329	9
4857	979	1056	6
4858	979	331	4
4859	980	309	8
4860	980	1057	7
4861	980	1058	5
4862	980	1059	4
4863	980	335	1
4864	981	1060	1
4865	981	337	2
4866	982	1061	5
4867	983	1062	6
4868	984	340	3
4869	984	1063	6
4870	985	1064	14
4871	985	1065	8
4872	985	344	10
4873	985	345	6
4874	986	1066	2
4875	986	1067	3
4876	986	1064	5
4877	986	1068	5
4878	986	349	5
4879	986	350	6
4880	986	351	1
4881	987	352	11
4882	987	1069	11
4883	987	1070	8
4884	987	1071	13
4885	987	356	9
4886	988	357	4
4887	988	1072	8
4888	988	359	6
4889	988	360	9
4890	988	361	3
4891	989	362	5
4892	989	363	5
4893	989	1073	9
4894	989	1074	2
4895	989	366	5
4896	990	367	3
4897	990	1075	11
4898	990	369	2
4899	990	1076	3
4900	990	371	5
4901	991	372	2
4902	991	1077	8
4903	991	374	1
4904	991	1078	3
4905	991	371	6
4906	992	367	4
4907	992	1077	9
4908	992	376	1
4909	992	1079	7
4910	992	378	7
4911	993	379	5
4912	993	1080	10
4913	993	1081	5
4914	993	1082	5
4915	993	378	1
4916	994	383	7
4917	994	1083	9
4918	994	385	6
4919	994	1084	3
4920	994	387	2
4921	995	1085	14
4922	995	1086	14
4923	995	390	9
4924	996	391	4
4925	996	392	7
4926	996	1087	8
4927	996	394	4
4928	996	395	12
4929	997	1088	2
4930	997	1085	14
4931	997	1089	8
4932	997	398	1
4933	997	399	2
4934	997	400	4
4935	997	401	1
4936	998	402	13
4937	998	1090	9
4938	998	1091	11
4939	998	1092	9
4940	998	406	9
4941	999	1093	8
4942	999	408	6
4943	999	1094	9
4944	999	1095	3
4945	999	398	6
4946	999	411	5
4947	1000	412	6
4948	1000	1096	11
4949	1000	1097	4
4950	1000	1098	4
4951	1000	416	6
4952	1001	417	8
4953	1001	418	4
4954	1001	1099	8
4955	1001	1100	5
4956	1001	421	8
4957	1002	422	5
4958	1002	423	3
4959	1002	424	3
4960	1002	1101	9
4961	1002	426	4
4962	1003	427	3
4963	1003	1102	9
4964	1003	1103	6
4965	1003	1104	4
4966	1003	426	5
4967	1004	431	5
4968	1004	1105	5
4969	1004	1106	4
4970	1004	1107	7
4971	1004	421	2
4972	1005	1108	9
4973	1005	1109	3
4974	1005	1110	2
4975	1005	1104	4
4976	1005	426	3
4977	1006	438	14
4978	1007	1111	9
4979	1008	1112	4
4980	1009	1113	9
4981	1010	1114	8
4982	1011	1115	7
4983	1012	1116	8
4984	1013	445	2
4985	1013	1117	4
4986	1014	1118	14
4987	1014	1119	4
4988	1014	449	7
4989	1014	450	11
4990	1014	451	8
4991	1014	452	12
4992	1014	453	11
4993	1014	454	1
4994	1015	455	8
4995	1015	456	11
4996	1015	451	8
4997	1015	457	12
4998	1015	458	2
4999	1015	459	5
5000	1015	460	14
5001	1015	1120	4
5002	1016	1121	9
5003	1016	1122	9
5004	1016	1118	14
5005	1016	1119	5
5006	1016	464	9
5007	1016	452	8
5008	1016	453	7
5009	1017	1118	14
5010	1017	1119	3
5011	1017	465	2
5012	1017	450	9
5013	1017	466	9
5014	1017	467	9
5015	1017	1120	8
5016	1018	468	3
5017	1018	1123	7
5018	1018	1124	11
5019	1018	471	7
5020	1019	1125	7
5021	1019	1126	7
5022	1019	1127	1
5023	1019	1128	2
5024	1019	476	7
5025	1020	477	5
5026	1020	1129	9
5027	1020	1130	2
5028	1020	1131	4
5029	1020	481	5
5030	1021	1132	4
5031	1021	1133	8
5032	1021	1134	1
5033	1021	476	8
5034	1022	1135	6
5035	1022	1136	8
5036	1022	1137	2
5037	1022	488	9
5038	1023	489	4
5039	1023	1138	4
5040	1023	1139	9
5041	1023	492	13
5042	1024	493	6
5043	1024	494	9
5044	1024	1140	6
5045	1024	1141	6
5046	1024	476	4
5047	1025	497	3
5048	1025	1142	8
5049	1025	1126	9
5050	1025	499	2
5051	1025	481	8
5052	1026	500	5
5053	1026	1143	7
5054	1026	502	1
5055	1026	1130	2
5056	1026	503	2
5057	1027	504	1
5058	1027	505	5
5059	1027	1144	3
5060	1027	1145	11
5061	1027	508	2
5062	1028	504	1
5063	1028	505	5
5064	1028	1144	3
5065	1028	1145	11
5066	1028	508	2
5067	1029	509	4
5068	1029	505	7
5069	1029	1146	11
5070	1029	1147	10
5071	1029	512	5
5072	1030	504	1
5073	1030	505	5
5074	1030	1144	9
5075	1030	1145	8
5076	1030	508	4
5077	1031	513	12
5078	1031	514	7
5079	1031	1146	7
5080	1031	1148	11
5081	1031	512	2
5082	1032	504	1
5083	1032	505	4
5084	1032	1144	8
5085	1032	1145	6
5086	1032	508	3
5087	1033	504	2
5088	1033	505	7
5089	1033	1144	1
5090	1033	1145	5
5091	1033	508	1
5092	1034	516	7
5093	1034	1149	9
5094	1034	1150	3
5095	1034	519	3
5096	1034	492	5
5097	1035	504	1
5098	1035	505	6
5099	1035	1144	3
5100	1035	1145	8
5101	1035	508	3
5102	1036	516	4
5103	1036	1149	6
5104	1036	520	6
5105	1036	1151	1
5106	1036	492	1
5107	1037	1152	9
5108	1038	1153	11
5109	1038	1154	6
5110	1038	525	5
5111	1038	526	2
5112	1038	527	12
5113	1038	528	6
5114	1039	529	4
5115	1039	1155	3
5116	1039	531	4
5117	1039	1156	8
5118	1039	1157	5
5119	1039	1158	12
5120	1039	535	12
5121	1040	536	11
5122	1040	1159	5
5123	1040	1160	10
5124	1040	539	11
5125	1040	540	9
5126	1040	541	12
5127	1040	542	11
5128	1041	543	13
5129	1041	1161	6
5130	1041	1162	5
5131	1041	540	2
5132	1041	546	2
5133	1041	542	5
5134	1042	547	9
5135	1042	1163	13
5136	1042	1164	5
5137	1042	550	13
5138	1042	551	7
5139	1043	1165	13
5140	1043	1166	3
5141	1043	1167	7
5142	1043	555	7
5143	1043	1168	3
5144	1043	550	8
5145	1044	557	9
5146	1044	1169	11
5147	1044	1166	8
5148	1044	1170	9
5149	1044	560	11
5150	1044	1171	2
5151	1045	562	4
5152	1045	1166	6
5153	1045	1172	11
5154	1045	1173	9
5155	1045	1174	5
5156	1045	566	11
5157	1046	567	9
5158	1046	568	8
5159	1046	1175	11
5160	1046	1173	10
5161	1046	570	11
5162	1047	571	12
5163	1047	1176	6
5164	1047	1177	8
5165	1047	1178	10
5166	1047	575	7
5167	1047	576	6
5168	1048	577	6
5169	1048	557	8
5170	1048	1179	9
5171	1048	1166	4
5172	1048	1178	13
5173	1048	566	8
5174	1049	1180	2
5175	1049	1172	11
5176	1049	1181	9
5177	1049	1167	11
5178	1049	566	11
5179	1050	581	5
5180	1050	1182	11
5181	1050	583	2
5182	1050	1183	3
5183	1050	585	4
5184	1051	1184	7
5185	1051	1185	9
5186	1051	583	4
5187	1051	1186	5
5188	1051	585	3
5189	1052	1187	8
5190	1052	1185	9
5191	1052	583	5
5192	1052	1186	6
5193	1052	585	7
5194	1053	590	4
5195	1053	1188	8
5196	1053	536	8
5197	1053	1189	7
5198	1053	593	6
5199	1054	1190	4
5200	1054	1191	9
5201	1054	583	6
5202	1054	1192	1
5203	1054	585	9
5204	1055	597	13
5205	1055	1193	11
5206	1055	599	5
5207	1055	1194	6
5208	1055	601	3
5209	1056	602	4
5210	1056	1195	11
5211	1056	555	8
5212	1056	1196	5
5213	1056	585	5
5214	1057	1184	5
5215	1057	1185	5
5216	1057	583	5
5217	1057	1186	6
5218	1057	585	2
5219	1058	605	4
5220	1058	606	4
5221	1058	1197	7
5222	1058	1198	2
5223	1058	609	1
5224	1059	610	3
5225	1059	611	3
5226	1059	1185	7
5227	1059	1199	3
5228	1059	570	3
5229	1060	613	1
5230	1060	1200	7
5231	1060	615	4
5232	1060	1201	2
5233	1060	601	2
5234	1061	617	3
5235	1062	618	12
5236	1063	1202	3
5237	1063	1203	9
5238	1064	1204	4
5239	1065	1205	5
5240	1066	623	6
5241	1066	624	5
5242	1067	1203	11
5243	1068	1206	4
5244	1068	1207	6
5245	1069	1208	4
5246	1070	1209	3
5247	1071	1210	9
5248	1072	1211	3
5249	1073	1212	5
5250	1074	1213	6
5251	1074	633	11
5252	1074	634	7
5253	1074	635	8
5254	1074	636	2
5255	1074	637	9
5256	1075	1214	13
5257	1075	1215	14
5258	1075	640	13
5259	1075	2325	14
5260	1075	641	9
5261	1075	642	9
5262	1075	1216	11
5263	1076	644	4
5264	1076	1217	6
5265	1076	646	1
5266	1076	647	4
5267	1076	648	1
5268	1077	1218	6
5269	1077	1219	3
5270	1077	1220	11
5271	1077	652	6
5272	1077	1221	7
5273	1078	654	5
5274	1078	1222	7
5275	1078	634	6
5276	1078	656	3
5277	1078	657	3
5278	1079	658	2
5279	1079	1223	9
5280	1079	1224	11
5281	1079	661	5
5282	1079	1225	6
5283	1080	1226	7
5284	1080	664	11
5285	1080	661	3
5286	1080	665	2
5287	1080	1225	8
5288	1081	1227	8
5289	1081	1228	7
5290	1081	1229	5
5291	1081	669	2
5292	1082	670	5
5293	1082	1230	4
5294	1082	1224	8
5295	1082	669	4
5296	1082	672	11
5297	1082	1225	6
5298	1083	1231	7
5299	1083	672	11
5300	1083	640	7
5301	1083	661	7
5302	1083	674	7
5303	1083	635	6
5304	1084	1232	3
5305	1084	1226	8
5306	1084	672	8
5307	1084	661	4
5308	1084	665	2
5309	1085	676	12
5310	1085	1233	9
5311	1085	1234	7
5312	1085	1235	6
5313	1085	680	2
5314	1086	681	2
5315	1086	682	4
5316	1086	1236	7
5317	1086	684	2
5318	1086	1237	7
5319	1087	1238	8
5320	1087	1235	5
5321	1087	1239	4
5322	1087	1240	4
5323	1087	680	3
5324	1088	689	9
5325	1088	1238	9
5326	1088	1235	6
5327	1088	1241	8
5328	1088	691	13
5329	1089	692	6
5330	1089	693	9
5331	1089	1235	9
5332	1089	1242	4
5333	1089	680	7
5334	1090	695	4
5335	1090	1243	9
5336	1090	1244	9
5337	1090	680	8
5338	1091	698	6
5339	1091	1233	10
5340	1091	1235	11
5341	1091	1245	6
5342	1092	700	3
5343	1092	1246	2
5344	1092	1243	9
5345	1092	1244	7
5346	1092	680	6
5347	1093	702	5
5348	1093	1247	7
5349	1093	1248	7
5350	1093	1235	6
5351	1093	680	7
5352	1094	705	5
5353	1094	1249	11
5354	1094	1244	9
5355	1094	1250	6
5356	1094	680	1
5357	1095	1251	8
5358	1095	1234	6
5359	1095	1244	6
5360	1095	709	9
5361	1095	710	8
5362	1096	711	3
5363	1096	1252	7
5364	1096	1253	7
5365	1096	1254	6
5366	1096	691	2
5367	1097	715	3
5368	1097	716	6
5369	1097	1255	9
5370	1097	1256	2
5371	1097	719	3
5372	1098	720	4
5373	1098	1257	7
5374	1098	722	2
5375	1098	1258	5
5376	1098	684	1
5377	1099	724	4
5378	1099	682	6
5379	1099	1259	6
5380	1099	1260	7
5381	1099	727	6
5382	1100	728	2
5383	1100	1261	9
5384	1100	730	3
5385	1100	1262	3
5386	1100	732	6
5387	1101	733	7
5388	1101	734	6
5389	1101	1263	8
5390	1101	1264	11
5391	1101	727	6
5392	1102	715	3
5393	1102	716	9
5394	1102	1255	5
5395	1102	1256	9
5396	1102	719	8
5397	1103	737	6
5398	1103	1265	6
5399	1103	739	4
5400	1103	1266	2
5401	1103	727	6
5402	1104	741	7
5403	1104	682	5
5404	1104	1263	5
5405	1104	1267	9
5406	1104	727	1
5407	1105	715	3
5408	1105	716	7
5409	1105	1255	6
5410	1105	1256	3
5411	1105	719	6
5412	1106	743	8
5413	1106	716	8
5414	1106	1265	8
5415	1106	1256	9
5416	1106	719	9
5417	1107	744	4
5418	1107	1261	6
5419	1107	1268	5
5420	1107	746	4
5421	1107	732	5
5422	1108	747	8
5423	1108	1269	11
5424	1108	749	3
5425	1108	1270	8
5426	1108	751	7
5427	1109	752	6
5428	1109	1261	9
5429	1109	753	5
5430	1109	1271	10
5431	1109	732	7
5432	1110	715	4
5433	1110	716	6
5434	1110	1255	8
5435	1110	1256	3
5436	1110	719	6
5437	1111	755	6
5438	1111	1265	5
5439	1111	756	5
5440	1111	1272	4
5441	1111	758	1
5442	1112	759	4
5443	1112	1273	6
5444	1112	730	4
5445	1112	1274	2
5446	1112	684	1
5447	1113	762	6
5448	1113	1275	7
5449	1113	764	6
5450	1113	1276	2
5451	1113	727	6
5452	1114	1277	5
5453	1114	693	4
5454	1114	1257	7
5455	1114	767	7
5456	1114	751	1
5457	1115	768	3
5458	1115	769	9
5459	1115	1278	8
5460	1115	1279	4
5461	1115	684	1
5462	1116	772	6
5463	1116	1280	5
5464	1116	774	4
5465	1116	1281	6
5466	1116	727	5
5467	1117	776	5
5468	1117	1282	11
5469	1117	778	4
5470	1117	1283	12
5471	1117	727	5
5472	1118	755	7
5473	1118	1265	8
5474	1118	756	7
5475	1118	1272	3
5476	1118	758	4
5477	1119	780	6
5478	1119	769	10
5479	1119	1284	8
5480	1119	1279	3
5481	1119	684	11
5482	1120	762	5
5483	1120	1275	8
5484	1120	764	5
5485	1120	1276	1
5486	1120	751	5
5487	1121	755	6
5488	1121	1265	4
5489	1121	756	8
5490	1121	1272	4
5491	1121	758	1
5492	1122	782	4
5493	1122	1261	7
5494	1122	767	4
5495	1122	1285	8
5496	1122	732	6
5497	1123	784	7
5498	1123	1286	9
5499	1123	753	5
5500	1123	1266	2
5501	1123	751	6
5502	1124	786	4
5503	1124	1261	8
5504	1124	767	5
5505	1124	1285	9
5506	1124	732	8
5507	1125	787	3
5508	1125	1261	4
5509	1125	1287	9
5510	1125	1288	4
5511	1125	732	3
5512	1126	1289	12
5513	1126	1261	1
5514	1126	791	8
5515	1126	1285	7
5516	1126	732	5
5517	1127	755	4
5518	1127	1265	9
5519	1127	756	9
5520	1127	1272	4
5521	1127	758	5
5522	1128	792	1
5523	1128	793	3
5524	1128	1290	8
5525	1128	1291	3
5526	1128	796	4
5527	1129	797	5
5528	1129	798	5
5529	1129	1292	2
5530	1129	1293	7
5531	1129	796	5
5532	1130	801	1
5533	1130	802	2
5534	1130	1290	11
5535	1130	1294	1
5536	1130	796	11
5537	1131	1295	8
5538	1131	805	12
5539	1131	1296	8
5540	1131	1297	10
5541	1131	1298	7
5542	1132	809	5
5543	1132	1299	6
5544	1132	811	12
5545	1132	812	3
5546	1132	813	12
5547	1132	1300	3
5548	1133	1295	6
5549	1133	1301	14
5550	1133	816	4
5551	1133	817	7
5552	1133	811	9
5553	1133	818	12
5554	1133	819	11
5555	1134	820	7
5556	1134	821	5
5557	1134	1302	2
5558	1134	1303	2
5559	1134	818	3
5560	1134	824	12
5561	1134	1304	7
5562	1135	1296	7
5563	1135	1305	8
5564	1135	827	5
5565	1135	828	8
5566	1135	1306	6
5567	1136	1307	2
5568	1136	1308	11
5569	1136	832	6
5570	1136	828	8
5571	1136	833	6
5572	1136	834	2
5573	1137	1309	7
5574	1137	1310	8
5575	1137	827	7
5576	1137	832	7
5577	1137	837	9
5578	1138	838	6
5579	1138	839	6
5580	1138	1311	11
5581	1138	841	8
5582	1138	842	12
5583	1138	843	5
5584	1139	844	9
5585	1139	1312	13
5586	1139	1313	7
5587	1139	1314	7
5588	1139	848	3
5589	1139	849	6
5590	1140	848	5
5591	1140	1315	11
5592	1140	827	1
5593	1140	842	7
5594	1140	849	5
5595	1141	851	4
5596	1141	817	12
5597	1141	837	5
5598	1141	812	6
5599	1141	852	3
5600	1141	853	12
5601	1141	1316	11
5602	1142	1308	11
5603	1142	855	8
5604	1142	817	5
5605	1142	828	9
5606	1142	1317	5
5607	1143	857	12
5608	1143	1318	11
5609	1143	1319	8
5610	1143	1320	1
5611	1143	855	7
5612	1143	861	5
5613	1144	862	8
5614	1144	1321	7
5615	1144	1322	9
5616	1144	1323	6
5617	1144	866	7
5618	1145	1296	7
5619	1145	1314	8
5620	1145	1324	6
5621	1145	868	3
5622	1145	1325	6
5623	1145	827	8
5624	1146	1326	10
5625	1146	1324	8
5626	1146	1327	5
5627	1146	827	11
5628	1146	849	9
5629	1147	872	8
5630	1147	1328	13
5631	1147	1329	13
5632	1147	1330	6
5633	1147	827	9
5634	1148	876	2
5635	1148	1331	9
5636	1148	1296	8
5637	1148	1332	9
5638	1148	1333	6
5639	1148	880	13
5640	1149	881	6
5641	1149	1334	4
5642	1149	1335	7
5643	1149	1336	5
5644	1149	841	3
5645	1150	1337	4
5646	1150	1313	9
5647	1150	1338	11
5648	1150	855	13
5649	1150	887	12
5650	1151	1313	6
5651	1151	1339	11
5652	1151	1340	9
5653	1151	1341	5
5654	1151	880	7
5655	1152	1342	5
5656	1152	1343	9
5657	1152	1334	11
5658	1152	1324	11
5659	1152	827	5
5660	1153	893	4
5661	1153	1344	5
5662	1153	1345	9
5663	1153	1346	1
5664	1153	841	13
5665	1153	1316	8
5666	1154	897	3
5667	1154	1347	9
5668	1154	1348	5
5669	1154	1349	5
5670	1154	901	6
5671	1155	902	2
5672	1155	1296	6
5673	1155	1339	8
5674	1155	1350	6
5675	1155	827	9
5676	1155	1351	3
5677	1156	905	4
5678	1156	906	5
5679	1156	1352	6
5680	1156	1353	7
5681	1156	909	3
5682	1157	910	4
5683	1157	1354	5
5684	1157	912	2
5685	1157	1355	3
5686	1157	914	2
5687	1158	1356	6
5688	1158	1357	9
5689	1158	917	6
5690	1158	1358	9
5691	1158	919	6
5692	1159	920	2
5693	1159	1359	11
5694	1159	839	8
5695	1159	1360	1
5696	1159	866	5
5697	1160	923	5
5698	1160	924	7
5699	1160	1361	8
5700	1160	1362	4
5701	1160	914	7
5702	1161	927	7
5703	1161	1363	5
5704	1161	1352	10
5705	1161	1364	2
5706	1161	930	9
5707	1162	931	12
5708	1162	1365	9
5709	1162	933	2
5710	1162	934	3
5711	1162	1298	3
5712	1163	935	5
5713	1163	1366	6
5714	1163	937	7
5715	1163	1367	5
5716	1163	930	1
5717	1164	939	5
5718	1164	905	4
5719	1164	1357	8
5720	1164	1368	2
5721	1164	930	7
5722	1165	1369	9
5723	1165	1366	7
5724	1165	1370	8
5725	1165	1371	13
5726	1165	1372	9
5727	1166	1373	4
5728	1166	1347	6
5729	1166	839	7
5730	1166	1374	8
5731	1166	866	5
5732	1167	1375	3
5733	1167	1376	8
5734	1167	1299	6
5735	1167	1320	2
5736	1167	919	10
5737	1168	1373	5
5738	1168	1377	10
5739	1168	1378	11
5740	1168	1379	8
5741	1168	866	5
5742	1169	1380	6
5743	1169	1352	7
5744	1169	1381	2
5745	1169	1346	3
5746	1169	930	6
5747	1170	1382	8
5748	1170	1383	3
5749	1170	1384	8
5750	1170	1385	5
5751	1170	914	1
5752	1171	1386	2
5753	1171	1387	6
5754	1171	1358	4
5755	1171	1388	4
5756	1171	1372	6
5757	1172	1389	5
5758	1172	1390	8
5759	1172	1391	7
5760	1172	1364	2
5761	1172	914	3
5762	1173	1392	8
5763	1173	1361	9
5764	1173	1393	5
5765	1173	1394	2
5766	1173	866	4
5767	1174	1395	7
5768	1174	1396	11
5769	1174	1397	6
5770	1174	816	6
5771	1174	1388	8
5772	1175	1398	8
5773	1175	1399	10
5774	1175	1366	3
5775	1175	1400	2
5776	1175	1401	6
5777	1175	1388	8
5778	1176	1402	2
5779	1176	1403	7
5780	1176	1404	5
5781	1176	1348	4
5782	1176	919	3
5783	1177	1405	5
5784	1177	1383	3
5785	1177	1387	8
5786	1177	1406	6
5787	1177	866	7
5788	1178	1407	4
5789	1178	1408	13
5790	1178	1404	4
5791	1178	1409	1
5792	1178	909	2
5793	1179	1389	5
5794	1179	1410	9
5795	1179	1391	7
5796	1179	1364	2
5797	1179	934	9
5798	1180	1411	4
5799	1180	1383	4
5800	1180	1359	9
5801	1180	1412	5
5802	1180	914	1
5803	1181	1413	2
5804	1181	1414	6
5805	1181	1415	4
5806	1181	816	6
5807	1181	866	5
5808	1182	1416	3
5809	1182	1417	9
5810	1182	1418	4
5811	1182	1406	4
5812	1182	934	6
5813	1183	1419	5
5814	1183	1377	9
5815	1183	1378	8
5816	1183	1420	7
5817	1183	866	7
5818	1184	1421	4
5819	1184	1390	3
5820	1184	839	8
5821	1184	1394	5
5822	1184	919	3
5823	1185	1422	7
5824	1185	1352	6
5825	1185	917	7
5826	1185	1423	12
5827	1185	866	9
5828	1186	1424	3
5829	1186	1425	4
5830	1186	1426	11
5831	1186	1427	7
5832	1186	930	8
5833	1187	935	5
5834	1187	1352	7
5835	1187	1412	7
5836	1187	1428	5
5837	1187	1388	8
5838	1188	902	3
5839	1188	1408	7
5840	1188	1429	11
5841	1188	1430	2
5842	1188	914	4
5843	1189	1431	2
5844	1189	1432	8
5845	1189	1433	4
5846	1189	1434	5
5847	1189	901	8
5848	1190	1435	8
5849	1191	1436	4
5850	1191	1437	6
5851	1192	1438	2
5852	1193	1439	2
5853	1194	1440	4
5854	1195	1441	3
5855	1195	1442	5
5856	1195	1443	9
5857	1196	1444	3
5858	1196	1445	6
5859	1197	1446	6
5860	1198	1447	8
5861	1199	1448	8
5862	1200	1449	1
5863	1201	1450	9
5864	1202	1451	11
5865	1202	1445	7
5866	1203	1452	6
5867	1203	1453	8
5868	1204	1454	9
5869	1205	1455	8
5870	1206	1456	4
5871	1206	1457	2
5872	1207	1458	9
5873	1208	1459	9
5874	1209	1460	8
5875	1210	1461	2
5876	1210	1462	1
5877	1211	1463	3
5878	1212	1464	6
5879	1213	1465	11
5880	1214	1466	9
5881	1214	1467	6
5882	1215	1468	9
5883	1216	1469	3
5884	1216	1457	3
5885	1217	1470	3
5886	1217	1471	4
5887	1218	1465	11
5888	1219	1454	5
5889	1220	1463	9
5890	1221	1472	6
5891	1221	1458	7
5892	1222	1473	1
5893	1223	1474	8
5894	1224	1475	4
5895	1225	1476	12
5896	1225	1477	9
5897	1225	1478	11
5898	1225	1479	11
5899	1225	1480	11
5900	1226	1481	7
5901	1227	1482	13
5902	1227	1483	4
5903	1227	1484	11
5904	1227	1485	9
5905	1227	1477	5
5906	1227	1486	5
5907	1227	1487	2
5908	1228	1488	6
5909	1228	1489	4
5910	1228	1487	12
5911	1229	1490	5
5912	1229	1491	5
5913	1229	1492	14
5914	1229	1477	5
5915	1229	1493	4
5916	1229	1494	4
5917	1229	1495	13
5918	1230	1496	11
5919	1230	1497	9
5920	1230	1486	11
5921	1230	1498	2
5922	1230	1499	12
5923	1231	1483	2
5924	1231	1500	4
5925	1231	1501	13
5926	1231	1502	11
5927	1231	1503	5
5928	1231	1504	8
5929	1232	1505	7
5930	1232	1506	13
5931	1232	1502	9
5932	1232	1477	8
5933	1232	1503	5
5934	1232	1507	6
5935	1233	1508	5
5936	1233	1509	2
5937	1233	1510	2
5938	1233	1511	2
5939	1233	1512	8
5940	1234	1513	6
5941	1234	1514	5
5942	1234	1491	13
5943	1234	1515	14
5944	1234	1516	9
5945	1234	1517	8
5946	1234	1495	10
5947	1235	1518	4
5948	1235	1519	13
5949	1235	1477	8
5950	1235	1478	9
5951	1235	1493	4
5952	1236	1520	3
5953	1236	1491	11
5954	1236	1521	14
5955	1236	1522	8
5956	1236	1502	9
5957	1236	1507	4
5958	1236	1499	7
5959	1236	1480	8
5960	1237	1496	9
5961	1237	1523	3
5962	1237	1493	5
5963	1237	1486	6
5964	1237	1494	5
5965	1237	1495	11
5966	1238	1524	7
5967	1238	1491	11
5968	1238	1515	14
5969	1238	1477	5
5970	1238	1525	5
5971	1238	1503	12
5972	1238	1526	11
5973	1239	1527	6
5974	1239	1528	11
5975	1239	1529	10
5976	1239	1491	8
5977	1239	1521	14
5978	1239	1530	4
5979	1240	1531	4
5980	1240	1529	6
5981	1240	1491	7
5982	1240	1532	14
5983	1240	1533	5
5984	1240	1534	4
5985	1241	1535	4
5986	1241	1491	2
5987	1241	1521	14
5988	1241	1536	9
5989	1241	1525	5
5990	1241	1503	7
5991	1241	1537	11
5992	1241	1495	9
5993	1242	1538	5
5994	1242	1490	6
5995	1242	1491	11
5996	1242	1521	14
5997	1242	1516	9
5998	1242	1517	9
5999	1242	1526	9
6000	1243	1528	13
6001	1243	1529	11
6002	1243	1539	10
6003	1243	1540	9
6004	1243	1541	9
6005	1244	1542	3
6006	1244	1525	4
6007	1244	1498	4
6008	1244	1543	7
6009	1244	1495	11
6010	1245	1544	11
6011	1245	1545	11
6012	1245	1546	2
6013	1245	1547	6
6014	1245	1479	12
6015	1246	1548	8
6016	1246	1516	6
6017	1246	1517	9
6018	1246	1498	4
6019	1246	1549	4
6020	1246	1495	11
6021	1247	1550	13
6022	1247	1491	11
6023	1247	1515	14
6024	1247	1477	8
6025	1247	1525	3
6026	1247	1503	5
6027	1247	1526	8
6028	1248	1529	10
6029	1248	1491	11
6030	1248	1532	14
6031	1248	1477	6
6032	1248	1478	6
6033	1248	1493	5
6034	1248	1526	11
6035	1249	1551	6
6036	1249	1552	8
6037	1249	1491	5
6038	1249	1521	14
6039	1249	1516	3
6040	1249	1478	4
6041	1250	1553	2
6042	1250	1554	5
6043	1250	1555	11
6044	1250	1556	8
6045	1250	1511	4
6046	1251	1557	5
6047	1251	1491	6
6048	1251	1492	14
6049	1251	1477	3
6050	1251	1540	2
6051	1251	1503	6
6052	1251	1526	8
6053	1252	1558	4
6054	1252	1559	4
6055	1252	1560	11
6056	1252	1561	9
6057	1252	1562	4
6058	1253	1567	3
6059	1253	1568	7
6060	1253	1569	8
6061	1253	1511	2
6062	1254	1570	2
6063	1254	1571	9
6064	1254	1572	3
6065	1254	1573	11
6066	1255	1574	5
6067	1255	1575	5
6068	1255	1576	5
6069	1255	1577	5
6070	1255	1530	2
6071	1256	1578	2
6072	1256	1579	9
6073	1256	1572	7
6074	1256	1580	7
6075	1256	1581	7
6076	1257	1582	3
6077	1257	1583	2
6078	1257	1560	7
6079	1257	1584	7
6080	1257	1562	5
6081	1258	1585	1
6082	1258	1586	9
6083	1258	1587	7
6084	1258	1588	3
6085	1258	1581	5
6086	1259	1589	11
6087	1259	1590	8
6088	1259	1591	2
6089	1259	1592	6
6090	1260	1593	5
6091	1260	1594	9
6092	1260	1595	11
6093	1260	1580	9
6094	1261	1596	3
6095	1261	1597	9
6096	1261	1598	7
6097	1261	1599	3
6098	1261	1530	7
6099	1262	1583	3
6100	1262	1600	3
6101	1262	1560	7
6102	1262	1601	8
6103	1262	1602	13
6104	1263	1583	3
6105	1263	1603	3
6106	1263	1576	7
6107	1263	1604	1
6108	1263	1602	9
6109	1264	1605	4
6110	1264	1568	7
6111	1264	1606	7
6112	1264	1530	1
6113	1265	1607	8
6114	1265	1608	9
6115	1265	1609	7
6116	1265	1610	3
6117	1265	1562	6
6118	1266	1611	11
6119	1266	1612	9
6120	1266	1613	8
6121	1266	1614	7
6122	1266	1592	3
6123	1267	1615	2
6124	1267	1616	7
6125	1267	1617	11
6126	1267	1618	3
6127	1267	1511	5
6128	1268	1619	12
6129	1268	1560	8
6130	1268	1601	9
6131	1268	1602	6
6132	1269	1620	2
6133	1269	1621	1
6134	1269	1571	13
6135	1269	1622	7
6136	1269	1511	3
6137	1270	1623	1
6138	1270	1624	7
6139	1270	1587	6
6140	1270	1625	5
6141	1270	1581	7
6142	1271	1626	5
6143	1271	1627	5
6144	1271	1628	9
6145	1271	1569	9
6146	1271	1511	2
6147	1272	1629	7
6148	1272	1630	9
6149	1272	1590	5
6150	1272	1592	9
6151	1273	1575	5
6152	1273	1631	9
6153	1273	1632	1
6154	1273	1633	5
6155	1273	1546	4
6156	1274	1634	2
6157	1274	1635	3
6158	1274	1636	3
6159	1274	1546	2
6160	1274	1516	4
6161	1275	1637	2
6162	1275	1638	5
6163	1275	1639	5
6164	1275	1530	4
6165	1275	1640	3
6166	1276	1641	3
6167	1276	1642	3
6168	1276	1643	8
6169	1276	1590	7
6170	1276	1581	9
6171	1277	1642	4
6172	1277	1644	9
6173	1277	1572	7
6174	1277	1645	8
6175	1277	1592	7
6176	1278	1646	4
6177	1278	1647	8
6178	1278	1648	9
6179	1278	1592	5
6180	1279	1575	11
6181	1279	1612	11
6182	1279	1649	12
6183	1279	1592	12
6184	1279	1516	11
6185	1280	1650	3
6186	1280	1638	7
6187	1280	1584	9
6188	1280	1651	5
6189	1280	1546	3
6190	1281	1652	4
6191	1281	1571	9
6192	1281	1572	5
6193	1281	1533	3
6194	1282	1653	3
6195	1282	1586	9
6196	1282	1654	6
6197	1282	1530	7
6198	1283	1655	2
6199	1283	1652	4
6200	1283	1571	8
6201	1283	1572	6
6202	1283	1533	4
6203	1284	1656	4
6204	1284	1643	9
6205	1284	1587	6
6206	1284	1651	2
6207	1284	1511	6
6208	1285	1641	3
6209	1285	1624	9
6210	1285	1572	9
6211	1285	1657	4
6212	1285	1581	8
6213	1286	1658	3
6214	1286	1659	9
6215	1286	1590	7
6216	1286	1660	1
6217	1286	1530	5
6218	1286	1516	6
6219	1287	1623	1
6220	1287	1624	9
6221	1287	1587	6
6222	1287	1625	6
6223	1287	1581	8
6224	1288	1661	6
6225	1288	1575	8
6226	1288	1662	7
6227	1288	1663	5
6228	1288	1546	2
6229	1289	1664	5
6230	1289	1665	11
6231	1289	1666	8
6232	1289	1667	4
6233	1289	1581	9
6234	1290	1583	2
6235	1290	1668	2
6236	1290	1669	6
6237	1290	1631	7
6238	1290	1511	3
6239	1291	1670	4
6240	1291	1671	4
6241	1291	1528	11
6242	1291	1672	8
6243	1291	1546	6
6244	1292	1673	7
6245	1292	1674	10
6246	1292	1622	8
6247	1292	1675	7
6248	1292	1530	7
6249	1293	1676	3
6250	1293	1643	13
6251	1293	1631	9
6252	1293	1618	3
6253	1293	1530	8
6254	1294	1677	4
6255	1294	1678	3
6256	1294	1665	7
6257	1294	1679	9
6258	1294	1613	8
6259	1294	1530	8
6260	1295	1680	7
6261	1295	1681	9
6262	1295	1682	12
6263	1295	1530	7
6264	1295	1683	4
6265	1296	1594	9
6266	1296	1590	9
6267	1296	1684	5
6268	1296	1511	9
6269	1297	1685	5
6270	1297	1686	1
6271	1297	1613	4
6272	1297	1687	7
6273	1297	1688	1
6274	1298	1689	5
6275	1298	1686	2
6276	1298	1690	3
6277	1298	1645	6
6278	1298	1688	3
6279	1299	1691	4
6280	1299	1692	8
6281	1299	1693	6
6282	1299	1694	1
6283	1299	1695	3
6284	1300	1696	5
6285	1300	1697	7
6286	1300	1698	5
6287	1300	1663	3
6288	1300	1699	9
6289	1301	1700	5
6290	1301	1701	4
6291	1301	1702	1
6292	1301	1703	1
6293	1301	1704	4
6294	1302	1705	4
6295	1302	1706	6
6296	1302	1707	7
6297	1302	1708	2
6298	1302	1699	3
6299	1303	1709	6
6300	1303	1710	8
6301	1303	1707	6
6302	1303	1711	3
6303	1303	1712	11
6304	1304	1551	5
6305	1304	1713	5
6306	1304	1714	5
6307	1304	1715	8
6308	1304	1699	8
6309	1305	1716	3
6310	1305	1717	6
6311	1305	1718	2
6312	1305	1719	1
6313	1305	1720	8
6314	1306	1691	3
6315	1306	1692	4
6316	1306	1693	4
6317	1306	1694	1
6318	1306	1695	2
6319	1307	1551	4
6320	1307	1721	2
6321	1307	1697	8
6322	1307	1722	1
6323	1307	1699	1
6324	1308	1723	3
6325	1308	1724	6
6326	1308	1701	8
6327	1308	1725	1
6328	1308	1704	7
6329	1309	1691	3
6330	1309	1692	5
6331	1309	1693	11
6332	1309	1694	6
6333	1309	1695	8
6334	1310	1709	5
6335	1310	1710	7
6336	1310	1707	7
6337	1310	1711	2
6338	1310	1712	7
6339	1311	1691	3
6340	1311	1692	6
6341	1311	1693	6
6342	1311	1694	1
6343	1311	1695	1
6344	1312	1709	5
6345	1312	1710	1
6346	1312	1707	4
6347	1312	1711	3
6348	1312	1712	1
6349	1313	1716	4
6350	1313	1717	3
6351	1313	1718	3
6352	1313	1719	3
6353	1313	1720	1
6354	1314	1726	4
6355	1314	1701	11
6356	1314	1702	6
6357	1314	1727	5
6358	1314	1704	8
6359	1315	1728	2
6360	1315	1729	5
6361	1315	1701	7
6362	1315	1704	5
6363	1315	1730	3
6364	1316	1658	1
6365	1316	1731	5
6366	1316	1732	1
6367	1316	1733	8
6368	1316	1533	4
6369	1317	1734	5
6370	1317	1735	6
6371	1317	1707	6
6372	1317	1736	2
6373	1317	1533	4
6374	1318	1737	6
6375	1318	1738	1
6376	1318	1739	2
6377	1318	1533	3
6378	1318	1740	3
6379	1319	1709	6
6380	1319	1710	8
6381	1319	1707	7
6382	1319	1711	3
6383	1319	1712	11
6384	1320	1709	6
6385	1320	1710	5
6386	1320	1707	7
6387	1320	1711	5
6388	1320	1712	7
6389	1321	1741	3
6390	1321	1686	2
6391	1321	1690	2
6392	1321	1742	5
6393	1321	1688	3
6394	1322	1716	4
6395	1322	1717	4
6396	1322	1718	1
6397	1322	1719	1
6398	1322	1720	7
6399	1323	1716	3
6400	1323	1717	5
6401	1323	1718	3
6402	1323	1719	2
6403	1323	1720	4
6404	1324	1743	7
6405	1324	1744	8
6406	1324	1698	4
6407	1324	1745	4
6408	1324	1699	8
6409	1325	1746	4
6410	1325	1686	3
6411	1325	1739	3
6412	1325	1747	8
6413	1325	1688	5
6414	1326	1709	5
6415	1326	1710	8
6416	1326	1707	4
6417	1326	1711	4
6418	1326	1712	9
6419	1327	1748	3
6420	1327	1729	5
6421	1327	1701	11
6422	1327	1749	6
6423	1327	1704	8
6424	1328	1750	5
6425	1328	1701	4
6426	1328	1613	7
6427	1328	1751	1
6428	1328	1704	4
6429	1329	1685	5
6430	1329	1686	1
6431	1329	1580	4
6432	1329	1752	1
6433	1329	1688	2
6434	1330	1753	5
6435	1330	1701	5
6436	1330	1702	2
6437	1330	1733	6
6438	1330	1704	5
6439	1331	1685	4
6440	1331	1686	4
6441	1331	1754	2
6442	1331	1755	2
6443	1331	1688	3
6444	1332	1756	3
6445	1332	1686	6
6446	1332	1732	7
6447	1332	1757	1
6448	1332	1688	3
6449	1333	1758	4
6450	1333	1701	11
6451	1333	1754	2
6452	1333	1759	5
6453	1333	1704	5
6454	1334	1760	6
6455	1334	1721	6
6456	1334	1761	9
6457	1334	1762	5
6458	1334	1699	9
6459	1335	1709	6
6460	1335	1710	8
6461	1335	1707	6
6462	1335	1711	5
6463	1335	1712	2
6464	1336	1709	6
6465	1336	1710	6
6466	1336	1707	4
6467	1336	1711	7
6468	1336	1712	1
6469	1337	1700	5
6470	1337	1701	7
6471	1337	1580	7
6472	1337	1749	5
6473	1337	1704	4
6474	1338	1743	7
6475	1338	1763	1
6476	1338	1714	4
6477	1338	1764	3
6478	1338	1704	5
6479	1339	1691	3
6480	1339	1692	4
6481	1339	1693	5
6482	1339	1694	1
6483	1339	1695	1
6484	1340	1709	5
6485	1340	1710	8
6486	1340	1707	8
6487	1340	1711	6
6488	1340	1712	5
6489	1341	1765	3
6490	1341	1766	3
6491	1341	1686	4
6492	1341	1732	2
6493	1341	1688	2
6494	1342	1716	4
6495	1342	1717	6
6496	1342	1718	3
6497	1342	1719	1
6498	1342	1720	1
6499	1343	1767	5
6500	1343	1768	7
6501	1343	1718	1
6502	1343	1769	5
6503	1343	1699	9
6504	1344	1691	4
6505	1344	1692	5
6506	1344	1693	2
6507	1344	1694	2
6508	1344	1695	3
6509	1345	1716	2
6510	1345	1717	4
6511	1345	1718	1
6512	1345	1719	1
6513	1345	1720	1
6514	1346	1696	5
6515	1346	1721	4
6516	1346	1697	9
6517	1346	1770	6
6518	1346	1699	5
6519	1347	1771	3
6520	1347	1721	7
6521	1347	1772	8
6522	1347	1651	2
6523	1347	1699	7
6524	1348	1691	2
6525	1348	1692	4
6526	1348	1693	5
6527	1348	1694	1
6528	1348	1695	1
6529	1349	1691	4
6530	1349	1692	5
6531	1349	1693	9
6532	1349	1694	2
6533	1349	1695	2
6534	1350	1691	3
6535	1350	1692	5
6536	1350	1693	6
6537	1350	1694	2
6538	1350	1695	3
6539	1351	1773	3
6540	1351	1686	2
6541	1351	1739	5
6542	1351	1774	1
6543	1351	1688	3
6544	1352	1709	7
6545	1352	1710	6
6546	1352	1707	7
6547	1352	1711	6
6548	1352	1712	6
6549	1353	1748	9
6550	1353	1701	6
6551	1353	1613	3
6552	1353	1747	9
6553	1353	1704	1
6554	1354	1737	5
6555	1354	1763	1
6556	1354	1707	1
6557	1354	1747	1
6558	1354	1704	1
6559	1355	1775	4
6560	1355	1701	1
6561	1355	1684	2
6562	1355	1776	1
6563	1355	1704	3
6564	1356	1728	3
6565	1356	1701	1
6566	1356	1702	4
6567	1356	1776	2
6568	1356	1704	1
6569	1357	1746	4
6570	1357	1777	4
6571	1357	1701	6
6572	1357	1684	3
6573	1357	1704	1
6574	1358	1775	4
6575	1358	1778	5
6576	1358	1686	4
6577	1358	1779	4
6578	1358	1688	5
6579	1359	1780	4
6580	1359	1731	9
6581	1359	1684	4
6582	1359	1781	5
6583	1359	1699	1
6584	1360	1782	5
6585	1360	1686	1
6586	1360	1613	2
6587	1360	1783	2
6588	1360	1688	3
6589	1361	1513	5
6590	1361	1784	6
6591	1361	1613	6
6592	1361	1785	5
6593	1361	1699	8
6594	1362	1716	3
6595	1362	1717	3
6596	1362	1718	1
6597	1362	1719	1
6598	1362	1720	1
6599	1363	1709	6
6600	1363	1710	6
6601	1363	1707	5
6602	1363	1711	3
6603	1363	1712	6
6604	1364	1786	8
6605	1364	1701	5
6606	1364	1702	2
6607	1364	1747	10
6608	1364	1704	6
6609	1365	1709	6
6610	1365	1710	9
6611	1365	1707	7
6612	1365	1711	2
6613	1365	1712	7
6614	1366	1709	6
6615	1366	1710	11
6616	1366	1707	8
6617	1366	1711	6
6618	1366	1712	7
6619	1367	1787	5
6620	1367	1692	3
6621	1367	1788	2
6622	1367	1789	1
6623	1367	1699	1
6624	1368	1691	3
6625	1368	1692	7
6626	1368	1693	9
6627	1368	1694	1
6628	1368	1695	4
6629	1369	1737	5
6630	1369	1686	3
6631	1369	1790	2
6632	1369	1688	4
6633	1369	1791	3
6634	1370	1792	3
6635	1370	1692	6
6636	1370	1693	3
6637	1370	1694	2
6638	1370	1695	2
6639	1371	1691	5
6640	1371	1692	4
6641	1371	1693	2
6642	1371	1694	1
6643	1371	1695	1
6644	1372	1691	4
6645	1372	1692	6
6646	1372	1693	8
6647	1372	1694	2
6648	1372	1695	4
6649	1373	1691	4
6650	1373	1692	7
6651	1373	1693	8
6652	1373	1694	2
6653	1373	1695	5
6654	1374	1748	5
6655	1374	1701	6
6656	1374	1718	1
6657	1374	1793	1
6658	1374	1704	5
6659	1375	1716	3
6660	1375	1717	9
6661	1375	1718	2
6662	1375	1719	1
6663	1375	1720	5
6664	1376	1766	6
6665	1376	1701	6
6666	1376	1794	6
6667	1376	1704	6
6668	1376	1543	8
6669	1377	1716	4
6670	1377	1717	6
6671	1377	1718	2
6672	1377	1719	2
6673	1377	1720	8
6674	1378	1691	5
6675	1378	1692	8
6676	1378	1693	8
6677	1378	1694	4
6678	1378	1695	1
6679	1379	1691	4
6680	1379	1692	8
6681	1379	1693	9
6682	1379	1694	3
6683	1379	1695	8
6684	1380	1716	3
6685	1380	1717	7
6686	1380	1718	3
6687	1380	1719	1
6688	1380	1720	3
6689	1381	1709	6
6690	1381	1710	7
6691	1381	1707	6
6692	1381	1711	3
6693	1381	1712	2
6694	1382	1696	4
6695	1382	1795	11
6696	1382	1707	6
6697	1382	1764	4
6698	1382	1699	1
6699	1383	1709	4
6700	1383	1710	9
6701	1383	1707	7
6702	1383	1711	6
6703	1383	1712	4
6704	1384	1716	5
6705	1384	1717	9
6706	1384	1718	4
6707	1384	1719	1
6708	1384	1720	9
6709	1385	1796	4
6710	1385	1797	5
6711	1385	1701	6
6712	1385	1798	1
6713	1385	1704	4
6714	1386	1723	4
6715	1386	1701	8
6716	1386	1718	3
6717	1386	1799	9
6718	1386	1704	6
6719	1387	1716	3
6720	1387	1717	9
6721	1387	1718	1
6722	1387	1719	3
6723	1387	1720	4
6724	1388	1691	3
6725	1388	1692	6
6726	1388	1693	7
6727	1388	1694	4
6728	1388	1695	5
6729	1389	1709	7
6730	1389	1710	9
6731	1389	1707	7
6732	1389	1711	6
6733	1389	1712	10
6734	1390	1800	5
6735	1390	1706	4
6736	1390	1745	2
6737	1390	1562	4
6738	1390	1549	2
6739	1391	1558	3
6740	1391	1554	6
6741	1391	1801	7
6742	1391	1562	5
6743	1391	1543	6
6744	1392	1582	1
6745	1392	1784	5
6746	1392	1714	5
6747	1392	1498	2
6748	1392	1562	1
6749	1393	1802	11
6750	1393	1803	10
6751	1393	1804	7
6752	1393	1805	11
6753	1393	1806	9
6754	1393	1807	1
6755	1394	1808	6
6756	1394	1809	4
6757	1394	1810	3
6758	1394	1811	2
6759	1394	1812	3
6760	1394	1813	14
6761	1394	1814	1
6762	1394	1815	11
6763	1395	1816	6
6764	1395	1812	3
6765	1395	1813	14
6766	1395	1804	5
6767	1395	1817	4
6768	1395	1805	2
6769	1395	1818	4
6770	1396	1819	4
6771	1396	1820	3
6772	1396	1812	4
6773	1396	1821	14
6774	1396	1822	9
6775	1397	1823	3
6776	1397	1824	5
6777	1397	1825	2
6778	1397	1826	7
6779	1397	1827	10
6780	1398	1828	7
6781	1398	1814	5
6782	1398	1829	7
6783	1398	1826	7
6784	1398	1830	9
6785	1399	1831	13
6786	1399	1832	4
6787	1399	1833	4
6788	1399	1834	7
6789	1399	1835	9
6790	1399	1836	3
6791	1400	1837	2
6792	1400	1838	7
6793	1400	1829	13
6794	1400	1839	7
6795	1400	1840	3
6796	1401	1841	8
6797	1401	1812	3
6798	1401	1813	14
6799	1401	1838	7
6800	1401	1817	1
6801	1401	1805	1
6802	1401	1818	7
6803	1402	1842	13
6804	1402	1843	8
6805	1402	1844	5
6806	1402	1829	13
6807	1402	1845	5
6808	1402	1846	2
6809	1402	1847	12
6810	1403	1848	9
6811	1403	1812	11
6812	1403	1849	14
6813	1403	1814	5
6814	1403	1826	8
6815	1404	1850	10
6816	1404	1851	6
6817	1404	1838	6
6818	1404	1814	6
6819	1404	1846	2
6820	1404	1817	7
6821	1404	1830	13
6822	1405	1852	7
6823	1405	1853	7
6824	1405	1812	4
6825	1405	1813	14
6826	1405	1804	6
6827	1405	1835	9
6828	1405	1854	8
6829	1406	1855	3
6830	1406	1856	4
6831	1406	1857	3
6832	1406	1812	11
6833	1406	1849	14
6834	1406	1833	7
6835	1406	1858	9
6836	1407	1859	4
6837	1407	1812	5
6838	1407	1821	14
6839	1407	1804	6
6840	1407	1860	4
6841	1407	1861	3
6842	1407	1834	4
6843	1408	1862	9
6844	1408	1863	5
6845	1408	1833	7
6846	1408	1864	7
6847	1408	1829	4
6848	1408	1865	4
6849	1409	1866	12
6850	1409	1867	11
6851	1409	1868	8
6852	1409	1869	9
6853	1409	1870	12
6854	1409	1854	5
6855	1410	1871	2
6856	1410	1872	2
6857	1410	1830	9
6858	1410	1873	6
6859	1410	1874	4
6860	1410	1875	2
6861	1411	1876	7
6862	1411	1877	11
6863	1411	1829	13
6864	1411	1861	13
6865	1411	1870	13
6866	1412	1878	1
6867	1412	1879	2
6868	1412	1880	5
6869	1412	1830	8
6870	1412	1874	3
6871	1413	1841	13
6872	1413	1881	4
6873	1413	1804	5
6874	1413	1882	5
6875	1413	1860	2
6876	1413	1861	7
6877	1414	1883	9
6878	1414	1884	7
6879	1414	1814	3
6880	1414	1817	4
6881	1414	1839	8
6882	1414	1818	7
6883	1415	1885	4
6884	1415	1833	3
6885	1415	1864	9
6886	1415	1829	6
6887	1416	1886	6
6888	1416	1887	9
6889	1416	1888	5
6890	1416	1832	7
6891	1416	1873	11
6892	1417	1889	8
6893	1417	1812	5
6894	1417	1890	14
6895	1417	1864	7
6896	1417	1817	5
6897	1417	1839	6
6898	1417	1891	8
6899	1418	1892	8
6900	1418	1893	7
6901	1418	1868	7
6902	1418	1894	9
6903	1418	1895	9
6904	1419	1900	8
6905	1419	1901	6
6906	1419	1816	11
6907	1419	1832	8
6908	1419	1902	11
6909	1420	1903	3
6910	1420	1900	9
6911	1420	1904	6
6912	1420	1905	7
6913	1420	1906	3
6914	1420	1907	1
6915	1421	1908	4
6916	1421	1852	8
6917	1421	1909	3
6918	1421	1910	4
6919	1421	1873	5
6920	1421	1865	6
6921	1422	1911	3
6922	1422	1912	8
6923	1422	1913	11
6924	1422	1914	9
6925	1422	1873	7
6926	1422	1902	3
6927	1423	1915	9
6928	1423	1916	9
6929	1423	1917	6
6930	1423	1918	5
6931	1423	1865	11
6932	1424	1887	10
6933	1424	1919	11
6934	1424	1904	8
6935	1424	1920	4
6936	1424	1921	4
6937	1424	1922	11
6938	1425	1923	5
6939	1425	1897	7
6940	1425	1924	5
6941	1425	1922	9
6942	1425	1902	11
6943	1426	1925	10
6944	1426	1926	5
6945	1426	1832	8
6946	1426	1835	11
6947	1426	1854	8
6948	1427	1927	5
6949	1427	1928	11
6950	1427	1909	8
6951	1427	1835	7
6952	1427	1854	6
6953	1428	1915	9
6954	1428	1929	4
6955	1428	1930	2
6956	1428	1918	5
6957	1428	1865	9
6958	1429	1931	8
6959	1429	1932	6
6960	1429	1933	7
6961	1429	1832	5
6962	1429	1934	7
6963	1429	1865	8
6964	1430	1935	8
6965	1430	1936	9
6966	1430	1937	7
6967	1430	1938	7
6968	1430	1835	1
6969	1430	1865	4
6970	1431	1939	5
6971	1431	1940	3
6972	1431	1941	6
6973	1431	1916	8
6974	1431	1942	8
6975	1431	1902	8
6976	1432	1943	13
6977	1432	1944	9
6978	1432	1909	11
6979	1432	1835	7
6980	1432	1854	8
6981	1433	1945	7
6982	1433	1946	9
6983	1433	1887	9
6984	1433	1947	13
6985	1433	1948	8
6986	1433	1949	10
6987	1434	1950	3
6988	1434	1951	8
6989	1434	1952	8
6990	1434	1832	6
6991	1434	1873	7
6992	1434	1865	7
6993	1435	1953	7
6994	1435	1954	9
6995	1435	1832	7
6996	1435	1934	6
6997	1435	1865	11
6998	1436	1955	4
6999	1436	1956	9
7000	1436	1916	10
7001	1436	1957	5
7002	1436	1873	8
7003	1436	1854	6
7004	1437	1958	9
7005	1437	1959	11
7006	1437	1960	6
7007	1437	1840	4
7008	1438	1887	9
7009	1438	1961	11
7010	1438	1909	9
7011	1438	1962	4
7012	1438	1832	9
7013	1438	1873	7
7014	1439	1963	6
7015	1439	1915	10
7016	1439	1964	5
7017	1439	1957	6
7018	1439	1835	9
7019	1440	1887	10
7020	1440	1941	6
7021	1440	1897	11
7022	1440	1883	6
7023	1440	1954	10
7024	1440	1934	8
7025	1441	1965	8
7026	1441	1888	2
7027	1441	1966	4
7028	1441	1967	6
7029	1441	1854	5
7030	1442	1968	2
7031	1442	1969	4
7032	1442	1970	9
7033	1442	1971	7
7034	1443	1972	3
7035	1443	1973	9
7036	1443	1974	1
7037	1443	1922	11
7038	1443	1902	11
7039	1444	1975	5
7040	1444	1900	13
7041	1444	1901	8
7042	1444	1976	3
7043	1444	1934	9
7044	1444	1902	11
7045	1445	1887	9
7046	1445	1977	9
7047	1445	1978	8
7048	1445	1979	6
7049	1445	1922	11
7050	1446	1980	3
7051	1446	1981	5
7052	1446	1953	9
7053	1446	1982	9
7054	1446	1934	11
7055	1446	1902	11
7056	1447	1983	6
7057	1447	1944	9
7058	1447	1984	6
7059	1447	1883	11
7060	1447	1934	9
7061	1448	1985	2
7062	1448	1986	4
7063	1448	1913	13
7064	1448	1987	9
7065	1448	1835	9
7066	1448	1854	6
7067	1449	1973	8
7068	1449	1914	6
7069	1449	1905	4
7070	1449	1988	2
7071	1449	1895	7
7072	1449	1865	6
7073	1450	1989	5
7074	1450	1990	10
7075	1450	1991	11
7076	1450	1992	7
7077	1450	1873	9
7078	1450	1854	7
7079	1451	1993	3
7080	1451	1994	7
7081	1451	1992	5
7082	1451	1918	4
7083	1451	1865	8
7084	1452	1956	9
7085	1452	1992	9
7086	1452	1995	3
7087	1452	1832	8
7088	1452	1934	9
7089	1452	1865	11
7090	1453	1996	4
7091	1453	1961	9
7092	1453	1938	7
7093	1453	1853	6
7094	1453	1934	9
7095	1453	1902	11
7096	1454	1997	8
7097	1454	1829	3
7098	1454	1834	9
7099	1454	1839	9
7100	1454	1836	2
7101	1454	1902	11
7102	1455	1998	6
7103	1455	1999	6
7104	1455	2000	9
7105	1455	2001	4
7106	1455	1922	6
7107	1455	1854	6
7108	1456	2002	5
7109	1456	2003	9
7110	1456	1997	8
7111	1456	2004	4
7112	1456	1873	8
7113	1456	1902	11
7114	1457	1999	6
7115	1457	1897	11
7116	1457	2005	10
7117	1457	2001	4
7118	1457	1934	11
7119	1457	1854	6
7120	1458	2006	4
7121	1458	2007	3
7122	1458	1867	8
7123	1458	2008	7
7124	1458	1971	5
7125	1458	1902	7
7126	1459	1953	2
7127	1459	1877	4
7128	1459	1832	1
7129	1459	1873	2
7130	1459	2009	3
7131	1460	2010	6
7132	1460	1852	7
7133	1460	1917	8
7134	1460	2011	11
7135	1460	1835	11
7136	1460	1854	14
7137	1461	1964	8
7138	1461	2012	1
7139	1461	2013	3
7140	1461	1934	7
7141	1461	1854	7
7142	1462	2014	6
7143	1462	2015	4
7144	1462	1925	6
7145	1462	2016	5
7146	1462	2017	7
7147	1462	2018	5
7148	1463	2019	9
7149	1463	2020	7
7150	1463	2021	7
7151	1463	1922	9
7152	1463	1865	8
7153	1464	1945	9
7154	1464	1961	4
7155	1464	1938	11
7156	1464	1922	9
7157	1464	1902	8
7158	1465	2022	2
7159	1465	1945	2
7160	1465	1868	6
7161	1465	1934	11
7162	1465	1854	6
7163	1466	2023	4
7164	1466	2024	4
7165	1466	2025	5
7166	1466	2026	1
7167	1466	2027	1
7168	1467	2028	3
7169	1467	2029	5
7170	1467	1853	8
7171	1467	2030	1
7172	1467	2031	7
7173	1468	2032	3
7174	1468	2033	5
7175	1468	2034	7
7176	1468	2035	1
7177	1468	1918	6
7178	1469	2036	6
7179	1469	2037	7
7180	1469	2038	4
7181	1469	1858	8
7182	1469	2009	4
7183	1470	1859	4
7184	1470	2039	9
7185	1470	2040	5
7186	1470	2041	1
7187	1470	1858	12
7188	1471	2023	5
7189	1471	2042	4
7190	1471	2043	3
7191	1471	2029	7
7192	1471	2044	4
7193	1471	1858	3
7194	1472	2045	4
7195	1472	2037	5
7196	1472	2046	3
7197	1472	2047	4
7198	1472	2048	6
7199	1473	2049	6
7200	1473	2050	5
7201	1473	2037	8
7202	1473	1995	2
7203	1473	1858	7
7204	1474	2051	3
7205	1474	2039	9
7206	1474	2052	6
7207	1474	2053	2
7208	1474	1942	7
7209	1475	2054	3
7210	1475	1989	3
7211	1475	2034	5
7212	1475	2035	1
7213	1475	2027	2
7214	1476	2055	3
7215	1476	2056	3
7216	1476	2029	9
7217	1476	2057	3
7218	1476	1858	2
7219	1477	1809	2
7220	1477	2058	9
7221	1477	1853	5
7222	1477	2059	4
7223	1477	1942	5
7224	1478	2060	7
7225	1478	2061	4
7226	1478	2062	8
7227	1478	1988	3
7228	1478	2027	13
7229	1479	2045	3
7230	1479	2063	7
7231	1479	2046	4
7232	1479	2064	1
7233	1479	1907	4
7234	1480	2065	4
7235	1480	2034	7
7236	1480	2066	6
7237	1480	2035	1
7238	1480	2027	3
7239	1481	2067	2
7240	1481	2068	4
7241	1481	2063	4
7242	1481	2041	1
7243	1481	1907	2
7244	1482	2010	1
7245	1482	2069	7
7246	1482	1883	7
7247	1482	2013	3
7248	1482	1942	1
7249	1483	2070	4
7250	1483	2071	8
7251	1483	2052	11
7252	1483	2072	4
7253	1483	2031	8
7254	1484	2022	2
7255	1484	2073	3
7256	1484	2074	11
7257	1484	2075	1
7258	1484	2076	2
7259	1484	1918	6
7260	1485	2077	3
7261	1485	2078	4
7262	1485	1816	4
7263	1485	2079	2
7264	1485	2031	6
7265	1486	2080	3
7266	1486	2081	6
7267	1486	2082	9
7268	1486	2083	1
7269	1486	1907	1
7270	1487	2051	2
7271	1487	2084	2
7272	1487	2029	5
7273	1487	2027	1
7274	1487	2085	2
7275	1488	2086	5
7276	1488	2015	7
7277	1488	2087	9
7278	1488	2088	3
7279	1488	2048	2
7280	1489	2089	3
7281	1489	2068	6
7282	1489	2090	8
7283	1489	2026	3
7284	1489	1895	5
7285	1490	2091	4
7286	1490	2092	3
7287	1490	2052	6
7288	1490	2093	5
7289	1490	1918	3
7290	1491	2094	4
7291	1491	2095	3
7292	1491	1970	7
7293	1491	2053	2
7294	1491	1942	11
7295	1492	2095	3
7296	1492	2096	4
7297	1492	2052	5
7298	1492	1883	7
7299	1492	1942	4
7300	1493	2097	5
7301	1493	2043	6
7302	1493	2090	8
7303	1493	2098	2
7304	1493	1942	7
7305	1494	2045	3
7306	1494	2099	7
7307	1494	2029	9
7308	1494	2072	2
7309	1494	2031	3
7310	1495	2045	3
7311	1495	2063	6
7312	1495	2046	4
7313	1495	2059	4
7314	1495	1907	3
7315	1496	2022	2
7316	1496	2100	3
7317	1496	2101	9
7318	1496	2102	4
7319	1496	1918	8
7320	1497	2103	3
7321	1497	1958	9
7322	1497	2104	4
7323	1497	2013	4
7324	1497	1942	9
7325	1498	2063	6
7326	1498	2105	4
7327	1498	2106	2
7328	1498	2026	6
7329	1498	1942	3
7330	1499	1931	4
7331	1499	2039	8
7332	1499	2066	3
7333	1499	2107	3
7334	1499	2027	1
7335	1500	2108	3
7336	1500	2025	6
7337	1500	2106	1
7338	1500	2109	4
7339	1500	2031	4
7340	1501	2110	12
7341	1501	2025	10
7342	1501	2066	8
7343	1501	2111	6
7344	1501	2031	8
7345	1502	2084	4
7346	1502	2071	7
7347	1502	2112	1
7348	1502	2113	3
7349	1502	2031	7
7350	1503	2045	4
7351	1503	2114	9
7352	1503	2115	2
7353	1503	2041	1
7354	1503	1858	8
7355	1504	2089	4
7356	1504	2068	6
7357	1504	2090	9
7358	1504	2026	1
7359	1504	1895	2
7360	1505	2045	3
7361	1505	1933	8
7362	1505	2046	3
7363	1505	2064	1
7364	1505	1907	1
7365	1506	1859	3
7366	1506	2116	4
7367	1506	2039	10
7368	1506	2117	4
7369	1506	1858	5
7370	1507	2014	5
7371	1507	2096	3
7372	1507	1816	3
7373	1507	2118	4
7374	1507	1907	3
7375	1508	2054	3
7376	1508	2034	9
7377	1508	2066	3
7378	1508	2035	1
7379	1508	2027	2
7380	1509	2089	3
7381	1509	2019	6
7382	1509	2063	8
7383	1509	2001	4
7384	1509	1895	5
7385	1510	2119	4
7386	1510	2120	7
7387	1510	2121	9
7388	1510	2122	4
7389	1510	1942	4
7390	1511	2123	4
7391	1511	2039	8
7392	1511	1883	6
7393	1511	2026	1
7394	1511	1942	1
7395	1512	2039	9
7396	1512	2106	3
7397	1512	2118	2
7398	1512	2035	4
7399	1512	1858	6
7400	1513	2042	3
7401	1513	2034	8
7402	1513	2124	1
7403	1513	1881	3
7404	1513	2027	8
7405	1514	1940	2
7406	1514	1970	6
7407	1514	2125	1
7408	1514	2118	9
7409	1514	1895	1
7410	1515	2049	6
7411	1515	1886	2
7412	1515	2037	8
7413	1515	2066	6
7414	1515	2126	3
7415	1515	1858	5
7416	1516	2049	5
7417	1516	2037	7
7418	1516	2066	9
7419	1516	2038	6
7420	1516	1858	8
7421	1517	2127	2
7422	1517	2114	5
7423	1517	2041	1
7424	1517	2031	1
7425	1517	2128	6
7426	1518	2054	4
7427	1518	2034	11
7428	1518	2066	8
7429	1518	2079	1
7430	1518	2027	7
7431	1519	2065	3
7432	1519	1989	2
7433	1519	2034	11
7434	1519	2035	1
7435	1519	2027	4
7436	1520	2129	1
7437	1520	2099	3
7438	1520	2130	9
7439	1520	2117	1
7440	1520	2031	7
7441	1521	2129	4
7442	1521	2099	4
7443	1521	2130	8
7444	1521	2131	3
7445	1521	2027	9
7446	1522	2132	2
7447	1522	2007	9
7448	1522	2090	8
7449	1522	2083	2
7450	1522	1858	5
7451	1523	2133	3
7452	1523	2029	2
7453	1523	1895	1
7454	1523	2128	4
7455	1523	1875	1
7456	1524	2123	2
7457	1524	2084	3
7458	1524	2039	4
7459	1524	2134	1
7460	1524	2031	1
7461	1525	2135	5
7462	1525	2039	2
7463	1525	2136	9
7464	1525	2027	1
7465	1525	1836	1
7466	1526	2137	4
7467	1526	2138	7
7468	1526	2007	8
7469	1526	2039	9
7470	1526	2031	5
7471	1527	2108	3
7472	1527	2130	9
7473	1527	1917	6
7474	1527	2111	4
7475	1527	2031	6
7476	1528	2139	5
7477	1528	1951	5
7478	1528	2029	7
7479	1528	2026	2
7480	1528	1858	2
7481	1529	2100	3
7482	1529	2140	2
7483	1529	2141	4
7484	1529	2142	2
7485	1529	2031	2
7486	1530	2143	5
7487	1530	2037	7
7488	1530	1917	6
7489	1530	2059	7
7490	1530	1858	12
7491	1531	2144	5
7492	1531	1970	4
7493	1531	1883	6
7494	1531	2026	1
7495	1531	1942	1
7496	1532	2045	4
7497	1532	2063	6
7498	1532	2046	3
7499	1532	2064	1
7500	1532	1907	5
7501	1533	2145	4
7502	1533	2039	8
7503	1533	2076	2
7504	1533	2001	1
7505	1533	2031	7
7506	1534	2146	3
7507	1534	2045	3
7508	1534	2063	7
7509	1534	2064	1
7510	1534	1907	3
7511	1535	2089	5
7512	1535	2068	6
7513	1535	2147	9
7514	1535	2026	1
7515	1535	1895	6
7516	1536	2056	4
7517	1536	2029	2
7518	1536	1853	2
7519	1536	1858	1
7520	1536	2148	2
7521	1537	2149	4
7522	1537	2150	3
7523	1537	2034	11
7524	1537	2035	1
7525	1537	1918	6
7526	1538	2151	5
7527	1538	2029	8
7528	1538	1853	6
7529	1538	1905	5
7530	1538	1942	5
7531	1539	2054	5
7532	1539	2034	11
7533	1539	2079	1
7534	1539	2027	4
7535	1539	1840	2
7536	1540	2054	5
7537	1540	2034	2
7538	1540	2066	4
7539	1540	2079	1
7540	1540	2027	1
7541	1541	2054	4
7542	1541	2034	8
7543	1541	2066	6
7544	1541	2035	2
7545	1541	2027	6
7546	1542	2065	4
7547	1542	2034	11
7548	1542	2066	7
7549	1542	2079	2
7550	1542	2027	4
7551	1543	2152	3
7552	1543	2153	2
7553	1543	2039	7
7554	1543	2154	4
7555	1543	2155	4
7556	1543	2031	2
7557	1544	2144	7
7558	1544	1990	8
7559	1544	1933	9
7560	1544	2026	4
7561	1544	1942	3
7562	1545	2143	5
7563	1545	2156	8
7564	1545	1853	6
7565	1545	2059	5
7566	1545	1942	8
7567	1546	2010	1
7568	1546	1970	11
7569	1546	1883	8
7570	1546	2157	9
7571	1546	1895	9
7572	1547	2054	6
7573	1547	2034	11
7574	1547	2079	2
7575	1547	2027	3
7576	1547	1840	4
7577	1548	2158	6
7578	1548	2034	13
7579	1548	1926	4
7580	1548	2159	5
7581	1548	1895	9
7582	1549	2010	1
7583	1549	1933	7
7584	1549	1883	8
7585	1549	2160	2
7586	1549	1942	5
7587	1550	2161	5
7588	1550	2063	6
7589	1550	2046	6
7590	1550	2059	4
7591	1550	1907	1
7592	1551	2127	2
7593	1551	2162	7
7594	1551	2163	2
7595	1551	2117	2
7596	1551	1858	3
7597	1552	2022	4
7598	1552	2068	5
7599	1552	2063	8
7600	1552	2026	3
7601	1552	1907	2
7602	1553	2010	3
7603	1553	1970	13
7604	1553	2157	8
7605	1553	1949	7
7606	1553	1942	7
7607	1554	2164	2
7608	1554	2039	8
7609	1554	2165	3
7610	1554	2031	2
7611	1554	1875	1
7612	1555	2166	5
7613	1555	2167	3
7614	1555	2090	11
7615	1555	2026	4
7616	1555	2031	11
7617	1556	2089	3
7618	1556	2096	8
7619	1556	2066	7
7620	1556	2168	4
7621	1556	1942	6
7622	1557	2032	3
7623	1557	2054	4
7624	1557	2034	11
7625	1557	2035	1
7626	1557	2027	5
7627	1558	2067	3
7628	1558	2068	6
7629	1558	2063	9
7630	1558	2041	1
7631	1558	2048	5
7632	1559	2084	5
7633	1559	2034	9
7634	1559	2169	3
7635	1559	1880	5
7636	1559	1895	4
7637	1560	2084	8
7638	1560	2114	8
7639	1560	2169	11
7640	1560	2170	4
7641	1560	1895	6
7642	1561	2171	1
7643	1561	2114	7
7644	1561	1957	1
7645	1561	1895	1
7646	1561	1836	1
7647	1562	2172	6
7648	1562	2173	5
7649	1562	2174	3
7650	1563	2175	5
7651	1564	2176	3
7652	1565	2177	4
7653	1565	2178	5
7654	1566	2176	11
7655	1567	2179	13
7656	1567	2180	4
7657	1568	2176	3
7658	1569	2176	1
7659	1570	2176	3
7660	1571	2181	3
7661	1571	2182	11
7662	1572	2172	4
7663	1572	2183	7
7664	1573	2184	7
7665	1573	2185	8
7666	1574	2186	4
7667	1575	2187	3
7668	1575	2188	11
7669	1576	2189	7
7670	1576	2174	3
7671	1577	2174	2
7672	1577	2190	13
7673	1578	2192	2
7674	1578	2193	4
7675	1579	2194	5
7676	1579	2190	5
7677	1580	2195	11
7678	1580	2196	10
7679	1581	2197	7
7680	1581	2188	9
7681	1582	2190	11
7682	1583	2198	7
7683	1584	2190	4
7684	1585	2195	2
7685	1585	2188	9
7686	1586	2199	8
7687	1587	2200	8
7688	1588	2201	6
7689	1588	2186	4
7690	1589	2185	3
7691	1590	2202	5
7692	1590	2203	1
7693	1591	2204	11
7694	1591	2190	2
7695	1592	2204	3
7696	1593	2192	5
7697	1593	2204	3
7698	1594	2205	9
7699	1594	2178	5
7700	1595	2202	7
7701	1595	2200	8
7702	1596	2206	4
7703	1596	2204	5
7704	1597	2207	3
7705	1597	2193	3
7706	1598	2188	8
7707	1599	2200	4
7708	1599	2204	11
7709	1600	2190	11
7710	1601	2208	4
7711	1602	2204	11
7712	1602	2190	5
7713	1603	2186	2
7714	1603	2198	4
7715	1604	2186	5
7716	1604	2191	1
7717	1605	2209	5
7718	1606	2210	8
7719	1607	2211	8
7720	1607	2212	4
7721	1608	2213	7
7722	1609	2214	2
7723	1610	2191	6
7724	1611	2215	6
7725	1612	2216	5
7726	1613	2217	4
7727	1613	2218	2
7728	1614	2197	1
7729	1615	2219	4
7730	1616	2219	7
7731	1617	2220	3
7732	1617	2221	5
7733	1618	2222	1
7734	1618	2178	3
7735	1619	2223	1
7736	1620	2224	11
7737	1621	2204	11
7738	1621	2190	4
7739	1622	2225	5
7740	1623	2213	3
7741	1624	2226	2
7742	1625	2215	5
7743	1626	2204	2
7744	1626	2190	1
7745	1627	2227	8
7746	1628	2228	1
7747	1629	2226	1
7748	1630	2229	1
7749	1631	2198	9
7750	1632	2230	1
7751	1632	2231	3
7752	1633	2216	3
7753	1634	2191	8
7754	1635	2197	5
7755	1636	2229	2
7756	1637	2225	5
7757	1638	2232	5
7758	1639	2204	1
7759	1639	2190	1
7760	1640	2233	6
7761	1641	2232	1
7762	1642	2227	7
7763	1643	2216	4
7764	1644	2226	7
7765	1644	2234	2
7766	1645	2224	5
7767	1646	2233	5
7768	1647	2235	2
7769	1647	2236	3
7770	1648	2237	2
7771	1649	2197	5
7772	1650	2224	11
7773	1651	2191	9
7774	1652	2238	11
7775	1653	2219	4
7776	1654	2228	3
7777	1655	2239	9
7778	1656	2219	1
7779	1657	2240	6
7780	1658	2241	11
7781	1658	2242	5
7782	1658	2243	11
7783	1658	2244	6
7784	1658	2245	11
7785	1659	2246	14
7786	1659	2247	14
7787	1659	2248	7
7788	1659	2249	4
7789	1659	2245	10
7790	1660	2250	3
7791	1661	2248	6
7792	1661	2251	11
7793	1661	2252	5
7794	1661	2253	4
7795	1661	2254	13
7796	1662	2252	4
7797	1662	2250	3
7798	1662	2255	14
7799	1662	2256	6
7800	1662	2245	9
7801	1663	2257	4
7802	1663	2258	2
7803	1663	2241	11
7804	1663	2259	5
7805	1663	2260	4
7806	1663	2253	3
7807	1664	2261	11
7808	1664	2262	14
7809	1664	2263	9
7810	1664	2264	8
7811	1664	2265	8
7812	1664	2259	11
7813	1664	2266	9
7814	1665	2261	5
7815	1665	2267	14
7816	1665	2251	11
7817	1665	2268	8
7818	1665	2269	7
7819	1666	2248	6
7820	1666	2251	11
7821	1666	2252	6
7822	1666	2249	3
7823	1666	2270	9
7824	1666	2253	4
7825	1667	2271	14
7826	1667	2272	11
7827	1668	2273	7
7828	1668	2274	8
7829	1668	2253	3
7830	1668	2245	11
7831	1669	2271	14
7832	1669	2272	11
7833	1669	2275	11
7834	1669	2276	3
7835	1669	2260	6
7836	1669	2277	1
7837	1669	2278	9
7838	1670	2279	2
7839	1670	2280	7
7840	1670	2248	8
7841	1670	2268	8
7842	1670	2265	2
7843	1670	2281	7
7844	1671	2282	5
7845	1671	2283	2
7846	1671	2284	10
7847	1671	2285	3
7848	1671	2286	13
7849	1671	2254	8
7850	1672	2287	9
7851	1672	2288	6
7852	1672	2259	6
7853	1672	2289	5
7854	1672	2250	7
7855	1672	2290	11
7856	1673	2263	3
7857	1673	2251	8
7858	1673	2291	6
7859	1673	2242	4
7860	1673	2252	8
7861	1673	2249	1
7862	1674	2292	3
7863	1674	2261	11
7864	1674	2262	14
7865	1674	2264	8
7866	1674	2243	11
7867	1674	2254	11
7868	1675	2263	7
7869	1675	2264	9
7870	1675	2281	6
7871	1675	2289	4
7872	1675	2245	9
7873	1676	2293	11
7874	1676	2294	2
7875	1676	2271	14
7876	1676	2272	11
7877	1676	2286	6
7878	1676	2244	12
7879	1676	2254	8
7880	1677	2263	6
7881	1677	2268	11
7882	1677	2281	6
7883	1677	2289	6
7884	1677	2254	9
7885	1678	2295	14
7886	1678	2272	5
7887	1678	2263	5
7888	1678	2251	2
7889	1678	2252	6
7890	1678	2289	13
7891	1678	2250	7
7892	1679	2261	11
7893	1679	2267	14
7894	1679	2248	9
7895	1679	2275	11
7896	1679	2252	8
7897	1679	2289	4
7898	1679	2296	2
7899	1679	2278	6
7900	1680	2263	5
7901	1680	2251	3
7902	1680	2291	6
7903	1680	2242	4
7904	1680	2252	2
7905	1680	2249	5
7906	1680	2289	5
7907	1681	2297	5
7908	1681	2298	11
7909	1681	2299	8
7910	1681	2289	13
7911	1681	2244	5
7912	1681	2245	11
7913	1682	2300	6
7914	1682	2287	11
7915	1682	2286	9
7916	1682	2243	8
7917	1682	2270	9
7918	1682	2301	3
7919	1683	2302	9
7920	1683	2303	3
7921	1683	2304	2
7922	1683	2260	2
7923	1684	2310	4
7924	1684	2311	9
7925	1684	2312	7
7926	1684	2309	12
7927	1684	2313	5
7928	1684	2245	8
7929	1685	2314	6
7930	1685	2315	5
7931	1685	2316	3
7932	1685	2285	5
7933	1685	2309	6
7934	1685	2254	8
7935	1686	2317	8
7936	1686	2318	9
7937	1686	2319	9
7938	1686	2309	9
7939	1687	2320	4
7940	1687	2264	2
7941	1687	2281	2
7942	1687	2243	5
7943	1687	2289	3
7944	1687	2321	2
7945	1688	2322	4
7946	1688	2323	5
7947	1688	2264	11
7948	1688	2324	8
7949	1689	970	14
7950	1689	157	9
7951	1689	158	10
7952	1689	159	5
7953	1689	971	14
7954	1690	972	7
7955	1690	162	14
7956	1690	973	9
7957	1690	974	14
7958	1690	975	5
7959	1690	166	5
7960	1691	167	9
7961	1691	976	8
7962	1691	977	9
7963	1691	978	4
7964	1691	171	7
7965	1692	172	12
7966	1692	979	7
7967	1692	174	5
7968	1692	175	9
7969	1692	980	14
7970	1693	177	14
7971	1693	981	9
7972	1693	179	6
7973	1693	982	6
7974	1693	181	12
7975	1694	182	12
7976	1695	183	5
7977	1695	184	4
7978	1695	983	13
7979	1695	984	4
7980	1695	187	9
7981	1695	188	9
7982	1696	985	11
7983	1696	986	9
7984	1696	987	11
7985	1696	988	11
7986	1696	193	11
7987	1697	194	13
7988	1697	989	9
7989	1697	196	9
7990	1697	990	9
7991	1697	198	5
7992	1698	991	9
7993	1698	992	6
7994	1698	993	4
7995	1698	994	2
7996	1698	203	2
7997	1699	995	6
7998	1700	996	8
7999	1701	206	5
8000	1701	997	5
8001	1702	998	10
8002	1703	209	4
8003	1703	999	9
8004	1703	211	8
8005	1703	212	11
8006	1703	213	8
8007	1703	1000	9
8008	1704	215	9
8009	1704	216	4
8010	1704	1001	9
8011	1704	1002	11
8012	1704	219	9
8013	1704	213	11
8014	1705	220	12
8015	1705	1003	7
8016	1705	1004	11
8017	1705	1005	13
8018	1705	224	6
8019	1706	225	12
8020	1706	1006	6
8021	1706	1007	7
8022	1706	228	7
8023	1706	229	7
8024	1707	230	4
8025	1707	1008	7
8026	1707	232	1
8027	1707	1009	4
8028	1707	234	1
8029	1708	1010	7
8030	1708	1011	4
8031	1708	237	8
8032	1708	238	1
8033	1708	239	7
8034	1708	240	9
8035	1709	241	12
8036	1709	242	4
8037	1709	1012	5
8038	1709	237	11
8039	1709	239	8
8040	1709	240	9
8041	1710	244	11
8042	1710	245	11
8043	1710	1013	11
8044	1710	1014	11
8045	1710	1015	9
8046	1710	249	11
8047	1711	250	5
8048	1711	1016	11
8049	1711	1017	11
8050	1711	1018	9
8051	1711	249	11
8052	1712	254	9
8053	1712	1019	6
8054	1712	1020	13
8055	1712	1021	5
8056	1712	258	2
8057	1713	259	4
8058	1713	1022	7
8059	1714	261	2
8060	1714	1023	4
8061	1715	1024	14
8062	1716	1025	6
8063	1717	1026	13
8064	1718	1027	6
8065	1718	267	9
8066	1718	268	9
8067	1718	1028	6
8068	1718	270	2
8069	1718	271	5
8070	1718	272	6
8071	1719	1029	11
8072	1719	274	5
8073	1719	268	5
8074	1719	275	6
8075	1719	276	6
8076	1719	1030	9
8077	1720	1031	6
8078	1720	279	5
8079	1720	1032	11
8080	1720	1033	11
8081	1720	1034	3
8082	1720	283	9
8083	1721	284	8
8084	1721	1035	11
8085	1721	1036	6
8086	1721	287	12
8087	1721	283	9
8088	1721	1030	7
8089	1722	288	4
8090	1722	1037	8
8091	1722	1038	7
8092	1722	287	1
8093	1722	291	7
8094	1723	292	7
8095	1723	293	5
8096	1723	1039	4
8097	1723	1040	3
8098	1723	296	4
8099	1724	297	6
8100	1724	298	4
8101	1724	1041	4
8102	1724	1042	8
8103	1724	301	2
8104	1725	302	3
8105	1725	1043	14
8106	1725	1044	9
8107	1725	305	9
8108	1725	306	12
8109	1725	307	7
8110	1725	308	2
8111	1726	309	8
8112	1726	310	5
8113	1726	1045	9
8114	1726	306	6
8115	1726	312	6
8116	1726	313	2
8117	1726	314	3
8118	1727	1046	6
8119	1727	1047	5
8120	1727	317	5
8121	1727	1048	10
8122	1727	1049	8
8123	1727	1050	7
8124	1728	321	12
8125	1728	1051	10
8126	1728	1052	4
8127	1728	1053	9
8128	1728	1054	6
8129	1728	326	5
8130	1729	327	13
8131	1729	1055	11
8132	1729	329	9
8133	1729	1056	6
8134	1729	331	4
8135	1730	309	8
8136	1730	1057	7
8137	1730	1058	5
8138	1730	1059	4
8139	1730	335	1
8140	1731	1060	1
8141	1731	337	2
8142	1732	1061	5
8143	1733	1062	6
8144	1734	340	3
8145	1734	1063	6
8146	1735	1064	14
8147	1735	1065	8
8148	1735	344	10
8149	1735	345	6
8150	1736	1066	2
8151	1736	1067	3
8152	1736	1064	5
8153	1736	1068	5
8154	1736	349	5
8155	1736	350	6
8156	1736	351	1
8157	1737	352	11
8158	1737	1069	11
8159	1737	1070	8
8160	1737	1071	13
8161	1737	356	9
8162	1738	357	4
8163	1738	1072	8
8164	1738	359	6
8165	1738	360	9
8166	1738	361	3
8167	1739	362	5
8168	1739	363	5
8169	1739	1073	9
8170	1739	1074	2
8171	1739	366	5
8172	1740	367	3
8173	1740	1075	11
8174	1740	369	2
8175	1740	1076	3
8176	1740	371	5
8177	1741	372	2
8178	1741	1077	8
8179	1741	374	1
8180	1741	1078	3
8181	1741	371	6
8182	1742	367	4
8183	1742	1077	9
8184	1742	376	1
8185	1742	1079	7
8186	1742	378	7
8187	1743	379	5
8188	1743	1080	10
8189	1743	1081	5
8190	1743	1082	5
8191	1743	378	1
8192	1744	383	7
8193	1744	1083	9
8194	1744	385	6
8195	1744	1084	3
8196	1744	387	2
8197	1745	1085	14
8198	1745	1086	14
8199	1745	390	9
8200	1746	391	4
8201	1746	392	7
8202	1746	1087	8
8203	1746	394	4
8204	1746	395	12
8205	1747	1088	2
8206	1747	1085	14
8207	1747	1089	8
8208	1747	398	1
8209	1747	399	2
8210	1747	400	4
8211	1747	401	1
8212	1748	402	13
8213	1748	1090	9
8214	1748	1091	11
8215	1748	1092	9
8216	1748	406	9
8217	1749	1093	8
8218	1749	408	6
8219	1749	1094	9
8220	1749	1095	3
8221	1749	398	6
8222	1749	411	5
8223	1750	412	6
8224	1750	1096	11
8225	1750	1097	4
8226	1750	1098	4
8227	1750	416	6
8228	1751	417	8
8229	1751	418	4
8230	1751	1099	8
8231	1751	1100	5
8232	1751	421	8
8233	1752	422	5
8234	1752	423	3
8235	1752	424	3
8236	1752	1101	9
8237	1752	426	4
8238	1753	427	3
8239	1753	1102	9
8240	1753	1103	6
8241	1753	1104	4
8242	1753	426	5
8243	1754	431	5
8244	1754	1105	5
8245	1754	1106	4
8246	1754	1107	7
8247	1754	421	2
8248	1755	1108	9
8249	1755	1109	3
8250	1755	1110	2
8251	1755	1104	4
8252	1755	426	3
8253	1756	438	14
8254	1757	1111	9
8255	1758	1112	4
8256	1759	1113	9
8257	1760	1114	8
8258	1761	1115	7
8259	1762	1116	8
8260	1763	445	2
8261	1763	1117	4
8262	1764	1118	14
8263	1764	1119	4
8264	1764	449	7
8265	1764	450	11
8266	1764	451	8
8267	1764	452	12
8268	1764	453	11
8269	1764	454	1
8270	1765	455	8
8271	1765	456	11
8272	1765	451	8
8273	1765	457	12
8274	1765	458	2
8275	1765	459	5
8276	1765	460	14
8277	1765	1120	4
8278	1766	1121	9
8279	1766	1122	9
8280	1766	1118	14
8281	1766	1119	5
8282	1766	464	9
8283	1766	452	8
8284	1766	453	7
8285	1767	1118	14
8286	1767	1119	3
8287	1767	465	2
8288	1767	450	9
8289	1767	466	9
8290	1767	467	9
8291	1767	1120	8
8292	1768	468	3
8293	1768	1123	7
8294	1768	1124	11
8295	1768	471	7
8296	1769	1125	7
8297	1769	1126	7
8298	1769	1127	1
8299	1769	1128	2
8300	1769	476	7
8301	1770	477	5
8302	1770	1129	9
8303	1770	1130	2
8304	1770	1131	4
8305	1770	481	5
8306	1771	1132	4
8307	1771	1133	8
8308	1771	1134	1
8309	1771	476	8
8310	1772	1135	6
8311	1772	1136	8
8312	1772	1137	2
8313	1772	488	9
8314	1773	489	4
8315	1773	1138	4
8316	1773	1139	9
8317	1773	492	13
8318	1774	493	6
8319	1774	494	9
8320	1774	1140	6
8321	1774	1141	6
8322	1774	476	4
8323	1775	497	3
8324	1775	1142	8
8325	1775	1126	9
8326	1775	499	2
8327	1775	481	8
8328	1776	500	5
8329	1776	1143	7
8330	1776	502	1
8331	1776	1130	2
8332	1776	503	2
8333	1777	504	1
8334	1777	505	5
8335	1777	1144	3
8336	1777	1145	11
8337	1777	508	2
8338	1778	504	1
8339	1778	505	5
8340	1778	1144	3
8341	1778	1145	11
8342	1778	508	2
8343	1779	509	4
8344	1779	505	7
8345	1779	1146	11
8346	1779	1147	10
8347	1779	512	5
8348	1780	504	1
8349	1780	505	5
8350	1780	1144	9
8351	1780	1145	8
8352	1780	508	4
8353	1781	513	12
8354	1781	514	7
8355	1781	1146	7
8356	1781	1148	11
8357	1781	512	2
8358	1782	504	1
8359	1782	505	4
8360	1782	1144	8
8361	1782	1145	6
8362	1782	508	3
8363	1783	504	2
8364	1783	505	7
8365	1783	1144	1
8366	1783	1145	5
8367	1783	508	1
8368	1784	516	7
8369	1784	1149	9
8370	1784	1150	3
8371	1784	519	3
8372	1784	492	5
8373	1785	504	1
8374	1785	505	6
8375	1785	1144	3
8376	1785	1145	8
8377	1785	508	3
8378	1786	516	4
8379	1786	1149	6
8380	1786	520	6
8381	1786	1151	1
8382	1786	492	1
8383	1787	1152	9
8384	1788	1153	11
8385	1788	1154	6
8386	1788	525	5
8387	1788	526	2
8388	1788	527	12
8389	1788	528	6
8390	1789	529	4
8391	1789	1155	3
8392	1789	531	4
8393	1789	1156	8
8394	1789	1157	5
8395	1789	1158	12
8396	1789	535	12
8397	1790	536	11
8398	1790	1159	5
8399	1790	1160	10
8400	1790	539	11
8401	1790	540	9
8402	1790	541	12
8403	1790	542	11
8404	1791	543	13
8405	1791	1161	6
8406	1791	1162	5
8407	1791	540	2
8408	1791	546	2
8409	1791	542	5
8410	1792	547	9
8411	1792	1163	13
8412	1792	1164	5
8413	1792	550	13
8414	1792	551	7
8415	1793	1165	13
8416	1793	1166	3
8417	1793	1167	7
8418	1793	555	7
8419	1793	1168	3
8420	1793	550	8
8421	1794	557	9
8422	1794	1169	11
8423	1794	1166	8
8424	1794	1170	9
8425	1794	560	11
8426	1794	1171	2
8427	1795	562	4
8428	1795	1166	6
8429	1795	1172	11
8430	1795	1173	9
8431	1795	1174	5
8432	1795	566	11
8433	1796	567	9
8434	1796	568	8
8435	1796	1175	11
8436	1796	1173	10
8437	1796	570	11
8438	1797	571	12
8439	1797	1176	6
8440	1797	1177	8
8441	1797	1178	10
8442	1797	575	7
8443	1797	576	6
8444	1798	577	6
8445	1798	557	8
8446	1798	1179	9
8447	1798	1166	4
8448	1798	1178	13
8449	1798	566	8
8450	1799	1180	2
8451	1799	1172	11
8452	1799	1181	9
8453	1799	1167	11
8454	1799	566	11
8455	1800	581	5
8456	1800	1182	11
8457	1800	583	2
8458	1800	1183	3
8459	1800	585	4
8460	1801	1184	7
8461	1801	1185	9
8462	1801	583	4
8463	1801	1186	5
8464	1801	585	3
8465	1802	1187	8
8466	1802	1185	9
8467	1802	583	5
8468	1802	1186	6
8469	1802	585	7
8470	1803	590	4
8471	1803	1188	8
8472	1803	536	8
8473	1803	1189	7
8474	1803	593	6
8475	1804	1190	4
8476	1804	1191	9
8477	1804	583	6
8478	1804	1192	1
8479	1804	585	9
8480	1805	597	13
8481	1805	1193	11
8482	1805	599	5
8483	1805	1194	6
8484	1805	601	3
8485	1806	602	4
8486	1806	1195	11
8487	1806	555	8
8488	1806	1196	5
8489	1806	585	5
8490	1807	1184	5
8491	1807	1185	5
8492	1807	583	5
8493	1807	1186	6
8494	1807	585	2
8495	1808	605	4
8496	1808	606	4
8497	1808	1197	7
8498	1808	1198	2
8499	1808	609	1
8500	1809	610	3
8501	1809	611	3
8502	1809	1185	7
8503	1809	1199	3
8504	1809	570	3
8505	1810	613	1
8506	1810	1200	7
8507	1810	615	4
8508	1810	1201	2
8509	1810	601	2
8510	1811	617	3
8511	1812	618	12
8512	1813	1202	3
8513	1813	1203	9
8514	1814	1204	4
8515	1815	1205	5
8516	1816	623	6
8517	1816	624	5
8518	1817	1203	11
8519	1818	1206	4
8520	1818	1207	6
8521	1819	1208	4
8522	1820	1209	3
8523	1821	1210	9
8524	1822	1211	3
8525	1823	1212	5
8526	1824	1213	6
8527	1824	633	11
8528	1824	634	7
8529	1824	635	8
8530	1824	636	2
8531	1824	637	9
8532	1825	1214	13
8533	1825	1215	14
8534	1825	640	13
8535	1825	2325	14
8536	1825	641	9
8537	1825	642	9
8538	1825	1216	11
8539	1826	644	4
8540	1826	1217	6
8541	1826	646	1
8542	1826	647	4
8543	1826	648	1
8544	1827	1218	6
8545	1827	1219	3
8546	1827	1220	11
8547	1827	652	6
8548	1827	1221	7
8549	1828	654	5
8550	1828	1222	7
8551	1828	634	6
8552	1828	656	3
8553	1828	657	3
8554	1829	658	2
8555	1829	1223	9
8556	1829	1224	11
8557	1829	661	5
8558	1829	1225	6
8559	1830	1226	7
8560	1830	664	11
8561	1830	661	3
8562	1830	665	2
8563	1830	1225	8
8564	1831	1227	8
8565	1831	1228	7
8566	1831	1229	5
8567	1831	669	2
8568	1832	670	5
8569	1832	1230	4
8570	1832	1224	8
8571	1832	669	4
8572	1832	672	11
8573	1832	1225	6
8574	1833	1231	7
8575	1833	672	11
8576	1833	640	7
8577	1833	661	7
8578	1833	674	7
8579	1833	635	6
8580	1834	1232	3
8581	1834	1226	8
8582	1834	672	8
8583	1834	661	4
8584	1834	665	2
8585	1835	676	12
8586	1835	1233	9
8587	1835	1234	7
8588	1835	1235	6
8589	1835	680	2
8590	1836	681	2
8591	1836	682	4
8592	1836	1236	7
8593	1836	684	2
8594	1836	1237	7
8595	1837	1238	8
8596	1837	1235	5
8597	1837	1239	4
8598	1837	1240	4
8599	1837	680	3
8600	1838	689	9
8601	1838	1238	9
8602	1838	1235	6
8603	1838	1241	8
8604	1838	691	13
8605	1839	692	6
8606	1839	693	9
8607	1839	1235	9
8608	1839	1242	4
8609	1839	680	7
8610	1840	695	4
8611	1840	1243	9
8612	1840	1244	9
8613	1840	680	8
8614	1841	698	6
8615	1841	1233	10
8616	1841	1235	11
8617	1841	1245	6
8618	1842	700	3
8619	1842	1246	2
8620	1842	1243	9
8621	1842	1244	7
8622	1842	680	6
8623	1843	702	5
8624	1843	1247	7
8625	1843	1248	7
8626	1843	1235	6
8627	1843	680	7
8628	1844	705	5
8629	1844	1249	11
8630	1844	1244	9
8631	1844	1250	6
8632	1844	680	1
8633	1845	1251	8
8634	1845	1234	6
8635	1845	1244	6
8636	1845	709	9
8637	1845	710	8
8638	1846	711	3
8639	1846	1252	7
8640	1846	1253	7
8641	1846	1254	6
8642	1846	691	2
8643	1847	715	3
8644	1847	716	6
8645	1847	1255	9
8646	1847	1256	2
8647	1847	719	3
8648	1848	720	4
8649	1848	1257	7
8650	1848	722	2
8651	1848	1258	5
8652	1848	684	1
8653	1849	724	4
8654	1849	682	6
8655	1849	1259	6
8656	1849	1260	7
8657	1849	727	6
8658	1850	728	2
8659	1850	1261	9
8660	1850	730	3
8661	1850	1262	3
8662	1850	732	6
8663	1851	733	7
8664	1851	734	6
8665	1851	1263	8
8666	1851	1264	11
8667	1851	727	6
8668	1852	715	3
8669	1852	716	9
8670	1852	1255	5
8671	1852	1256	9
8672	1852	719	8
8673	1853	737	6
8674	1853	1265	6
8675	1853	739	4
8676	1853	1266	2
8677	1853	727	6
8678	1854	741	7
8679	1854	682	5
8680	1854	1263	5
8681	1854	1267	9
8682	1854	727	1
8683	1855	715	3
8684	1855	716	7
8685	1855	1255	6
8686	1855	1256	3
8687	1855	719	6
8688	1856	743	8
8689	1856	716	8
8690	1856	1265	8
8691	1856	1256	9
8692	1856	719	9
8693	1857	744	4
8694	1857	1261	6
8695	1857	1268	5
8696	1857	746	4
8697	1857	732	5
8698	1858	747	8
8699	1858	1269	11
8700	1858	749	3
8701	1858	1270	8
8702	1858	751	7
8703	1859	752	6
8704	1859	1261	9
8705	1859	753	5
8706	1859	1271	10
8707	1859	732	7
8708	1860	715	4
8709	1860	716	6
8710	1860	1255	8
8711	1860	1256	3
8712	1860	719	6
8713	1861	755	6
8714	1861	1265	5
8715	1861	756	5
8716	1861	1272	4
8717	1861	758	1
8718	1862	759	4
8719	1862	1273	6
8720	1862	730	4
8721	1862	1274	2
8722	1862	684	1
8723	1863	762	6
8724	1863	1275	7
8725	1863	764	6
8726	1863	1276	2
8727	1863	727	6
8728	1864	1277	5
8729	1864	693	4
8730	1864	1257	7
8731	1864	767	7
8732	1864	751	1
8733	1865	768	3
8734	1865	769	9
8735	1865	1278	8
8736	1865	1279	4
8737	1865	684	1
8738	1866	772	6
8739	1866	1280	5
8740	1866	774	4
8741	1866	1281	6
8742	1866	727	5
8743	1867	776	5
8744	1867	1282	11
8745	1867	778	4
8746	1867	1283	12
8747	1867	727	5
8748	1868	755	7
8749	1868	1265	8
8750	1868	756	7
8751	1868	1272	3
8752	1868	758	4
8753	1869	780	6
8754	1869	769	10
8755	1869	1284	8
8756	1869	1279	3
8757	1869	684	11
8758	1870	762	5
8759	1870	1275	8
8760	1870	764	5
8761	1870	1276	1
8762	1870	751	5
8763	1871	755	6
8764	1871	1265	4
8765	1871	756	8
8766	1871	1272	4
8767	1871	758	1
8768	1872	782	4
8769	1872	1261	7
8770	1872	767	4
8771	1872	1285	8
8772	1872	732	6
8773	1873	784	7
8774	1873	1286	9
8775	1873	753	5
8776	1873	1266	2
8777	1873	751	6
8778	1874	786	4
8779	1874	1261	8
8780	1874	767	5
8781	1874	1285	9
8782	1874	732	8
8783	1875	787	3
8784	1875	1261	4
8785	1875	1287	9
8786	1875	1288	4
8787	1875	732	3
8788	1876	1289	12
8789	1876	1261	1
8790	1876	791	8
8791	1876	1285	7
8792	1876	732	5
8793	1877	755	4
8794	1877	1265	9
8795	1877	756	9
8796	1877	1272	4
8797	1877	758	5
8798	1878	792	1
8799	1878	793	3
8800	1878	1290	8
8801	1878	1291	3
8802	1878	796	4
8803	1879	797	5
8804	1879	798	5
8805	1879	1292	2
8806	1879	1293	7
8807	1879	796	5
8808	1880	801	1
8809	1880	802	2
8810	1880	1290	11
8811	1880	1294	1
8812	1880	796	11
8813	1881	1295	8
8814	1881	805	12
8815	1881	1296	8
8816	1881	1297	10
8817	1881	1298	7
8818	1882	809	5
8819	1882	1299	6
8820	1882	811	12
8821	1882	812	3
8822	1882	813	12
8823	1882	1300	3
8824	1883	1295	6
8825	1883	1301	14
8826	1883	816	4
8827	1883	817	7
8828	1883	811	9
8829	1883	818	12
8830	1883	819	11
8831	1884	820	7
8832	1884	821	5
8833	1884	1302	2
8834	1884	1303	2
8835	1884	818	3
8836	1884	824	12
8837	1884	1304	7
8838	1885	1296	7
8839	1885	1305	8
8840	1885	827	5
8841	1885	828	8
8842	1885	1306	6
8843	1886	1307	2
8844	1886	1308	11
8845	1886	832	6
8846	1886	828	8
8847	1886	833	6
8848	1886	834	2
8849	1887	1309	7
8850	1887	1310	8
8851	1887	827	7
8852	1887	832	7
8853	1887	837	9
8854	1888	838	6
8855	1888	839	6
8856	1888	1311	11
8857	1888	841	8
8858	1888	842	12
8859	1888	843	5
8860	1889	844	9
8861	1889	1312	13
8862	1889	1313	7
8863	1889	1314	7
8864	1889	848	3
8865	1889	849	6
8866	1890	848	5
8867	1890	1315	11
8868	1890	827	1
8869	1890	842	7
8870	1890	849	5
8871	1891	851	4
8872	1891	817	12
8873	1891	837	5
8874	1891	812	6
8875	1891	852	3
8876	1891	853	12
8877	1891	1316	11
8878	1892	1308	11
8879	1892	855	8
8880	1892	817	5
8881	1892	828	9
8882	1892	1317	5
8883	1893	857	12
8884	1893	1318	11
8885	1893	1319	8
8886	1893	1320	1
8887	1893	855	7
8888	1893	861	5
8889	1894	862	8
8890	1894	1321	7
8891	1894	1322	9
8892	1894	1323	6
8893	1894	866	7
8894	1895	1296	7
8895	1895	1314	8
8896	1895	1324	6
8897	1895	868	3
8898	1895	1325	6
8899	1895	827	8
8900	1896	1326	10
8901	1896	1324	8
8902	1896	1327	5
8903	1896	827	11
8904	1896	849	9
8905	1897	872	8
8906	1897	1328	13
8907	1897	1329	13
8908	1897	1330	6
8909	1897	827	9
8910	1898	876	2
8911	1898	1331	9
8912	1898	1296	8
8913	1898	1332	9
8914	1898	1333	6
8915	1898	880	13
8916	1899	881	6
8917	1899	1334	4
8918	1899	1335	7
8919	1899	1336	5
8920	1899	841	3
8921	1900	1337	4
8922	1900	1313	9
8923	1900	1338	11
8924	1900	855	13
8925	1900	887	12
8926	1901	1313	6
8927	1901	1339	11
8928	1901	1340	9
8929	1901	1341	5
8930	1901	880	7
8931	1902	1342	5
8932	1902	1343	9
8933	1902	1334	11
8934	1902	1324	11
8935	1902	827	5
8936	1903	893	4
8937	1903	1344	5
8938	1903	1345	9
8939	1903	1346	1
8940	1903	841	13
8941	1903	1316	8
8942	1904	897	3
8943	1904	1347	9
8944	1904	1348	5
8945	1904	1349	5
8946	1904	901	6
8947	1905	902	2
8948	1905	1296	6
8949	1905	1339	8
8950	1905	1350	6
8951	1905	827	9
8952	1905	1351	3
8953	1906	905	4
8954	1906	906	5
8955	1906	1352	6
8956	1906	1353	7
8957	1906	909	3
8958	1907	910	4
8959	1907	1354	5
8960	1907	912	2
8961	1907	1355	3
8962	1907	914	2
8963	1908	1356	6
8964	1908	1357	9
8965	1908	917	6
8966	1908	1358	9
8967	1908	919	6
8968	1909	920	2
8969	1909	1359	11
8970	1909	839	8
8971	1909	1360	1
8972	1909	866	5
8973	1910	923	5
8974	1910	924	7
8975	1910	1361	8
8976	1910	1362	4
8977	1910	914	7
8978	1911	927	7
8979	1911	1363	5
8980	1911	1352	10
8981	1911	1364	2
8982	1911	930	9
8983	1912	931	12
8984	1912	1365	9
8985	1912	933	2
8986	1912	934	3
8987	1912	1298	3
8988	1913	935	5
8989	1913	1366	6
8990	1913	937	7
8991	1913	1367	5
8992	1913	930	1
8993	1914	939	5
8994	1914	905	4
8995	1914	1357	8
8996	1914	1368	2
8997	1914	930	7
8998	1915	1369	9
8999	1915	1366	7
9000	1915	1370	8
9001	1915	1371	13
9002	1915	1372	9
9003	1916	1373	4
9004	1916	1347	6
9005	1916	839	7
9006	1916	1374	8
9007	1916	866	5
9008	1917	1375	3
9009	1917	1376	8
9010	1917	1299	6
9011	1917	1320	2
9012	1917	919	10
9013	1918	1373	5
9014	1918	1377	10
9015	1918	1378	11
9016	1918	1379	8
9017	1918	866	5
9018	1919	1380	6
9019	1919	1352	7
9020	1919	1381	2
9021	1919	1346	3
9022	1919	930	6
9023	1920	1382	8
9024	1920	1383	3
9025	1920	1384	8
9026	1920	1385	5
9027	1920	914	1
9028	1921	1386	2
9029	1921	1387	6
9030	1921	1358	4
9031	1921	1388	4
9032	1921	1372	6
9033	1922	1389	5
9034	1922	1390	8
9035	1922	1391	7
9036	1922	1364	2
9037	1922	914	3
9038	1923	1392	8
9039	1923	1361	9
9040	1923	1393	5
9041	1923	1394	2
9042	1923	866	4
9043	1924	1395	7
9044	1924	1396	11
9045	1924	1397	6
9046	1924	816	6
9047	1924	1388	8
9048	1925	1398	8
9049	1925	1399	10
9050	1925	1366	3
9051	1925	1400	2
9052	1925	1401	6
9053	1925	1388	8
9054	1926	1402	2
9055	1926	1403	7
9056	1926	1404	5
9057	1926	1348	4
9058	1926	919	3
9059	1927	1405	5
9060	1927	1383	3
9061	1927	1387	8
9062	1927	1406	6
9063	1927	866	7
9064	1928	1407	4
9065	1928	1408	13
9066	1928	1404	4
9067	1928	1409	1
9068	1928	909	2
9069	1929	1389	5
9070	1929	1410	9
9071	1929	1391	7
9072	1929	1364	2
9073	1929	934	9
9074	1930	1411	4
9075	1930	1383	4
9076	1930	1359	9
9077	1930	1412	5
9078	1930	914	1
9079	1931	1413	2
9080	1931	1414	6
9081	1931	1415	4
9082	1931	816	6
9083	1931	866	5
9084	1932	1416	3
9085	1932	1417	9
9086	1932	1418	4
9087	1932	1406	4
9088	1932	934	6
9089	1933	1419	5
9090	1933	1377	9
9091	1933	1378	8
9092	1933	1420	7
9093	1933	866	7
9094	1934	1421	4
9095	1934	1390	3
9096	1934	839	8
9097	1934	1394	5
9098	1934	919	3
9099	1935	1422	7
9100	1935	1352	6
9101	1935	917	7
9102	1935	1423	12
9103	1935	866	9
9104	1936	1424	3
9105	1936	1425	4
9106	1936	1426	11
9107	1936	1427	7
9108	1936	930	8
9109	1937	935	5
9110	1937	1352	7
9111	1937	1412	7
9112	1937	1428	5
9113	1937	1388	8
9114	1938	902	3
9115	1938	1408	7
9116	1938	1429	11
9117	1938	1430	2
9118	1938	914	4
9119	1939	1431	2
9120	1939	1432	8
9121	1939	1433	4
9122	1939	1434	5
9123	1939	901	8
9124	1940	1435	8
9125	1941	1436	4
9126	1941	1437	6
9127	1942	1438	2
9128	1943	1439	2
9129	1944	1440	4
9130	1945	1441	3
9131	1945	1442	5
9132	1945	1443	9
9133	1946	1444	3
9134	1946	1445	6
9135	1947	1446	6
9136	1948	1447	8
9137	1949	1448	8
9138	1950	1449	1
9139	1951	1450	9
9140	1952	1451	11
9141	1952	1445	7
9142	1953	1452	6
9143	1953	1453	8
9144	1954	1454	9
9145	1955	1455	8
9146	1956	1456	4
9147	1956	1457	2
9148	1957	1458	9
9149	1958	1459	9
9150	1959	1460	8
9151	1960	1461	2
9152	1960	1462	1
9153	1961	1463	3
9154	1962	1464	6
9155	1963	1465	11
9156	1964	1466	9
9157	1964	1467	6
9158	1965	1468	9
9159	1966	1469	3
9160	1966	1457	3
9161	1967	1470	3
9162	1967	1471	4
9163	1968	1465	11
9164	1969	1454	5
9165	1970	1463	9
9166	1971	1472	6
9167	1971	1458	7
9168	1972	1473	1
9169	1973	1474	8
9170	1974	1475	4
9171	1975	1476	12
9172	1975	1477	9
9173	1975	1478	11
9174	1975	1479	11
9175	1975	1480	11
9176	1976	1481	7
9177	1977	1482	13
9178	1977	1483	4
9179	1977	1484	11
9180	1977	1485	9
9181	1977	1477	5
9182	1977	1486	5
9183	1977	1487	2
9184	1978	1488	6
9185	1978	1489	4
9186	1978	1487	12
9187	1979	1490	5
9188	1979	1491	5
9189	1979	1492	14
9190	1979	1477	5
9191	1979	1493	4
9192	1979	1494	4
9193	1979	1495	13
9194	1980	1496	11
9195	1980	1497	9
9196	1980	1486	11
9197	1980	1498	2
9198	1980	1499	12
9199	1981	1483	2
9200	1981	1500	4
9201	1981	1501	13
9202	1981	1502	11
9203	1981	1503	5
9204	1981	1504	8
9205	1982	1505	7
9206	1982	1506	13
9207	1982	1502	9
9208	1982	1477	8
9209	1982	1503	5
9210	1982	1507	6
9211	1983	1508	5
9212	1983	1509	2
9213	1983	1510	2
9214	1983	1511	2
9215	1983	1512	8
9216	1984	1513	6
9217	1984	1514	5
9218	1984	1491	13
9219	1984	1515	14
9220	1984	1516	9
9221	1984	1517	8
9222	1984	1495	10
9223	1985	1518	4
9224	1985	1519	13
9225	1985	1477	8
9226	1985	1478	9
9227	1985	1493	4
9228	1986	1520	3
9229	1986	1491	11
9230	1986	1521	14
9231	1986	1522	8
9232	1986	1502	9
9233	1986	1507	4
9234	1986	1499	7
9235	1986	1480	8
9236	1987	1496	9
9237	1987	1523	3
9238	1987	1493	5
9239	1987	1486	6
9240	1987	1494	5
9241	1987	1495	11
9242	1988	1524	7
9243	1988	1491	11
9244	1988	1515	14
9245	1988	1477	5
9246	1988	1525	5
9247	1988	1503	12
9248	1988	1526	11
9249	1989	1527	6
9250	1989	1528	11
9251	1989	1529	10
9252	1989	1491	8
9253	1989	1521	14
9254	1989	1530	4
9255	1990	1531	4
9256	1990	1529	6
9257	1990	1491	7
9258	1990	1532	14
9259	1990	1533	5
9260	1990	1534	4
9261	1991	1535	4
9262	1991	1491	2
9263	1991	1521	14
9264	1991	1536	9
9265	1991	1525	5
9266	1991	1503	7
9267	1991	1537	11
9268	1991	1495	9
9269	1992	1538	5
9270	1992	1490	6
9271	1992	1491	11
9272	1992	1521	14
9273	1992	1516	9
9274	1992	1517	9
9275	1992	1526	9
9276	1993	1528	13
9277	1993	1529	11
9278	1993	1539	10
9279	1993	1540	9
9280	1993	1541	9
9281	1994	1542	3
9282	1994	1525	4
9283	1994	1498	4
9284	1994	1543	7
9285	1994	1495	11
9286	1995	1544	11
9287	1995	1545	11
9288	1995	1546	2
9289	1995	1547	6
9290	1995	1479	12
9291	1996	1548	8
9292	1996	1516	6
9293	1996	1517	9
9294	1996	1498	4
9295	1996	1549	4
9296	1996	1495	11
9297	1997	1550	13
9298	1997	1491	11
9299	1997	1515	14
9300	1997	1477	8
9301	1997	1525	3
9302	1997	1503	5
9303	1997	1526	8
9304	1998	1529	10
9305	1998	1491	11
9306	1998	1532	14
9307	1998	1477	6
9308	1998	1478	6
9309	1998	1493	5
9310	1998	1526	11
9311	1999	1551	6
9312	1999	1552	8
9313	1999	1491	5
9314	1999	1521	14
9315	1999	1516	3
9316	1999	1478	4
9317	2000	1553	2
9318	2000	1554	5
9319	2000	1555	11
9320	2000	1556	8
9321	2000	1511	4
9322	2001	1557	5
9323	2001	1491	6
9324	2001	1492	14
9325	2001	1477	3
9326	2001	1540	2
9327	2001	1503	6
9328	2001	1526	8
9329	2002	1558	4
9330	2002	1559	4
9331	2002	1560	11
9332	2002	1561	9
9333	2002	1562	4
9334	2003	1563	4
9335	2003	1564	3
9336	2003	1565	9
9337	2003	1566	9
9338	2003	1562	8
9339	2004	1567	3
9340	2004	1568	7
9341	2004	1569	8
9342	2004	1511	2
9343	2005	1570	2
9344	2005	1571	9
9345	2005	1572	3
9346	2005	1573	11
9347	2006	1574	5
9348	2006	1575	5
9349	2006	1576	5
9350	2006	1577	5
9351	2006	1530	2
9352	2007	1578	2
9353	2007	1579	9
9354	2007	1572	7
9355	2007	1580	7
9356	2007	1581	7
9357	2008	1582	3
9358	2008	1583	2
9359	2008	1560	7
9360	2008	1584	7
9361	2008	1562	5
9362	2009	1585	1
9363	2009	1586	9
9364	2009	1587	7
9365	2009	1588	3
9366	2009	1581	5
9367	2010	1589	11
9368	2010	1590	8
9369	2010	1591	2
9370	2010	1592	6
9371	2011	1593	5
9372	2011	1594	9
9373	2011	1595	11
9374	2011	1580	9
9375	2012	1596	3
9376	2012	1597	9
9377	2012	1598	7
9378	2012	1599	3
9379	2012	1530	7
9380	2013	1583	3
9381	2013	1600	3
9382	2013	1560	7
9383	2013	1601	8
9384	2013	1602	13
9385	2014	1583	3
9386	2014	1603	3
9387	2014	1576	7
9388	2014	1604	1
9389	2014	1602	9
9390	2015	1605	4
9391	2015	1568	7
9392	2015	1606	7
9393	2015	1530	1
9394	2016	1607	8
9395	2016	1608	9
9396	2016	1609	7
9397	2016	1610	3
9398	2016	1562	6
9399	2017	1611	11
9400	2017	1612	9
9401	2017	1613	8
9402	2017	1614	7
9403	2017	1592	3
9404	2018	1615	2
9405	2018	1616	7
9406	2018	1617	11
9407	2018	1618	3
9408	2018	1511	5
9409	2019	1619	12
9410	2019	1560	8
9411	2019	1601	9
9412	2019	1602	6
9413	2020	1620	2
9414	2020	1621	1
9415	2020	1571	13
9416	2020	1622	7
9417	2020	1511	3
9418	2021	1623	1
9419	2021	1624	7
9420	2021	1587	6
9421	2021	1625	5
9422	2021	1581	7
9423	2022	1626	5
9424	2022	1627	5
9425	2022	1628	9
9426	2022	1569	9
9427	2022	1511	2
9428	2023	1629	7
9429	2023	1630	9
9430	2023	1590	5
9431	2023	1592	9
9432	2024	1575	5
9433	2024	1631	9
9434	2024	1632	1
9435	2024	1633	5
9436	2024	1546	4
9437	2025	1634	2
9438	2025	1635	3
9439	2025	1636	3
9440	2025	1546	2
9441	2025	1516	4
9442	2026	1637	2
9443	2026	1638	5
9444	2026	1639	5
9445	2026	1530	4
9446	2026	1640	3
9447	2027	1641	3
9448	2027	1642	3
9449	2027	1643	8
9450	2027	1590	7
9451	2027	1581	9
9452	2028	1642	4
9453	2028	1644	9
9454	2028	1572	7
9455	2028	1645	8
9456	2028	1592	7
9457	2029	1646	4
9458	2029	1647	8
9459	2029	1648	9
9460	2029	1592	5
9461	2030	1575	11
9462	2030	1612	11
9463	2030	1649	12
9464	2030	1592	12
9465	2030	1516	11
9466	2031	1650	3
9467	2031	1638	7
9468	2031	1584	9
9469	2031	1651	5
9470	2031	1546	3
9471	2032	1652	4
9472	2032	1571	9
9473	2032	1572	5
9474	2032	1533	3
9475	2033	1653	3
9476	2033	1586	9
9477	2033	1654	6
9478	2033	1530	7
9479	2034	1655	2
9480	2034	1652	4
9481	2034	1571	8
9482	2034	1572	6
9483	2034	1533	4
9484	2035	1656	4
9485	2035	1643	9
9486	2035	1587	6
9487	2035	1651	2
9488	2035	1511	6
9489	2036	1641	3
9490	2036	1624	9
9491	2036	1572	9
9492	2036	1657	4
9493	2036	1581	8
9494	2037	1658	3
9495	2037	1659	9
9496	2037	1590	7
9497	2037	1660	1
9498	2037	1530	5
9499	2037	1516	6
9500	2038	1623	1
9501	2038	1624	9
9502	2038	1587	6
9503	2038	1625	6
9504	2038	1581	8
9505	2039	1661	6
9506	2039	1575	8
9507	2039	1662	7
9508	2039	1663	5
9509	2039	1546	2
9510	2040	1664	5
9511	2040	1665	11
9512	2040	1666	8
9513	2040	1667	4
9514	2040	1581	9
9515	2041	1583	2
9516	2041	1668	2
9517	2041	1669	6
9518	2041	1631	7
9519	2041	1511	3
9520	2042	1670	4
9521	2042	1671	4
9522	2042	1528	11
9523	2042	1672	8
9524	2042	1546	6
9525	2043	1673	7
9526	2043	1674	10
9527	2043	1622	8
9528	2043	1675	7
9529	2043	1530	7
9530	2044	1676	3
9531	2044	1643	13
9532	2044	1631	9
9533	2044	1618	3
9534	2044	1530	8
9535	2045	1677	4
9536	2045	1678	3
9537	2045	1665	7
9538	2045	1679	9
9539	2045	1613	8
9540	2045	1530	8
9541	2046	1680	7
9542	2046	1681	9
9543	2046	1682	12
9544	2046	1530	7
9545	2046	1683	4
9546	2047	1594	9
9547	2047	1590	9
9548	2047	1684	5
9549	2047	1511	9
9550	2048	1685	5
9551	2048	1686	1
9552	2048	1613	4
9553	2048	1687	7
9554	2048	1688	1
9555	2049	1689	5
9556	2049	1686	2
9557	2049	1690	3
9558	2049	1645	6
9559	2049	1688	3
9560	2050	1691	4
9561	2050	1692	8
9562	2050	1693	6
9563	2050	1694	1
9564	2050	1695	3
9565	2051	1696	5
9566	2051	1697	7
9567	2051	1698	5
9568	2051	1663	3
9569	2051	1699	9
9570	2052	1700	5
9571	2052	1701	4
9572	2052	1702	1
9573	2052	1703	1
9574	2052	1704	4
9575	2053	1705	4
9576	2053	1706	6
9577	2053	1707	7
9578	2053	1708	2
9579	2053	1699	3
9580	2054	1709	6
9581	2054	1710	8
9582	2054	1707	6
9583	2054	1711	3
9584	2054	1712	11
9585	2055	1551	5
9586	2055	1713	5
9587	2055	1714	5
9588	2055	1715	8
9589	2055	1699	8
9590	2056	1716	3
9591	2056	1717	6
9592	2056	1718	2
9593	2056	1719	1
9594	2056	1720	8
9595	2057	1691	3
9596	2057	1692	4
9597	2057	1693	4
9598	2057	1694	1
9599	2057	1695	2
9600	2058	1551	4
9601	2058	1721	2
9602	2058	1697	8
9603	2058	1722	1
9604	2058	1699	1
9605	2059	1723	3
9606	2059	1724	6
9607	2059	1701	8
9608	2059	1725	1
9609	2059	1704	7
9610	2060	1691	3
9611	2060	1692	5
9612	2060	1693	11
9613	2060	1694	6
9614	2060	1695	8
9615	2061	1709	5
9616	2061	1710	7
9617	2061	1707	7
9618	2061	1711	2
9619	2061	1712	7
9620	2062	1691	3
9621	2062	1692	6
9622	2062	1693	6
9623	2062	1694	1
9624	2062	1695	1
9625	2063	1709	5
9626	2063	1710	1
9627	2063	1707	4
9628	2063	1711	3
9629	2063	1712	1
9630	2064	1716	4
9631	2064	1717	3
9632	2064	1718	3
9633	2064	1719	3
9634	2064	1720	1
9635	2065	1726	4
9636	2065	1701	11
9637	2065	1702	6
9638	2065	1727	5
9639	2065	1704	8
9640	2066	1728	2
9641	2066	1729	5
9642	2066	1701	7
9643	2066	1704	5
9644	2066	1730	3
9645	2067	1658	1
9646	2067	1731	5
9647	2067	1732	1
9648	2067	1733	8
9649	2067	1533	4
9650	2068	1734	5
9651	2068	1735	6
9652	2068	1707	6
9653	2068	1736	2
9654	2068	1533	4
9655	2069	1737	6
9656	2069	1738	1
9657	2069	1739	2
9658	2069	1533	3
9659	2069	1740	3
9660	2070	1709	6
9661	2070	1710	8
9662	2070	1707	7
9663	2070	1711	3
9664	2070	1712	11
9665	2071	1709	6
9666	2071	1710	5
9667	2071	1707	7
9668	2071	1711	5
9669	2071	1712	7
9670	2072	1741	3
9671	2072	1686	2
9672	2072	1690	2
9673	2072	1742	5
9674	2072	1688	3
9675	2073	1716	4
9676	2073	1717	4
9677	2073	1718	1
9678	2073	1719	1
9679	2073	1720	7
9680	2074	1716	3
9681	2074	1717	5
9682	2074	1718	3
9683	2074	1719	2
9684	2074	1720	4
9685	2075	1743	7
9686	2075	1744	8
9687	2075	1698	4
9688	2075	1745	4
9689	2075	1699	8
9690	2076	1746	4
9691	2076	1686	3
9692	2076	1739	3
9693	2076	1747	8
9694	2076	1688	5
9695	2077	1709	5
9696	2077	1710	8
9697	2077	1707	4
9698	2077	1711	4
9699	2077	1712	9
9700	2078	1748	3
9701	2078	1729	5
9702	2078	1701	11
9703	2078	1749	6
9704	2078	1704	8
9705	2079	1750	5
9706	2079	1701	4
9707	2079	1613	7
9708	2079	1751	1
9709	2079	1704	4
9710	2080	1685	5
9711	2080	1686	1
9712	2080	1580	4
9713	2080	1752	1
9714	2080	1688	2
9715	2081	1753	5
9716	2081	1701	5
9717	2081	1702	2
9718	2081	1733	6
9719	2081	1704	5
9720	2082	1685	4
9721	2082	1686	4
9722	2082	1754	2
9723	2082	1755	2
9724	2082	1688	3
9725	2083	1756	3
9726	2083	1686	6
9727	2083	1732	7
9728	2083	1757	1
9729	2083	1688	3
9730	2084	1758	4
9731	2084	1701	11
9732	2084	1754	2
9733	2084	1759	5
9734	2084	1704	5
9735	2085	1760	6
9736	2085	1721	6
9737	2085	1761	9
9738	2085	1762	5
9739	2085	1699	9
9740	2086	1709	6
9741	2086	1710	8
9742	2086	1707	6
9743	2086	1711	5
9744	2086	1712	2
9745	2087	1709	6
9746	2087	1710	6
9747	2087	1707	4
9748	2087	1711	7
9749	2087	1712	1
9750	2088	1700	5
9751	2088	1701	7
9752	2088	1580	7
9753	2088	1749	5
9754	2088	1704	4
9755	2089	1743	7
9756	2089	1763	1
9757	2089	1714	4
9758	2089	1764	3
9759	2089	1704	5
9760	2090	1691	3
9761	2090	1692	4
9762	2090	1693	5
9763	2090	1694	1
9764	2090	1695	1
9765	2091	1709	5
9766	2091	1710	8
9767	2091	1707	8
9768	2091	1711	6
9769	2091	1712	5
9770	2092	1765	3
9771	2092	1766	3
9772	2092	1686	4
9773	2092	1732	2
9774	2092	1688	2
9775	2093	1716	4
9776	2093	1717	6
9777	2093	1718	3
9778	2093	1719	1
9779	2093	1720	1
9780	2094	1767	5
9781	2094	1768	7
9782	2094	1718	1
9783	2094	1769	5
9784	2094	1699	9
9785	2095	1691	4
9786	2095	1692	5
9787	2095	1693	2
9788	2095	1694	2
9789	2095	1695	3
9790	2096	1716	2
9791	2096	1717	4
9792	2096	1718	1
9793	2096	1719	1
9794	2096	1720	1
9795	2097	1696	5
9796	2097	1721	4
9797	2097	1697	9
9798	2097	1770	6
9799	2097	1699	5
9800	2098	1771	3
9801	2098	1721	7
9802	2098	1772	8
9803	2098	1651	2
9804	2098	1699	7
9805	2099	1691	2
9806	2099	1692	4
9807	2099	1693	5
9808	2099	1694	1
9809	2099	1695	1
9810	2100	1691	4
9811	2100	1692	5
9812	2100	1693	9
9813	2100	1694	2
9814	2100	1695	2
9815	2101	1691	3
9816	2101	1692	5
9817	2101	1693	6
9818	2101	1694	2
9819	2101	1695	3
9820	2102	1773	3
9821	2102	1686	2
9822	2102	1739	5
9823	2102	1774	1
9824	2102	1688	3
9825	2103	1709	7
9826	2103	1710	6
9827	2103	1707	7
9828	2103	1711	6
9829	2103	1712	6
9830	2104	1748	9
9831	2104	1701	6
9832	2104	1613	3
9833	2104	1747	9
9834	2104	1704	1
9835	2105	1737	5
9836	2105	1763	1
9837	2105	1707	1
9838	2105	1747	1
9839	2105	1704	1
9840	2106	1775	4
9841	2106	1701	1
9842	2106	1684	2
9843	2106	1776	1
9844	2106	1704	3
9845	2107	1728	3
9846	2107	1701	1
9847	2107	1702	4
9848	2107	1776	2
9849	2107	1704	1
9850	2108	1746	4
9851	2108	1777	4
9852	2108	1701	6
9853	2108	1684	3
9854	2108	1704	1
9855	2109	1775	4
9856	2109	1778	5
9857	2109	1686	4
9858	2109	1779	4
9859	2109	1688	5
9860	2110	1780	4
9861	2110	1731	9
9862	2110	1684	4
9863	2110	1781	5
9864	2110	1699	1
9865	2111	1782	5
9866	2111	1686	1
9867	2111	1613	2
9868	2111	1783	2
9869	2111	1688	3
9870	2112	1513	5
9871	2112	1784	6
9872	2112	1613	6
9873	2112	1785	5
9874	2112	1699	8
9875	2113	1716	3
9876	2113	1717	3
9877	2113	1718	1
9878	2113	1719	1
9879	2113	1720	1
9880	2114	1709	6
9881	2114	1710	6
9882	2114	1707	5
9883	2114	1711	3
9884	2114	1712	6
9885	2115	1786	8
9886	2115	1701	5
9887	2115	1702	2
9888	2115	1747	10
9889	2115	1704	6
9890	2116	1709	6
9891	2116	1710	9
9892	2116	1707	7
9893	2116	1711	2
9894	2116	1712	7
9895	2117	1709	6
9896	2117	1710	11
9897	2117	1707	8
9898	2117	1711	6
9899	2117	1712	7
9900	2118	1787	5
9901	2118	1692	3
9902	2118	1788	2
9903	2118	1789	1
9904	2118	1699	1
9905	2119	1691	3
9906	2119	1692	7
9907	2119	1693	9
9908	2119	1694	1
9909	2119	1695	4
9910	2120	1737	5
9911	2120	1686	3
9912	2120	1790	2
9913	2120	1688	4
9914	2120	1791	3
9915	2121	1792	3
9916	2121	1692	6
9917	2121	1693	3
9918	2121	1694	2
9919	2121	1695	2
9920	2122	1691	5
9921	2122	1692	4
9922	2122	1693	2
9923	2122	1694	1
9924	2122	1695	1
9925	2123	1691	4
9926	2123	1692	6
9927	2123	1693	8
9928	2123	1694	2
9929	2123	1695	4
9930	2124	1691	4
9931	2124	1692	7
9932	2124	1693	8
9933	2124	1694	2
9934	2124	1695	5
9935	2125	1748	5
9936	2125	1701	6
9937	2125	1718	1
9938	2125	1793	1
9939	2125	1704	5
9940	2126	1716	3
9941	2126	1717	9
9942	2126	1718	2
9943	2126	1719	1
9944	2126	1720	5
9945	2127	1766	6
9946	2127	1701	6
9947	2127	1794	6
9948	2127	1704	6
9949	2127	1543	8
9950	2128	1716	4
9951	2128	1717	6
9952	2128	1718	2
9953	2128	1719	2
9954	2128	1720	8
9955	2129	1691	5
9956	2129	1692	8
9957	2129	1693	8
9958	2129	1694	4
9959	2129	1695	1
9960	2130	1691	4
9961	2130	1692	8
9962	2130	1693	9
9963	2130	1694	3
9964	2130	1695	8
9965	2131	1716	3
9966	2131	1717	7
9967	2131	1718	3
9968	2131	1719	1
9969	2131	1720	3
9970	2132	1709	6
9971	2132	1710	7
9972	2132	1707	6
9973	2132	1711	3
9974	2132	1712	2
9975	2133	1696	4
9976	2133	1795	11
9977	2133	1707	6
9978	2133	1764	4
9979	2133	1699	1
9980	2134	1709	4
9981	2134	1710	9
9982	2134	1707	7
9983	2134	1711	6
9984	2134	1712	4
9985	2135	1716	5
9986	2135	1717	9
9987	2135	1718	4
9988	2135	1719	1
9989	2135	1720	9
9990	2136	1796	4
9991	2136	1797	5
9992	2136	1701	6
9993	2136	1798	1
9994	2136	1704	4
9995	2137	1723	4
9996	2137	1701	8
9997	2137	1718	3
9998	2137	1799	9
9999	2137	1704	6
10000	2138	1716	3
10001	2138	1717	9
10002	2138	1718	1
10003	2138	1719	3
10004	2138	1720	4
10005	2139	1691	3
10006	2139	1692	6
10007	2139	1693	7
10008	2139	1694	4
10009	2139	1695	5
10010	2140	1709	7
10011	2140	1710	9
10012	2140	1707	7
10013	2140	1711	6
10014	2140	1712	10
10015	2141	1800	5
10016	2141	1706	4
10017	2141	1745	2
10018	2141	1562	4
10019	2141	1549	2
10020	2142	1558	3
10021	2142	1554	6
10022	2142	1801	7
10023	2142	1562	5
10024	2142	1543	6
10025	2143	1582	1
10026	2143	1784	5
10027	2143	1714	5
10028	2143	1498	2
10029	2143	1562	1
10030	2144	1802	11
10031	2144	1803	10
10032	2144	1804	7
10033	2144	1805	11
10034	2144	1806	9
10035	2144	1807	1
10036	2145	1808	6
10037	2145	1809	4
10038	2145	1810	3
10039	2145	1811	2
10040	2145	1812	3
10041	2145	1813	14
10042	2145	1814	1
10043	2145	1815	11
10044	2146	1816	6
10045	2146	1812	3
10046	2146	1813	14
10047	2146	1804	5
10048	2146	1817	4
10049	2146	1805	2
10050	2146	1818	4
10051	2147	1819	4
10052	2147	1820	3
10053	2147	1812	4
10054	2147	1821	14
10055	2147	1822	9
10056	2148	1823	3
10057	2148	1824	5
10058	2148	1825	2
10059	2148	1826	7
10060	2148	1827	10
10061	2149	1828	7
10062	2149	1814	5
10063	2149	1829	7
10064	2149	1826	7
10065	2149	1830	9
10066	2150	1831	13
10067	2150	1832	4
10068	2150	1833	4
10069	2150	1834	7
10070	2150	1835	9
10071	2150	1836	3
10072	2151	1837	2
10073	2151	1838	7
10074	2151	1829	13
10075	2151	1839	7
10076	2151	1840	3
10077	2152	1841	8
10078	2152	1812	3
10079	2152	1813	14
10080	2152	1838	7
10081	2152	1817	1
10082	2152	1805	1
10083	2152	1818	7
10084	2153	1842	13
10085	2153	1843	8
10086	2153	1844	5
10087	2153	1829	13
10088	2153	1845	5
10089	2153	1846	2
10090	2153	1847	12
10091	2154	1848	9
10092	2154	1812	11
10093	2154	1849	14
10094	2154	1814	5
10095	2154	1826	8
10096	2155	1850	10
10097	2155	1851	6
10098	2155	1838	6
10099	2155	1814	6
10100	2155	1846	2
10101	2155	1817	7
10102	2155	1830	13
10103	2156	1852	7
10104	2156	1853	7
10105	2156	1812	4
10106	2156	1813	14
10107	2156	1804	6
10108	2156	1835	9
10109	2156	1854	8
10110	2157	1855	3
10111	2157	1856	4
10112	2157	1857	3
10113	2157	1812	11
10114	2157	1849	14
10115	2157	1833	7
10116	2157	1858	9
10117	2158	1859	4
10118	2158	1812	5
10119	2158	1821	14
10120	2158	1804	6
10121	2158	1860	4
10122	2158	1861	3
10123	2158	1834	4
10124	2159	1862	9
10125	2159	1863	5
10126	2159	1833	7
10127	2159	1864	7
10128	2159	1829	4
10129	2159	1865	4
10130	2160	1866	12
10131	2160	1867	11
10132	2160	1868	8
10133	2160	1869	9
10134	2160	1870	12
10135	2160	1854	5
10136	2161	1871	2
10137	2161	1872	2
10138	2161	1830	9
10139	2161	1873	6
10140	2161	1874	4
10141	2161	1875	2
10142	2162	1876	7
10143	2162	1877	11
10144	2162	1829	13
10145	2162	1861	13
10146	2162	1870	13
10147	2163	1878	1
10148	2163	1879	2
10149	2163	1880	5
10150	2163	1830	8
10151	2163	1874	3
10152	2164	1841	13
10153	2164	1881	4
10154	2164	1804	5
10155	2164	1882	5
10156	2164	1860	2
10157	2164	1861	7
10158	2165	1883	9
10159	2165	1884	7
10160	2165	1814	3
10161	2165	1817	4
10162	2165	1839	8
10163	2165	1818	7
10164	2166	1885	4
10165	2166	1833	3
10166	2166	1864	9
10167	2166	1829	6
10168	2167	1886	6
10169	2167	1887	9
10170	2167	1888	5
10171	2167	1832	7
10172	2167	1873	11
10173	2168	1889	8
10174	2168	1812	5
10175	2168	1890	14
10176	2168	1864	7
10177	2168	1817	5
10178	2168	1839	6
10179	2168	1891	8
10180	2169	1892	8
10181	2169	1893	7
10182	2169	1868	7
10183	2169	1894	9
10184	2169	1895	9
10185	2170	1896	11
10186	2170	1897	9
10187	2170	1898	3
10188	2170	1899	2
10189	2170	1858	9
10190	2171	1900	8
10191	2171	1901	6
10192	2171	1816	11
10193	2171	1832	8
10194	2171	1902	11
10195	2172	1903	3
10196	2172	1900	9
10197	2172	1904	6
10198	2172	1905	7
10199	2172	1906	3
10200	2172	1907	1
10201	2173	1908	4
10202	2173	1852	8
10203	2173	1909	3
10204	2173	1910	4
10205	2173	1873	5
10206	2173	1865	6
10207	2174	1911	3
10208	2174	1912	8
10209	2174	1913	11
10210	2174	1914	9
10211	2174	1873	7
10212	2174	1902	3
10213	2175	1915	9
10214	2175	1916	9
10215	2175	1917	6
10216	2175	1918	5
10217	2175	1865	11
10218	2176	1887	10
10219	2176	1919	11
10220	2176	1904	8
10221	2176	1920	4
10222	2176	1921	4
10223	2176	1922	11
10224	2177	1923	5
10225	2177	1897	7
10226	2177	1924	5
10227	2177	1922	9
10228	2177	1902	11
10229	2178	1925	10
10230	2178	1926	5
10231	2178	1832	8
10232	2178	1835	11
10233	2178	1854	8
10234	2179	1927	5
10235	2179	1928	11
10236	2179	1909	8
10237	2179	1835	7
10238	2179	1854	6
10239	2180	1915	9
10240	2180	1929	4
10241	2180	1930	2
10242	2180	1918	5
10243	2180	1865	9
10244	2181	1931	8
10245	2181	1932	6
10246	2181	1933	7
10247	2181	1832	5
10248	2181	1934	7
10249	2181	1865	8
10250	2182	1935	8
10251	2182	1936	9
10252	2182	1937	7
10253	2182	1938	7
10254	2182	1835	1
10255	2182	1865	4
10256	2183	1939	5
10257	2183	1940	3
10258	2183	1941	6
10259	2183	1916	8
10260	2183	1942	8
10261	2183	1902	8
10262	2184	1943	13
10263	2184	1944	9
10264	2184	1909	11
10265	2184	1835	7
10266	2184	1854	8
10267	2185	1945	7
10268	2185	1946	9
10269	2185	1887	9
10270	2185	1947	13
10271	2185	1948	8
10272	2185	1949	10
10273	2186	1950	3
10274	2186	1951	8
10275	2186	1952	8
10276	2186	1832	6
10277	2186	1873	7
10278	2186	1865	7
10279	2187	1953	7
10280	2187	1954	9
10281	2187	1832	7
10282	2187	1934	6
10283	2187	1865	11
10284	2188	1955	4
10285	2188	1956	9
10286	2188	1916	10
10287	2188	1957	5
10288	2188	1873	8
10289	2188	1854	6
10290	2189	1958	9
10291	2189	1959	11
10292	2189	1960	6
10293	2189	1840	4
10294	2190	1887	9
10295	2190	1961	11
10296	2190	1909	9
10297	2190	1962	4
10298	2190	1832	9
10299	2190	1873	7
10300	2191	1963	6
10301	2191	1915	10
10302	2191	1964	5
10303	2191	1957	6
10304	2191	1835	9
10305	2192	1887	10
10306	2192	1941	6
10307	2192	1897	11
10308	2192	1883	6
10309	2192	1954	10
10310	2192	1934	8
10311	2193	1965	8
10312	2193	1888	2
10313	2193	1966	4
10314	2193	1967	6
10315	2193	1854	5
10316	2194	1968	2
10317	2194	1969	4
10318	2194	1970	9
10319	2194	1971	7
10320	2195	1972	3
10321	2195	1973	9
10322	2195	1974	1
10323	2195	1922	11
10324	2195	1902	11
10325	2196	1975	5
10326	2196	1900	13
10327	2196	1901	8
10328	2196	1976	3
10329	2196	1934	9
10330	2196	1902	11
10331	2197	1887	9
10332	2197	1977	9
10333	2197	1978	8
10334	2197	1979	6
10335	2197	1922	11
10336	2198	1980	3
10337	2198	1981	5
10338	2198	1953	9
10339	2198	1982	9
10340	2198	1934	11
10341	2198	1902	11
10342	2199	1983	6
10343	2199	1944	9
10344	2199	1984	6
10345	2199	1883	11
10346	2199	1934	9
10347	2200	1985	2
10348	2200	1986	4
10349	2200	1913	13
10350	2200	1987	9
10351	2200	1835	9
10352	2200	1854	6
10353	2201	1973	8
10354	2201	1914	6
10355	2201	1905	4
10356	2201	1988	2
10357	2201	1895	7
10358	2201	1865	6
10359	2202	1989	5
10360	2202	1990	10
10361	2202	1991	11
10362	2202	1992	7
10363	2202	1873	9
10364	2202	1854	7
10365	2203	1993	3
10366	2203	1994	7
10367	2203	1992	5
10368	2203	1918	4
10369	2203	1865	8
10370	2204	1956	9
10371	2204	1992	9
10372	2204	1995	3
10373	2204	1832	8
10374	2204	1934	9
10375	2204	1865	11
10376	2205	1996	4
10377	2205	1961	9
10378	2205	1938	7
10379	2205	1853	6
10380	2205	1934	9
10381	2205	1902	11
10382	2206	1997	8
10383	2206	1829	3
10384	2206	1834	9
10385	2206	1839	9
10386	2206	1836	2
10387	2206	1902	11
10388	2207	1998	6
10389	2207	1999	6
10390	2207	2000	9
10391	2207	2001	4
10392	2207	1922	6
10393	2207	1854	6
10394	2208	2002	5
10395	2208	2003	9
10396	2208	1997	8
10397	2208	2004	4
10398	2208	1873	8
10399	2208	1902	11
10400	2209	1999	6
10401	2209	1897	11
10402	2209	2005	10
10403	2209	2001	4
10404	2209	1934	11
10405	2209	1854	6
10406	2210	2006	4
10407	2210	2007	3
10408	2210	1867	8
10409	2210	2008	7
10410	2210	1971	5
10411	2210	1902	7
10412	2211	1953	2
10413	2211	1877	4
10414	2211	1832	1
10415	2211	1873	2
10416	2211	2009	3
10417	2212	2010	6
10418	2212	1852	7
10419	2212	1917	8
10420	2212	2011	11
10421	2212	1835	11
10422	2212	1854	14
10423	2213	1964	8
10424	2213	2012	1
10425	2213	2013	3
10426	2213	1934	7
10427	2213	1854	7
10428	2214	2014	6
10429	2214	2015	4
10430	2214	1925	6
10431	2214	2016	5
10432	2214	2017	7
10433	2214	2018	5
10434	2215	2019	9
10435	2215	2020	7
10436	2215	2021	7
10437	2215	1922	9
10438	2215	1865	8
10439	2216	1945	9
10440	2216	1961	4
10441	2216	1938	11
10442	2216	1922	9
10443	2216	1902	8
10444	2217	2022	2
10445	2217	1945	2
10446	2217	1868	6
10447	2217	1934	11
10448	2217	1854	6
10449	2218	2023	4
10450	2218	2024	4
10451	2218	2025	5
10452	2218	2026	1
10453	2218	2027	1
10454	2219	2028	3
10455	2219	2029	5
10456	2219	1853	8
10457	2219	2030	1
10458	2219	2031	7
10459	2220	2032	3
10460	2220	2033	5
10461	2220	2034	7
10462	2220	2035	1
10463	2220	1918	6
10464	2221	2036	6
10465	2221	2037	7
10466	2221	2038	4
10467	2221	1858	8
10468	2221	2009	4
10469	2222	1859	4
10470	2222	2039	9
10471	2222	2040	5
10472	2222	2041	1
10473	2222	1858	12
10474	2223	2023	5
10475	2223	2042	4
10476	2223	2043	3
10477	2223	2029	7
10478	2223	2044	4
10479	2223	1858	3
10480	2224	2045	4
10481	2224	2037	5
10482	2224	2046	3
10483	2224	2047	4
10484	2224	2048	6
10485	2225	2049	6
10486	2225	2050	5
10487	2225	2037	8
10488	2225	1995	2
10489	2225	1858	7
10490	2226	2051	3
10491	2226	2039	9
10492	2226	2052	6
10493	2226	2053	2
10494	2226	1942	7
10495	2227	2054	3
10496	2227	1989	3
10497	2227	2034	5
10498	2227	2035	1
10499	2227	2027	2
10500	2228	2055	3
10501	2228	2056	3
10502	2228	2029	9
10503	2228	2057	3
10504	2228	1858	2
10505	2229	1809	2
10506	2229	2058	9
10507	2229	1853	5
10508	2229	2059	4
10509	2229	1942	5
10510	2230	2060	7
10511	2230	2061	4
10512	2230	2062	8
10513	2230	1988	3
10514	2230	2027	13
10515	2231	2045	3
10516	2231	2063	7
10517	2231	2046	4
10518	2231	2064	1
10519	2231	1907	4
10520	2232	2065	4
10521	2232	2034	7
10522	2232	2066	6
10523	2232	2035	1
10524	2232	2027	3
10525	2233	2067	2
10526	2233	2068	4
10527	2233	2063	4
10528	2233	2041	1
10529	2233	1907	2
10530	2234	2010	1
10531	2234	2069	7
10532	2234	1883	7
10533	2234	2013	3
10534	2234	1942	1
10535	2235	2070	4
10536	2235	2071	8
10537	2235	2052	11
10538	2235	2072	4
10539	2235	2031	8
10540	2236	2022	2
10541	2236	2073	3
10542	2236	2074	11
10543	2236	2075	1
10544	2236	2076	2
10545	2236	1918	6
10546	2237	2077	3
10547	2237	2078	4
10548	2237	1816	4
10549	2237	2079	2
10550	2237	2031	6
10551	2238	2080	3
10552	2238	2081	6
10553	2238	2082	9
10554	2238	2083	1
10555	2238	1907	1
10556	2239	2051	2
10557	2239	2084	2
10558	2239	2029	5
10559	2239	2027	1
10560	2239	2085	2
10561	2240	2086	5
10562	2240	2015	7
10563	2240	2087	9
10564	2240	2088	3
10565	2240	2048	2
10566	2241	2089	3
10567	2241	2068	6
10568	2241	2090	8
10569	2241	2026	3
10570	2241	1895	5
10571	2242	2091	4
10572	2242	2092	3
10573	2242	2052	6
10574	2242	2093	5
10575	2242	1918	3
10576	2243	2094	4
10577	2243	2095	3
10578	2243	1970	7
10579	2243	2053	2
10580	2243	1942	11
10581	2244	2095	3
10582	2244	2096	4
10583	2244	2052	5
10584	2244	1883	7
10585	2244	1942	4
10586	2245	2097	5
10587	2245	2043	6
10588	2245	2090	8
10589	2245	2098	2
10590	2245	1942	7
10591	2246	2045	3
10592	2246	2099	7
10593	2246	2029	9
10594	2246	2072	2
10595	2246	2031	3
10596	2247	2045	3
10597	2247	2063	6
10598	2247	2046	4
10599	2247	2059	4
10600	2247	1907	3
10601	2248	2022	2
10602	2248	2100	3
10603	2248	2101	9
10604	2248	2102	4
10605	2248	1918	8
10606	2249	2103	3
10607	2249	1958	9
10608	2249	2104	4
10609	2249	2013	4
10610	2249	1942	9
10611	2250	2063	6
10612	2250	2105	4
10613	2250	2106	2
10614	2250	2026	6
10615	2250	1942	3
10616	2251	1931	4
10617	2251	2039	8
10618	2251	2066	3
10619	2251	2107	3
10620	2251	2027	1
10621	2252	2108	3
10622	2252	2025	6
10623	2252	2106	1
10624	2252	2109	4
10625	2252	2031	4
10626	2253	2110	12
10627	2253	2025	10
10628	2253	2066	8
10629	2253	2111	6
10630	2253	2031	8
10631	2254	2084	4
10632	2254	2071	7
10633	2254	2112	1
10634	2254	2113	3
10635	2254	2031	7
10636	2255	2045	4
10637	2255	2114	9
10638	2255	2115	2
10639	2255	2041	1
10640	2255	1858	8
10641	2256	2089	4
10642	2256	2068	6
10643	2256	2090	9
10644	2256	2026	1
10645	2256	1895	2
10646	2257	2045	3
10647	2257	1933	8
10648	2257	2046	3
10649	2257	2064	1
10650	2257	1907	1
10651	2258	1859	3
10652	2258	2116	4
10653	2258	2039	10
10654	2258	2117	4
10655	2258	1858	5
10656	2259	2014	5
10657	2259	2096	3
10658	2259	1816	3
10659	2259	2118	4
10660	2259	1907	3
10661	2260	2054	3
10662	2260	2034	9
10663	2260	2066	3
10664	2260	2035	1
10665	2260	2027	2
10666	2261	2089	3
10667	2261	2019	6
10668	2261	2063	8
10669	2261	2001	4
10670	2261	1895	5
10671	2262	2119	4
10672	2262	2120	7
10673	2262	2121	9
10674	2262	2122	4
10675	2262	1942	4
10676	2263	2123	4
10677	2263	2039	8
10678	2263	1883	6
10679	2263	2026	1
10680	2263	1942	1
10681	2264	2039	9
10682	2264	2106	3
10683	2264	2118	2
10684	2264	2035	4
10685	2264	1858	6
10686	2265	2042	3
10687	2265	2034	8
10688	2265	2124	1
10689	2265	1881	3
10690	2265	2027	8
10691	2266	1940	2
10692	2266	1970	6
10693	2266	2125	1
10694	2266	2118	9
10695	2266	1895	1
10696	2267	2049	6
10697	2267	1886	2
10698	2267	2037	8
10699	2267	2066	6
10700	2267	2126	3
10701	2267	1858	5
10702	2268	2049	5
10703	2268	2037	7
10704	2268	2066	9
10705	2268	2038	6
10706	2268	1858	8
10707	2269	2127	2
10708	2269	2114	5
10709	2269	2041	1
10710	2269	2031	1
10711	2269	2128	6
10712	2270	2054	4
10713	2270	2034	11
10714	2270	2066	8
10715	2270	2079	1
10716	2270	2027	7
10717	2271	2065	3
10718	2271	1989	2
10719	2271	2034	11
10720	2271	2035	1
10721	2271	2027	4
10722	2272	2129	1
10723	2272	2099	3
10724	2272	2130	9
10725	2272	2117	1
10726	2272	2031	7
10727	2273	2129	4
10728	2273	2099	4
10729	2273	2130	8
10730	2273	2131	3
10731	2273	2027	9
10732	2274	2132	2
10733	2274	2007	9
10734	2274	2090	8
10735	2274	2083	2
10736	2274	1858	5
10737	2275	2133	3
10738	2275	2029	2
10739	2275	1895	1
10740	2275	2128	4
10741	2275	1875	1
10742	2276	2123	2
10743	2276	2084	3
10744	2276	2039	4
10745	2276	2134	1
10746	2276	2031	1
10747	2277	2135	5
10748	2277	2039	2
10749	2277	2136	9
10750	2277	2027	1
10751	2277	1836	1
10752	2278	2137	4
10753	2278	2138	7
10754	2278	2007	8
10755	2278	2039	9
10756	2278	2031	5
10757	2279	2108	3
10758	2279	2130	9
10759	2279	1917	6
10760	2279	2111	4
10761	2279	2031	6
10762	2280	2139	5
10763	2280	1951	5
10764	2280	2029	7
10765	2280	2026	2
10766	2280	1858	2
10767	2281	2100	3
10768	2281	2140	2
10769	2281	2141	4
10770	2281	2142	2
10771	2281	2031	2
10772	2282	2143	5
10773	2282	2037	7
10774	2282	1917	6
10775	2282	2059	7
10776	2282	1858	12
10777	2283	2144	5
10778	2283	1970	4
10779	2283	1883	6
10780	2283	2026	1
10781	2283	1942	1
10782	2284	2045	4
10783	2284	2063	6
10784	2284	2046	3
10785	2284	2064	1
10786	2284	1907	5
10787	2285	2145	4
10788	2285	2039	8
10789	2285	2076	2
10790	2285	2001	1
10791	2285	2031	7
10792	2286	2146	3
10793	2286	2045	3
10794	2286	2063	7
10795	2286	2064	1
10796	2286	1907	3
10797	2287	2089	5
10798	2287	2068	6
10799	2287	2147	9
10800	2287	2026	1
10801	2287	1895	6
10802	2288	2056	4
10803	2288	2029	2
10804	2288	1853	2
10805	2288	1858	1
10806	2288	2148	2
10807	2289	2149	4
10808	2289	2150	3
10809	2289	2034	11
10810	2289	2035	1
10811	2289	1918	6
10812	2290	2151	5
10813	2290	2029	8
10814	2290	1853	6
10815	2290	1905	5
10816	2290	1942	5
10817	2291	2054	5
10818	2291	2034	11
10819	2291	2079	1
10820	2291	2027	4
10821	2291	1840	2
10822	2292	2054	5
10823	2292	2034	2
10824	2292	2066	4
10825	2292	2079	1
10826	2292	2027	1
10827	2293	2054	4
10828	2293	2034	8
10829	2293	2066	6
10830	2293	2035	2
10831	2293	2027	6
10832	2294	2065	4
10833	2294	2034	11
10834	2294	2066	7
10835	2294	2079	2
10836	2294	2027	4
10837	2295	2152	3
10838	2295	2153	2
10839	2295	2039	7
10840	2295	2154	4
10841	2295	2155	4
10842	2295	2031	2
10843	2296	2144	7
10844	2296	1990	8
10845	2296	1933	9
10846	2296	2026	4
10847	2296	1942	3
10848	2297	2143	5
10849	2297	2156	8
10850	2297	1853	6
10851	2297	2059	5
10852	2297	1942	8
10853	2298	2010	1
10854	2298	1970	11
10855	2298	1883	8
10856	2298	2157	9
10857	2298	1895	9
10858	2299	2054	6
10859	2299	2034	11
10860	2299	2079	2
10861	2299	2027	3
10862	2299	1840	4
10863	2300	2158	6
10864	2300	2034	13
10865	2300	1926	4
10866	2300	2159	5
10867	2300	1895	9
10868	2301	2010	1
10869	2301	1933	7
10870	2301	1883	8
10871	2301	2160	2
10872	2301	1942	5
10873	2302	2161	5
10874	2302	2063	6
10875	2302	2046	6
10876	2302	2059	4
10877	2302	1907	1
10878	2303	2127	2
10879	2303	2162	7
10880	2303	2163	2
10881	2303	2117	2
10882	2303	1858	3
10883	2304	2022	4
10884	2304	2068	5
10885	2304	2063	8
10886	2304	2026	3
10887	2304	1907	2
10888	2305	2010	3
10889	2305	1970	13
10890	2305	2157	8
10891	2305	1949	7
10892	2305	1942	7
10893	2306	2164	2
10894	2306	2039	8
10895	2306	2165	3
10896	2306	2031	2
10897	2306	1875	1
10898	2307	2166	5
10899	2307	2167	3
10900	2307	2090	11
10901	2307	2026	4
10902	2307	2031	11
10903	2308	2089	3
10904	2308	2096	8
10905	2308	2066	7
10906	2308	2168	4
10907	2308	1942	6
10908	2309	2032	3
10909	2309	2054	4
10910	2309	2034	11
10911	2309	2035	1
10912	2309	2027	5
10913	2310	2067	3
10914	2310	2068	6
10915	2310	2063	9
10916	2310	2041	1
10917	2310	2048	5
10918	2311	2084	5
10919	2311	2034	9
10920	2311	2169	3
10921	2311	1880	5
10922	2311	1895	4
10923	2312	2084	8
10924	2312	2114	8
10925	2312	2169	11
10926	2312	2170	4
10927	2312	1895	6
10928	2313	2171	1
10929	2313	2114	7
10930	2313	1957	1
10931	2313	1895	1
10932	2313	1836	1
10933	2314	2172	6
10934	2314	2173	5
10935	2314	2174	3
10936	2315	2175	5
10937	2316	2176	3
10938	2317	2177	4
10939	2317	2178	5
10940	2318	2176	11
10941	2319	2179	13
10942	2319	2180	4
10943	2320	2176	3
10944	2321	2176	1
10945	2322	2176	3
10946	2323	2181	3
10947	2323	2182	11
10948	2324	2172	4
10949	2324	2183	7
10950	2325	2184	7
10951	2325	2185	8
10952	2326	2186	4
10953	2327	2187	3
10954	2327	2188	11
10955	2328	2189	7
10956	2328	2174	3
10957	2329	2174	2
10958	2329	2190	13
10959	2330	2191	8
10960	2331	2192	2
10961	2331	2193	4
10962	2332	2194	5
10963	2332	2190	5
10964	2333	2195	11
10965	2333	2196	10
10966	2334	2197	7
10967	2334	2188	9
10968	2335	2190	11
10969	2336	2198	7
10970	2337	2190	4
10971	2338	2195	2
10972	2338	2188	9
10973	2339	2199	8
10974	2340	2200	8
10975	2341	2201	6
10976	2341	2186	4
10977	2342	2185	3
10978	2343	2202	5
10979	2343	2203	1
10980	2344	2204	11
10981	2344	2190	2
10982	2345	2204	3
10983	2346	2192	5
10984	2346	2204	3
10985	2347	2205	9
10986	2347	2178	5
10987	2348	2202	7
10988	2348	2200	8
10989	2349	2206	4
10990	2349	2204	5
10991	2350	2207	3
10992	2350	2193	3
10993	2351	2188	8
10994	2352	2200	4
10995	2352	2204	11
10996	2353	2190	11
10997	2354	2208	4
10998	2355	2204	11
10999	2355	2190	5
11000	2356	2186	2
11001	2356	2198	4
11002	2357	2186	5
11003	2357	2191	1
11004	2358	2209	5
11005	2359	2210	8
11006	2360	2211	8
11007	2360	2212	4
11008	2361	2213	7
11009	2362	2214	2
11010	2363	2191	6
11011	2364	2215	6
11012	2365	2216	5
11013	2366	2217	4
11014	2366	2218	2
11015	2367	2197	1
11016	2368	2219	4
11017	2369	2219	7
11018	2370	2220	3
11019	2370	2221	5
11020	2371	2222	1
11021	2371	2178	3
11022	2372	2223	1
11023	2373	2224	11
11024	2374	2204	11
11025	2374	2190	4
11026	2375	2225	5
11027	2376	2213	3
11028	2377	2226	2
11029	2378	2215	5
11030	2379	2204	2
11031	2379	2190	1
11032	2380	2227	8
11033	2381	2228	1
11034	2382	2226	1
11035	2383	2229	1
11036	2384	2198	9
11037	2385	2230	1
11038	2385	2231	3
11039	2386	2216	3
11040	2387	2191	8
11041	2388	2197	5
11042	2389	2229	2
11043	2390	2225	5
11044	2391	2232	5
11045	2392	2204	1
11046	2392	2190	1
11047	2393	2233	6
11048	2394	2232	1
11049	2395	2227	7
11050	2396	2216	4
11051	2397	2226	7
11052	2397	2234	2
11053	2398	2224	5
11054	2399	2233	5
11055	2400	2235	2
11056	2400	2236	3
11057	2401	2237	2
11058	2402	2197	5
11059	2403	2224	11
11060	2404	2191	9
11061	2405	2238	11
11062	2406	2219	4
11063	2407	2228	3
11064	2408	2239	9
11065	2409	2219	1
11066	2410	2240	6
11067	2411	2241	11
11068	2411	2242	5
11069	2411	2243	11
11070	2411	2244	6
11071	2411	2245	11
11072	2412	2246	14
11073	2412	2247	14
11074	2412	2248	7
11075	2412	2249	4
11076	2412	2245	10
11077	2413	2250	3
11078	2414	2248	6
11079	2414	2251	11
11080	2414	2252	5
11081	2414	2253	4
11082	2414	2254	13
11083	2415	2252	4
11084	2415	2250	3
11085	2415	2255	14
11086	2415	2256	6
11087	2415	2245	9
11088	2416	2257	4
11089	2416	2258	2
11090	2416	2241	11
11091	2416	2259	5
11092	2416	2260	4
11093	2416	2253	3
11094	2417	2261	11
11095	2417	2262	14
11096	2417	2263	9
11097	2417	2264	8
11098	2417	2265	8
11099	2417	2259	11
11100	2417	2266	9
11101	2418	2261	5
11102	2418	2267	14
11103	2418	2251	11
11104	2418	2268	8
11105	2418	2269	7
11106	2419	2248	6
11107	2419	2251	11
11108	2419	2252	6
11109	2419	2249	3
11110	2419	2270	9
11111	2419	2253	4
11112	2420	2271	14
11113	2420	2272	11
11114	2421	2273	7
11115	2421	2274	8
11116	2421	2253	3
11117	2421	2245	11
11118	2422	2271	14
11119	2422	2272	11
11120	2422	2275	11
11121	2422	2276	3
11122	2422	2260	6
11123	2422	2277	1
11124	2422	2278	9
11125	2423	2279	2
11126	2423	2280	7
11127	2423	2248	8
11128	2423	2268	8
11129	2423	2265	2
11130	2423	2281	7
11131	2424	2282	5
11132	2424	2283	2
11133	2424	2284	10
11134	2424	2285	3
11135	2424	2286	13
11136	2424	2254	8
11137	2425	2287	9
11138	2425	2288	6
11139	2425	2259	6
11140	2425	2289	5
11141	2425	2250	7
11142	2425	2290	11
11143	2426	2263	3
11144	2426	2251	8
11145	2426	2291	6
11146	2426	2242	4
11147	2426	2252	8
11148	2426	2249	1
11149	2427	2292	3
11150	2427	2261	11
11151	2427	2262	14
11152	2427	2264	8
11153	2427	2243	11
11154	2427	2254	11
11155	2428	2263	7
11156	2428	2264	9
11157	2428	2281	6
11158	2428	2289	4
11159	2428	2245	9
11160	2429	2293	11
11161	2429	2294	2
11162	2429	2271	14
11163	2429	2272	11
11164	2429	2286	6
11165	2429	2244	12
11166	2429	2254	8
11167	2430	2263	6
11168	2430	2268	11
11169	2430	2281	6
11170	2430	2289	6
11171	2430	2254	9
11172	2431	2295	14
11173	2431	2272	5
11174	2431	2263	5
11175	2431	2251	2
11176	2431	2252	6
11177	2431	2289	13
11178	2431	2250	7
11179	2432	2261	11
11180	2432	2267	14
11181	2432	2248	9
11182	2432	2275	11
11183	2432	2252	8
11184	2432	2289	4
11185	2432	2296	2
11186	2432	2278	6
11187	2433	2263	5
11188	2433	2251	3
11189	2433	2291	6
11190	2433	2242	4
11191	2433	2252	2
11192	2433	2249	5
11193	2433	2289	5
11194	2434	2297	5
11195	2434	2298	11
11196	2434	2299	8
11197	2434	2289	13
11198	2434	2244	5
11199	2434	2245	11
11200	2435	2300	6
11201	2435	2287	11
11202	2435	2286	9
11203	2435	2243	8
11204	2435	2270	9
11205	2435	2301	3
11206	2436	2302	9
11207	2436	2303	3
11208	2436	2304	2
11209	2436	2260	2
11210	2437	2305	4
11211	2437	2306	9
11212	2437	2307	8
11213	2437	2308	4
11214	2437	2304	7
11215	2437	2309	9
11216	2438	2310	4
11217	2438	2311	9
11218	2438	2312	7
11219	2438	2309	12
11220	2438	2313	5
11221	2438	2245	8
11222	2439	2314	6
11223	2439	2315	5
11224	2439	2316	3
11225	2439	2285	5
11226	2439	2309	6
11227	2439	2254	8
11228	2440	2317	8
11229	2440	2318	9
11230	2440	2319	9
11231	2440	2309	9
11232	2441	2320	4
11233	2441	2264	2
11234	2441	2281	2
11235	2441	2243	5
11236	2441	2289	3
11237	2441	2321	2
11238	2442	2322	4
11239	2442	2323	5
11240	2442	2264	11
11241	2442	2324	8
11242	2443	941	6
11243	2443	942	7
11244	2443	943	7
11245	2443	944	6
11246	2443	99	4
11247	2443	100	3
11248	2443	945	1
11249	2444	102	4
11250	2444	946	5
11251	2444	947	6
11252	2444	948	4
11253	2444	106	3
11254	2445	949	10
11255	2445	950	11
11256	2445	951	9
11257	2445	110	8
11258	2445	111	11
11259	2446	952	3
11260	2446	953	9
11261	2447	114	7
11262	2447	954	9
11263	2447	955	13
11264	2447	117	10
11265	2447	118	6
11266	2448	956	13
11267	2448	957	9
11268	2448	121	11
11269	2448	122	11
11270	2448	123	9
11271	2448	958	11
11272	2449	125	6
11273	2449	126	5
11274	2450	127	9
11275	2450	128	6
11276	2450	129	11
11277	2450	959	9
11278	2450	960	5
11279	2451	132	6
11280	2451	961	9
11281	2451	962	6
11282	2451	135	8
11283	2451	136	3
11284	2452	137	7
11285	2452	963	6
11286	2452	964	5
11287	2452	140	6
11288	2452	141	6
11289	2453	142	9
11290	2453	143	8
11291	2453	144	10
11292	2454	145	5
11293	2454	965	9
11294	2454	966	7
11295	2454	967	7
11296	2454	149	11
11297	2455	150	7
11298	2455	968	9
11299	2455	969	3
11300	2455	153	6
11301	2455	154	9
11302	2456	970	14
11303	2456	157	9
11304	2456	158	10
11305	2456	159	5
11306	2456	971	14
11307	2457	972	7
11308	2457	162	14
11309	2457	973	9
11310	2457	974	14
11311	2457	975	5
11312	2457	166	5
11313	2458	167	9
11314	2458	976	8
11315	2458	977	9
11316	2458	978	4
11317	2458	171	7
11318	2459	172	12
11319	2459	979	7
11320	2459	174	5
11321	2459	175	9
11322	2459	980	14
11323	2460	177	14
11324	2460	981	9
11325	2460	179	6
11326	2460	982	6
11327	2460	181	12
11328	2461	182	12
11329	2462	183	5
11330	2462	184	4
11331	2462	983	13
11332	2462	984	4
11333	2462	187	9
11334	2462	188	9
11335	2463	985	11
11336	2463	986	9
11337	2463	987	11
11338	2463	988	11
11339	2463	193	11
11340	2464	194	13
11341	2464	989	9
11342	2464	196	9
11343	2464	990	9
11344	2464	198	5
11345	2465	991	9
11346	2465	992	6
11347	2465	993	4
11348	2465	994	2
11349	2465	203	2
11350	2466	995	6
11351	2467	996	8
11352	2468	206	5
11353	2468	997	5
11354	2469	998	10
11355	2470	209	4
11356	2470	999	9
11357	2470	211	8
11358	2470	212	11
11359	2470	213	8
11360	2470	1000	9
11361	2471	215	9
11362	2471	216	4
11363	2471	1001	9
11364	2471	1002	11
11365	2471	219	9
11366	2471	213	11
11367	2472	220	12
11368	2472	1003	7
11369	2472	1004	11
11370	2472	1005	13
11371	2472	224	6
11372	2473	225	12
11373	2473	1006	6
11374	2473	1007	7
11375	2473	228	7
11376	2473	229	7
11377	2474	230	4
11378	2474	1008	7
11379	2474	232	1
11380	2474	1009	4
11381	2474	234	1
11382	2475	1010	7
11383	2475	1011	4
11384	2475	237	8
11385	2475	238	1
11386	2475	239	7
11387	2475	240	9
11388	2476	241	12
11389	2476	242	4
11390	2476	1012	5
11391	2476	237	11
11392	2476	239	8
11393	2476	240	9
11394	2477	244	11
11395	2477	245	11
11396	2477	1013	11
11397	2477	1014	11
11398	2477	1015	9
11399	2477	249	11
11400	2478	250	5
11401	2478	1016	11
11402	2478	1017	11
11403	2478	1018	9
11404	2478	249	11
11405	2479	254	9
11406	2479	1019	6
11407	2479	1020	13
11408	2479	1021	5
11409	2479	258	2
11410	2480	259	4
11411	2480	1022	7
11412	2481	261	2
11413	2481	1023	4
11414	2482	1024	14
11415	2483	1025	6
11416	2484	1026	13
11417	2485	1027	6
11418	2485	267	9
11419	2485	268	9
11420	2485	1028	6
11421	2485	270	2
11422	2485	271	5
11423	2485	272	6
11424	2486	1029	11
11425	2486	274	5
11426	2486	268	5
11427	2486	275	6
11428	2486	276	6
11429	2486	1030	9
11430	2487	1031	6
11431	2487	279	5
11432	2487	1032	11
11433	2487	1033	11
11434	2487	1034	3
11435	2487	283	9
11436	2488	284	8
11437	2488	1035	11
11438	2488	1036	6
11439	2488	287	12
11440	2488	283	9
11441	2488	1030	7
11442	2489	288	4
11443	2489	1037	8
11444	2489	1038	7
11445	2489	287	1
11446	2489	291	7
11447	2490	292	7
11448	2490	293	5
11449	2490	1039	4
11450	2490	1040	3
11451	2490	296	4
11452	2491	297	6
11453	2491	298	4
11454	2491	1041	4
11455	2491	1042	8
11456	2491	301	2
11457	2492	302	3
11458	2492	1043	14
11459	2492	1044	9
11460	2492	305	9
11461	2492	306	12
11462	2492	307	7
11463	2492	308	2
11464	2493	309	8
11465	2493	310	5
11466	2493	1045	9
11467	2493	306	6
11468	2493	312	6
11469	2493	313	2
11470	2493	314	3
11471	2494	1046	6
11472	2494	1047	5
11473	2494	317	5
11474	2494	1048	10
11475	2494	1049	8
11476	2494	1050	7
11477	2495	321	12
11478	2495	1051	10
11479	2495	1052	4
11480	2495	1053	9
11481	2495	1054	6
11482	2495	326	5
11483	2496	327	13
11484	2496	1055	11
11485	2496	329	9
11486	2496	1056	6
11487	2496	331	4
11488	2497	309	8
11489	2497	1057	7
11490	2497	1058	5
11491	2497	1059	4
11492	2497	335	1
11493	2498	1060	1
11494	2498	337	2
11495	2499	1061	5
11496	2500	1062	6
11497	2501	340	3
11498	2501	1063	6
11499	2502	1064	14
11500	2502	1065	8
11501	2502	344	10
11502	2502	345	6
11503	2503	1066	2
11504	2503	1067	3
11505	2503	1064	5
11506	2503	1068	5
11507	2503	349	5
11508	2503	350	6
11509	2503	351	1
11510	2504	352	11
11511	2504	1069	11
11512	2504	1070	8
11513	2504	1071	13
11514	2504	356	9
11515	2505	357	4
11516	2505	1072	8
11517	2505	359	6
11518	2505	360	9
11519	2505	361	3
11520	2506	362	5
11521	2506	363	5
11522	2506	1073	9
11523	2506	1074	2
11524	2506	366	5
11525	2507	367	3
11526	2507	1075	11
11527	2507	369	2
11528	2507	1076	3
11529	2507	371	5
11530	2508	372	2
11531	2508	1077	8
11532	2508	374	1
11533	2508	1078	3
11534	2508	371	6
11535	2509	367	4
11536	2509	1077	9
11537	2509	376	1
11538	2509	1079	7
11539	2509	378	7
11540	2510	379	5
11541	2510	1080	10
11542	2510	1081	5
11543	2510	1082	5
11544	2510	378	1
11545	2511	383	7
11546	2511	1083	9
11547	2511	385	6
11548	2511	1084	3
11549	2511	387	2
11550	2512	1085	14
11551	2512	1086	14
11552	2512	390	9
11553	2513	391	4
11554	2513	392	7
11555	2513	1087	8
11556	2513	394	4
11557	2513	395	12
11558	2514	1088	2
11559	2514	1085	14
11560	2514	1089	8
11561	2514	398	1
11562	2514	399	2
11563	2514	400	4
11564	2514	401	1
11565	2515	402	13
11566	2515	1090	9
11567	2515	1091	11
11568	2515	1092	9
11569	2515	406	9
11570	2516	1093	8
11571	2516	408	6
11572	2516	1094	9
11573	2516	1095	3
11574	2516	398	6
11575	2516	411	5
11576	2517	412	6
11577	2517	1096	11
11578	2517	1097	4
11579	2517	1098	4
11580	2517	416	6
11581	2518	417	8
11582	2518	418	4
11583	2518	1099	8
11584	2518	1100	5
11585	2518	421	8
11586	2519	422	5
11587	2519	423	3
11588	2519	424	3
11589	2519	1101	9
11590	2519	426	4
11591	2520	427	3
11592	2520	1102	9
11593	2520	1103	6
11594	2520	1104	4
11595	2520	426	5
11596	2521	431	5
11597	2521	1105	5
11598	2521	1106	4
11599	2521	1107	7
11600	2521	421	2
11601	2522	1108	9
11602	2522	1109	3
11603	2522	1110	2
11604	2522	1104	4
11605	2522	426	3
11606	2523	438	14
11607	2524	1111	9
11608	2525	1112	4
11609	2526	1113	9
11610	2527	1114	8
11611	2528	1115	7
11612	2529	1116	8
11613	2530	445	2
11614	2530	1117	4
11615	2531	1118	14
11616	2531	1119	4
11617	2531	449	7
11618	2531	450	11
11619	2531	451	8
11620	2531	452	12
11621	2531	453	11
11622	2531	454	1
11623	2532	455	8
11624	2532	456	11
11625	2532	451	8
11626	2532	457	12
11627	2532	458	2
11628	2532	459	5
11629	2532	460	14
11630	2532	1120	4
11631	2533	1121	9
11632	2533	1122	9
11633	2533	1118	14
11634	2533	1119	5
11635	2533	464	9
11636	2533	452	8
11637	2533	453	7
11638	2534	1118	14
11639	2534	1119	3
11640	2534	465	2
11641	2534	450	9
11642	2534	466	9
11643	2534	467	9
11644	2534	1120	8
11645	2535	468	3
11646	2535	1123	7
11647	2535	1124	11
11648	2535	471	7
11649	2536	1125	7
11650	2536	1126	7
11651	2536	1127	1
11652	2536	1128	2
11653	2536	476	7
11654	2537	477	5
11655	2537	1129	9
11656	2537	1130	2
11657	2537	1131	4
11658	2537	481	5
11659	2538	1132	4
11660	2538	1133	8
11661	2538	1134	1
11662	2538	476	8
11663	2539	1135	6
11664	2539	1136	8
11665	2539	1137	2
11666	2539	488	9
11667	2540	489	4
11668	2540	1138	4
11669	2540	1139	9
11670	2540	492	13
11671	2541	493	6
11672	2541	494	9
11673	2541	1140	6
11674	2541	1141	6
11675	2541	476	4
11676	2542	497	3
11677	2542	1142	8
11678	2542	1126	9
11679	2542	499	2
11680	2542	481	8
11681	2543	500	5
11682	2543	1143	7
11683	2543	502	1
11684	2543	1130	2
11685	2543	503	2
11686	2544	504	1
11687	2544	505	5
11688	2544	1144	3
11689	2544	1145	11
11690	2544	508	2
11691	2545	504	1
11692	2545	505	5
11693	2545	1144	3
11694	2545	1145	11
11695	2545	508	2
11696	2546	509	4
11697	2546	505	7
11698	2546	1146	11
11699	2546	1147	10
11700	2546	512	5
11701	2547	504	1
11702	2547	505	5
11703	2547	1144	9
11704	2547	1145	8
11705	2547	508	4
11706	2548	513	12
11707	2548	514	7
11708	2548	1146	7
11709	2548	1148	11
11710	2548	512	2
11711	2549	504	1
11712	2549	505	4
11713	2549	1144	8
11714	2549	1145	6
11715	2549	508	3
11716	2550	504	2
11717	2550	505	7
11718	2550	1144	1
11719	2550	1145	5
11720	2550	508	1
11721	2551	516	7
11722	2551	1149	9
11723	2551	1150	3
11724	2551	519	3
11725	2551	492	5
11726	2552	504	1
11727	2552	505	6
11728	2552	1144	3
11729	2552	1145	8
11730	2552	508	3
11731	2553	516	4
11732	2553	1149	6
11733	2553	520	6
11734	2553	1151	1
11735	2553	492	1
11736	2554	1152	9
11737	2555	1153	11
11738	2555	1154	6
11739	2555	525	5
11740	2555	526	2
11741	2555	527	12
11742	2555	528	6
11743	2556	529	4
11744	2556	1155	3
11745	2556	531	4
11746	2556	1156	8
11747	2556	1157	5
11748	2556	1158	12
11749	2556	535	12
11750	2557	536	11
11751	2557	1159	5
11752	2557	1160	10
11753	2557	539	11
11754	2557	540	9
11755	2557	541	12
11756	2557	542	11
11757	2558	543	13
11758	2558	1161	6
11759	2558	1162	5
11760	2558	540	2
11761	2558	546	2
11762	2558	542	5
11763	2559	547	9
11764	2559	1163	13
11765	2559	1164	5
11766	2559	550	13
11767	2559	551	7
11768	2560	1165	13
11769	2560	1166	3
11770	2560	1167	7
11771	2560	555	7
11772	2560	1168	3
11773	2560	550	8
11774	2561	557	9
11775	2561	1169	11
11776	2561	1166	8
11777	2561	1170	9
11778	2561	560	11
11779	2561	1171	2
11780	2562	562	4
11781	2562	1166	6
11782	2562	1172	11
11783	2562	1173	9
11784	2562	1174	5
11785	2562	566	11
11786	2563	567	9
11787	2563	568	8
11788	2563	1175	11
11789	2563	1173	10
11790	2563	570	11
11791	2564	571	12
11792	2564	1176	6
11793	2564	1177	8
11794	2564	1178	10
11795	2564	575	7
11796	2564	576	6
11797	2565	577	6
11798	2565	557	8
11799	2565	1179	9
11800	2565	1166	4
11801	2565	1178	13
11802	2565	566	8
11803	2566	1180	2
11804	2566	1172	11
11805	2566	1181	9
11806	2566	1167	11
11807	2566	566	11
11808	2567	581	5
11809	2567	1182	11
11810	2567	583	2
11811	2567	1183	3
11812	2567	585	4
11813	2568	1184	7
11814	2568	1185	9
11815	2568	583	4
11816	2568	1186	5
11817	2568	585	3
11818	2569	1187	8
11819	2569	1185	9
11820	2569	583	5
11821	2569	1186	6
11822	2569	585	7
11823	2570	590	4
11824	2570	1188	8
11825	2570	536	8
11826	2570	1189	7
11827	2570	593	6
11828	2571	1190	4
11829	2571	1191	9
11830	2571	583	6
11831	2571	1192	1
11832	2571	585	9
11833	2572	597	13
11834	2572	1193	11
11835	2572	599	5
11836	2572	1194	6
11837	2572	601	3
11838	2573	602	4
11839	2573	1195	11
11840	2573	555	8
11841	2573	1196	5
11842	2573	585	5
11843	2574	1184	5
11844	2574	1185	5
11845	2574	583	5
11846	2574	1186	6
11847	2574	585	2
11848	2575	605	4
11849	2575	606	4
11850	2575	1197	7
11851	2575	1198	2
11852	2575	609	1
11853	2576	610	3
11854	2576	611	3
11855	2576	1185	7
11856	2576	1199	3
11857	2576	570	3
11858	2577	613	1
11859	2577	1200	7
11860	2577	615	4
11861	2577	1201	2
11862	2577	601	2
11863	2578	617	3
11864	2579	618	12
11865	2580	1202	3
11866	2580	1203	9
11867	2581	1204	4
11868	2582	1205	5
11869	2583	623	6
11870	2583	624	5
11871	2584	1203	11
11872	2585	1206	4
11873	2585	1207	6
11874	2586	1208	4
11875	2587	1209	3
11876	2588	1210	9
11877	2589	1211	3
11878	2590	1212	5
11879	2591	1213	6
11880	2591	633	11
11881	2591	634	7
11882	2591	635	8
11883	2591	636	2
11884	2591	637	9
11885	2592	1214	13
11886	2592	1215	14
11887	2592	640	13
11888	2592	2325	14
11889	2592	641	9
11890	2592	642	9
11891	2592	1216	11
11892	2593	644	4
11893	2593	1217	6
11894	2593	646	1
11895	2593	647	4
11896	2593	648	1
11897	2594	1218	6
11898	2594	1219	3
11899	2594	1220	11
11900	2594	652	6
11901	2594	1221	7
11902	2595	654	5
11903	2595	1222	7
11904	2595	634	6
11905	2595	656	3
11906	2595	657	3
11907	2596	658	2
11908	2596	1223	9
11909	2596	1224	11
11910	2596	661	5
11911	2596	1225	6
11912	2597	1226	7
11913	2597	664	11
11914	2597	661	3
11915	2597	665	2
11916	2597	1225	8
11917	2598	1227	8
11918	2598	1228	7
11919	2598	1229	5
11920	2598	669	2
11921	2599	670	5
11922	2599	1230	4
11923	2599	1224	8
11924	2599	669	4
11925	2599	672	11
11926	2599	1225	6
11927	2600	1231	7
11928	2600	672	11
11929	2600	640	7
11930	2600	661	7
11931	2600	674	7
11932	2600	635	6
11933	2601	1232	3
11934	2601	1226	8
11935	2601	672	8
11936	2601	661	4
11937	2601	665	2
11938	2602	676	12
11939	2602	1233	9
11940	2602	1234	7
11941	2602	1235	6
11942	2602	680	2
11943	2603	681	2
11944	2603	682	4
11945	2603	1236	7
11946	2603	684	2
11947	2603	1237	7
11948	2604	1238	8
11949	2604	1235	5
11950	2604	1239	4
11951	2604	1240	4
11952	2604	680	3
11953	2605	689	9
11954	2605	1238	9
11955	2605	1235	6
11956	2605	1241	8
11957	2605	691	13
11958	2606	692	6
11959	2606	693	9
11960	2606	1235	9
11961	2606	1242	4
11962	2606	680	7
11963	2607	695	4
11964	2607	1243	9
11965	2607	1244	9
11966	2607	680	8
11967	2608	698	6
11968	2608	1233	10
11969	2608	1235	11
11970	2608	1245	6
11971	2609	700	3
11972	2609	1246	2
11973	2609	1243	9
11974	2609	1244	7
11975	2609	680	6
11976	2610	702	5
11977	2610	1247	7
11978	2610	1248	7
11979	2610	1235	6
11980	2610	680	7
11981	2611	705	5
11982	2611	1249	11
11983	2611	1244	9
11984	2611	1250	6
11985	2611	680	1
11986	2612	1251	8
11987	2612	1234	6
11988	2612	1244	6
11989	2612	709	9
11990	2612	710	8
11991	2613	711	3
11992	2613	1252	7
11993	2613	1253	7
11994	2613	1254	6
11995	2613	691	2
11996	2614	715	3
11997	2614	716	6
11998	2614	1255	9
11999	2614	1256	2
12000	2614	719	3
12001	2615	720	4
12002	2615	1257	7
12003	2615	722	2
12004	2615	1258	5
12005	2615	684	1
12006	2616	724	4
12007	2616	682	6
12008	2616	1259	6
12009	2616	1260	7
12010	2616	727	6
12011	2617	728	2
12012	2617	1261	9
12013	2617	730	3
12014	2617	1262	3
12015	2617	732	6
12016	2618	733	7
12017	2618	734	6
12018	2618	1263	8
12019	2618	1264	11
12020	2618	727	6
12021	2619	715	3
12022	2619	716	9
12023	2619	1255	5
12024	2619	1256	9
12025	2619	719	8
12026	2620	737	6
12027	2620	1265	6
12028	2620	739	4
12029	2620	1266	2
12030	2620	727	6
12031	2621	741	7
12032	2621	682	5
12033	2621	1263	5
12034	2621	1267	9
12035	2621	727	1
12036	2622	715	3
12037	2622	716	7
12038	2622	1255	6
12039	2622	1256	3
12040	2622	719	6
12041	2623	743	8
12042	2623	716	8
12043	2623	1265	8
12044	2623	1256	9
12045	2623	719	9
12046	2624	744	4
12047	2624	1261	6
12048	2624	1268	5
12049	2624	746	4
12050	2624	732	5
12051	2625	747	8
12052	2625	1269	11
12053	2625	749	3
12054	2625	1270	8
12055	2625	751	7
12056	2626	752	6
12057	2626	1261	9
12058	2626	753	5
12059	2626	1271	10
12060	2626	732	7
12061	2627	715	4
12062	2627	716	6
12063	2627	1255	8
12064	2627	1256	3
12065	2627	719	6
12066	2628	755	6
12067	2628	1265	5
12068	2628	756	5
12069	2628	1272	4
12070	2628	758	1
12071	2629	759	4
12072	2629	1273	6
12073	2629	730	4
12074	2629	1274	2
12075	2629	684	1
12076	2630	762	6
12077	2630	1275	7
12078	2630	764	6
12079	2630	1276	2
12080	2630	727	6
12081	2631	1277	5
12082	2631	693	4
12083	2631	1257	7
12084	2631	767	7
12085	2631	751	1
12086	2632	768	3
12087	2632	769	9
12088	2632	1278	8
12089	2632	1279	4
12090	2632	684	1
12091	2633	772	6
12092	2633	1280	5
12093	2633	774	4
12094	2633	1281	6
12095	2633	727	5
12096	2634	776	5
12097	2634	1282	11
12098	2634	778	4
12099	2634	1283	12
12100	2634	727	5
12101	2635	755	7
12102	2635	1265	8
12103	2635	756	7
12104	2635	1272	3
12105	2635	758	4
12106	2636	780	6
12107	2636	769	10
12108	2636	1284	8
12109	2636	1279	3
12110	2636	684	11
12111	2637	762	5
12112	2637	1275	8
12113	2637	764	5
12114	2637	1276	1
12115	2637	751	5
12116	2638	755	6
12117	2638	1265	4
12118	2638	756	8
12119	2638	1272	4
12120	2638	758	1
12121	2639	782	4
12122	2639	1261	7
12123	2639	767	4
12124	2639	1285	8
12125	2639	732	6
12126	2640	784	7
12127	2640	1286	9
12128	2640	753	5
12129	2640	1266	2
12130	2640	751	6
12131	2641	786	4
12132	2641	1261	8
12133	2641	767	5
12134	2641	1285	9
12135	2641	732	8
12136	2642	787	3
12137	2642	1261	4
12138	2642	1287	9
12139	2642	1288	4
12140	2642	732	3
12141	2643	1289	12
12142	2643	1261	1
12143	2643	791	8
12144	2643	1285	7
12145	2643	732	5
12146	2644	755	4
12147	2644	1265	9
12148	2644	756	9
12149	2644	1272	4
12150	2644	758	5
12151	2645	792	1
12152	2645	793	3
12153	2645	1290	8
12154	2645	1291	3
12155	2645	796	4
12156	2646	797	5
12157	2646	798	5
12158	2646	1292	2
12159	2646	1293	7
12160	2646	796	5
12161	2647	801	1
12162	2647	802	2
12163	2647	1290	11
12164	2647	1294	1
12165	2647	796	11
12166	2648	1295	8
12167	2648	805	12
12168	2648	1296	8
12169	2648	1297	10
12170	2648	1298	7
12171	2649	809	5
12172	2649	1299	6
12173	2649	811	12
12174	2649	812	3
12175	2649	813	12
12176	2649	1300	3
12177	2650	1295	6
12178	2650	1301	14
12179	2650	816	4
12180	2650	817	7
12181	2650	811	9
12182	2650	818	12
12183	2650	819	11
12184	2651	820	7
12185	2651	821	5
12186	2651	1302	2
12187	2651	1303	2
12188	2651	818	3
12189	2651	824	12
12190	2651	1304	7
12191	2652	1296	7
12192	2652	1305	8
12193	2652	827	5
12194	2652	828	8
12195	2652	1306	6
12196	2653	1307	2
12197	2653	1308	11
12198	2653	832	6
12199	2653	828	8
12200	2653	833	6
12201	2653	834	2
12202	2654	1309	7
12203	2654	1310	8
12204	2654	827	7
12205	2654	832	7
12206	2654	837	9
12207	2655	838	6
12208	2655	839	6
12209	2655	1311	11
12210	2655	841	8
12211	2655	842	12
12212	2655	843	5
12213	2656	844	9
12214	2656	1312	13
12215	2656	1313	7
12216	2656	1314	7
12217	2656	848	3
12218	2656	849	6
12219	2657	848	5
12220	2657	1315	11
12221	2657	827	1
12222	2657	842	7
12223	2657	849	5
12224	2658	851	4
12225	2658	817	12
12226	2658	837	5
12227	2658	812	6
12228	2658	852	3
12229	2658	853	12
12230	2658	1316	11
12231	2659	1308	11
12232	2659	855	8
12233	2659	817	5
12234	2659	828	9
12235	2659	1317	5
12236	2660	857	12
12237	2660	1318	11
12238	2660	1319	8
12239	2660	1320	1
12240	2660	855	7
12241	2660	861	5
12242	2661	862	8
12243	2661	1321	7
12244	2661	1322	9
12245	2661	1323	6
12246	2661	866	7
12247	2662	1296	7
12248	2662	1314	8
12249	2662	1324	6
12250	2662	868	3
12251	2662	1325	6
12252	2662	827	8
12253	2663	1326	10
12254	2663	1324	8
12255	2663	1327	5
12256	2663	827	11
12257	2663	849	9
12258	2664	872	8
12259	2664	1328	13
12260	2664	1329	13
12261	2664	1330	6
12262	2664	827	9
12263	2665	876	2
12264	2665	1331	9
12265	2665	1296	8
12266	2665	1332	9
12267	2665	1333	6
12268	2665	880	13
12269	2666	881	6
12270	2666	1334	4
12271	2666	1335	7
12272	2666	1336	5
12273	2666	841	3
12274	2667	1337	4
12275	2667	1313	9
12276	2667	1338	11
12277	2667	855	13
12278	2667	887	12
12279	2668	1313	6
12280	2668	1339	11
12281	2668	1340	9
12282	2668	1341	5
12283	2668	880	7
12284	2669	1342	5
12285	2669	1343	9
12286	2669	1334	11
12287	2669	1324	11
12288	2669	827	5
12289	2670	893	4
12290	2670	1344	5
12291	2670	1345	9
12292	2670	1346	1
12293	2670	841	13
12294	2670	1316	8
12295	2671	897	3
12296	2671	1347	9
12297	2671	1348	5
12298	2671	1349	5
12299	2671	901	6
12300	2672	902	2
12301	2672	1296	6
12302	2672	1339	8
12303	2672	1350	6
12304	2672	827	9
12305	2672	1351	3
12306	2673	905	4
12307	2673	906	5
12308	2673	1352	6
12309	2673	1353	7
12310	2673	909	3
12311	2674	910	4
12312	2674	1354	5
12313	2674	912	2
12314	2674	1355	3
12315	2674	914	2
12316	2675	1356	6
12317	2675	1357	9
12318	2675	917	6
12319	2675	1358	9
12320	2675	919	6
12321	2676	920	2
12322	2676	1359	11
12323	2676	839	8
12324	2676	1360	1
12325	2676	866	5
12326	2677	923	5
12327	2677	924	7
12328	2677	1361	8
12329	2677	1362	4
12330	2677	914	7
12331	2678	927	7
12332	2678	1363	5
12333	2678	1352	10
12334	2678	1364	2
12335	2678	930	9
12336	2679	931	12
12337	2679	1365	9
12338	2679	933	2
12339	2679	934	3
12340	2679	1298	3
12341	2680	935	5
12342	2680	1366	6
12343	2680	937	7
12344	2680	1367	5
12345	2680	930	1
12346	2681	939	5
12347	2681	905	4
12348	2681	1357	8
12349	2681	1368	2
12350	2681	930	7
12351	2682	1369	9
12352	2682	1366	7
12353	2682	1370	8
12354	2682	1371	13
12355	2682	1372	9
12356	2683	1373	4
12357	2683	1347	6
12358	2683	839	7
12359	2683	1374	8
12360	2683	866	5
12361	2684	1375	3
12362	2684	1376	8
12363	2684	1299	6
12364	2684	1320	2
12365	2684	919	10
12366	2685	1373	5
12367	2685	1377	10
12368	2685	1378	11
12369	2685	1379	8
12370	2685	866	5
12371	2686	1380	6
12372	2686	1352	7
12373	2686	1381	2
12374	2686	1346	3
12375	2686	930	6
12376	2687	1382	8
12377	2687	1383	3
12378	2687	1384	8
12379	2687	1385	5
12380	2687	914	1
12381	2688	1386	2
12382	2688	1387	6
12383	2688	1358	4
12384	2688	1388	4
12385	2688	1372	6
12386	2689	1389	5
12387	2689	1390	8
12388	2689	1391	7
12389	2689	1364	2
12390	2689	914	3
12391	2690	1392	8
12392	2690	1361	9
12393	2690	1393	5
12394	2690	1394	2
12395	2690	866	4
12396	2691	1395	7
12397	2691	1396	11
12398	2691	1397	6
12399	2691	816	6
12400	2691	1388	8
12401	2692	1398	8
12402	2692	1399	10
12403	2692	1366	3
12404	2692	1400	2
12405	2692	1401	6
12406	2692	1388	8
12407	2693	1402	2
12408	2693	1403	7
12409	2693	1404	5
12410	2693	1348	4
12411	2693	919	3
12412	2694	1405	5
12413	2694	1383	3
12414	2694	1387	8
12415	2694	1406	6
12416	2694	866	7
12417	2695	1407	4
12418	2695	1408	13
12419	2695	1404	4
12420	2695	1409	1
12421	2695	909	2
12422	2696	1389	5
12423	2696	1410	9
12424	2696	1391	7
12425	2696	1364	2
12426	2696	934	9
12427	2697	1411	4
12428	2697	1383	4
12429	2697	1359	9
12430	2697	1412	5
12431	2697	914	1
12432	2698	1413	2
12433	2698	1414	6
12434	2698	1415	4
12435	2698	816	6
12436	2698	866	5
12437	2699	1416	3
12438	2699	1417	9
12439	2699	1418	4
12440	2699	1406	4
12441	2699	934	6
12442	2700	1419	5
12443	2700	1377	9
12444	2700	1378	8
12445	2700	1420	7
12446	2700	866	7
12447	2701	1421	4
12448	2701	1390	3
12449	2701	839	8
12450	2701	1394	5
12451	2701	919	3
12452	2702	1422	7
12453	2702	1352	6
12454	2702	917	7
12455	2702	1423	12
12456	2702	866	9
12457	2703	1424	3
12458	2703	1425	4
12459	2703	1426	11
12460	2703	1427	7
12461	2703	930	8
12462	2704	935	5
12463	2704	1352	7
12464	2704	1412	7
12465	2704	1428	5
12466	2704	1388	8
12467	2705	902	3
12468	2705	1408	7
12469	2705	1429	11
12470	2705	1430	2
12471	2705	914	4
12472	2706	1431	2
12473	2706	1432	8
12474	2706	1433	4
12475	2706	1434	5
12476	2706	901	8
12477	2707	1435	8
12478	2708	1436	4
12479	2708	1437	6
12480	2709	1438	2
12481	2710	1439	2
12482	2711	1440	4
12483	2712	1441	3
12484	2712	1442	5
12485	2712	1443	9
12486	2713	1444	3
12487	2713	1445	6
12488	2714	1446	6
12489	2715	1447	8
12490	2716	1448	8
12491	2717	1449	1
12492	2718	1450	9
12493	2719	1451	11
12494	2719	1445	7
12495	2720	1452	6
12496	2720	1453	8
12497	2721	1454	9
12498	2722	1455	8
12499	2723	1456	4
12500	2723	1457	2
12501	2724	1458	9
12502	2725	1459	9
12503	2726	1460	8
12504	2727	1461	2
12505	2727	1462	1
12506	2728	1463	3
12507	2729	1464	6
12508	2730	1465	11
12509	2731	1466	9
12510	2731	1467	6
12511	2732	1468	9
12512	2733	1469	3
12513	2733	1457	3
12514	2734	1470	3
12515	2734	1471	4
12516	2735	1465	11
12517	2736	1454	5
12518	2737	1463	9
12519	2738	1472	6
12520	2738	1458	7
12521	2739	1473	1
12522	2740	1474	8
12523	2741	1475	4
12524	2742	1476	12
12525	2742	1477	9
12526	2742	1478	11
12527	2742	1479	11
12528	2742	1480	11
12529	2743	1481	7
12530	2744	1482	13
12531	2744	1483	4
12532	2744	1484	11
12533	2744	1485	9
12534	2744	1477	5
12535	2744	1486	5
12536	2744	1487	2
12537	2745	1488	6
12538	2745	1489	4
12539	2745	1487	12
12540	2746	1490	5
12541	2746	1491	5
12542	2746	1492	14
12543	2746	1477	5
12544	2746	1493	4
12545	2746	1494	4
12546	2746	1495	13
12547	2747	1496	11
12548	2747	1497	9
12549	2747	1486	11
12550	2747	1498	2
12551	2747	1499	12
12552	2748	1483	2
12553	2748	1500	4
12554	2748	1501	13
12555	2748	1502	11
12556	2748	1503	5
12557	2748	1504	8
12558	2749	1505	7
12559	2749	1506	13
12560	2749	1502	9
12561	2749	1477	8
12562	2749	1503	5
12563	2749	1507	6
12564	2750	1508	5
12565	2750	1509	2
12566	2750	1510	2
12567	2750	1511	2
12568	2750	1512	8
12569	2751	1513	6
12570	2751	1514	5
12571	2751	1491	13
12572	2751	1515	14
12573	2751	1516	9
12574	2751	1517	8
12575	2751	1495	10
12576	2752	1518	4
12577	2752	1519	13
12578	2752	1477	8
12579	2752	1478	9
12580	2752	1493	4
12581	2753	1520	3
12582	2753	1491	11
12583	2753	1521	14
12584	2753	1522	8
12585	2753	1502	9
12586	2753	1507	4
12587	2753	1499	7
12588	2753	1480	8
12589	2754	1496	9
12590	2754	1523	3
12591	2754	1493	5
12592	2754	1486	6
12593	2754	1494	5
12594	2754	1495	11
12595	2755	1524	7
12596	2755	1491	11
12597	2755	1515	14
12598	2755	1477	5
12599	2755	1525	5
12600	2755	1503	12
12601	2755	1526	11
12602	2756	1527	6
12603	2756	1528	11
12604	2756	1529	10
12605	2756	1491	8
12606	2756	1521	14
12607	2756	1530	4
12608	2757	1531	4
12609	2757	1529	6
12610	2757	1491	7
12611	2757	1532	14
12612	2757	1533	5
12613	2757	1534	4
12614	2758	1535	4
12615	2758	1491	2
12616	2758	1521	14
12617	2758	1536	9
12618	2758	1525	5
12619	2758	1503	7
12620	2758	1537	11
12621	2758	1495	9
12622	2759	1538	5
12623	2759	1490	6
12624	2759	1491	11
12625	2759	1521	14
12626	2759	1516	9
12627	2759	1517	9
12628	2759	1526	9
12629	2760	1528	13
12630	2760	1529	11
12631	2760	1539	10
12632	2760	1540	9
12633	2760	1541	9
12634	2761	1542	3
12635	2761	1525	4
12636	2761	1498	4
12637	2761	1543	7
12638	2761	1495	11
12639	2762	1544	11
12640	2762	1545	11
12641	2762	1546	2
12642	2762	1547	6
12643	2762	1479	12
12644	2763	1548	8
12645	2763	1516	6
12646	2763	1517	9
12647	2763	1498	4
12648	2763	1549	4
12649	2763	1495	11
12650	2764	1550	13
12651	2764	1491	11
12652	2764	1515	14
12653	2764	1477	8
12654	2764	1525	3
12655	2764	1503	5
12656	2764	1526	8
12657	2765	1529	10
12658	2765	1491	11
12659	2765	1532	14
12660	2765	1477	6
12661	2765	1478	6
12662	2765	1493	5
12663	2765	1526	11
12664	2766	1551	6
12665	2766	1552	8
12666	2766	1491	5
12667	2766	1521	14
12668	2766	1516	3
12669	2766	1478	4
12670	2767	1553	2
12671	2767	1554	5
12672	2767	1555	11
12673	2767	1556	8
12674	2767	1511	4
12675	2768	1557	5
12676	2768	1491	6
12677	2768	1492	14
12678	2768	1477	3
12679	2768	1540	2
12680	2768	1503	6
12681	2768	1526	8
12682	2769	1558	4
12683	2769	1559	4
12684	2769	1560	11
12685	2769	1561	9
12686	2769	1562	4
12687	2770	1563	4
12688	2770	1564	3
12689	2770	1565	9
12690	2770	1566	9
12691	2770	1562	8
12692	2771	1567	3
12693	2771	1568	7
12694	2771	1569	8
12695	2771	1511	2
12696	2772	1570	2
12697	2772	1571	9
12698	2772	1572	3
12699	2772	1573	11
12700	2773	1574	5
12701	2773	1575	5
12702	2773	1576	5
12703	2773	1577	5
12704	2773	1530	2
12705	2774	1578	2
12706	2774	1579	9
12707	2774	1572	7
12708	2774	1580	7
12709	2774	1581	7
12710	2775	1582	3
12711	2775	1583	2
12712	2775	1560	7
12713	2775	1584	7
12714	2775	1562	5
12715	2776	1585	1
12716	2776	1586	9
12717	2776	1587	7
12718	2776	1588	3
12719	2776	1581	5
12720	2777	1589	11
12721	2777	1590	8
12722	2777	1591	2
12723	2777	1592	6
12724	2778	1593	5
12725	2778	1594	9
12726	2778	1595	11
12727	2778	1580	9
12728	2779	1596	3
12729	2779	1597	9
12730	2779	1598	7
12731	2779	1599	3
12732	2779	1530	7
12733	2780	1583	3
12734	2780	1600	3
12735	2780	1560	7
12736	2780	1601	8
12737	2780	1602	13
12738	2781	1583	3
12739	2781	1603	3
12740	2781	1576	7
12741	2781	1604	1
12742	2781	1602	9
12743	2782	1605	4
12744	2782	1568	7
12745	2782	1606	7
12746	2782	1530	1
12747	2783	1607	8
12748	2783	1608	9
12749	2783	1609	7
12750	2783	1610	3
12751	2783	1562	6
12752	2784	1611	11
12753	2784	1612	9
12754	2784	1613	8
12755	2784	1614	7
12756	2784	1592	3
12757	2785	1615	2
12758	2785	1616	7
12759	2785	1617	11
12760	2785	1618	3
12761	2785	1511	5
12762	2786	1619	12
12763	2786	1560	8
12764	2786	1601	9
12765	2786	1602	6
12766	2787	1620	2
12767	2787	1621	1
12768	2787	1571	13
12769	2787	1622	7
12770	2787	1511	3
12771	2788	1623	1
12772	2788	1624	7
12773	2788	1587	6
12774	2788	1625	5
12775	2788	1581	7
12776	2789	1626	5
12777	2789	1627	5
12778	2789	1628	9
12779	2789	1569	9
12780	2789	1511	2
12781	2790	1629	7
12782	2790	1630	9
12783	2790	1590	5
12784	2790	1592	9
12785	2791	1575	5
12786	2791	1631	9
12787	2791	1632	1
12788	2791	1633	5
12789	2791	1546	4
12790	2792	1634	2
12791	2792	1635	3
12792	2792	1636	3
12793	2792	1546	2
12794	2792	1516	4
12795	2793	1637	2
12796	2793	1638	5
12797	2793	1639	5
12798	2793	1530	4
12799	2793	1640	3
12800	2794	1641	3
12801	2794	1642	3
12802	2794	1643	8
12803	2794	1590	7
12804	2794	1581	9
12805	2795	1642	4
12806	2795	1644	9
12807	2795	1572	7
12808	2795	1645	8
12809	2795	1592	7
12810	2796	1646	4
12811	2796	1647	8
12812	2796	1648	9
12813	2796	1592	5
12814	2797	1575	11
12815	2797	1612	11
12816	2797	1649	12
12817	2797	1592	12
12818	2797	1516	11
12819	2798	1650	3
12820	2798	1638	7
12821	2798	1584	9
12822	2798	1651	5
12823	2798	1546	3
12824	2799	1652	4
12825	2799	1571	9
12826	2799	1572	5
12827	2799	1533	3
12828	2800	1653	3
12829	2800	1586	9
12830	2800	1654	6
12831	2800	1530	7
12832	2801	1655	2
12833	2801	1652	4
12834	2801	1571	8
12835	2801	1572	6
12836	2801	1533	4
12837	2802	1656	4
12838	2802	1643	9
12839	2802	1587	6
12840	2802	1651	2
12841	2802	1511	6
12842	2803	1641	3
12843	2803	1624	9
12844	2803	1572	9
12845	2803	1657	4
12846	2803	1581	8
12847	2804	1658	3
12848	2804	1659	9
12849	2804	1590	7
12850	2804	1660	1
12851	2804	1530	5
12852	2804	1516	6
12853	2805	1623	1
12854	2805	1624	9
12855	2805	1587	6
12856	2805	1625	6
12857	2805	1581	8
12858	2806	1661	6
12859	2806	1575	8
12860	2806	1662	7
12861	2806	1663	5
12862	2806	1546	2
12863	2807	1664	5
12864	2807	1665	11
12865	2807	1666	8
12866	2807	1667	4
12867	2807	1581	9
12868	2808	1583	2
12869	2808	1668	2
12870	2808	1669	6
12871	2808	1631	7
12872	2808	1511	3
12873	2809	1670	4
12874	2809	1671	4
12875	2809	1528	11
12876	2809	1672	8
12877	2809	1546	6
12878	2810	1673	7
12879	2810	1674	10
12880	2810	1622	8
12881	2810	1675	7
12882	2810	1530	7
12883	2811	1676	3
12884	2811	1643	13
12885	2811	1631	9
12886	2811	1618	3
12887	2811	1530	8
12888	2812	1677	4
12889	2812	1678	3
12890	2812	1665	7
12891	2812	1679	9
12892	2812	1613	8
12893	2812	1530	8
12894	2813	1680	7
12895	2813	1681	9
12896	2813	1682	12
12897	2813	1530	7
12898	2813	1683	4
12899	2814	1594	9
12900	2814	1590	9
12901	2814	1684	5
12902	2814	1511	9
12903	2815	1685	5
12904	2815	1686	1
12905	2815	1613	4
12906	2815	1687	7
12907	2815	1688	1
12908	2816	1689	5
12909	2816	1686	2
12910	2816	1690	3
12911	2816	1645	6
12912	2816	1688	3
12913	2817	1691	4
12914	2817	1692	8
12915	2817	1693	6
12916	2817	1694	1
12917	2817	1695	3
12918	2818	1696	5
12919	2818	1697	7
12920	2818	1698	5
12921	2818	1663	3
12922	2818	1699	9
12923	2819	1700	5
12924	2819	1701	4
12925	2819	1702	1
12926	2819	1703	1
12927	2819	1704	4
12928	2820	1705	4
12929	2820	1706	6
12930	2820	1707	7
12931	2820	1708	2
12932	2820	1699	3
12933	2821	1709	6
12934	2821	1710	8
12935	2821	1707	6
12936	2821	1711	3
12937	2821	1712	11
12938	2822	1551	5
12939	2822	1713	5
12940	2822	1714	5
12941	2822	1715	8
12942	2822	1699	8
12943	2823	1716	3
12944	2823	1717	6
12945	2823	1718	2
12946	2823	1719	1
12947	2823	1720	8
12948	2824	1691	3
12949	2824	1692	4
12950	2824	1693	4
12951	2824	1694	1
12952	2824	1695	2
12953	2825	1551	4
12954	2825	1721	2
12955	2825	1697	8
12956	2825	1722	1
12957	2825	1699	1
12958	2826	1723	3
12959	2826	1724	6
12960	2826	1701	8
12961	2826	1725	1
12962	2826	1704	7
12963	2827	1691	3
12964	2827	1692	5
12965	2827	1693	11
12966	2827	1694	6
12967	2827	1695	8
12968	2828	1709	5
12969	2828	1710	7
12970	2828	1707	7
12971	2828	1711	2
12972	2828	1712	7
12973	2829	1691	3
12974	2829	1692	6
12975	2829	1693	6
12976	2829	1694	1
12977	2829	1695	1
12978	2830	1709	5
12979	2830	1710	1
12980	2830	1707	4
12981	2830	1711	3
12982	2830	1712	1
12983	2831	1716	4
12984	2831	1717	3
12985	2831	1718	3
12986	2831	1719	3
12987	2831	1720	1
12988	2832	1726	4
12989	2832	1701	11
12990	2832	1702	6
12991	2832	1727	5
12992	2832	1704	8
12993	2833	1728	2
12994	2833	1729	5
12995	2833	1701	7
12996	2833	1704	5
12997	2833	1730	3
12998	2834	1658	1
12999	2834	1731	5
13000	2834	1732	1
13001	2834	1733	8
13002	2834	1533	4
13003	2835	1734	5
13004	2835	1735	6
13005	2835	1707	6
13006	2835	1736	2
13007	2835	1533	4
13008	2836	1737	6
13009	2836	1738	1
13010	2836	1739	2
13011	2836	1533	3
13012	2836	1740	3
13013	2837	1709	6
13014	2837	1710	8
13015	2837	1707	7
13016	2837	1711	3
13017	2837	1712	11
13018	2838	1709	6
13019	2838	1710	5
13020	2838	1707	7
13021	2838	1711	5
13022	2838	1712	7
13023	2839	1741	3
13024	2839	1686	2
13025	2839	1690	2
13026	2839	1742	5
13027	2839	1688	3
13028	2840	1716	4
13029	2840	1717	4
13030	2840	1718	1
13031	2840	1719	1
13032	2840	1720	7
13033	2841	1716	3
13034	2841	1717	5
13035	2841	1718	3
13036	2841	1719	2
13037	2841	1720	4
13038	2842	1743	7
13039	2842	1744	8
13040	2842	1698	4
13041	2842	1745	4
13042	2842	1699	8
13043	2843	1746	4
13044	2843	1686	3
13045	2843	1739	3
13046	2843	1747	8
13047	2843	1688	5
13048	2844	1709	5
13049	2844	1710	8
13050	2844	1707	4
13051	2844	1711	4
13052	2844	1712	9
13053	2845	1748	3
13054	2845	1729	5
13055	2845	1701	11
13056	2845	1749	6
13057	2845	1704	8
13058	2846	1750	5
13059	2846	1701	4
13060	2846	1613	7
13061	2846	1751	1
13062	2846	1704	4
13063	2847	1685	5
13064	2847	1686	1
13065	2847	1580	4
13066	2847	1752	1
13067	2847	1688	2
13068	2848	1753	5
13069	2848	1701	5
13070	2848	1702	2
13071	2848	1733	6
13072	2848	1704	5
13073	2849	1685	4
13074	2849	1686	4
13075	2849	1754	2
13076	2849	1755	2
13077	2849	1688	3
13078	2850	1756	3
13079	2850	1686	6
13080	2850	1732	7
13081	2850	1757	1
13082	2850	1688	3
13083	2851	1758	4
13084	2851	1701	11
13085	2851	1754	2
13086	2851	1759	5
13087	2851	1704	5
13088	2852	1760	6
13089	2852	1721	6
13090	2852	1761	9
13091	2852	1762	5
13092	2852	1699	9
13093	2853	1709	6
13094	2853	1710	8
13095	2853	1707	6
13096	2853	1711	5
13097	2853	1712	2
13098	2854	1709	6
13099	2854	1710	6
13100	2854	1707	4
13101	2854	1711	7
13102	2854	1712	1
13103	2855	1700	5
13104	2855	1701	7
13105	2855	1580	7
13106	2855	1749	5
13107	2855	1704	4
13108	2856	1743	7
13109	2856	1763	1
13110	2856	1714	4
13111	2856	1764	3
13112	2856	1704	5
13113	2857	1691	3
13114	2857	1692	4
13115	2857	1693	5
13116	2857	1694	1
13117	2857	1695	1
13118	2858	1709	5
13119	2858	1710	8
13120	2858	1707	8
13121	2858	1711	6
13122	2858	1712	5
13123	2859	1765	3
13124	2859	1766	3
13125	2859	1686	4
13126	2859	1732	2
13127	2859	1688	2
13128	2860	1716	4
13129	2860	1717	6
13130	2860	1718	3
13131	2860	1719	1
13132	2860	1720	1
13133	2861	1767	5
13134	2861	1768	7
13135	2861	1718	1
13136	2861	1769	5
13137	2861	1699	9
13138	2862	1691	4
13139	2862	1692	5
13140	2862	1693	2
13141	2862	1694	2
13142	2862	1695	3
13143	2863	1716	2
13144	2863	1717	4
13145	2863	1718	1
13146	2863	1719	1
13147	2863	1720	1
13148	2864	1696	5
13149	2864	1721	4
13150	2864	1697	9
13151	2864	1770	6
13152	2864	1699	5
13153	2865	1771	3
13154	2865	1721	7
13155	2865	1772	8
13156	2865	1651	2
13157	2865	1699	7
13158	2866	1691	2
13159	2866	1692	4
13160	2866	1693	5
13161	2866	1694	1
13162	2866	1695	1
13163	2867	1691	4
13164	2867	1692	5
13165	2867	1693	9
13166	2867	1694	2
13167	2867	1695	2
13168	2868	1691	3
13169	2868	1692	5
13170	2868	1693	6
13171	2868	1694	2
13172	2868	1695	3
13173	2869	1773	3
13174	2869	1686	2
13175	2869	1739	5
13176	2869	1774	1
13177	2869	1688	3
13178	2870	1709	7
13179	2870	1710	6
13180	2870	1707	7
13181	2870	1711	6
13182	2870	1712	6
13183	2871	1748	9
13184	2871	1701	6
13185	2871	1613	3
13186	2871	1747	9
13187	2871	1704	1
13188	2872	1737	5
13189	2872	1763	1
13190	2872	1707	1
13191	2872	1747	1
13192	2872	1704	1
13193	2873	1775	4
13194	2873	1701	1
13195	2873	1684	2
13196	2873	1776	1
13197	2873	1704	3
13198	2874	1728	3
13199	2874	1701	1
13200	2874	1702	4
13201	2874	1776	2
13202	2874	1704	1
13203	2875	1746	4
13204	2875	1777	4
13205	2875	1701	6
13206	2875	1684	3
13207	2875	1704	1
13208	2876	1775	4
13209	2876	1778	5
13210	2876	1686	4
13211	2876	1779	4
13212	2876	1688	5
13213	2877	1780	4
13214	2877	1731	9
13215	2877	1684	4
13216	2877	1781	5
13217	2877	1699	1
13218	2878	1782	5
13219	2878	1686	1
13220	2878	1613	2
13221	2878	1783	2
13222	2878	1688	3
13223	2879	1513	5
13224	2879	1784	6
13225	2879	1613	6
13226	2879	1785	5
13227	2879	1699	8
13228	2880	1716	3
13229	2880	1717	3
13230	2880	1718	1
13231	2880	1719	1
13232	2880	1720	1
13233	2881	1709	6
13234	2881	1710	6
13235	2881	1707	5
13236	2881	1711	3
13237	2881	1712	6
13238	2882	1786	8
13239	2882	1701	5
13240	2882	1702	2
13241	2882	1747	10
13242	2882	1704	6
13243	2883	1709	6
13244	2883	1710	9
13245	2883	1707	7
13246	2883	1711	2
13247	2883	1712	7
13248	2884	1709	6
13249	2884	1710	11
13250	2884	1707	8
13251	2884	1711	6
13252	2884	1712	7
13253	2885	1787	5
13254	2885	1692	3
13255	2885	1788	2
13256	2885	1789	1
13257	2885	1699	1
13258	2886	1691	3
13259	2886	1692	7
13260	2886	1693	9
13261	2886	1694	1
13262	2886	1695	4
13263	2887	1737	5
13264	2887	1686	3
13265	2887	1790	2
13266	2887	1688	4
13267	2887	1791	3
13268	2888	1792	3
13269	2888	1692	6
13270	2888	1693	3
13271	2888	1694	2
13272	2888	1695	2
13273	2889	1691	5
13274	2889	1692	4
13275	2889	1693	2
13276	2889	1694	1
13277	2889	1695	1
13278	2890	1691	4
13279	2890	1692	6
13280	2890	1693	8
13281	2890	1694	2
13282	2890	1695	4
13283	2891	1691	4
13284	2891	1692	7
13285	2891	1693	8
13286	2891	1694	2
13287	2891	1695	5
13288	2892	1748	5
13289	2892	1701	6
13290	2892	1718	1
13291	2892	1793	1
13292	2892	1704	5
13293	2893	1716	3
13294	2893	1717	9
13295	2893	1718	2
13296	2893	1719	1
13297	2893	1720	5
13298	2894	1766	6
13299	2894	1701	6
13300	2894	1794	6
13301	2894	1704	6
13302	2894	1543	8
13303	2895	1716	4
13304	2895	1717	6
13305	2895	1718	2
13306	2895	1719	2
13307	2895	1720	8
13308	2896	1691	5
13309	2896	1692	8
13310	2896	1693	8
13311	2896	1694	4
13312	2896	1695	1
13313	2897	1691	4
13314	2897	1692	8
13315	2897	1693	9
13316	2897	1694	3
13317	2897	1695	8
13318	2898	1716	3
13319	2898	1717	7
13320	2898	1718	3
13321	2898	1719	1
13322	2898	1720	3
13323	2899	1709	6
13324	2899	1710	7
13325	2899	1707	6
13326	2899	1711	3
13327	2899	1712	2
13328	2900	1696	4
13329	2900	1795	11
13330	2900	1707	6
13331	2900	1764	4
13332	2900	1699	1
13333	2901	1709	4
13334	2901	1710	9
13335	2901	1707	7
13336	2901	1711	6
13337	2901	1712	4
13338	2902	1716	5
13339	2902	1717	9
13340	2902	1718	4
13341	2902	1719	1
13342	2902	1720	9
13343	2903	1796	4
13344	2903	1797	5
13345	2903	1701	6
13346	2903	1798	1
13347	2903	1704	4
13348	2904	1723	4
13349	2904	1701	8
13350	2904	1718	3
13351	2904	1799	9
13352	2904	1704	6
13353	2905	1716	3
13354	2905	1717	9
13355	2905	1718	1
13356	2905	1719	3
13357	2905	1720	4
13358	2906	1691	3
13359	2906	1692	6
13360	2906	1693	7
13361	2906	1694	4
13362	2906	1695	5
13363	2907	1709	7
13364	2907	1710	9
13365	2907	1707	7
13366	2907	1711	6
13367	2907	1712	10
13368	2908	1800	5
13369	2908	1706	4
13370	2908	1745	2
13371	2908	1562	4
13372	2908	1549	2
13373	2909	1558	3
13374	2909	1554	6
13375	2909	1801	7
13376	2909	1562	5
13377	2909	1543	6
13378	2910	1582	1
13379	2910	1784	5
13380	2910	1714	5
13381	2910	1498	2
13382	2910	1562	1
13383	2911	1802	11
13384	2911	1803	10
13385	2911	1804	7
13386	2911	1805	11
13387	2911	1806	9
13388	2911	1807	1
13389	2912	1808	6
13390	2912	1809	4
13391	2912	1810	3
13392	2912	1811	2
13393	2912	1812	3
13394	2912	1813	14
13395	2912	1814	1
13396	2912	1815	11
13397	2913	1816	6
13398	2913	1812	3
13399	2913	1813	14
13400	2913	1804	5
13401	2913	1817	4
13402	2913	1805	2
13403	2913	1818	4
13404	2914	1819	4
13405	2914	1820	3
13406	2914	1812	4
13407	2914	1821	14
13408	2914	1822	9
13409	2915	1823	3
13410	2915	1824	5
13411	2915	1825	2
13412	2915	1826	7
13413	2915	1827	10
13414	2916	1828	7
13415	2916	1814	5
13416	2916	1829	7
13417	2916	1826	7
13418	2916	1830	9
13419	2917	1831	13
13420	2917	1832	4
13421	2917	1833	4
13422	2917	1834	7
13423	2917	1835	9
13424	2917	1836	3
13425	2918	1837	2
13426	2918	1838	7
13427	2918	1829	13
13428	2918	1839	7
13429	2918	1840	3
13430	2919	1841	8
13431	2919	1812	3
13432	2919	1813	14
13433	2919	1838	7
13434	2919	1817	1
13435	2919	1805	1
13436	2919	1818	7
13437	2920	1842	13
13438	2920	1843	8
13439	2920	1844	5
13440	2920	1829	13
13441	2920	1845	5
13442	2920	1846	2
13443	2920	1847	12
13444	2921	1848	9
13445	2921	1812	11
13446	2921	1849	14
13447	2921	1814	5
13448	2921	1826	8
13449	2922	1850	10
13450	2922	1851	6
13451	2922	1838	6
13452	2922	1814	6
13453	2922	1846	2
13454	2922	1817	7
13455	2922	1830	13
13456	2923	1852	7
13457	2923	1853	7
13458	2923	1812	4
13459	2923	1813	14
13460	2923	1804	6
13461	2923	1835	9
13462	2923	1854	8
13463	2924	1855	3
13464	2924	1856	4
13465	2924	1857	3
13466	2924	1812	11
13467	2924	1849	14
13468	2924	1833	7
13469	2924	1858	9
13470	2925	1859	4
13471	2925	1812	5
13472	2925	1821	14
13473	2925	1804	6
13474	2925	1860	4
13475	2925	1861	3
13476	2925	1834	4
13477	2926	1862	9
13478	2926	1863	5
13479	2926	1833	7
13480	2926	1864	7
13481	2926	1829	4
13482	2926	1865	4
13483	2927	1866	12
13484	2927	1867	11
13485	2927	1868	8
13486	2927	1869	9
13487	2927	1870	12
13488	2927	1854	5
13489	2928	1871	2
13490	2928	1872	2
13491	2928	1830	9
13492	2928	1873	6
13493	2928	1874	4
13494	2928	1875	2
13495	2929	1876	7
13496	2929	1877	11
13497	2929	1829	13
13498	2929	1861	13
13499	2929	1870	13
13500	2930	1878	1
13501	2930	1879	2
13502	2930	1880	5
13503	2930	1830	8
13504	2930	1874	3
13505	2931	1841	13
13506	2931	1881	4
13507	2931	1804	5
13508	2931	1882	5
13509	2931	1860	2
13510	2931	1861	7
13511	2932	1883	9
13512	2932	1884	7
13513	2932	1814	3
13514	2932	1817	4
13515	2932	1839	8
13516	2932	1818	7
13517	2933	1885	4
13518	2933	1833	3
13519	2933	1864	9
13520	2933	1829	6
13521	2934	1886	6
13522	2934	1887	9
13523	2934	1888	5
13524	2934	1832	7
13525	2934	1873	11
13526	2935	1889	8
13527	2935	1812	5
13528	2935	1890	14
13529	2935	1864	7
13530	2935	1817	5
13531	2935	1839	6
13532	2935	1891	8
13533	2936	1892	8
13534	2936	1893	7
13535	2936	1868	7
13536	2936	1894	9
13537	2936	1895	9
13538	2937	1896	11
13539	2937	1897	9
13540	2937	1898	3
13541	2937	1899	2
13542	2937	1858	9
13543	2938	1900	8
13544	2938	1901	6
13545	2938	1816	11
13546	2938	1832	8
13547	2938	1902	11
13548	2939	1903	3
13549	2939	1900	9
13550	2939	1904	6
13551	2939	1905	7
13552	2939	1906	3
13553	2939	1907	1
13554	2940	1908	4
13555	2940	1852	8
13556	2940	1909	3
13557	2940	1910	4
13558	2940	1873	5
13559	2940	1865	6
13560	2941	1911	3
13561	2941	1912	8
13562	2941	1913	11
13563	2941	1914	9
13564	2941	1873	7
13565	2941	1902	3
13566	2942	1915	9
13567	2942	1916	9
13568	2942	1917	6
13569	2942	1918	5
13570	2942	1865	11
13571	2943	1887	10
13572	2943	1919	11
13573	2943	1904	8
13574	2943	1920	4
13575	2943	1921	4
13576	2943	1922	11
13577	2944	1923	5
13578	2944	1897	7
13579	2944	1924	5
13580	2944	1922	9
13581	2944	1902	11
13582	2945	1925	10
13583	2945	1926	5
13584	2945	1832	8
13585	2945	1835	11
13586	2945	1854	8
13587	2946	1927	5
13588	2946	1928	11
13589	2946	1909	8
13590	2946	1835	7
13591	2946	1854	6
13592	2947	1915	9
13593	2947	1929	4
13594	2947	1930	2
13595	2947	1918	5
13596	2947	1865	9
13597	2948	1931	8
13598	2948	1932	6
13599	2948	1933	7
13600	2948	1832	5
13601	2948	1934	7
13602	2948	1865	8
13603	2949	1935	8
13604	2949	1936	9
13605	2949	1937	7
13606	2949	1938	7
13607	2949	1835	1
13608	2949	1865	4
13609	2950	1939	5
13610	2950	1940	3
13611	2950	1941	6
13612	2950	1916	8
13613	2950	1942	8
13614	2950	1902	8
13615	2951	1943	13
13616	2951	1944	9
13617	2951	1909	11
13618	2951	1835	7
13619	2951	1854	8
13620	2952	1945	7
13621	2952	1946	9
13622	2952	1887	9
13623	2952	1947	13
13624	2952	1948	8
13625	2952	1949	10
13626	2953	1950	3
13627	2953	1951	8
13628	2953	1952	8
13629	2953	1832	6
13630	2953	1873	7
13631	2953	1865	7
13632	2954	1953	7
13633	2954	1954	9
13634	2954	1832	7
13635	2954	1934	6
13636	2954	1865	11
13637	2955	1955	4
13638	2955	1956	9
13639	2955	1916	10
13640	2955	1957	5
13641	2955	1873	8
13642	2955	1854	6
13643	2956	1958	9
13644	2956	1959	11
13645	2956	1960	6
13646	2956	1840	4
13647	2957	1887	9
13648	2957	1961	11
13649	2957	1909	9
13650	2957	1962	4
13651	2957	1832	9
13652	2957	1873	7
13653	2958	1963	6
13654	2958	1915	10
13655	2958	1964	5
13656	2958	1957	6
13657	2958	1835	9
13658	2959	1887	10
13659	2959	1941	6
13660	2959	1897	11
13661	2959	1883	6
13662	2959	1954	10
13663	2959	1934	8
13664	2960	1965	8
13665	2960	1888	2
13666	2960	1966	4
13667	2960	1967	6
13668	2960	1854	5
13669	2961	1968	2
13670	2961	1969	4
13671	2961	1970	9
13672	2961	1971	7
13673	2962	1972	3
13674	2962	1973	9
13675	2962	1974	1
13676	2962	1922	11
13677	2962	1902	11
13678	2963	1975	5
13679	2963	1900	13
13680	2963	1901	8
13681	2963	1976	3
13682	2963	1934	9
13683	2963	1902	11
13684	2964	1887	9
13685	2964	1977	9
13686	2964	1978	8
13687	2964	1979	6
13688	2964	1922	11
13689	2965	1980	3
13690	2965	1981	5
13691	2965	1953	9
13692	2965	1982	9
13693	2965	1934	11
13694	2965	1902	11
13695	2966	1983	6
13696	2966	1944	9
13697	2966	1984	6
13698	2966	1883	11
13699	2966	1934	9
13700	2967	1985	2
13701	2967	1986	4
13702	2967	1913	13
13703	2967	1987	9
13704	2967	1835	9
13705	2967	1854	6
13706	2968	1973	8
13707	2968	1914	6
13708	2968	1905	4
13709	2968	1988	2
13710	2968	1895	7
13711	2968	1865	6
13712	2969	1989	5
13713	2969	1990	10
13714	2969	1991	11
13715	2969	1992	7
13716	2969	1873	9
13717	2969	1854	7
13718	2970	1993	3
13719	2970	1994	7
13720	2970	1992	5
13721	2970	1918	4
13722	2970	1865	8
13723	2971	1956	9
13724	2971	1992	9
13725	2971	1995	3
13726	2971	1832	8
13727	2971	1934	9
13728	2971	1865	11
13729	2972	1996	4
13730	2972	1961	9
13731	2972	1938	7
13732	2972	1853	6
13733	2972	1934	9
13734	2972	1902	11
13735	2973	1997	8
13736	2973	1829	3
13737	2973	1834	9
13738	2973	1839	9
13739	2973	1836	2
13740	2973	1902	11
13741	2974	1998	6
13742	2974	1999	6
13743	2974	2000	9
13744	2974	2001	4
13745	2974	1922	6
13746	2974	1854	6
13747	2975	2002	5
13748	2975	2003	9
13749	2975	1997	8
13750	2975	2004	4
13751	2975	1873	8
13752	2975	1902	11
13753	2976	1999	6
13754	2976	1897	11
13755	2976	2005	10
13756	2976	2001	4
13757	2976	1934	11
13758	2976	1854	6
13759	2977	2006	4
13760	2977	2007	3
13761	2977	1867	8
13762	2977	2008	7
13763	2977	1971	5
13764	2977	1902	7
13765	2978	1953	2
13766	2978	1877	4
13767	2978	1832	1
13768	2978	1873	2
13769	2978	2009	3
13770	2979	2010	6
13771	2979	1852	7
13772	2979	1917	8
13773	2979	2011	11
13774	2979	1835	11
13775	2979	1854	14
13776	2980	1964	8
13777	2980	2012	1
13778	2980	2013	3
13779	2980	1934	7
13780	2980	1854	7
13781	2981	2014	6
13782	2981	2015	4
13783	2981	1925	6
13784	2981	2016	5
13785	2981	2017	7
13786	2981	2018	5
13787	2982	2019	9
13788	2982	2020	7
13789	2982	2021	7
13790	2982	1922	9
13791	2982	1865	8
13792	2983	1945	9
13793	2983	1961	4
13794	2983	1938	11
13795	2983	1922	9
13796	2983	1902	8
13797	2984	2022	2
13798	2984	1945	2
13799	2984	1868	6
13800	2984	1934	11
13801	2984	1854	6
13802	2985	2023	4
13803	2985	2024	4
13804	2985	2025	5
13805	2985	2026	1
13806	2985	2027	1
13807	2986	2028	3
13808	2986	2029	5
13809	2986	1853	8
13810	2986	2030	1
13811	2986	2031	7
13812	2987	2032	3
13813	2987	2033	5
13814	2987	2034	7
13815	2987	2035	1
13816	2987	1918	6
13817	2988	2036	6
13818	2988	2037	7
13819	2988	2038	4
13820	2988	1858	8
13821	2988	2009	4
13822	2989	1859	4
13823	2989	2039	9
13824	2989	2040	5
13825	2989	2041	1
13826	2989	1858	12
13827	2990	2023	5
13828	2990	2042	4
13829	2990	2043	3
13830	2990	2029	7
13831	2990	2044	4
13832	2990	1858	3
13833	2991	2045	4
13834	2991	2037	5
13835	2991	2046	3
13836	2991	2047	4
13837	2991	2048	6
13838	2992	2049	6
13839	2992	2050	5
13840	2992	2037	8
13841	2992	1995	2
13842	2992	1858	7
13843	2993	2051	3
13844	2993	2039	9
13845	2993	2052	6
13846	2993	2053	2
13847	2993	1942	7
13848	2994	2054	3
13849	2994	1989	3
13850	2994	2034	5
13851	2994	2035	1
13852	2994	2027	2
13853	2995	2055	3
13854	2995	2056	3
13855	2995	2029	9
13856	2995	2057	3
13857	2995	1858	2
13858	2996	1809	2
13859	2996	2058	9
13860	2996	1853	5
13861	2996	2059	4
13862	2996	1942	5
13863	2997	2060	7
13864	2997	2061	4
13865	2997	2062	8
13866	2997	1988	3
13867	2997	2027	13
13868	2998	2045	3
13869	2998	2063	7
13870	2998	2046	4
13871	2998	2064	1
13872	2998	1907	4
13873	2999	2065	4
13874	2999	2034	7
13875	2999	2066	6
13876	2999	2035	1
13877	2999	2027	3
13878	3000	2067	2
13879	3000	2068	4
13880	3000	2063	4
13881	3000	2041	1
13882	3000	1907	2
13883	3001	2010	1
13884	3001	2069	7
13885	3001	1883	7
13886	3001	2013	3
13887	3001	1942	1
13888	3002	2070	4
13889	3002	2071	8
13890	3002	2052	11
13891	3002	2072	4
13892	3002	2031	8
13893	3003	2022	2
13894	3003	2073	3
13895	3003	2074	11
13896	3003	2075	1
13897	3003	2076	2
13898	3003	1918	6
13899	3004	2077	3
13900	3004	2078	4
13901	3004	1816	4
13902	3004	2079	2
13903	3004	2031	6
13904	3005	2080	3
13905	3005	2081	6
13906	3005	2082	9
13907	3005	2083	1
13908	3005	1907	1
13909	3006	2051	2
13910	3006	2084	2
13911	3006	2029	5
13912	3006	2027	1
13913	3006	2085	2
13914	3007	2086	5
13915	3007	2015	7
13916	3007	2087	9
13917	3007	2088	3
13918	3007	2048	2
13919	3008	2089	3
13920	3008	2068	6
13921	3008	2090	8
13922	3008	2026	3
13923	3008	1895	5
13924	3009	2091	4
13925	3009	2092	3
13926	3009	2052	6
13927	3009	2093	5
13928	3009	1918	3
13929	3010	2094	4
13930	3010	2095	3
13931	3010	1970	7
13932	3010	2053	2
13933	3010	1942	11
13934	3011	2095	3
13935	3011	2096	4
13936	3011	2052	5
13937	3011	1883	7
13938	3011	1942	4
13939	3012	2097	5
13940	3012	2043	6
13941	3012	2090	8
13942	3012	2098	2
13943	3012	1942	7
13944	3013	2045	3
13945	3013	2099	7
13946	3013	2029	9
13947	3013	2072	2
13948	3013	2031	3
13949	3014	2045	3
13950	3014	2063	6
13951	3014	2046	4
13952	3014	2059	4
13953	3014	1907	3
13954	3015	2022	2
13955	3015	2100	3
13956	3015	2101	9
13957	3015	2102	4
13958	3015	1918	8
13959	3016	2103	3
13960	3016	1958	9
13961	3016	2104	4
13962	3016	2013	4
13963	3016	1942	9
13964	3017	2063	6
13965	3017	2105	4
13966	3017	2106	2
13967	3017	2026	6
13968	3017	1942	3
13969	3018	1931	4
13970	3018	2039	8
13971	3018	2066	3
13972	3018	2107	3
13973	3018	2027	1
13974	3019	2108	3
13975	3019	2025	6
13976	3019	2106	1
13977	3019	2109	4
13978	3019	2031	4
13979	3020	2110	12
13980	3020	2025	10
13981	3020	2066	8
13982	3020	2111	6
13983	3020	2031	8
13984	3021	2084	4
13985	3021	2071	7
13986	3021	2112	1
13987	3021	2113	3
13988	3021	2031	7
13989	3022	2045	4
13990	3022	2114	9
13991	3022	2115	2
13992	3022	2041	1
13993	3022	1858	8
13994	3023	2089	4
13995	3023	2068	6
13996	3023	2090	9
13997	3023	2026	1
13998	3023	1895	2
13999	3024	2045	3
14000	3024	1933	8
14001	3024	2046	3
14002	3024	2064	1
14003	3024	1907	1
14004	3025	1859	3
14005	3025	2116	4
14006	3025	2039	10
14007	3025	2117	4
14008	3025	1858	5
14009	3026	2014	5
14010	3026	2096	3
14011	3026	1816	3
14012	3026	2118	4
14013	3026	1907	3
14014	3027	2054	3
14015	3027	2034	9
14016	3027	2066	3
14017	3027	2035	1
14018	3027	2027	2
14019	3028	2089	3
14020	3028	2019	6
14021	3028	2063	8
14022	3028	2001	4
14023	3028	1895	5
14024	3029	2119	4
14025	3029	2120	7
14026	3029	2121	9
14027	3029	2122	4
14028	3029	1942	4
14029	3030	2123	4
14030	3030	2039	8
14031	3030	1883	6
14032	3030	2026	1
14033	3030	1942	1
14034	3031	2039	9
14035	3031	2106	3
14036	3031	2118	2
14037	3031	2035	4
14038	3031	1858	6
14039	3032	2042	3
14040	3032	2034	8
14041	3032	2124	1
14042	3032	1881	3
14043	3032	2027	8
14044	3033	1940	2
14045	3033	1970	6
14046	3033	2125	1
14047	3033	2118	9
14048	3033	1895	1
14049	3034	2049	6
14050	3034	1886	2
14051	3034	2037	8
14052	3034	2066	6
14053	3034	2126	3
14054	3034	1858	5
14055	3035	2049	5
14056	3035	2037	7
14057	3035	2066	9
14058	3035	2038	6
14059	3035	1858	8
14060	3036	2127	2
14061	3036	2114	5
14062	3036	2041	1
14063	3036	2031	1
14064	3036	2128	6
14065	3037	2054	4
14066	3037	2034	11
14067	3037	2066	8
14068	3037	2079	1
14069	3037	2027	7
14070	3038	2065	3
14071	3038	1989	2
14072	3038	2034	11
14073	3038	2035	1
14074	3038	2027	4
14075	3039	2129	1
14076	3039	2099	3
14077	3039	2130	9
14078	3039	2117	1
14079	3039	2031	7
14080	3040	2129	4
14081	3040	2099	4
14082	3040	2130	8
14083	3040	2131	3
14084	3040	2027	9
14085	3041	2132	2
14086	3041	2007	9
14087	3041	2090	8
14088	3041	2083	2
14089	3041	1858	5
14090	3042	2133	3
14091	3042	2029	2
14092	3042	1895	1
14093	3042	2128	4
14094	3042	1875	1
14095	3043	2123	2
14096	3043	2084	3
14097	3043	2039	4
14098	3043	2134	1
14099	3043	2031	1
14100	3044	2135	5
14101	3044	2039	2
14102	3044	2136	9
14103	3044	2027	1
14104	3044	1836	1
14105	3045	2137	4
14106	3045	2138	7
14107	3045	2007	8
14108	3045	2039	9
14109	3045	2031	5
14110	3046	2108	3
14111	3046	2130	9
14112	3046	1917	6
14113	3046	2111	4
14114	3046	2031	6
14115	3047	2139	5
14116	3047	1951	5
14117	3047	2029	7
14118	3047	2026	2
14119	3047	1858	2
14120	3048	2100	3
14121	3048	2140	2
14122	3048	2141	4
14123	3048	2142	2
14124	3048	2031	2
14125	3049	2143	5
14126	3049	2037	7
14127	3049	1917	6
14128	3049	2059	7
14129	3049	1858	12
14130	3050	2144	5
14131	3050	1970	4
14132	3050	1883	6
14133	3050	2026	1
14134	3050	1942	1
14135	3051	2045	4
14136	3051	2063	6
14137	3051	2046	3
14138	3051	2064	1
14139	3051	1907	5
14140	3052	2145	4
14141	3052	2039	8
14142	3052	2076	2
14143	3052	2001	1
14144	3052	2031	7
14145	3053	2146	3
14146	3053	2045	3
14147	3053	2063	7
14148	3053	2064	1
14149	3053	1907	3
14150	3054	2089	5
14151	3054	2068	6
14152	3054	2147	9
14153	3054	2026	1
14154	3054	1895	6
14155	3055	2056	4
14156	3055	2029	2
14157	3055	1853	2
14158	3055	1858	1
14159	3055	2148	2
14160	3056	2149	4
14161	3056	2150	3
14162	3056	2034	11
14163	3056	2035	1
14164	3056	1918	6
14165	3057	2151	5
14166	3057	2029	8
14167	3057	1853	6
14168	3057	1905	5
14169	3057	1942	5
14170	3058	2054	5
14171	3058	2034	11
14172	3058	2079	1
14173	3058	2027	4
14174	3058	1840	2
14175	3059	2054	5
14176	3059	2034	2
14177	3059	2066	4
14178	3059	2079	1
14179	3059	2027	1
14180	3060	2054	4
14181	3060	2034	8
14182	3060	2066	6
14183	3060	2035	2
14184	3060	2027	6
14185	3061	2065	4
14186	3061	2034	11
14187	3061	2066	7
14188	3061	2079	2
14189	3061	2027	4
14190	3062	2152	3
14191	3062	2153	2
14192	3062	2039	7
14193	3062	2154	4
14194	3062	2155	4
14195	3062	2031	2
14196	3063	2144	7
14197	3063	1990	8
14198	3063	1933	9
14199	3063	2026	4
14200	3063	1942	3
14201	3064	2143	5
14202	3064	2156	8
14203	3064	1853	6
14204	3064	2059	5
14205	3064	1942	8
14206	3065	2010	1
14207	3065	1970	11
14208	3065	1883	8
14209	3065	2157	9
14210	3065	1895	9
14211	3066	2054	6
14212	3066	2034	11
14213	3066	2079	2
14214	3066	2027	3
14215	3066	1840	4
14216	3067	2158	6
14217	3067	2034	13
14218	3067	1926	4
14219	3067	2159	5
14220	3067	1895	9
14221	3068	2010	1
14222	3068	1933	7
14223	3068	1883	8
14224	3068	2160	2
14225	3068	1942	5
14226	3069	2161	5
14227	3069	2063	6
14228	3069	2046	6
14229	3069	2059	4
14230	3069	1907	1
14231	3070	2127	2
14232	3070	2162	7
14233	3070	2163	2
14234	3070	2117	2
14235	3070	1858	3
14236	3071	2022	4
14237	3071	2068	5
14238	3071	2063	8
14239	3071	2026	3
14240	3071	1907	2
14241	3072	2010	3
14242	3072	1970	13
14243	3072	2157	8
14244	3072	1949	7
14245	3072	1942	7
14246	3073	2164	2
14247	3073	2039	8
14248	3073	2165	3
14249	3073	2031	2
14250	3073	1875	1
14251	3074	2166	5
14252	3074	2167	3
14253	3074	2090	11
14254	3074	2026	4
14255	3074	2031	11
14256	3075	2089	3
14257	3075	2096	8
14258	3075	2066	7
14259	3075	2168	4
14260	3075	1942	6
14261	3076	2032	3
14262	3076	2054	4
14263	3076	2034	11
14264	3076	2035	1
14265	3076	2027	5
14266	3077	2067	3
14267	3077	2068	6
14268	3077	2063	9
14269	3077	2041	1
14270	3077	2048	5
14271	3078	2084	5
14272	3078	2034	9
14273	3078	2169	3
14274	3078	1880	5
14275	3078	1895	4
14276	3079	2084	8
14277	3079	2114	8
14278	3079	2169	11
14279	3079	2170	4
14280	3079	1895	6
14281	3080	2171	1
14282	3080	2114	7
14283	3080	1957	1
14284	3080	1895	1
14285	3080	1836	1
14286	3081	2172	6
14287	3081	2173	5
14288	3081	2174	3
14289	3082	2175	5
14290	3083	2176	3
14291	3084	2177	4
14292	3084	2178	5
14293	3085	2176	11
14294	3086	2179	13
14295	3086	2180	4
14296	3087	2176	3
14297	3088	2176	1
14298	3089	2176	3
14299	3090	2181	3
14300	3090	2182	11
14301	3091	2172	4
14302	3091	2183	7
14303	3092	2184	7
14304	3092	2185	8
14305	3093	2186	4
14306	3094	2187	3
14307	3094	2188	11
14308	3095	2189	7
14309	3095	2174	3
14310	3096	2174	2
14311	3096	2190	13
14312	3097	2191	8
14313	3098	2192	2
14314	3098	2193	4
14315	3099	2194	5
14316	3099	2190	5
14317	3100	2195	11
14318	3100	2196	10
14319	3101	2197	7
14320	3101	2188	9
14321	3102	2190	11
14322	3103	2198	7
14323	3104	2190	4
14324	3105	2195	2
14325	3105	2188	9
14326	3106	2199	8
14327	3107	2200	8
14328	3108	2201	6
14329	3108	2186	4
14330	3109	2185	3
14331	3110	2202	5
14332	3110	2203	1
14333	3111	2204	11
14334	3111	2190	2
14335	3112	2204	3
14336	3113	2192	5
14337	3113	2204	3
14338	3114	2205	9
14339	3114	2178	5
14340	3115	2202	7
14341	3115	2200	8
14342	3116	2206	4
14343	3116	2204	5
14344	3117	2207	3
14345	3117	2193	3
14346	3118	2188	8
14347	3119	2200	4
14348	3119	2204	11
14349	3120	2190	11
14350	3121	2208	4
14351	3122	2204	11
14352	3122	2190	5
14353	3123	2186	2
14354	3123	2198	4
14355	3124	2186	5
14356	3124	2191	1
14357	3125	2209	5
14358	3126	2210	8
14359	3127	2211	8
14360	3127	2212	4
14361	3128	2213	7
14362	3129	2214	2
14363	3130	2191	6
14364	3131	2215	6
14365	3132	2216	5
14366	3133	2217	4
14367	3133	2218	2
14368	3134	2197	1
14369	3135	2219	4
14370	3136	2219	7
14371	3137	2220	3
14372	3137	2221	5
14373	3138	2222	1
14374	3138	2178	3
14375	3139	2223	1
14376	3140	2224	11
14377	3141	2204	11
14378	3141	2190	4
14379	3142	2225	5
14380	3143	2213	3
14381	3144	2226	2
14382	3145	2215	5
14383	3146	2204	2
14384	3146	2190	1
14385	3147	2227	8
14386	3148	2228	1
14387	3149	2226	1
14388	3150	2229	1
14389	3151	2198	9
14390	3152	2230	1
14391	3152	2231	3
14392	3153	2216	3
14393	3154	2191	8
14394	3155	2197	5
14395	3156	2229	2
14396	3157	2225	5
14397	3158	2232	5
14398	3159	2204	1
14399	3159	2190	1
14400	3160	2233	6
14401	3161	2232	1
14402	3162	2227	7
14403	3163	2216	4
14404	3164	2226	7
14405	3164	2234	2
14406	3165	2224	5
14407	3166	2233	5
14408	3167	2235	2
14409	3167	2236	3
14410	3168	2237	2
14411	3169	2197	5
14412	3170	2224	11
14413	3171	2191	9
14414	3172	2238	11
14415	3173	2219	4
14416	3174	2228	3
14417	3175	2239	9
14418	3176	2219	1
14419	3177	2240	6
14420	3178	2241	11
14421	3178	2242	5
14422	3178	2243	11
14423	3178	2244	6
14424	3178	2245	11
14425	3179	2246	14
14426	3179	2247	14
14427	3179	2248	7
14428	3179	2249	4
14429	3179	2245	10
14430	3180	2250	3
14431	3181	2248	6
14432	3181	2251	11
14433	3181	2252	5
14434	3181	2253	4
14435	3181	2254	13
14436	3182	2252	4
14437	3182	2250	3
14438	3182	2255	14
14439	3182	2256	6
14440	3182	2245	9
14441	3183	2257	4
14442	3183	2258	2
14443	3183	2241	11
14444	3183	2259	5
14445	3183	2260	4
14446	3183	2253	3
14447	3184	2261	11
14448	3184	2262	14
14449	3184	2263	9
14450	3184	2264	8
14451	3184	2265	8
14452	3184	2259	11
14453	3184	2266	9
14454	3185	2261	5
14455	3185	2267	14
14456	3185	2251	11
14457	3185	2268	8
14458	3185	2269	7
14459	3186	2248	6
14460	3186	2251	11
14461	3186	2252	6
14462	3186	2249	3
14463	3186	2270	9
14464	3186	2253	4
14465	3187	2271	14
14466	3187	2272	11
14467	3188	2273	7
14468	3188	2274	8
14469	3188	2253	3
14470	3188	2245	11
14471	3189	2271	14
14472	3189	2272	11
14473	3189	2275	11
14474	3189	2276	3
14475	3189	2260	6
14476	3189	2277	1
14477	3189	2278	9
14478	3190	2279	2
14479	3190	2280	7
14480	3190	2248	8
14481	3190	2268	8
14482	3190	2265	2
14483	3190	2281	7
14484	3191	2282	5
14485	3191	2283	2
14486	3191	2284	10
14487	3191	2285	3
14488	3191	2286	13
14489	3191	2254	8
14490	3192	2287	9
14491	3192	2288	6
14492	3192	2259	6
14493	3192	2289	5
14494	3192	2250	7
14495	3192	2290	11
14496	3193	2263	3
14497	3193	2251	8
14498	3193	2291	6
14499	3193	2242	4
14500	3193	2252	8
14501	3193	2249	1
14502	3194	2292	3
14503	3194	2261	11
14504	3194	2262	14
14505	3194	2264	8
14506	3194	2243	11
14507	3194	2254	11
14508	3195	2263	7
14509	3195	2264	9
14510	3195	2281	6
14511	3195	2289	4
14512	3195	2245	9
14513	3196	2293	11
14514	3196	2294	2
14515	3196	2271	14
14516	3196	2272	11
14517	3196	2286	6
14518	3196	2244	12
14519	3196	2254	8
14520	3197	2263	6
14521	3197	2268	11
14522	3197	2281	6
14523	3197	2289	6
14524	3197	2254	9
14525	3198	2295	14
14526	3198	2272	5
14527	3198	2263	5
14528	3198	2251	2
14529	3198	2252	6
14530	3198	2289	13
14531	3198	2250	7
14532	3199	2261	11
14533	3199	2267	14
14534	3199	2248	9
14535	3199	2275	11
14536	3199	2252	8
14537	3199	2289	4
14538	3199	2296	2
14539	3199	2278	6
14540	3200	2263	5
14541	3200	2251	3
14542	3200	2291	6
14543	3200	2242	4
14544	3200	2252	2
14545	3200	2249	5
14546	3200	2289	5
14547	3201	2297	5
14548	3201	2298	11
14549	3201	2299	8
14550	3201	2289	13
14551	3201	2244	5
14552	3201	2245	11
14553	3202	2300	6
14554	3202	2287	11
14555	3202	2286	9
14556	3202	2243	8
14557	3202	2270	9
14558	3202	2301	3
14559	3203	2302	9
14560	3203	2303	3
14561	3203	2304	2
14562	3203	2260	2
14563	3204	2305	4
14564	3204	2306	9
14565	3204	2307	8
14566	3204	2308	4
14567	3204	2304	7
14568	3204	2309	9
14569	3205	2310	4
14570	3205	2311	9
14571	3205	2312	7
14572	3205	2309	12
14573	3205	2313	5
14574	3205	2245	8
14575	3206	2314	6
14576	3206	2315	5
14577	3206	2316	3
14578	3206	2285	5
14579	3206	2309	6
14580	3206	2254	8
14581	3207	2317	8
14582	3207	2318	9
14583	3207	2319	9
14584	3207	2309	9
14585	3208	2320	4
14586	3208	2264	2
14587	3208	2281	2
14588	3208	2243	5
14589	3208	2289	3
14590	3208	2321	2
14591	3209	2322	4
14592	3209	2323	5
14593	3209	2264	11
14594	3209	2324	8
14595	3210	941	6
14596	3210	942	7
14597	3210	943	7
14598	3210	944	6
14599	3210	99	4
14600	3210	100	3
14601	3210	945	1
14602	3211	102	4
14603	3211	946	5
14604	3211	947	6
14605	3211	948	4
14606	3211	106	3
14607	3212	949	10
14608	3212	950	11
14609	3212	951	9
14610	3212	110	8
14611	3212	111	11
14612	3213	952	3
14613	3213	953	9
14614	3214	114	7
14615	3214	954	9
14616	3214	955	13
14617	3214	117	10
14618	3214	118	6
14619	3215	956	13
14620	3215	957	9
14621	3215	121	11
14622	3215	122	11
14623	3215	123	9
14624	3215	958	11
14625	3216	125	6
14626	3216	126	5
14627	3217	127	9
14628	3217	128	6
14629	3217	129	11
14630	3217	959	9
14631	3217	960	5
14632	3218	132	6
14633	3218	961	9
14634	3218	962	6
14635	3218	135	8
14636	3218	136	3
14637	3219	137	7
14638	3219	963	6
14639	3219	964	5
14640	3219	140	6
14641	3219	141	6
14642	3220	142	9
14643	3220	143	8
14644	3220	144	10
14645	3221	145	5
14646	3221	965	9
14647	3221	966	7
14648	3221	967	7
14649	3221	149	11
14650	3222	150	7
14651	3222	968	9
14652	3222	969	3
14653	3222	153	6
14654	3222	154	9
14655	3223	970	14
14656	3223	157	9
14657	3223	158	10
14658	3223	159	5
14659	3223	971	14
14660	3224	972	7
14661	3224	162	14
14662	3224	973	9
14663	3224	974	14
14664	3224	975	5
14665	3224	166	5
14666	3225	167	9
14667	3225	976	8
14668	3225	977	9
14669	3225	978	4
14670	3225	171	7
14671	3226	172	12
14672	3226	979	7
14673	3226	174	5
14674	3226	175	9
14675	3226	980	14
14676	3227	177	14
14677	3227	981	9
14678	3227	179	6
14679	3227	982	6
14680	3227	181	12
14681	3228	182	12
14682	3229	183	5
14683	3229	184	4
14684	3229	983	13
14685	3229	984	4
14686	3229	187	9
14687	3229	188	9
14688	3230	985	11
14689	3230	986	9
14690	3230	987	11
14691	3230	988	11
14692	3230	193	11
14693	3231	194	13
14694	3231	989	9
14695	3231	196	9
14696	3231	990	9
14697	3231	198	5
14698	3232	991	9
14699	3232	992	6
14700	3232	993	4
14701	3232	994	2
14702	3232	203	2
14703	3233	995	6
14704	3234	996	8
14705	3235	206	5
14706	3235	997	5
14707	3236	998	10
14708	3237	209	4
14709	3237	999	9
14710	3237	211	8
14711	3237	212	11
14712	3237	213	8
14713	3237	1000	9
14714	3238	215	9
14715	3238	216	4
14716	3238	1001	9
14717	3238	1002	11
14718	3238	219	9
14719	3238	213	11
14720	3239	220	12
14721	3239	1003	7
14722	3239	1004	11
14723	3239	1005	13
14724	3239	224	6
14725	3240	225	12
14726	3240	1006	6
14727	3240	1007	7
14728	3240	228	7
14729	3240	229	7
14730	3241	230	4
14731	3241	1008	7
14732	3241	232	1
14733	3241	1009	4
14734	3241	234	1
14735	3242	1010	7
14736	3242	1011	4
14737	3242	237	8
14738	3242	238	1
14739	3242	239	7
14740	3242	240	9
14741	3243	241	12
14742	3243	242	4
14743	3243	1012	5
14744	3243	237	11
14745	3243	239	8
14746	3243	240	9
14747	3244	244	11
14748	3244	245	11
14749	3244	1013	11
14750	3244	1014	11
14751	3244	1015	9
14752	3244	249	11
14753	3245	250	5
14754	3245	1016	11
14755	3245	1017	11
14756	3245	1018	9
14757	3245	249	11
14758	3246	254	9
14759	3246	1019	6
14760	3246	1020	13
14761	3246	1021	5
14762	3246	258	2
14763	3247	259	4
14764	3247	1022	7
14765	3248	261	2
14766	3248	1023	4
14767	3249	1024	14
14768	3250	1025	6
14769	3251	1026	13
14770	3252	1027	6
14771	3252	267	9
14772	3252	268	9
14773	3252	1028	6
14774	3252	270	2
14775	3252	271	5
14776	3252	272	6
14777	3253	1029	11
14778	3253	274	5
14779	3253	268	5
14780	3253	275	6
14781	3253	276	6
14782	3253	1030	9
14783	3254	1031	6
14784	3254	279	5
14785	3254	1032	11
14786	3254	1033	11
14787	3254	1034	3
14788	3254	283	9
14789	3255	284	8
14790	3255	1035	11
14791	3255	1036	6
14792	3255	287	12
14793	3255	283	9
14794	3255	1030	7
14795	3256	288	4
14796	3256	1037	8
14797	3256	1038	7
14798	3256	287	1
14799	3256	291	7
14800	3257	292	7
14801	3257	293	5
14802	3257	1039	4
14803	3257	1040	3
14804	3257	296	4
14805	3258	297	6
14806	3258	298	4
14807	3258	1041	4
14808	3258	1042	8
14809	3258	301	2
14810	3259	302	3
14811	3259	1043	14
14812	3259	1044	9
14813	3259	305	9
14814	3259	306	12
14815	3259	307	7
14816	3259	308	2
14817	3260	309	8
14818	3260	310	5
14819	3260	1045	9
14820	3260	306	6
14821	3260	312	6
14822	3260	313	2
14823	3260	314	3
14824	3261	1046	6
14825	3261	1047	5
14826	3261	317	5
14827	3261	1048	10
14828	3261	1049	8
14829	3261	1050	7
14830	3262	321	12
14831	3262	1051	10
14832	3262	1052	4
14833	3262	1053	9
14834	3262	1054	6
14835	3262	326	5
14836	3263	327	13
14837	3263	1055	11
14838	3263	329	9
14839	3263	1056	6
14840	3263	331	4
14841	3264	309	8
14842	3264	1057	7
14843	3264	1058	5
14844	3264	1059	4
14845	3264	335	1
14846	3265	1060	1
14847	3265	337	2
14848	3266	1061	5
14849	3267	1062	6
14850	3268	340	3
14851	3268	1063	6
14852	3269	1064	14
14853	3269	1065	8
14854	3269	344	10
14855	3269	345	6
14856	3270	1066	2
14857	3270	1067	3
14858	3270	1064	5
14859	3270	1068	5
14860	3270	349	5
14861	3270	350	6
14862	3270	351	1
14863	3271	352	11
14864	3271	1069	11
14865	3271	1070	8
14866	3271	1071	13
14867	3271	356	9
14868	3272	357	4
14869	3272	1072	8
14870	3272	359	6
14871	3272	360	9
14872	3272	361	3
14873	3273	362	5
14874	3273	363	5
14875	3273	1073	9
14876	3273	1074	2
14877	3273	366	5
14878	3274	367	3
14879	3274	1075	11
14880	3274	369	2
14881	3274	1076	3
14882	3274	371	5
14883	3275	372	2
14884	3275	1077	8
14885	3275	374	1
14886	3275	1078	3
14887	3275	371	6
14888	3276	367	4
14889	3276	1077	9
14890	3276	376	1
14891	3276	1079	7
14892	3276	378	7
14893	3277	379	5
14894	3277	1080	10
14895	3277	1081	5
14896	3277	1082	5
14897	3277	378	1
14898	3278	383	7
14899	3278	1083	9
14900	3278	385	6
14901	3278	1084	3
14902	3278	387	2
14903	3279	1085	14
14904	3279	1086	14
14905	3279	390	9
14906	3280	391	4
14907	3280	392	7
14908	3280	1087	8
14909	3280	394	4
14910	3280	395	12
14911	3281	1088	2
14912	3281	1085	14
14913	3281	1089	8
14914	3281	398	1
14915	3281	399	2
14916	3281	400	4
14917	3281	401	1
14918	3282	402	13
14919	3282	1090	9
14920	3282	1091	11
14921	3282	1092	9
14922	3282	406	9
14923	3283	1093	8
14924	3283	408	6
14925	3283	1094	9
14926	3283	1095	3
14927	3283	398	6
14928	3283	411	5
14929	3284	412	6
14930	3284	1096	11
14931	3284	1097	4
14932	3284	1098	4
14933	3284	416	6
14934	3285	417	8
14935	3285	418	4
14936	3285	1099	8
14937	3285	1100	5
14938	3285	421	8
14939	3286	422	5
14940	3286	423	3
14941	3286	424	3
14942	3286	1101	9
14943	3286	426	4
14944	3287	427	3
14945	3287	1102	9
14946	3287	1103	6
14947	3287	1104	4
14948	3287	426	5
14949	3288	431	5
14950	3288	1105	5
14951	3288	1106	4
14952	3288	1107	7
14953	3288	421	2
14954	3289	1108	9
14955	3289	1109	3
14956	3289	1110	2
14957	3289	1104	4
14958	3289	426	3
14959	3290	438	14
14960	3291	1111	9
14961	3292	1112	4
14962	3293	1113	9
14963	3294	1114	8
14964	3295	1115	7
14965	3296	1116	8
14966	3297	445	2
14967	3297	1117	4
14968	3298	1118	14
14969	3298	1119	4
14970	3298	449	7
14971	3298	450	11
14972	3298	451	8
14973	3298	452	12
14974	3298	453	11
14975	3298	454	1
14976	3299	455	8
14977	3299	456	11
14978	3299	451	8
14979	3299	457	12
14980	3299	458	2
14981	3299	459	5
14982	3299	460	14
14983	3299	1120	4
14984	3300	1121	9
14985	3300	1122	9
14986	3300	1118	14
14987	3300	1119	5
14988	3300	464	9
14989	3300	452	8
14990	3300	453	7
14991	3301	1118	14
14992	3301	1119	3
14993	3301	465	2
14994	3301	450	9
14995	3301	466	9
14996	3301	467	9
14997	3301	1120	8
14998	3302	468	3
14999	3302	1123	7
15000	3302	1124	11
15001	3302	471	7
15002	3303	1125	7
15003	3303	1126	7
15004	3303	1127	1
15005	3303	1128	2
15006	3303	476	7
15007	3304	477	5
15008	3304	1129	9
15009	3304	1130	2
15010	3304	1131	4
15011	3304	481	5
15012	3305	1132	4
15013	3305	1133	8
15014	3305	1134	1
15015	3305	476	8
15016	3306	1135	6
15017	3306	1136	8
15018	3306	1137	2
15019	3306	488	9
15020	3307	489	4
15021	3307	1138	4
15022	3307	1139	9
15023	3307	492	13
15024	3308	493	6
15025	3308	494	9
15026	3308	1140	6
15027	3308	1141	6
15028	3308	476	4
15029	3309	497	3
15030	3309	1142	8
15031	3309	1126	9
15032	3309	499	2
15033	3309	481	8
15034	3310	500	5
15035	3310	1143	7
15036	3310	502	1
15037	3310	1130	2
15038	3310	503	2
15039	3311	504	1
15040	3311	505	5
15041	3311	1144	3
15042	3311	1145	11
15043	3311	508	2
15044	3312	504	1
15045	3312	505	5
15046	3312	1144	3
15047	3312	1145	11
15048	3312	508	2
15049	3313	509	4
15050	3313	505	7
15051	3313	1146	11
15052	3313	1147	10
15053	3313	512	5
15054	3314	504	1
15055	3314	505	5
15056	3314	1144	9
15057	3314	1145	8
15058	3314	508	4
15059	3315	513	12
15060	3315	514	7
15061	3315	1146	7
15062	3315	1148	11
15063	3315	512	2
15064	3316	504	1
15065	3316	505	4
15066	3316	1144	8
15067	3316	1145	6
15068	3316	508	3
15069	3317	504	2
15070	3317	505	7
15071	3317	1144	1
15072	3317	1145	5
15073	3317	508	1
15074	3318	516	7
15075	3318	1149	9
15076	3318	1150	3
15077	3318	519	3
15078	3318	492	5
15079	3319	504	1
15080	3319	505	6
15081	3319	1144	3
15082	3319	1145	8
15083	3319	508	3
15084	3320	516	4
15085	3320	1149	6
15086	3320	520	6
15087	3320	1151	1
15088	3320	492	1
15089	3321	1152	9
15090	3322	1153	11
15091	3322	1154	6
15092	3322	525	5
15093	3322	526	2
15094	3322	527	12
15095	3322	528	6
15096	3323	529	4
15097	3323	1155	3
15098	3323	531	4
15099	3323	1156	8
15100	3323	1157	5
15101	3323	1158	12
15102	3323	535	12
15103	3324	536	11
15104	3324	1159	5
15105	3324	1160	10
15106	3324	539	11
15107	3324	540	9
15108	3324	541	12
15109	3324	542	11
15110	3325	543	13
15111	3325	1161	6
15112	3325	1162	5
15113	3325	540	2
15114	3325	546	2
15115	3325	542	5
15116	3326	547	9
15117	3326	1163	13
15118	3326	1164	5
15119	3326	550	13
15120	3326	551	7
15121	3327	1165	13
15122	3327	1166	3
15123	3327	1167	7
15124	3327	555	7
15125	3327	1168	3
15126	3327	550	8
15127	3328	557	9
15128	3328	1169	11
15129	3328	1166	8
15130	3328	1170	9
15131	3328	560	11
15132	3328	1171	2
15133	3329	562	4
15134	3329	1166	6
15135	3329	1172	11
15136	3329	1173	9
15137	3329	1174	5
15138	3329	566	11
15139	3330	567	9
15140	3330	568	8
15141	3330	1175	11
15142	3330	1173	10
15143	3330	570	11
15144	3331	571	12
15145	3331	1176	6
15146	3331	1177	8
15147	3331	1178	10
15148	3331	575	7
15149	3331	576	6
15150	3332	577	6
15151	3332	557	8
15152	3332	1179	9
15153	3332	1166	4
15154	3332	1178	13
15155	3332	566	8
15156	3333	1180	2
15157	3333	1172	11
15158	3333	1181	9
15159	3333	1167	11
15160	3333	566	11
15161	3334	581	5
15162	3334	1182	11
15163	3334	583	2
15164	3334	1183	3
15165	3334	585	4
15166	3335	1184	7
15167	3335	1185	9
15168	3335	583	4
15169	3335	1186	5
15170	3335	585	3
15171	3336	1187	8
15172	3336	1185	9
15173	3336	583	5
15174	3336	1186	6
15175	3336	585	7
15176	3337	590	4
15177	3337	1188	8
15178	3337	536	8
15179	3337	1189	7
15180	3337	593	6
15181	3338	1190	4
15182	3338	1191	9
15183	3338	583	6
15184	3338	1192	1
15185	3338	585	9
15186	3339	597	13
15187	3339	1193	11
15188	3339	599	5
15189	3339	1194	6
15190	3339	601	3
15191	3340	602	4
15192	3340	1195	11
15193	3340	555	8
15194	3340	1196	5
15195	3340	585	5
15196	3341	1184	5
15197	3341	1185	5
15198	3341	583	5
15199	3341	1186	6
15200	3341	585	2
15201	3342	605	4
15202	3342	606	4
15203	3342	1197	7
15204	3342	1198	2
15205	3342	609	1
15206	3343	610	3
15207	3343	611	3
15208	3343	1185	7
15209	3343	1199	3
15210	3343	570	3
15211	3344	613	1
15212	3344	1200	7
15213	3344	615	4
15214	3344	1201	2
15215	3344	601	2
15216	3345	617	3
15217	3346	618	12
15218	3347	1202	3
15219	3347	1203	9
15220	3348	1204	4
15221	3349	1205	5
15222	3350	623	6
15223	3350	624	5
15224	3351	1203	11
15225	3352	1206	4
15226	3352	1207	6
15227	3353	1208	4
15228	3354	1209	3
15229	3355	1210	9
15230	3356	1211	3
15231	3357	1212	5
15232	3358	1213	6
15233	3358	633	11
15234	3358	634	7
15235	3358	635	8
15236	3358	636	2
15237	3358	637	9
15238	3359	1214	13
15239	3359	1215	14
15240	3359	640	13
15241	3359	2325	14
15242	3359	641	9
15243	3359	642	9
15244	3359	1216	11
15245	3360	644	4
15246	3360	1217	6
15247	3360	646	1
15248	3360	647	4
15249	3360	648	1
15250	3361	1218	6
15251	3361	1219	3
15252	3361	1220	11
15253	3361	652	6
15254	3361	1221	7
15255	3362	654	5
15256	3362	1222	7
15257	3362	634	6
15258	3362	656	3
15259	3362	657	3
15260	3363	658	2
15261	3363	1223	9
15262	3363	1224	11
15263	3363	661	5
15264	3363	1225	6
15265	3364	1226	7
15266	3364	664	11
15267	3364	661	3
15268	3364	665	2
15269	3364	1225	8
15270	3365	1227	8
15271	3365	1228	7
15272	3365	1229	5
15273	3365	669	2
15274	3366	670	5
15275	3366	1230	4
15276	3366	1224	8
15277	3366	669	4
15278	3366	672	11
15279	3366	1225	6
15280	3367	1231	7
15281	3367	672	11
15282	3367	640	7
15283	3367	661	7
15284	3367	674	7
15285	3367	635	6
15286	3368	1232	3
15287	3368	1226	8
15288	3368	672	8
15289	3368	661	4
15290	3368	665	2
15291	3369	676	12
15292	3369	1233	9
15293	3369	1234	7
15294	3369	1235	6
15295	3369	680	2
15296	3370	681	2
15297	3370	682	4
15298	3370	1236	7
15299	3370	684	2
15300	3370	1237	7
15301	3371	1238	8
15302	3371	1235	5
15303	3371	1239	4
15304	3371	1240	4
15305	3371	680	3
15306	3372	689	9
15307	3372	1238	9
15308	3372	1235	6
15309	3372	1241	8
15310	3372	691	13
15311	3373	692	6
15312	3373	693	9
15313	3373	1235	9
15314	3373	1242	4
15315	3373	680	7
15316	3374	695	4
15317	3374	1243	9
15318	3374	1244	9
15319	3374	680	8
15320	3375	698	6
15321	3375	1233	10
15322	3375	1235	11
15323	3375	1245	6
15324	3376	700	3
15325	3376	1246	2
15326	3376	1243	9
15327	3376	1244	7
15328	3376	680	6
15329	3377	702	5
15330	3377	1247	7
15331	3377	1248	7
15332	3377	1235	6
15333	3377	680	7
15334	3378	705	5
15335	3378	1249	11
15336	3378	1244	9
15337	3378	1250	6
15338	3378	680	1
15339	3379	1251	8
15340	3379	1234	6
15341	3379	1244	6
15342	3379	709	9
15343	3379	710	8
15344	3380	711	3
15345	3380	1252	7
15346	3380	1253	7
15347	3380	1254	6
15348	3380	691	2
15349	3381	715	3
15350	3381	716	6
15351	3381	1255	9
15352	3381	1256	2
15353	3381	719	3
15354	3382	720	4
15355	3382	1257	7
15356	3382	722	2
15357	3382	1258	5
15358	3382	684	1
15359	3383	724	4
15360	3383	682	6
15361	3383	1259	6
15362	3383	1260	7
15363	3383	727	6
15364	3384	728	2
15365	3384	1261	9
15366	3384	730	3
15367	3384	1262	3
15368	3384	732	6
15369	3385	733	7
15370	3385	734	6
15371	3385	1263	8
15372	3385	1264	11
15373	3385	727	6
15374	3386	715	3
15375	3386	716	9
15376	3386	1255	5
15377	3386	1256	9
15378	3386	719	8
15379	3387	737	6
15380	3387	1265	6
15381	3387	739	4
15382	3387	1266	2
15383	3387	727	6
15384	3388	741	7
15385	3388	682	5
15386	3388	1263	5
15387	3388	1267	9
15388	3388	727	1
15389	3389	715	3
15390	3389	716	7
15391	3389	1255	6
15392	3389	1256	3
15393	3389	719	6
15394	3390	743	8
15395	3390	716	8
15396	3390	1265	8
15397	3390	1256	9
15398	3390	719	9
15399	3391	744	4
15400	3391	1261	6
15401	3391	1268	5
15402	3391	746	4
15403	3391	732	5
15404	3392	747	8
15405	3392	1269	11
15406	3392	749	3
15407	3392	1270	8
15408	3392	751	7
15409	3393	752	6
15410	3393	1261	9
15411	3393	753	5
15412	3393	1271	10
15413	3393	732	7
15414	3394	715	4
15415	3394	716	6
15416	3394	1255	8
15417	3394	1256	3
15418	3394	719	6
15419	3395	755	6
15420	3395	1265	5
15421	3395	756	5
15422	3395	1272	4
15423	3395	758	1
15424	3396	759	4
15425	3396	1273	6
15426	3396	730	4
15427	3396	1274	2
15428	3396	684	1
15429	3397	762	6
15430	3397	1275	7
15431	3397	764	6
15432	3397	1276	2
15433	3397	727	6
15434	3398	1277	5
15435	3398	693	4
15436	3398	1257	7
15437	3398	767	7
15438	3398	751	1
15439	3399	768	3
15440	3399	769	9
15441	3399	1278	8
15442	3399	1279	4
15443	3399	684	1
15444	3400	772	6
15445	3400	1280	5
15446	3400	774	4
15447	3400	1281	6
15448	3400	727	5
15449	3401	776	5
15450	3401	1282	11
15451	3401	778	4
15452	3401	1283	12
15453	3401	727	5
15454	3402	755	7
15455	3402	1265	8
15456	3402	756	7
15457	3402	1272	3
15458	3402	758	4
15459	3403	780	6
15460	3403	769	10
15461	3403	1284	8
15462	3403	1279	3
15463	3403	684	11
15464	3404	762	5
15465	3404	1275	8
15466	3404	764	5
15467	3404	1276	1
15468	3404	751	5
15469	3405	755	6
15470	3405	1265	4
15471	3405	756	8
15472	3405	1272	4
15473	3405	758	1
15474	3406	782	4
15475	3406	1261	7
15476	3406	767	4
15477	3406	1285	8
15478	3406	732	6
15479	3407	784	7
15480	3407	1286	9
15481	3407	753	5
15482	3407	1266	2
15483	3407	751	6
15484	3408	786	4
15485	3408	1261	8
15486	3408	767	5
15487	3408	1285	9
15488	3408	732	8
15489	3409	787	3
15490	3409	1261	4
15491	3409	1287	9
15492	3409	1288	4
15493	3409	732	3
15494	3410	1289	12
15495	3410	1261	1
15496	3410	791	8
15497	3410	1285	7
15498	3410	732	5
15499	3411	755	4
15500	3411	1265	9
15501	3411	756	9
15502	3411	1272	4
15503	3411	758	5
15504	3412	792	1
15505	3412	793	3
15506	3412	1290	8
15507	3412	1291	3
15508	3412	796	4
15509	3413	797	5
15510	3413	798	5
15511	3413	1292	2
15512	3413	1293	7
15513	3413	796	5
15514	3414	801	1
15515	3414	802	2
15516	3414	1290	11
15517	3414	1294	1
15518	3414	796	11
15519	3415	1295	8
15520	3415	805	12
15521	3415	1296	8
15522	3415	1297	10
15523	3415	1298	7
15524	3416	809	5
15525	3416	1299	6
15526	3416	811	12
15527	3416	812	3
15528	3416	813	12
15529	3416	1300	3
15530	3417	1295	6
15531	3417	1301	14
15532	3417	816	4
15533	3417	817	7
15534	3417	811	9
15535	3417	818	12
15536	3417	819	11
15537	3418	820	7
15538	3418	821	5
15539	3418	1302	2
15540	3418	1303	2
15541	3418	818	3
15542	3418	824	12
15543	3418	1304	7
15544	3419	1296	7
15545	3419	1305	8
15546	3419	827	5
15547	3419	828	8
15548	3419	1306	6
15549	3420	1307	2
15550	3420	1308	11
15551	3420	832	6
15552	3420	828	8
15553	3420	833	6
15554	3420	834	2
15555	3421	1309	7
15556	3421	1310	8
15557	3421	827	7
15558	3421	832	7
15559	3421	837	9
15560	3422	838	6
15561	3422	839	6
15562	3422	1311	11
15563	3422	841	8
15564	3422	842	12
15565	3422	843	5
15566	3423	844	9
15567	3423	1312	13
15568	3423	1313	7
15569	3423	1314	7
15570	3423	848	3
15571	3423	849	6
15572	3424	848	5
15573	3424	1315	11
15574	3424	827	1
15575	3424	842	7
15576	3424	849	5
15577	3425	851	4
15578	3425	817	12
15579	3425	837	5
15580	3425	812	6
15581	3425	852	3
15582	3425	853	12
15583	3425	1316	11
15584	3426	1308	11
15585	3426	855	8
15586	3426	817	5
15587	3426	828	9
15588	3426	1317	5
15589	3427	857	12
15590	3427	1318	11
15591	3427	1319	8
15592	3427	1320	1
15593	3427	855	7
15594	3427	861	5
15595	3428	862	8
15596	3428	1321	7
15597	3428	1322	9
15598	3428	1323	6
15599	3428	866	7
15600	3429	1296	7
15601	3429	1314	8
15602	3429	1324	6
15603	3429	868	3
15604	3429	1325	6
15605	3429	827	8
15606	3430	1326	10
15607	3430	1324	8
15608	3430	1327	5
15609	3430	827	11
15610	3430	849	9
15611	3431	872	8
15612	3431	1328	13
15613	3431	1329	13
15614	3431	1330	6
15615	3431	827	9
15616	3432	876	2
15617	3432	1331	9
15618	3432	1296	8
15619	3432	1332	9
15620	3432	1333	6
15621	3432	880	13
15622	3433	881	6
15623	3433	1334	4
15624	3433	1335	7
15625	3433	1336	5
15626	3433	841	3
15627	3434	1337	4
15628	3434	1313	9
15629	3434	1338	11
15630	3434	855	13
15631	3434	887	12
15632	3435	1313	6
15633	3435	1339	11
15634	3435	1340	9
15635	3435	1341	5
15636	3435	880	7
15637	3436	1342	5
15638	3436	1343	9
15639	3436	1334	11
15640	3436	1324	11
15641	3436	827	5
15642	3437	893	4
15643	3437	1344	5
15644	3437	1345	9
15645	3437	1346	1
15646	3437	841	13
15647	3437	1316	8
15648	3438	897	3
15649	3438	1347	9
15650	3438	1348	5
15651	3438	1349	5
15652	3438	901	6
15653	3439	902	2
15654	3439	1296	6
15655	3439	1339	8
15656	3439	1350	6
15657	3439	827	9
15658	3439	1351	3
15659	3440	905	4
15660	3440	906	5
15661	3440	1352	6
15662	3440	1353	7
15663	3440	909	3
15664	3441	910	4
15665	3441	1354	5
15666	3441	912	2
15667	3441	1355	3
15668	3441	914	2
15669	3442	1356	6
15670	3442	1357	9
15671	3442	917	6
15672	3442	1358	9
15673	3442	919	6
15674	3443	920	2
15675	3443	1359	11
15676	3443	839	8
15677	3443	1360	1
15678	3443	866	5
15679	3444	923	5
15680	3444	924	7
15681	3444	1361	8
15682	3444	1362	4
15683	3444	914	7
15684	3445	927	7
15685	3445	1363	5
15686	3445	1352	10
15687	3445	1364	2
15688	3445	930	9
15689	3446	931	12
15690	3446	1365	9
15691	3446	933	2
15692	3446	934	3
15693	3446	1298	3
15694	3447	935	5
15695	3447	1366	6
15696	3447	937	7
15697	3447	1367	5
15698	3447	930	1
15699	3448	939	5
15700	3448	905	4
15701	3448	1357	8
15702	3448	1368	2
15703	3448	930	7
15704	3449	1369	9
15705	3449	1366	7
15706	3449	1370	8
15707	3449	1371	13
15708	3449	1372	9
15709	3450	1373	4
15710	3450	1347	6
15711	3450	839	7
15712	3450	1374	8
15713	3450	866	5
15714	3451	1375	3
15715	3451	1376	8
15716	3451	1299	6
15717	3451	1320	2
15718	3451	919	10
15719	3452	1373	5
15720	3452	1377	10
15721	3452	1378	11
15722	3452	1379	8
15723	3452	866	5
15724	3453	1380	6
15725	3453	1352	7
15726	3453	1381	2
15727	3453	1346	3
15728	3453	930	6
15729	3454	1382	8
15730	3454	1383	3
15731	3454	1384	8
15732	3454	1385	5
15733	3454	914	1
15734	3455	1386	2
15735	3455	1387	6
15736	3455	1358	4
15737	3455	1388	4
15738	3455	1372	6
15739	3456	1389	5
15740	3456	1390	8
15741	3456	1391	7
15742	3456	1364	2
15743	3456	914	3
15744	3457	1392	8
15745	3457	1361	9
15746	3457	1393	5
15747	3457	1394	2
15748	3457	866	4
15749	3458	1395	7
15750	3458	1396	11
15751	3458	1397	6
15752	3458	816	6
15753	3458	1388	8
15754	3459	1398	8
15755	3459	1399	10
15756	3459	1366	3
15757	3459	1400	2
15758	3459	1401	6
15759	3459	1388	8
15760	3460	1402	2
15761	3460	1403	7
15762	3460	1404	5
15763	3460	1348	4
15764	3460	919	3
15765	3461	1405	5
15766	3461	1383	3
15767	3461	1387	8
15768	3461	1406	6
15769	3461	866	7
15770	3462	1407	4
15771	3462	1408	13
15772	3462	1404	4
15773	3462	1409	1
15774	3462	909	2
15775	3463	1389	5
15776	3463	1410	9
15777	3463	1391	7
15778	3463	1364	2
15779	3463	934	9
15780	3464	1411	4
15781	3464	1383	4
15782	3464	1359	9
15783	3464	1412	5
15784	3464	914	1
15785	3465	1413	2
15786	3465	1414	6
15787	3465	1415	4
15788	3465	816	6
15789	3465	866	5
15790	3466	1416	3
15791	3466	1417	9
15792	3466	1418	4
15793	3466	1406	4
15794	3466	934	6
15795	3467	1419	5
15796	3467	1377	9
15797	3467	1378	8
15798	3467	1420	7
15799	3467	866	7
15800	3468	1421	4
15801	3468	1390	3
15802	3468	839	8
15803	3468	1394	5
15804	3468	919	3
15805	3469	1422	7
15806	3469	1352	6
15807	3469	917	7
15808	3469	1423	12
15809	3469	866	9
15810	3470	1424	3
15811	3470	1425	4
15812	3470	1426	11
15813	3470	1427	7
15814	3470	930	8
15815	3471	935	5
15816	3471	1352	7
15817	3471	1412	7
15818	3471	1428	5
15819	3471	1388	8
15820	3472	902	3
15821	3472	1408	7
15822	3472	1429	11
15823	3472	1430	2
15824	3472	914	4
15825	3473	1431	2
15826	3473	1432	8
15827	3473	1433	4
15828	3473	1434	5
15829	3473	901	8
15830	3474	1435	8
15831	3475	1436	4
15832	3475	1437	6
15833	3476	1438	2
15834	3477	1439	2
15835	3478	1440	4
15836	3479	1441	3
15837	3479	1442	5
15838	3479	1443	9
15839	3480	1444	3
15840	3480	1445	6
15841	3481	1446	6
15842	3482	1447	8
15843	3483	1448	8
15844	3484	1449	1
15845	3485	1450	9
15846	3486	1451	11
15847	3486	1445	7
15848	3487	1452	6
15849	3487	1453	8
15850	3488	1454	9
15851	3489	1455	8
15852	3490	1456	4
15853	3490	1457	2
15854	3491	1458	9
15855	3492	1459	9
15856	3493	1460	8
15857	3494	1461	2
15858	3494	1462	1
15859	3495	1463	3
15860	3496	1464	6
15861	3497	1465	11
15862	3498	1466	9
15863	3498	1467	6
15864	3499	1468	9
15865	3500	1469	3
15866	3500	1457	3
15867	3501	1470	3
15868	3501	1471	4
15869	3502	1465	11
15870	3503	1454	5
15871	3504	1463	9
15872	3505	1472	6
15873	3505	1458	7
15874	3506	1473	1
15875	3507	1474	8
15876	3508	1475	4
15877	3509	1476	12
15878	3509	1477	9
15879	3509	1478	11
15880	3509	1479	11
15881	3509	1480	11
15882	3510	1481	7
15883	3511	1482	13
15884	3511	1483	4
15885	3511	1484	11
15886	3511	1485	9
15887	3511	1477	5
15888	3511	1486	5
15889	3511	1487	2
15890	3512	1488	6
15891	3512	1489	4
15892	3512	1487	12
15893	3513	1490	5
15894	3513	1491	5
15895	3513	1492	14
15896	3513	1477	5
15897	3513	1493	4
15898	3513	1494	4
15899	3513	1495	13
15900	3514	1496	11
15901	3514	1497	9
15902	3514	1486	11
15903	3514	1498	2
15904	3514	1499	12
15905	3515	1483	2
15906	3515	1500	4
15907	3515	1501	13
15908	3515	1502	11
15909	3515	1503	5
15910	3515	1504	8
15911	3516	1505	7
15912	3516	1506	13
15913	3516	1502	9
15914	3516	1477	8
15915	3516	1503	5
15916	3516	1507	6
15917	3517	1508	5
15918	3517	1509	2
15919	3517	1510	2
15920	3517	1511	2
15921	3517	1512	8
15922	3518	1513	6
15923	3518	1514	5
15924	3518	1491	13
15925	3518	1515	14
15926	3518	1516	9
15927	3518	1517	8
15928	3518	1495	10
15929	3519	1518	4
15930	3519	1519	13
15931	3519	1477	8
15932	3519	1478	9
15933	3519	1493	4
15934	3520	1520	3
15935	3520	1491	11
15936	3520	1521	14
15937	3520	1522	8
15938	3520	1502	9
15939	3520	1507	4
15940	3520	1499	7
15941	3520	1480	8
15942	3521	1496	9
15943	3521	1523	3
15944	3521	1493	5
15945	3521	1486	6
15946	3521	1494	5
15947	3521	1495	11
15948	3522	1524	7
15949	3522	1491	11
15950	3522	1515	14
15951	3522	1477	5
15952	3522	1525	5
15953	3522	1503	12
15954	3522	1526	11
15955	3523	1527	6
15956	3523	1528	11
15957	3523	1529	10
15958	3523	1491	8
15959	3523	1521	14
15960	3523	1530	4
15961	3524	1531	4
15962	3524	1529	6
15963	3524	1491	7
15964	3524	1532	14
15965	3524	1533	5
15966	3524	1534	4
15967	3525	1535	4
15968	3525	1491	2
15969	3525	1521	14
15970	3525	1536	9
15971	3525	1525	5
15972	3525	1503	7
15973	3525	1537	11
15974	3525	1495	9
15975	3526	1538	5
15976	3526	1490	6
15977	3526	1491	11
15978	3526	1521	14
15979	3526	1516	9
15980	3526	1517	9
15981	3526	1526	9
15982	3527	1528	13
15983	3527	1529	11
15984	3527	1539	10
15985	3527	1540	9
15986	3527	1541	9
15987	3528	1542	3
15988	3528	1525	4
15989	3528	1498	4
15990	3528	1543	7
15991	3528	1495	11
15992	3529	1544	11
15993	3529	1545	11
15994	3529	1546	2
15995	3529	1547	6
15996	3529	1479	12
15997	3530	1548	8
15998	3530	1516	6
15999	3530	1517	9
16000	3530	1498	4
16001	3530	1549	4
16002	3530	1495	11
16003	3531	1550	13
16004	3531	1491	11
16005	3531	1515	14
16006	3531	1477	8
16007	3531	1525	3
16008	3531	1503	5
16009	3531	1526	8
16010	3532	1529	10
16011	3532	1491	11
16012	3532	1532	14
16013	3532	1477	6
16014	3532	1478	6
16015	3532	1493	5
16016	3532	1526	11
16017	3533	1551	6
16018	3533	1552	8
16019	3533	1491	5
16020	3533	1521	14
16021	3533	1516	3
16022	3533	1478	4
16023	3534	1553	2
16024	3534	1554	5
16025	3534	1555	11
16026	3534	1556	8
16027	3534	1511	4
16028	3535	1557	5
16029	3535	1491	6
16030	3535	1492	14
16031	3535	1477	3
16032	3535	1540	2
16033	3535	1503	6
16034	3535	1526	8
16035	3536	1558	4
16036	3536	1559	4
16037	3536	1560	11
16038	3536	1561	9
16039	3536	1562	4
16040	3537	1563	4
16041	3537	1564	3
16042	3537	1565	9
16043	3537	1566	9
16044	3537	1562	8
16045	3538	1567	3
16046	3538	1568	7
16047	3538	1569	8
16048	3538	1511	2
16049	3539	1570	2
16050	3539	1571	9
16051	3539	1572	3
16052	3539	1573	11
16053	3540	1574	5
16054	3540	1575	5
16055	3540	1576	5
16056	3540	1577	5
16057	3540	1530	2
16058	3541	1578	2
16059	3541	1579	9
16060	3541	1572	7
16061	3541	1580	7
16062	3541	1581	7
16063	3542	1582	3
16064	3542	1583	2
16065	3542	1560	7
16066	3542	1584	7
16067	3542	1562	5
16068	3543	1585	1
16069	3543	1586	9
16070	3543	1587	7
16071	3543	1588	3
16072	3543	1581	5
16073	3544	1589	11
16074	3544	1590	8
16075	3544	1591	2
16076	3544	1592	6
16077	3545	1593	5
16078	3545	1594	9
16079	3545	1595	11
16080	3545	1580	9
16081	3546	1596	3
16082	3546	1597	9
16083	3546	1598	7
16084	3546	1599	3
16085	3546	1530	7
16086	3547	1583	3
16087	3547	1600	3
16088	3547	1560	7
16089	3547	1601	8
16090	3547	1602	13
16091	3548	1583	3
16092	3548	1603	3
16093	3548	1576	7
16094	3548	1604	1
16095	3548	1602	9
16096	3549	1605	4
16097	3549	1568	7
16098	3549	1606	7
16099	3549	1530	1
16100	3550	1607	8
16101	3550	1608	9
16102	3550	1609	7
16103	3550	1610	3
16104	3550	1562	6
16105	3551	1611	11
16106	3551	1612	9
16107	3551	1613	8
16108	3551	1614	7
16109	3551	1592	3
16110	3552	1615	2
16111	3552	1616	7
16112	3552	1617	11
16113	3552	1618	3
16114	3552	1511	5
16115	3553	1619	12
16116	3553	1560	8
16117	3553	1601	9
16118	3553	1602	6
16119	3554	1620	2
16120	3554	1621	1
16121	3554	1571	13
16122	3554	1622	7
16123	3554	1511	3
16124	3555	1623	1
16125	3555	1624	7
16126	3555	1587	6
16127	3555	1625	5
16128	3555	1581	7
16129	3556	1626	5
16130	3556	1627	5
16131	3556	1628	9
16132	3556	1569	9
16133	3556	1511	2
16134	3557	1629	7
16135	3557	1630	9
16136	3557	1590	5
16137	3557	1592	9
16138	3558	1575	5
16139	3558	1631	9
16140	3558	1632	1
16141	3558	1633	5
16142	3558	1546	4
16143	3559	1634	2
16144	3559	1635	3
16145	3559	1636	3
16146	3559	1546	2
16147	3559	1516	4
16148	3560	1637	2
16149	3560	1638	5
16150	3560	1639	5
16151	3560	1530	4
16152	3560	1640	3
16153	3561	1641	3
16154	3561	1642	3
16155	3561	1643	8
16156	3561	1590	7
16157	3561	1581	9
16158	3562	1642	4
16159	3562	1644	9
16160	3562	1572	7
16161	3562	1645	8
16162	3562	1592	7
16163	3563	1646	4
16164	3563	1647	8
16165	3563	1648	9
16166	3563	1592	5
16167	3564	1575	11
16168	3564	1612	11
16169	3564	1649	12
16170	3564	1592	12
16171	3564	1516	11
16172	3565	1650	3
16173	3565	1638	7
16174	3565	1584	9
16175	3565	1651	5
16176	3565	1546	3
16177	3566	1652	4
16178	3566	1571	9
16179	3566	1572	5
16180	3566	1533	3
16181	3567	1653	3
16182	3567	1586	9
16183	3567	1654	6
16184	3567	1530	7
16185	3568	1655	2
16186	3568	1652	4
16187	3568	1571	8
16188	3568	1572	6
16189	3568	1533	4
16190	3569	1656	4
16191	3569	1643	9
16192	3569	1587	6
16193	3569	1651	2
16194	3569	1511	6
16195	3570	1641	3
16196	3570	1624	9
16197	3570	1572	9
16198	3570	1657	4
16199	3570	1581	8
16200	3571	1658	3
16201	3571	1659	9
16202	3571	1590	7
16203	3571	1660	1
16204	3571	1530	5
16205	3571	1516	6
16206	3572	1623	1
16207	3572	1624	9
16208	3572	1587	6
16209	3572	1625	6
16210	3572	1581	8
16211	3573	1661	6
16212	3573	1575	8
16213	3573	1662	7
16214	3573	1663	5
16215	3573	1546	2
16216	3574	1664	5
16217	3574	1665	11
16218	3574	1666	8
16219	3574	1667	4
16220	3574	1581	9
16221	3575	1583	2
16222	3575	1668	2
16223	3575	1669	6
16224	3575	1631	7
16225	3575	1511	3
16226	3576	1670	4
16227	3576	1671	4
16228	3576	1528	11
16229	3576	1672	8
16230	3576	1546	6
16231	3577	1673	7
16232	3577	1674	10
16233	3577	1622	8
16234	3577	1675	7
16235	3577	1530	7
16236	3578	1676	3
16237	3578	1643	13
16238	3578	1631	9
16239	3578	1618	3
16240	3578	1530	8
16241	3579	1677	4
16242	3579	1678	3
16243	3579	1665	7
16244	3579	1679	9
16245	3579	1613	8
16246	3579	1530	8
16247	3580	1680	7
16248	3580	1681	9
16249	3580	1682	12
16250	3580	1530	7
16251	3580	1683	4
16252	3581	1594	9
16253	3581	1590	9
16254	3581	1684	5
16255	3581	1511	9
16256	3582	1685	5
16257	3582	1686	1
16258	3582	1613	4
16259	3582	1687	7
16260	3582	1688	1
16261	3583	1689	5
16262	3583	1686	2
16263	3583	1690	3
16264	3583	1645	6
16265	3583	1688	3
16266	3584	1691	4
16267	3584	1692	8
16268	3584	1693	6
16269	3584	1694	1
16270	3584	1695	3
16271	3585	1696	5
16272	3585	1697	7
16273	3585	1698	5
16274	3585	1663	3
16275	3585	1699	9
16276	3586	1700	5
16277	3586	1701	4
16278	3586	1702	1
16279	3586	1703	1
16280	3586	1704	4
16281	3587	1705	4
16282	3587	1706	6
16283	3587	1707	7
16284	3587	1708	2
16285	3587	1699	3
16286	3588	1709	6
16287	3588	1710	8
16288	3588	1707	6
16289	3588	1711	3
16290	3588	1712	11
16291	3589	1551	5
16292	3589	1713	5
16293	3589	1714	5
16294	3589	1715	8
16295	3589	1699	8
16296	3590	1716	3
16297	3590	1717	6
16298	3590	1718	2
16299	3590	1719	1
16300	3590	1720	8
16301	3591	1691	3
16302	3591	1692	4
16303	3591	1693	4
16304	3591	1694	1
16305	3591	1695	2
16306	3592	1551	4
16307	3592	1721	2
16308	3592	1697	8
16309	3592	1722	1
16310	3592	1699	1
16311	3593	1723	3
16312	3593	1724	6
16313	3593	1701	8
16314	3593	1725	1
16315	3593	1704	7
16316	3594	1691	3
16317	3594	1692	5
16318	3594	1693	11
16319	3594	1694	6
16320	3594	1695	8
16321	3595	1709	5
16322	3595	1710	7
16323	3595	1707	7
16324	3595	1711	2
16325	3595	1712	7
16326	3596	1691	3
16327	3596	1692	6
16328	3596	1693	6
16329	3596	1694	1
16330	3596	1695	1
16331	3597	1709	5
16332	3597	1710	1
16333	3597	1707	4
16334	3597	1711	3
16335	3597	1712	1
16336	3598	1716	4
16337	3598	1717	3
16338	3598	1718	3
16339	3598	1719	3
16340	3598	1720	1
16341	3599	1726	4
16342	3599	1701	11
16343	3599	1702	6
16344	3599	1727	5
16345	3599	1704	8
16346	3600	1728	2
16347	3600	1729	5
16348	3600	1701	7
16349	3600	1704	5
16350	3600	1730	3
16351	3601	1658	1
16352	3601	1731	5
16353	3601	1732	1
16354	3601	1733	8
16355	3601	1533	4
16356	3602	1734	5
16357	3602	1735	6
16358	3602	1707	6
16359	3602	1736	2
16360	3602	1533	4
16361	3603	1737	6
16362	3603	1738	1
16363	3603	1739	2
16364	3603	1533	3
16365	3603	1740	3
16366	3604	1709	6
16367	3604	1710	8
16368	3604	1707	7
16369	3604	1711	3
16370	3604	1712	11
16371	3605	1709	6
16372	3605	1710	5
16373	3605	1707	7
16374	3605	1711	5
16375	3605	1712	7
16376	3606	1741	3
16377	3606	1686	2
16378	3606	1690	2
16379	3606	1742	5
16380	3606	1688	3
16381	3607	1716	4
16382	3607	1717	4
16383	3607	1718	1
16384	3607	1719	1
16385	3607	1720	7
16386	3608	1716	3
16387	3608	1717	5
16388	3608	1718	3
16389	3608	1719	2
16390	3608	1720	4
16391	3609	1743	7
16392	3609	1744	8
16393	3609	1698	4
16394	3609	1745	4
16395	3609	1699	8
16396	3610	1746	4
16397	3610	1686	3
16398	3610	1739	3
16399	3610	1747	8
16400	3610	1688	5
16401	3611	1709	5
16402	3611	1710	8
16403	3611	1707	4
16404	3611	1711	4
16405	3611	1712	9
16406	3612	1748	3
16407	3612	1729	5
16408	3612	1701	11
16409	3612	1749	6
16410	3612	1704	8
16411	3613	1750	5
16412	3613	1701	4
16413	3613	1613	7
16414	3613	1751	1
16415	3613	1704	4
16416	3614	1685	5
16417	3614	1686	1
16418	3614	1580	4
16419	3614	1752	1
16420	3614	1688	2
16421	3615	1753	5
16422	3615	1701	5
16423	3615	1702	2
16424	3615	1733	6
16425	3615	1704	5
16426	3616	1685	4
16427	3616	1686	4
16428	3616	1754	2
16429	3616	1755	2
16430	3616	1688	3
16431	3617	1756	3
16432	3617	1686	6
16433	3617	1732	7
16434	3617	1757	1
16435	3617	1688	3
16436	3618	1758	4
16437	3618	1701	11
16438	3618	1754	2
16439	3618	1759	5
16440	3618	1704	5
16441	3619	1760	6
16442	3619	1721	6
16443	3619	1761	9
16444	3619	1762	5
16445	3619	1699	9
16446	3620	1709	6
16447	3620	1710	8
16448	3620	1707	6
16449	3620	1711	5
16450	3620	1712	2
16451	3621	1709	6
16452	3621	1710	6
16453	3621	1707	4
16454	3621	1711	7
16455	3621	1712	1
16456	3622	1700	5
16457	3622	1701	7
16458	3622	1580	7
16459	3622	1749	5
16460	3622	1704	4
16461	3623	1743	7
16462	3623	1763	1
16463	3623	1714	4
16464	3623	1764	3
16465	3623	1704	5
16466	3624	1691	3
16467	3624	1692	4
16468	3624	1693	5
16469	3624	1694	1
16470	3624	1695	1
16471	3625	1709	5
16472	3625	1710	8
16473	3625	1707	8
16474	3625	1711	6
16475	3625	1712	5
16476	3626	1765	3
16477	3626	1766	3
16478	3626	1686	4
16479	3626	1732	2
16480	3626	1688	2
16481	3627	1716	4
16482	3627	1717	6
16483	3627	1718	3
16484	3627	1719	1
16485	3627	1720	1
16486	3628	1767	5
16487	3628	1768	7
16488	3628	1718	1
16489	3628	1769	5
16490	3628	1699	9
16491	3629	1691	4
16492	3629	1692	5
16493	3629	1693	2
16494	3629	1694	2
16495	3629	1695	3
16496	3630	1716	2
16497	3630	1717	4
16498	3630	1718	1
16499	3630	1719	1
16500	3630	1720	1
16501	3631	1696	5
16502	3631	1721	4
16503	3631	1697	9
16504	3631	1770	6
16505	3631	1699	5
16506	3632	1771	3
16507	3632	1721	7
16508	3632	1772	8
16509	3632	1651	2
16510	3632	1699	7
16511	3633	1691	2
16512	3633	1692	4
16513	3633	1693	5
16514	3633	1694	1
16515	3633	1695	1
16516	3634	1691	4
16517	3634	1692	5
16518	3634	1693	9
16519	3634	1694	2
16520	3634	1695	2
16521	3635	1691	3
16522	3635	1692	5
16523	3635	1693	6
16524	3635	1694	2
16525	3635	1695	3
16526	3636	1773	3
16527	3636	1686	2
16528	3636	1739	5
16529	3636	1774	1
16530	3636	1688	3
16531	3637	1709	7
16532	3637	1710	6
16533	3637	1707	7
16534	3637	1711	6
16535	3637	1712	6
16536	3638	1748	9
16537	3638	1701	6
16538	3638	1613	3
16539	3638	1747	9
16540	3638	1704	1
16541	3639	1737	5
16542	3639	1763	1
16543	3639	1707	1
16544	3639	1747	1
16545	3639	1704	1
16546	3640	1775	4
16547	3640	1701	1
16548	3640	1684	2
16549	3640	1776	1
16550	3640	1704	3
16551	3641	1728	3
16552	3641	1701	1
16553	3641	1702	4
16554	3641	1776	2
16555	3641	1704	1
16556	3642	1746	4
16557	3642	1777	4
16558	3642	1701	6
16559	3642	1684	3
16560	3642	1704	1
16561	3643	1775	4
16562	3643	1778	5
16563	3643	1686	4
16564	3643	1779	4
16565	3643	1688	5
16566	3644	1780	4
16567	3644	1731	9
16568	3644	1684	4
16569	3644	1781	5
16570	3644	1699	1
16571	3645	1782	5
16572	3645	1686	1
16573	3645	1613	2
16574	3645	1783	2
16575	3645	1688	3
16576	3646	1513	5
16577	3646	1784	6
16578	3646	1613	6
16579	3646	1785	5
16580	3646	1699	8
16581	3647	1716	3
16582	3647	1717	3
16583	3647	1718	1
16584	3647	1719	1
16585	3647	1720	1
16586	3648	1709	6
16587	3648	1710	6
16588	3648	1707	5
16589	3648	1711	3
16590	3648	1712	6
16591	3649	1786	8
16592	3649	1701	5
16593	3649	1702	2
16594	3649	1747	10
16595	3649	1704	6
16596	3650	1709	6
16597	3650	1710	9
16598	3650	1707	7
16599	3650	1711	2
16600	3650	1712	7
16601	3651	1709	6
16602	3651	1710	11
16603	3651	1707	8
16604	3651	1711	6
16605	3651	1712	7
16606	3652	1787	5
16607	3652	1692	3
16608	3652	1788	2
16609	3652	1789	1
16610	3652	1699	1
16611	3653	1691	3
16612	3653	1692	7
16613	3653	1693	9
16614	3653	1694	1
16615	3653	1695	4
16616	3654	1737	5
16617	3654	1686	3
16618	3654	1790	2
16619	3654	1688	4
16620	3654	1791	3
16621	3655	1792	3
16622	3655	1692	6
16623	3655	1693	3
16624	3655	1694	2
16625	3655	1695	2
16626	3656	1691	5
16627	3656	1692	4
16628	3656	1693	2
16629	3656	1694	1
16630	3656	1695	1
16631	3657	1691	4
16632	3657	1692	6
16633	3657	1693	8
16634	3657	1694	2
16635	3657	1695	4
16636	3658	1691	4
16637	3658	1692	7
16638	3658	1693	8
16639	3658	1694	2
16640	3658	1695	5
16641	3659	1748	5
16642	3659	1701	6
16643	3659	1718	1
16644	3659	1793	1
16645	3659	1704	5
16646	3660	1716	3
16647	3660	1717	9
16648	3660	1718	2
16649	3660	1719	1
16650	3660	1720	5
16651	3661	1766	6
16652	3661	1701	6
16653	3661	1794	6
16654	3661	1704	6
16655	3661	1543	8
16656	3662	1716	4
16657	3662	1717	6
16658	3662	1718	2
16659	3662	1719	2
16660	3662	1720	8
16661	3663	1691	5
16662	3663	1692	8
16663	3663	1693	8
16664	3663	1694	4
16665	3663	1695	1
16666	3664	1691	4
16667	3664	1692	8
16668	3664	1693	9
16669	3664	1694	3
16670	3664	1695	8
16671	3665	1716	3
16672	3665	1717	7
16673	3665	1718	3
16674	3665	1719	1
16675	3665	1720	3
16676	3666	1709	6
16677	3666	1710	7
16678	3666	1707	6
16679	3666	1711	3
16680	3666	1712	2
16681	3667	1696	4
16682	3667	1795	11
16683	3667	1707	6
16684	3667	1764	4
16685	3667	1699	1
16686	3668	1709	4
16687	3668	1710	9
16688	3668	1707	7
16689	3668	1711	6
16690	3668	1712	4
16691	3669	1716	5
16692	3669	1717	9
16693	3669	1718	4
16694	3669	1719	1
16695	3669	1720	9
16696	3670	1796	4
16697	3670	1797	5
16698	3670	1701	6
16699	3670	1798	1
16700	3670	1704	4
16701	3671	1723	4
16702	3671	1701	8
16703	3671	1718	3
16704	3671	1799	9
16705	3671	1704	6
16706	3672	1716	3
16707	3672	1717	9
16708	3672	1718	1
16709	3672	1719	3
16710	3672	1720	4
16711	3673	1691	3
16712	3673	1692	6
16713	3673	1693	7
16714	3673	1694	4
16715	3673	1695	5
16716	3674	1709	7
16717	3674	1710	9
16718	3674	1707	7
16719	3674	1711	6
16720	3674	1712	10
16721	3675	1800	5
16722	3675	1706	4
16723	3675	1745	2
16724	3675	1562	4
16725	3675	1549	2
16726	3676	1558	3
16727	3676	1554	6
16728	3676	1801	7
16729	3676	1562	5
16730	3676	1543	6
16731	3677	1582	1
16732	3677	1784	5
16733	3677	1714	5
16734	3677	1498	2
16735	3677	1562	1
16736	3678	1802	11
16737	3678	1803	10
16738	3678	1804	7
16739	3678	1805	11
16740	3678	1806	9
16741	3678	1807	1
16742	3679	1808	6
16743	3679	1809	4
16744	3679	1810	3
16745	3679	1811	2
16746	3679	1812	3
16747	3679	1813	14
16748	3679	1814	1
16749	3679	1815	11
16750	3680	1816	6
16751	3680	1812	3
16752	3680	1813	14
16753	3680	1804	5
16754	3680	1817	4
16755	3680	1805	2
16756	3680	1818	4
16757	3681	1819	4
16758	3681	1820	3
16759	3681	1812	4
16760	3681	1821	14
16761	3681	1822	9
16762	3682	1823	3
16763	3682	1824	5
16764	3682	1825	2
16765	3682	1826	7
16766	3682	1827	10
16767	3683	1828	7
16768	3683	1814	5
16769	3683	1829	7
16770	3683	1826	7
16771	3683	1830	9
16772	3684	1831	13
16773	3684	1832	4
16774	3684	1833	4
16775	3684	1834	7
16776	3684	1835	9
16777	3684	1836	3
16778	3685	1837	2
16779	3685	1838	7
16780	3685	1829	13
16781	3685	1839	7
16782	3685	1840	3
16783	3686	1841	8
16784	3686	1812	3
16785	3686	1813	14
16786	3686	1838	7
16787	3686	1817	1
16788	3686	1805	1
16789	3686	1818	7
16790	3687	1842	13
16791	3687	1843	8
16792	3687	1844	5
16793	3687	1829	13
16794	3687	1845	5
16795	3687	1846	2
16796	3687	1847	12
16797	3688	1848	9
16798	3688	1812	11
16799	3688	1849	14
16800	3688	1814	5
16801	3688	1826	8
16802	3689	1850	10
16803	3689	1851	6
16804	3689	1838	6
16805	3689	1814	6
16806	3689	1846	2
16807	3689	1817	7
16808	3689	1830	13
16809	3690	1852	7
16810	3690	1853	7
16811	3690	1812	4
16812	3690	1813	14
16813	3690	1804	6
16814	3690	1835	9
16815	3690	1854	8
16816	3691	1855	3
16817	3691	1856	4
16818	3691	1857	3
16819	3691	1812	11
16820	3691	1849	14
16821	3691	1833	7
16822	3691	1858	9
16823	3692	1859	4
16824	3692	1812	5
16825	3692	1821	14
16826	3692	1804	6
16827	3692	1860	4
16828	3692	1861	3
16829	3692	1834	4
16830	3693	1862	9
16831	3693	1863	5
16832	3693	1833	7
16833	3693	1864	7
16834	3693	1829	4
16835	3693	1865	4
16836	3694	1866	12
16837	3694	1867	11
16838	3694	1868	8
16839	3694	1869	9
16840	3694	1870	12
16841	3694	1854	5
16842	3695	1871	2
16843	3695	1872	2
16844	3695	1830	9
16845	3695	1873	6
16846	3695	1874	4
16847	3695	1875	2
16848	3696	1876	7
16849	3696	1877	11
16850	3696	1829	13
16851	3696	1861	13
16852	3696	1870	13
16853	3697	1878	1
16854	3697	1879	2
16855	3697	1880	5
16856	3697	1830	8
16857	3697	1874	3
16858	3698	1841	13
16859	3698	1881	4
16860	3698	1804	5
16861	3698	1882	5
16862	3698	1860	2
16863	3698	1861	7
16864	3699	1883	9
16865	3699	1884	7
16866	3699	1814	3
16867	3699	1817	4
16868	3699	1839	8
16869	3699	1818	7
16870	3700	1885	4
16871	3700	1833	3
16872	3700	1864	9
16873	3700	1829	6
16874	3701	1886	6
16875	3701	1887	9
16876	3701	1888	5
16877	3701	1832	7
16878	3701	1873	11
16879	3702	1889	8
16880	3702	1812	5
16881	3702	1890	14
16882	3702	1864	7
16883	3702	1817	5
16884	3702	1839	6
16885	3702	1891	8
16886	3703	1892	8
16887	3703	1893	7
16888	3703	1868	7
16889	3703	1894	9
16890	3703	1895	9
16891	3704	1896	11
16892	3704	1897	9
16893	3704	1898	3
16894	3704	1899	2
16895	3704	1858	9
16896	3705	1900	8
16897	3705	1901	6
16898	3705	1816	11
16899	3705	1832	8
16900	3705	1902	11
16901	3706	1903	3
16902	3706	1900	9
16903	3706	1904	6
16904	3706	1905	7
16905	3706	1906	3
16906	3706	1907	1
16907	3707	1908	4
16908	3707	1852	8
16909	3707	1909	3
16910	3707	1910	4
16911	3707	1873	5
16912	3707	1865	6
16913	3708	1911	3
16914	3708	1912	8
16915	3708	1913	11
16916	3708	1914	9
16917	3708	1873	7
16918	3708	1902	3
16919	3709	1915	9
16920	3709	1916	9
16921	3709	1917	6
16922	3709	1918	5
16923	3709	1865	11
16924	3710	1887	10
16925	3710	1919	11
16926	3710	1904	8
16927	3710	1920	4
16928	3710	1921	4
16929	3710	1922	11
16930	3711	1923	5
16931	3711	1897	7
16932	3711	1924	5
16933	3711	1922	9
16934	3711	1902	11
16935	3712	1925	10
16936	3712	1926	5
16937	3712	1832	8
16938	3712	1835	11
16939	3712	1854	8
16940	3713	1927	5
16941	3713	1928	11
16942	3713	1909	8
16943	3713	1835	7
16944	3713	1854	6
16945	3714	1915	9
16946	3714	1929	4
16947	3714	1930	2
16948	3714	1918	5
16949	3714	1865	9
16950	3715	1931	8
16951	3715	1932	6
16952	3715	1933	7
16953	3715	1832	5
16954	3715	1934	7
16955	3715	1865	8
16956	3716	1935	8
16957	3716	1936	9
16958	3716	1937	7
16959	3716	1938	7
16960	3716	1835	1
16961	3716	1865	4
16962	3717	1939	5
16963	3717	1940	3
16964	3717	1941	6
16965	3717	1916	8
16966	3717	1942	8
16967	3717	1902	8
16968	3718	1943	13
16969	3718	1944	9
16970	3718	1909	11
16971	3718	1835	7
16972	3718	1854	8
16973	3719	1945	7
16974	3719	1946	9
16975	3719	1887	9
16976	3719	1947	13
16977	3719	1948	8
16978	3719	1949	10
16979	3720	1950	3
16980	3720	1951	8
16981	3720	1952	8
16982	3720	1832	6
16983	3720	1873	7
16984	3720	1865	7
16985	3721	1953	7
16986	3721	1954	9
16987	3721	1832	7
16988	3721	1934	6
16989	3721	1865	11
16990	3722	1955	4
16991	3722	1956	9
16992	3722	1916	10
16993	3722	1957	5
16994	3722	1873	8
16995	3722	1854	6
16996	3723	1958	9
16997	3723	1959	11
16998	3723	1960	6
16999	3723	1840	4
17000	3724	1887	9
17001	3724	1961	11
17002	3724	1909	9
17003	3724	1962	4
17004	3724	1832	9
17005	3724	1873	7
17006	3725	1963	6
17007	3725	1915	10
17008	3725	1964	5
17009	3725	1957	6
17010	3725	1835	9
17011	3726	1887	10
17012	3726	1941	6
17013	3726	1897	11
17014	3726	1883	6
17015	3726	1954	10
17016	3726	1934	8
17017	3727	1965	8
17018	3727	1888	2
17019	3727	1966	4
17020	3727	1967	6
17021	3727	1854	5
17022	3728	1968	2
17023	3728	1969	4
17024	3728	1970	9
17025	3728	1971	7
17026	3729	1972	3
17027	3729	1973	9
17028	3729	1974	1
17029	3729	1922	11
17030	3729	1902	11
17031	3730	1975	5
17032	3730	1900	13
17033	3730	1901	8
17034	3730	1976	3
17035	3730	1934	9
17036	3730	1902	11
17037	3731	1887	9
17038	3731	1977	9
17039	3731	1978	8
17040	3731	1979	6
17041	3731	1922	11
17042	3732	1980	3
17043	3732	1981	5
17044	3732	1953	9
17045	3732	1982	9
17046	3732	1934	11
17047	3732	1902	11
17048	3733	1983	6
17049	3733	1944	9
17050	3733	1984	6
17051	3733	1883	11
17052	3733	1934	9
17053	3734	1985	2
17054	3734	1986	4
17055	3734	1913	13
17056	3734	1987	9
17057	3734	1835	9
17058	3734	1854	6
17059	3735	1973	8
17060	3735	1914	6
17061	3735	1905	4
17062	3735	1988	2
17063	3735	1895	7
17064	3735	1865	6
17065	3736	1989	5
17066	3736	1990	10
17067	3736	1991	11
17068	3736	1992	7
17069	3736	1873	9
17070	3736	1854	7
17071	3737	1993	3
17072	3737	1994	7
17073	3737	1992	5
17074	3737	1918	4
17075	3737	1865	8
17076	3738	1956	9
17077	3738	1992	9
17078	3738	1995	3
17079	3738	1832	8
17080	3738	1934	9
17081	3738	1865	11
17082	3739	1996	4
17083	3739	1961	9
17084	3739	1938	7
17085	3739	1853	6
17086	3739	1934	9
17087	3739	1902	11
17088	3740	1997	8
17089	3740	1829	3
17090	3740	1834	9
17091	3740	1839	9
17092	3740	1836	2
17093	3740	1902	11
17094	3741	1998	6
17095	3741	1999	6
17096	3741	2000	9
17097	3741	2001	4
17098	3741	1922	6
17099	3741	1854	6
17100	3742	2002	5
17101	3742	2003	9
17102	3742	1997	8
17103	3742	2004	4
17104	3742	1873	8
17105	3742	1902	11
17106	3743	1999	6
17107	3743	1897	11
17108	3743	2005	10
17109	3743	2001	4
17110	3743	1934	11
17111	3743	1854	6
17112	3744	2006	4
17113	3744	2007	3
17114	3744	1867	8
17115	3744	2008	7
17116	3744	1971	5
17117	3744	1902	7
17118	3745	1953	2
17119	3745	1877	4
17120	3745	1832	1
17121	3745	1873	2
17122	3745	2009	3
17123	3746	2010	6
17124	3746	1852	7
17125	3746	1917	8
17126	3746	2011	11
17127	3746	1835	11
17128	3746	1854	14
17129	3747	1964	8
17130	3747	2012	1
17131	3747	2013	3
17132	3747	1934	7
17133	3747	1854	7
17134	3748	2014	6
17135	3748	2015	4
17136	3748	1925	6
17137	3748	2016	5
17138	3748	2017	7
17139	3748	2018	5
17140	3749	2019	9
17141	3749	2020	7
17142	3749	2021	7
17143	3749	1922	9
17144	3749	1865	8
17145	3750	1945	9
17146	3750	1961	4
17147	3750	1938	11
17148	3750	1922	9
17149	3750	1902	8
17150	3751	2022	2
17151	3751	1945	2
17152	3751	1868	6
17153	3751	1934	11
17154	3751	1854	6
17155	3752	2023	4
17156	3752	2024	4
17157	3752	2025	5
17158	3752	2026	1
17159	3752	2027	1
17160	3753	2028	3
17161	3753	2029	5
17162	3753	1853	8
17163	3753	2030	1
17164	3753	2031	7
17165	3754	2032	3
17166	3754	2033	5
17167	3754	2034	7
17168	3754	2035	1
17169	3754	1918	6
17170	3755	2036	6
17171	3755	2037	7
17172	3755	2038	4
17173	3755	1858	8
17174	3755	2009	4
17175	3756	1859	4
17176	3756	2039	9
17177	3756	2040	5
17178	3756	2041	1
17179	3756	1858	12
17180	3757	2023	5
17181	3757	2042	4
17182	3757	2043	3
17183	3757	2029	7
17184	3757	2044	4
17185	3757	1858	3
17186	3758	2045	4
17187	3758	2037	5
17188	3758	2046	3
17189	3758	2047	4
17190	3758	2048	6
17191	3759	2049	6
17192	3759	2050	5
17193	3759	2037	8
17194	3759	1995	2
17195	3759	1858	7
17196	3760	2051	3
17197	3760	2039	9
17198	3760	2052	6
17199	3760	2053	2
17200	3760	1942	7
17201	3761	2054	3
17202	3761	1989	3
17203	3761	2034	5
17204	3761	2035	1
17205	3761	2027	2
17206	3762	2055	3
17207	3762	2056	3
17208	3762	2029	9
17209	3762	2057	3
17210	3762	1858	2
17211	3763	1809	2
17212	3763	2058	9
17213	3763	1853	5
17214	3763	2059	4
17215	3763	1942	5
17216	3764	2060	7
17217	3764	2061	4
17218	3764	2062	8
17219	3764	1988	3
17220	3764	2027	13
17221	3765	2045	3
17222	3765	2063	7
17223	3765	2046	4
17224	3765	2064	1
17225	3765	1907	4
17226	3766	2065	4
17227	3766	2034	7
17228	3766	2066	6
17229	3766	2035	1
17230	3766	2027	3
17231	3767	2067	2
17232	3767	2068	4
17233	3767	2063	4
17234	3767	2041	1
17235	3767	1907	2
17236	3768	2010	1
17237	3768	2069	7
17238	3768	1883	7
17239	3768	2013	3
17240	3768	1942	1
17241	3769	2070	4
17242	3769	2071	8
17243	3769	2052	11
17244	3769	2072	4
17245	3769	2031	8
17246	3770	2022	2
17247	3770	2073	3
17248	3770	2074	11
17249	3770	2075	1
17250	3770	2076	2
17251	3770	1918	6
17252	3771	2077	3
17253	3771	2078	4
17254	3771	1816	4
17255	3771	2079	2
17256	3771	2031	6
17257	3772	2080	3
17258	3772	2081	6
17259	3772	2082	9
17260	3772	2083	1
17261	3772	1907	1
17262	3773	2051	2
17263	3773	2084	2
17264	3773	2029	5
17265	3773	2027	1
17266	3773	2085	2
17267	3774	2086	5
17268	3774	2015	7
17269	3774	2087	9
17270	3774	2088	3
17271	3774	2048	2
17272	3775	2089	3
17273	3775	2068	6
17274	3775	2090	8
17275	3775	2026	3
17276	3775	1895	5
17277	3776	2091	4
17278	3776	2092	3
17279	3776	2052	6
17280	3776	2093	5
17281	3776	1918	3
17282	3777	2094	4
17283	3777	2095	3
17284	3777	1970	7
17285	3777	2053	2
17286	3777	1942	11
17287	3778	2095	3
17288	3778	2096	4
17289	3778	2052	5
17290	3778	1883	7
17291	3778	1942	4
17292	3779	2097	5
17293	3779	2043	6
17294	3779	2090	8
17295	3779	2098	2
17296	3779	1942	7
17297	3780	2045	3
17298	3780	2099	7
17299	3780	2029	9
17300	3780	2072	2
17301	3780	2031	3
17302	3781	2045	3
17303	3781	2063	6
17304	3781	2046	4
17305	3781	2059	4
17306	3781	1907	3
17307	3782	2022	2
17308	3782	2100	3
17309	3782	2101	9
17310	3782	2102	4
17311	3782	1918	8
17312	3783	2103	3
17313	3783	1958	9
17314	3783	2104	4
17315	3783	2013	4
17316	3783	1942	9
17317	3784	2063	6
17318	3784	2105	4
17319	3784	2106	2
17320	3784	2026	6
17321	3784	1942	3
17322	3785	1931	4
17323	3785	2039	8
17324	3785	2066	3
17325	3785	2107	3
17326	3785	2027	1
17327	3786	2108	3
17328	3786	2025	6
17329	3786	2106	1
17330	3786	2109	4
17331	3786	2031	4
17332	3787	2110	12
17333	3787	2025	10
17334	3787	2066	8
17335	3787	2111	6
17336	3787	2031	8
17337	3788	2084	4
17338	3788	2071	7
17339	3788	2112	1
17340	3788	2113	3
17341	3788	2031	7
17342	3789	2045	4
17343	3789	2114	9
17344	3789	2115	2
17345	3789	2041	1
17346	3789	1858	8
17347	3790	2089	4
17348	3790	2068	6
17349	3790	2090	9
17350	3790	2026	1
17351	3790	1895	2
17352	3791	2045	3
17353	3791	1933	8
17354	3791	2046	3
17355	3791	2064	1
17356	3791	1907	1
17357	3792	1859	3
17358	3792	2116	4
17359	3792	2039	10
17360	3792	2117	4
17361	3792	1858	5
17362	3793	2014	5
17363	3793	2096	3
17364	3793	1816	3
17365	3793	2118	4
17366	3793	1907	3
17367	3794	2054	3
17368	3794	2034	9
17369	3794	2066	3
17370	3794	2035	1
17371	3794	2027	2
17372	3795	2089	3
17373	3795	2019	6
17374	3795	2063	8
17375	3795	2001	4
17376	3795	1895	5
17377	3796	2119	4
17378	3796	2120	7
17379	3796	2121	9
17380	3796	2122	4
17381	3796	1942	4
17382	3797	2123	4
17383	3797	2039	8
17384	3797	1883	6
17385	3797	2026	1
17386	3797	1942	1
17387	3798	2039	9
17388	3798	2106	3
17389	3798	2118	2
17390	3798	2035	4
17391	3798	1858	6
17392	3799	2042	3
17393	3799	2034	8
17394	3799	2124	1
17395	3799	1881	3
17396	3799	2027	8
17397	3800	1940	2
17398	3800	1970	6
17399	3800	2125	1
17400	3800	2118	9
17401	3800	1895	1
17402	3801	2049	6
17403	3801	1886	2
17404	3801	2037	8
17405	3801	2066	6
17406	3801	2126	3
17407	3801	1858	5
17408	3802	2049	5
17409	3802	2037	7
17410	3802	2066	9
17411	3802	2038	6
17412	3802	1858	8
17413	3803	2127	2
17414	3803	2114	5
17415	3803	2041	1
17416	3803	2031	1
17417	3803	2128	6
17418	3804	2054	4
17419	3804	2034	11
17420	3804	2066	8
17421	3804	2079	1
17422	3804	2027	7
17423	3805	2065	3
17424	3805	1989	2
17425	3805	2034	11
17426	3805	2035	1
17427	3805	2027	4
17428	3806	2129	1
17429	3806	2099	3
17430	3806	2130	9
17431	3806	2117	1
17432	3806	2031	7
17433	3807	2129	4
17434	3807	2099	4
17435	3807	2130	8
17436	3807	2131	3
17437	3807	2027	9
17438	3808	2132	2
17439	3808	2007	9
17440	3808	2090	8
17441	3808	2083	2
17442	3808	1858	5
17443	3809	2133	3
17444	3809	2029	2
17445	3809	1895	1
17446	3809	2128	4
17447	3809	1875	1
17448	3810	2123	2
17449	3810	2084	3
17450	3810	2039	4
17451	3810	2134	1
17452	3810	2031	1
17453	3811	2135	5
17454	3811	2039	2
17455	3811	2136	9
17456	3811	2027	1
17457	3811	1836	1
17458	3812	2137	4
17459	3812	2138	7
17460	3812	2007	8
17461	3812	2039	9
17462	3812	2031	5
17463	3813	2108	3
17464	3813	2130	9
17465	3813	1917	6
17466	3813	2111	4
17467	3813	2031	6
17468	3814	2139	5
17469	3814	1951	5
17470	3814	2029	7
17471	3814	2026	2
17472	3814	1858	2
17473	3815	2100	3
17474	3815	2140	2
17475	3815	2141	4
17476	3815	2142	2
17477	3815	2031	2
17478	3816	2143	5
17479	3816	2037	7
17480	3816	1917	6
17481	3816	2059	7
17482	3816	1858	12
17483	3817	2144	5
17484	3817	1970	4
17485	3817	1883	6
17486	3817	2026	1
17487	3817	1942	1
17488	3818	2045	4
17489	3818	2063	6
17490	3818	2046	3
17491	3818	2064	1
17492	3818	1907	5
17493	3819	2145	4
17494	3819	2039	8
17495	3819	2076	2
17496	3819	2001	1
17497	3819	2031	7
17498	3820	2146	3
17499	3820	2045	3
17500	3820	2063	7
17501	3820	2064	1
17502	3820	1907	3
17503	3821	2089	5
17504	3821	2068	6
17505	3821	2147	9
17506	3821	2026	1
17507	3821	1895	6
17508	3822	2056	4
17509	3822	2029	2
17510	3822	1853	2
17511	3822	1858	1
17512	3822	2148	2
17513	3823	2149	4
17514	3823	2150	3
17515	3823	2034	11
17516	3823	2035	1
17517	3823	1918	6
17518	3824	2151	5
17519	3824	2029	8
17520	3824	1853	6
17521	3824	1905	5
17522	3824	1942	5
17523	3825	2054	5
17524	3825	2034	11
17525	3825	2079	1
17526	3825	2027	4
17527	3825	1840	2
17528	3826	2054	5
17529	3826	2034	2
17530	3826	2066	4
17531	3826	2079	1
17532	3826	2027	1
17533	3827	2054	4
17534	3827	2034	8
17535	3827	2066	6
17536	3827	2035	2
17537	3827	2027	6
17538	3828	2065	4
17539	3828	2034	11
17540	3828	2066	7
17541	3828	2079	2
17542	3828	2027	4
17543	3829	2152	3
17544	3829	2153	2
17545	3829	2039	7
17546	3829	2154	4
17547	3829	2155	4
17548	3829	2031	2
17549	3830	2144	7
17550	3830	1990	8
17551	3830	1933	9
17552	3830	2026	4
17553	3830	1942	3
17554	3831	2143	5
17555	3831	2156	8
17556	3831	1853	6
17557	3831	2059	5
17558	3831	1942	8
17559	3832	2010	1
17560	3832	1970	11
17561	3832	1883	8
17562	3832	2157	9
17563	3832	1895	9
17564	3833	2054	6
17565	3833	2034	11
17566	3833	2079	2
17567	3833	2027	3
17568	3833	1840	4
17569	3834	2158	6
17570	3834	2034	13
17571	3834	1926	4
17572	3834	2159	5
17573	3834	1895	9
17574	3835	2010	1
17575	3835	1933	7
17576	3835	1883	8
17577	3835	2160	2
17578	3835	1942	5
17579	3836	2161	5
17580	3836	2063	6
17581	3836	2046	6
17582	3836	2059	4
17583	3836	1907	1
17584	3837	2127	2
17585	3837	2162	7
17586	3837	2163	2
17587	3837	2117	2
17588	3837	1858	3
17589	3838	2022	4
17590	3838	2068	5
17591	3838	2063	8
17592	3838	2026	3
17593	3838	1907	2
17594	3839	2010	3
17595	3839	1970	13
17596	3839	2157	8
17597	3839	1949	7
17598	3839	1942	7
17599	3840	2164	2
17600	3840	2039	8
17601	3840	2165	3
17602	3840	2031	2
17603	3840	1875	1
17604	3841	2166	5
17605	3841	2167	3
17606	3841	2090	11
17607	3841	2026	4
17608	3841	2031	11
17609	3842	2089	3
17610	3842	2096	8
17611	3842	2066	7
17612	3842	2168	4
17613	3842	1942	6
17614	3843	2032	3
17615	3843	2054	4
17616	3843	2034	11
17617	3843	2035	1
17618	3843	2027	5
17619	3844	2067	3
17620	3844	2068	6
17621	3844	2063	9
17622	3844	2041	1
17623	3844	2048	5
17624	3845	2084	5
17625	3845	2034	9
17626	3845	2169	3
17627	3845	1880	5
17628	3845	1895	4
17629	3846	2084	8
17630	3846	2114	8
17631	3846	2169	11
17632	3846	2170	4
17633	3846	1895	6
17634	3847	2171	1
17635	3847	2114	7
17636	3847	1957	1
17637	3847	1895	1
17638	3847	1836	1
17639	3848	2172	6
17640	3848	2173	5
17641	3848	2174	3
17642	3849	2175	5
17643	3850	2176	3
17644	3851	2177	4
17645	3851	2178	5
17646	3852	2176	11
17647	3853	2179	13
17648	3853	2180	4
17649	3854	2176	3
17650	3855	2176	1
17651	3856	2176	3
17652	3857	2181	3
17653	3857	2182	11
17654	3858	2172	4
17655	3858	2183	7
17656	3859	2184	7
17657	3859	2185	8
17658	3860	2186	4
17659	3861	2187	3
17660	3861	2188	11
17661	3862	2189	7
17662	3862	2174	3
17663	3863	2174	2
17664	3863	2190	13
17665	3864	2191	8
17666	3865	2192	2
17667	3865	2193	4
17668	3866	2194	5
17669	3866	2190	5
17670	3867	2195	11
17671	3867	2196	10
17672	3868	2197	7
17673	3868	2188	9
17674	3869	2190	11
17675	3870	2198	7
17676	3871	2190	4
17677	3872	2195	2
17678	3872	2188	9
17679	3873	2199	8
17680	3874	2200	8
17681	3875	2201	6
17682	3875	2186	4
17683	3876	2185	3
17684	3877	2202	5
17685	3877	2203	1
17686	3878	2204	11
17687	3878	2190	2
17688	3879	2204	3
17689	3880	2192	5
17690	3880	2204	3
17691	3881	2205	9
17692	3881	2178	5
17693	3882	2202	7
17694	3882	2200	8
17695	3883	2206	4
17696	3883	2204	5
17697	3884	2207	3
17698	3884	2193	3
17699	3885	2188	8
17700	3886	2200	4
17701	3886	2204	11
17702	3887	2190	11
17703	3888	2208	4
17704	3889	2204	11
17705	3889	2190	5
17706	3890	2186	2
17707	3890	2198	4
17708	3891	2186	5
17709	3891	2191	1
17710	3892	2209	5
17711	3893	2210	8
17712	3894	2211	8
17713	3894	2212	4
17714	3895	2213	7
17715	3896	2214	2
17716	3897	2191	6
17717	3898	2215	6
17718	3899	2216	5
17719	3900	2217	4
17720	3900	2218	2
17721	3901	2197	1
17722	3902	2219	4
17723	3903	2219	7
17724	3904	2220	3
17725	3904	2221	5
17726	3905	2222	1
17727	3905	2178	3
17728	3906	2223	1
17729	3907	2224	11
17730	3908	2204	11
17731	3908	2190	4
17732	3909	2225	5
17733	3910	2213	3
17734	3911	2226	2
17735	3912	2215	5
17736	3913	2204	2
17737	3913	2190	1
17738	3914	2227	8
17739	3915	2228	1
17740	3916	2226	1
17741	3917	2229	1
17742	3918	2198	9
17743	3919	2230	1
17744	3919	2231	3
17745	3920	2216	3
17746	3921	2191	8
17747	3922	2197	5
17748	3923	2229	2
17749	3924	2225	5
17750	3925	2232	5
17751	3926	2204	1
17752	3926	2190	1
17753	3927	2233	6
17754	3928	2232	1
17755	3929	2227	7
17756	3930	2216	4
17757	3931	2226	7
17758	3931	2234	2
17759	3932	2224	5
17760	3933	2233	5
17761	3934	2235	2
17762	3934	2236	3
17763	3935	2237	2
17764	3936	2197	5
17765	3937	2224	11
17766	3938	2191	9
17767	3939	2238	11
17768	3940	2219	4
17769	3941	2228	3
17770	3942	2239	9
17771	3943	2219	1
17772	3944	2240	6
17773	3945	2241	11
17774	3945	2242	5
17775	3945	2243	11
17776	3945	2244	6
17777	3945	2245	11
17778	3946	2246	14
17779	3946	2247	14
17780	3946	2248	7
17781	3946	2249	4
17782	3946	2245	10
17783	3947	2250	3
17784	3948	2248	6
17785	3948	2251	11
17786	3948	2252	5
17787	3948	2253	4
17788	3948	2254	13
17789	3949	2252	4
17790	3949	2250	3
17791	3949	2255	14
17792	3949	2256	6
17793	3949	2245	9
17794	3950	2257	4
17795	3950	2258	2
17796	3950	2241	11
17797	3950	2259	5
17798	3950	2260	4
17799	3950	2253	3
17800	3951	2261	11
17801	3951	2262	14
17802	3951	2263	9
17803	3951	2264	8
17804	3951	2265	8
17805	3951	2259	11
17806	3951	2266	9
17807	3952	2261	5
17808	3952	2267	14
17809	3952	2251	11
17810	3952	2268	8
17811	3952	2269	7
17812	3953	2248	6
17813	3953	2251	11
17814	3953	2252	6
17815	3953	2249	3
17816	3953	2270	9
17817	3953	2253	4
17818	3954	2271	14
17819	3954	2272	11
17820	3955	2273	7
17821	3955	2274	8
17822	3955	2253	3
17823	3955	2245	11
17824	3956	2271	14
17825	3956	2272	11
17826	3956	2275	11
17827	3956	2276	3
17828	3956	2260	6
17829	3956	2277	1
17830	3956	2278	9
17831	3957	2279	2
17832	3957	2280	7
17833	3957	2248	8
17834	3957	2268	8
17835	3957	2265	2
17836	3957	2281	7
17837	3958	2282	5
17838	3958	2283	2
17839	3958	2284	10
17840	3958	2285	3
17841	3958	2286	13
17842	3958	2254	8
17843	3959	2287	9
17844	3959	2288	6
17845	3959	2259	6
17846	3959	2289	5
17847	3959	2250	7
17848	3959	2290	11
17849	3960	2263	3
17850	3960	2251	8
17851	3960	2291	6
17852	3960	2242	4
17853	3960	2252	8
17854	3960	2249	1
17855	3961	2292	3
17856	3961	2261	11
17857	3961	2262	14
17858	3961	2264	8
17859	3961	2243	11
17860	3961	2254	11
17861	3962	2263	7
17862	3962	2264	9
17863	3962	2281	6
17864	3962	2289	4
17865	3962	2245	9
17866	3963	2293	11
17867	3963	2294	2
17868	3963	2271	14
17869	3963	2272	11
17870	3963	2286	6
17871	3963	2244	12
17872	3963	2254	8
17873	3964	2263	6
17874	3964	2268	11
17875	3964	2281	6
17876	3964	2289	6
17877	3964	2254	9
17878	3965	2295	14
17879	3965	2272	5
17880	3965	2263	5
17881	3965	2251	2
17882	3965	2252	6
17883	3965	2289	13
17884	3965	2250	7
17885	3966	2261	11
17886	3966	2267	14
17887	3966	2248	9
17888	3966	2275	11
17889	3966	2252	8
17890	3966	2289	4
17891	3966	2296	2
17892	3966	2278	6
17893	3967	2263	5
17894	3967	2251	3
17895	3967	2291	6
17896	3967	2242	4
17897	3967	2252	2
17898	3967	2249	5
17899	3967	2289	5
17900	3968	2297	5
17901	3968	2298	11
17902	3968	2299	8
17903	3968	2289	13
17904	3968	2244	5
17905	3968	2245	11
17906	3969	2300	6
17907	3969	2287	11
17908	3969	2286	9
17909	3969	2243	8
17910	3969	2270	9
17911	3969	2301	3
17912	3970	2302	9
17913	3970	2303	3
17914	3970	2304	2
17915	3970	2260	2
17916	3971	2305	4
17917	3971	2306	9
17918	3971	2307	8
17919	3971	2308	4
17920	3971	2304	7
17921	3971	2309	9
17922	3972	2310	4
17923	3972	2311	9
17924	3972	2312	7
17925	3972	2309	12
17926	3972	2313	5
17927	3972	2245	8
17928	3973	2314	6
17929	3973	2315	5
17930	3973	2316	3
17931	3973	2285	5
17932	3973	2309	6
17933	3973	2254	8
17934	3974	2317	8
17935	3974	2318	9
17936	3974	2319	9
17937	3974	2309	9
17938	3975	2320	4
17939	3975	2264	2
17940	3975	2281	2
17941	3975	2243	5
17942	3975	2289	3
17943	3975	2321	2
17944	3976	2322	4
17945	3976	2323	5
17946	3976	2264	11
17947	3976	2324	8
17948	3977	970	14
17949	3977	157	9
17950	3977	158	10
17951	3977	159	5
17952	3977	971	14
17953	3978	972	7
17954	3978	162	14
17955	3978	973	9
17956	3978	974	14
17957	3978	975	5
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
1	1	200928374	2
2	2	200947583	2
3	3	200937561	2
4	4	200975639	2
5	5	200909570	2
6	6	200983647	2
7	7	200917263	2
8	8	200912341	2
9	9	200934567	2
10	10	200912651	2
11	11	201000001	1
12	12	201000002	1
13	13	201000003	1
14	14	201000004	1
15	15	201000005	1
16	16	201000006	1
17	17	201000033	1
18	18	201092343	1
19	19	201032143	1
20	20	201092384	1
21	21	201123456	1
22	22	201100098	1
23	23	201110001	1
24	24	201110002	1
25	25	201111000	1
26	26	201192833	1
27	27	201123453	1
28	28	201100092	1
29	29	201100321	1
30	30	201101010	1
31	31	201209876	1
32	32	201212341	1
33	33	201234567	1
34	34	201202030	1
35	35	201212341	1
36	36	201212134	1
37	37	201210000	1
38	38	201220000	1
39	39	201230000	1
40	40	201240000	1
41	51	201125423	1
42	52	201103298	1
43	53	201110024	1
44	54	201110543	1
45	55	201111145	1
46	56	201192972	1
47	57	201125134	1
48	58	201104312	1
49	59	201106312	1
50	60	201105423	1
51	61	201198549	1
52	62	201121234	1
53	63	201106323	1
54	64	201185235	1
55	65	201176204	1
56	66	201135068	1
57	67	201001492	1
58	68	199938944	1
59	69	200258957	1
60	70	200261631	1
61	71	201156438	2
62	72	200302684	1
63	73	200306538	1
64	74	200427046	1
65	75	200505277	1
66	76	200571597	1
67	77	200604764	1
68	78	200611321	1
69	79	200618693	1
70	80	200645172	1
71	81	200678578	1
72	82	200678652	1
73	83	200660742	1
74	84	200660849	1
75	85	200702110	1
76	86	200716081	1
77	87	200722129	1
78	88	200727064	1
79	89	200729866	1
80	90	200737513	1
81	91	200742060	1
82	92	200746440	1
83	93	200746691	1
84	94	200750610	1
85	95	200776104	1
86	96	200703789	1
87	97	200801494	1
88	98	200804269	1
89	99	200805213	1
90	100	200806725	1
91	101	200807619	1
92	102	200810012	1
93	103	200810449	1
94	104	200812434	1
95	105	200816057	1
96	106	200816182	1
97	107	200818798	1
98	108	200820492	1
99	109	200820845	1
100	110	200822195	1
101	111	200824411	1
102	112	200826125	1
103	113	200826132	1
104	114	200829462	1
105	115	200831088	1
106	116	200835065	1
107	117	200838847	1
108	118	200850304	1
109	119	200854833	1
110	120	200859513	1
111	121	200861979	1
112	122	200863141	1
113	123	200863910	1
114	124	200863943	1
115	125	200867820	1
116	126	200867969	1
117	127	200869234	1
118	128	200878505	1
119	129	200878522	1
120	130	200879055	1
121	131	200751702	1
122	132	200649333	1
123	133	200704149	1
124	134	200800722	1
125	135	200800992	1
126	136	200802019	1
127	137	200805994	1
128	138	200810511	1
129	139	200810842	1
130	140	200815563	1
131	141	200816422	1
132	142	200817653	1
133	143	200850077	1
134	144	200852284	1
135	145	200865811	1
136	146	200900039	1
137	147	200900138	1
138	148	200900163	1
139	149	200900184	1
140	150	200900407	1
141	151	200900495	1
142	152	200900643	1
143	153	200900790	1
144	154	200901056	1
145	155	200903933	1
146	156	200904996	1
147	157	200905558	1
148	158	200906611	1
149	159	200906984	1
150	160	200907623	1
151	161	200909509	1
152	162	200910151	1
153	163	200910605	1
154	164	200911631	1
155	165	200911675	1
156	166	200911724	1
157	167	200911734	1
158	168	200911738	1
159	169	200911827	1
160	170	200912221	1
161	171	200912581	1
162	172	200912820	1
163	173	200912874	1
164	174	200912972	1
165	175	200913084	1
166	176	200913146	1
167	177	200913757	1
168	178	200913846	1
169	179	200913901	1
170	180	200914214	1
171	181	200914369	1
172	182	200914550	1
173	183	200915033	1
174	184	200920483	1
175	185	200920633	1
176	186	200921105	1
177	187	200921634	1
178	188	200922056	1
179	189	200922763	1
180	190	200922784	1
181	191	200922882	1
182	192	200924554	1
183	193	200925215	1
184	194	200925241	1
185	195	200925249	1
186	196	200925556	1
187	197	200925562	1
188	198	200926277	1
189	199	200926328	1
190	200	200926380	1
191	201	200926385	1
192	202	200929259	1
193	203	200929277	1
194	204	200929367	1
195	205	200929381	1
196	206	200929428	1
197	207	200929656	1
198	208	200930017	1
199	209	200932205	1
200	210	200933686	1
201	211	200935632	1
202	212	200936633	1
203	213	200937320	1
204	214	200939122	1
205	215	200940273	1
206	216	200942368	1
207	217	200942606	1
208	218	200945214	1
209	219	200945219	1
210	220	200950378	1
211	221	200950655	1
212	222	200950663	1
213	223	200951345	1
214	224	200951383	1
215	225	200952820	1
216	226	200952936	1
217	227	200953322	1
218	228	200953427	1
219	229	200953449	1
220	230	200953589	1
221	231	200953593	1
222	232	200953879	1
223	233	200953979	1
224	234	200954553	1
225	235	200955605	1
226	236	200957922	1
227	237	200960039	1
228	238	200962443	1
229	239	200978170	1
230	240	200978810	1
231	241	200978939	1
232	242	200819985	1
233	243	200824759	1
234	244	200865810	1
235	245	200804221	1
236	246	199938944	1
237	247	200258957	1
238	248	200261631	1
239	249	200302684	1
240	250	200306538	1
241	251	200427046	1
242	252	200505277	1
243	253	200571597	1
244	254	200604764	1
245	255	200611321	1
246	256	200618693	1
247	257	200645172	1
248	258	200678578	1
249	259	200678652	1
250	260	200660742	1
251	261	200660849	1
252	262	200702110	1
253	263	200716081	1
254	264	200722129	1
255	265	200727064	1
256	266	200729866	1
257	267	200737513	1
258	268	200742060	1
259	269	200746440	1
260	270	200746691	1
261	271	200750610	1
262	272	200776104	1
263	273	200703789	1
264	274	200801494	1
265	275	200804269	1
266	276	200805213	1
267	277	200806725	1
268	278	200807619	1
269	279	200810012	1
270	280	200810449	1
271	281	200812434	1
272	282	200816057	1
273	283	200816182	1
274	284	200818798	1
275	285	200820492	1
276	286	200820845	1
277	287	200822195	1
278	288	200824411	1
279	289	200826125	1
280	290	200826132	1
281	291	200829462	1
282	292	200831088	1
283	293	200835065	1
284	294	200838847	1
285	295	200850304	1
286	296	200854833	1
287	297	200859513	1
288	298	200861979	1
289	299	200863141	1
290	300	200863910	1
291	301	200863943	1
292	302	200867820	1
293	303	200867969	1
294	304	200869234	1
295	305	200878505	1
296	306	200878522	1
297	307	200879055	1
298	308	200751702	1
299	309	200649333	1
300	310	200704149	1
301	311	200800722	1
302	312	200802019	1
303	313	200805994	1
304	314	200810511	1
305	315	200810842	1
306	316	200815563	1
307	317	200816422	1
308	318	200817653	1
309	319	200850077	1
310	320	200852284	1
311	321	200865811	1
312	322	200900039	1
313	323	200900138	1
314	324	200900163	1
315	325	200900184	1
316	326	200900407	1
317	327	200900495	1
318	328	200900643	1
319	329	200900790	1
320	330	200901056	1
321	331	200903933	1
322	332	200904996	1
323	333	200905558	1
324	334	200906611	1
325	335	200906984	1
326	336	200907623	1
327	337	200909509	1
328	338	200910151	1
329	339	200910605	1
330	340	200911631	1
331	341	200911675	1
332	342	200911724	1
333	343	200911734	1
334	344	200911738	1
335	345	200911827	1
336	346	200912221	1
337	347	200912581	1
338	348	200912820	1
339	349	200912874	1
340	350	200912972	1
341	351	200913084	1
342	352	200913146	1
343	353	200913757	1
344	354	200913846	1
345	355	200913901	1
346	356	200914214	1
347	357	200914369	1
348	358	200914550	1
349	359	200915033	1
350	360	200920483	1
351	361	200920633	1
352	362	200921105	1
353	363	200921634	1
354	364	200922056	1
355	365	200922763	1
356	366	200922784	1
357	367	200922882	1
358	368	200924554	1
359	369	200925215	1
360	370	200925241	1
361	371	200925249	1
362	372	200925556	1
363	373	200925562	1
364	374	200926277	1
365	375	200926328	1
366	376	200926380	1
367	377	200926385	1
368	378	200929259	1
369	379	200929277	1
370	380	200929367	1
371	381	200929381	1
372	382	200929428	1
373	383	200929656	1
374	384	200930017	1
375	385	200932205	1
376	386	200933686	1
377	387	200935632	1
378	388	200936633	1
379	389	200937320	1
380	390	200939122	1
381	391	200940273	1
382	392	200942368	1
383	393	200942606	1
384	394	200945214	1
385	395	200945219	1
386	396	200950378	1
387	397	200950655	1
388	398	200950663	1
389	399	200951345	1
390	400	200951383	1
391	401	200952820	1
392	402	200952936	1
393	403	200953322	1
394	404	200953427	1
395	405	200953449	1
396	406	200953589	1
397	407	200953593	1
398	408	200953879	1
399	409	200953979	1
400	410	200954553	1
401	411	200955605	1
402	412	200957922	1
403	413	200960039	1
404	414	200962443	1
405	415	200978170	1
406	416	200978810	1
407	417	200978939	1
408	418	200819985	1
409	419	200824759	1
410	420	200865810	1
411	421	200804221	1
412	422	199938944	1
413	423	200258957	1
414	424	200261631	1
415	425	200302684	1
416	426	200306538	1
417	427	200427046	1
418	428	200505277	1
419	429	200571597	1
420	430	200604764	1
421	431	200611321	1
422	432	200618693	1
423	433	200645172	1
424	434	200678578	1
425	435	200678652	1
426	436	200660742	1
427	437	200660849	1
428	438	200702110	1
429	439	200716081	1
430	440	200722129	1
431	441	200727064	1
432	442	200729866	1
433	443	200737513	1
434	444	200742060	1
435	445	200746440	1
436	446	200746691	1
437	447	200750610	1
438	448	200776104	1
439	449	200703789	1
440	450	200801494	1
441	451	200804269	1
442	452	200805213	1
443	453	200806725	1
444	454	200807619	1
445	455	200810012	1
446	456	200810449	1
447	457	200812434	1
448	458	200816057	1
449	459	200816182	1
450	460	200818798	1
451	461	200820492	1
452	462	200820845	1
453	463	200822195	1
454	464	200824411	1
455	465	200826125	1
456	466	200826132	1
457	467	200829462	1
458	468	200831088	1
459	469	200835065	1
460	470	200838847	1
461	471	200850304	1
462	472	200854833	1
463	473	200859513	1
464	474	200861979	1
465	475	200863141	1
466	476	200863910	1
467	477	200863943	1
468	478	200867820	1
469	479	200867969	1
470	480	200869234	1
471	481	200878505	1
472	482	200878522	1
473	483	200879055	1
474	484	200751702	1
475	485	200649333	1
476	486	200704149	1
477	487	200800722	1
478	488	200800992	1
479	489	200802019	1
480	490	200805994	1
481	491	200810511	1
482	492	200810842	1
483	493	200815563	1
484	494	200816422	1
485	495	200817653	1
486	496	200850077	1
487	497	200852284	1
488	498	200865811	1
489	499	200900039	1
490	500	200900138	1
491	501	200900163	1
492	502	200900184	1
493	503	200900407	1
494	504	200900495	1
495	505	200900643	1
496	506	200900790	1
497	507	200901056	1
498	508	200903933	1
499	509	200904996	1
500	510	200905558	1
501	511	200906611	1
502	512	200906984	1
503	513	200907623	1
504	514	200909509	1
505	515	200910151	1
506	516	200910605	1
507	517	200911631	1
508	518	200911675	1
509	519	200911724	1
510	520	200911734	1
511	521	200911738	1
512	522	200911827	1
513	523	200912221	1
514	524	200912581	1
515	525	200912820	1
516	526	200912874	1
517	527	200912972	1
518	528	200913084	1
519	529	200913146	1
520	530	200913757	1
521	531	200913846	1
522	532	200913901	1
523	533	200914214	1
524	534	200914369	1
525	535	200914550	1
526	536	200915033	1
527	537	200920483	1
528	538	200920633	1
529	539	200921105	1
530	540	200921634	1
531	541	200922056	1
532	542	200922763	1
533	543	200922784	1
534	544	200922882	1
535	545	200924554	1
536	546	200925215	1
537	547	200925241	1
538	548	200925249	1
539	549	200925556	1
540	550	200925562	1
541	551	200926277	1
542	552	200926328	1
543	553	200926380	1
544	554	200926385	1
545	555	200929259	1
546	556	200929277	1
547	557	200929367	1
548	558	200929381	1
549	559	200929428	1
550	560	200929656	1
551	561	200930017	1
552	562	200932205	1
553	563	200933686	1
554	564	200935632	1
555	565	200936633	1
556	566	200937320	1
557	567	200939122	1
558	568	200940273	1
559	569	200942368	1
560	570	200942606	1
561	571	200945214	1
562	572	200945219	1
563	573	200950378	1
564	574	200950655	1
565	575	200950663	1
566	576	200951345	1
567	577	200951383	1
568	578	200952820	1
569	579	200952936	1
570	580	200953322	1
571	581	200953427	1
572	582	200953449	1
573	583	200953589	1
574	584	200953593	1
575	585	200953879	1
576	586	200953979	1
577	587	200954553	1
578	588	200955605	1
579	589	200957922	1
580	590	200960039	1
581	591	200962443	1
582	592	200978170	1
583	593	200978810	1
584	594	200978939	1
585	595	200819985	1
586	596	200824759	1
587	597	200865810	1
588	598	200804221	1
589	599	199938944	1
590	600	200258957	1
591	601	200261631	1
592	602	200302684	1
593	603	200306538	1
594	604	200427046	1
595	605	200505277	1
596	606	200571597	1
597	607	200604764	1
598	608	200611321	1
599	609	200618693	1
600	610	200645172	1
601	611	200678578	1
602	612	200678652	1
603	613	200660742	1
604	614	200660849	1
605	615	200702110	1
606	616	200716081	1
607	617	200722129	1
608	618	200727064	1
609	619	200729866	1
610	620	200737513	1
611	621	200742060	1
612	622	200746440	1
613	623	200746691	1
614	624	200750610	1
615	625	200776104	1
616	626	200703789	1
617	627	200801494	1
618	628	200804269	1
619	629	200805213	1
620	630	200806725	1
621	631	200807619	1
622	632	200810012	1
623	633	200810449	1
624	634	200812434	1
625	635	200816057	1
626	636	200816182	1
627	637	200818798	1
628	638	200820492	1
629	639	200820845	1
630	640	200822195	1
631	641	200824411	1
632	642	200826125	1
633	643	200826132	1
634	644	200829462	1
635	645	200831088	1
636	646	200835065	1
637	647	200838847	1
638	648	200850304	1
639	649	200854833	1
640	650	200859513	1
641	651	200861979	1
642	652	200863141	1
643	653	200863910	1
644	654	200863943	1
645	655	200867820	1
646	656	200867969	1
647	657	200869234	1
648	658	200878505	1
649	659	200878522	1
650	660	200879055	1
651	661	200751702	1
652	662	200649333	1
653	663	200704149	1
654	664	200800722	1
655	665	200800992	1
656	666	200802019	1
657	667	200805994	1
658	668	200810511	1
659	669	200810842	1
660	670	200815563	1
661	671	200816422	1
662	672	200817653	1
663	673	200850077	1
664	674	200852284	1
665	675	200865811	1
666	676	200900039	1
667	677	200900138	1
668	678	200900163	1
669	679	200900184	1
670	680	200900407	1
671	681	200900495	1
672	682	200900643	1
673	683	200900790	1
674	684	200901056	1
675	685	200903933	1
676	686	200904996	1
677	687	200905558	1
678	688	200906611	1
679	689	200906984	1
680	690	200907623	1
681	691	200909509	1
682	692	200910151	1
683	693	200910605	1
684	694	200911631	1
685	695	200911675	1
686	696	200911724	1
687	697	200911734	1
688	698	200911738	1
689	699	200911827	1
690	700	200912221	1
691	701	200912581	1
692	702	200912820	1
693	703	200912874	1
694	704	200912972	1
695	705	200913084	1
696	706	200913146	1
697	707	200913757	1
698	708	200913846	1
699	709	200913901	1
700	710	200914214	1
701	711	200914369	1
702	712	200914550	1
703	713	200915033	1
704	714	200920483	1
705	715	200920633	1
706	716	200921105	1
707	717	200921634	1
708	718	200922056	1
709	719	200922763	1
710	720	200922784	1
711	721	200922882	1
712	722	200924554	1
713	723	200925215	1
714	724	200925241	1
715	725	200925249	1
716	726	200925556	1
717	727	200925562	1
718	728	200926277	1
719	729	200926328	1
720	730	200926380	1
721	731	200926385	1
722	732	200929259	1
723	733	200929277	1
724	734	200929367	1
725	735	200929381	1
726	736	200929428	1
727	737	200929656	1
728	738	200930017	1
729	739	200932205	1
730	740	200933686	1
731	741	200935632	1
732	742	200936633	1
733	743	200937320	1
734	744	200939122	1
735	745	200940273	1
736	746	200942368	1
737	747	200942606	1
738	748	200945214	1
739	749	200945219	1
740	750	200950378	1
741	751	200950655	1
742	752	200950663	1
743	753	200951345	1
744	754	200951383	1
745	755	200952820	1
746	756	200952936	1
747	757	200953322	1
748	758	200953427	1
749	759	200953449	1
750	760	200953589	1
751	761	200953593	1
752	762	200953879	1
753	763	200953979	1
754	764	200954553	1
755	765	200955605	1
756	766	200957922	1
757	767	200960039	1
758	768	200962443	1
759	769	200978170	1
760	770	200978810	1
761	771	200978939	1
762	772	200819985	1
763	773	200824759	1
764	774	200865810	1
765	775	200804221	1
766	776	199938944	1
767	777	200258957	1
768	778	200261631	1
769	779	200302684	1
770	780	200306538	1
771	781	200427046	1
772	782	200505277	1
773	783	200571597	1
774	784	200604764	1
775	785	200611321	1
776	786	200618693	1
777	787	200645172	1
778	788	200678578	1
779	789	200678652	1
780	790	200660742	1
781	791	200660849	1
782	792	200702110	1
783	793	200716081	1
784	794	200722129	1
785	795	200727064	1
786	796	200729866	1
787	797	200737513	1
788	798	200742060	1
789	799	200746440	1
790	800	200746691	1
791	801	200750610	1
792	802	200776104	1
793	803	200703789	1
794	804	200801494	1
795	805	200804269	1
796	806	200805213	1
797	807	200806725	1
798	808	200807619	1
799	809	200810012	1
800	810	200810449	1
801	811	200812434	1
802	812	200816057	1
803	813	200816182	1
804	814	200818798	1
805	815	200820492	1
806	816	200820845	1
807	817	200822195	1
808	818	200824411	1
809	819	200826125	1
810	820	200826132	1
811	821	200829462	1
812	822	200831088	1
813	823	200835065	1
814	824	200838847	1
815	825	200850304	1
816	826	200854833	1
817	827	200859513	1
818	828	200861979	1
819	829	200863141	1
820	830	200863910	1
821	831	200863943	1
822	832	200867820	1
823	833	200867969	1
824	834	200869234	1
825	835	200878505	1
826	836	200878522	1
827	837	200879055	1
828	838	200751702	1
829	839	200649333	1
830	840	200704149	1
831	841	200800722	1
832	842	200800992	1
833	843	200802019	1
834	844	200805994	1
835	845	200810511	1
836	846	200810842	1
837	847	200815563	1
838	848	200816422	1
839	849	200817653	1
840	850	200850077	1
841	851	200852284	1
842	852	200865811	1
843	853	200900039	1
844	854	200900138	1
845	855	200900163	1
846	856	200900184	1
847	857	200900407	1
848	858	200900495	1
849	859	200900643	1
850	860	200900790	1
851	861	200901056	1
852	862	200903933	1
853	863	200904996	1
854	864	200905558	1
855	865	200906611	1
856	866	200906984	1
857	867	200907623	1
858	868	200909509	1
859	869	200910151	1
860	870	200910605	1
861	871	200911631	1
862	872	200911675	1
863	873	200911724	1
864	874	200911734	1
865	875	200911738	1
866	876	200911827	1
867	877	200912221	1
868	878	200912581	1
869	879	200912820	1
870	880	200912874	1
871	881	200912972	1
872	882	200913084	1
873	883	200913146	1
874	884	200913757	1
875	885	200913846	1
876	886	200913901	1
877	887	200914214	1
878	888	200914369	1
879	889	200914550	1
880	890	200915033	1
881	891	200920483	1
882	892	200920633	1
883	893	200921105	1
884	894	200921634	1
885	895	200922056	1
886	896	200922763	1
887	897	200922784	1
888	898	200922882	1
889	899	200924554	1
890	900	200925215	1
891	901	200925241	1
892	902	200925249	1
893	903	200925556	1
894	904	200925562	1
895	905	200926277	1
896	906	200926328	1
897	907	200926380	1
898	908	200926385	1
899	909	200929259	1
900	910	200929277	1
901	911	200929367	1
902	912	200929381	1
903	913	200929428	1
904	914	200929656	1
905	915	200930017	1
906	916	200932205	1
907	917	200933686	1
908	918	200935632	1
909	919	200936633	1
910	920	200937320	1
911	921	200939122	1
912	922	200940273	1
913	923	200942368	1
914	924	200942606	1
915	925	200945214	1
916	926	200945219	1
917	927	200950378	1
918	928	200950655	1
919	929	200950663	1
920	930	200951345	1
921	931	200951383	1
922	932	200952820	1
923	933	200952936	1
924	934	200953322	1
925	935	200953427	1
926	936	200953449	1
927	937	200953589	1
928	938	200953593	1
929	939	200953879	1
930	940	200953979	1
931	941	200954553	1
932	942	200955605	1
933	943	200957922	1
934	944	200960039	1
935	945	200962443	1
936	946	200978170	1
937	947	200978810	1
938	948	200978939	1
939	949	200819985	1
940	950	200824759	1
941	951	200865810	1
942	952	200804221	1
943	953	199938944	1
944	954	200258957	1
\.


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentterms (studenttermid, studentid, termid, ineligibilities, issettled) FROM stdin;
1	11	20121	N/A	t
2	12	20121	N/A	t
3	13	20121	N/A	t
4	14	20121	N/A	t
5	15	20121	N/A	t
6	16	20121	N/A	t
7	17	20121	N/A	t
8	18	20121	N/A	t
9	19	20121	N/A	t
10	20	20121	N/A	t
11	11	20101	N/A	t
12	12	20101	N/A	t
13	13	20101	N/A	t
14	14	20101	N/A	t
15	15	20101	N/A	t
16	16	20101	N/A	t
17	17	20101	N/A	t
18	18	20101	N/A	t
19	19	20101	N/A	t
20	20	20101	N/A	t
21	11	20102	N/A	t
22	12	20102	N/A	t
23	13	20102	N/A	t
24	14	20102	N/A	t
25	15	20102	N/A	t
26	16	20102	N/A	t
27	17	20102	N/A	t
28	18	20102	N/A	t
29	19	20102	N/A	t
30	20	20102	N/A	t
31	11	20103	N/A	t
32	12	20103	N/A	t
33	13	20103	N/A	t
34	14	20103	N/A	t
35	15	20103	N/A	t
36	11	20111	N/A	t
37	12	20111	N/A	t
38	13	20111	N/A	t
39	14	20111	N/A	t
40	15	20111	N/A	t
41	16	20111	N/A	t
42	17	20111	N/A	t
43	18	20111	N/A	t
44	19	20111	N/A	t
45	20	20111	N/A	t
46	11	20112	N/A	t
47	12	20112	N/A	t
48	13	20112	N/A	t
49	14	20112	N/A	t
50	15	20112	N/A	t
51	16	20112	N/A	t
52	17	20112	N/A	t
53	18	20112	N/A	t
54	19	20112	N/A	t
55	20	20112	N/A	t
56	1	20091	N/A	t
57	2	20091	N/A	t
58	3	20091	N/A	t
59	4	20091	N/A	t
60	5	20091	N/A	t
61	6	20091	N/A	t
62	7	20091	N/A	t
63	8	20091	N/A	t
64	9	20091	N/A	t
65	10	20091	N/A	t
66	21	20111	N/A	t
67	22	20111	N/A	t
68	23	20111	N/A	t
69	24	20111	N/A	t
70	25	20111	N/A	t
71	26	20111	N/A	t
72	27	20111	N/A	t
73	28	20111	N/A	t
74	29	20111	N/A	t
75	30	20111	N/A	t
76	21	20112	N/A	t
77	22	20112	N/A	t
78	23	20112	N/A	t
79	24	20112	N/A	t
80	25	20112	N/A	t
81	26	20112	N/A	t
82	27	20112	N/A	t
83	28	20112	N/A	t
84	29	20112	N/A	t
85	30	20112	N/A	t
86	21	20121	N/A	t
87	22	20121	N/A	t
88	23	20121	N/A	t
89	24	20121	N/A	t
90	25	20121	N/A	t
91	26	20121	N/A	t
92	27	20121	N/A	t
93	28	20121	N/A	t
94	29	20121	N/A	t
95	30	20121	N/A	t
96	31	20121	N/A	t
97	32	20121	N/A	t
98	33	20121	N/A	t
99	34	20121	N/A	t
100	35	20121	N/A	t
101	36	20121	N/A	t
102	37	20121	N/A	t
103	38	20121	N/A	t
104	39	20121	N/A	t
105	40	20121	N/A	t
106	41	20111	N/A	t
107	42	20111	N/A	t
108	43	20111	N/A	t
109	44	20111	N/A	t
110	45	20111	N/A	t
111	46	20111	N/A	t
112	47	20111	N/A	t
113	48	20111	N/A	t
114	49	20111	N/A	t
115	50	20111	N/A	t
116	51	20111	N/A	t
117	52	20111	N/A	t
118	53	20111	N/A	t
119	54	20111	N/A	t
120	55	20111	N/A	t
121	41	20112	N/A	t
122	42	20112	N/A	t
123	43	20112	N/A	t
124	44	20112	N/A	t
125	45	20112	N/A	t
126	46	20112	N/A	t
127	47	20112	N/A	t
128	48	20112	N/A	t
129	49	20112	N/A	t
130	50	20112	N/A	t
131	51	20112	N/A	t
132	52	20112	N/A	t
133	53	20112	N/A	t
134	54	20112	N/A	t
135	55	20112	N/A	t
136	41	20121	N/A	t
137	42	20121	N/A	t
138	43	20121	N/A	t
139	44	20121	N/A	t
140	45	20121	N/A	t
141	46	20121	N/A	t
142	47	20121	N/A	t
143	48	20121	N/A	t
144	49	20121	N/A	t
145	50	20121	N/A	t
146	51	20121	N/A	t
147	52	20121	N/A	t
148	53	20121	N/A	t
149	54	20121	N/A	t
150	55	20121	N/A	t
151	56	20111	N\\A	t
152	56	20112	N\\A	t
153	56	20121	N\\A	t
154	57	20101	N\\A	t
155	57	20102	N\\A	t
156	57	20111	N\\A	t
157	57	20112	N\\A	t
158	58	19991	N/A	t
159	58	20001	N/A	t
160	58	20002	N/A	t
161	58	20003	N/A	t
162	58	20011	N/A	t
163	58	20012	N/A	t
164	58	20013	N/A	t
165	58	20021	N/A	t
166	59	20021	N/A	t
167	60	20021	N/A	t
168	58	20022	N/A	t
169	59	20022	N/A	t
170	60	20022	N/A	t
171	58	20031	N/A	t
172	61	20121	N/A	t
173	59	20031	N/A	t
174	60	20031	N/A	t
175	62	20031	N/A	t
176	63	20031	N/A	t
177	58	20032	N/A	t
178	59	20032	N/A	t
179	60	20032	N/A	t
180	62	20032	N/A	t
181	63	20032	N/A	t
182	59	20033	N/A	t
183	60	20033	N/A	t
184	62	20033	N/A	t
185	63	20033	N/A	t
186	59	20041	N/A	t
187	60	20041	N/A	t
188	62	20041	N/A	t
189	63	20041	N/A	t
190	64	20041	N/A	t
191	59	20042	N/A	t
192	60	20042	N/A	t
193	62	20042	N/A	t
194	63	20042	N/A	t
195	64	20042	N/A	t
196	59	20043	N/A	t
197	60	20043	N/A	t
198	62	20043	N/A	t
199	63	20043	N/A	t
200	64	20043	N/A	t
201	59	20051	N/A	t
202	60	20051	N/A	t
203	62	20051	N/A	t
204	63	20051	N/A	t
205	64	20051	N/A	t
206	65	20051	N/A	t
207	66	20051	N/A	t
208	59	20052	N/A	t
209	60	20052	N/A	t
210	62	20052	N/A	t
211	64	20052	N/A	t
212	65	20052	N/A	t
213	66	20052	N/A	t
214	60	20053	N/A	t
215	62	20053	N/A	t
216	65	20053	N/A	t
217	66	20053	N/A	t
218	60	20061	N/A	t
219	64	20061	N/A	t
220	65	20061	N/A	t
221	66	20061	N/A	t
222	67	20061	N/A	t
223	68	20061	N/A	t
224	69	20061	N/A	t
225	70	20061	N/A	t
226	71	20061	N/A	t
227	72	20061	N/A	t
228	60	20062	N/A	t
229	63	20062	N/A	t
230	64	20062	N/A	t
231	65	20062	N/A	t
232	66	20062	N/A	t
233	67	20062	N/A	t
234	68	20062	N/A	t
235	69	20062	N/A	t
236	70	20062	N/A	t
237	71	20062	N/A	t
238	72	20062	N/A	t
239	64	20063	N/A	t
240	65	20063	N/A	t
241	66	20063	N/A	t
242	68	20063	N/A	t
243	69	20063	N/A	t
244	70	20063	N/A	t
245	71	20063	N/A	t
246	72	20063	N/A	t
247	63	20071	N/A	t
248	64	20071	N/A	t
249	65	20071	N/A	t
250	66	20071	N/A	t
251	67	20071	N/A	t
252	68	20071	N/A	t
253	69	20071	N/A	t
254	70	20071	N/A	t
255	73	20071	N/A	t
256	74	20071	N/A	t
257	71	20071	N/A	t
258	72	20071	N/A	t
259	75	20071	N/A	t
260	76	20071	N/A	t
261	77	20071	N/A	t
262	78	20071	N/A	t
263	79	20071	N/A	t
264	80	20071	N/A	t
265	81	20071	N/A	t
266	82	20071	N/A	t
267	83	20071	N/A	t
268	84	20071	N/A	t
269	85	20071	N/A	t
270	60	20072	N/A	t
271	63	20072	N/A	t
272	64	20072	N/A	t
273	65	20072	N/A	t
274	66	20072	N/A	t
275	67	20072	N/A	t
276	68	20072	N/A	t
277	69	20072	N/A	t
278	70	20072	N/A	t
279	73	20072	N/A	t
280	74	20072	N/A	t
281	71	20072	N/A	t
282	72	20072	N/A	t
283	75	20072	N/A	t
284	76	20072	N/A	t
285	77	20072	N/A	t
286	78	20072	N/A	t
287	79	20072	N/A	t
288	80	20072	N/A	t
289	81	20072	N/A	t
290	82	20072	N/A	t
291	83	20072	N/A	t
292	84	20072	N/A	t
293	85	20072	N/A	t
294	64	20073	N/A	t
295	66	20073	N/A	t
296	67	20073	N/A	t
297	68	20073	N/A	t
298	70	20073	N/A	t
299	73	20073	N/A	t
300	71	20073	N/A	t
301	72	20073	N/A	t
302	75	20073	N/A	t
303	77	20073	N/A	t
304	78	20073	N/A	t
305	80	20073	N/A	t
306	81	20073	N/A	t
307	63	20081	N/A	t
308	65	20081	N/A	t
309	66	20081	N/A	t
310	67	20081	N/A	t
311	68	20081	N/A	t
312	69	20081	N/A	t
313	70	20081	N/A	t
314	73	20081	N/A	t
315	74	20081	N/A	t
316	71	20081	N/A	t
317	72	20081	N/A	t
318	75	20081	N/A	t
319	86	20081	N/A	t
320	76	20081	N/A	t
321	77	20081	N/A	t
322	78	20081	N/A	t
323	79	20081	N/A	t
324	80	20081	N/A	t
325	81	20081	N/A	t
326	82	20081	N/A	t
327	83	20081	N/A	t
328	84	20081	N/A	t
329	85	20081	N/A	t
330	87	20081	N/A	t
331	88	20081	N/A	t
332	89	20081	N/A	t
333	90	20081	N/A	t
334	91	20081	N/A	t
335	92	20081	N/A	t
336	93	20081	N/A	t
337	94	20081	N/A	t
338	95	20081	N/A	t
339	96	20081	N/A	t
340	97	20081	N/A	t
341	98	20081	N/A	t
342	99	20081	N/A	t
343	100	20081	N/A	t
344	101	20081	N/A	t
345	102	20081	N/A	t
346	103	20081	N/A	t
347	104	20081	N/A	t
348	105	20081	N/A	t
349	106	20081	N/A	t
350	107	20081	N/A	t
351	108	20081	N/A	t
352	109	20081	N/A	t
353	110	20081	N/A	t
354	111	20081	N/A	t
355	112	20081	N/A	t
356	113	20081	N/A	t
357	114	20081	N/A	t
358	115	20081	N/A	t
359	116	20081	N/A	t
360	117	20081	N/A	t
361	118	20081	N/A	t
362	119	20081	N/A	t
363	120	20081	N/A	t
364	62	20082	N/A	t
365	63	20082	N/A	t
366	65	20082	N/A	t
367	66	20082	N/A	t
368	67	20082	N/A	t
369	68	20082	N/A	t
370	69	20082	N/A	t
371	70	20082	N/A	t
372	73	20082	N/A	t
373	74	20082	N/A	t
374	71	20082	N/A	t
375	72	20082	N/A	t
376	75	20082	N/A	t
377	86	20082	N/A	t
378	76	20082	N/A	t
379	77	20082	N/A	t
380	78	20082	N/A	t
381	79	20082	N/A	t
382	80	20082	N/A	t
383	81	20082	N/A	t
384	82	20082	N/A	t
385	83	20082	N/A	t
386	84	20082	N/A	t
387	121	20082	N/A	t
388	85	20082	N/A	t
389	87	20082	N/A	t
390	88	20082	N/A	t
391	89	20082	N/A	t
392	90	20082	N/A	t
393	91	20082	N/A	t
394	92	20082	N/A	t
395	93	20082	N/A	t
396	94	20082	N/A	t
397	95	20082	N/A	t
398	96	20082	N/A	t
399	97	20082	N/A	t
400	98	20082	N/A	t
401	99	20082	N/A	t
402	100	20082	N/A	t
403	101	20082	N/A	t
404	102	20082	N/A	t
405	103	20082	N/A	t
406	104	20082	N/A	t
407	105	20082	N/A	t
408	106	20082	N/A	t
409	107	20082	N/A	t
410	108	20082	N/A	t
411	109	20082	N/A	t
412	110	20082	N/A	t
413	111	20082	N/A	t
414	112	20082	N/A	t
415	113	20082	N/A	t
416	114	20082	N/A	t
417	115	20082	N/A	t
418	116	20082	N/A	t
419	117	20082	N/A	t
420	118	20082	N/A	t
421	119	20082	N/A	t
422	120	20082	N/A	t
423	62	20083	N/A	t
424	63	20083	N/A	t
425	68	20083	N/A	t
426	70	20083	N/A	t
427	73	20083	N/A	t
428	71	20083	N/A	t
429	75	20083	N/A	t
430	86	20083	N/A	t
431	77	20083	N/A	t
432	78	20083	N/A	t
433	80	20083	N/A	t
434	81	20083	N/A	t
435	82	20083	N/A	t
436	83	20083	N/A	t
437	121	20083	N/A	t
438	90	20083	N/A	t
439	91	20083	N/A	t
440	92	20083	N/A	t
441	96	20083	N/A	t
442	98	20083	N/A	t
443	99	20083	N/A	t
444	101	20083	N/A	t
445	102	20083	N/A	t
446	103	20083	N/A	t
447	106	20083	N/A	t
448	107	20083	N/A	t
449	108	20083	N/A	t
450	109	20083	N/A	t
451	110	20083	N/A	t
452	111	20083	N/A	t
453	114	20083	N/A	t
454	115	20083	N/A	t
455	116	20083	N/A	t
456	117	20083	N/A	t
457	118	20083	N/A	t
458	62	20091	N/A	t
459	63	20091	N/A	t
460	65	20091	N/A	t
461	66	20091	N/A	t
462	67	20091	N/A	t
463	68	20091	N/A	t
464	69	20091	N/A	t
465	70	20091	N/A	t
466	122	20091	N/A	t
467	73	20091	N/A	t
468	74	20091	N/A	t
469	71	20091	N/A	t
470	72	20091	N/A	t
471	75	20091	N/A	t
472	86	20091	N/A	t
473	123	20091	N/A	t
474	76	20091	N/A	t
475	77	20091	N/A	t
476	78	20091	N/A	t
477	79	20091	N/A	t
478	80	20091	N/A	t
479	81	20091	N/A	t
480	82	20091	N/A	t
481	83	20091	N/A	t
482	84	20091	N/A	t
483	121	20091	N/A	t
484	85	20091	N/A	t
485	124	20091	N/A	t
486	125	20091	N/A	t
487	87	20091	N/A	t
488	126	20091	N/A	t
489	88	20091	N/A	t
490	89	20091	N/A	t
491	127	20091	N/A	t
492	90	20091	N/A	t
493	91	20091	N/A	t
494	92	20091	N/A	t
495	93	20091	N/A	t
496	128	20091	N/A	t
497	129	20091	N/A	t
498	94	20091	N/A	t
499	130	20091	N/A	t
500	95	20091	N/A	t
501	96	20091	N/A	t
502	131	20091	N/A	t
503	132	20091	N/A	t
504	97	20091	N/A	t
505	98	20091	N/A	t
506	99	20091	N/A	t
507	100	20091	N/A	t
508	101	20091	N/A	t
509	102	20091	N/A	t
510	103	20091	N/A	t
511	104	20091	N/A	t
512	105	20091	N/A	t
513	106	20091	N/A	t
514	107	20091	N/A	t
515	133	20091	N/A	t
516	108	20091	N/A	t
517	134	20091	N/A	t
518	109	20091	N/A	t
519	110	20091	N/A	t
520	111	20091	N/A	t
521	112	20091	N/A	t
522	113	20091	N/A	t
523	114	20091	N/A	t
524	135	20091	N/A	t
525	115	20091	N/A	t
526	116	20091	N/A	t
527	117	20091	N/A	t
528	118	20091	N/A	t
529	119	20091	N/A	t
530	120	20091	N/A	t
531	136	20091	N/A	t
532	137	20091	N/A	t
533	138	20091	N/A	t
534	139	20091	N/A	t
535	140	20091	N/A	t
536	141	20091	N/A	t
537	142	20091	N/A	t
538	143	20091	N/A	t
539	144	20091	N/A	t
540	145	20091	N/A	t
541	146	20091	N/A	t
542	147	20091	N/A	t
543	148	20091	N/A	t
544	149	20091	N/A	t
545	150	20091	N/A	t
546	151	20091	N/A	t
547	152	20091	N/A	t
548	153	20091	N/A	t
549	154	20091	N/A	t
550	155	20091	N/A	t
551	156	20091	N/A	t
552	157	20091	N/A	t
553	158	20091	N/A	t
554	159	20091	N/A	t
555	160	20091	N/A	t
556	161	20091	N/A	t
557	162	20091	N/A	t
558	163	20091	N/A	t
559	164	20091	N/A	t
560	165	20091	N/A	t
561	166	20091	N/A	t
562	167	20091	N/A	t
563	168	20091	N/A	t
564	169	20091	N/A	t
565	170	20091	N/A	t
566	171	20091	N/A	t
567	172	20091	N/A	t
568	173	20091	N/A	t
569	174	20091	N/A	t
570	175	20091	N/A	t
571	176	20091	N/A	t
572	177	20091	N/A	t
573	178	20091	N/A	t
574	179	20091	N/A	t
575	180	20091	N/A	t
576	181	20091	N/A	t
577	182	20091	N/A	t
578	183	20091	N/A	t
579	184	20091	N/A	t
580	185	20091	N/A	t
581	186	20091	N/A	t
582	187	20091	N/A	t
583	188	20091	N/A	t
584	189	20091	N/A	t
585	190	20091	N/A	t
586	191	20091	N/A	t
587	192	20091	N/A	t
588	193	20091	N/A	t
589	194	20091	N/A	t
590	195	20091	N/A	t
591	196	20091	N/A	t
592	197	20091	N/A	t
593	198	20091	N/A	t
594	199	20091	N/A	t
595	200	20091	N/A	t
596	201	20091	N/A	t
597	202	20091	N/A	t
598	203	20091	N/A	t
599	204	20091	N/A	t
600	205	20091	N/A	t
601	206	20091	N/A	t
602	207	20091	N/A	t
603	208	20091	N/A	t
604	209	20091	N/A	t
605	210	20091	N/A	t
606	211	20091	N/A	t
607	212	20091	N/A	t
608	213	20091	N/A	t
609	214	20091	N/A	t
610	215	20091	N/A	t
611	216	20091	N/A	t
612	217	20091	N/A	t
613	218	20091	N/A	t
614	219	20091	N/A	t
615	220	20091	N/A	t
616	221	20091	N/A	t
617	222	20091	N/A	t
618	223	20091	N/A	t
619	224	20091	N/A	t
620	225	20091	N/A	t
621	226	20091	N/A	t
622	227	20091	N/A	t
623	228	20091	N/A	t
624	229	20091	N/A	t
625	230	20091	N/A	t
626	231	20091	N/A	t
627	62	20092	N/A	t
628	65	20092	N/A	t
629	67	20092	N/A	t
630	68	20092	N/A	t
631	69	20092	N/A	t
632	70	20092	N/A	t
633	122	20092	N/A	t
634	73	20092	N/A	t
635	74	20092	N/A	t
636	71	20092	N/A	t
637	72	20092	N/A	t
638	75	20092	N/A	t
639	86	20092	N/A	t
640	123	20092	N/A	t
641	76	20092	N/A	t
642	77	20092	N/A	t
643	78	20092	N/A	t
644	79	20092	N/A	t
645	80	20092	N/A	t
646	81	20092	N/A	t
647	82	20092	N/A	t
648	83	20092	N/A	t
649	84	20092	N/A	t
650	121	20092	N/A	t
651	85	20092	N/A	t
652	124	20092	N/A	t
653	125	20092	N/A	t
654	87	20092	N/A	t
655	126	20092	N/A	t
656	88	20092	N/A	t
657	89	20092	N/A	t
658	127	20092	N/A	t
659	90	20092	N/A	t
660	91	20092	N/A	t
661	92	20092	N/A	t
662	93	20092	N/A	t
663	128	20092	N/A	t
664	129	20092	N/A	t
665	94	20092	N/A	t
666	130	20092	N/A	t
667	95	20092	N/A	t
668	96	20092	N/A	t
669	131	20092	N/A	t
670	132	20092	N/A	t
671	97	20092	N/A	t
672	232	20092	N/A	t
673	98	20092	N/A	t
674	99	20092	N/A	t
675	100	20092	N/A	t
676	101	20092	N/A	t
677	233	20092	N/A	t
678	102	20092	N/A	t
679	103	20092	N/A	t
680	104	20092	N/A	t
681	105	20092	N/A	t
682	106	20092	N/A	t
683	107	20092	N/A	t
684	133	20092	N/A	t
685	108	20092	N/A	t
686	134	20092	N/A	t
687	109	20092	N/A	t
688	110	20092	N/A	t
689	111	20092	N/A	t
690	112	20092	N/A	t
691	113	20092	N/A	t
692	114	20092	N/A	t
693	234	20092	N/A	t
694	135	20092	N/A	t
695	115	20092	N/A	t
696	116	20092	N/A	t
697	117	20092	N/A	t
698	118	20092	N/A	t
699	119	20092	N/A	t
700	120	20092	N/A	t
701	136	20092	N/A	t
702	137	20092	N/A	t
703	138	20092	N/A	t
704	139	20092	N/A	t
705	140	20092	N/A	t
706	141	20092	N/A	t
707	142	20092	N/A	t
708	143	20092	N/A	t
709	144	20092	N/A	t
710	145	20092	N/A	t
711	146	20092	N/A	t
712	147	20092	N/A	t
713	148	20092	N/A	t
714	149	20092	N/A	t
715	150	20092	N/A	t
716	151	20092	N/A	t
717	152	20092	N/A	t
718	153	20092	N/A	t
719	154	20092	N/A	t
720	155	20092	N/A	t
721	156	20092	N/A	t
722	157	20092	N/A	t
723	158	20092	N/A	t
724	159	20092	N/A	t
725	160	20092	N/A	t
726	161	20092	N/A	t
727	162	20092	N/A	t
728	163	20092	N/A	t
729	164	20092	N/A	t
730	165	20092	N/A	t
731	166	20092	N/A	t
732	167	20092	N/A	t
733	168	20092	N/A	t
734	169	20092	N/A	t
735	170	20092	N/A	t
736	171	20092	N/A	t
737	172	20092	N/A	t
738	173	20092	N/A	t
739	174	20092	N/A	t
740	175	20092	N/A	t
741	176	20092	N/A	t
742	177	20092	N/A	t
743	178	20092	N/A	t
744	179	20092	N/A	t
745	180	20092	N/A	t
746	181	20092	N/A	t
747	182	20092	N/A	t
748	183	20092	N/A	t
749	184	20092	N/A	t
750	185	20092	N/A	t
751	186	20092	N/A	t
752	187	20092	N/A	t
753	188	20092	N/A	t
754	189	20092	N/A	t
755	190	20092	N/A	t
756	191	20092	N/A	t
757	192	20092	N/A	t
758	193	20092	N/A	t
759	194	20092	N/A	t
760	195	20092	N/A	t
761	196	20092	N/A	t
762	197	20092	N/A	t
763	198	20092	N/A	t
764	199	20092	N/A	t
765	200	20092	N/A	t
766	201	20092	N/A	t
767	202	20092	N/A	t
768	203	20092	N/A	t
769	204	20092	N/A	t
770	205	20092	N/A	t
771	206	20092	N/A	t
772	207	20092	N/A	t
773	208	20092	N/A	t
774	209	20092	N/A	t
775	210	20092	N/A	t
776	211	20092	N/A	t
777	212	20092	N/A	t
778	213	20092	N/A	t
779	214	20092	N/A	t
780	215	20092	N/A	t
781	216	20092	N/A	t
782	217	20092	N/A	t
783	218	20092	N/A	t
784	219	20092	N/A	t
785	220	20092	N/A	t
786	221	20092	N/A	t
787	222	20092	N/A	t
788	223	20092	N/A	t
789	224	20092	N/A	t
790	225	20092	N/A	t
791	226	20092	N/A	t
792	227	20092	N/A	t
793	228	20092	N/A	t
794	229	20092	N/A	t
795	230	20092	N/A	t
796	231	20092	N/A	t
797	62	20093	N/A	t
798	65	20093	N/A	t
799	67	20093	N/A	t
800	68	20093	N/A	t
801	70	20093	N/A	t
802	122	20093	N/A	t
803	74	20093	N/A	t
804	71	20093	N/A	t
805	72	20093	N/A	t
806	75	20093	N/A	t
807	76	20093	N/A	t
808	78	20093	N/A	t
809	79	20093	N/A	t
810	80	20093	N/A	t
811	83	20093	N/A	t
812	121	20093	N/A	t
813	125	20093	N/A	t
814	89	20093	N/A	t
815	127	20093	N/A	t
816	91	20093	N/A	t
817	92	20093	N/A	t
818	128	20093	N/A	t
819	129	20093	N/A	t
820	130	20093	N/A	t
821	95	20093	N/A	t
822	131	20093	N/A	t
823	132	20093	N/A	t
824	98	20093	N/A	t
825	99	20093	N/A	t
826	101	20093	N/A	t
827	102	20093	N/A	t
828	103	20093	N/A	t
829	105	20093	N/A	t
830	107	20093	N/A	t
831	108	20093	N/A	t
832	110	20093	N/A	t
833	112	20093	N/A	t
834	114	20093	N/A	t
835	135	20093	N/A	t
836	115	20093	N/A	t
837	116	20093	N/A	t
838	117	20093	N/A	t
839	136	20093	N/A	t
840	141	20093	N/A	t
841	142	20093	N/A	t
842	146	20093	N/A	t
843	148	20093	N/A	t
844	153	20093	N/A	t
845	155	20093	N/A	t
846	156	20093	N/A	t
847	158	20093	N/A	t
848	159	20093	N/A	t
849	160	20093	N/A	t
850	161	20093	N/A	t
851	162	20093	N/A	t
852	165	20093	N/A	t
853	168	20093	N/A	t
854	169	20093	N/A	t
855	171	20093	N/A	t
856	172	20093	N/A	t
857	173	20093	N/A	t
858	174	20093	N/A	t
859	176	20093	N/A	t
860	177	20093	N/A	t
861	186	20093	N/A	t
862	187	20093	N/A	t
863	188	20093	N/A	t
864	189	20093	N/A	t
865	193	20093	N/A	t
866	194	20093	N/A	t
867	196	20093	N/A	t
868	197	20093	N/A	t
869	198	20093	N/A	t
870	200	20093	N/A	t
871	202	20093	N/A	t
872	203	20093	N/A	t
873	204	20093	N/A	t
874	205	20093	N/A	t
875	206	20093	N/A	t
876	207	20093	N/A	t
877	209	20093	N/A	t
878	212	20093	N/A	t
879	213	20093	N/A	t
880	215	20093	N/A	t
881	216	20093	N/A	t
882	217	20093	N/A	t
883	218	20093	N/A	t
884	219	20093	N/A	t
885	220	20093	N/A	t
886	221	20093	N/A	t
887	222	20093	N/A	t
888	223	20093	N/A	t
889	224	20093	N/A	t
890	227	20093	N/A	t
891	228	20093	N/A	t
892	229	20093	N/A	t
893	230	20093	N/A	t
894	62	20101	N/A	t
895	65	20101	N/A	t
896	66	20101	N/A	t
897	67	20101	N/A	t
898	68	20101	N/A	t
899	70	20101	N/A	t
900	122	20101	N/A	t
901	73	20101	N/A	t
902	74	20101	N/A	t
903	71	20101	N/A	t
904	72	20101	N/A	t
905	75	20101	N/A	t
906	86	20101	N/A	t
907	123	20101	N/A	t
908	76	20101	N/A	t
909	77	20101	N/A	t
910	78	20101	N/A	t
911	79	20101	N/A	t
912	80	20101	N/A	t
913	81	20101	N/A	t
914	82	20101	N/A	t
915	83	20101	N/A	t
916	84	20101	N/A	t
917	121	20101	N/A	t
918	85	20101	N/A	t
919	124	20101	N/A	t
920	125	20101	N/A	t
921	87	20101	N/A	t
922	126	20101	N/A	t
923	235	20101	N/A	t
924	88	20101	N/A	t
925	89	20101	N/A	t
926	236	19991	N/A	t
927	236	20001	N/A	t
928	236	20002	N/A	t
929	236	20003	N/A	t
930	236	20011	N/A	t
931	236	20012	N/A	t
932	236	20013	N/A	t
933	236	20021	N/A	t
934	237	20021	N/A	t
935	238	20021	N/A	t
936	236	20022	N/A	t
937	237	20022	N/A	t
938	238	20022	N/A	t
939	236	20031	N/A	t
940	237	20031	N/A	t
941	238	20031	N/A	t
942	239	20031	N/A	t
943	240	20031	N/A	t
944	236	20032	N/A	t
945	237	20032	N/A	t
946	238	20032	N/A	t
947	239	20032	N/A	t
948	240	20032	N/A	t
949	237	20033	N/A	t
950	238	20033	N/A	t
951	239	20033	N/A	t
952	240	20033	N/A	t
953	237	20041	N/A	t
954	238	20041	N/A	t
955	239	20041	N/A	t
956	240	20041	N/A	t
957	241	20041	N/A	t
958	237	20042	N/A	t
959	238	20042	N/A	t
960	239	20042	N/A	t
961	240	20042	N/A	t
962	241	20042	N/A	t
963	237	20043	N/A	t
964	238	20043	N/A	t
965	239	20043	N/A	t
966	240	20043	N/A	t
967	241	20043	N/A	t
968	237	20051	N/A	t
969	238	20051	N/A	t
970	239	20051	N/A	t
971	240	20051	N/A	t
972	241	20051	N/A	t
973	242	20051	N/A	t
974	243	20051	N/A	t
975	237	20052	N/A	t
976	238	20052	N/A	t
977	239	20052	N/A	t
978	241	20052	N/A	t
979	242	20052	N/A	t
980	243	20052	N/A	t
981	238	20053	N/A	t
982	239	20053	N/A	t
983	242	20053	N/A	t
984	243	20053	N/A	t
985	238	20061	N/A	t
986	241	20061	N/A	t
987	242	20061	N/A	t
988	243	20061	N/A	t
989	244	20061	N/A	t
990	245	20061	N/A	t
991	246	20061	N/A	t
992	247	20061	N/A	t
993	248	20061	N/A	t
994	249	20061	N/A	t
995	238	20062	N/A	t
996	240	20062	N/A	t
997	241	20062	N/A	t
998	242	20062	N/A	t
999	243	20062	N/A	t
1000	244	20062	N/A	t
1001	245	20062	N/A	t
1002	246	20062	N/A	t
1003	247	20062	N/A	t
1004	248	20062	N/A	t
1005	249	20062	N/A	t
1006	241	20063	N/A	t
1007	242	20063	N/A	t
1008	243	20063	N/A	t
1009	245	20063	N/A	t
1010	246	20063	N/A	t
1011	247	20063	N/A	t
1012	248	20063	N/A	t
1013	249	20063	N/A	t
1014	240	20071	N/A	t
1015	241	20071	N/A	t
1016	242	20071	N/A	t
1017	243	20071	N/A	t
1018	244	20071	N/A	t
1019	245	20071	N/A	t
1020	246	20071	N/A	t
1021	247	20071	N/A	t
1022	250	20071	N/A	t
1023	251	20071	N/A	t
1024	248	20071	N/A	t
1025	249	20071	N/A	t
1026	252	20071	N/A	t
1027	253	20071	N/A	t
1028	254	20071	N/A	t
1029	255	20071	N/A	t
1030	256	20071	N/A	t
1031	257	20071	N/A	t
1032	258	20071	N/A	t
1033	259	20071	N/A	t
1034	260	20071	N/A	t
1035	261	20071	N/A	t
1036	262	20071	N/A	t
1037	238	20072	N/A	t
1038	240	20072	N/A	t
1039	241	20072	N/A	t
1040	242	20072	N/A	t
1041	243	20072	N/A	t
1042	244	20072	N/A	t
1043	245	20072	N/A	t
1044	246	20072	N/A	t
1045	247	20072	N/A	t
1046	250	20072	N/A	t
1047	251	20072	N/A	t
1048	248	20072	N/A	t
1049	249	20072	N/A	t
1050	252	20072	N/A	t
1051	253	20072	N/A	t
1052	254	20072	N/A	t
1053	255	20072	N/A	t
1054	256	20072	N/A	t
1055	257	20072	N/A	t
1056	258	20072	N/A	t
1057	259	20072	N/A	t
1058	260	20072	N/A	t
1059	261	20072	N/A	t
1060	262	20072	N/A	t
1061	241	20073	N/A	t
1062	243	20073	N/A	t
1063	244	20073	N/A	t
1064	245	20073	N/A	t
1065	247	20073	N/A	t
1066	250	20073	N/A	t
1067	248	20073	N/A	t
1068	249	20073	N/A	t
1069	252	20073	N/A	t
1070	254	20073	N/A	t
1071	255	20073	N/A	t
1072	257	20073	N/A	t
1073	258	20073	N/A	t
1074	240	20081	N/A	t
1075	242	20081	N/A	t
1076	243	20081	N/A	t
1077	244	20081	N/A	t
1078	245	20081	N/A	t
1079	246	20081	N/A	t
1080	247	20081	N/A	t
1081	250	20081	N/A	t
1082	251	20081	N/A	t
1083	248	20081	N/A	t
1084	249	20081	N/A	t
1085	252	20081	N/A	t
1086	263	20081	N/A	t
1087	253	20081	N/A	t
1088	254	20081	N/A	t
1089	255	20081	N/A	t
1090	256	20081	N/A	t
1091	257	20081	N/A	t
1092	258	20081	N/A	t
1093	259	20081	N/A	t
1094	260	20081	N/A	t
1095	261	20081	N/A	t
1096	262	20081	N/A	t
1097	264	20081	N/A	t
1098	265	20081	N/A	t
1099	266	20081	N/A	t
1100	267	20081	N/A	t
1101	268	20081	N/A	t
1102	269	20081	N/A	t
1103	270	20081	N/A	t
1104	271	20081	N/A	t
1105	272	20081	N/A	t
1106	273	20081	N/A	t
1107	274	20081	N/A	t
1108	275	20081	N/A	t
1109	276	20081	N/A	t
1110	277	20081	N/A	t
1111	278	20081	N/A	t
1112	279	20081	N/A	t
1113	280	20081	N/A	t
1114	281	20081	N/A	t
1115	282	20081	N/A	t
1116	283	20081	N/A	t
1117	284	20081	N/A	t
1118	285	20081	N/A	t
1119	286	20081	N/A	t
1120	287	20081	N/A	t
1121	288	20081	N/A	t
1122	289	20081	N/A	t
1123	290	20081	N/A	t
1124	291	20081	N/A	t
1125	292	20081	N/A	t
1126	293	20081	N/A	t
1127	294	20081	N/A	t
1128	295	20081	N/A	t
1129	296	20081	N/A	t
1130	297	20081	N/A	t
1131	239	20082	N/A	t
1132	240	20082	N/A	t
1133	242	20082	N/A	t
1134	243	20082	N/A	t
1135	244	20082	N/A	t
1136	245	20082	N/A	t
1137	246	20082	N/A	t
1138	247	20082	N/A	t
1139	250	20082	N/A	t
1140	251	20082	N/A	t
1141	248	20082	N/A	t
1142	249	20082	N/A	t
1143	252	20082	N/A	t
1144	263	20082	N/A	t
1145	253	20082	N/A	t
1146	254	20082	N/A	t
1147	255	20082	N/A	t
1148	256	20082	N/A	t
1149	257	20082	N/A	t
1150	258	20082	N/A	t
1151	259	20082	N/A	t
1152	260	20082	N/A	t
1153	261	20082	N/A	t
1154	298	20082	N/A	t
1155	262	20082	N/A	t
1156	264	20082	N/A	t
1157	265	20082	N/A	t
1158	266	20082	N/A	t
1159	267	20082	N/A	t
1160	268	20082	N/A	t
1161	269	20082	N/A	t
1162	270	20082	N/A	t
1163	271	20082	N/A	t
1164	272	20082	N/A	t
1165	273	20082	N/A	t
1166	274	20082	N/A	t
1167	275	20082	N/A	t
1168	276	20082	N/A	t
1169	277	20082	N/A	t
1170	278	20082	N/A	t
1171	279	20082	N/A	t
1172	280	20082	N/A	t
1173	281	20082	N/A	t
1174	282	20082	N/A	t
1175	283	20082	N/A	t
1176	284	20082	N/A	t
1177	285	20082	N/A	t
1178	286	20082	N/A	t
1179	287	20082	N/A	t
1180	288	20082	N/A	t
1181	289	20082	N/A	t
1182	290	20082	N/A	t
1183	291	20082	N/A	t
1184	292	20082	N/A	t
1185	293	20082	N/A	t
1186	294	20082	N/A	t
1187	295	20082	N/A	t
1188	296	20082	N/A	t
1189	297	20082	N/A	t
1190	239	20083	N/A	t
1191	240	20083	N/A	t
1192	245	20083	N/A	t
1193	247	20083	N/A	t
1194	250	20083	N/A	t
1195	248	20083	N/A	t
1196	252	20083	N/A	t
1197	263	20083	N/A	t
1198	254	20083	N/A	t
1199	255	20083	N/A	t
1200	257	20083	N/A	t
1201	258	20083	N/A	t
1202	259	20083	N/A	t
1203	260	20083	N/A	t
1204	298	20083	N/A	t
1205	267	20083	N/A	t
1206	268	20083	N/A	t
1207	269	20083	N/A	t
1208	273	20083	N/A	t
1209	275	20083	N/A	t
1210	276	20083	N/A	t
1211	278	20083	N/A	t
1212	279	20083	N/A	t
1213	280	20083	N/A	t
1214	283	20083	N/A	t
1215	284	20083	N/A	t
1216	285	20083	N/A	t
1217	286	20083	N/A	t
1218	287	20083	N/A	t
1219	288	20083	N/A	t
1220	291	20083	N/A	t
1221	292	20083	N/A	t
1222	293	20083	N/A	t
1223	294	20083	N/A	t
1224	295	20083	N/A	t
1225	239	20091	N/A	t
1226	240	20091	N/A	t
1227	242	20091	N/A	t
1228	243	20091	N/A	t
1229	244	20091	N/A	t
1230	245	20091	N/A	t
1231	246	20091	N/A	t
1232	247	20091	N/A	t
1233	299	20091	N/A	t
1234	250	20091	N/A	t
1235	251	20091	N/A	t
1236	248	20091	N/A	t
1237	249	20091	N/A	t
1238	252	20091	N/A	t
1239	263	20091	N/A	t
1240	300	20091	N/A	t
1241	253	20091	N/A	t
1242	254	20091	N/A	t
1243	255	20091	N/A	t
1244	256	20091	N/A	t
1245	257	20091	N/A	t
1246	258	20091	N/A	t
1247	259	20091	N/A	t
1248	260	20091	N/A	t
1249	261	20091	N/A	t
1250	298	20091	N/A	t
1251	262	20091	N/A	t
1252	301	20091	N/A	t
1253	264	20091	N/A	t
1254	302	20091	N/A	t
1255	265	20091	N/A	t
1256	266	20091	N/A	t
1257	303	20091	N/A	t
1258	267	20091	N/A	t
1259	268	20091	N/A	t
1260	269	20091	N/A	t
1261	270	20091	N/A	t
1262	304	20091	N/A	t
1263	305	20091	N/A	t
1264	271	20091	N/A	t
1265	306	20091	N/A	t
1266	272	20091	N/A	t
1267	273	20091	N/A	t
1268	307	20091	N/A	t
1269	308	20091	N/A	t
1270	274	20091	N/A	t
1271	275	20091	N/A	t
1272	276	20091	N/A	t
1273	277	20091	N/A	t
1274	278	20091	N/A	t
1275	279	20091	N/A	t
1276	280	20091	N/A	t
1277	281	20091	N/A	t
1278	282	20091	N/A	t
1279	283	20091	N/A	t
1280	284	20091	N/A	t
1281	309	20091	N/A	t
1282	285	20091	N/A	t
1283	310	20091	N/A	t
1284	286	20091	N/A	t
1285	287	20091	N/A	t
1286	288	20091	N/A	t
1287	289	20091	N/A	t
1288	290	20091	N/A	t
1289	291	20091	N/A	t
1290	311	20091	N/A	t
1291	292	20091	N/A	t
1292	293	20091	N/A	t
1293	294	20091	N/A	t
1294	295	20091	N/A	t
1295	296	20091	N/A	t
1296	297	20091	N/A	t
1297	312	20091	N/A	t
1298	313	20091	N/A	t
1299	314	20091	N/A	t
1300	315	20091	N/A	t
1301	316	20091	N/A	t
1302	317	20091	N/A	t
1303	318	20091	N/A	t
1304	319	20091	N/A	t
1305	320	20091	N/A	t
1306	321	20091	N/A	t
1307	322	20091	N/A	t
1308	323	20091	N/A	t
1309	324	20091	N/A	t
1310	325	20091	N/A	t
1311	326	20091	N/A	t
1312	327	20091	N/A	t
1313	328	20091	N/A	t
1314	329	20091	N/A	t
1315	330	20091	N/A	t
1316	331	20091	N/A	t
1317	332	20091	N/A	t
1318	333	20091	N/A	t
1319	334	20091	N/A	t
1320	335	20091	N/A	t
1321	336	20091	N/A	t
1322	337	20091	N/A	t
1323	338	20091	N/A	t
1324	339	20091	N/A	t
1325	340	20091	N/A	t
1326	341	20091	N/A	t
1327	342	20091	N/A	t
1328	343	20091	N/A	t
1329	344	20091	N/A	t
1330	345	20091	N/A	t
1331	346	20091	N/A	t
1332	347	20091	N/A	t
1333	348	20091	N/A	t
1334	349	20091	N/A	t
1335	350	20091	N/A	t
1336	351	20091	N/A	t
1337	352	20091	N/A	t
1338	353	20091	N/A	t
1339	354	20091	N/A	t
1340	355	20091	N/A	t
1341	356	20091	N/A	t
1342	357	20091	N/A	t
1343	358	20091	N/A	t
1344	359	20091	N/A	t
1345	360	20091	N/A	t
1346	361	20091	N/A	t
1347	362	20091	N/A	t
1348	363	20091	N/A	t
1349	364	20091	N/A	t
1350	365	20091	N/A	t
1351	366	20091	N/A	t
1352	367	20091	N/A	t
1353	368	20091	N/A	t
1354	369	20091	N/A	t
1355	370	20091	N/A	t
1356	371	20091	N/A	t
1357	372	20091	N/A	t
1358	373	20091	N/A	t
1359	374	20091	N/A	t
1360	375	20091	N/A	t
1361	376	20091	N/A	t
1362	377	20091	N/A	t
1363	378	20091	N/A	t
1364	379	20091	N/A	t
1365	380	20091	N/A	t
1366	381	20091	N/A	t
1367	382	20091	N/A	t
1368	383	20091	N/A	t
1369	384	20091	N/A	t
1370	385	20091	N/A	t
1371	386	20091	N/A	t
1372	387	20091	N/A	t
1373	388	20091	N/A	t
1374	389	20091	N/A	t
1375	390	20091	N/A	t
1376	391	20091	N/A	t
1377	392	20091	N/A	t
1378	393	20091	N/A	t
1379	394	20091	N/A	t
1380	395	20091	N/A	t
1381	396	20091	N/A	t
1382	397	20091	N/A	t
1383	398	20091	N/A	t
1384	399	20091	N/A	t
1385	400	20091	N/A	t
1386	401	20091	N/A	t
1387	402	20091	N/A	t
1388	403	20091	N/A	t
1389	404	20091	N/A	t
1390	405	20091	N/A	t
1391	406	20091	N/A	t
1392	407	20091	N/A	t
1393	239	20092	N/A	t
1394	242	20092	N/A	t
1395	244	20092	N/A	t
1396	245	20092	N/A	t
1397	246	20092	N/A	t
1398	247	20092	N/A	t
1399	299	20092	N/A	t
1400	250	20092	N/A	t
1401	251	20092	N/A	t
1402	248	20092	N/A	t
1403	249	20092	N/A	t
1404	252	20092	N/A	t
1405	263	20092	N/A	t
1406	300	20092	N/A	t
1407	253	20092	N/A	t
1408	254	20092	N/A	t
1409	255	20092	N/A	t
1410	256	20092	N/A	t
1411	257	20092	N/A	t
1412	258	20092	N/A	t
1413	259	20092	N/A	t
1414	260	20092	N/A	t
1415	261	20092	N/A	t
1416	298	20092	N/A	t
1417	262	20092	N/A	t
1418	301	20092	N/A	t
1419	264	20092	N/A	t
1420	302	20092	N/A	t
1421	265	20092	N/A	t
1422	266	20092	N/A	t
1423	303	20092	N/A	t
1424	267	20092	N/A	t
1425	268	20092	N/A	t
1426	269	20092	N/A	t
1427	270	20092	N/A	t
1428	304	20092	N/A	t
1429	305	20092	N/A	t
1430	271	20092	N/A	t
1431	306	20092	N/A	t
1432	272	20092	N/A	t
1433	273	20092	N/A	t
1434	307	20092	N/A	t
1435	308	20092	N/A	t
1436	274	20092	N/A	t
1437	408	20092	N/A	t
1438	275	20092	N/A	t
1439	276	20092	N/A	t
1440	277	20092	N/A	t
1441	278	20092	N/A	t
1442	409	20092	N/A	t
1443	279	20092	N/A	t
1444	280	20092	N/A	t
1445	281	20092	N/A	t
1446	282	20092	N/A	t
1447	283	20092	N/A	t
1448	284	20092	N/A	t
1449	309	20092	N/A	t
1450	285	20092	N/A	t
1451	310	20092	N/A	t
1452	286	20092	N/A	t
1453	287	20092	N/A	t
1454	288	20092	N/A	t
1455	289	20092	N/A	t
1456	290	20092	N/A	t
1457	291	20092	N/A	t
1458	410	20092	N/A	t
1459	311	20092	N/A	t
1460	292	20092	N/A	t
1461	293	20092	N/A	t
1462	294	20092	N/A	t
1463	295	20092	N/A	t
1464	296	20092	N/A	t
1465	297	20092	N/A	t
1466	312	20092	N/A	t
1467	313	20092	N/A	t
1468	314	20092	N/A	t
1469	315	20092	N/A	t
1470	316	20092	N/A	t
1471	317	20092	N/A	t
1472	318	20092	N/A	t
1473	319	20092	N/A	t
1474	320	20092	N/A	t
1475	321	20092	N/A	t
1476	322	20092	N/A	t
1477	323	20092	N/A	t
1478	324	20092	N/A	t
1479	325	20092	N/A	t
1480	326	20092	N/A	t
1481	327	20092	N/A	t
1482	328	20092	N/A	t
1483	329	20092	N/A	t
1484	330	20092	N/A	t
1485	331	20092	N/A	t
1486	332	20092	N/A	t
1487	333	20092	N/A	t
1488	334	20092	N/A	t
1489	335	20092	N/A	t
1490	336	20092	N/A	t
1491	337	20092	N/A	t
1492	338	20092	N/A	t
1493	339	20092	N/A	t
1494	340	20092	N/A	t
1495	341	20092	N/A	t
1496	342	20092	N/A	t
1497	343	20092	N/A	t
1498	344	20092	N/A	t
1499	345	20092	N/A	t
1500	346	20092	N/A	t
1501	347	20092	N/A	t
1502	348	20092	N/A	t
1503	349	20092	N/A	t
1504	350	20092	N/A	t
1505	351	20092	N/A	t
1506	352	20092	N/A	t
1507	353	20092	N/A	t
1508	354	20092	N/A	t
1509	355	20092	N/A	t
1510	356	20092	N/A	t
1511	357	20092	N/A	t
1512	358	20092	N/A	t
1513	359	20092	N/A	t
1514	360	20092	N/A	t
1515	361	20092	N/A	t
1516	362	20092	N/A	t
1517	363	20092	N/A	t
1518	364	20092	N/A	t
1519	365	20092	N/A	t
1520	366	20092	N/A	t
1521	367	20092	N/A	t
1522	368	20092	N/A	t
1523	369	20092	N/A	t
1524	370	20092	N/A	t
1525	371	20092	N/A	t
1526	372	20092	N/A	t
1527	373	20092	N/A	t
1528	374	20092	N/A	t
1529	375	20092	N/A	t
1530	376	20092	N/A	t
1531	377	20092	N/A	t
1532	378	20092	N/A	t
1533	379	20092	N/A	t
1534	380	20092	N/A	t
1535	381	20092	N/A	t
1536	382	20092	N/A	t
1537	383	20092	N/A	t
1538	384	20092	N/A	t
1539	385	20092	N/A	t
1540	386	20092	N/A	t
1541	387	20092	N/A	t
1542	388	20092	N/A	t
1543	389	20092	N/A	t
1544	390	20092	N/A	t
1545	391	20092	N/A	t
1546	392	20092	N/A	t
1547	393	20092	N/A	t
1548	394	20092	N/A	t
1549	395	20092	N/A	t
1550	396	20092	N/A	t
1551	397	20092	N/A	t
1552	398	20092	N/A	t
1553	399	20092	N/A	t
1554	400	20092	N/A	t
1555	401	20092	N/A	t
1556	402	20092	N/A	t
1557	403	20092	N/A	t
1558	404	20092	N/A	t
1559	405	20092	N/A	t
1560	406	20092	N/A	t
1561	407	20092	N/A	t
1562	239	20093	N/A	t
1563	242	20093	N/A	t
1564	244	20093	N/A	t
1565	245	20093	N/A	t
1566	247	20093	N/A	t
1567	299	20093	N/A	t
1568	251	20093	N/A	t
1569	248	20093	N/A	t
1570	249	20093	N/A	t
1571	252	20093	N/A	t
1572	253	20093	N/A	t
1573	255	20093	N/A	t
1574	256	20093	N/A	t
1575	257	20093	N/A	t
1576	260	20093	N/A	t
1577	298	20093	N/A	t
1578	266	20093	N/A	t
1579	303	20093	N/A	t
1580	268	20093	N/A	t
1581	269	20093	N/A	t
1582	304	20093	N/A	t
1583	305	20093	N/A	t
1584	306	20093	N/A	t
1585	272	20093	N/A	t
1586	307	20093	N/A	t
1587	308	20093	N/A	t
1588	275	20093	N/A	t
1589	276	20093	N/A	t
1590	278	20093	N/A	t
1591	279	20093	N/A	t
1592	280	20093	N/A	t
1593	282	20093	N/A	t
1594	284	20093	N/A	t
1595	285	20093	N/A	t
1596	287	20093	N/A	t
1597	289	20093	N/A	t
1598	291	20093	N/A	t
1599	311	20093	N/A	t
1600	292	20093	N/A	t
1601	293	20093	N/A	t
1602	294	20093	N/A	t
1603	312	20093	N/A	t
1604	317	20093	N/A	t
1605	318	20093	N/A	t
1606	322	20093	N/A	t
1607	324	20093	N/A	t
1608	329	20093	N/A	t
1609	331	20093	N/A	t
1610	332	20093	N/A	t
1611	334	20093	N/A	t
1612	335	20093	N/A	t
1613	336	20093	N/A	t
1614	337	20093	N/A	t
1615	338	20093	N/A	t
1616	341	20093	N/A	t
1617	344	20093	N/A	t
1618	345	20093	N/A	t
1619	347	20093	N/A	t
1620	348	20093	N/A	t
1621	349	20093	N/A	t
1622	350	20093	N/A	t
1623	352	20093	N/A	t
1624	353	20093	N/A	t
1625	362	20093	N/A	t
1626	363	20093	N/A	t
1627	364	20093	N/A	t
1628	365	20093	N/A	t
1629	369	20093	N/A	t
1630	370	20093	N/A	t
1631	372	20093	N/A	t
1632	373	20093	N/A	t
1633	374	20093	N/A	t
1634	376	20093	N/A	t
1635	378	20093	N/A	t
1636	379	20093	N/A	t
1637	380	20093	N/A	t
1638	381	20093	N/A	t
1639	382	20093	N/A	t
1640	383	20093	N/A	t
1641	385	20093	N/A	t
1642	388	20093	N/A	t
1643	389	20093	N/A	t
1644	391	20093	N/A	t
1645	392	20093	N/A	t
1646	393	20093	N/A	t
1647	394	20093	N/A	t
1648	395	20093	N/A	t
1649	396	20093	N/A	t
1650	397	20093	N/A	t
1651	398	20093	N/A	t
1652	399	20093	N/A	t
1653	400	20093	N/A	t
1654	403	20093	N/A	t
1655	404	20093	N/A	t
1656	405	20093	N/A	t
1657	406	20093	N/A	t
1658	239	20101	N/A	t
1659	242	20101	N/A	t
1660	243	20101	N/A	t
1661	244	20101	N/A	t
1662	245	20101	N/A	t
1663	247	20101	N/A	t
1664	299	20101	N/A	t
1665	250	20101	N/A	t
1666	251	20101	N/A	t
1667	248	20101	N/A	t
1668	249	20101	N/A	t
1669	252	20101	N/A	t
1670	263	20101	N/A	t
1671	300	20101	N/A	t
1672	253	20101	N/A	t
1673	254	20101	N/A	t
1674	255	20101	N/A	t
1675	256	20101	N/A	t
1676	257	20101	N/A	t
1677	258	20101	N/A	t
1678	259	20101	N/A	t
1679	260	20101	N/A	t
1680	261	20101	N/A	t
1681	298	20101	N/A	t
1682	262	20101	N/A	t
1683	301	20101	N/A	t
1684	264	20101	N/A	t
1685	302	20101	N/A	t
1686	411	20101	N/A	t
1687	265	20101	N/A	t
1688	266	20101	N/A	t
1689	412	20031	N/A	t
1690	413	20031	N/A	t
1691	414	20031	N/A	t
1692	415	20031	N/A	t
1693	416	20031	N/A	t
1694	412	20032	N/A	t
1695	413	20032	N/A	t
1696	414	20032	N/A	t
1697	415	20032	N/A	t
1698	416	20032	N/A	t
1699	413	20033	N/A	t
1700	414	20033	N/A	t
1701	415	20033	N/A	t
1702	416	20033	N/A	t
1703	413	20041	N/A	t
1704	414	20041	N/A	t
1705	415	20041	N/A	t
1706	416	20041	N/A	t
1707	417	20041	N/A	t
1708	413	20042	N/A	t
1709	414	20042	N/A	t
1710	415	20042	N/A	t
1711	416	20042	N/A	t
1712	417	20042	N/A	t
1713	413	20043	N/A	t
1714	414	20043	N/A	t
1715	415	20043	N/A	t
1716	416	20043	N/A	t
1717	417	20043	N/A	t
1718	413	20051	N/A	t
1719	414	20051	N/A	t
1720	415	20051	N/A	t
1721	416	20051	N/A	t
1722	417	20051	N/A	t
1723	418	20051	N/A	t
1724	419	20051	N/A	t
1725	413	20052	N/A	t
1726	414	20052	N/A	t
1727	415	20052	N/A	t
1728	417	20052	N/A	t
1729	418	20052	N/A	t
1730	419	20052	N/A	t
1731	414	20053	N/A	t
1732	415	20053	N/A	t
1733	418	20053	N/A	t
1734	419	20053	N/A	t
1735	414	20061	N/A	t
1736	417	20061	N/A	t
1737	418	20061	N/A	t
1738	419	20061	N/A	t
1739	420	20061	N/A	t
1740	421	20061	N/A	t
1741	422	20061	N/A	t
1742	423	20061	N/A	t
1743	424	20061	N/A	t
1744	425	20061	N/A	t
1745	414	20062	N/A	t
1746	416	20062	N/A	t
1747	417	20062	N/A	t
1748	418	20062	N/A	t
1749	419	20062	N/A	t
1750	420	20062	N/A	t
1751	421	20062	N/A	t
1752	422	20062	N/A	t
1753	423	20062	N/A	t
1754	424	20062	N/A	t
1755	425	20062	N/A	t
1756	417	20063	N/A	t
1757	418	20063	N/A	t
1758	419	20063	N/A	t
1759	421	20063	N/A	t
1760	422	20063	N/A	t
1761	423	20063	N/A	t
1762	424	20063	N/A	t
1763	425	20063	N/A	t
1764	416	20071	N/A	t
1765	417	20071	N/A	t
1766	418	20071	N/A	t
1767	419	20071	N/A	t
1768	420	20071	N/A	t
1769	421	20071	N/A	t
1770	422	20071	N/A	t
1771	423	20071	N/A	t
1772	426	20071	N/A	t
1773	427	20071	N/A	t
1774	424	20071	N/A	t
1775	425	20071	N/A	t
1776	428	20071	N/A	t
1777	429	20071	N/A	t
1778	430	20071	N/A	t
1779	431	20071	N/A	t
1780	432	20071	N/A	t
1781	433	20071	N/A	t
1782	434	20071	N/A	t
1783	435	20071	N/A	t
1784	436	20071	N/A	t
1785	437	20071	N/A	t
1786	438	20071	N/A	t
1787	414	20072	N/A	t
1788	416	20072	N/A	t
1789	417	20072	N/A	t
1790	418	20072	N/A	t
1791	419	20072	N/A	t
1792	420	20072	N/A	t
1793	421	20072	N/A	t
1794	422	20072	N/A	t
1795	423	20072	N/A	t
1796	426	20072	N/A	t
1797	427	20072	N/A	t
1798	424	20072	N/A	t
1799	425	20072	N/A	t
1800	428	20072	N/A	t
1801	429	20072	N/A	t
1802	430	20072	N/A	t
1803	431	20072	N/A	t
1804	432	20072	N/A	t
1805	433	20072	N/A	t
1806	434	20072	N/A	t
1807	435	20072	N/A	t
1808	436	20072	N/A	t
1809	437	20072	N/A	t
1810	438	20072	N/A	t
1811	417	20073	N/A	t
1812	419	20073	N/A	t
1813	420	20073	N/A	t
1814	421	20073	N/A	t
1815	423	20073	N/A	t
1816	426	20073	N/A	t
1817	424	20073	N/A	t
1818	425	20073	N/A	t
1819	428	20073	N/A	t
1820	430	20073	N/A	t
1821	431	20073	N/A	t
1822	433	20073	N/A	t
1823	434	20073	N/A	t
1824	416	20081	N/A	t
1825	418	20081	N/A	t
1826	419	20081	N/A	t
1827	420	20081	N/A	t
1828	421	20081	N/A	t
1829	422	20081	N/A	t
1830	423	20081	N/A	t
1831	426	20081	N/A	t
1832	427	20081	N/A	t
1833	424	20081	N/A	t
1834	425	20081	N/A	t
1835	428	20081	N/A	t
1836	439	20081	N/A	t
1837	429	20081	N/A	t
1838	430	20081	N/A	t
1839	431	20081	N/A	t
1840	432	20081	N/A	t
1841	433	20081	N/A	t
1842	434	20081	N/A	t
1843	435	20081	N/A	t
1844	436	20081	N/A	t
1845	437	20081	N/A	t
1846	438	20081	N/A	t
1847	440	20081	N/A	t
1848	441	20081	N/A	t
1849	442	20081	N/A	t
1850	443	20081	N/A	t
1851	444	20081	N/A	t
1852	445	20081	N/A	t
1853	446	20081	N/A	t
1854	447	20081	N/A	t
1855	448	20081	N/A	t
1856	449	20081	N/A	t
1857	450	20081	N/A	t
1858	451	20081	N/A	t
1859	452	20081	N/A	t
1860	453	20081	N/A	t
1861	454	20081	N/A	t
1862	455	20081	N/A	t
1863	456	20081	N/A	t
1864	457	20081	N/A	t
1865	458	20081	N/A	t
1866	459	20081	N/A	t
1867	460	20081	N/A	t
1868	461	20081	N/A	t
1869	462	20081	N/A	t
1870	463	20081	N/A	t
1871	464	20081	N/A	t
1872	465	20081	N/A	t
1873	466	20081	N/A	t
1874	467	20081	N/A	t
1875	468	20081	N/A	t
1876	469	20081	N/A	t
1877	470	20081	N/A	t
1878	471	20081	N/A	t
1879	472	20081	N/A	t
1880	473	20081	N/A	t
1881	415	20082	N/A	t
1882	416	20082	N/A	t
1883	418	20082	N/A	t
1884	419	20082	N/A	t
1885	420	20082	N/A	t
1886	421	20082	N/A	t
1887	422	20082	N/A	t
1888	423	20082	N/A	t
1889	426	20082	N/A	t
1890	427	20082	N/A	t
1891	424	20082	N/A	t
1892	425	20082	N/A	t
1893	428	20082	N/A	t
1894	439	20082	N/A	t
1895	429	20082	N/A	t
1896	430	20082	N/A	t
1897	431	20082	N/A	t
1898	432	20082	N/A	t
1899	433	20082	N/A	t
1900	434	20082	N/A	t
1901	435	20082	N/A	t
1902	436	20082	N/A	t
1903	437	20082	N/A	t
1904	474	20082	N/A	t
1905	438	20082	N/A	t
1906	440	20082	N/A	t
1907	441	20082	N/A	t
1908	442	20082	N/A	t
1909	443	20082	N/A	t
1910	444	20082	N/A	t
1911	445	20082	N/A	t
1912	446	20082	N/A	t
1913	447	20082	N/A	t
1914	448	20082	N/A	t
1915	449	20082	N/A	t
1916	450	20082	N/A	t
1917	451	20082	N/A	t
1918	452	20082	N/A	t
1919	453	20082	N/A	t
1920	454	20082	N/A	t
1921	455	20082	N/A	t
1922	456	20082	N/A	t
1923	457	20082	N/A	t
1924	458	20082	N/A	t
1925	459	20082	N/A	t
1926	460	20082	N/A	t
1927	461	20082	N/A	t
1928	462	20082	N/A	t
1929	463	20082	N/A	t
1930	464	20082	N/A	t
1931	465	20082	N/A	t
1932	466	20082	N/A	t
1933	467	20082	N/A	t
1934	468	20082	N/A	t
1935	469	20082	N/A	t
1936	470	20082	N/A	t
1937	471	20082	N/A	t
1938	472	20082	N/A	t
1939	473	20082	N/A	t
1940	415	20083	N/A	t
1941	416	20083	N/A	t
1942	421	20083	N/A	t
1943	423	20083	N/A	t
1944	426	20083	N/A	t
1945	424	20083	N/A	t
1946	428	20083	N/A	t
1947	439	20083	N/A	t
1948	430	20083	N/A	t
1949	431	20083	N/A	t
1950	433	20083	N/A	t
1951	434	20083	N/A	t
1952	435	20083	N/A	t
1953	436	20083	N/A	t
1954	474	20083	N/A	t
1955	443	20083	N/A	t
1956	444	20083	N/A	t
1957	445	20083	N/A	t
1958	449	20083	N/A	t
1959	451	20083	N/A	t
1960	452	20083	N/A	t
1961	454	20083	N/A	t
1962	455	20083	N/A	t
1963	456	20083	N/A	t
1964	459	20083	N/A	t
1965	460	20083	N/A	t
1966	461	20083	N/A	t
1967	462	20083	N/A	t
1968	463	20083	N/A	t
1969	464	20083	N/A	t
1970	467	20083	N/A	t
1971	468	20083	N/A	t
1972	469	20083	N/A	t
1973	470	20083	N/A	t
1974	471	20083	N/A	t
1975	415	20091	N/A	t
1976	416	20091	N/A	t
1977	418	20091	N/A	t
1978	419	20091	N/A	t
1979	420	20091	N/A	t
1980	421	20091	N/A	t
1981	422	20091	N/A	t
1982	423	20091	N/A	t
1983	475	20091	N/A	t
1984	426	20091	N/A	t
1985	427	20091	N/A	t
1986	424	20091	N/A	t
1987	425	20091	N/A	t
1988	428	20091	N/A	t
1989	439	20091	N/A	t
1990	476	20091	N/A	t
1991	429	20091	N/A	t
1992	430	20091	N/A	t
1993	431	20091	N/A	t
1994	432	20091	N/A	t
1995	433	20091	N/A	t
1996	434	20091	N/A	t
1997	435	20091	N/A	t
1998	436	20091	N/A	t
1999	437	20091	N/A	t
2000	474	20091	N/A	t
2001	438	20091	N/A	t
2002	477	20091	N/A	t
2003	478	20091	N/A	t
2004	440	20091	N/A	t
2005	479	20091	N/A	t
2006	441	20091	N/A	t
2007	442	20091	N/A	t
2008	480	20091	N/A	t
2009	443	20091	N/A	t
2010	444	20091	N/A	t
2011	445	20091	N/A	t
2012	446	20091	N/A	t
2013	481	20091	N/A	t
2014	482	20091	N/A	t
2015	447	20091	N/A	t
2016	483	20091	N/A	t
2017	448	20091	N/A	t
2018	449	20091	N/A	t
2019	484	20091	N/A	t
2020	485	20091	N/A	t
2021	450	20091	N/A	t
2022	451	20091	N/A	t
2023	452	20091	N/A	t
2024	453	20091	N/A	t
2025	454	20091	N/A	t
2026	455	20091	N/A	t
2027	456	20091	N/A	t
2028	457	20091	N/A	t
2029	458	20091	N/A	t
2030	459	20091	N/A	t
2031	460	20091	N/A	t
2032	486	20091	N/A	t
2033	461	20091	N/A	t
2034	487	20091	N/A	t
2035	462	20091	N/A	t
2036	463	20091	N/A	t
2037	464	20091	N/A	t
2038	465	20091	N/A	t
2039	466	20091	N/A	t
2040	467	20091	N/A	t
2041	488	20091	N/A	t
2042	468	20091	N/A	t
2043	469	20091	N/A	t
2044	470	20091	N/A	t
2045	471	20091	N/A	t
2046	472	20091	N/A	t
2047	473	20091	N/A	t
2048	489	20091	N/A	t
2049	490	20091	N/A	t
2050	491	20091	N/A	t
2051	492	20091	N/A	t
2052	493	20091	N/A	t
2053	494	20091	N/A	t
2054	495	20091	N/A	t
2055	496	20091	N/A	t
2056	497	20091	N/A	t
2057	498	20091	N/A	t
2058	499	20091	N/A	t
2059	500	20091	N/A	t
2060	501	20091	N/A	t
2061	502	20091	N/A	t
2062	503	20091	N/A	t
2063	504	20091	N/A	t
2064	505	20091	N/A	t
2065	506	20091	N/A	t
2066	507	20091	N/A	t
2067	508	20091	N/A	t
2068	509	20091	N/A	t
2069	510	20091	N/A	t
2070	511	20091	N/A	t
2071	512	20091	N/A	t
2072	513	20091	N/A	t
2073	514	20091	N/A	t
2074	515	20091	N/A	t
2075	516	20091	N/A	t
2076	517	20091	N/A	t
2077	518	20091	N/A	t
2078	519	20091	N/A	t
2079	520	20091	N/A	t
2080	521	20091	N/A	t
2081	522	20091	N/A	t
2082	523	20091	N/A	t
2083	524	20091	N/A	t
2084	525	20091	N/A	t
2085	526	20091	N/A	t
2086	527	20091	N/A	t
2087	528	20091	N/A	t
2088	529	20091	N/A	t
2089	530	20091	N/A	t
2090	531	20091	N/A	t
2091	532	20091	N/A	t
2092	533	20091	N/A	t
2093	534	20091	N/A	t
2094	535	20091	N/A	t
2095	536	20091	N/A	t
2096	537	20091	N/A	t
2097	538	20091	N/A	t
2098	539	20091	N/A	t
2099	540	20091	N/A	t
2100	541	20091	N/A	t
2101	542	20091	N/A	t
2102	543	20091	N/A	t
2103	544	20091	N/A	t
2104	545	20091	N/A	t
2105	546	20091	N/A	t
2106	547	20091	N/A	t
2107	548	20091	N/A	t
2108	549	20091	N/A	t
2109	550	20091	N/A	t
2110	551	20091	N/A	t
2111	552	20091	N/A	t
2112	553	20091	N/A	t
2113	554	20091	N/A	t
2114	555	20091	N/A	t
2115	556	20091	N/A	t
2116	557	20091	N/A	t
2117	558	20091	N/A	t
2118	559	20091	N/A	t
2119	560	20091	N/A	t
2120	561	20091	N/A	t
2121	562	20091	N/A	t
2122	563	20091	N/A	t
2123	564	20091	N/A	t
2124	565	20091	N/A	t
2125	566	20091	N/A	t
2126	567	20091	N/A	t
2127	568	20091	N/A	t
2128	569	20091	N/A	t
2129	570	20091	N/A	t
2130	571	20091	N/A	t
2131	572	20091	N/A	t
2132	573	20091	N/A	t
2133	574	20091	N/A	t
2134	575	20091	N/A	t
2135	576	20091	N/A	t
2136	577	20091	N/A	t
2137	578	20091	N/A	t
2138	579	20091	N/A	t
2139	580	20091	N/A	t
2140	581	20091	N/A	t
2141	582	20091	N/A	t
2142	583	20091	N/A	t
2143	584	20091	N/A	t
2144	415	20092	N/A	t
2145	418	20092	N/A	t
2146	420	20092	N/A	t
2147	421	20092	N/A	t
2148	422	20092	N/A	t
2149	423	20092	N/A	t
2150	475	20092	N/A	t
2151	426	20092	N/A	t
2152	427	20092	N/A	t
2153	424	20092	N/A	t
2154	425	20092	N/A	t
2155	428	20092	N/A	t
2156	439	20092	N/A	t
2157	476	20092	N/A	t
2158	429	20092	N/A	t
2159	430	20092	N/A	t
2160	431	20092	N/A	t
2161	432	20092	N/A	t
2162	433	20092	N/A	t
2163	434	20092	N/A	t
2164	435	20092	N/A	t
2165	436	20092	N/A	t
2166	437	20092	N/A	t
2167	474	20092	N/A	t
2168	438	20092	N/A	t
2169	477	20092	N/A	t
2170	478	20092	N/A	t
2171	440	20092	N/A	t
2172	479	20092	N/A	t
2173	441	20092	N/A	t
2174	442	20092	N/A	t
2175	480	20092	N/A	t
2176	443	20092	N/A	t
2177	444	20092	N/A	t
2178	445	20092	N/A	t
2179	446	20092	N/A	t
2180	481	20092	N/A	t
2181	482	20092	N/A	t
2182	447	20092	N/A	t
2183	483	20092	N/A	t
2184	448	20092	N/A	t
2185	449	20092	N/A	t
2186	484	20092	N/A	t
2187	485	20092	N/A	t
2188	450	20092	N/A	t
2189	585	20092	N/A	t
2190	451	20092	N/A	t
2191	452	20092	N/A	t
2192	453	20092	N/A	t
2193	454	20092	N/A	t
2194	586	20092	N/A	t
2195	455	20092	N/A	t
2196	456	20092	N/A	t
2197	457	20092	N/A	t
2198	458	20092	N/A	t
2199	459	20092	N/A	t
2200	460	20092	N/A	t
2201	486	20092	N/A	t
2202	461	20092	N/A	t
2203	487	20092	N/A	t
2204	462	20092	N/A	t
2205	463	20092	N/A	t
2206	464	20092	N/A	t
2207	465	20092	N/A	t
2208	466	20092	N/A	t
2209	467	20092	N/A	t
2210	587	20092	N/A	t
2211	488	20092	N/A	t
2212	468	20092	N/A	t
2213	469	20092	N/A	t
2214	470	20092	N/A	t
2215	471	20092	N/A	t
2216	472	20092	N/A	t
2217	473	20092	N/A	t
2218	489	20092	N/A	t
2219	490	20092	N/A	t
2220	491	20092	N/A	t
2221	492	20092	N/A	t
2222	493	20092	N/A	t
2223	494	20092	N/A	t
2224	495	20092	N/A	t
2225	496	20092	N/A	t
2226	497	20092	N/A	t
2227	498	20092	N/A	t
2228	499	20092	N/A	t
2229	500	20092	N/A	t
2230	501	20092	N/A	t
2231	502	20092	N/A	t
2232	503	20092	N/A	t
2233	504	20092	N/A	t
2234	505	20092	N/A	t
2235	506	20092	N/A	t
2236	507	20092	N/A	t
2237	508	20092	N/A	t
2238	509	20092	N/A	t
2239	510	20092	N/A	t
2240	511	20092	N/A	t
2241	512	20092	N/A	t
2242	513	20092	N/A	t
2243	514	20092	N/A	t
2244	515	20092	N/A	t
2245	516	20092	N/A	t
2246	517	20092	N/A	t
2247	518	20092	N/A	t
2248	519	20092	N/A	t
2249	520	20092	N/A	t
2250	521	20092	N/A	t
2251	522	20092	N/A	t
2252	523	20092	N/A	t
2253	524	20092	N/A	t
2254	525	20092	N/A	t
2255	526	20092	N/A	t
2256	527	20092	N/A	t
2257	528	20092	N/A	t
2258	529	20092	N/A	t
2259	530	20092	N/A	t
2260	531	20092	N/A	t
2261	532	20092	N/A	t
2262	533	20092	N/A	t
2263	534	20092	N/A	t
2264	535	20092	N/A	t
2265	536	20092	N/A	t
2266	537	20092	N/A	t
2267	538	20092	N/A	t
2268	539	20092	N/A	t
2269	540	20092	N/A	t
2270	541	20092	N/A	t
2271	542	20092	N/A	t
2272	543	20092	N/A	t
2273	544	20092	N/A	t
2274	545	20092	N/A	t
2275	546	20092	N/A	t
2276	547	20092	N/A	t
2277	548	20092	N/A	t
2278	549	20092	N/A	t
2279	550	20092	N/A	t
2280	551	20092	N/A	t
2281	552	20092	N/A	t
2282	553	20092	N/A	t
2283	554	20092	N/A	t
2284	555	20092	N/A	t
2285	556	20092	N/A	t
2286	557	20092	N/A	t
2287	558	20092	N/A	t
2288	559	20092	N/A	t
2289	560	20092	N/A	t
2290	561	20092	N/A	t
2291	562	20092	N/A	t
2292	563	20092	N/A	t
2293	564	20092	N/A	t
2294	565	20092	N/A	t
2295	566	20092	N/A	t
2296	567	20092	N/A	t
2297	568	20092	N/A	t
2298	569	20092	N/A	t
2299	570	20092	N/A	t
2300	571	20092	N/A	t
2301	572	20092	N/A	t
2302	573	20092	N/A	t
2303	574	20092	N/A	t
2304	575	20092	N/A	t
2305	576	20092	N/A	t
2306	577	20092	N/A	t
2307	578	20092	N/A	t
2308	579	20092	N/A	t
2309	580	20092	N/A	t
2310	581	20092	N/A	t
2311	582	20092	N/A	t
2312	583	20092	N/A	t
2313	584	20092	N/A	t
2314	415	20093	N/A	t
2315	418	20093	N/A	t
2316	420	20093	N/A	t
2317	421	20093	N/A	t
2318	423	20093	N/A	t
2319	475	20093	N/A	t
2320	427	20093	N/A	t
2321	424	20093	N/A	t
2322	425	20093	N/A	t
2323	428	20093	N/A	t
2324	429	20093	N/A	t
2325	431	20093	N/A	t
2326	432	20093	N/A	t
2327	433	20093	N/A	t
2328	436	20093	N/A	t
2329	474	20093	N/A	t
2330	478	20093	N/A	t
2331	442	20093	N/A	t
2332	480	20093	N/A	t
2333	444	20093	N/A	t
2334	445	20093	N/A	t
2335	481	20093	N/A	t
2336	482	20093	N/A	t
2337	483	20093	N/A	t
2338	448	20093	N/A	t
2339	484	20093	N/A	t
2340	485	20093	N/A	t
2341	451	20093	N/A	t
2342	452	20093	N/A	t
2343	454	20093	N/A	t
2344	455	20093	N/A	t
2345	456	20093	N/A	t
2346	458	20093	N/A	t
2347	460	20093	N/A	t
2348	461	20093	N/A	t
2349	463	20093	N/A	t
2350	465	20093	N/A	t
2351	467	20093	N/A	t
2352	488	20093	N/A	t
2353	468	20093	N/A	t
2354	469	20093	N/A	t
2355	470	20093	N/A	t
2356	489	20093	N/A	t
2357	494	20093	N/A	t
2358	495	20093	N/A	t
2359	499	20093	N/A	t
2360	501	20093	N/A	t
2361	506	20093	N/A	t
2362	508	20093	N/A	t
2363	509	20093	N/A	t
2364	511	20093	N/A	t
2365	512	20093	N/A	t
2366	513	20093	N/A	t
2367	514	20093	N/A	t
2368	515	20093	N/A	t
2369	518	20093	N/A	t
2370	521	20093	N/A	t
2371	522	20093	N/A	t
2372	524	20093	N/A	t
2373	525	20093	N/A	t
2374	526	20093	N/A	t
2375	527	20093	N/A	t
2376	529	20093	N/A	t
2377	530	20093	N/A	t
2378	539	20093	N/A	t
2379	540	20093	N/A	t
2380	541	20093	N/A	t
2381	542	20093	N/A	t
2382	546	20093	N/A	t
2383	547	20093	N/A	t
2384	549	20093	N/A	t
2385	550	20093	N/A	t
2386	551	20093	N/A	t
2387	553	20093	N/A	t
2388	555	20093	N/A	t
2389	556	20093	N/A	t
2390	557	20093	N/A	t
2391	558	20093	N/A	t
2392	559	20093	N/A	t
2393	560	20093	N/A	t
2394	562	20093	N/A	t
2395	565	20093	N/A	t
2396	566	20093	N/A	t
2397	568	20093	N/A	t
2398	569	20093	N/A	t
2399	570	20093	N/A	t
2400	571	20093	N/A	t
2401	572	20093	N/A	t
2402	573	20093	N/A	t
2403	574	20093	N/A	t
2404	575	20093	N/A	t
2405	576	20093	N/A	t
2406	577	20093	N/A	t
2407	580	20093	N/A	t
2408	581	20093	N/A	t
2409	582	20093	N/A	t
2410	583	20093	N/A	t
2411	415	20101	N/A	t
2412	418	20101	N/A	t
2413	419	20101	N/A	t
2414	420	20101	N/A	t
2415	421	20101	N/A	t
2416	423	20101	N/A	t
2417	475	20101	N/A	t
2418	426	20101	N/A	t
2419	427	20101	N/A	t
2420	424	20101	N/A	t
2421	425	20101	N/A	t
2422	428	20101	N/A	t
2423	439	20101	N/A	t
2424	476	20101	N/A	t
2425	429	20101	N/A	t
2426	430	20101	N/A	t
2427	431	20101	N/A	t
2428	432	20101	N/A	t
2429	433	20101	N/A	t
2430	434	20101	N/A	t
2431	435	20101	N/A	t
2432	436	20101	N/A	t
2433	437	20101	N/A	t
2434	474	20101	N/A	t
2435	438	20101	N/A	t
2436	477	20101	N/A	t
2437	478	20101	N/A	t
2438	440	20101	N/A	t
2439	479	20101	N/A	t
2440	588	20101	N/A	t
2441	441	20101	N/A	t
2442	442	20101	N/A	t
2443	589	19991	N/A	t
2444	589	20001	N/A	t
2445	589	20002	N/A	t
2446	589	20003	N/A	t
2447	589	20011	N/A	t
2448	589	20012	N/A	t
2449	589	20013	N/A	t
2450	589	20021	N/A	t
2451	590	20021	N/A	t
2452	591	20021	N/A	t
2453	589	20022	N/A	t
2454	590	20022	N/A	t
2455	591	20022	N/A	t
2456	589	20031	N/A	t
2457	590	20031	N/A	t
2458	591	20031	N/A	t
2459	592	20031	N/A	t
2460	593	20031	N/A	t
2461	589	20032	N/A	t
2462	590	20032	N/A	t
2463	591	20032	N/A	t
2464	592	20032	N/A	t
2465	593	20032	N/A	t
2466	590	20033	N/A	t
2467	591	20033	N/A	t
2468	592	20033	N/A	t
2469	593	20033	N/A	t
2470	590	20041	N/A	t
2471	591	20041	N/A	t
2472	592	20041	N/A	t
2473	593	20041	N/A	t
2474	594	20041	N/A	t
2475	590	20042	N/A	t
2476	591	20042	N/A	t
2477	592	20042	N/A	t
2478	593	20042	N/A	t
2479	594	20042	N/A	t
2480	590	20043	N/A	t
2481	591	20043	N/A	t
2482	592	20043	N/A	t
2483	593	20043	N/A	t
2484	594	20043	N/A	t
2485	590	20051	N/A	t
2486	591	20051	N/A	t
2487	592	20051	N/A	t
2488	593	20051	N/A	t
2489	594	20051	N/A	t
2490	595	20051	N/A	t
2491	596	20051	N/A	t
2492	590	20052	N/A	t
2493	591	20052	N/A	t
2494	592	20052	N/A	t
2495	594	20052	N/A	t
2496	595	20052	N/A	t
2497	596	20052	N/A	t
2498	591	20053	N/A	t
2499	592	20053	N/A	t
2500	595	20053	N/A	t
2501	596	20053	N/A	t
2502	591	20061	N/A	t
2503	594	20061	N/A	t
2504	595	20061	N/A	t
2505	596	20061	N/A	t
2506	597	20061	N/A	t
2507	598	20061	N/A	t
2508	599	20061	N/A	t
2509	600	20061	N/A	t
2510	601	20061	N/A	t
2511	602	20061	N/A	t
2512	591	20062	N/A	t
2513	593	20062	N/A	t
2514	594	20062	N/A	t
2515	595	20062	N/A	t
2516	596	20062	N/A	t
2517	597	20062	N/A	t
2518	598	20062	N/A	t
2519	599	20062	N/A	t
2520	600	20062	N/A	t
2521	601	20062	N/A	t
2522	602	20062	N/A	t
2523	594	20063	N/A	t
2524	595	20063	N/A	t
2525	596	20063	N/A	t
2526	598	20063	N/A	t
2527	599	20063	N/A	t
2528	600	20063	N/A	t
2529	601	20063	N/A	t
2530	602	20063	N/A	t
2531	593	20071	N/A	t
2532	594	20071	N/A	t
2533	595	20071	N/A	t
2534	596	20071	N/A	t
2535	597	20071	N/A	t
2536	598	20071	N/A	t
2537	599	20071	N/A	t
2538	600	20071	N/A	t
2539	603	20071	N/A	t
2540	604	20071	N/A	t
2541	601	20071	N/A	t
2542	602	20071	N/A	t
2543	605	20071	N/A	t
2544	606	20071	N/A	t
2545	607	20071	N/A	t
2546	608	20071	N/A	t
2547	609	20071	N/A	t
2548	610	20071	N/A	t
2549	611	20071	N/A	t
2550	612	20071	N/A	t
2551	613	20071	N/A	t
2552	614	20071	N/A	t
2553	615	20071	N/A	t
2554	591	20072	N/A	t
2555	593	20072	N/A	t
2556	594	20072	N/A	t
2557	595	20072	N/A	t
2558	596	20072	N/A	t
2559	597	20072	N/A	t
2560	598	20072	N/A	t
2561	599	20072	N/A	t
2562	600	20072	N/A	t
2563	603	20072	N/A	t
2564	604	20072	N/A	t
2565	601	20072	N/A	t
2566	602	20072	N/A	t
2567	605	20072	N/A	t
2568	606	20072	N/A	t
2569	607	20072	N/A	t
2570	608	20072	N/A	t
2571	609	20072	N/A	t
2572	610	20072	N/A	t
2573	611	20072	N/A	t
2574	612	20072	N/A	t
2575	613	20072	N/A	t
2576	614	20072	N/A	t
2577	615	20072	N/A	t
2578	594	20073	N/A	t
2579	596	20073	N/A	t
2580	597	20073	N/A	t
2581	598	20073	N/A	t
2582	600	20073	N/A	t
2583	603	20073	N/A	t
2584	601	20073	N/A	t
2585	602	20073	N/A	t
2586	605	20073	N/A	t
2587	607	20073	N/A	t
2588	608	20073	N/A	t
2589	610	20073	N/A	t
2590	611	20073	N/A	t
2591	593	20081	N/A	t
2592	595	20081	N/A	t
2593	596	20081	N/A	t
2594	597	20081	N/A	t
2595	598	20081	N/A	t
2596	599	20081	N/A	t
2597	600	20081	N/A	t
2598	603	20081	N/A	t
2599	604	20081	N/A	t
2600	601	20081	N/A	t
2601	602	20081	N/A	t
2602	605	20081	N/A	t
2603	616	20081	N/A	t
2604	606	20081	N/A	t
2605	607	20081	N/A	t
2606	608	20081	N/A	t
2607	609	20081	N/A	t
2608	610	20081	N/A	t
2609	611	20081	N/A	t
2610	612	20081	N/A	t
2611	613	20081	N/A	t
2612	614	20081	N/A	t
2613	615	20081	N/A	t
2614	617	20081	N/A	t
2615	618	20081	N/A	t
2616	619	20081	N/A	t
2617	620	20081	N/A	t
2618	621	20081	N/A	t
2619	622	20081	N/A	t
2620	623	20081	N/A	t
2621	624	20081	N/A	t
2622	625	20081	N/A	t
2623	626	20081	N/A	t
2624	627	20081	N/A	t
2625	628	20081	N/A	t
2626	629	20081	N/A	t
2627	630	20081	N/A	t
2628	631	20081	N/A	t
2629	632	20081	N/A	t
2630	633	20081	N/A	t
2631	634	20081	N/A	t
2632	635	20081	N/A	t
2633	636	20081	N/A	t
2634	637	20081	N/A	t
2635	638	20081	N/A	t
2636	639	20081	N/A	t
2637	640	20081	N/A	t
2638	641	20081	N/A	t
2639	642	20081	N/A	t
2640	643	20081	N/A	t
2641	644	20081	N/A	t
2642	645	20081	N/A	t
2643	646	20081	N/A	t
2644	647	20081	N/A	t
2645	648	20081	N/A	t
2646	649	20081	N/A	t
2647	650	20081	N/A	t
2648	592	20082	N/A	t
2649	593	20082	N/A	t
2650	595	20082	N/A	t
2651	596	20082	N/A	t
2652	597	20082	N/A	t
2653	598	20082	N/A	t
2654	599	20082	N/A	t
2655	600	20082	N/A	t
2656	603	20082	N/A	t
2657	604	20082	N/A	t
2658	601	20082	N/A	t
2659	602	20082	N/A	t
2660	605	20082	N/A	t
2661	616	20082	N/A	t
2662	606	20082	N/A	t
2663	607	20082	N/A	t
2664	608	20082	N/A	t
2665	609	20082	N/A	t
2666	610	20082	N/A	t
2667	611	20082	N/A	t
2668	612	20082	N/A	t
2669	613	20082	N/A	t
2670	614	20082	N/A	t
2671	651	20082	N/A	t
2672	615	20082	N/A	t
2673	617	20082	N/A	t
2674	618	20082	N/A	t
2675	619	20082	N/A	t
2676	620	20082	N/A	t
2677	621	20082	N/A	t
2678	622	20082	N/A	t
2679	623	20082	N/A	t
2680	624	20082	N/A	t
2681	625	20082	N/A	t
2682	626	20082	N/A	t
2683	627	20082	N/A	t
2684	628	20082	N/A	t
2685	629	20082	N/A	t
2686	630	20082	N/A	t
2687	631	20082	N/A	t
2688	632	20082	N/A	t
2689	633	20082	N/A	t
2690	634	20082	N/A	t
2691	635	20082	N/A	t
2692	636	20082	N/A	t
2693	637	20082	N/A	t
2694	638	20082	N/A	t
2695	639	20082	N/A	t
2696	640	20082	N/A	t
2697	641	20082	N/A	t
2698	642	20082	N/A	t
2699	643	20082	N/A	t
2700	644	20082	N/A	t
2701	645	20082	N/A	t
2702	646	20082	N/A	t
2703	647	20082	N/A	t
2704	648	20082	N/A	t
2705	649	20082	N/A	t
2706	650	20082	N/A	t
2707	592	20083	N/A	t
2708	593	20083	N/A	t
2709	598	20083	N/A	t
2710	600	20083	N/A	t
2711	603	20083	N/A	t
2712	601	20083	N/A	t
2713	605	20083	N/A	t
2714	616	20083	N/A	t
2715	607	20083	N/A	t
2716	608	20083	N/A	t
2717	610	20083	N/A	t
2718	611	20083	N/A	t
2719	612	20083	N/A	t
2720	613	20083	N/A	t
2721	651	20083	N/A	t
2722	620	20083	N/A	t
2723	621	20083	N/A	t
2724	622	20083	N/A	t
2725	626	20083	N/A	t
2726	628	20083	N/A	t
2727	629	20083	N/A	t
2728	631	20083	N/A	t
2729	632	20083	N/A	t
2730	633	20083	N/A	t
2731	636	20083	N/A	t
2732	637	20083	N/A	t
2733	638	20083	N/A	t
2734	639	20083	N/A	t
2735	640	20083	N/A	t
2736	641	20083	N/A	t
2737	644	20083	N/A	t
2738	645	20083	N/A	t
2739	646	20083	N/A	t
2740	647	20083	N/A	t
2741	648	20083	N/A	t
2742	592	20091	N/A	t
2743	593	20091	N/A	t
2744	595	20091	N/A	t
2745	596	20091	N/A	t
2746	597	20091	N/A	t
2747	598	20091	N/A	t
2748	599	20091	N/A	t
2749	600	20091	N/A	t
2750	652	20091	N/A	t
2751	603	20091	N/A	t
2752	604	20091	N/A	t
2753	601	20091	N/A	t
2754	602	20091	N/A	t
2755	605	20091	N/A	t
2756	616	20091	N/A	t
2757	653	20091	N/A	t
2758	606	20091	N/A	t
2759	607	20091	N/A	t
2760	608	20091	N/A	t
2761	609	20091	N/A	t
2762	610	20091	N/A	t
2763	611	20091	N/A	t
2764	612	20091	N/A	t
2765	613	20091	N/A	t
2766	614	20091	N/A	t
2767	651	20091	N/A	t
2768	615	20091	N/A	t
2769	654	20091	N/A	t
2770	655	20091	N/A	t
2771	617	20091	N/A	t
2772	656	20091	N/A	t
2773	618	20091	N/A	t
2774	619	20091	N/A	t
2775	657	20091	N/A	t
2776	620	20091	N/A	t
2777	621	20091	N/A	t
2778	622	20091	N/A	t
2779	623	20091	N/A	t
2780	658	20091	N/A	t
2781	659	20091	N/A	t
2782	624	20091	N/A	t
2783	660	20091	N/A	t
2784	625	20091	N/A	t
2785	626	20091	N/A	t
2786	661	20091	N/A	t
2787	662	20091	N/A	t
2788	627	20091	N/A	t
2789	628	20091	N/A	t
2790	629	20091	N/A	t
2791	630	20091	N/A	t
2792	631	20091	N/A	t
2793	632	20091	N/A	t
2794	633	20091	N/A	t
2795	634	20091	N/A	t
2796	635	20091	N/A	t
2797	636	20091	N/A	t
2798	637	20091	N/A	t
2799	663	20091	N/A	t
2800	638	20091	N/A	t
2801	664	20091	N/A	t
2802	639	20091	N/A	t
2803	640	20091	N/A	t
2804	641	20091	N/A	t
2805	642	20091	N/A	t
2806	643	20091	N/A	t
2807	644	20091	N/A	t
2808	665	20091	N/A	t
2809	645	20091	N/A	t
2810	646	20091	N/A	t
2811	647	20091	N/A	t
2812	648	20091	N/A	t
2813	649	20091	N/A	t
2814	650	20091	N/A	t
2815	666	20091	N/A	t
2816	667	20091	N/A	t
2817	668	20091	N/A	t
2818	669	20091	N/A	t
2819	670	20091	N/A	t
2820	671	20091	N/A	t
2821	672	20091	N/A	t
2822	673	20091	N/A	t
2823	674	20091	N/A	t
2824	675	20091	N/A	t
2825	676	20091	N/A	t
2826	677	20091	N/A	t
2827	678	20091	N/A	t
2828	679	20091	N/A	t
2829	680	20091	N/A	t
2830	681	20091	N/A	t
2831	682	20091	N/A	t
2832	683	20091	N/A	t
2833	684	20091	N/A	t
2834	685	20091	N/A	t
2835	686	20091	N/A	t
2836	687	20091	N/A	t
2837	688	20091	N/A	t
2838	689	20091	N/A	t
2839	690	20091	N/A	t
2840	691	20091	N/A	t
2841	692	20091	N/A	t
2842	693	20091	N/A	t
2843	694	20091	N/A	t
2844	695	20091	N/A	t
2845	696	20091	N/A	t
2846	697	20091	N/A	t
2847	698	20091	N/A	t
2848	699	20091	N/A	t
2849	700	20091	N/A	t
2850	701	20091	N/A	t
2851	702	20091	N/A	t
2852	703	20091	N/A	t
2853	704	20091	N/A	t
2854	705	20091	N/A	t
2855	706	20091	N/A	t
2856	707	20091	N/A	t
2857	708	20091	N/A	t
2858	709	20091	N/A	t
2859	710	20091	N/A	t
2860	711	20091	N/A	t
2861	712	20091	N/A	t
2862	713	20091	N/A	t
2863	714	20091	N/A	t
2864	715	20091	N/A	t
2865	716	20091	N/A	t
2866	717	20091	N/A	t
2867	718	20091	N/A	t
2868	719	20091	N/A	t
2869	720	20091	N/A	t
2870	721	20091	N/A	t
2871	722	20091	N/A	t
2872	723	20091	N/A	t
2873	724	20091	N/A	t
2874	725	20091	N/A	t
2875	726	20091	N/A	t
2876	727	20091	N/A	t
2877	728	20091	N/A	t
2878	729	20091	N/A	t
2879	730	20091	N/A	t
2880	731	20091	N/A	t
2881	732	20091	N/A	t
2882	733	20091	N/A	t
2883	734	20091	N/A	t
2884	735	20091	N/A	t
2885	736	20091	N/A	t
2886	737	20091	N/A	t
2887	738	20091	N/A	t
2888	739	20091	N/A	t
2889	740	20091	N/A	t
2890	741	20091	N/A	t
2891	742	20091	N/A	t
2892	743	20091	N/A	t
2893	744	20091	N/A	t
2894	745	20091	N/A	t
2895	746	20091	N/A	t
2896	747	20091	N/A	t
2897	748	20091	N/A	t
2898	749	20091	N/A	t
2899	750	20091	N/A	t
2900	751	20091	N/A	t
2901	752	20091	N/A	t
2902	753	20091	N/A	t
2903	754	20091	N/A	t
2904	755	20091	N/A	t
2905	756	20091	N/A	t
2906	757	20091	N/A	t
2907	758	20091	N/A	t
2908	759	20091	N/A	t
2909	760	20091	N/A	t
2910	761	20091	N/A	t
2911	592	20092	N/A	t
2912	595	20092	N/A	t
2913	597	20092	N/A	t
2914	598	20092	N/A	t
2915	599	20092	N/A	t
2916	600	20092	N/A	t
2917	652	20092	N/A	t
2918	603	20092	N/A	t
2919	604	20092	N/A	t
2920	601	20092	N/A	t
2921	602	20092	N/A	t
2922	605	20092	N/A	t
2923	616	20092	N/A	t
2924	653	20092	N/A	t
2925	606	20092	N/A	t
2926	607	20092	N/A	t
2927	608	20092	N/A	t
2928	609	20092	N/A	t
2929	610	20092	N/A	t
2930	611	20092	N/A	t
2931	612	20092	N/A	t
2932	613	20092	N/A	t
2933	614	20092	N/A	t
2934	651	20092	N/A	t
2935	615	20092	N/A	t
2936	654	20092	N/A	t
2937	655	20092	N/A	t
2938	617	20092	N/A	t
2939	656	20092	N/A	t
2940	618	20092	N/A	t
2941	619	20092	N/A	t
2942	657	20092	N/A	t
2943	620	20092	N/A	t
2944	621	20092	N/A	t
2945	622	20092	N/A	t
2946	623	20092	N/A	t
2947	658	20092	N/A	t
2948	659	20092	N/A	t
2949	624	20092	N/A	t
2950	660	20092	N/A	t
2951	625	20092	N/A	t
2952	626	20092	N/A	t
2953	661	20092	N/A	t
2954	662	20092	N/A	t
2955	627	20092	N/A	t
2956	762	20092	N/A	t
2957	628	20092	N/A	t
2958	629	20092	N/A	t
2959	630	20092	N/A	t
2960	631	20092	N/A	t
2961	763	20092	N/A	t
2962	632	20092	N/A	t
2963	633	20092	N/A	t
2964	634	20092	N/A	t
2965	635	20092	N/A	t
2966	636	20092	N/A	t
2967	637	20092	N/A	t
2968	663	20092	N/A	t
2969	638	20092	N/A	t
2970	664	20092	N/A	t
2971	639	20092	N/A	t
2972	640	20092	N/A	t
2973	641	20092	N/A	t
2974	642	20092	N/A	t
2975	643	20092	N/A	t
2976	644	20092	N/A	t
2977	764	20092	N/A	t
2978	665	20092	N/A	t
2979	645	20092	N/A	t
2980	646	20092	N/A	t
2981	647	20092	N/A	t
2982	648	20092	N/A	t
2983	649	20092	N/A	t
2984	650	20092	N/A	t
2985	666	20092	N/A	t
2986	667	20092	N/A	t
2987	668	20092	N/A	t
2988	669	20092	N/A	t
2989	670	20092	N/A	t
2990	671	20092	N/A	t
2991	672	20092	N/A	t
2992	673	20092	N/A	t
2993	674	20092	N/A	t
2994	675	20092	N/A	t
2995	676	20092	N/A	t
2996	677	20092	N/A	t
2997	678	20092	N/A	t
2998	679	20092	N/A	t
2999	680	20092	N/A	t
3000	681	20092	N/A	t
3001	682	20092	N/A	t
3002	683	20092	N/A	t
3003	684	20092	N/A	t
3004	685	20092	N/A	t
3005	686	20092	N/A	t
3006	687	20092	N/A	t
3007	688	20092	N/A	t
3008	689	20092	N/A	t
3009	690	20092	N/A	t
3010	691	20092	N/A	t
3011	692	20092	N/A	t
3012	693	20092	N/A	t
3013	694	20092	N/A	t
3014	695	20092	N/A	t
3015	696	20092	N/A	t
3016	697	20092	N/A	t
3017	698	20092	N/A	t
3018	699	20092	N/A	t
3019	700	20092	N/A	t
3020	701	20092	N/A	t
3021	702	20092	N/A	t
3022	703	20092	N/A	t
3023	704	20092	N/A	t
3024	705	20092	N/A	t
3025	706	20092	N/A	t
3026	707	20092	N/A	t
3027	708	20092	N/A	t
3028	709	20092	N/A	t
3029	710	20092	N/A	t
3030	711	20092	N/A	t
3031	712	20092	N/A	t
3032	713	20092	N/A	t
3033	714	20092	N/A	t
3034	715	20092	N/A	t
3035	716	20092	N/A	t
3036	717	20092	N/A	t
3037	718	20092	N/A	t
3038	719	20092	N/A	t
3039	720	20092	N/A	t
3040	721	20092	N/A	t
3041	722	20092	N/A	t
3042	723	20092	N/A	t
3043	724	20092	N/A	t
3044	725	20092	N/A	t
3045	726	20092	N/A	t
3046	727	20092	N/A	t
3047	728	20092	N/A	t
3048	729	20092	N/A	t
3049	730	20092	N/A	t
3050	731	20092	N/A	t
3051	732	20092	N/A	t
3052	733	20092	N/A	t
3053	734	20092	N/A	t
3054	735	20092	N/A	t
3055	736	20092	N/A	t
3056	737	20092	N/A	t
3057	738	20092	N/A	t
3058	739	20092	N/A	t
3059	740	20092	N/A	t
3060	741	20092	N/A	t
3061	742	20092	N/A	t
3062	743	20092	N/A	t
3063	744	20092	N/A	t
3064	745	20092	N/A	t
3065	746	20092	N/A	t
3066	747	20092	N/A	t
3067	748	20092	N/A	t
3068	749	20092	N/A	t
3069	750	20092	N/A	t
3070	751	20092	N/A	t
3071	752	20092	N/A	t
3072	753	20092	N/A	t
3073	754	20092	N/A	t
3074	755	20092	N/A	t
3075	756	20092	N/A	t
3076	757	20092	N/A	t
3077	758	20092	N/A	t
3078	759	20092	N/A	t
3079	760	20092	N/A	t
3080	761	20092	N/A	t
3081	592	20093	N/A	t
3082	595	20093	N/A	t
3083	597	20093	N/A	t
3084	598	20093	N/A	t
3085	600	20093	N/A	t
3086	652	20093	N/A	t
3087	604	20093	N/A	t
3088	601	20093	N/A	t
3089	602	20093	N/A	t
3090	605	20093	N/A	t
3091	606	20093	N/A	t
3092	608	20093	N/A	t
3093	609	20093	N/A	t
3094	610	20093	N/A	t
3095	613	20093	N/A	t
3096	651	20093	N/A	t
3097	655	20093	N/A	t
3098	619	20093	N/A	t
3099	657	20093	N/A	t
3100	621	20093	N/A	t
3101	622	20093	N/A	t
3102	658	20093	N/A	t
3103	659	20093	N/A	t
3104	660	20093	N/A	t
3105	625	20093	N/A	t
3106	661	20093	N/A	t
3107	662	20093	N/A	t
3108	628	20093	N/A	t
3109	629	20093	N/A	t
3110	631	20093	N/A	t
3111	632	20093	N/A	t
3112	633	20093	N/A	t
3113	635	20093	N/A	t
3114	637	20093	N/A	t
3115	638	20093	N/A	t
3116	640	20093	N/A	t
3117	642	20093	N/A	t
3118	644	20093	N/A	t
3119	665	20093	N/A	t
3120	645	20093	N/A	t
3121	646	20093	N/A	t
3122	647	20093	N/A	t
3123	666	20093	N/A	t
3124	671	20093	N/A	t
3125	672	20093	N/A	t
3126	676	20093	N/A	t
3127	678	20093	N/A	t
3128	683	20093	N/A	t
3129	685	20093	N/A	t
3130	686	20093	N/A	t
3131	688	20093	N/A	t
3132	689	20093	N/A	t
3133	690	20093	N/A	t
3134	691	20093	N/A	t
3135	692	20093	N/A	t
3136	695	20093	N/A	t
3137	698	20093	N/A	t
3138	699	20093	N/A	t
3139	701	20093	N/A	t
3140	702	20093	N/A	t
3141	703	20093	N/A	t
3142	704	20093	N/A	t
3143	706	20093	N/A	t
3144	707	20093	N/A	t
3145	716	20093	N/A	t
3146	717	20093	N/A	t
3147	718	20093	N/A	t
3148	719	20093	N/A	t
3149	723	20093	N/A	t
3150	724	20093	N/A	t
3151	726	20093	N/A	t
3152	727	20093	N/A	t
3153	728	20093	N/A	t
3154	730	20093	N/A	t
3155	732	20093	N/A	t
3156	733	20093	N/A	t
3157	734	20093	N/A	t
3158	735	20093	N/A	t
3159	736	20093	N/A	t
3160	737	20093	N/A	t
3161	739	20093	N/A	t
3162	742	20093	N/A	t
3163	743	20093	N/A	t
3164	745	20093	N/A	t
3165	746	20093	N/A	t
3166	747	20093	N/A	t
3167	748	20093	N/A	t
3168	749	20093	N/A	t
3169	750	20093	N/A	t
3170	751	20093	N/A	t
3171	752	20093	N/A	t
3172	753	20093	N/A	t
3173	754	20093	N/A	t
3174	757	20093	N/A	t
3175	758	20093	N/A	t
3176	759	20093	N/A	t
3177	760	20093	N/A	t
3178	592	20101	N/A	t
3179	595	20101	N/A	t
3180	596	20101	N/A	t
3181	597	20101	N/A	t
3182	598	20101	N/A	t
3183	600	20101	N/A	t
3184	652	20101	N/A	t
3185	603	20101	N/A	t
3186	604	20101	N/A	t
3187	601	20101	N/A	t
3188	602	20101	N/A	t
3189	605	20101	N/A	t
3190	616	20101	N/A	t
3191	653	20101	N/A	t
3192	606	20101	N/A	t
3193	607	20101	N/A	t
3194	608	20101	N/A	t
3195	609	20101	N/A	t
3196	610	20101	N/A	t
3197	611	20101	N/A	t
3198	612	20101	N/A	t
3199	613	20101	N/A	t
3200	614	20101	N/A	t
3201	651	20101	N/A	t
3202	615	20101	N/A	t
3203	654	20101	N/A	t
3204	655	20101	N/A	t
3205	617	20101	N/A	t
3206	656	20101	N/A	t
3207	765	20101	N/A	t
3208	618	20101	N/A	t
3209	619	20101	N/A	t
3210	766	19991	N/A	t
3211	766	20001	N/A	t
3212	766	20002	N/A	t
3213	766	20003	N/A	t
3214	766	20011	N/A	t
3215	766	20012	N/A	t
3216	766	20013	N/A	t
3217	766	20021	N/A	t
3218	767	20021	N/A	t
3219	768	20021	N/A	t
3220	766	20022	N/A	t
3221	767	20022	N/A	t
3222	768	20022	N/A	t
3223	766	20031	N/A	t
3224	767	20031	N/A	t
3225	768	20031	N/A	t
3226	769	20031	N/A	t
3227	770	20031	N/A	t
3228	766	20032	N/A	t
3229	767	20032	N/A	t
3230	768	20032	N/A	t
3231	769	20032	N/A	t
3232	770	20032	N/A	t
3233	767	20033	N/A	t
3234	768	20033	N/A	t
3235	769	20033	N/A	t
3236	770	20033	N/A	t
3237	767	20041	N/A	t
3238	768	20041	N/A	t
3239	769	20041	N/A	t
3240	770	20041	N/A	t
3241	771	20041	N/A	t
3242	767	20042	N/A	t
3243	768	20042	N/A	t
3244	769	20042	N/A	t
3245	770	20042	N/A	t
3246	771	20042	N/A	t
3247	767	20043	N/A	t
3248	768	20043	N/A	t
3249	769	20043	N/A	t
3250	770	20043	N/A	t
3251	771	20043	N/A	t
3252	767	20051	N/A	t
3253	768	20051	N/A	t
3254	769	20051	N/A	t
3255	770	20051	N/A	t
3256	771	20051	N/A	t
3257	772	20051	N/A	t
3258	773	20051	N/A	t
3259	767	20052	N/A	t
3260	768	20052	N/A	t
3261	769	20052	N/A	t
3262	771	20052	N/A	t
3263	772	20052	N/A	t
3264	773	20052	N/A	t
3265	768	20053	N/A	t
3266	769	20053	N/A	t
3267	772	20053	N/A	t
3268	773	20053	N/A	t
3269	768	20061	N/A	t
3270	771	20061	N/A	t
3271	772	20061	N/A	t
3272	773	20061	N/A	t
3273	774	20061	N/A	t
3274	775	20061	N/A	t
3275	776	20061	N/A	t
3276	777	20061	N/A	t
3277	778	20061	N/A	t
3278	779	20061	N/A	t
3279	768	20062	N/A	t
3280	770	20062	N/A	t
3281	771	20062	N/A	t
3282	772	20062	N/A	t
3283	773	20062	N/A	t
3284	774	20062	N/A	t
3285	775	20062	N/A	t
3286	776	20062	N/A	t
3287	777	20062	N/A	t
3288	778	20062	N/A	t
3289	779	20062	N/A	t
3290	771	20063	N/A	t
3291	772	20063	N/A	t
3292	773	20063	N/A	t
3293	775	20063	N/A	t
3294	776	20063	N/A	t
3295	777	20063	N/A	t
3296	778	20063	N/A	t
3297	779	20063	N/A	t
3298	770	20071	N/A	t
3299	771	20071	N/A	t
3300	772	20071	N/A	t
3301	773	20071	N/A	t
3302	774	20071	N/A	t
3303	775	20071	N/A	t
3304	776	20071	N/A	t
3305	777	20071	N/A	t
3306	780	20071	N/A	t
3307	781	20071	N/A	t
3308	778	20071	N/A	t
3309	779	20071	N/A	t
3310	782	20071	N/A	t
3311	783	20071	N/A	t
3312	784	20071	N/A	t
3313	785	20071	N/A	t
3314	786	20071	N/A	t
3315	787	20071	N/A	t
3316	788	20071	N/A	t
3317	789	20071	N/A	t
3318	790	20071	N/A	t
3319	791	20071	N/A	t
3320	792	20071	N/A	t
3321	768	20072	N/A	t
3322	770	20072	N/A	t
3323	771	20072	N/A	t
3324	772	20072	N/A	t
3325	773	20072	N/A	t
3326	774	20072	N/A	t
3327	775	20072	N/A	t
3328	776	20072	N/A	t
3329	777	20072	N/A	t
3330	780	20072	N/A	t
3331	781	20072	N/A	t
3332	778	20072	N/A	t
3333	779	20072	N/A	t
3334	782	20072	N/A	t
3335	783	20072	N/A	t
3336	784	20072	N/A	t
3337	785	20072	N/A	t
3338	786	20072	N/A	t
3339	787	20072	N/A	t
3340	788	20072	N/A	t
3341	789	20072	N/A	t
3342	790	20072	N/A	t
3343	791	20072	N/A	t
3344	792	20072	N/A	t
3345	771	20073	N/A	t
3346	773	20073	N/A	t
3347	774	20073	N/A	t
3348	775	20073	N/A	t
3349	777	20073	N/A	t
3350	780	20073	N/A	t
3351	778	20073	N/A	t
3352	779	20073	N/A	t
3353	782	20073	N/A	t
3354	784	20073	N/A	t
3355	785	20073	N/A	t
3356	787	20073	N/A	t
3357	788	20073	N/A	t
3358	770	20081	N/A	t
3359	772	20081	N/A	t
3360	773	20081	N/A	t
3361	774	20081	N/A	t
3362	775	20081	N/A	t
3363	776	20081	N/A	t
3364	777	20081	N/A	t
3365	780	20081	N/A	t
3366	781	20081	N/A	t
3367	778	20081	N/A	t
3368	779	20081	N/A	t
3369	782	20081	N/A	t
3370	793	20081	N/A	t
3371	783	20081	N/A	t
3372	784	20081	N/A	t
3373	785	20081	N/A	t
3374	786	20081	N/A	t
3375	787	20081	N/A	t
3376	788	20081	N/A	t
3377	789	20081	N/A	t
3378	790	20081	N/A	t
3379	791	20081	N/A	t
3380	792	20081	N/A	t
3381	794	20081	N/A	t
3382	795	20081	N/A	t
3383	796	20081	N/A	t
3384	797	20081	N/A	t
3385	798	20081	N/A	t
3386	799	20081	N/A	t
3387	800	20081	N/A	t
3388	801	20081	N/A	t
3389	802	20081	N/A	t
3390	803	20081	N/A	t
3391	804	20081	N/A	t
3392	805	20081	N/A	t
3393	806	20081	N/A	t
3394	807	20081	N/A	t
3395	808	20081	N/A	t
3396	809	20081	N/A	t
3397	810	20081	N/A	t
3398	811	20081	N/A	t
3399	812	20081	N/A	t
3400	813	20081	N/A	t
3401	814	20081	N/A	t
3402	815	20081	N/A	t
3403	816	20081	N/A	t
3404	817	20081	N/A	t
3405	818	20081	N/A	t
3406	819	20081	N/A	t
3407	820	20081	N/A	t
3408	821	20081	N/A	t
3409	822	20081	N/A	t
3410	823	20081	N/A	t
3411	824	20081	N/A	t
3412	825	20081	N/A	t
3413	826	20081	N/A	t
3414	827	20081	N/A	t
3415	769	20082	N/A	t
3416	770	20082	N/A	t
3417	772	20082	N/A	t
3418	773	20082	N/A	t
3419	774	20082	N/A	t
3420	775	20082	N/A	t
3421	776	20082	N/A	t
3422	777	20082	N/A	t
3423	780	20082	N/A	t
3424	781	20082	N/A	t
3425	778	20082	N/A	t
3426	779	20082	N/A	t
3427	782	20082	N/A	t
3428	793	20082	N/A	t
3429	783	20082	N/A	t
3430	784	20082	N/A	t
3431	785	20082	N/A	t
3432	786	20082	N/A	t
3433	787	20082	N/A	t
3434	788	20082	N/A	t
3435	789	20082	N/A	t
3436	790	20082	N/A	t
3437	791	20082	N/A	t
3438	828	20082	N/A	t
3439	792	20082	N/A	t
3440	794	20082	N/A	t
3441	795	20082	N/A	t
3442	796	20082	N/A	t
3443	797	20082	N/A	t
3444	798	20082	N/A	t
3445	799	20082	N/A	t
3446	800	20082	N/A	t
3447	801	20082	N/A	t
3448	802	20082	N/A	t
3449	803	20082	N/A	t
3450	804	20082	N/A	t
3451	805	20082	N/A	t
3452	806	20082	N/A	t
3453	807	20082	N/A	t
3454	808	20082	N/A	t
3455	809	20082	N/A	t
3456	810	20082	N/A	t
3457	811	20082	N/A	t
3458	812	20082	N/A	t
3459	813	20082	N/A	t
3460	814	20082	N/A	t
3461	815	20082	N/A	t
3462	816	20082	N/A	t
3463	817	20082	N/A	t
3464	818	20082	N/A	t
3465	819	20082	N/A	t
3466	820	20082	N/A	t
3467	821	20082	N/A	t
3468	822	20082	N/A	t
3469	823	20082	N/A	t
3470	824	20082	N/A	t
3471	825	20082	N/A	t
3472	826	20082	N/A	t
3473	827	20082	N/A	t
3474	769	20083	N/A	t
3475	770	20083	N/A	t
3476	775	20083	N/A	t
3477	777	20083	N/A	t
3478	780	20083	N/A	t
3479	778	20083	N/A	t
3480	782	20083	N/A	t
3481	793	20083	N/A	t
3482	784	20083	N/A	t
3483	785	20083	N/A	t
3484	787	20083	N/A	t
3485	788	20083	N/A	t
3486	789	20083	N/A	t
3487	790	20083	N/A	t
3488	828	20083	N/A	t
3489	797	20083	N/A	t
3490	798	20083	N/A	t
3491	799	20083	N/A	t
3492	803	20083	N/A	t
3493	805	20083	N/A	t
3494	806	20083	N/A	t
3495	808	20083	N/A	t
3496	809	20083	N/A	t
3497	810	20083	N/A	t
3498	813	20083	N/A	t
3499	814	20083	N/A	t
3500	815	20083	N/A	t
3501	816	20083	N/A	t
3502	817	20083	N/A	t
3503	818	20083	N/A	t
3504	821	20083	N/A	t
3505	822	20083	N/A	t
3506	823	20083	N/A	t
3507	824	20083	N/A	t
3508	825	20083	N/A	t
3509	769	20091	N/A	t
3510	770	20091	N/A	t
3511	772	20091	N/A	t
3512	773	20091	N/A	t
3513	774	20091	N/A	t
3514	775	20091	N/A	t
3515	776	20091	N/A	t
3516	777	20091	N/A	t
3517	829	20091	N/A	t
3518	780	20091	N/A	t
3519	781	20091	N/A	t
3520	778	20091	N/A	t
3521	779	20091	N/A	t
3522	782	20091	N/A	t
3523	793	20091	N/A	t
3524	830	20091	N/A	t
3525	783	20091	N/A	t
3526	784	20091	N/A	t
3527	785	20091	N/A	t
3528	786	20091	N/A	t
3529	787	20091	N/A	t
3530	788	20091	N/A	t
3531	789	20091	N/A	t
3532	790	20091	N/A	t
3533	791	20091	N/A	t
3534	828	20091	N/A	t
3535	792	20091	N/A	t
3536	831	20091	N/A	t
3537	832	20091	N/A	t
3538	794	20091	N/A	t
3539	833	20091	N/A	t
3540	795	20091	N/A	t
3541	796	20091	N/A	t
3542	834	20091	N/A	t
3543	797	20091	N/A	t
3544	798	20091	N/A	t
3545	799	20091	N/A	t
3546	800	20091	N/A	t
3547	835	20091	N/A	t
3548	836	20091	N/A	t
3549	801	20091	N/A	t
3550	837	20091	N/A	t
3551	802	20091	N/A	t
3552	803	20091	N/A	t
3553	838	20091	N/A	t
3554	839	20091	N/A	t
3555	804	20091	N/A	t
3556	805	20091	N/A	t
3557	806	20091	N/A	t
3558	807	20091	N/A	t
3559	808	20091	N/A	t
3560	809	20091	N/A	t
3561	810	20091	N/A	t
3562	811	20091	N/A	t
3563	812	20091	N/A	t
3564	813	20091	N/A	t
3565	814	20091	N/A	t
3566	840	20091	N/A	t
3567	815	20091	N/A	t
3568	841	20091	N/A	t
3569	816	20091	N/A	t
3570	817	20091	N/A	t
3571	818	20091	N/A	t
3572	819	20091	N/A	t
3573	820	20091	N/A	t
3574	821	20091	N/A	t
3575	842	20091	N/A	t
3576	822	20091	N/A	t
3577	823	20091	N/A	t
3578	824	20091	N/A	t
3579	825	20091	N/A	t
3580	826	20091	N/A	t
3581	827	20091	N/A	t
3582	843	20091	N/A	t
3583	844	20091	N/A	t
3584	845	20091	N/A	t
3585	846	20091	N/A	t
3586	847	20091	N/A	t
3587	848	20091	N/A	t
3588	849	20091	N/A	t
3589	850	20091	N/A	t
3590	851	20091	N/A	t
3591	852	20091	N/A	t
3592	853	20091	N/A	t
3593	854	20091	N/A	t
3594	855	20091	N/A	t
3595	856	20091	N/A	t
3596	857	20091	N/A	t
3597	858	20091	N/A	t
3598	859	20091	N/A	t
3599	860	20091	N/A	t
3600	861	20091	N/A	t
3601	862	20091	N/A	t
3602	863	20091	N/A	t
3603	864	20091	N/A	t
3604	865	20091	N/A	t
3605	866	20091	N/A	t
3606	867	20091	N/A	t
3607	868	20091	N/A	t
3608	869	20091	N/A	t
3609	870	20091	N/A	t
3610	871	20091	N/A	t
3611	872	20091	N/A	t
3612	873	20091	N/A	t
3613	874	20091	N/A	t
3614	875	20091	N/A	t
3615	876	20091	N/A	t
3616	877	20091	N/A	t
3617	878	20091	N/A	t
3618	879	20091	N/A	t
3619	880	20091	N/A	t
3620	881	20091	N/A	t
3621	882	20091	N/A	t
3622	883	20091	N/A	t
3623	884	20091	N/A	t
3624	885	20091	N/A	t
3625	886	20091	N/A	t
3626	887	20091	N/A	t
3627	888	20091	N/A	t
3628	889	20091	N/A	t
3629	890	20091	N/A	t
3630	891	20091	N/A	t
3631	892	20091	N/A	t
3632	893	20091	N/A	t
3633	894	20091	N/A	t
3634	895	20091	N/A	t
3635	896	20091	N/A	t
3636	897	20091	N/A	t
3637	898	20091	N/A	t
3638	899	20091	N/A	t
3639	900	20091	N/A	t
3640	901	20091	N/A	t
3641	902	20091	N/A	t
3642	903	20091	N/A	t
3643	904	20091	N/A	t
3644	905	20091	N/A	t
3645	906	20091	N/A	t
3646	907	20091	N/A	t
3647	908	20091	N/A	t
3648	909	20091	N/A	t
3649	910	20091	N/A	t
3650	911	20091	N/A	t
3651	912	20091	N/A	t
3652	913	20091	N/A	t
3653	914	20091	N/A	t
3654	915	20091	N/A	t
3655	916	20091	N/A	t
3656	917	20091	N/A	t
3657	918	20091	N/A	t
3658	919	20091	N/A	t
3659	920	20091	N/A	t
3660	921	20091	N/A	t
3661	922	20091	N/A	t
3662	923	20091	N/A	t
3663	924	20091	N/A	t
3664	925	20091	N/A	t
3665	926	20091	N/A	t
3666	927	20091	N/A	t
3667	928	20091	N/A	t
3668	929	20091	N/A	t
3669	930	20091	N/A	t
3670	931	20091	N/A	t
3671	932	20091	N/A	t
3672	933	20091	N/A	t
3673	934	20091	N/A	t
3674	935	20091	N/A	t
3675	936	20091	N/A	t
3676	937	20091	N/A	t
3677	938	20091	N/A	t
3678	769	20092	N/A	t
3679	772	20092	N/A	t
3680	774	20092	N/A	t
3681	775	20092	N/A	t
3682	776	20092	N/A	t
3683	777	20092	N/A	t
3684	829	20092	N/A	t
3685	780	20092	N/A	t
3686	781	20092	N/A	t
3687	778	20092	N/A	t
3688	779	20092	N/A	t
3689	782	20092	N/A	t
3690	793	20092	N/A	t
3691	830	20092	N/A	t
3692	783	20092	N/A	t
3693	784	20092	N/A	t
3694	785	20092	N/A	t
3695	786	20092	N/A	t
3696	787	20092	N/A	t
3697	788	20092	N/A	t
3698	789	20092	N/A	t
3699	790	20092	N/A	t
3700	791	20092	N/A	t
3701	828	20092	N/A	t
3702	792	20092	N/A	t
3703	831	20092	N/A	t
3704	832	20092	N/A	t
3705	794	20092	N/A	t
3706	833	20092	N/A	t
3707	795	20092	N/A	t
3708	796	20092	N/A	t
3709	834	20092	N/A	t
3710	797	20092	N/A	t
3711	798	20092	N/A	t
3712	799	20092	N/A	t
3713	800	20092	N/A	t
3714	835	20092	N/A	t
3715	836	20092	N/A	t
3716	801	20092	N/A	t
3717	837	20092	N/A	t
3718	802	20092	N/A	t
3719	803	20092	N/A	t
3720	838	20092	N/A	t
3721	839	20092	N/A	t
3722	804	20092	N/A	t
3723	939	20092	N/A	t
3724	805	20092	N/A	t
3725	806	20092	N/A	t
3726	807	20092	N/A	t
3727	808	20092	N/A	t
3728	940	20092	N/A	t
3729	809	20092	N/A	t
3730	810	20092	N/A	t
3731	811	20092	N/A	t
3732	812	20092	N/A	t
3733	813	20092	N/A	t
3734	814	20092	N/A	t
3735	840	20092	N/A	t
3736	815	20092	N/A	t
3737	841	20092	N/A	t
3738	816	20092	N/A	t
3739	817	20092	N/A	t
3740	818	20092	N/A	t
3741	819	20092	N/A	t
3742	820	20092	N/A	t
3743	821	20092	N/A	t
3744	941	20092	N/A	t
3745	842	20092	N/A	t
3746	822	20092	N/A	t
3747	823	20092	N/A	t
3748	824	20092	N/A	t
3749	825	20092	N/A	t
3750	826	20092	N/A	t
3751	827	20092	N/A	t
3752	843	20092	N/A	t
3753	844	20092	N/A	t
3754	845	20092	N/A	t
3755	846	20092	N/A	t
3756	847	20092	N/A	t
3757	848	20092	N/A	t
3758	849	20092	N/A	t
3759	850	20092	N/A	t
3760	851	20092	N/A	t
3761	852	20092	N/A	t
3762	853	20092	N/A	t
3763	854	20092	N/A	t
3764	855	20092	N/A	t
3765	856	20092	N/A	t
3766	857	20092	N/A	t
3767	858	20092	N/A	t
3768	859	20092	N/A	t
3769	860	20092	N/A	t
3770	861	20092	N/A	t
3771	862	20092	N/A	t
3772	863	20092	N/A	t
3773	864	20092	N/A	t
3774	865	20092	N/A	t
3775	866	20092	N/A	t
3776	867	20092	N/A	t
3777	868	20092	N/A	t
3778	869	20092	N/A	t
3779	870	20092	N/A	t
3780	871	20092	N/A	t
3781	872	20092	N/A	t
3782	873	20092	N/A	t
3783	874	20092	N/A	t
3784	875	20092	N/A	t
3785	876	20092	N/A	t
3786	877	20092	N/A	t
3787	878	20092	N/A	t
3788	879	20092	N/A	t
3789	880	20092	N/A	t
3790	881	20092	N/A	t
3791	882	20092	N/A	t
3792	883	20092	N/A	t
3793	884	20092	N/A	t
3794	885	20092	N/A	t
3795	886	20092	N/A	t
3796	887	20092	N/A	t
3797	888	20092	N/A	t
3798	889	20092	N/A	t
3799	890	20092	N/A	t
3800	891	20092	N/A	t
3801	892	20092	N/A	t
3802	893	20092	N/A	t
3803	894	20092	N/A	t
3804	895	20092	N/A	t
3805	896	20092	N/A	t
3806	897	20092	N/A	t
3807	898	20092	N/A	t
3808	899	20092	N/A	t
3809	900	20092	N/A	t
3810	901	20092	N/A	t
3811	902	20092	N/A	t
3812	903	20092	N/A	t
3813	904	20092	N/A	t
3814	905	20092	N/A	t
3815	906	20092	N/A	t
3816	907	20092	N/A	t
3817	908	20092	N/A	t
3818	909	20092	N/A	t
3819	910	20092	N/A	t
3820	911	20092	N/A	t
3821	912	20092	N/A	t
3822	913	20092	N/A	t
3823	914	20092	N/A	t
3824	915	20092	N/A	t
3825	916	20092	N/A	t
3826	917	20092	N/A	t
3827	918	20092	N/A	t
3828	919	20092	N/A	t
3829	920	20092	N/A	t
3830	921	20092	N/A	t
3831	922	20092	N/A	t
3832	923	20092	N/A	t
3833	924	20092	N/A	t
3834	925	20092	N/A	t
3835	926	20092	N/A	t
3836	927	20092	N/A	t
3837	928	20092	N/A	t
3838	929	20092	N/A	t
3839	930	20092	N/A	t
3840	931	20092	N/A	t
3841	932	20092	N/A	t
3842	933	20092	N/A	t
3843	934	20092	N/A	t
3844	935	20092	N/A	t
3845	936	20092	N/A	t
3846	937	20092	N/A	t
3847	938	20092	N/A	t
3848	769	20093	N/A	t
3849	772	20093	N/A	t
3850	774	20093	N/A	t
3851	775	20093	N/A	t
3852	777	20093	N/A	t
3853	829	20093	N/A	t
3854	781	20093	N/A	t
3855	778	20093	N/A	t
3856	779	20093	N/A	t
3857	782	20093	N/A	t
3858	783	20093	N/A	t
3859	785	20093	N/A	t
3860	786	20093	N/A	t
3861	787	20093	N/A	t
3862	790	20093	N/A	t
3863	828	20093	N/A	t
3864	832	20093	N/A	t
3865	796	20093	N/A	t
3866	834	20093	N/A	t
3867	798	20093	N/A	t
3868	799	20093	N/A	t
3869	835	20093	N/A	t
3870	836	20093	N/A	t
3871	837	20093	N/A	t
3872	802	20093	N/A	t
3873	838	20093	N/A	t
3874	839	20093	N/A	t
3875	805	20093	N/A	t
3876	806	20093	N/A	t
3877	808	20093	N/A	t
3878	809	20093	N/A	t
3879	810	20093	N/A	t
3880	812	20093	N/A	t
3881	814	20093	N/A	t
3882	815	20093	N/A	t
3883	817	20093	N/A	t
3884	819	20093	N/A	t
3885	821	20093	N/A	t
3886	842	20093	N/A	t
3887	822	20093	N/A	t
3888	823	20093	N/A	t
3889	824	20093	N/A	t
3890	843	20093	N/A	t
3891	848	20093	N/A	t
3892	849	20093	N/A	t
3893	853	20093	N/A	t
3894	855	20093	N/A	t
3895	860	20093	N/A	t
3896	862	20093	N/A	t
3897	863	20093	N/A	t
3898	865	20093	N/A	t
3899	866	20093	N/A	t
3900	867	20093	N/A	t
3901	868	20093	N/A	t
3902	869	20093	N/A	t
3903	872	20093	N/A	t
3904	875	20093	N/A	t
3905	876	20093	N/A	t
3906	878	20093	N/A	t
3907	879	20093	N/A	t
3908	880	20093	N/A	t
3909	881	20093	N/A	t
3910	883	20093	N/A	t
3911	884	20093	N/A	t
3912	893	20093	N/A	t
3913	894	20093	N/A	t
3914	895	20093	N/A	t
3915	896	20093	N/A	t
3916	900	20093	N/A	t
3917	901	20093	N/A	t
3918	903	20093	N/A	t
3919	904	20093	N/A	t
3920	905	20093	N/A	t
3921	907	20093	N/A	t
3922	909	20093	N/A	t
3923	910	20093	N/A	t
3924	911	20093	N/A	t
3925	912	20093	N/A	t
3926	913	20093	N/A	t
3927	914	20093	N/A	t
3928	916	20093	N/A	t
3929	919	20093	N/A	t
3930	920	20093	N/A	t
3931	922	20093	N/A	t
3932	923	20093	N/A	t
3933	924	20093	N/A	t
3934	925	20093	N/A	t
3935	926	20093	N/A	t
3936	927	20093	N/A	t
3937	928	20093	N/A	t
3938	929	20093	N/A	t
3939	930	20093	N/A	t
3940	931	20093	N/A	t
3941	934	20093	N/A	t
3942	935	20093	N/A	t
3943	936	20093	N/A	t
3944	937	20093	N/A	t
3945	769	20101	N/A	t
3946	772	20101	N/A	t
3947	773	20101	N/A	t
3948	774	20101	N/A	t
3949	775	20101	N/A	t
3950	777	20101	N/A	t
3951	829	20101	N/A	t
3952	780	20101	N/A	t
3953	781	20101	N/A	t
3954	778	20101	N/A	t
3955	779	20101	N/A	t
3956	782	20101	N/A	t
3957	793	20101	N/A	t
3958	830	20101	N/A	t
3959	783	20101	N/A	t
3960	784	20101	N/A	t
3961	785	20101	N/A	t
3962	786	20101	N/A	t
3963	787	20101	N/A	t
3964	788	20101	N/A	t
3965	789	20101	N/A	t
3966	790	20101	N/A	t
3967	791	20101	N/A	t
3968	828	20101	N/A	t
3969	792	20101	N/A	t
3970	831	20101	N/A	t
3971	832	20101	N/A	t
3972	794	20101	N/A	t
3973	833	20101	N/A	t
3974	942	20101	N/A	t
3975	795	20101	N/A	t
3976	796	20101	N/A	t
3977	943	20031	N/A	t
3978	944	20031	N/A	t
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

