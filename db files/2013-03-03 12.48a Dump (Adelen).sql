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
    section character varying(7),
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
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY courses (courseid, coursename, credits, domain, commtype) FROM stdin;
1	cs 11	3	MAJ	\N
2	cs 12	3	MAJ	\N
3	cs 21	4	MAJ	\N
4	cs 30	3	MAJ	\N
5	cs 32	3	MAJ	\N
6	cs 140	3	MAJ	\N
7	cs 150	3	MAJ	\N
8	cs 135	3	MAJ	\N
9	cs 165	3	MAJ	\N
10	cs 191	3	MAJ	\N
11	cs 130	3	MAJ	\N
12	cs 192	3	MAJ	\N
13	cs 194	1	MAJ	\N
14	cs 145	3	MAJ	\N
15	cs 153	3	MAJ	\N
16	cs 180	3	MAJ	\N
17	cs 131	3	MAJ	\N
18	cs 195	3	MAJ	\N
19	cs 133	3	MAJ	\N
20	cs 198	3	MAJ	\N
21	cs 196	1	MAJ	\N
22	cs 199	3	MAJ	\N
23	cs 197	3	ELEC	\N
24	cs 120	3	ELEC	\N
27	cs 173	3	ELEC	\N
28	cs 174	3	ELEC	\N
29	cs 175	3	ELEC	\N
30	cs 176	3	ELEC	\N
25	cs 171	3	ELEC	\N
26	cs 172	3	ELEC	\N
31	comm 1	3	AH	E
32	comm 2	3	AH	E
33	hum 1	3	AH	\N
34	hum 2	3	AH	\N
35	aral pil 12	3	AH	P
36	art stud 1	3	AH	\N
37	art stud 2	3	AH	\N
38	bc 10	3	AH	\N
39	comm 3	3	AH	E
40	cw 10	3	AH	E
41	eng 1	3	AH	E
42	eng 10	3	AH	E
43	eng 11	3	AH	E
44	l arch 1	3	AH	\N
45	eng 30	3	AH	E
46	el 50	3	AH	\N
47	fa 28	3	AH	P
48	fa 30	3	AH	\N
49	fil 25	3	AH	\N
50	fil 40	3	AH	P
51	film 10	3	AH	\N
52	film 12	3	AH	P
53	humad 1	3	AH	P
54	j 18	3	AH	\N
55	kom 1	3	AH	E
56	kom 2	3	AH	E
57	mps 10	3	AH	P
58	mud 1	3	AH	\N
59	mul 9	3	AH	P
60	mul 13	3	AH	\N
61	pan pil 12	3	AH	P
62	pan pil 17	3	AH	P
63	pan pil 19	3	AH	P
64	pan pil 40	3	AH	P
65	pan pil 50	3	AH	P
66	sea 30	3	AH	\N
67	theatre 10	3	AH	\N
68	theatre 11	3	AH	P
69	theatre 12	3	AH	\N
70	bio 1	3	MST	\N
71	chem 1	3	MST	\N
72	eee 10	3	MST	\N
73	env sci 1	3	MST	\N
74	es 10	3	MST	\N
75	ge 1	3	MST	\N
76	geol 1	3	MST	\N
77	l arch 1	3	MST	\N
78	math 2	3	MST	\N
79	mbb 1	3	MST	\N
80	ms 1	3	MST	\N
81	nat sci 1	3	MST	\N
82	nat sci 2	3	MST	\N
83	physics 10	3	MST	\N
84	sts	3	MST	\N
85	fn 1	3	MST	\N
86	anthro 10	3	SSP	\N
87	archaeo 2	3	SSP	\N
88	arkiyoloji 1	3	SSP	P
89	econ 11	3	SSP	\N
90	econ 31	3	SSP	\N
91	geog 1	3	SSP	\N
92	kas 1	3	SSP	P
93	kas 2	3	SSP	\N
94	l arch 1	3	SSP	\N
95	lingg 1	3	SSP	\N
96	philo 1	3	SSP	\N
97	philo 10	3	SSP	\N
98	philo 11	3	SSP	\N
99	sea 30	3	SSP	P
100	soc sci 1	3	SSP	\N
101	soc sci 2	3	SSP	\N
102	soc sci 3	3	SSP	\N
103	socio 10	3	SSP	P
104	math 17	5	MAJ	\N
105	math 53	5	MAJ	\N
106	math 54	5	MAJ	\N
107	math 55	3	MAJ	\N
108	physics 71	4	MAJ	\N
109	physics 72	4	MAJ	\N
110	Stat 130	3	MAJ	\N
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
\.


--
-- Data for Name: studentineligibilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentineligibilities (studentineligibilityid, ineligibilityid) FROM stdin;
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY students (studentid, personid, studentno, curriculumid, cwa) FROM stdin;
1	1	200928374	2	0
2	2	200947583	2	0
3	3	200937561	2	0
4	4	200975639	2	0
5	5	200909570	2	0
6	6	200983647	2	0
7	7	200917263	2	0
8	8	200912341	2	0
9	9	200934567	2	0
10	10	200912651	2	0
11	11	201000001	1	1.8947
12	12	201000002	1	1.8672
13	13	201000003	1	1.8229
14	14	201000004	1	1.8255
15	15	201000005	1	1.9557
16	16	201000006	1	1.2043
17	17	201000033	1	1.4570
18	18	201092343	1	1.5565
19	19	201032143	1	1.5860
20	20	201092384	1	1.2876
21	21	201123456	1	1.2151
22	22	201100098	1	1.9471
23	23	201110001	1	2.6587
24	24	201110002	1	1.3462
25	25	201111000	1	1.6202
26	26	201192833	1	2.2163
27	27	201123453	1	3.2885
28	28	201100092	1	1.8894
29	29	201100321	1	2.0385
30	30	201101010	1	1.7452
31	31	201209876	1	1.4559
32	32	201212341	1	1.0882
33	33	201234567	1	1.8235
34	34	201202030	1	1.5588
35	35	201212341	1	1.6324
36	36	201212134	1	1.4706
37	37	201210000	1	1.6176
38	38	201220000	1	1.5882
39	39	201230000	1	1.3971
40	40	201240000	1	1.1324
41	51	201125423	1	1.6971
42	52	201103298	1	2.2981
43	53	201110024	1	1.6394
44	54	201110543	1	1.6538
45	55	201111145	1	2.0192
46	56	201192972	1	1.2740
47	57	201125134	1	1.6346
48	58	201104312	1	2.4952
49	59	201106312	1	2.1106
50	60	201105423	1	1.8606
51	61	201198549	1	1.4663
52	62	201121234	1	2.1106
53	63	201106323	1	2.1683
54	64	201185235	1	1.5288
55	65	201176204	1	2.4519
56	66	201135068	1	2.1765
57	67	201001492	1	3.1176
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

