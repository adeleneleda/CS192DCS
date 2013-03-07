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
	studenttermid integer,
	unitspassed real
);


ALTER TYPE public.t_elig_24unitspassed OWNER TO postgres;

--
-- Name: t_elig_passhalf_mathcs_persem; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE t_elig_passhalf_mathcs_persem AS (
	studentid integer,
	studenttermid integer,
	failpercentage real
);


ALTER TYPE public.t_elig_passhalf_mathcs_persem OWNER TO postgres;

--
-- Name: t_elig_passhalfpersem; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE t_elig_passhalfpersem AS (
	studentid integer,
	studenttermid integer,
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


IF (SELECT COUNT(*) FROM viewclasses WHERE studentid = $1 AND coursename like 'cs%' AND gradeid <= 11) = 0
	THEN RETURN 0;
END IF;


SELECT SUM(gradevalue * credits) / SUM(credits) into x

FROM viewclasses

WHERE studentid = $1 AND coursename like 'cs%' AND gradeid <= 11;



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

	SELECT studentid, studenttermid, unitspassed

	FROM 

		(SELECT studentid, studenttermid,

			(SELECT SUM(courses.credits)

			FROM studentterms JOIN studentclasses USING (studenttermid)

				JOIN classes USING (classid)

				JOIN grades USING (gradeid)

				JOIN courses USING (courseid)

			WHERE grades.gradevalue <= 5 AND grades.gradevalue >= 1

				AND studentterms.termid >= $1 * 10

				AND studentterms.termid <= $1 * 10 + 3

				AND studentterms.studenttermid = outerTerms.studenttermid

			)

			AS unitspassed

		FROM studentterms AS outerTerms) as innerQuery

	WHERE unitspassed < 24

$_$;


ALTER FUNCTION public.f_elig_24unitspassed(p_year integer) OWNER TO postgres;

--
-- Name: f_elig_passhalf_mathcs_persem(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_elig_passhalf_mathcs_persem(p_termid integer) RETURNS SETOF t_elig_passhalf_mathcs_persem
    LANGUAGE sql
    AS $_$

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
-- Name: gwa(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gwa(p_studentid integer, p_termid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE x NUMERIC;
counter NUMERIC;



BEGIN
IF (SELECT COUNT(*) FROM viewclasses WHERE studentid = $1 AND termid = $2 AND gradeid <= 11) = 0
	THEN RETURN 0;
END IF;

SELECT SUM(gradevalue*credits) / SUM(credits) into x

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


IF (SELECT COUNT(*) FROM viewclasses WHERE studentid = $1 AND coursename like 'math%' AND (coursename <> 'math 1' AND coursename <> 'math 2') AND gradeid <= 11) = 0
	THEN RETURN 0;
END IF;


SELECT SUM(gradevalue * credits) / SUM(credits) into x

FROM viewclasses

WHERE studentid = $1 AND coursename like 'math%' AND (coursename <> 'math 1' AND coursename <> 'math 2') AND gradeid <= 11;



RETURN round(x,4);



END$_$;


ALTER FUNCTION public.mathgwa(p_studentid integer) OWNER TO postgres;

--
-- Name: ns1_correction(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ns1_correction(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

ns1group_credits numeric DEFAULT 0;

otherMST_credits numeric DEFAULT 0;



BEGIN



	CREATE TEMPORARY TABLE allmstPass AS

		SELECT v.gradevalue as x, v.credits as y, v.coursename

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND v.gradeid < 10

		ORDER BY v.termid ASC;



	SELECT SUM(x * y) into ns1group_credits

	FROM allmstPass 

	WHERE coursename IN ('nat sci 1', 'chem 1', 'physics 10')

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('nat sci 1', 'chem 1', 'physics 10')) != 0 THEN

		SELECT SUM(x * y) into otherMST_credits

		FROM allmstPass

		WHERE coursename NOT IN ('nat sci 1', 'chem 1', 'physics 10')

		LIMIT 2;

	END IF;



	return ns1group_credits + otherMST_credits;



END;$_$;


ALTER FUNCTION public.ns1_correction(p_studentid integer) OWNER TO postgres;

--
-- Name: ns1_dcorrection(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ns1_dcorrection(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

ns1group_units numeric DEFAULT 0;

otherMST_units numeric DEFAULT 0;



BEGIN



	CREATE TEMPORARY TABLE allmstPass AS

		SELECT v.gradevalue as x, v.credits as y, v.coursename

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND v.gradeid < 10

		ORDER BY v.termid ASC;



	SELECT SUM(y) into ns1group_units

	FROM allmstPass 

	WHERE coursename IN ('nat sci 1', 'chem 1', 'physics 10')

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('nat sci 1', 'chem 1', 'physics 10')) != 0 THEN

		SELECT SUM(y) into otherMST_units

		FROM allmstPass

		WHERE coursename NOT IN ('nat sci 1', 'chem 1', 'physics 10')

		LIMIT 2;

	END IF;



	return ns1group_units + otherMST_units;



END;$_$;


ALTER FUNCTION public.ns1_dcorrection(p_studentid integer) OWNER TO postgres;

--
-- Name: ns2_correction(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ns2_correction(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

ns2group_credits numeric DEFAULT 0;

otherMST_credits numeric DEFAULT 0;



BEGIN



	CREATE TEMPORARY TABLE allmstPass AS

		SELECT v.gradevalue as x, v.credits as y, v.coursename

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND v.gradeid < 10

		ORDER BY v.termid ASC;



	SELECT SUM(x * y) into ns2group_credits

	FROM allmstPass 

	WHERE coursename IN ('nat sci 2', 'bio 1', 'geol 1')

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('nat sci 2', 'bio 1', 'geol 1')) != 0 THEN

		SELECT SUM(x * y) into otherMST_credits

		FROM allmstPass

		WHERE coursename NOT IN ('nat sci 2', 'bio 1', 'geol 1')

		LIMIT 2;

	END IF;



	return ns2group_credits + otherMST_credits;



END;$_$;


ALTER FUNCTION public.ns2_correction(p_studentid integer) OWNER TO postgres;

--
-- Name: ns2_dcorrection(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ns2_dcorrection(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

ns2group_units numeric DEFAULT 0;

otherMST_units numeric DEFAULT 0;



BEGIN



	CREATE TEMPORARY TABLE allmstPass AS

		SELECT v.gradevalue as x, v.credits as y, v.coursename

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND v.gradeid < 10

		ORDER BY v.termid ASC;



	SELECT SUM(y) into ns2group_units

	FROM allmstPass 

	WHERE coursename IN ('nat sci 2', 'bio 1', 'geol 1')

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allmstPass WHERE coursename NOT IN ('nat sci 2', 'bio 1', 'geol 1')) != 0 THEN

		SELECT SUM(y) into otherMST_units

		FROM allmstPass

		WHERE coursename NOT IN ('nat sci 2', 'bio 1', 'geol 1')

		LIMIT 2;

	END IF;



	return ns2group_units + otherMST_units;



END;$_$;


ALTER FUNCTION public.ns2_dcorrection(p_studentid integer) OWNER TO postgres;

--
-- Name: overFE_correction(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "overFE_correction"(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

FEgroup_credits numeric DEFAULT 0;

otherELE_credits numeric DEFAULT 0;



BEGIN

	CREATE TEMPORARY TABLE allelePass AS 

	SELECT v.gradevalue as x, v.credits as y

	FROM viewclasses v 

	WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

	ORDER BY v.termid ASC;



	SELECT SUM(x * y) into FEgroup_credits

	FROM allelePass

	WHERE v.domain = 'FE'

	LIMIT 1;



	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN

		SELECT SUM(x * y) into otherELE_credits

		FROM allelePass

		WHERE v.domain <> 'FE'

		LIMIT 2;

	END IF;



	return FEgroup_credits + otherELE_credits;

END$_$;


ALTER FUNCTION public."overFE_correction"(p_studentid integer) OWNER TO postgres;

--
-- Name: overFE_dcorrection(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "overFE_dcorrection"() RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

FEgroup_units numeric DEFAULT 0;

otherELE_units numeric DEFAULT 0;



BEGIN

	CREATE TEMPORARY TABLE allelePass AS 

	SELECT v.gradevalue as x, v.credits as y

	FROM viewclasses v 

	WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

	ORDER BY v.termid ASC;



	SELECT SUM(y) into FEgroup_units

	FROM allelePass

	WHERE v.domain = 'FE'

	LIMIT 1;



	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN

		SELECT SUM(y) into otherELE_units

		FROM allelePass

		WHERE v.domain <> 'FE'

		LIMIT 2;

	END IF;



	return FEgroup_units + otherELE_units;

END$_$;


ALTER FUNCTION public."overFE_dcorrection"() OWNER TO postgres;

--
-- Name: overMSEE_correction(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "overMSEE_correction"(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

MSEEgroup_credits numeric DEFAULT 0;

otherELE_credits numeric DEFAULT 0;



BEGIN

	CREATE TEMPORARY TABLE allelePass AS 

	SELECT v.gradevalue as x, v.credits as y

	FROM viewclasses v 

	WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

	ORDER BY v.termid ASC;



	SELECT SUM(x * y) into MSEEgroup_credits

	FROM allelePass

	WHERE v.domain = 'MSEE'

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN

		SELECT SUM(x * y) into otherELE_credits

		FROM allelePass

		WHERE v.domain <> 'MSEE'

		LIMIT 1;

	END IF;



	return MSEEgroup_credits + otherELE_credits;

END$_$;


ALTER FUNCTION public."overMSEE_correction"(p_studentid integer) OWNER TO postgres;

--
-- Name: overMSEE_dcorrection(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "overMSEE_dcorrection"(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

MSEEgroup_units numeric DEFAULT 0;

otherELE_units numeric DEFAULT 0;



BEGIN

	CREATE TEMPORARY TABLE allelePass AS 

	SELECT v.gradevalue as x, v.credits as y

	FROM viewclasses v 

	WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

	ORDER BY v.termid ASC;



	SELECT SUM(y) into MSEEgroup_units

	FROM allelePass

	WHERE v.domain = 'MSEE'

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN

		SELECT SUM(y) into otherELE_units

		FROM allelePass

		WHERE v.domain <> 'MSEE'

		LIMIT 1;

	END IF;



	return MSEEgroup_units + otherELE_units;

END$_$;


ALTER FUNCTION public."overMSEE_dcorrection"(p_studentid integer) OWNER TO postgres;

--
-- Name: overcs197_correction(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION overcs197_correction(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

CSEgroup_credits numeric DEFAULT 0;

otherELE_credits numeric DEFAULT 0;



BEGIN

	CREATE TEMPORARY TABLE allelePass AS 

	SELECT v.gradevalue as x, v.credits as y

	FROM viewclasses v 

	WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

	ORDER BY v.termid ASC;



	SELECT SUM(x * y) into CSEgroup_credits

	FROM allelePass

	WHERE v.domain = 'C197'

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN

		SELECT SUM(x * y) into otherELE_credits

		FROM allelePass

		WHERE v.domain <> 'C197'

		LIMIT 1;

	END IF;



	return CSEgroup_credits + otherELE_credits;

END$_$;


ALTER FUNCTION public.overcs197_correction(p_studentid integer) OWNER TO postgres;

--
-- Name: overcs197_dcorrection(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION overcs197_dcorrection(p_studentid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$DECLARE

CSEgroup_units numeric DEFAULT 0;

otherELE_units numeric DEFAULT 0;



BEGIN

	CREATE TEMPORARY TABLE allelePass AS 

	SELECT v.gradevalue as x, v.credits as y

	FROM viewclasses v 

	WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'C197') AND v.gradeid < 10

	ORDER BY v.termid ASC;



	SELECT SUM(y) into CSEgroup_units

	FROM allelePass

	WHERE v.domain = 'C197'

	LIMIT 2;



	IF (SELECT COUNT(*) FROM allelePass WHERE v.domain <> 'CSE') <> 0 THEN

		SELECT SUM(y) into otherELE_units

		FROM allelePass

		WHERE v.domain <> 'C197'

		LIMIT 1;

	END IF;



	return CSEgroup_units + otherELE_units;

END$_$;


ALTER FUNCTION public.overcs197_dcorrection(p_studentid integer) OWNER TO postgres;

--
-- Name: unitspassed(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION unitspassed(p_studentid integer) RETURNS numeric
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

unitspassed numeric DEFAULT 0;



BEGIN







	CREATE TEMPORARY TABLE first5ahPass AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'AH' AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 5;



	CREATE TEMPORARY TABLE first4mstPass AS

		SELECT v.gradevalue as x, v.credits as y, v.coursename

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename <> 'math 2' AND v.coursename <> 'math 1' AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 4;



	CREATE TEMPORARY TABLE first5sspPass AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'SSP' AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 5;



	CREATE TEMPORARY TABLE majors AS 

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v 

		WHERE v.studentid = $1 AND v.domain = 'MAJ' AND v.gradeid < 10;



	CREATE TEMPORARY TABLE first3elePass AS

		SELECT v.gradevalue as x, v.credits as y

		FROM viewclasses v

		WHERE v.studentid = $1 AND (v.domain = 'CSE' OR v.domain = 'MSEE' OR v.domain = 'FE' OR v.domain = 'CSE197') AND v.gradeid < 10

		ORDER BY v.termid ASC

		LIMIT 3;





	IF (SELECT COUNT(*) FROM first5ahPass) <> 0 THEN

		--SELECT SUM(x * y) into ah FROM first5ahPass;

		SELECT SUM(y) into ahd FROM first5ahPass;

	END IF;



	IF (SELECT COUNT(*) FROM first4mstPass) <> 0 THEN

		--SELECT SUM(x * y) into mst FROM first4mstPass;

		SELECT SUM(y) into mstd FROM first4mstPass;



		IF (SELECT COUNT(*) FROM first4mstPass WHERE coursename IN ('nat sci 1', 'chem 1', 'physics 10')) > 2 THEN 

			--SELECT ns1_correction($1) into mst; 

			SELECT ns1_dcorrection($1) into mstd;

		END IF;

		

		IF (SELECT COUNT(*) FROM first4mstPass WHERE coursename IN ('nat sci 2', 'bio 1', 'geol 1')) > 2 THEN 

			--SELECT ns2_correction($1) into mst; 

			SELECT ns2_dcorrection($1) into mstd;

		END IF;

		

	END IF;



	IF (SELECT COUNT(*) FROM first5sspPass) <> 0 THEN

		--SELECT SUM(x * y) into ssp FROM first5sspPass;

		SELECT SUM(y) into sspd FROM first5sspPass;

	END IF;



	IF (SELECT COUNT(*) FROM majors) <> 0 THEN

		--SELECT SUM(x * y) into maj FROM majors;

		SELECT SUM(y) into majd FROM majors;

	END IF;



	IF (SELECT COUNT(*) FROM first3elePass) <> 0 THEN

		--SELECT SUM(x * y) into ele FROM first3elePass;

		SELECT SUM(y) into eled FROM first3elePass;



		IF (SELECT COUNT(*) FROM first3elePass WHERE v.domain = 'CSE197') > 2 THEN

			--SELECT overcs197_correction($1) INTO ele;

			SELECT overcs197_dcorrection($1) INTO eled;

		END IF;



		IF (SELECT COUNT(*) FROM first3ele WHERE v.domain = 'MSEE') > 2 THEN

			--SELECT overMSEE_correction($1) INTO ele;

			SELECT overMSEE_dcorrection($1) INTO eled;

		END if;



		IF (SELECT COUNT(*) FROM first3ele WHERE v.domain = 'FE') > 2 THEN

			--SELECT overFE_correction($1) INTO ele;

			SELECT overFE_dcorrection($1) INTO eled; 

		END IF;

	END IF;



	unitspassed = (ahd + mstd + sspd + majd + eled) / 145;



	DROP TABLE first5ahPass;

	DROP TABLE first4mstPass;

	DROP TABLE first5sspPass;

	DROP TABLE majors;

	DROP TABLE first3elePass;

	

	RETURN round(unitspassed,4);	



END$_$;


ALTER FUNCTION public.unitspassed(p_studentid integer) OWNER TO postgres;

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

SELECT pg_catalog.setval('classes_classid_seq', 94, true);


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

SELECT pg_catalog.setval('persons_personid_seq', 67, true);


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

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 728, true);


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
    curriculumid integer,
    cwa numeric DEFAULT 0 NOT NULL
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

SELECT pg_catalog.setval('students_studentid_seq', 57, true);


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

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 157, true);


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
-- Name: classes_courseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY classes
    ADD CONSTRAINT classes_courseid_fkey FOREIGN KEY (courseid) REFERENCES courses(courseid);


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


INSERT INTO curricula (curriculumname) VALUES ('new');
INSERT INTO curricula (curriculumname) VALUES ('old');

INSERT INTO grades (gradename, gradevalue) VALUES ('1.00', 1.00);
INSERT INTO grades (gradename, gradevalue) VALUES ('1.25', 1.25);
INSERT INTO grades (gradename, gradevalue) VALUES ('1.50', 1.50);
INSERT INTO grades (gradename, gradevalue) VALUES ('1.75', 1.75);
INSERT INTO grades (gradename, gradevalue) VALUES ('2.00', 2.00);
INSERT INTO grades (gradename, gradevalue) VALUES ('2.25', 2.25);
INSERT INTO grades (gradename, gradevalue) VALUES ('2.50', 2.50);
INSERT INTO grades (gradename, gradevalue) VALUES ('2.75', 2.75);
INSERT INTO grades (gradename, gradevalue) VALUES ('3.00', 3.00);
INSERT INTO grades (gradename, gradevalue) VALUES ('4.00', 4.00);
INSERT INTO grades (gradename, gradevalue) VALUES ('5.00', 5.00);
INSERT INTO grades (gradename, gradevalue) VALUES ('INC', -1.00);
INSERT INTO grades (gradename, gradevalue) VALUES ('NG', -2.00);
INSERT INTO grades (gradename, gradevalue) VALUES ('DRP', 0.00);

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


INSERT INTO courses VALUES(31, 'Comm 1', 3, 'AH', 'E');
INSERT INTO courses VALUES(32, 'Comm 2', 3, 'AH', 'E');
INSERT INTO courses VALUES(33, 'Hum 1', 3, 'AH', NULL);
INSERT INTO courses VALUES(34, 'Hum 2', 3, 'AH', NULL);
INSERT INTO courses VALUES(35, 'Aral Pil 12', 3, 'AH', 'P');
INSERT INTO courses VALUES(36, 'Art Stud 1', 3, 'AH', NULL);
INSERT INTO courses VALUES(37, 'Art Stud 2', 3, 'AH', NULL);
INSERT INTO courses VALUES(38, 'BC 10', 3, 'AH', NULL);
INSERT INTO courses VALUES(39, 'Comm 3', 3, 'AH', 'E');
INSERT INTO courses VALUES(40, 'CW 10', 3, 'AH', 'E');
INSERT INTO courses VALUES(41, 'Eng 1', 3, 'AH', 'E');
INSERT INTO courses VALUES(42, 'Eng 10', 3, 'AH', 'E');
INSERT INTO courses VALUES(43, 'Eng 11', 3, 'AH', 'E');
INSERT INTO courses VALUES(44, 'L Arch 1', 3, 'AH', NULL);
INSERT INTO courses VALUES(45, 'Eng 30', 3, 'AH', 'E');
INSERT INTO courses VALUES(46, 'EL 50', 3, 'AH', NULL);
INSERT INTO courses VALUES(47, 'FA 28', 3, 'AH', 'P');
INSERT INTO courses VALUES(48, 'FA 30', 3, 'AH', NULL);
INSERT INTO courses VALUES(49, 'Fil 25', 3, 'AH', NULL);
INSERT INTO courses VALUES(50, 'Fil 40', 3, 'AH', 'P');
INSERT INTO courses VALUES(51, 'Film 10', 3, 'AH', NULL);
INSERT INTO courses VALUES(52, 'Film 12', 3, 'AH', 'P');
INSERT INTO courses VALUES(53, 'Humad 1', 3, 'AH', 'P');
INSERT INTO courses VALUES(54, 'J 18', 3, 'AH', NULL);
INSERT INTO courses VALUES(55, 'Kom 1', 3, 'AH', 'E');
INSERT INTO courses VALUES(56, 'Kom 2', 3, 'AH', 'E');
INSERT INTO courses VALUES(57, 'MPs 10', 3, 'AH', 'P');
INSERT INTO courses VALUES(58, 'MuD 1', 3, 'AH', NULL);
INSERT INTO courses VALUES(59, 'MuL 9', 3, 'AH', 'P');
INSERT INTO courses VALUES(60, 'MuL 13', 3, 'AH', NULL);
INSERT INTO courses VALUES(61, 'Pan Pil 12', 3, 'AH', 'P');
INSERT INTO courses VALUES(62, 'Pan Pil 17', 3, 'AH', 'P');
INSERT INTO courses VALUES(63, 'Pan Pil 19', 3, 'AH', 'P');
INSERT INTO courses VALUES(64, 'Pan Pil 40', 3, 'AH', 'P');
INSERT INTO courses VALUES(65, 'Pan Pil 50', 3, 'AH', 'P');
INSERT INTO courses VALUES(66, 'SEA 30', 3, 'AH', NULL);
INSERT INTO courses VALUES(67, 'Theatre 10', 3, 'AH', NULL);
INSERT INTO courses VALUES(68, 'Theatre 11', 3, 'AH', 'P');
INSERT INTO courses VALUES(69, 'Theatre 12', 3, 'AH', NULL);


INSERT INTO courses VALUES(70, 'Bio 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(71, 'Chem 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(72, 'EEE 10', 3, 'MST', NULL);
INSERT INTO courses VALUES(73, 'Env Sci 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(74, 'ES 10', 3, 'MST', NULL);
INSERT INTO courses VALUES(75, 'GE 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(76, 'Geol 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(77, 'L Arch 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(78, 'Math 2', 3, 'MST', NULL);
INSERT INTO courses VALUES(79, 'MBB 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(80, 'MS 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(81, 'Nat Sci 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(82, 'Nat Sci 2', 3, 'MST', NULL);
INSERT INTO courses VALUES(83, 'Physics 10', 3, 'MST', NULL);
INSERT INTO courses VALUES(84, 'STS', 3, 'MST', NULL);
INSERT INTO courses VALUES(85, 'FN 1', 3, 'MST', NULL);
INSERT INTO courses VALUES(86, 'CE 10', 3, 'MST', NULL);

INSERT INTO courses VALUES(87, 'Anthro 10', 3, 'SSP', NULL);
INSERT INTO courses VALUES(88, 'Archaeo 2', 3, 'SSP', NULL);
INSERT INTO courses VALUES(89, 'Arkiyoloji 1', 3, 'SSP', 'P');
INSERT INTO courses VALUES(90, 'CE 10', 3, 'SSP', NULL);
INSERT INTO courses VALUES(91, 'Econ 11', 3, 'SSP', NULL);
INSERT INTO courses VALUES(92, 'Econ 31', 3, 'SSP', NULL);
INSERT INTO courses VALUES(93, 'Geog 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES(94, 'Kas 1', 3, 'SSP', 'P');
INSERT INTO courses VALUES(95, 'Kas 2', 3, 'SSP', NULL);
INSERT INTO courses VALUES(96, 'L Arch 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES(97, 'Lingg 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES(98, 'Philo 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES(99, 'Philo 10', 3, 'SSP', NULL);
INSERT INTO courses VALUES(100, 'Philo 11', 3, 'SSP', NULL);
INSERT INTO courses VALUES(101, 'SEA 30', 3, 'SSP', 'P');
INSERT INTO courses VALUES(102, 'Soc Sci 1', 3, 'SSP', NULL);
INSERT INTO courses VALUES(103, 'Soc Sci 2', 3, 'SSP', NULL);
INSERT INTO courses VALUES(104, 'Soc Sci 3', 3, 'SSP', NULL);
INSERT INTO courses VALUES(105, 'Socio 10', 3, 'SSP', 'P');

INSERT INTO courses VALUES(106, 'Math 17', 5, 'MAJ', NULL);
INSERT INTO courses VALUES(107, 'Math 53', 5, 'MAJ', NULL);
INSERT INTO courses VALUES(108, 'Math 54', 5, 'MAJ', NULL);
INSERT INTO courses VALUES(109, 'Math 55', 3, 'MAJ', NULL);

INSERT INTO courses VALUES(110, 'Physics 71', 4, 'MAJ', NULL);
INSERT INTO courses VALUES(111, 'Physics 72', 4, 'MAJ', NULL);

INSERT INTO courses VALUES(112, 'Stat 130', 3, 'MAJ', NULL);
INSERT INTO courses VALUES(113, 'PI 100', 3, 'MAJ', NULL);
INSERT INTO courses VALUES(114, 'EEE 8', 3, 'MAJ', NULL);
INSERT INTO courses VALUES(115, 'EEE 9', 3, 'MAJ', NULL);	

	
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

