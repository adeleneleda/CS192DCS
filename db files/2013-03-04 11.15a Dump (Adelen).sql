--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

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
		WHERE termid <= $1) AS temp
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
		WHERE termid <= $1) AS temp
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
					WHERE classes.termid <= $1
						AND students.studentid = studentlist.jstudentid
						AND classes.courseid = studentlist.courseid) >= 1
			) AS studentlist
		ON (studentlist.jstudentid = students.studentid AND studentlist.courseid = classes.courseid)
	WHERE grades.gradevalue = 5
	ORDER BY students.studentid, classes.courseid, classes.termid;
$_$;


ALTER FUNCTION public.f_elig_twicefailsubjects(p_termid integer) OWNER TO postgres;

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

SELECT pg_catalog.setval('persons_personid_seq', 245, true);


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

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 4612, true);


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

SELECT pg_catalog.setval('students_studentid_seq', 235, true);


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

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 925, true);


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
-- Data for Name: eligtwicefailcourses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY eligtwicefailcourses (courseid) FROM stdin;
104
105
106
107
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

