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
DROP SEQUENCE public.curricula_curriculumid_seq;
DROP TABLE public.curricula;
DROP SEQUENCE public.courses_courseid_seq;
DROP TABLE public.courses;
DROP SEQUENCE public.classes_classid_seq;
DROP TABLE public.classes;
DROP FUNCTION public.xovercs197_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xovercs197_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public."xoverMSEE_dcorrection"(p_studentid integer, p_termid integer);
DROP FUNCTION public."xoverMSEE_correction"(p_studentid integer, p_termid integer);
DROP FUNCTION public."xoverFE_dcorrection"(p_studentid integer, p_termid integer);
DROP FUNCTION public."xoverFE_correction"(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns2_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns2_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns1_dcorrection(p_studentid integer, p_termid integer);
DROP FUNCTION public.xns1_correction(p_studentid integer, p_termid integer);
DROP FUNCTION public.xcwa69(p_studentid integer, p_termid integer);
DROP FUNCTION public.mathgwa(p_studentid integer);
DROP FUNCTION public.gwa(p_studentid integer, p_termid integer);
DROP FUNCTION public.f_elig_twicefailsubjects(p_termid integer);
DROP FUNCTION public.f_elig_passhalfpersem(p_termid integer);
DROP FUNCTION public.f_elig_passhalf_mathcs_persem(p_termid integer);
DROP FUNCTION public.f_elig_24unitspassed_singleyear(p_year integer);
DROP FUNCTION public.f_elig_24unitspassed(p_year integer);
DROP FUNCTION public.cwaproto4(p_studentid integer);
DROP FUNCTION public.csgwa(p_studentid integer);
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

INSERT INTO classes VALUES (2326, 19991, 98, 'TFQ1', '418');
INSERT INTO classes VALUES (2327, 19991, 116, 'WBC', '919');
INSERT INTO classes VALUES (2328, 19991, 117, '11', '3557');
INSERT INTO classes VALUES (2329, 19991, 94, 'MHQ3', '3983');
INSERT INTO classes VALUES (2330, 19991, 81, 'MHW', '6800');
INSERT INTO classes VALUES (2331, 19991, 55, 'TFR2', '9661');
INSERT INTO classes VALUES (2332, 19991, 106, 'MTHFX6', '9764');
INSERT INTO classes VALUES (2333, 20001, 33, 'TFR3', '12225');
INSERT INTO classes VALUES (2334, 20001, 108, 'MTHFW3', '35242');
INSERT INTO classes VALUES (2335, 20001, 110, 'MTHFI', '37302');
INSERT INTO classes VALUES (2336, 20001, 102, 'MHR-S', '41562');
INSERT INTO classes VALUES (2337, 20001, 2, 'HMXY', '44901');
INSERT INTO classes VALUES (2338, 20002, 109, 'MHW2', '35238');
INSERT INTO classes VALUES (2339, 20002, 118, 'TFQ', '35271');
INSERT INTO classes VALUES (2340, 20002, 111, 'MTHFD', '37331');
INSERT INTO classes VALUES (2341, 20002, 3, 'TFXY', '44911');
INSERT INTO classes VALUES (2342, 20002, 5, 'MHX1', '44913');
INSERT INTO classes VALUES (2343, 20003, 118, 'X3-2', '35181');
INSERT INTO classes VALUES (2344, 20003, 95, 'X1-1', '38511');
INSERT INTO classes VALUES (2345, 20011, 34, 'TFW-3', '11676');
INSERT INTO classes VALUES (2346, 20011, 119, 'MHX', '35252');
INSERT INTO classes VALUES (2347, 20011, 103, 'TFY2', '40385');
INSERT INTO classes VALUES (2348, 20011, 6, 'TFR', '44922');
INSERT INTO classes VALUES (2349, 20011, 5, 'W1', '44944');
INSERT INTO classes VALUES (2350, 20012, 113, 'MHX3', '13972');
INSERT INTO classes VALUES (2351, 20012, 103, 'MHU1', '40344');
INSERT INTO classes VALUES (2352, 20012, 11, 'MHY', '44919');
INSERT INTO classes VALUES (2353, 20012, 19, 'TFR', '44921');
INSERT INTO classes VALUES (2354, 20012, 24, 'TFY', '44939');
INSERT INTO classes VALUES (2355, 20012, 114, 'TFZ', '45440');
INSERT INTO classes VALUES (2356, 20013, 39, 'X6-D', '14922');
INSERT INTO classes VALUES (2357, 20013, 11, 'X3', '44906');
INSERT INTO classes VALUES (2358, 20021, 8, 'TFY', '44920');
INSERT INTO classes VALUES (2359, 20021, 6, 'TFW', '44922');
INSERT INTO classes VALUES (2360, 20021, 7, 'MHXY', '44925');
INSERT INTO classes VALUES (2361, 20021, 120, 'TFV', '44931');
INSERT INTO classes VALUES (2362, 20021, 114, 'MHW', '45405');
INSERT INTO classes VALUES (2363, 20021, 41, 'TFX2', '12350');
INSERT INTO classes VALUES (2364, 20021, 106, 'MTHFU1', '35138');
INSERT INTO classes VALUES (2365, 20021, 98, 'TFY1', '39648');
INSERT INTO classes VALUES (2366, 20021, 81, 'MHY', '41805');
INSERT INTO classes VALUES (2367, 20021, 1, 'MHVW', '44901');
INSERT INTO classes VALUES (2368, 20021, 41, 'TFV6', '12389');
INSERT INTO classes VALUES (2369, 20021, 106, 'MTHFW4', '35161');
INSERT INTO classes VALUES (2370, 20021, 94, 'MHV1', '38510');
INSERT INTO classes VALUES (2371, 20021, 81, 'TFR', '41807');
INSERT INTO classes VALUES (2372, 20021, 1, 'MHXY', '44902');
INSERT INTO classes VALUES (2373, 20022, 19, 'TFX', '44918');
INSERT INTO classes VALUES (2374, 20022, 9, 'TFV', '44925');
INSERT INTO classes VALUES (2375, 20022, 27, 'TFW', '44927');
INSERT INTO classes VALUES (2376, 20022, 70, 'TFR2', '33729');
INSERT INTO classes VALUES (2377, 20022, 107, 'MTHFV1', '35165');
INSERT INTO classes VALUES (2378, 20022, 95, 'MHX', '38533');
INSERT INTO classes VALUES (2379, 20022, 100, 'MHW2', '39648');
INSERT INTO classes VALUES (2380, 20022, 2, 'MHRU', '44900');
INSERT INTO classes VALUES (2381, 20022, 71, 'MHR', '34200');
INSERT INTO classes VALUES (2382, 20022, 107, 'MTHFW3', '35173');
INSERT INTO classes VALUES (2383, 20022, 100, 'MHV', '39646');
INSERT INTO classes VALUES (2384, 20022, 82, 'TFU', '41814');
INSERT INTO classes VALUES (2385, 20022, 2, 'MHXY', '44901');
INSERT INTO classes VALUES (2386, 20031, 121, 'MHW2', '16602');
INSERT INTO classes VALUES (2387, 20031, 17, 'MHX', '54566');
INSERT INTO classes VALUES (2388, 20031, 20, 'WSVX2', '54582');
INSERT INTO classes VALUES (2389, 20031, 14, 'TFVW', '54603');
INSERT INTO classes VALUES (2390, 20031, 122, 'MHY', '54604');
INSERT INTO classes VALUES (2391, 20031, 123, 'MHW', '14482');
INSERT INTO classes VALUES (2392, 20031, 63, 'MHV', '15620');
INSERT INTO classes VALUES (2393, 20031, 109, 'TFU2', '39320');
INSERT INTO classes VALUES (2394, 20031, 110, 'MTHFX', '41352');
INSERT INTO classes VALUES (2395, 20031, 93, 'MHU1', '46314');
INSERT INTO classes VALUES (2396, 20031, 2, 'TFVW', '54555');
INSERT INTO classes VALUES (2397, 20031, 34, 'TFV-2', '13921');
INSERT INTO classes VALUES (2398, 20031, 108, 'MTHFW1', '39247');
INSERT INTO classes VALUES (2399, 20031, 110, 'MTHFD', '41419');
INSERT INTO classes VALUES (2400, 20031, 93, 'TFY2', '46310');
INSERT INTO classes VALUES (2401, 20031, 3, 'MHXY', '54560');
INSERT INTO classes VALUES (2402, 20031, 43, 'MHW2', '14467');
INSERT INTO classes VALUES (2403, 20031, 106, 'MTHFX8', '39221');
INSERT INTO classes VALUES (2404, 20031, 82, 'TFR', '41908');
INSERT INTO classes VALUES (2405, 20031, 1, 'MHRU', '54550');
INSERT INTO classes VALUES (2406, 20031, 88, '(1)', '62806');
INSERT INTO classes VALUES (2407, 20031, 41, 'TFQ2', '14425');
INSERT INTO classes VALUES (2408, 20031, 106, 'MTHFW6', '39211');
INSERT INTO classes VALUES (2409, 20031, 82, 'MHQ', '41905');
INSERT INTO classes VALUES (2410, 20031, 103, 'MHX2', '44662');
INSERT INTO classes VALUES (2411, 20031, 1, 'TFRU', '54553');
INSERT INTO classes VALUES (2412, 20032, 20, 'WSVX2', '54595');
INSERT INTO classes VALUES (2413, 20032, 42, 'TFW1', '14435');
INSERT INTO classes VALUES (2414, 20032, 73, 'MTHW', '38073');
INSERT INTO classes VALUES (2415, 20032, 119, 'MHX', '39321');
INSERT INTO classes VALUES (2416, 20032, 94, 'TFX2', '45813');
INSERT INTO classes VALUES (2417, 20032, 3, 'FTRU', '54560');
INSERT INTO classes VALUES (2418, 20032, 5, 'MHU', '54561');
INSERT INTO classes VALUES (2419, 20032, 109, 'TFV1', '39278');
INSERT INTO classes VALUES (2420, 20032, 119, 'MHW', '39320');
INSERT INTO classes VALUES (2421, 20032, 111, 'MTHFV', '41488');
INSERT INTO classes VALUES (2422, 20032, 95, 'TFX1', '45839');
INSERT INTO classes VALUES (2423, 20032, 5, 'MHX', '54562');
INSERT INTO classes VALUES (2424, 20032, 42, 'TFU2', '14432');
INSERT INTO classes VALUES (2425, 20032, 107, 'MTHFR3', '39215');
INSERT INTO classes VALUES (2426, 20032, 81, 'MHW', '41902');
INSERT INTO classes VALUES (2427, 20032, 102, 'MHU', '45213');
INSERT INTO classes VALUES (2428, 20032, 2, 'TFVW', '54558');
INSERT INTO classes VALUES (2429, 20032, 107, 'MTHFW2', '39236');
INSERT INTO classes VALUES (2430, 20032, 98, 'WSR2', '42601');
INSERT INTO classes VALUES (2431, 20032, 102, 'TFQ', '45220');
INSERT INTO classes VALUES (2432, 20032, 94, 'TFR3', '45801');
INSERT INTO classes VALUES (2433, 20032, 1, 'MHRU', '54552');
INSERT INTO classes VALUES (2434, 20033, 110, 'Y3', '41355');
INSERT INTO classes VALUES (2435, 20033, 111, 'Y3', '41362');
INSERT INTO classes VALUES (2436, 20033, 43, 'X3A', '14411');
INSERT INTO classes VALUES (2437, 20033, 98, 'X1-1', '42451');
INSERT INTO classes VALUES (2438, 20033, 108, 'Z1-2', '39183');
INSERT INTO classes VALUES (2439, 20041, 62, 'MHX1', '15613');
INSERT INTO classes VALUES (2440, 20041, 119, 'TFW', '39305');
INSERT INTO classes VALUES (2441, 20041, 7, 'HMRU', '54555');
INSERT INTO classes VALUES (2442, 20041, 8, 'TFR', '54569');
INSERT INTO classes VALUES (2443, 20041, 6, 'TFU', '54572');
INSERT INTO classes VALUES (2444, 20041, 112, 'MHV', '70025');
INSERT INTO classes VALUES (2445, 20041, 36, 'TFR-1', '13856');
INSERT INTO classes VALUES (2446, 20041, 35, 'WIJK', '15505');
INSERT INTO classes VALUES (2447, 20041, 109, 'MHW2', '39395');
INSERT INTO classes VALUES (2448, 20041, 114, 'TFW', '52451');
INSERT INTO classes VALUES (2449, 20041, 5, 'MHU', '54563');
INSERT INTO classes VALUES (2450, 20041, 31, 'MHR1', '15507');
INSERT INTO classes VALUES (2451, 20041, 108, 'MTHFW2', '39255');
INSERT INTO classes VALUES (2452, 20041, 110, 'MTHFX', '41354');
INSERT INTO classes VALUES (2453, 20041, 94, 'MHU5', '45761');
INSERT INTO classes VALUES (2454, 20041, 3, 'TFRU', '54561');
INSERT INTO classes VALUES (2455, 20041, 41, 'MHX3', '14423');
INSERT INTO classes VALUES (2456, 20041, 108, 'MTHFQ2', '39369');
INSERT INTO classes VALUES (2457, 20041, 110, 'MTHFD', '41350');
INSERT INTO classes VALUES (2458, 20041, 81, 'MHW', '41902');
INSERT INTO classes VALUES (2459, 20041, 2, 'TFVW', '54557');
INSERT INTO classes VALUES (2460, 20041, 41, 'TFQ1', '14428');
INSERT INTO classes VALUES (2461, 20041, 106, 'MTHFW2', '39208');
INSERT INTO classes VALUES (2462, 20041, 76, 'MHX', '40826');
INSERT INTO classes VALUES (2463, 20041, 98, 'TFX2', '42471');
INSERT INTO classes VALUES (2464, 20041, 1, 'MHRU', '54550');
INSERT INTO classes VALUES (2465, 20042, 113, 'MHX1', '15672');
INSERT INTO classes VALUES (2466, 20042, 124, 'TFY', '47972');
INSERT INTO classes VALUES (2467, 20042, 19, 'MHR', '54564');
INSERT INTO classes VALUES (2468, 20042, 12, 'TFRU', '54573');
INSERT INTO classes VALUES (2469, 20042, 24, 'MHU', '54597');
INSERT INTO classes VALUES (2470, 20042, 11, 'TFV', '54598');
INSERT INTO classes VALUES (2471, 20042, 42, 'MHW1', '14429');
INSERT INTO classes VALUES (2472, 20042, 55, 'TFU1', '15568');
INSERT INTO classes VALUES (2473, 20042, 113, 'MHV3', '15668');
INSERT INTO classes VALUES (2474, 20042, 41, 'MHR', '14401');
INSERT INTO classes VALUES (2475, 20042, 73, 'MTHU-2', '38052');
INSERT INTO classes VALUES (2476, 20042, 109, 'TFU2', '39271');
INSERT INTO classes VALUES (2477, 20042, 119, 'TFR', '39311');
INSERT INTO classes VALUES (2478, 20042, 110, 'MTHFI', '41352');
INSERT INTO classes VALUES (2479, 20042, 5, 'MHX', '54561');
INSERT INTO classes VALUES (2480, 20042, 43, 'MHV2', '14460');
INSERT INTO classes VALUES (2481, 20042, 119, 'TFQ', '39178');
INSERT INTO classes VALUES (2482, 20042, 109, 'TFR', '39268');
INSERT INTO classes VALUES (2483, 20042, 111, 'MTHFD', '41379');
INSERT INTO classes VALUES (2484, 20042, 42, 'MHU1', '14421');
INSERT INTO classes VALUES (2485, 20042, 107, 'MTHFQ2', '39209');
INSERT INTO classes VALUES (2486, 20042, 95, 'MHR1', '45780');
INSERT INTO classes VALUES (2487, 20042, 93, 'TFR3', '46324');
INSERT INTO classes VALUES (2488, 20042, 2, 'MHXY', '54557');
INSERT INTO classes VALUES (2489, 20043, 39, 'X3-A', '16057');
INSERT INTO classes VALUES (2490, 20043, 111, 'Y4', '41354');
INSERT INTO classes VALUES (2491, 20043, 84, 'X4', '41905');
INSERT INTO classes VALUES (2492, 20043, 103, 'X-5-2', '44660');
INSERT INTO classes VALUES (2493, 20043, 111, 'Y1', '41353');
INSERT INTO classes VALUES (2494, 20043, 109, 'X1-1', '39196');
INSERT INTO classes VALUES (2495, 20043, 108, 'Z1-4', '39187');
INSERT INTO classes VALUES (2496, 20051, 114, 'MHR', '52454');
INSERT INTO classes VALUES (2497, 20051, 17, 'MHX', '54567');
INSERT INTO classes VALUES (2498, 20051, 8, 'TFY', '54570');
INSERT INTO classes VALUES (2499, 20051, 122, 'MHU', '54577');
INSERT INTO classes VALUES (2500, 20051, 20, 'WSVX2', '54581');
INSERT INTO classes VALUES (2501, 20051, 27, 'WRU', '54588');
INSERT INTO classes VALUES (2502, 20051, 21, 'FR', '54592');
INSERT INTO classes VALUES (2503, 20051, 114, 'TFU', '52455');
INSERT INTO classes VALUES (2504, 20051, 17, 'MHU', '54566');
INSERT INTO classes VALUES (2505, 20051, 6, 'TFW', '54573');
INSERT INTO classes VALUES (2506, 20051, 7, 'HMXY', '54575');
INSERT INTO classes VALUES (2507, 20051, 112, 'MHR', '69953');
INSERT INTO classes VALUES (2508, 20051, 113, 'TFU2', '15702');
INSERT INTO classes VALUES (2509, 20051, 48, 'MTU', '19924');
INSERT INTO classes VALUES (2510, 20051, 119, 'TFR', '39309');
INSERT INTO classes VALUES (2511, 20051, 111, 'MTHFI', '41439');
INSERT INTO classes VALUES (2512, 20051, 94, 'MHX3', '45771');
INSERT INTO classes VALUES (2513, 20051, 5, 'TFX', '54562');
INSERT INTO classes VALUES (2514, 20051, 62, 'TFR1', '15564');
INSERT INTO classes VALUES (2515, 20051, 119, 'TFQ', '39308');
INSERT INTO classes VALUES (2516, 20051, 93, 'TFV1', '46329');
INSERT INTO classes VALUES (2517, 20051, 3, 'MHXY', '54559');
INSERT INTO classes VALUES (2518, 20051, 71, 'TFX', '38890');
INSERT INTO classes VALUES (2519, 20051, 108, 'MTHFU1', '39242');
INSERT INTO classes VALUES (2520, 20051, 110, 'MTHFI', '41412');
INSERT INTO classes VALUES (2521, 20051, 29, 'WSR', '54589');
INSERT INTO classes VALUES (2522, 20051, 41, 'TFV2', '14437');
INSERT INTO classes VALUES (2523, 20051, 70, 'MHV', '37502');
INSERT INTO classes VALUES (2524, 20051, 106, 'MTHFW4', '39212');
INSERT INTO classes VALUES (2525, 20051, 94, 'TFQ2', '45773');
INSERT INTO classes VALUES (2526, 20051, 1, 'MHXY', '54551');
INSERT INTO classes VALUES (2527, 20051, 41, 'MHU3', '14410');
INSERT INTO classes VALUES (2528, 20051, 71, 'MHQ', '38678');
INSERT INTO classes VALUES (2529, 20051, 107, 'MTHFR', '39228');
INSERT INTO classes VALUES (2530, 20051, 98, 'TFQ3', '42463');
INSERT INTO classes VALUES (2531, 20051, 1, 'TFVW', '54553');
INSERT INTO classes VALUES (2532, 20052, 76, 'MHX', '40806');
INSERT INTO classes VALUES (2533, 20052, 115, 'MHL', '52457');
INSERT INTO classes VALUES (2534, 20052, 115, 'MHLM', '52459');
INSERT INTO classes VALUES (2535, 20052, 14, 'TFRU', '54570');
INSERT INTO classes VALUES (2536, 20052, 9, 'TFW', '54573');
INSERT INTO classes VALUES (2537, 20052, 27, 'WRU', '54575');
INSERT INTO classes VALUES (2538, 20052, 22, 'WSVX2', '54584');
INSERT INTO classes VALUES (2539, 20052, 42, 'MHY', '14425');
INSERT INTO classes VALUES (2540, 20052, 14, 'HMVW', '54568');
INSERT INTO classes VALUES (2541, 20052, 122, 'MHU', '54571');
INSERT INTO classes VALUES (2542, 20052, 28, 'TFV', '54576');
INSERT INTO classes VALUES (2543, 20052, 12, 'TFXY', '54579');
INSERT INTO classes VALUES (2544, 20052, 21, 'TR', '54580');
INSERT INTO classes VALUES (2545, 20052, 125, 'MHTFX', '15078');
INSERT INTO classes VALUES (2546, 20052, 126, 'MHTFX', '15079');
INSERT INTO classes VALUES (2547, 20052, 60, 'BMR1', '33107');
INSERT INTO classes VALUES (2548, 20052, 111, 'MTHFD', '41375');
INSERT INTO classes VALUES (2549, 20052, 103, 'MHV2', '44695');
INSERT INTO classes VALUES (2550, 20052, 91, 'MI1', '67273');
INSERT INTO classes VALUES (2551, 20052, 61, 'MHX1', '15613');
INSERT INTO classes VALUES (2552, 20052, 109, 'MHV', '39215');
INSERT INTO classes VALUES (2553, 20052, 119, 'TFV', '39279');
INSERT INTO classes VALUES (2554, 20052, 111, 'MTHFR', '41467');
INSERT INTO classes VALUES (2555, 20052, 94, 'MHU2', '45759');
INSERT INTO classes VALUES (2556, 20052, 5, 'TFU', '54561');
INSERT INTO classes VALUES (2557, 20052, 39, 'MHR-1', '16052');
INSERT INTO classes VALUES (2558, 20052, 107, 'MTHFV4', '39184');
INSERT INTO classes VALUES (2559, 20052, 81, 'TFR', '41903');
INSERT INTO classes VALUES (2560, 20052, 95, 'TFU1', '45811');
INSERT INTO classes VALUES (2561, 20052, 2, 'MHXY', '54554');
INSERT INTO classes VALUES (2562, 20052, 108, 'MTHFX3', '39209');
INSERT INTO classes VALUES (2563, 20052, 110, 'MTHFV', '41353');
INSERT INTO classes VALUES (2564, 20052, 102, 'MHQ', '44152');
INSERT INTO classes VALUES (2565, 20052, 2, 'TFRU', '54555');
INSERT INTO classes VALUES (2566, 20053, 87, 'MTWHFAB', '47950');
INSERT INTO classes VALUES (2567, 20053, 18, 'X2', '54550');
INSERT INTO classes VALUES (2568, 20053, 109, 'X3-2', '39181');
INSERT INTO classes VALUES (2569, 20053, 107, 'Z3-2', '39170');
INSERT INTO classes VALUES (2570, 20053, 70, 'X3', '37501');
INSERT INTO classes VALUES (2571, 20053, 109, 'X2', '39179');
INSERT INTO classes VALUES (2572, 20061, 114, 'WIJF', '52455');
INSERT INTO classes VALUES (2573, 20061, 114, 'WIJT1', '52456');
INSERT INTO classes VALUES (2574, 20061, 19, 'TFX', '54565');
INSERT INTO classes VALUES (2575, 20061, 20, 'MHXYM2', '54582');
INSERT INTO classes VALUES (2576, 20061, 113, 'TFZ1', '15681');
INSERT INTO classes VALUES (2577, 20061, 109, 'MHV', '39271');
INSERT INTO classes VALUES (2578, 20061, 114, 'WIJT2', '52457');
INSERT INTO classes VALUES (2579, 20061, 6, 'HMRU', '54569');
INSERT INTO classes VALUES (2580, 20061, 7, 'TFRU', '54574');
INSERT INTO classes VALUES (2581, 20061, 8, 'GS2', '54603');
INSERT INTO classes VALUES (2582, 20061, 37, 'TFX-2', '13886');
INSERT INTO classes VALUES (2583, 20061, 108, 'MTHFW1', '39186');
INSERT INTO classes VALUES (2584, 20061, 110, 'MTHFV', '41356');
INSERT INTO classes VALUES (2585, 20061, 93, 'TFR2', '46327');
INSERT INTO classes VALUES (2586, 20061, 3, 'MHRU', '54557');
INSERT INTO classes VALUES (2587, 20061, 39, 'MHX2', '16069');
INSERT INTO classes VALUES (2588, 20061, 111, 'MTHFV', '41382');
INSERT INTO classes VALUES (2589, 20061, 3, 'TFXY', '54560');
INSERT INTO classes VALUES (2590, 20061, 5, 'TFU', '54561');
INSERT INTO classes VALUES (2591, 20061, 29, 'WSR', '54597');
INSERT INTO classes VALUES (2592, 20061, 41, 'TFV2', '14520');
INSERT INTO classes VALUES (2593, 20061, 70, 'MHU', '37501');
INSERT INTO classes VALUES (2594, 20061, 106, 'MTHFW1', '39189');
INSERT INTO classes VALUES (2595, 20061, 99, 'TFR', '42466');
INSERT INTO classes VALUES (2596, 20061, 1, 'MHXY', '54551');
INSERT INTO classes VALUES (2597, 20061, 39, 'MHR3', '16054');
INSERT INTO classes VALUES (2598, 20061, 106, 'MTHFQ1', '39150');
INSERT INTO classes VALUES (2599, 20061, 83, 'MHW', '41434');
INSERT INTO classes VALUES (2600, 20061, 104, 'TFU', '47970');
INSERT INTO classes VALUES (2601, 20061, 1, 'TFVW', '54553');
INSERT INTO classes VALUES (2602, 20061, 43, 'MHV2', '14551');
INSERT INTO classes VALUES (2603, 20061, 106, 'MTHFX1', '39197');
INSERT INTO classes VALUES (2604, 20061, 76, 'TFU', '40807');
INSERT INTO classes VALUES (2605, 20061, 105, 'MHQ', '43553');
INSERT INTO classes VALUES (2606, 20061, 80, 'TFW', '40252');
INSERT INTO classes VALUES (2607, 20061, 100, 'MHY2', '42478');
INSERT INTO classes VALUES (2608, 20061, 1, 'WSRU', '54599');
INSERT INTO classes VALUES (2609, 20061, 41, 'MHR2', '14493');
INSERT INTO classes VALUES (2610, 20061, 106, 'MTHFY5', '39299');
INSERT INTO classes VALUES (2611, 20061, 94, 'TFW2', '45853');
INSERT INTO classes VALUES (2612, 20061, 93, 'MHV6', '46380');
INSERT INTO classes VALUES (2613, 20061, 41, 'TFU3', '14518');
INSERT INTO classes VALUES (2614, 20061, 106, 'MTHFX4', '39200');
INSERT INTO classes VALUES (2615, 20061, 82, 'MHY', '41911');
INSERT INTO classes VALUES (2616, 20061, 94, 'TFR3', '45763');
INSERT INTO classes VALUES (2617, 20061, 1, 'SWRU', '54600');
INSERT INTO classes VALUES (2618, 20062, 115, 'MHK', '52449');
INSERT INTO classes VALUES (2619, 20062, 115, 'MHKH', '52450');
INSERT INTO classes VALUES (2620, 20062, 22, 'W1', '54595');
INSERT INTO classes VALUES (2621, 20062, 36, 'MHQ-2', '13851');
INSERT INTO classes VALUES (2622, 20062, 42, 'TFU1', '14589');
INSERT INTO classes VALUES (2623, 20062, 119, 'TFQ', '39314');
INSERT INTO classes VALUES (2624, 20062, 3, 'MHXY', '54559');
INSERT INTO classes VALUES (2625, 20062, 24, 'MHW', '54571');
INSERT INTO classes VALUES (2626, 20062, 100, 'TFU1', '42493');
INSERT INTO classes VALUES (2627, 20062, 115, 'MHKM', '52451');
INSERT INTO classes VALUES (2628, 20062, 11, 'MHY', '54565');
INSERT INTO classes VALUES (2629, 20062, 14, 'TFVW', '54567');
INSERT INTO classes VALUES (2630, 20062, 9, 'FTXY', '54570');
INSERT INTO classes VALUES (2631, 20062, 12, 'MHVW', '54573');
INSERT INTO classes VALUES (2632, 20062, 63, 'TFX1', '15613');
INSERT INTO classes VALUES (2633, 20062, 108, 'MTHFR3', '39259');
INSERT INTO classes VALUES (2634, 20062, 111, 'MTHFY', '41440');
INSERT INTO classes VALUES (2635, 20062, 98, 'MHV2', '42456');
INSERT INTO classes VALUES (2636, 20062, 5, 'TFU', '54562');
INSERT INTO classes VALUES (2637, 20062, 119, 'TFR', '39315');
INSERT INTO classes VALUES (2638, 20062, 81, 'MHR', '41900');
INSERT INTO classes VALUES (2639, 20062, 100, 'MHW1', '42487');
INSERT INTO classes VALUES (2640, 20062, 93, 'TFX2', '46335');
INSERT INTO classes VALUES (2641, 20062, 7, 'WRUVX', '54602');
INSERT INTO classes VALUES (2642, 20062, 39, 'MHR1', '16054');
INSERT INTO classes VALUES (2643, 20062, 107, 'MTHFU5', '39212');
INSERT INTO classes VALUES (2644, 20062, 94, 'TFV2', '45786');
INSERT INTO classes VALUES (2645, 20062, 93, 'MHV5', '46316');
INSERT INTO classes VALUES (2646, 20062, 2, 'TFXY', '54558');
INSERT INTO classes VALUES (2647, 20062, 40, 'TFX1', '14591');
INSERT INTO classes VALUES (2648, 20062, 62, 'MHU2', '15598');
INSERT INTO classes VALUES (2649, 20062, 106, 'MTHFW-1', '39184');
INSERT INTO classes VALUES (2650, 20062, 100, 'MHX', '42489');
INSERT INTO classes VALUES (2651, 20062, 2, 'TFRU', '54557');
INSERT INTO classes VALUES (2652, 20062, 36, 'MHV-2', '13859');
INSERT INTO classes VALUES (2653, 20062, 40, 'TFV1', '14476');
INSERT INTO classes VALUES (2654, 20062, 47, 'Z', '19918');
INSERT INTO classes VALUES (2655, 20062, 107, 'MTHFW1', '39201');
INSERT INTO classes VALUES (2656, 20062, 2, 'MHRU', '54552');
INSERT INTO classes VALUES (2657, 20062, 41, 'TFX', '14415');
INSERT INTO classes VALUES (2658, 20062, 107, 'MTHFV6', '39225');
INSERT INTO classes VALUES (2659, 20062, 98, 'TFQ1', '42460');
INSERT INTO classes VALUES (2660, 20062, 93, 'TFR', '46328');
INSERT INTO classes VALUES (2661, 20062, 42, 'MHR', '14417');
INSERT INTO classes VALUES (2662, 20062, 106, 'MTHFQ-1', '39197');
INSERT INTO classes VALUES (2663, 20062, 100, 'MHW2', '42488');
INSERT INTO classes VALUES (2664, 20062, 95, 'TFV2', '45812');
INSERT INTO classes VALUES (2665, 20062, 107, 'MTHFQ6', '39395');
INSERT INTO classes VALUES (2666, 20062, 98, 'TFX1', '42466');
INSERT INTO classes VALUES (2667, 20062, 105, 'TFW', '43616');
INSERT INTO classes VALUES (2668, 20063, 18, 'X2', '54550');
INSERT INTO classes VALUES (2669, 20063, 111, 'Y3', '41353');
INSERT INTO classes VALUES (2670, 20063, 113, 'X1B', '15527');
INSERT INTO classes VALUES (2671, 20063, 107, 'Z1-A', '39176');
INSERT INTO classes VALUES (2672, 20063, 110, 'Y2', '41350');
INSERT INTO classes VALUES (2673, 20063, 110, 'Y3', '41351');
INSERT INTO classes VALUES (2674, 20063, 107, 'Z2-C', '39175');
INSERT INTO classes VALUES (2675, 20063, 36, 'X2-A', '13855');
INSERT INTO classes VALUES (2676, 20063, 127, 'X1A', '15540');
INSERT INTO classes VALUES (2677, 20071, 114, 'TFL', '52463');
INSERT INTO classes VALUES (2678, 20071, 114, 'TFLH', '52464');
INSERT INTO classes VALUES (2679, 20071, 8, 'TFX3', '54561');
INSERT INTO classes VALUES (2680, 20071, 6, 'TFRU', '54562');
INSERT INTO classes VALUES (2681, 20071, 19, 'TFV1', '54567');
INSERT INTO classes VALUES (2682, 20071, 7, 'MWVWXY', '54583');
INSERT INTO classes VALUES (2683, 20071, 27, 'WRU2', '54585');
INSERT INTO classes VALUES (2684, 20071, 21, 'MH', '54594');
INSERT INTO classes VALUES (2685, 20071, 55, 'MHU1', '15574');
INSERT INTO classes VALUES (2686, 20071, 17, 'TFU', '54566');
INSERT INTO classes VALUES (2687, 20071, 16, 'MHV1', '54569');
INSERT INTO classes VALUES (2688, 20071, 20, 'W2', '54571');
INSERT INTO classes VALUES (2689, 20071, 27, 'WRU1', '54579');
INSERT INTO classes VALUES (2690, 20071, 21, 'MQ', '54593');
INSERT INTO classes VALUES (2691, 20071, 112, 'TFW', '70005');
INSERT INTO classes VALUES (2692, 20071, 119, 'TFW', '39298');
INSERT INTO classes VALUES (2693, 20071, 109, 'MHQ', '39388');
INSERT INTO classes VALUES (2694, 20071, 6, 'TMRU', '54563');
INSERT INTO classes VALUES (2695, 20071, 8, 'TFX2', '54560');
INSERT INTO classes VALUES (2696, 20071, 17, 'MHU', '54565');
INSERT INTO classes VALUES (2697, 20071, 19, 'TFV2', '54568');
INSERT INTO classes VALUES (2698, 20071, 50, 'MHV1', '15526');
INSERT INTO classes VALUES (2699, 20071, 107, 'MTHFW2', '39228');
INSERT INTO classes VALUES (2700, 20071, 110, 'MTHFX', '41361');
INSERT INTO classes VALUES (2701, 20071, 3, 'TFRU', '54576');
INSERT INTO classes VALUES (2702, 20071, 108, 'MTHFU2', '39237');
INSERT INTO classes VALUES (2703, 20071, 110, 'MTHFQ1', '41359');
INSERT INTO classes VALUES (2704, 20071, 93, 'MHY2', '46327');
INSERT INTO classes VALUES (2705, 20071, 102, 'TFY', '47991');
INSERT INTO classes VALUES (2706, 20071, 3, 'MHVW', '54574');
INSERT INTO classes VALUES (2707, 20071, 71, 'TFU', '38606');
INSERT INTO classes VALUES (2708, 20071, 108, 'MTHFX', '39248');
INSERT INTO classes VALUES (2709, 20071, 93, 'TFV1', '46370');
INSERT INTO classes VALUES (2710, 20071, 104, 'MHV', '47978');
INSERT INTO classes VALUES (2711, 20071, 3, 'MHRU', '54573');
INSERT INTO classes VALUES (2712, 20071, 128, 'TFW', '15019');
INSERT INTO classes VALUES (2713, 20071, 108, 'MTHFU3', '39243');
INSERT INTO classes VALUES (2714, 20071, 104, 'TFR-1', '44162');
INSERT INTO classes VALUES (2715, 20071, 107, 'MTHFR2', '39410');
INSERT INTO classes VALUES (2716, 20071, 110, 'MTHFV', '41360');
INSERT INTO classes VALUES (2717, 20071, 93, 'TFU2', '46331');
INSERT INTO classes VALUES (2718, 20071, 1, 'HMXY', '54552');
INSERT INTO classes VALUES (2719, 20071, 73, 'MHR', '38055');
INSERT INTO classes VALUES (2720, 20071, 108, 'MTHFU7', '39239');
INSERT INTO classes VALUES (2721, 20071, 110, 'MTHFI', '41357');
INSERT INTO classes VALUES (2722, 20071, 1, 'FTXY', '54555');
INSERT INTO classes VALUES (2723, 20071, 63, 'TFR1', '15635');
INSERT INTO classes VALUES (2724, 20071, 71, 'TFW', '38833');
INSERT INTO classes VALUES (2725, 20071, 108, 'MTHFX3', '39396');
INSERT INTO classes VALUES (2726, 20071, 110, 'MTHFD', '41356');
INSERT INTO classes VALUES (2727, 20071, 71, 'TFR', '38605');
INSERT INTO classes VALUES (2728, 20071, 108, 'MTHFW1', '39235');
INSERT INTO classes VALUES (2729, 20071, 74, 'TFU', '52910');
INSERT INTO classes VALUES (2730, 20071, 43, 'TFU1', '14447');
INSERT INTO classes VALUES (2731, 20071, 106, 'MTHFX2', '39212');
INSERT INTO classes VALUES (2732, 20071, 76, 'TFY', '40809');
INSERT INTO classes VALUES (2733, 20071, 1, 'HMRU1', '54550');
INSERT INTO classes VALUES (2734, 20071, 43, 'TFX', '14453');
INSERT INTO classes VALUES (2735, 20071, 70, 'MHR', '37500');
INSERT INTO classes VALUES (2736, 20071, 106, 'MTHFW11', '39187');
INSERT INTO classes VALUES (2737, 20071, 100, 'MHU', '42540');
INSERT INTO classes VALUES (2738, 20071, 1, 'FTRU', '54553');
INSERT INTO classes VALUES (2739, 20071, 43, 'TFV', '14449');
INSERT INTO classes VALUES (2740, 20071, 106, 'MTHFX-6', '39342');
INSERT INTO classes VALUES (2741, 20071, 94, 'TFR4', '45781');
INSERT INTO classes VALUES (2742, 20071, 1, 'HMVW', '54551');
INSERT INTO classes VALUES (2743, 20071, 43, 'TFU2', '14448');
INSERT INTO classes VALUES (2744, 20071, 70, 'TFV', '37508');
INSERT INTO classes VALUES (2745, 20071, 100, 'MHR', '42539');
INSERT INTO classes VALUES (2746, 20071, 42, 'MHW', '14433');
INSERT INTO classes VALUES (2747, 20071, 106, 'MTHFR3', '39218');
INSERT INTO classes VALUES (2748, 20071, 94, 'MHU3', '45758');
INSERT INTO classes VALUES (2749, 20071, 74, 'TFV', '52911');
INSERT INTO classes VALUES (2750, 20071, 82, 'MHU', '41900');
INSERT INTO classes VALUES (2751, 20071, 93, 'TFW1', '46332');
INSERT INTO classes VALUES (2752, 20072, 115, 'MHLW2', '52451');
INSERT INTO classes VALUES (2753, 20072, 129, 'MHR', '40251');
INSERT INTO classes VALUES (2754, 20072, 115, 'MHLF', '52452');
INSERT INTO classes VALUES (2755, 20072, 11, 'MHZ', '54570');
INSERT INTO classes VALUES (2756, 20072, 12, 'HMVW', '54577');
INSERT INTO classes VALUES (2757, 20072, 28, 'MHU', '54585');
INSERT INTO classes VALUES (2758, 20072, 23, 'SRU', '54606');
INSERT INTO classes VALUES (2759, 20072, 36, 'TFY-1', '13875');
INSERT INTO classes VALUES (2760, 20072, 123, 'TFW', '14462');
INSERT INTO classes VALUES (2761, 20072, 70, 'MHW', '37503');
INSERT INTO classes VALUES (2762, 20072, 130, 'TFV', '43031');
INSERT INTO classes VALUES (2763, 20072, 102, 'TFX', '47972');
INSERT INTO classes VALUES (2764, 20072, 131, 'GTH', '52932');
INSERT INTO classes VALUES (2765, 20072, 22, 'W2', '54581');
INSERT INTO classes VALUES (2766, 20072, 82, 'TFU', '42004');
INSERT INTO classes VALUES (2767, 20072, 93, 'TFV5', '46332');
INSERT INTO classes VALUES (2768, 20072, 115, 'MHLW1', '52450');
INSERT INTO classes VALUES (2769, 20072, 11, 'MHX2', '54569');
INSERT INTO classes VALUES (2770, 20072, 12, 'MHVW', '54578');
INSERT INTO classes VALUES (2771, 20072, 23, 'TFW', '54584');
INSERT INTO classes VALUES (2772, 20072, 14, 'MHQR2', '54609');
INSERT INTO classes VALUES (2773, 20072, 66, 'MHX1', '26506');
INSERT INTO classes VALUES (2774, 20072, 130, 'TFW', '43032');
INSERT INTO classes VALUES (2775, 20072, 115, 'MHLT', '52449');
INSERT INTO classes VALUES (2776, 20072, 9, 'MHSUWX', '54602');
INSERT INTO classes VALUES (2777, 20072, 43, 'MHV3', '14437');
INSERT INTO classes VALUES (2778, 20072, 108, 'MTHFX', '39197');
INSERT INTO classes VALUES (2779, 20072, 110, 'MTHFW', '41355');
INSERT INTO classes VALUES (2780, 20072, 5, 'TFU2', '54566');
INSERT INTO classes VALUES (2781, 20072, 75, 'MHR', '55102');
INSERT INTO classes VALUES (2782, 20072, 109, 'TFW1', '39211');
INSERT INTO classes VALUES (2783, 20072, 119, 'TFY', '39260');
INSERT INTO classes VALUES (2784, 20072, 111, 'MTHFQ', '41357');
INSERT INTO classes VALUES (2785, 20072, 81, 'MHR', '42009');
INSERT INTO classes VALUES (2786, 20072, 98, 'MHX2', '42460');
INSERT INTO classes VALUES (2787, 20072, 70, 'MHX', '37504');
INSERT INTO classes VALUES (2788, 20072, 109, 'TFW2', '39233');
INSERT INTO classes VALUES (2789, 20072, 111, 'MTHFCR', '41358');
INSERT INTO classes VALUES (2790, 20072, 5, 'TFU', '54564');
INSERT INTO classes VALUES (2791, 20072, 89, 'MHW', '62802');
INSERT INTO classes VALUES (2792, 20072, 36, 'TFX-2', '13872');
INSERT INTO classes VALUES (2793, 20072, 109, 'MHW1', '39294');
INSERT INTO classes VALUES (2794, 20072, 111, 'MTHFGV', '41360');
INSERT INTO classes VALUES (2795, 20072, 95, 'MHX1', '45814');
INSERT INTO classes VALUES (2796, 20072, 5, 'MHU', '54563');
INSERT INTO classes VALUES (2797, 20072, 36, 'TFR-1', '13864');
INSERT INTO classes VALUES (2798, 20072, 70, 'TFU', '37507');
INSERT INTO classes VALUES (2799, 20072, 108, 'MTHFQ', '39207');
INSERT INTO classes VALUES (2800, 20072, 2, 'MHRU', '54556');
INSERT INTO classes VALUES (2801, 20072, 39, 'MHU4', '16065');
INSERT INTO classes VALUES (2802, 20072, 109, 'MHV', '39206');
INSERT INTO classes VALUES (2803, 20072, 119, 'TFX', '39259');
INSERT INTO classes VALUES (2804, 20072, 111, 'MTHFW', '41361');
INSERT INTO classes VALUES (2805, 20072, 74, 'MHX', '52911');
INSERT INTO classes VALUES (2806, 20072, 1, 'FTRU', '54550');
INSERT INTO classes VALUES (2807, 20072, 45, 'TFU', '14470');
INSERT INTO classes VALUES (2808, 20072, 109, 'MHR', '39202');
INSERT INTO classes VALUES (2809, 20072, 123, 'TFV', '14459');
INSERT INTO classes VALUES (2810, 20072, 119, 'TFX1', '39383');
INSERT INTO classes VALUES (2811, 20072, 63, 'MHR', '15608');
INSERT INTO classes VALUES (2812, 20072, 107, 'MTHFW4', '39183');
INSERT INTO classes VALUES (2813, 20072, 81, 'TFX', '42012');
INSERT INTO classes VALUES (2814, 20072, 105, 'MHV', '43552');
INSERT INTO classes VALUES (2815, 20072, 2, 'TFRU', '54559');
INSERT INTO classes VALUES (2816, 20072, 123, 'MHU2', '14453');
INSERT INTO classes VALUES (2817, 20072, 107, 'MTHFW6', '39189');
INSERT INTO classes VALUES (2818, 20072, 93, 'MHR4', '46307');
INSERT INTO classes VALUES (2819, 20072, 123, 'MHU', '14451');
INSERT INTO classes VALUES (2820, 20072, 37, 'TFQ-2', '13887');
INSERT INTO classes VALUES (2821, 20072, 106, 'MTHFX', '39200');
INSERT INTO classes VALUES (2822, 20072, 98, 'MHW2', '42458');
INSERT INTO classes VALUES (2823, 20072, 2, 'TFVW', '54560');
INSERT INTO classes VALUES (2824, 20072, 123, 'MHR', '14450');
INSERT INTO classes VALUES (2825, 20072, 107, 'MTHFW2', '39171');
INSERT INTO classes VALUES (2826, 20072, 98, 'MHU2', '42452');
INSERT INTO classes VALUES (2827, 20072, 40, 'MHR', '14471');
INSERT INTO classes VALUES (2828, 20072, 107, 'MTHFW3', '39177');
INSERT INTO classes VALUES (2829, 20072, 83, 'MHX', '41425');
INSERT INTO classes VALUES (2830, 20072, 103, 'MHU1', '44677');
INSERT INTO classes VALUES (2831, 20072, 2, 'TFXY', '54561');
INSERT INTO classes VALUES (2832, 20072, 39, 'TFX2', '16133');
INSERT INTO classes VALUES (2833, 20072, 107, 'MTHFV4', '39182');
INSERT INTO classes VALUES (2834, 20072, 98, 'MHX1', '42459');
INSERT INTO classes VALUES (2835, 20072, 40, 'TFW', '14481');
INSERT INTO classes VALUES (2836, 20072, 55, 'MHU', '15575');
INSERT INTO classes VALUES (2837, 20072, 107, 'MTHFR', '39155');
INSERT INTO classes VALUES (2838, 20072, 95, 'TFX1', '45831');
INSERT INTO classes VALUES (2839, 20072, 2, 'MHVW', '54557');
INSERT INTO classes VALUES (2840, 20072, 50, 'TFR1', '15529');
INSERT INTO classes VALUES (2841, 20072, 55, 'MHQ', '15573');
INSERT INTO classes VALUES (2842, 20072, 94, 'TFX1', '45796');
INSERT INTO classes VALUES (2843, 20072, 55, 'MHV1', '15577');
INSERT INTO classes VALUES (2844, 20072, 107, 'MTHFR4', '39180');
INSERT INTO classes VALUES (2845, 20072, 81, 'TFW', '42011');
INSERT INTO classes VALUES (2846, 20072, 100, 'MHW', '42481');
INSERT INTO classes VALUES (2847, 20073, 44, 'MTWHFBC', '11651');
INSERT INTO classes VALUES (2848, 20073, 18, 'X2', '54550');
INSERT INTO classes VALUES (2849, 20073, 127, 'X2-A', '15518');
INSERT INTO classes VALUES (2850, 20073, 111, 'MTWHFJ', '41354');
INSERT INTO classes VALUES (2851, 20073, 109, 'X1-1', '39164');
INSERT INTO classes VALUES (2852, 20073, 109, 'X3-1', '39167');
INSERT INTO classes VALUES (2853, 20073, 37, 'X3-A', '13862');
INSERT INTO classes VALUES (2854, 20073, 71, 'X5', '38604');
INSERT INTO classes VALUES (2855, 20073, 109, 'X3-2', '39206');
INSERT INTO classes VALUES (2856, 20073, 111, 'MTWHFQ', '41352');
INSERT INTO classes VALUES (2857, 20073, 107, 'Z1-4', '39180');
INSERT INTO classes VALUES (2858, 20073, 98, 'X2-1', '42450');
INSERT INTO classes VALUES (2859, 20073, 107, 'Z3-1', '39186');
INSERT INTO classes VALUES (2860, 20073, 107, 'Z1-6', '39182');
INSERT INTO classes VALUES (2861, 20073, 107, 'Z1-5', '39181');
INSERT INTO classes VALUES (2862, 20081, 132, 'THV-2', '44102');
INSERT INTO classes VALUES (2863, 20081, 17, 'THU', '54562');
INSERT INTO classes VALUES (2864, 20081, 6, 'FWRU', '54571');
INSERT INTO classes VALUES (2865, 20081, 16, 'WFV2', '54578');
INSERT INTO classes VALUES (2866, 20081, 20, 'MS2', '54584');
INSERT INTO classes VALUES (2867, 20081, 75, 'WFW', '55101');
INSERT INTO classes VALUES (2868, 20081, 100, 'THR1', '42483');
INSERT INTO classes VALUES (2869, 20081, 133, 'THW', '52938');
INSERT INTO classes VALUES (2870, 20081, 8, 'WFW', '54568');
INSERT INTO classes VALUES (2871, 20081, 21, 'MU', '54580');
INSERT INTO classes VALUES (2872, 20081, 20, 'MS3', '54585');
INSERT INTO classes VALUES (2873, 20081, 23, 'THV', '54609');
INSERT INTO classes VALUES (2874, 20081, 112, 'WFR', '69950');
INSERT INTO classes VALUES (2875, 20081, 47, 'W', '19916');
INSERT INTO classes VALUES (2876, 20081, 134, 'THX', '43031');
INSERT INTO classes VALUES (2877, 20081, 16, 'WFV', '54577');
INSERT INTO classes VALUES (2878, 20081, 20, 'MS4', '54586');
INSERT INTO classes VALUES (2879, 20081, 29, 'THW3', '54602');
INSERT INTO classes VALUES (2880, 20081, 108, 'TWHFR', '39212');
INSERT INTO classes VALUES (2881, 20081, 97, 'THY', '43057');
INSERT INTO classes VALUES (2882, 20081, 114, 'THQF2', '52451');
INSERT INTO classes VALUES (2883, 20081, 6, 'FWVW', '54572');
INSERT INTO classes VALUES (2884, 20081, 91, 'THD/HJ2', '67252');
INSERT INTO classes VALUES (2885, 20081, 70, 'THY', '37505');
INSERT INTO classes VALUES (2886, 20081, 114, 'THQW2', '52450');
INSERT INTO classes VALUES (2887, 20081, 7, 'THVW', '54574');
INSERT INTO classes VALUES (2888, 20081, 8, 'SUV', '54599');
INSERT INTO classes VALUES (2889, 20081, 62, 'THW3', '15694');
INSERT INTO classes VALUES (2890, 20081, 109, 'THV', '39301');
INSERT INTO classes VALUES (2891, 20081, 114, 'THQF1', '52449');
INSERT INTO classes VALUES (2892, 20081, 6, 'THRU', '54573');
INSERT INTO classes VALUES (2893, 20081, 112, 'WFV', '69957');
INSERT INTO classes VALUES (2894, 20081, 114, 'THQW1', '52448');
INSERT INTO classes VALUES (2895, 20081, 19, 'THW', '54565');
INSERT INTO classes VALUES (2896, 20081, 23, 'WFU', '54610');
INSERT INTO classes VALUES (2897, 20081, 108, 'TWHFU1', '39219');
INSERT INTO classes VALUES (2898, 20081, 111, 'TWHFGV', '41386');
INSERT INTO classes VALUES (2899, 20081, 99, 'THW2', '42474');
INSERT INTO classes VALUES (2900, 20081, 2, 'FWXY', '54556');
INSERT INTO classes VALUES (2901, 20081, 45, 'THR2', '14480');
INSERT INTO classes VALUES (2902, 20081, 135, 'THU', '15105');
INSERT INTO classes VALUES (2903, 20081, 19, 'THW2', '54566');
INSERT INTO classes VALUES (2904, 20081, 111, 'TWHFQ', '41383');
INSERT INTO classes VALUES (2905, 20081, 7, 'THXY2', '54576');
INSERT INTO classes VALUES (2906, 20081, 136, 'THV', '13927');
INSERT INTO classes VALUES (2907, 20081, 66, 'THU2', '26503');
INSERT INTO classes VALUES (2908, 20081, 108, 'TWHFX', '39226');
INSERT INTO classes VALUES (2909, 20081, 119, 'WFV', '39347');
INSERT INTO classes VALUES (2910, 20081, 110, 'TWHFW', '41382');
INSERT INTO classes VALUES (2911, 20081, 3, 'WFRU', '54561');
INSERT INTO classes VALUES (2912, 20081, 48, 'W', '19919');
INSERT INTO classes VALUES (2913, 20081, 71, 'WFX', '38601');
INSERT INTO classes VALUES (2914, 20081, 107, 'TWHFW', '39209');
INSERT INTO classes VALUES (2915, 20081, 1, 'THXY2', '54551');
INSERT INTO classes VALUES (2916, 20081, 89, 'A', '62800');
INSERT INTO classes VALUES (2917, 20081, 108, 'TWHFV1', '39221');
INSERT INTO classes VALUES (2918, 20081, 98, 'WFY2', '42471');
INSERT INTO classes VALUES (2919, 20081, 95, 'THQ2', '45799');
INSERT INTO classes VALUES (2920, 20081, 36, 'WFR-4', '13872');
INSERT INTO classes VALUES (2921, 20081, 103, 'THR-4', '44662');
INSERT INTO classes VALUES (2922, 20081, 3, 'THXY', '54558');
INSERT INTO classes VALUES (2923, 20081, 40, 'THY', '14496');
INSERT INTO classes VALUES (2924, 20081, 62, 'THU2', '15618');
INSERT INTO classes VALUES (2925, 20081, 93, 'THX1', '46320');
INSERT INTO classes VALUES (2926, 20081, 39, 'THX4', '16137');
INSERT INTO classes VALUES (2927, 20081, 108, 'TWHFW2', '39229');
INSERT INTO classes VALUES (2928, 20081, 110, 'TWHFQ', '41378');
INSERT INTO classes VALUES (2929, 20081, 36, 'THR-1', '13851');
INSERT INTO classes VALUES (2930, 20081, 91, 'WFB/WC', '67292');
INSERT INTO classes VALUES (2931, 20081, 49, 'WFX1', '15543');
INSERT INTO classes VALUES (2932, 20081, 127, 'THX2', '15575');
INSERT INTO classes VALUES (2933, 20081, 37, 'THU-1', '13881');
INSERT INTO classes VALUES (2934, 20081, 137, 'THR', '15043');
INSERT INTO classes VALUES (2935, 20081, 108, 'TWHFV', '39217');
INSERT INTO classes VALUES (2936, 20081, 39, 'WFV1', '16136');
INSERT INTO classes VALUES (2937, 20081, 108, 'TWHFW1', '39225');
INSERT INTO classes VALUES (2938, 20081, 100, 'THR2', '42484');
INSERT INTO classes VALUES (2939, 20081, 108, 'TWHFR4', '39216');
INSERT INTO classes VALUES (2940, 20081, 3, 'WFXY', '54559');
INSERT INTO classes VALUES (2941, 20081, 75, 'THW', '55100');
INSERT INTO classes VALUES (2942, 20081, 39, 'WFW2', '16113');
INSERT INTO classes VALUES (2943, 20081, 108, 'TWHFR2', '39214');
INSERT INTO classes VALUES (2944, 20081, 110, 'TWHFU', '41380');
INSERT INTO classes VALUES (2945, 20081, 95, 'THW1', '45808');
INSERT INTO classes VALUES (2946, 20081, 43, 'WFR1', '14463');
INSERT INTO classes VALUES (2947, 20081, 70, 'WFU', '37507');
INSERT INTO classes VALUES (2948, 20081, 106, 'TWHFW2', '39167');
INSERT INTO classes VALUES (2949, 20081, 100, 'WFX1', '42494');
INSERT INTO classes VALUES (2950, 20081, 1, 'HTRU', '54554');
INSERT INTO classes VALUES (2951, 20081, 37, 'THV-1', '13882');
INSERT INTO classes VALUES (2952, 20081, 106, 'TWHFR7', '39277');
INSERT INTO classes VALUES (2953, 20081, 76, 'WFU-1', '40811');
INSERT INTO classes VALUES (2954, 20081, 104, 'THU', '44165');
INSERT INTO classes VALUES (2955, 20081, 40, 'THU', '14489');
INSERT INTO classes VALUES (2956, 20081, 106, 'TWHFQ4', '39174');
INSERT INTO classes VALUES (2957, 20081, 95, 'THR1', '45800');
INSERT INTO classes VALUES (2958, 20081, 1, 'THXY', '54550');
INSERT INTO classes VALUES (2959, 20081, 43, 'THV2', '14459');
INSERT INTO classes VALUES (2960, 20081, 106, 'TWHFU3', '39158');
INSERT INTO classes VALUES (2961, 20081, 82, 'WFR', '42007');
INSERT INTO classes VALUES (2962, 20081, 94, 'THX2', '45768');
INSERT INTO classes VALUES (2963, 20081, 1, 'WFXY2', '54553');
INSERT INTO classes VALUES (2964, 20081, 43, 'WFX', '14467');
INSERT INTO classes VALUES (2965, 20081, 70, 'THU', '37501');
INSERT INTO classes VALUES (2966, 20081, 106, 'TWHFR9', '39279');
INSERT INTO classes VALUES (2967, 20081, 99, 'WFY', '42478');
INSERT INTO classes VALUES (2968, 20081, 40, 'WFX1', '14501');
INSERT INTO classes VALUES (2969, 20081, 106, 'TWHFW3', '39168');
INSERT INTO classes VALUES (2970, 20081, 84, 'THU', '42004');
INSERT INTO classes VALUES (2971, 20081, 93, 'WFU3', '46330');
INSERT INTO classes VALUES (2972, 20081, 45, 'THU', '14481');
INSERT INTO classes VALUES (2973, 20081, 100, 'THW', '42485');
INSERT INTO classes VALUES (2974, 20081, 43, 'WFR2', '14464');
INSERT INTO classes VALUES (2975, 20081, 41, 'WFW2', '14434');
INSERT INTO classes VALUES (2976, 20081, 93, 'THV3', '46313');
INSERT INTO classes VALUES (2977, 20081, 74, 'THX', '52900');
INSERT INTO classes VALUES (2978, 20081, 41, 'THX2', '14418');
INSERT INTO classes VALUES (2979, 20081, 106, 'TWHFV7', '39258');
INSERT INTO classes VALUES (2980, 20081, 76, 'THY', '40808');
INSERT INTO classes VALUES (2981, 20081, 94, 'WFR2', '45776');
INSERT INTO classes VALUES (2982, 20081, 1, 'WFXY', '54552');
INSERT INTO classes VALUES (2983, 20081, 41, 'THW2', '14413');
INSERT INTO classes VALUES (2984, 20081, 82, 'WFW', '42008');
INSERT INTO classes VALUES (2985, 20081, 94, 'THQ1', '45750');
INSERT INTO classes VALUES (2986, 20081, 41, 'WFU2', '14427');
INSERT INTO classes VALUES (2987, 20081, 81, 'WFR', '42001');
INSERT INTO classes VALUES (2988, 20081, 94, 'WFX1', '45791');
INSERT INTO classes VALUES (2989, 20081, 1, 'HTQR', '54555');
INSERT INTO classes VALUES (2990, 20081, 41, 'THR1', '14402');
INSERT INTO classes VALUES (2991, 20081, 106, 'TWHFW8', '39270');
INSERT INTO classes VALUES (2992, 20081, 94, 'THU5', '45761');
INSERT INTO classes VALUES (2993, 20081, 42, 'THW', '14446');
INSERT INTO classes VALUES (2994, 20081, 106, 'TWHFR2', '39152');
INSERT INTO classes VALUES (2995, 20081, 82, 'THU', '42009');
INSERT INTO classes VALUES (2996, 20081, 93, 'WFU1', '46328');
INSERT INTO classes VALUES (2997, 20081, 123, 'WFV', '14477');
INSERT INTO classes VALUES (2998, 20081, 82, 'THW', '42010');
INSERT INTO classes VALUES (2999, 20081, 41, 'WFX2', '14438');
INSERT INTO classes VALUES (3000, 20081, 70, 'THR', '37500');
INSERT INTO classes VALUES (3001, 20081, 106, 'TWHFQ', '39170');
INSERT INTO classes VALUES (3002, 20081, 94, 'THU3', '45759');
INSERT INTO classes VALUES (3003, 20081, 43, 'WFY', '14468');
INSERT INTO classes VALUES (3004, 20081, 106, 'TWHFW7', '39260');
INSERT INTO classes VALUES (3005, 20081, 83, 'WFU', '41375');
INSERT INTO classes VALUES (3006, 20081, 98, 'THR2', '42451');
INSERT INTO classes VALUES (3007, 20081, 39, 'THU3', '16133');
INSERT INTO classes VALUES (3008, 20081, 106, 'TWHFW6', '39259');
INSERT INTO classes VALUES (3009, 20081, 81, 'WFX', '42003');
INSERT INTO classes VALUES (3010, 20081, 93, 'THR3', '46305');
INSERT INTO classes VALUES (3011, 20081, 41, 'WFW4', '14436');
INSERT INTO classes VALUES (3012, 20081, 106, 'TWHFQ5', '39280');
INSERT INTO classes VALUES (3013, 20081, 41, 'THR2', '14403');
INSERT INTO classes VALUES (3014, 20081, 100, 'WFW', '42493');
INSERT INTO classes VALUES (3015, 20081, 42, 'THV1', '14444');
INSERT INTO classes VALUES (3016, 20081, 106, 'TWHFR3', '39153');
INSERT INTO classes VALUES (3017, 20081, 39, 'THY2', '16078');
INSERT INTO classes VALUES (3018, 20081, 43, 'THQ', '14455');
INSERT INTO classes VALUES (3019, 20081, 138, 'WFV', '40824');
INSERT INTO classes VALUES (3020, 20081, 105, 'WFQ1', '43583');
INSERT INTO classes VALUES (3021, 20081, 123, 'THX', '14469');
INSERT INTO classes VALUES (3022, 20081, 79, 'THV1', '39703');
INSERT INTO classes VALUES (3023, 20081, 50, 'WFU3', '15547');
INSERT INTO classes VALUES (3024, 20081, 55, 'THR2', '15664');
INSERT INTO classes VALUES (3025, 20081, 106, 'TWHFX2', '39187');
INSERT INTO classes VALUES (3026, 20081, 93, 'THV6', '46345');
INSERT INTO classes VALUES (3027, 20081, 1, 'MUVWX', '54597');
INSERT INTO classes VALUES (3028, 20081, 43, 'THW3', '14600');
INSERT INTO classes VALUES (3029, 20081, 41, 'WFX5', '14607');
INSERT INTO classes VALUES (3030, 20081, 106, 'TWHFU2', '39157');
INSERT INTO classes VALUES (3031, 20081, 94, 'THX3', '45769');
INSERT INTO classes VALUES (3032, 20081, 37, 'WFY-2', '13931');
INSERT INTO classes VALUES (3033, 20081, 50, 'THV1', '15528');
INSERT INTO classes VALUES (3034, 20081, 93, 'THY4', '46325');
INSERT INTO classes VALUES (3035, 20082, 123, 'THX', '14474');
INSERT INTO classes VALUES (3036, 20082, 40, 'THW1', '14505');
INSERT INTO classes VALUES (3037, 20082, 119, 'THR', '39281');
INSERT INTO classes VALUES (3038, 20082, 111, 'S3L/R4', '41472');
INSERT INTO classes VALUES (3039, 20082, 89, 'WFA', '62804');
INSERT INTO classes VALUES (3040, 20082, 45, 'WFV', '14496');
INSERT INTO classes VALUES (3041, 20082, 138, 'WFW', '40816');
INSERT INTO classes VALUES (3042, 20082, 14, 'THRU', '54566');
INSERT INTO classes VALUES (3043, 20082, 9, 'THVW', '54570');
INSERT INTO classes VALUES (3044, 20082, 22, 'S2', '54581');
INSERT INTO classes VALUES (3045, 20082, 131, 'GM', '56235');
INSERT INTO classes VALUES (3046, 20082, 113, 'WFU2', '15707');
INSERT INTO classes VALUES (3047, 20082, 74, 'THW', '52917');
INSERT INTO classes VALUES (3048, 20082, 11, 'WFV', '54565');
INSERT INTO classes VALUES (3049, 20082, 21, 'HV', '54579');
INSERT INTO classes VALUES (3050, 20082, 22, 'S1', '54580');
INSERT INTO classes VALUES (3051, 20082, 60, 'MR2A', '33109');
INSERT INTO classes VALUES (3052, 20082, 84, 'THW', '42007');
INSERT INTO classes VALUES (3053, 20082, 139, 'THWFY', '43021');
INSERT INTO classes VALUES (3054, 20082, 140, 'THWFY', '43022');
INSERT INTO classes VALUES (3055, 20082, 22, 'S4', '54583');
INSERT INTO classes VALUES (3056, 20082, 89, 'THK', '62800');
INSERT INTO classes VALUES (3057, 20082, 109, 'WFU2', '39310');
INSERT INTO classes VALUES (3058, 20082, 5, 'THU2', '54561');
INSERT INTO classes VALUES (3059, 20082, 14, 'THVW', '54567');
INSERT INTO classes VALUES (3060, 20082, 141, 'WFIJ', '67206');
INSERT INTO classes VALUES (3061, 20082, 123, 'THQ1', '14536');
INSERT INTO classes VALUES (3062, 20082, 115, 'WFLT', '52430');
INSERT INTO classes VALUES (3063, 20082, 11, 'WFW', '54562');
INSERT INTO classes VALUES (3064, 20082, 9, 'THYZ', '54571');
INSERT INTO classes VALUES (3065, 20082, 12, 'WFUV', '54575');
INSERT INTO classes VALUES (3066, 20082, 135, 'WFU2', '15154');
INSERT INTO classes VALUES (3067, 20082, 94, 'THV4', '45765');
INSERT INTO classes VALUES (3068, 20082, 14, 'THXY', '54568');
INSERT INTO classes VALUES (3069, 20082, 40, 'THV1', '14503');
INSERT INTO classes VALUES (3070, 20082, 81, 'THR', '42008');
INSERT INTO classes VALUES (3071, 20082, 115, 'WFLW', '52431');
INSERT INTO classes VALUES (3072, 20082, 5, 'THU', '54559');
INSERT INTO classes VALUES (3073, 20082, 11, 'WFX', '54563');
INSERT INTO classes VALUES (3074, 20082, 14, 'WFVW', '54569');
INSERT INTO classes VALUES (3075, 20082, 41, 'THV2', '14406');
INSERT INTO classes VALUES (3076, 20082, 123, 'WFV1', '14480');
INSERT INTO classes VALUES (3077, 20082, 119, 'THU', '39233');
INSERT INTO classes VALUES (3078, 20082, 109, 'WFU5', '39321');
INSERT INTO classes VALUES (3079, 20082, 81, 'WFW', '42010');
INSERT INTO classes VALUES (3080, 20082, 3, 'HTQR', '54609');
INSERT INTO classes VALUES (3081, 20082, 115, 'WFLF', '52433');
INSERT INTO classes VALUES (3082, 20082, 39, 'WFU4', '16078');
INSERT INTO classes VALUES (3083, 20082, 12, 'WFWX', '54576');
INSERT INTO classes VALUES (3084, 20082, 30, 'SWX', '54588');
INSERT INTO classes VALUES (3085, 20082, 112, 'TBA', '70009');
INSERT INTO classes VALUES (3086, 20082, 5, 'WFU', '54560');
INSERT INTO classes VALUES (3087, 20082, 89, 'WFV', '62829');
INSERT INTO classes VALUES (3088, 20082, 42, 'THU1', '14429');
INSERT INTO classes VALUES (3089, 20082, 109, 'THR1', '39274');
INSERT INTO classes VALUES (3090, 20082, 111, 'S4L/R1', '41386');
INSERT INTO classes VALUES (3091, 20082, 100, 'THW2', '42475');
INSERT INTO classes VALUES (3092, 20082, 75, 'WFW', '55100');
INSERT INTO classes VALUES (3093, 20082, 43, 'THV1', '14450');
INSERT INTO classes VALUES (3094, 20082, 108, 'TWHFU1', '39213');
INSERT INTO classes VALUES (3095, 20082, 110, 'S2L/R4', '41439');
INSERT INTO classes VALUES (3096, 20082, 94, 'THW3', '45768');
INSERT INTO classes VALUES (3097, 20082, 2, 'WFXY', '54555');
INSERT INTO classes VALUES (3098, 20082, 111, 'S5L/R5', '41481');
INSERT INTO classes VALUES (3099, 20082, 82, 'THY', '42003');
INSERT INTO classes VALUES (3100, 20082, 94, 'THV2', '45763');
INSERT INTO classes VALUES (3101, 20082, 119, 'THV', '39271');
INSERT INTO classes VALUES (3102, 20082, 95, 'THX3', '45817');
INSERT INTO classes VALUES (3103, 20082, 48, 'X', '19904');
INSERT INTO classes VALUES (3104, 20082, 108, 'TWHFW', '39211');
INSERT INTO classes VALUES (3105, 20082, 111, 'S2L/R4', '41468');
INSERT INTO classes VALUES (3106, 20082, 87, 'THY', '47957');
INSERT INTO classes VALUES (3107, 20082, 35, 'THX1', '15506');
INSERT INTO classes VALUES (3108, 20082, 109, 'THW1', '39221');
INSERT INTO classes VALUES (3109, 20082, 111, 'S1L/R5', '41465');
INSERT INTO classes VALUES (3110, 20082, 103, 'WFR-2', '44731');
INSERT INTO classes VALUES (3111, 20082, 5, 'WFU2', '54618');
INSERT INTO classes VALUES (3112, 20082, 37, 'THR-3', '13884');
INSERT INTO classes VALUES (3113, 20082, 119, 'THQ', '39280');
INSERT INTO classes VALUES (3114, 20082, 110, 'S5L/R1', '41392');
INSERT INTO classes VALUES (3115, 20082, 94, 'THX3', '45771');
INSERT INTO classes VALUES (3116, 20082, 123, 'WFX', '14484');
INSERT INTO classes VALUES (3117, 20082, 111, 'S1L/R1', '41383');
INSERT INTO classes VALUES (3118, 20082, 24, 'THR', '54585');
INSERT INTO classes VALUES (3119, 20082, 109, 'WFR2', '39309');
INSERT INTO classes VALUES (3120, 20082, 111, 'S5L/R1', '41387');
INSERT INTO classes VALUES (3121, 20082, 95, 'WFV2', '45826');
INSERT INTO classes VALUES (3122, 20082, 123, 'WFV3', '14482');
INSERT INTO classes VALUES (3123, 20082, 108, 'TWHFR', '39212');
INSERT INTO classes VALUES (3124, 20082, 45, 'WFQ', '14491');
INSERT INTO classes VALUES (3125, 20082, 109, 'THQ1', '39378');
INSERT INTO classes VALUES (3126, 20082, 111, 'S5L/R3', '41479');
INSERT INTO classes VALUES (3127, 20082, 93, 'WFU2', '46319');
INSERT INTO classes VALUES (3128, 20082, 36, 'THV-2', '13859');
INSERT INTO classes VALUES (3129, 20082, 107, 'TWHFU7', '39326');
INSERT INTO classes VALUES (3130, 20082, 98, 'THR3', '42452');
INSERT INTO classes VALUES (3131, 20082, 103, 'WFR-4', '44733');
INSERT INTO classes VALUES (3132, 20082, 1, 'FWVW', '54614');
INSERT INTO classes VALUES (3133, 20082, 73, 'WFW-1', '38078');
INSERT INTO classes VALUES (3134, 20082, 111, 'S4L/R3', '41475');
INSERT INTO classes VALUES (3135, 20082, 89, 'TNQ', '62803');
INSERT INTO classes VALUES (3136, 20082, 41, 'WFR', '14415');
INSERT INTO classes VALUES (3137, 20082, 49, 'THR1', '15522');
INSERT INTO classes VALUES (3138, 20082, 107, 'TWHFW2', '39169');
INSERT INTO classes VALUES (3139, 20082, 94, 'WFU1', '45782');
INSERT INTO classes VALUES (3140, 20082, 1, 'HTXY', '54550');
INSERT INTO classes VALUES (3141, 20082, 39, 'WFV3', '16081');
INSERT INTO classes VALUES (3142, 20082, 107, 'TWHFQ4', '39268');
INSERT INTO classes VALUES (3143, 20082, 81, 'WFX', '42011');
INSERT INTO classes VALUES (3144, 20082, 98, 'WFU2', '42464');
INSERT INTO classes VALUES (3145, 20082, 2, 'HTVW', '54552');
INSERT INTO classes VALUES (3146, 20082, 142, 'WFV', '14556');
INSERT INTO classes VALUES (3147, 20082, 107, 'TWHFQ1', '39158');
INSERT INTO classes VALUES (3148, 20082, 82, 'THU', '42000');
INSERT INTO classes VALUES (3149, 20082, 100, 'THR2', '42472');
INSERT INTO classes VALUES (3150, 20082, 2, 'WFRU', '54554');
INSERT INTO classes VALUES (3151, 20082, 39, 'THQ1', '16050');
INSERT INTO classes VALUES (3152, 20082, 107, 'TWHFU3', '39173');
INSERT INTO classes VALUES (3153, 20082, 100, 'WFQ2', '42477');
INSERT INTO classes VALUES (3154, 20082, 42, 'THY', '14435');
INSERT INTO classes VALUES (3155, 20082, 73, 'WFV', '38059');
INSERT INTO classes VALUES (3156, 20082, 107, 'TWHFQ5', '39345');
INSERT INTO classes VALUES (3157, 20082, 94, 'WFX1', '45795');
INSERT INTO classes VALUES (3158, 20082, 41, 'THX2', '14411');
INSERT INTO classes VALUES (3159, 20082, 123, 'WFR', '14477');
INSERT INTO classes VALUES (3160, 20082, 98, 'WFU1', '42463');
INSERT INTO classes VALUES (3161, 20082, 2, 'THRU', '54556');
INSERT INTO classes VALUES (3162, 20082, 61, 'THW1', '15620');
INSERT INTO classes VALUES (3163, 20082, 107, 'TWHFV3', '39174');
INSERT INTO classes VALUES (3164, 20082, 76, 'WFU', '40850');
INSERT INTO classes VALUES (3165, 20082, 2, 'HTXY', '54557');
INSERT INTO classes VALUES (3166, 20082, 41, 'WFU', '14416');
INSERT INTO classes VALUES (3167, 20082, 107, 'TWHFW', '39155');
INSERT INTO classes VALUES (3168, 20082, 81, 'WFR', '42009');
INSERT INTO classes VALUES (3169, 20082, 93, 'WFX', '46327');
INSERT INTO classes VALUES (3170, 20082, 36, 'WFU-1', '13867');
INSERT INTO classes VALUES (3171, 20082, 93, 'WFV2', '46321');
INSERT INTO classes VALUES (3172, 20082, 143, 'WFR/WFRUV2', '38632');
INSERT INTO classes VALUES (3173, 20082, 104, 'MUV', '44132');
INSERT INTO classes VALUES (3174, 20082, 94, 'THU2', '45758');
INSERT INTO classes VALUES (3175, 20082, 75, 'WFX', '55101');
INSERT INTO classes VALUES (3176, 20082, 42, 'THW2', '14433');
INSERT INTO classes VALUES (3177, 20082, 100, 'WFR2', '42479');
INSERT INTO classes VALUES (3178, 20082, 123, 'THR', '14537');
INSERT INTO classes VALUES (3179, 20082, 106, 'TWHFQ1', '39232');
INSERT INTO classes VALUES (3180, 20082, 70, 'THU', '37501');
INSERT INTO classes VALUES (3181, 20082, 107, 'TWHFR4', '39177');
INSERT INTO classes VALUES (3182, 20082, 100, 'WFW', '42481');
INSERT INTO classes VALUES (3183, 20082, 40, 'WFX1', '14513');
INSERT INTO classes VALUES (3184, 20082, 76, 'THX', '40804');
INSERT INTO classes VALUES (3185, 20082, 55, 'WFR1', '15580');
INSERT INTO classes VALUES (3186, 20082, 71, 'THX', '38600');
INSERT INTO classes VALUES (3187, 20082, 107, 'TWHFU6', '39325');
INSERT INTO classes VALUES (3188, 20082, 103, 'WFV-2', '44736');
INSERT INTO classes VALUES (3189, 20082, 39, 'WFU2', '16076');
INSERT INTO classes VALUES (3190, 20082, 107, 'TWHFW4', '39179');
INSERT INTO classes VALUES (3191, 20082, 2, 'THXY', '54553');
INSERT INTO classes VALUES (3192, 20082, 123, 'WFW', '14483');
INSERT INTO classes VALUES (3193, 20082, 107, 'TWHFQ3', '39171');
INSERT INTO classes VALUES (3194, 20082, 80, 'THU', '40251');
INSERT INTO classes VALUES (3195, 20082, 41, 'THV3', '14407');
INSERT INTO classes VALUES (3196, 20082, 98, 'WFV2', '42466');
INSERT INTO classes VALUES (3197, 20082, 93, 'THU1', '46303');
INSERT INTO classes VALUES (3198, 20082, 43, 'WFR', '14457');
INSERT INTO classes VALUES (3199, 20082, 107, 'TWHFU5', '39181');
INSERT INTO classes VALUES (3200, 20082, 93, 'THQ1', '46322');
INSERT INTO classes VALUES (3201, 20082, 123, 'THR1', '14465');
INSERT INTO classes VALUES (3202, 20082, 70, 'WFU', '37507');
INSERT INTO classes VALUES (3203, 20082, 100, 'WFX', '42482');
INSERT INTO classes VALUES (3204, 20082, 105, 'THV', '43563');
INSERT INTO classes VALUES (3205, 20082, 40, 'THU2', '14515');
INSERT INTO classes VALUES (3206, 20082, 106, 'TWHFX', '39186');
INSERT INTO classes VALUES (3207, 20082, 82, 'WFV', '42004');
INSERT INTO classes VALUES (3208, 20082, 37, 'WFR-2', '13894');
INSERT INTO classes VALUES (3209, 20082, 100, 'WFU', '42480');
INSERT INTO classes VALUES (3210, 20082, 42, 'WFX1', '14443');
INSERT INTO classes VALUES (3211, 20082, 107, 'TWHFU2', '39167');
INSERT INTO classes VALUES (3212, 20082, 98, 'WFR1', '42461');
INSERT INTO classes VALUES (3213, 20082, 107, 'TWHFR3', '39172');
INSERT INTO classes VALUES (3214, 20082, 42, 'THR1', '14427');
INSERT INTO classes VALUES (3215, 20082, 100, 'WFR1', '42478');
INSERT INTO classes VALUES (3216, 20082, 39, 'WFU3', '16077');
INSERT INTO classes VALUES (3217, 20082, 107, 'TWHFR2', '39166');
INSERT INTO classes VALUES (3218, 20082, 94, 'WFW1', '45791');
INSERT INTO classes VALUES (3219, 20082, 123, 'THU', '14466');
INSERT INTO classes VALUES (3220, 20082, 107, 'TWHFR', '39152');
INSERT INTO classes VALUES (3221, 20082, 76, 'WFW', '40808');
INSERT INTO classes VALUES (3222, 20082, 41, 'THW', '14408');
INSERT INTO classes VALUES (3223, 20082, 104, 'THX', '44130');
INSERT INTO classes VALUES (3224, 20082, 41, 'WFV', '14417');
INSERT INTO classes VALUES (3225, 20082, 43, 'WFU', '14459');
INSERT INTO classes VALUES (3226, 20082, 105, 'THY', '43554');
INSERT INTO classes VALUES (3227, 20082, 62, 'THX1', '15624');
INSERT INTO classes VALUES (3228, 20082, 71, 'WFX', '38601');
INSERT INTO classes VALUES (3229, 20082, 107, 'TWHFW3', '39175');
INSERT INTO classes VALUES (3230, 20082, 105, 'WFR', '43552');
INSERT INTO classes VALUES (3231, 20082, 94, 'THR4', '45755');
INSERT INTO classes VALUES (3232, 20082, 100, 'WFQ1', '42476');
INSERT INTO classes VALUES (3233, 20082, 93, 'WFV1', '46320');
INSERT INTO classes VALUES (3234, 20082, 36, 'WFX-2', '13879');
INSERT INTO classes VALUES (3235, 20082, 106, 'TWHFU', '39372');
INSERT INTO classes VALUES (3236, 20082, 94, 'THX1', '45769');
INSERT INTO classes VALUES (3237, 20082, 95, 'THW2', '45813');
INSERT INTO classes VALUES (3238, 20083, 70, 'X2', '37500');
INSERT INTO classes VALUES (3239, 20083, 113, 'X4-A', '15534');
INSERT INTO classes VALUES (3240, 20083, 70, 'X5', '37503');
INSERT INTO classes VALUES (3241, 20083, 71, 'X2', '38601');
INSERT INTO classes VALUES (3242, 20083, 43, 'X5', '14420');
INSERT INTO classes VALUES (3243, 20083, 105, 'X-3C', '43554');
INSERT INTO classes VALUES (3244, 20083, 98, 'X5-1', '42456');
INSERT INTO classes VALUES (3245, 20083, 130, 'X2-1', '43011');
INSERT INTO classes VALUES (3246, 20083, 133, 'X4', '52901');
INSERT INTO classes VALUES (3247, 20083, 70, 'X4', '37502');
INSERT INTO classes VALUES (3248, 20083, 109, 'X3', '39181');
INSERT INTO classes VALUES (3249, 20083, 111, 'MTWHFJ', '41366');
INSERT INTO classes VALUES (3250, 20083, 109, 'X2', '39180');
INSERT INTO classes VALUES (3251, 20083, 108, 'Z2-6', '39201');
INSERT INTO classes VALUES (3252, 20083, 108, 'Z1-6', '39197');
INSERT INTO classes VALUES (3253, 20083, 109, 'X4', '39206');
INSERT INTO classes VALUES (3254, 20083, 40, 'X2', '14432');
INSERT INTO classes VALUES (3255, 20083, 109, 'X4-1', '39210');
INSERT INTO classes VALUES (3256, 20083, 111, 'MTWHFQ', '41364');
INSERT INTO classes VALUES (3257, 20083, 108, 'Z2-2', '39175');
INSERT INTO classes VALUES (3258, 20083, 107, 'Z1-3', '39164');
INSERT INTO classes VALUES (3259, 20083, 37, 'X4', '13861');
INSERT INTO classes VALUES (3260, 20083, 93, 'X3-2', '46302');
INSERT INTO classes VALUES (3261, 20083, 110, 'MTWHFE', '41362');
INSERT INTO classes VALUES (3262, 20083, 108, 'Z3-5', '39204');
INSERT INTO classes VALUES (3263, 20083, 107, 'Z2', '39165');
INSERT INTO classes VALUES (3264, 20083, 71, 'X3', '38602');
INSERT INTO classes VALUES (3265, 20083, 93, 'X5-1', '46305');
INSERT INTO classes VALUES (3266, 20083, 108, 'Z3-2', '39178');
INSERT INTO classes VALUES (3267, 20083, 110, 'MTWHFJ', '41363');
INSERT INTO classes VALUES (3268, 20083, 108, 'Z1-1', '39170');
INSERT INTO classes VALUES (3269, 20083, 36, 'X5', '13859');
INSERT INTO classes VALUES (3270, 20083, 130, 'X1', '43000');
INSERT INTO classes VALUES (3271, 20083, 107, 'Z1', '39161');
INSERT INTO classes VALUES (3272, 20083, 95, 'X2', '45753');
INSERT INTO classes VALUES (3273, 20083, 43, 'X3-B', '14419');
INSERT INTO classes VALUES (3274, 20083, 107, 'Z3', '39168');
INSERT INTO classes VALUES (3275, 20083, 108, 'Z3', '39176');
INSERT INTO classes VALUES (3276, 20083, 108, 'Z3-1', '39177');
INSERT INTO classes VALUES (3277, 20083, 107, 'Z2-1', '39166');
INSERT INTO classes VALUES (3278, 20083, 108, 'Z2-4', '39199');
INSERT INTO classes VALUES (3279, 20091, 24, 'THX', '54565');
INSERT INTO classes VALUES (3280, 20091, 8, 'WFV', '54575');
INSERT INTO classes VALUES (3281, 20091, 6, 'THVW', '54580');
INSERT INTO classes VALUES (3282, 20091, 7, 'FWXY', '54583');
INSERT INTO classes VALUES (3283, 20091, 112, 'WFW', '69988');
INSERT INTO classes VALUES (3284, 20091, 143, 'WFQ/WFUV1', '38617');
INSERT INTO classes VALUES (3285, 20091, 63, 'WFW1', '15604');
INSERT INTO classes VALUES (3286, 20091, 132, 'THU1', '44103');
INSERT INTO classes VALUES (3287, 20091, 17, 'THV', '54567');
INSERT INTO classes VALUES (3288, 20091, 19, 'THW', '54571');
INSERT INTO classes VALUES (3289, 20091, 16, 'WFX', '54587');
INSERT INTO classes VALUES (3290, 20091, 20, 'S6', '54625');
INSERT INTO classes VALUES (3291, 20091, 144, 'TWHFX', '43036');
INSERT INTO classes VALUES (3292, 20091, 145, 'TWHFX', '43037');
INSERT INTO classes VALUES (3293, 20091, 71, 'THW', '38717');
INSERT INTO classes VALUES (3294, 20091, 114, 'THQ', '52479');
INSERT INTO classes VALUES (3295, 20091, 114, 'THQS2', '52483');
INSERT INTO classes VALUES (3296, 20091, 7, 'THXY', '54585');
INSERT INTO classes VALUES (3297, 20091, 21, 'MR', '54589');
INSERT INTO classes VALUES (3298, 20091, 112, 'WFY', '69990');
INSERT INTO classes VALUES (3299, 20091, 17, 'THU', '54568');
INSERT INTO classes VALUES (3300, 20091, 19, 'THX', '54572');
INSERT INTO classes VALUES (3301, 20091, 23, 'MXY', '54592');
INSERT INTO classes VALUES (3302, 20091, 20, 'S7', '54629');
INSERT INTO classes VALUES (3303, 20091, 146, 'THX', '53508');
INSERT INTO classes VALUES (3304, 20091, 17, 'WFU', '54569');
INSERT INTO classes VALUES (3305, 20091, 19, 'THR', '54570');
INSERT INTO classes VALUES (3306, 20091, 7, 'HTVW', '54582');
INSERT INTO classes VALUES (3307, 20091, 16, 'WFV', '54586');
INSERT INTO classes VALUES (3308, 20091, 37, 'WFU-1', '13892');
INSERT INTO classes VALUES (3309, 20091, 133, 'THU', '52904');
INSERT INTO classes VALUES (3310, 20091, 23, 'WFX', '54591');
INSERT INTO classes VALUES (3311, 20091, 45, 'WFV1', '14606');
INSERT INTO classes VALUES (3312, 20091, 147, 'TWHFR', '43056');
INSERT INTO classes VALUES (3313, 20091, 148, 'TWHFR', '43057');
INSERT INTO classes VALUES (3314, 20091, 2, 'THVW', '54559');
INSERT INTO classes VALUES (3315, 20091, 19, 'WFU', '54573');
INSERT INTO classes VALUES (3316, 20091, 43, 'THW1', '14544');
INSERT INTO classes VALUES (3317, 20091, 40, 'WFX3', '14637');
INSERT INTO classes VALUES (3318, 20091, 114, 'THQT', '52480');
INSERT INTO classes VALUES (3319, 20091, 5, 'WFR', '54564');
INSERT INTO classes VALUES (3320, 20091, 6, 'FWVW', '54579');
INSERT INTO classes VALUES (3321, 20091, 149, 'THR', '14968');
INSERT INTO classes VALUES (3322, 20091, 111, 'S3L/R3', '41398');
INSERT INTO classes VALUES (3323, 20091, 150, 'WFV', '43061');
INSERT INTO classes VALUES (3324, 20091, 114, 'THQS1', '52482');
INSERT INTO classes VALUES (3325, 20091, 17, 'THW', '54566');
INSERT INTO classes VALUES (3326, 20091, 8, 'THV', '54574');
INSERT INTO classes VALUES (3327, 20091, 98, 'WFR2', '42458');
INSERT INTO classes VALUES (3328, 20091, 6, 'THXY', '54581');
INSERT INTO classes VALUES (3329, 20091, 112, 'WFX', '69989');
INSERT INTO classes VALUES (3330, 20091, 73, 'THW', '38071');
INSERT INTO classes VALUES (3331, 20091, 109, 'WFR', '39303');
INSERT INTO classes VALUES (3332, 20091, 119, 'WFY', '39310');
INSERT INTO classes VALUES (3333, 20091, 3, 'WFVW', '54562');
INSERT INTO classes VALUES (3334, 20091, 73, 'WFU', '38063');
INSERT INTO classes VALUES (3335, 20091, 114, 'THQH', '52481');
INSERT INTO classes VALUES (3336, 20091, 1, 'HTXY', '54552');
INSERT INTO classes VALUES (3337, 20091, 75, 'WFV', '55104');
INSERT INTO classes VALUES (3338, 20091, 87, 'THU', '47951');
INSERT INTO classes VALUES (3339, 20091, 8, 'SWX', '54577');
INSERT INTO classes VALUES (3340, 20091, 88, 'WFX', '62814');
INSERT INTO classes VALUES (3341, 20091, 57, 'WFU1', '15575');
INSERT INTO classes VALUES (3342, 20091, 111, 'S4L/R2', '41402');
INSERT INTO classes VALUES (3343, 20091, 6, 'HTXY', '54578');
INSERT INTO classes VALUES (3344, 20091, 7, 'WFWX', '54584');
INSERT INTO classes VALUES (3345, 20091, 93, 'THW2', '46362');
INSERT INTO classes VALUES (3346, 20091, 75, 'WFW', '55100');
INSERT INTO classes VALUES (3347, 20091, 109, 'WFQ', '39302');
INSERT INTO classes VALUES (3348, 20091, 111, 'S5L/R3', '41408');
INSERT INTO classes VALUES (3349, 20091, 3, 'THRU', '54560');
INSERT INTO classes VALUES (3350, 20091, 8, 'THY', '54576');
INSERT INTO classes VALUES (3351, 20091, 111, 'S1L/R5', '41390');
INSERT INTO classes VALUES (3352, 20091, 88, 'THV', '62807');
INSERT INTO classes VALUES (3353, 20091, 50, 'WFU1', '15533');
INSERT INTO classes VALUES (3354, 20091, 39, 'THU1', '16075');
INSERT INTO classes VALUES (3355, 20091, 151, 'WFX', '39266');
INSERT INTO classes VALUES (3356, 20091, 123, 'THQ', '14562');
INSERT INTO classes VALUES (3357, 20091, 50, 'THU3', '15523');
INSERT INTO classes VALUES (3358, 20091, 109, 'WFV', '39297');
INSERT INTO classes VALUES (3359, 20091, 110, 'S2L/R3', '41358');
INSERT INTO classes VALUES (3360, 20091, 43, 'WFW2', '14556');
INSERT INTO classes VALUES (3361, 20091, 35, 'THQ1', '15500');
INSERT INTO classes VALUES (3362, 20091, 57, 'THR1', '15574');
INSERT INTO classes VALUES (3363, 20091, 107, 'TWHFV', '39388');
INSERT INTO classes VALUES (3364, 20091, 110, 'S6L/R2', '41381');
INSERT INTO classes VALUES (3365, 20091, 1, 'WFRU2', '54616');
INSERT INTO classes VALUES (3366, 20091, 123, 'THU2', '14565');
INSERT INTO classes VALUES (3367, 20091, 39, 'THV3', '16119');
INSERT INTO classes VALUES (3368, 20091, 107, 'TWHFY', '39272');
INSERT INTO classes VALUES (3369, 20091, 110, 'S5L/R1', '41374');
INSERT INTO classes VALUES (3370, 20091, 63, 'WFR1', '15601');
INSERT INTO classes VALUES (3371, 20091, 108, 'TWHFU3', '39278');
INSERT INTO classes VALUES (3372, 20091, 110, 'S1L/R4', '41353');
INSERT INTO classes VALUES (3373, 20091, 123, 'THV3', '14568');
INSERT INTO classes VALUES (3374, 20091, 108, 'TWHFR4', '39339');
INSERT INTO classes VALUES (3375, 20091, 110, 'S3L/R1', '41362');
INSERT INTO classes VALUES (3376, 20091, 100, 'THW', '42471');
INSERT INTO classes VALUES (3377, 20091, 43, 'THW2', '14545');
INSERT INTO classes VALUES (3378, 20091, 108, 'TWHFQ2', '39371');
INSERT INTO classes VALUES (3379, 20091, 110, 'S6L/R6', '41385');
INSERT INTO classes VALUES (3380, 20091, 95, 'THV3', '45805');
INSERT INTO classes VALUES (3381, 20091, 123, 'THV2', '14567');
INSERT INTO classes VALUES (3382, 20091, 108, 'TWHFQ3', '39372');
INSERT INTO classes VALUES (3383, 20091, 81, 'WFR', '42001');
INSERT INTO classes VALUES (3384, 20091, 3, 'WFXY', '54563');
INSERT INTO classes VALUES (3385, 20091, 43, 'THR1', '14635');
INSERT INTO classes VALUES (3386, 20091, 35, 'WFQ1', '15504');
INSERT INTO classes VALUES (3387, 20091, 110, 'S6L/R4', '41383');
INSERT INTO classes VALUES (3388, 20091, 41, 'THX5', '14502');
INSERT INTO classes VALUES (3389, 20091, 108, 'TWHFR1', '39277');
INSERT INTO classes VALUES (3390, 20091, 110, 'S3L/R4', '41365');
INSERT INTO classes VALUES (3391, 20091, 97, 'THV', '43059');
INSERT INTO classes VALUES (3392, 20091, 108, 'TWHFR', '39275');
INSERT INTO classes VALUES (3393, 20091, 110, 'S3L/R3', '41364');
INSERT INTO classes VALUES (3394, 20091, 98, 'WFX', '42525');
INSERT INTO classes VALUES (3395, 20091, 3, 'THXY', '54561');
INSERT INTO classes VALUES (3396, 20091, 63, 'THR1', '15594');
INSERT INTO classes VALUES (3397, 20091, 107, 'TWHFX', '39271');
INSERT INTO classes VALUES (3398, 20091, 111, 'S3L/R2', '41397');
INSERT INTO classes VALUES (3399, 20091, 43, 'THQ', '14539');
INSERT INTO classes VALUES (3400, 20091, 108, 'TWHFU', '39273');
INSERT INTO classes VALUES (3401, 20091, 110, 'S2L/R4', '41359');
INSERT INTO classes VALUES (3402, 20091, 99, 'THV', '42461');
INSERT INTO classes VALUES (3403, 20091, 127, 'THY1', '15552');
INSERT INTO classes VALUES (3404, 20091, 110, 'S6L/R5', '41384');
INSERT INTO classes VALUES (3405, 20091, 2, 'THRU', '54628');
INSERT INTO classes VALUES (3406, 20091, 127, 'WFR1', '15554');
INSERT INTO classes VALUES (3407, 20091, 93, 'THV3', '46307');
INSERT INTO classes VALUES (3408, 20091, 50, 'THV2', '15558');
INSERT INTO classes VALUES (3409, 20091, 110, 'S1L/R5', '41354');
INSERT INTO classes VALUES (3410, 20091, 36, 'WFV-3', '13865');
INSERT INTO classes VALUES (3411, 20091, 108, 'TWHFQ1', '39338');
INSERT INTO classes VALUES (3412, 20091, 110, 'S5L/R6', '41379');
INSERT INTO classes VALUES (3413, 20091, 93, 'WFX2', '46357');
INSERT INTO classes VALUES (3414, 20091, 108, 'TWHFU2', '39276');
INSERT INTO classes VALUES (3415, 20091, 110, 'S4L/R1', '41368');
INSERT INTO classes VALUES (3416, 20091, 81, 'WFX', '42003');
INSERT INTO classes VALUES (3417, 20091, 94, 'WFY3', '45798');
INSERT INTO classes VALUES (3418, 20091, 41, 'THX6', '14638');
INSERT INTO classes VALUES (3419, 20091, 50, 'WFV2', '15536');
INSERT INTO classes VALUES (3420, 20091, 109, 'WFW', '39298');
INSERT INTO classes VALUES (3421, 20091, 93, 'THU4', '46305');
INSERT INTO classes VALUES (3422, 20091, 64, 'THQ1', '15666');
INSERT INTO classes VALUES (3423, 20091, 50, 'WFV1', '15535');
INSERT INTO classes VALUES (3424, 20091, 57, 'WFX1', '15577');
INSERT INTO classes VALUES (3425, 20091, 110, 'S3L/R5', '41366');
INSERT INTO classes VALUES (3426, 20091, 43, 'WFW4', '14558');
INSERT INTO classes VALUES (3427, 20091, 108, 'TWHFR5', '39340');
INSERT INTO classes VALUES (3428, 20091, 95, 'THW1', '45806');
INSERT INTO classes VALUES (3429, 20091, 62, 'THR1', '15665');
INSERT INTO classes VALUES (3430, 20091, 70, 'THY', '37505');
INSERT INTO classes VALUES (3431, 20091, 108, 'TWHFU4', '39287');
INSERT INTO classes VALUES (3432, 20091, 36, 'WFY-1', '13878');
INSERT INTO classes VALUES (3433, 20091, 107, 'TWHFR1', '39383');
INSERT INTO classes VALUES (3434, 20091, 110, 'S6L/R3', '41382');
INSERT INTO classes VALUES (3435, 20091, 99, 'WFU', '42463');
INSERT INTO classes VALUES (3436, 20091, 95, 'WFR1', '45813');
INSERT INTO classes VALUES (3437, 20091, 152, 'NONE', '20509');
INSERT INTO classes VALUES (3438, 20091, 110, 'S4L/R4', '41371');
INSERT INTO classes VALUES (3439, 20091, 97, 'WFU', '43001');
INSERT INTO classes VALUES (3440, 20091, 127, 'THV2', '15561');
INSERT INTO classes VALUES (3441, 20091, 108, 'TWHFQ', '39285');
INSERT INTO classes VALUES (3442, 20091, 111, 'S2L/R1', '41391');
INSERT INTO classes VALUES (3443, 20091, 89, 'WFX', '62805');
INSERT INTO classes VALUES (3444, 20091, 37, 'WFW-1', '13896');
INSERT INTO classes VALUES (3445, 20091, 63, 'THV1', '15596');
INSERT INTO classes VALUES (3446, 20091, 108, 'TWHFR6', '39347');
INSERT INTO classes VALUES (3447, 20091, 108, 'TWHFR2', '39284');
INSERT INTO classes VALUES (3448, 20091, 94, 'WFX2', '45793');
INSERT INTO classes VALUES (3449, 20091, 65, 'THV1', '15616');
INSERT INTO classes VALUES (3450, 20091, 107, 'TWHFR', '39270');
INSERT INTO classes VALUES (3451, 20091, 110, 'S5L/R4', '41377');
INSERT INTO classes VALUES (3452, 20091, 134, 'THU', '43031');
INSERT INTO classes VALUES (3453, 20091, 37, 'THW-1', '13883');
INSERT INTO classes VALUES (3454, 20091, 95, 'WFW1', '45820');
INSERT INTO classes VALUES (3455, 20091, 37, 'WFY-1', '13898');
INSERT INTO classes VALUES (3456, 20091, 39, 'THW1', '16091');
INSERT INTO classes VALUES (3457, 20091, 110, 'S3L/R2', '41363');
INSERT INTO classes VALUES (3458, 20091, 36, 'WFW-4', '13864');
INSERT INTO classes VALUES (3459, 20091, 57, 'WFV1', '15576');
INSERT INTO classes VALUES (3460, 20091, 94, 'THV4', '45763');
INSERT INTO classes VALUES (3461, 20091, 39, 'THV1', '16090');
INSERT INTO classes VALUES (3462, 20091, 109, 'THX', '39300');
INSERT INTO classes VALUES (3463, 20091, 23, 'WFY', '54550');
INSERT INTO classes VALUES (3464, 20091, 36, 'WFR-2', '13868');
INSERT INTO classes VALUES (3465, 20091, 110, 'S4L/R3', '41370');
INSERT INTO classes VALUES (3466, 20091, 95, 'THW2', '45807');
INSERT INTO classes VALUES (3467, 20091, 36, 'THU-3', '13938');
INSERT INTO classes VALUES (3468, 20091, 109, 'WFU', '39385');
INSERT INTO classes VALUES (3469, 20091, 110, 'S5L/R5', '41378');
INSERT INTO classes VALUES (3470, 20091, 74, 'THV', '52915');
INSERT INTO classes VALUES (3471, 20091, 62, 'WFR1', '15668');
INSERT INTO classes VALUES (3472, 20091, 107, 'TWHFU', '39378');
INSERT INTO classes VALUES (3473, 20091, 36, 'WFX-4', '13939');
INSERT INTO classes VALUES (3474, 20091, 50, 'THW1', '15525');
INSERT INTO classes VALUES (3475, 20091, 111, 'S1L/R3', '41388');
INSERT INTO classes VALUES (3476, 20091, 50, 'THX3', '15638');
INSERT INTO classes VALUES (3477, 20091, 109, 'THY', '39296');
INSERT INTO classes VALUES (3478, 20091, 95, 'WFY1', '45824');
INSERT INTO classes VALUES (3479, 20091, 36, 'THV-1', '13856');
INSERT INTO classes VALUES (3480, 20091, 123, 'THW', '14571');
INSERT INTO classes VALUES (3481, 20091, 39, 'THX2', '16082');
INSERT INTO classes VALUES (3482, 20091, 110, 'S2L/R1', '41356');
INSERT INTO classes VALUES (3483, 20091, 108, 'TWHFU1', '39274');
INSERT INTO classes VALUES (3484, 20091, 110, 'S2L/R5', '41360');
INSERT INTO classes VALUES (3485, 20091, 87, 'THQ1', '47992');
INSERT INTO classes VALUES (3486, 20091, 89, 'THZ', '62833');
INSERT INTO classes VALUES (3487, 20091, 81, 'WFW', '42002');
INSERT INTO classes VALUES (3488, 20091, 43, 'THX2', '14547');
INSERT INTO classes VALUES (3489, 20091, 106, 'TWHFW5', '39209');
INSERT INTO classes VALUES (3490, 20091, 94, 'WFQ2', '45774');
INSERT INTO classes VALUES (3491, 20091, 1, 'HTRU', '54554');
INSERT INTO classes VALUES (3492, 20091, 41, 'THX2', '14499');
INSERT INTO classes VALUES (3493, 20091, 83, 'WFU', '41502');
INSERT INTO classes VALUES (3494, 20091, 43, 'THR', '14540');
INSERT INTO classes VALUES (3495, 20091, 70, 'THU', '37501');
INSERT INTO classes VALUES (3496, 20091, 106, 'TWHFW4', '39174');
INSERT INTO classes VALUES (3497, 20091, 100, 'WFX', '42475');
INSERT INTO classes VALUES (3498, 20091, 1, 'FWRU', '54553');
INSERT INTO classes VALUES (3499, 20091, 41, 'THV2', '14490');
INSERT INTO classes VALUES (3500, 20091, 106, 'TWHFQ1', '39151');
INSERT INTO classes VALUES (3501, 20091, 82, 'THU', '42006');
INSERT INTO classes VALUES (3502, 20091, 1, 'WFRU', '54557');
INSERT INTO classes VALUES (3503, 20091, 41, 'WFV2', '14513');
INSERT INTO classes VALUES (3504, 20091, 106, 'TWHFU3', '39163');
INSERT INTO classes VALUES (3505, 20091, 83, 'WFW', '41503');
INSERT INTO classes VALUES (3506, 20091, 100, 'THR2', '42469');
INSERT INTO classes VALUES (3507, 20091, 1, 'HTVW', '54551');
INSERT INTO classes VALUES (3508, 20091, 41, 'WFX2', '14521');
INSERT INTO classes VALUES (3509, 20091, 106, 'TWHFW7', '39248');
INSERT INTO classes VALUES (3510, 20091, 81, 'THR', '42000');
INSERT INTO classes VALUES (3511, 20091, 93, 'THU2', '46303');
INSERT INTO classes VALUES (3512, 20091, 41, 'WFX1', '14520');
INSERT INTO classes VALUES (3513, 20091, 106, 'TWHFU2', '39162');
INSERT INTO classes VALUES (3514, 20091, 94, 'THW1', '45765');
INSERT INTO classes VALUES (3515, 20091, 1, 'FWVW', '54555');
INSERT INTO classes VALUES (3516, 20091, 106, 'TWHFQ3', '39153');
INSERT INTO classes VALUES (3517, 20091, 82, 'WFW', '42005');
INSERT INTO classes VALUES (3518, 20091, 100, 'THR1', '42468');
INSERT INTO classes VALUES (3519, 20091, 42, 'THW', '14530');
INSERT INTO classes VALUES (3520, 20091, 106, 'TWHFV2', '39167');
INSERT INTO classes VALUES (3521, 20091, 82, 'THR', '42004');
INSERT INTO classes VALUES (3522, 20091, 93, 'WFR2', '46317');
INSERT INTO classes VALUES (3523, 20091, 1, 'FWXY', '54556');
INSERT INTO classes VALUES (3524, 20091, 70, 'THR', '37500');
INSERT INTO classes VALUES (3525, 20091, 99, 'THW', '42462');
INSERT INTO classes VALUES (3526, 20091, 41, 'WFX3', '14522');
INSERT INTO classes VALUES (3527, 20091, 70, 'WFW', '37509');
INSERT INTO classes VALUES (3528, 20091, 93, 'THR', '46369');
INSERT INTO classes VALUES (3529, 20091, 40, 'THX1', '14585');
INSERT INTO classes VALUES (3530, 20091, 87, 'WFR', '47957');
INSERT INTO classes VALUES (3531, 20091, 39, 'THR2', '16099');
INSERT INTO classes VALUES (3532, 20091, 70, 'WFV', '37508');
INSERT INTO classes VALUES (3533, 20091, 88, 'WFR', '62809');
INSERT INTO classes VALUES (3534, 20091, 106, 'TWHFQ5', '39249');
INSERT INTO classes VALUES (3535, 20091, 83, 'WFX', '41504');
INSERT INTO classes VALUES (3536, 20091, 100, 'WFR', '42473');
INSERT INTO classes VALUES (3537, 20091, 43, 'THV', '14543');
INSERT INTO classes VALUES (3538, 20091, 106, 'TWHFU1', '39161');
INSERT INTO classes VALUES (3539, 20091, 94, 'WFW2', '45790');
INSERT INTO classes VALUES (3540, 20091, 40, 'WFX1', '14594');
INSERT INTO classes VALUES (3541, 20091, 106, 'TWHFV4', '39169');
INSERT INTO classes VALUES (3542, 20091, 76, 'WFU1', '40810');
INSERT INTO classes VALUES (3543, 20091, 91, 'WFB/WI2', '67207');
INSERT INTO classes VALUES (3544, 20091, 39, 'THX3', '16054');
INSERT INTO classes VALUES (3545, 20091, 94, 'WFX4', '45795');
INSERT INTO classes VALUES (3546, 20091, 42, 'THY', '14531');
INSERT INTO classes VALUES (3547, 20091, 106, 'TWHFV6', '39242');
INSERT INTO classes VALUES (3548, 20091, 94, 'WFX1', '45792');
INSERT INTO classes VALUES (3549, 20091, 40, 'WFY', '14596');
INSERT INTO classes VALUES (3550, 20091, 100, 'WFQ1', '42472');
INSERT INTO classes VALUES (3551, 20091, 123, 'WFW', '14578');
INSERT INTO classes VALUES (3552, 20091, 100, 'THR3', '42515');
INSERT INTO classes VALUES (3553, 20091, 39, 'WFV2', '16114');
INSERT INTO classes VALUES (3554, 20091, 100, 'WFW', '42474');
INSERT INTO classes VALUES (3555, 20091, 93, 'THV1', '46306');
INSERT INTO classes VALUES (3556, 20091, 123, 'WFV3', '14577');
INSERT INTO classes VALUES (3557, 20091, 76, 'WFX', '40811');
INSERT INTO classes VALUES (3558, 20091, 94, 'WFQ3', '45775');
INSERT INTO classes VALUES (3559, 20091, 40, 'THX2', '14586');
INSERT INTO classes VALUES (3560, 20091, 93, 'WFY1', '46331');
INSERT INTO classes VALUES (3561, 20091, 43, 'WFW1', '14555');
INSERT INTO classes VALUES (3562, 20091, 93, 'WFY2', '46320');
INSERT INTO classes VALUES (3563, 20091, 41, 'THU4', '14488');
INSERT INTO classes VALUES (3564, 20091, 106, 'TWHFW6', '39243');
INSERT INTO classes VALUES (3565, 20091, 94, 'THQ1', '45750');
INSERT INTO classes VALUES (3566, 20091, 153, 'WFU', '39192');
INSERT INTO classes VALUES (3567, 20091, 105, 'WFV1', '43584');
INSERT INTO classes VALUES (3568, 20091, 44, 'WFY', '11656');
INSERT INTO classes VALUES (3569, 20091, 40, 'THY', '14588');
INSERT INTO classes VALUES (3570, 20091, 41, 'THQ', '14483');
INSERT INTO classes VALUES (3571, 20091, 106, 'TWHFX7', '39254');
INSERT INTO classes VALUES (3572, 20091, 104, 'THV1', '45853');
INSERT INTO classes VALUES (3573, 20091, 94, 'THX2', '45769');
INSERT INTO classes VALUES (3574, 20091, 41, 'THW5', '14497');
INSERT INTO classes VALUES (3575, 20091, 106, 'TWHFQ', '39150');
INSERT INTO classes VALUES (3576, 20091, 39, 'THQ1', '16098');
INSERT INTO classes VALUES (3577, 20091, 93, 'THX3', '46314');
INSERT INTO classes VALUES (3578, 20091, 40, 'WFV2', '14592');
INSERT INTO classes VALUES (3579, 20091, 100, 'WFQ2', '42522');
INSERT INTO classes VALUES (3580, 20091, 60, 'MR2B', '33108');
INSERT INTO classes VALUES (3581, 20091, 70, 'WFU', '37507');
INSERT INTO classes VALUES (3582, 20091, 102, 'THX', '44146');
INSERT INTO classes VALUES (3583, 20091, 41, 'THX3', '14500');
INSERT INTO classes VALUES (3584, 20091, 94, 'WFX3', '45794');
INSERT INTO classes VALUES (3585, 20091, 42, 'WFY1', '14536');
INSERT INTO classes VALUES (3586, 20091, 93, 'WFU1', '46319');
INSERT INTO classes VALUES (3587, 20091, 106, 'TWHFY1', '39180');
INSERT INTO classes VALUES (3588, 20091, 94, 'THU1', '45756');
INSERT INTO classes VALUES (3589, 20091, 42, 'WFY2', '14537');
INSERT INTO classes VALUES (3590, 20091, 42, 'THR', '14525');
INSERT INTO classes VALUES (3591, 20091, 106, 'TWHFX6', '39244');
INSERT INTO classes VALUES (3592, 20091, 98, 'WFV', '42460');
INSERT INTO classes VALUES (3593, 20091, 76, 'THX1', '40806');
INSERT INTO classes VALUES (3594, 20091, 88, 'WFU', '62810');
INSERT INTO classes VALUES (3595, 20091, 123, 'THR', '14563');
INSERT INTO classes VALUES (3596, 20091, 99, 'WFV', '42464');
INSERT INTO classes VALUES (3597, 20091, 94, 'WFV4', '45788');
INSERT INTO classes VALUES (3598, 20091, 106, 'TWHFY2', '39203');
INSERT INTO classes VALUES (3599, 20091, 43, 'WFX2', '14560');
INSERT INTO classes VALUES (3600, 20091, 70, 'WFR', '37506');
INSERT INTO classes VALUES (3601, 20091, 100, 'THQ1', '42466');
INSERT INTO classes VALUES (3602, 20091, 94, 'WFV3', '45787');
INSERT INTO classes VALUES (3603, 20091, 123, 'THU3', '14611');
INSERT INTO classes VALUES (3604, 20091, 106, 'TWHFY3', '39204');
INSERT INTO classes VALUES (3605, 20092, 154, 'THY', '39298');
INSERT INTO classes VALUES (3606, 20092, 118, 'THW', '39332');
INSERT INTO classes VALUES (3607, 20092, 11, 'WFV', '54554');
INSERT INTO classes VALUES (3608, 20092, 9, 'WFRU', '54591');
INSERT INTO classes VALUES (3609, 20092, 19, 'WFW', '54631');
INSERT INTO classes VALUES (3610, 20092, 23, 'MWX', '54637');
INSERT INTO classes VALUES (3611, 20092, 113, 'THY1', '15663');
INSERT INTO classes VALUES (3612, 20092, 39, 'WFU2', '16144');
INSERT INTO classes VALUES (3613, 20092, 155, 'THW', '40256');
INSERT INTO classes VALUES (3614, 20092, 84, 'WFV', '42006');
INSERT INTO classes VALUES (3615, 20092, 115, 'THX', '52450');
INSERT INTO classes VALUES (3616, 20092, 115, 'THXH', '52453');
INSERT INTO classes VALUES (3617, 20092, 9, 'WFXY', '54566');
INSERT INTO classes VALUES (3618, 20092, 22, 'SCVMIG', '54602');
INSERT INTO classes VALUES (3619, 20092, 81, 'WFW', '42002');
INSERT INTO classes VALUES (3620, 20092, 12, 'THVW', '54575');
INSERT INTO classes VALUES (3621, 20092, 27, 'MBD', '54625');
INSERT INTO classes VALUES (3622, 20092, 156, 'WFQ', '15001');
INSERT INTO classes VALUES (3623, 20092, 50, 'THU1', '15531');
INSERT INTO classes VALUES (3624, 20092, 115, 'THXW', '52452');
INSERT INTO classes VALUES (3625, 20092, 131, 'WFW', '56273');
INSERT INTO classes VALUES (3626, 20092, 39, 'THV', '16073');
INSERT INTO classes VALUES (3627, 20092, 59, 'MR11A', '33100');
INSERT INTO classes VALUES (3628, 20092, 74, 'THW', '54000');
INSERT INTO classes VALUES (3629, 20092, 12, 'FWVW', '54572');
INSERT INTO classes VALUES (3630, 20092, 157, 'THX', '55673');
INSERT INTO classes VALUES (3631, 20092, 94, 'THU1', '45755');
INSERT INTO classes VALUES (3632, 20092, 24, 'THW', '54567');
INSERT INTO classes VALUES (3633, 20092, 11, 'WFU', '54578');
INSERT INTO classes VALUES (3634, 20092, 35, 'THR1', '15502');
INSERT INTO classes VALUES (3635, 20092, 3, 'THVW', '54551');
INSERT INTO classes VALUES (3636, 20092, 11, 'WFW', '54555');
INSERT INTO classes VALUES (3637, 20092, 23, 'WFX', '54573');
INSERT INTO classes VALUES (3638, 20092, 5, 'WFU', '54589');
INSERT INTO classes VALUES (3639, 20092, 29, 'THQ', '54628');
INSERT INTO classes VALUES (3640, 20092, 137, 'THX', '15026');
INSERT INTO classes VALUES (3641, 20092, 14, 'WFVW', '54560');
INSERT INTO classes VALUES (3642, 20092, 11, 'WFR', '54577');
INSERT INTO classes VALUES (3643, 20092, 75, 'THY', '55115');
INSERT INTO classes VALUES (3644, 20092, 41, 'THY1', '14408');
INSERT INTO classes VALUES (3645, 20092, 113, 'WFV1', '15650');
INSERT INTO classes VALUES (3646, 20092, 79, 'THV2', '39704');
INSERT INTO classes VALUES (3647, 20092, 83, 'THU', '41483');
INSERT INTO classes VALUES (3648, 20092, 21, 'HR', '54570');
INSERT INTO classes VALUES (3649, 20092, 23, 'THY', '54571');
INSERT INTO classes VALUES (3650, 20092, 22, 'MACL', '54600');
INSERT INTO classes VALUES (3651, 20092, 43, 'THV1', '14441');
INSERT INTO classes VALUES (3652, 20092, 115, 'THXF', '52454');
INSERT INTO classes VALUES (3653, 20092, 123, 'THR1', '14470');
INSERT INTO classes VALUES (3654, 20092, 45, 'SDEF', '14501');
INSERT INTO classes VALUES (3655, 20092, 109, 'THW', '39239');
INSERT INTO classes VALUES (3656, 20092, 81, 'WFX', '42003');
INSERT INTO classes VALUES (3657, 20092, 23, 'WFY1', '54638');
INSERT INTO classes VALUES (3658, 20092, 42, 'WFX', '14435');
INSERT INTO classes VALUES (3659, 20092, 45, 'THV', '14492');
INSERT INTO classes VALUES (3660, 20092, 158, 'THW', '16135');
INSERT INTO classes VALUES (3661, 20092, 2, 'THRU', '54579');
INSERT INTO classes VALUES (3662, 20092, 37, 'WFW-2', '13928');
INSERT INTO classes VALUES (3663, 20092, 12, 'HTVW', '54563');
INSERT INTO classes VALUES (3664, 20092, 9, 'HTRU', '54568');
INSERT INTO classes VALUES (3665, 20092, 42, 'THV1', '14615');
INSERT INTO classes VALUES (3666, 20092, 94, 'THX1', '45765');
INSERT INTO classes VALUES (3667, 20092, 14, 'WFXY', '54561');
INSERT INTO classes VALUES (3668, 20092, 23, 'MVW', '54634');
INSERT INTO classes VALUES (3669, 20092, 47, 'Y', '19902');
INSERT INTO classes VALUES (3670, 20092, 109, 'THW1', '39343');
INSERT INTO classes VALUES (3671, 20092, 111, 'S3L/R1', '41398');
INSERT INTO classes VALUES (3672, 20092, 94, 'THV2', '45760');
INSERT INTO classes VALUES (3673, 20092, 26, 'THX', '54569');
INSERT INTO classes VALUES (3674, 20092, 125, 'THY', '15057');
INSERT INTO classes VALUES (3675, 20092, 159, 'WFW', '16126');
INSERT INTO classes VALUES (3676, 20092, 5, 'THX', '54587');
INSERT INTO classes VALUES (3677, 20092, 23, 'WFENTREP', '54635');
INSERT INTO classes VALUES (3678, 20092, 91, 'WFB/WK2', '67256');
INSERT INTO classes VALUES (3679, 20092, 109, 'THV1', '39245');
INSERT INTO classes VALUES (3680, 20092, 111, 'S1L/R5', '41392');
INSERT INTO classes VALUES (3681, 20092, 135, 'THW', '14956');
INSERT INTO classes VALUES (3682, 20092, 97, 'WFX', '43062');
INSERT INTO classes VALUES (3683, 20092, 93, 'THQ2', '46301');
INSERT INTO classes VALUES (3684, 20092, 102, 'THX', '44162');
INSERT INTO classes VALUES (3685, 20092, 14, 'WFRU', '54559');
INSERT INTO classes VALUES (3686, 20092, 81, 'THR', '42000');
INSERT INTO classes VALUES (3687, 20092, 14, 'THXY', '54562');
INSERT INTO classes VALUES (3688, 20092, 98, 'THY1', '42456');
INSERT INTO classes VALUES (3689, 20092, 35, 'WFV1', '15508');
INSERT INTO classes VALUES (3690, 20092, 119, 'WFX', '39214');
INSERT INTO classes VALUES (3691, 20092, 109, 'WFU2', '39334');
INSERT INTO classes VALUES (3692, 20092, 45, 'WFU', '14495');
INSERT INTO classes VALUES (3693, 20092, 115, 'THXT', '52451');
INSERT INTO classes VALUES (3694, 20092, 9, 'WFVW', '54592');
INSERT INTO classes VALUES (3695, 20092, 43, 'WFQ', '14452');
INSERT INTO classes VALUES (3696, 20092, 107, 'TWHFV6', '39335');
INSERT INTO classes VALUES (3697, 20092, 103, 'THR-1', '44670');
INSERT INTO classes VALUES (3698, 20092, 2, 'HTXY', '54586');
INSERT INTO classes VALUES (3699, 20092, 108, 'TWHFX', '39230');
INSERT INTO classes VALUES (3700, 20092, 111, 'S5L/R2', '41409');
INSERT INTO classes VALUES (3701, 20092, 97, 'WFR', '43002');
INSERT INTO classes VALUES (3702, 20092, 93, 'WFV3', '46327');
INSERT INTO classes VALUES (3703, 20092, 109, 'THU1', '39333');
INSERT INTO classes VALUES (3704, 20092, 111, 'S2L/R4', '41396');
INSERT INTO classes VALUES (3705, 20092, 23, 'WFY', '54633');
INSERT INTO classes VALUES (3706, 20092, 36, 'WFU-3', '13878');
INSERT INTO classes VALUES (3707, 20092, 111, 'S1L/R4', '41389');
INSERT INTO classes VALUES (3708, 20092, 100, 'THR1', '42472');
INSERT INTO classes VALUES (3709, 20092, 93, 'THY1', '46319');
INSERT INTO classes VALUES (3710, 20092, 2, 'HTVW', '54580');
INSERT INTO classes VALUES (3711, 20092, 50, 'WFW1', '15543');
INSERT INTO classes VALUES (3712, 20092, 111, 'S2L/R1', '41393');
INSERT INTO classes VALUES (3713, 20092, 94, 'THV1', '45759');
INSERT INTO classes VALUES (3714, 20092, 55, 'WFW1', '15573');
INSERT INTO classes VALUES (3715, 20092, 70, 'THR', '37500');
INSERT INTO classes VALUES (3716, 20092, 109, 'THQ', '39248');
INSERT INTO classes VALUES (3717, 20092, 111, 'S3L/R5', '41402');
INSERT INTO classes VALUES (3718, 20092, 108, 'TWHFV', '39233');
INSERT INTO classes VALUES (3719, 20092, 111, 'S5L/R5', '41412');
INSERT INTO classes VALUES (3720, 20092, 82, 'WFR', '42009');
INSERT INTO classes VALUES (3721, 20092, 2, 'FWXY', '54582');
INSERT INTO classes VALUES (3722, 20092, 109, 'WFU1', '39253');
INSERT INTO classes VALUES (3723, 20092, 93, 'THV5', '46307');
INSERT INTO classes VALUES (3724, 20092, 87, 'WFY', '47951');
INSERT INTO classes VALUES (3725, 20092, 5, 'THU', '54590');
INSERT INTO classes VALUES (3726, 20092, 108, 'TWHFR', '39232');
INSERT INTO classes VALUES (3727, 20092, 95, 'THY1', '45805');
INSERT INTO classes VALUES (3728, 20092, 108, 'TWHFX1', '39235');
INSERT INTO classes VALUES (3729, 20092, 94, 'WFR1', '45774');
INSERT INTO classes VALUES (3730, 20092, 41, 'THV1', '14402');
INSERT INTO classes VALUES (3731, 20092, 109, 'WFV1', '39255');
INSERT INTO classes VALUES (3732, 20092, 100, 'WFW', '42478');
INSERT INTO classes VALUES (3733, 20092, 93, 'THU2', '46305');
INSERT INTO classes VALUES (3734, 20092, 36, 'WFW-1', '13880');
INSERT INTO classes VALUES (3735, 20092, 61, 'THX1', '15597');
INSERT INTO classes VALUES (3736, 20092, 107, 'TWHFU7', '39338');
INSERT INTO classes VALUES (3737, 20092, 5, 'THY', '54588');
INSERT INTO classes VALUES (3738, 20092, 43, 'THW1', '14446');
INSERT INTO classes VALUES (3739, 20092, 60, 'MR1', '33108');
INSERT INTO classes VALUES (3740, 20092, 109, 'THX', '39240');
INSERT INTO classes VALUES (3741, 20092, 111, 'S2L/R3', '41395');
INSERT INTO classes VALUES (3742, 20092, 43, 'WFU2', '14454');
INSERT INTO classes VALUES (3743, 20092, 123, 'WFV1', '14484');
INSERT INTO classes VALUES (3744, 20092, 109, 'THV', '39238');
INSERT INTO classes VALUES (3745, 20092, 2, 'THXY', '54584');
INSERT INTO classes VALUES (3746, 20092, 63, 'THQ1', '15608');
INSERT INTO classes VALUES (3747, 20092, 108, 'TWHFW1', '39234');
INSERT INTO classes VALUES (3748, 20092, 123, 'THV2', '14473');
INSERT INTO classes VALUES (3749, 20092, 55, 'THW1', '15570');
INSERT INTO classes VALUES (3750, 20092, 118, 'THR', '39323');
INSERT INTO classes VALUES (3751, 20092, 109, 'THU2', '39340');
INSERT INTO classes VALUES (3752, 20092, 94, 'WFY1', '45790');
INSERT INTO classes VALUES (3753, 20092, 37, 'WFV-2', '13926');
INSERT INTO classes VALUES (3754, 20092, 73, 'WFR', '38050');
INSERT INTO classes VALUES (3755, 20092, 100, 'THR3', '42523');
INSERT INTO classes VALUES (3756, 20092, 108, 'TWHFU', '39231');
INSERT INTO classes VALUES (3757, 20092, 94, 'WFV2', '45782');
INSERT INTO classes VALUES (3758, 20092, 50, 'WFX2', '15535');
INSERT INTO classes VALUES (3759, 20092, 109, 'THR1', '39326');
INSERT INTO classes VALUES (3760, 20092, 94, 'THU2', '45756');
INSERT INTO classes VALUES (3761, 20092, 107, 'TWHFV4', '39204');
INSERT INTO classes VALUES (3762, 20092, 110, 'S5L/R6', '41379');
INSERT INTO classes VALUES (3763, 20092, 1, 'FWXY', '54553');
INSERT INTO classes VALUES (3764, 20092, 109, 'WFU', '39244');
INSERT INTO classes VALUES (3765, 20092, 93, 'THY2', '46320');
INSERT INTO classes VALUES (3766, 20092, 70, 'THW', '37503');
INSERT INTO classes VALUES (3767, 20092, 111, 'S2L/R5', '41397');
INSERT INTO classes VALUES (3768, 20092, 42, 'WFR2', '14429');
INSERT INTO classes VALUES (3769, 20092, 111, 'S4L/R5', '41407');
INSERT INTO classes VALUES (3770, 20092, 160, 'THU', '42480');
INSERT INTO classes VALUES (3771, 20092, 36, 'THY-2', '13870');
INSERT INTO classes VALUES (3772, 20092, 35, 'WFX1', '15544');
INSERT INTO classes VALUES (3773, 20092, 107, 'TWHFU4', '39203');
INSERT INTO classes VALUES (3774, 20092, 1, 'FWVW', '54565');
INSERT INTO classes VALUES (3775, 20092, 42, 'WFU1', '14430');
INSERT INTO classes VALUES (3776, 20092, 109, 'THV2', '39254');
INSERT INTO classes VALUES (3777, 20092, 74, 'THY', '54001');
INSERT INTO classes VALUES (3778, 20092, 50, 'THV4', '15656');
INSERT INTO classes VALUES (3779, 20092, 94, 'WFV3', '45783');
INSERT INTO classes VALUES (3780, 20092, 109, 'WFW', '39257');
INSERT INTO classes VALUES (3781, 20092, 111, 'S2L/R2', '41394');
INSERT INTO classes VALUES (3782, 20092, 95, 'THX1', '45803');
INSERT INTO classes VALUES (3783, 20092, 66, 'THX1', '26506');
INSERT INTO classes VALUES (3784, 20092, 51, 'FWX', '29251');
INSERT INTO classes VALUES (3785, 20092, 95, 'WFR1', '45808');
INSERT INTO classes VALUES (3786, 20092, 40, 'THU2', '14503');
INSERT INTO classes VALUES (3787, 20092, 110, 'S6L/R3', '41382');
INSERT INTO classes VALUES (3788, 20092, 36, 'THR-2', '13852');
INSERT INTO classes VALUES (3789, 20092, 43, 'THU1', '14438');
INSERT INTO classes VALUES (3790, 20092, 111, 'S5L/R3', '41410');
INSERT INTO classes VALUES (3791, 20092, 93, 'WFX2', '46330');
INSERT INTO classes VALUES (3792, 20092, 35, 'WFR1', '15506');
INSERT INTO classes VALUES (3793, 20092, 70, 'THV', '37502');
INSERT INTO classes VALUES (3794, 20092, 109, 'THR3', '39339');
INSERT INTO classes VALUES (3795, 20092, 111, 'S3L/R4', '41401');
INSERT INTO classes VALUES (3796, 20092, 50, 'WFR1', '15539');
INSERT INTO classes VALUES (3797, 20092, 109, 'THR', '39250');
INSERT INTO classes VALUES (3798, 20092, 93, 'WFV1', '46325');
INSERT INTO classes VALUES (3799, 20092, 50, 'THV2', '15534');
INSERT INTO classes VALUES (3800, 20092, 111, 'S3L/R2', '41399');
INSERT INTO classes VALUES (3801, 20092, 123, 'THX1', '14478');
INSERT INTO classes VALUES (3802, 20092, 109, 'THR2', '39331');
INSERT INTO classes VALUES (3803, 20092, 111, 'S5L/R1', '41408');
INSERT INTO classes VALUES (3804, 20092, 93, 'WFX1', '46332');
INSERT INTO classes VALUES (3805, 20092, 50, 'WFX1', '15545');
INSERT INTO classes VALUES (3806, 20092, 109, 'WFR', '39251');
INSERT INTO classes VALUES (3807, 20092, 94, 'THR2', '45753');
INSERT INTO classes VALUES (3808, 20092, 94, 'THQ1', '45750');
INSERT INTO classes VALUES (3809, 20092, 35, 'THV1', '15504');
INSERT INTO classes VALUES (3810, 20092, 70, 'THY', '37505');
INSERT INTO classes VALUES (3811, 20092, 110, 'S6L/R2', '41381');
INSERT INTO classes VALUES (3812, 20092, 75, 'WFW', '55101');
INSERT INTO classes VALUES (3813, 20092, 37, 'THV-1', '13917');
INSERT INTO classes VALUES (3814, 20092, 95, 'WFV2', '45812');
INSERT INTO classes VALUES (3815, 20092, 93, 'THU3', '46306');
INSERT INTO classes VALUES (3816, 20092, 104, 'WFW', '47957');
INSERT INTO classes VALUES (3817, 20092, 39, 'THR', '16069');
INSERT INTO classes VALUES (3818, 20092, 70, 'THU', '37501');
INSERT INTO classes VALUES (3819, 20092, 138, 'WFU', '40812');
INSERT INTO classes VALUES (3820, 20092, 111, 'S4L/R4', '41406');
INSERT INTO classes VALUES (3821, 20092, 161, 'FAB2', '41451');
INSERT INTO classes VALUES (3822, 20092, 70, 'WFV', '37508');
INSERT INTO classes VALUES (3823, 20092, 111, 'S5L/R4', '41411');
INSERT INTO classes VALUES (3824, 20092, 87, 'WFR', '47963');
INSERT INTO classes VALUES (3825, 20092, 43, 'WFV2', '14457');
INSERT INTO classes VALUES (3826, 20092, 42, 'THX2', '14425');
INSERT INTO classes VALUES (3827, 20092, 45, 'WFX', '14500');
INSERT INTO classes VALUES (3828, 20092, 107, 'TWHFW', '39180');
INSERT INTO classes VALUES (3829, 20092, 100, 'WFQ1', '42475');
INSERT INTO classes VALUES (3830, 20092, 2, 'HTRU1', '54557');
INSERT INTO classes VALUES (3831, 20092, 36, 'WFV-2', '13873');
INSERT INTO classes VALUES (3832, 20092, 107, 'TWHFW3', '39201');
INSERT INTO classes VALUES (3833, 20092, 98, 'THY3', '42458');
INSERT INTO classes VALUES (3834, 20092, 2, 'HTRU2', '54550');
INSERT INTO classes VALUES (3835, 20092, 36, 'THX-2', '13867');
INSERT INTO classes VALUES (3836, 20092, 41, 'THU1', '14606');
INSERT INTO classes VALUES (3837, 20092, 107, 'TWHFW2', '39194');
INSERT INTO classes VALUES (3838, 20092, 93, 'WFU3', '46324');
INSERT INTO classes VALUES (3839, 20092, 123, 'WFV2', '14485');
INSERT INTO classes VALUES (3840, 20092, 107, 'TWHFQ1', '39183');
INSERT INTO classes VALUES (3841, 20092, 105, 'WFU', '43562');
INSERT INTO classes VALUES (3842, 20092, 107, 'TWHFV3', '39200');
INSERT INTO classes VALUES (3843, 20092, 94, 'THW2', '45764');
INSERT INTO classes VALUES (3844, 20092, 93, 'WFR1', '46321');
INSERT INTO classes VALUES (3845, 20092, 40, 'WFR', '14511');
INSERT INTO classes VALUES (3846, 20092, 70, 'WFU', '37507');
INSERT INTO classes VALUES (3847, 20092, 87, 'WFX', '47970');
INSERT INTO classes VALUES (3848, 20092, 43, 'WFX', '14466');
INSERT INTO classes VALUES (3849, 20092, 82, 'THR', '42008');
INSERT INTO classes VALUES (3850, 20092, 95, 'WFV1', '45811');
INSERT INTO classes VALUES (3851, 20092, 1, 'THVW', '54556');
INSERT INTO classes VALUES (3852, 20092, 123, 'WFW1', '14487');
INSERT INTO classes VALUES (3853, 20092, 48, 'X', '19904');
INSERT INTO classes VALUES (3854, 20092, 39, 'THQ', '16094');
INSERT INTO classes VALUES (3855, 20092, 79, 'THW2', '39705');
INSERT INTO classes VALUES (3856, 20092, 94, 'WFW2', '45785');
INSERT INTO classes VALUES (3857, 20092, 41, 'WFX1', '14417');
INSERT INTO classes VALUES (3858, 20092, 36, 'WFU-2', '13877');
INSERT INTO classes VALUES (3859, 20092, 41, 'WFR', '14411');
INSERT INTO classes VALUES (3860, 20092, 100, 'WFQ2', '42476');
INSERT INTO classes VALUES (3861, 20092, 107, 'TWHFQ3', '39196');
INSERT INTO classes VALUES (3862, 20092, 98, 'WFV2', '42461');
INSERT INTO classes VALUES (3863, 20092, 123, 'WFR', '14481');
INSERT INTO classes VALUES (3864, 20092, 40, 'WFU1', '14512');
INSERT INTO classes VALUES (3865, 20092, 106, 'TWHFW', '39174');
INSERT INTO classes VALUES (3866, 20092, 107, 'TWHFU2', '39192');
INSERT INTO classes VALUES (3867, 20092, 98, 'WFV1', '42460');
INSERT INTO classes VALUES (3868, 20092, 41, 'THX2', '14406');
INSERT INTO classes VALUES (3869, 20092, 81, 'WFR', '42001');
INSERT INTO classes VALUES (3870, 20092, 39, 'WFX4', '16105');
INSERT INTO classes VALUES (3871, 20092, 70, 'WFW', '37509');
INSERT INTO classes VALUES (3872, 20092, 107, 'TWHFU1', '39185');
INSERT INTO classes VALUES (3873, 20092, 39, 'THX1', '16053');
INSERT INTO classes VALUES (3874, 20092, 106, 'TWHFV1', '39211');
INSERT INTO classes VALUES (3875, 20092, 94, 'WFR3', '45776');
INSERT INTO classes VALUES (3876, 20092, 158, 'THX', '16136');
INSERT INTO classes VALUES (3877, 20092, 107, 'TWHFU', '39178');
INSERT INTO classes VALUES (3878, 20092, 98, 'THV1', '42453');
INSERT INTO classes VALUES (3879, 20092, 99, 'WFW', '42467');
INSERT INTO classes VALUES (3880, 20092, 43, 'WFV4', '14459');
INSERT INTO classes VALUES (3881, 20092, 107, 'TWHFQ4', '39209');
INSERT INTO classes VALUES (3882, 20092, 93, 'WFU1', '46322');
INSERT INTO classes VALUES (3883, 20092, 39, 'WFV1', '16104');
INSERT INTO classes VALUES (3884, 20092, 73, 'WFU', '38065');
INSERT INTO classes VALUES (3885, 20092, 107, 'TWHFR', '39177');
INSERT INTO classes VALUES (3886, 20092, 93, 'WFW1', '46328');
INSERT INTO classes VALUES (3887, 20092, 70, 'WFX', '37510');
INSERT INTO classes VALUES (3888, 20092, 89, 'WFR', '62802');
INSERT INTO classes VALUES (3889, 20092, 42, 'WFU2', '14431');
INSERT INTO classes VALUES (3890, 20092, 107, 'TWHFR2', '39191');
INSERT INTO classes VALUES (3891, 20092, 100, 'THQ2', '42470');
INSERT INTO classes VALUES (3892, 20092, 39, 'THW', '16074');
INSERT INTO classes VALUES (3893, 20092, 107, 'TWHFV1', '39186');
INSERT INTO classes VALUES (3894, 20092, 41, 'WFU1', '14412');
INSERT INTO classes VALUES (3895, 20092, 107, 'TWHFR4', '39202');
INSERT INTO classes VALUES (3896, 20092, 98, 'THU', '42452');
INSERT INTO classes VALUES (3897, 20092, 63, 'WFV1', '15617');
INSERT INTO classes VALUES (3898, 20092, 39, 'WFR1', '16097');
INSERT INTO classes VALUES (3899, 20092, 107, 'TWHFU3', '39198');
INSERT INTO classes VALUES (3900, 20092, 41, 'WFW1', '14415');
INSERT INTO classes VALUES (3901, 20092, 93, 'THW2', '46316');
INSERT INTO classes VALUES (3902, 20092, 70, 'THX', '37504');
INSERT INTO classes VALUES (3903, 20092, 39, 'WFW', '16121');
INSERT INTO classes VALUES (3904, 20092, 106, 'TWHFR', '39171');
INSERT INTO classes VALUES (3905, 20092, 83, 'THX', '41485');
INSERT INTO classes VALUES (3906, 20092, 63, 'THW3', '15664');
INSERT INTO classes VALUES (3907, 20092, 94, 'WFU3', '45780');
INSERT INTO classes VALUES (3908, 20092, 79, 'THV1', '39703');
INSERT INTO classes VALUES (3909, 20092, 83, 'WFX', '41488');
INSERT INTO classes VALUES (3910, 20092, 93, 'THW3', '46313');
INSERT INTO classes VALUES (3911, 20092, 41, 'THX3', '14407');
INSERT INTO classes VALUES (3912, 20092, 105, 'THY', '43560');
INSERT INTO classes VALUES (3913, 20092, 42, 'THX1', '14424');
INSERT INTO classes VALUES (3914, 20092, 95, 'WFU1', '45809');
INSERT INTO classes VALUES (3915, 20092, 83, 'THW', '41484');
INSERT INTO classes VALUES (3916, 20092, 94, 'WFR4', '45777');
INSERT INTO classes VALUES (3917, 20092, 107, 'TWHFW1', '39187');
INSERT INTO classes VALUES (3918, 20092, 99, 'WFU', '42464');
INSERT INTO classes VALUES (3919, 20092, 71, 'THX', '38794');
INSERT INTO classes VALUES (3920, 20092, 94, 'WFX3', '45789');
INSERT INTO classes VALUES (3921, 20092, 100, 'THQ1', '42469');
INSERT INTO classes VALUES (3922, 20092, 46, 'WFR', '14951');
INSERT INTO classes VALUES (3923, 20092, 107, 'TWHFV2', '39193');
INSERT INTO classes VALUES (3924, 20092, 95, 'WFQ1', '45807');
INSERT INTO classes VALUES (3925, 20092, 93, 'THU1', '46304');
INSERT INTO classes VALUES (3926, 20092, 43, 'WFU3', '14455');
INSERT INTO classes VALUES (3927, 20092, 99, 'WFX', '42468');
INSERT INTO classes VALUES (3928, 20092, 76, 'WFY', '40806');
INSERT INTO classes VALUES (3929, 20092, 93, 'THX1', '46317');
INSERT INTO classes VALUES (3930, 20092, 123, 'WFU1', '14482');
INSERT INTO classes VALUES (3931, 20092, 75, 'WFV', '55100');
INSERT INTO classes VALUES (3932, 20092, 61, 'WFU1', '15599');
INSERT INTO classes VALUES (3933, 20092, 107, 'TWHFW4', '39321');
INSERT INTO classes VALUES (3934, 20092, 93, 'THV4', '46312');
INSERT INTO classes VALUES (3935, 20092, 57, 'WFR1', '15588');
INSERT INTO classes VALUES (3936, 20092, 63, 'WFY1', '15620');
INSERT INTO classes VALUES (3937, 20092, 99, 'THW', '42463');
INSERT INTO classes VALUES (3938, 20092, 41, 'WFU3', '14414');
INSERT INTO classes VALUES (3939, 20092, 97, 'THW1', '43003');
INSERT INTO classes VALUES (3940, 20092, 39, 'THX2', '16078');
INSERT INTO classes VALUES (3941, 20092, 59, 'MR11C', '33102');
INSERT INTO classes VALUES (3942, 20092, 36, 'WFU-1', '13875');
INSERT INTO classes VALUES (3943, 20092, 70, 'WFR', '37506');
INSERT INTO classes VALUES (3944, 20092, 107, 'TWHFV5', '39329');
INSERT INTO classes VALUES (3945, 20092, 94, 'WFU2', '45779');
INSERT INTO classes VALUES (3946, 20092, 41, 'WFW2', '14416');
INSERT INTO classes VALUES (3947, 20092, 123, 'WFW2', '14488');
INSERT INTO classes VALUES (3948, 20092, 40, 'THW', '14506');
INSERT INTO classes VALUES (3949, 20092, 36, 'THQ-1', '13850');
INSERT INTO classes VALUES (3950, 20092, 106, 'TWHFV', '39173');
INSERT INTO classes VALUES (3951, 20092, 89, 'WFU', '62803');
INSERT INTO classes VALUES (3952, 20092, 36, 'THU-2', '13855');
INSERT INTO classes VALUES (3953, 20092, 39, 'WFQ1', '16096');
INSERT INTO classes VALUES (3954, 20092, 43, 'THU2', '14439');
INSERT INTO classes VALUES (3955, 20092, 40, 'THY2', '14510');
INSERT INTO classes VALUES (3956, 20092, 158, 'WFX', '16127');
INSERT INTO classes VALUES (3957, 20092, 76, 'THW', '40802');
INSERT INTO classes VALUES (3958, 20092, 94, 'THX4', '45768');
INSERT INTO classes VALUES (3959, 20092, 107, 'TWHFU5', '39206');
INSERT INTO classes VALUES (3960, 20092, 100, 'THW', '42474');
INSERT INTO classes VALUES (3961, 20092, 41, 'WFX2', '14418');
INSERT INTO classes VALUES (3962, 20092, 93, 'THR1', '46302');
INSERT INTO classes VALUES (3963, 20092, 94, 'WFX1', '45787');
INSERT INTO classes VALUES (3964, 20092, 43, 'WFW1', '14461');
INSERT INTO classes VALUES (3965, 20092, 106, 'TWHFQ', '39170');
INSERT INTO classes VALUES (3966, 20092, 103, 'WFV-1', '44684');
INSERT INTO classes VALUES (3967, 20092, 39, 'THX3', '16081');
INSERT INTO classes VALUES (3968, 20092, 93, 'THW1', '46315');
INSERT INTO classes VALUES (3969, 20092, 42, 'THX3', '14426');
INSERT INTO classes VALUES (3970, 20092, 39, 'WFY2', '16068');
INSERT INTO classes VALUES (3971, 20092, 104, 'MCDE1', '45817');
INSERT INTO classes VALUES (3972, 20092, 100, 'WFR', '42477');
INSERT INTO classes VALUES (3973, 20092, 95, 'THU2', '45796');
INSERT INTO classes VALUES (3974, 20092, 39, 'WFU', '16103');
INSERT INTO classes VALUES (3975, 20093, 41, 'X4A', '14406');
INSERT INTO classes VALUES (3976, 20093, 111, 'X7-5', '41355');
INSERT INTO classes VALUES (3977, 20093, 93, 'X3-1', '46307');
INSERT INTO classes VALUES (3978, 20093, 35, 'X2-A', '15501');
INSERT INTO classes VALUES (3979, 20093, 18, 'Prac', '54551');
INSERT INTO classes VALUES (3980, 20093, 162, 'X7-9', '41359');
INSERT INTO classes VALUES (3981, 20093, 94, 'X3', '45753');
INSERT INTO classes VALUES (3982, 20093, 113, 'X1-A', '15546');
INSERT INTO classes VALUES (3983, 20093, 70, 'X5', '37504');
INSERT INTO classes VALUES (3984, 20093, 113, 'X2-B', '15543');
INSERT INTO classes VALUES (3985, 20093, 133, 'X4', '55651');
INSERT INTO classes VALUES (3986, 20093, 61, 'X3-A', '15519');
INSERT INTO classes VALUES (3987, 20093, 109, 'X2-1', '39205');
INSERT INTO classes VALUES (3988, 20093, 81, 'X4', '42003');
INSERT INTO classes VALUES (3989, 20093, 71, 'X3', '38602');
INSERT INTO classes VALUES (3990, 20093, 123, 'X3A', '14431');
INSERT INTO classes VALUES (3991, 20093, 111, 'X7-4', '41354');
INSERT INTO classes VALUES (3992, 20093, 98, 'X1', '42451');
INSERT INTO classes VALUES (3993, 20093, 5, 'X', '54554');
INSERT INTO classes VALUES (3994, 20093, 108, 'Z1-4', '39195');
INSERT INTO classes VALUES (3995, 20093, 109, 'X1-1', '39193');
INSERT INTO classes VALUES (3996, 20093, 103, 'X-2', '44659');
INSERT INTO classes VALUES (3997, 20093, 109, 'X4', '39182');
INSERT INTO classes VALUES (3998, 20093, 109, 'X3', '39181');
INSERT INTO classes VALUES (3999, 20093, 100, 'X4-1', '42461');
INSERT INTO classes VALUES (4000, 20093, 108, 'Z2', '39172');
INSERT INTO classes VALUES (4001, 20093, 108, 'Z3-1', '39175');
INSERT INTO classes VALUES (4002, 20093, 108, 'Z3-4', '39206');
INSERT INTO classes VALUES (4003, 20093, 109, 'X4-1', '39183');
INSERT INTO classes VALUES (4004, 20093, 43, 'X2B', '14418');
INSERT INTO classes VALUES (4005, 20093, 123, 'X2A', '14428');
INSERT INTO classes VALUES (4006, 20093, 93, 'X3', '46302');
INSERT INTO classes VALUES (4007, 20093, 23, 'X', '54553');
INSERT INTO classes VALUES (4008, 20093, 109, 'X2', '39180');
INSERT INTO classes VALUES (4009, 20093, 103, 'X5', '43556');
INSERT INTO classes VALUES (4010, 20093, 50, 'X4-A', '15507');
INSERT INTO classes VALUES (4011, 20093, 41, 'X3A', '14403');
INSERT INTO classes VALUES (4012, 20093, 108, 'Z1-1', '39173');
INSERT INTO classes VALUES (4013, 20093, 108, 'Z2-3', '39199');
INSERT INTO classes VALUES (4014, 20093, 137, 'X3', '14966');
INSERT INTO classes VALUES (4015, 20093, 163, 'X-2-2', '44653');
INSERT INTO classes VALUES (4016, 20093, 107, 'Z1-2', '39169');
INSERT INTO classes VALUES (4017, 20093, 108, 'Z1', '39170');
INSERT INTO classes VALUES (4018, 20093, 108, 'Z1-3', '39194');
INSERT INTO classes VALUES (4019, 20093, 108, 'Z1-5', '39196');
INSERT INTO classes VALUES (4020, 20093, 95, 'X3', '45755');
INSERT INTO classes VALUES (4021, 20093, 93, 'X2', '46301');
INSERT INTO classes VALUES (4022, 20093, 108, 'Z2-2', '39177');
INSERT INTO classes VALUES (4023, 20093, 105, 'X3', '43554');
INSERT INTO classes VALUES (4024, 20093, 94, 'X2', '45752');
INSERT INTO classes VALUES (4025, 20093, 40, 'X4A', '14439');
INSERT INTO classes VALUES (4026, 20093, 100, 'X3-1', '42459');
INSERT INTO classes VALUES (4027, 20093, 107, 'Z1', '39164');
INSERT INTO classes VALUES (4028, 20093, 108, 'Z1-2', '39176');
INSERT INTO classes VALUES (4029, 20093, 108, 'Z1-6', '39197');
INSERT INTO classes VALUES (4030, 20093, 107, 'Z2', '39165');
INSERT INTO classes VALUES (4031, 20093, 107, 'Z1-3', '39201');
INSERT INTO classes VALUES (4032, 20093, 108, 'Z3-2', '39178');
INSERT INTO classes VALUES (4033, 20093, 100, 'X3-2', '42460');
INSERT INTO classes VALUES (4034, 20093, 94, 'X1', '45751');
INSERT INTO classes VALUES (4035, 20093, 107, 'Z2-1', '39168');
INSERT INTO classes VALUES (4036, 20093, 107, 'Z2-2', '39202');
INSERT INTO classes VALUES (4037, 20093, 84, 'X3', '42002');
INSERT INTO classes VALUES (4038, 20093, 39, 'X1A', '16051');
INSERT INTO classes VALUES (4039, 20093, 102, 'X2-1', '44110');
INSERT INTO classes VALUES (4040, 20093, 71, 'X2', '38601');
INSERT INTO classes VALUES (4041, 20093, 107, 'Z1-1', '39167');
INSERT INTO classes VALUES (4042, 20093, 108, 'Z1-8', '39215');
INSERT INTO classes VALUES (4043, 20093, 108, 'Z2-1', '39174');
INSERT INTO classes VALUES (4044, 20101, 17, 'THU', '54569');
INSERT INTO classes VALUES (4045, 20101, 7, 'HTVW', '54586');
INSERT INTO classes VALUES (4046, 20101, 16, 'THY', '54592');
INSERT INTO classes VALUES (4047, 20101, 6, 'S2', '54650');
INSERT INTO classes VALUES (4048, 20101, 112, 'WFR', '69955');
INSERT INTO classes VALUES (4049, 20101, 37, 'WFX-1', '13890');
INSERT INTO classes VALUES (4050, 20101, 102, 'WFU', '44164');
INSERT INTO classes VALUES (4051, 20101, 17, 'WFV', '54571');
INSERT INTO classes VALUES (4052, 20101, 21, 'HR', '54593');
INSERT INTO classes VALUES (4053, 20101, 20, 'MACL', '54614');
INSERT INTO classes VALUES (4054, 20101, 19, 'WFX', '54576');
INSERT INTO classes VALUES (4055, 20101, 16, 'WFY', '54591');
INSERT INTO classes VALUES (4056, 20101, 20, 'MWSG', '54619');
INSERT INTO classes VALUES (4057, 20101, 112, 'WFU', '69956');
INSERT INTO classes VALUES (4058, 20101, 164, 'THD', '66665');
INSERT INTO classes VALUES (4059, 20101, 164, 'HJ4', '66745');
INSERT INTO classes VALUES (4060, 20101, 70, 'WFV', '37509');
INSERT INTO classes VALUES (4061, 20101, 82, 'THX', '42012');
INSERT INTO classes VALUES (4062, 20101, 16, 'WFX', '54590');
INSERT INTO classes VALUES (4063, 20101, 23, 'THR', '54605');
INSERT INTO classes VALUES (4064, 20101, 114, 'WBC', '52481');
INSERT INTO classes VALUES (4065, 20101, 114, 'WBCH', '52483');
INSERT INTO classes VALUES (4066, 20101, 17, 'WFW', '54572');
INSERT INTO classes VALUES (4067, 20101, 8, 'THV', '54579');
INSERT INTO classes VALUES (4068, 20101, 6, 'HTXY', '54582');
INSERT INTO classes VALUES (4069, 20101, 7, 'M', '54649');
INSERT INTO classes VALUES (4070, 20101, 114, 'WBCT', '52482');
INSERT INTO classes VALUES (4071, 20101, 8, 'THW', '54577');
INSERT INTO classes VALUES (4072, 20101, 7, 'WFVW', '54646');
INSERT INTO classes VALUES (4073, 20101, 23, 'THV', '54595');
INSERT INTO classes VALUES (4074, 20101, 114, 'FBCS2', '52528');
INSERT INTO classes VALUES (4075, 20101, 114, 'FBC', '52530');
INSERT INTO classes VALUES (4076, 20101, 113, 'WFQ2', '15650');
INSERT INTO classes VALUES (4077, 20101, 155, 'THW', '40258');
INSERT INTO classes VALUES (4078, 20101, 19, 'WFU', '54574');
INSERT INTO classes VALUES (4079, 20101, 16, 'WFV', '54589');
INSERT INTO classes VALUES (4080, 20101, 20, 'MCVMIG', '54616');
INSERT INTO classes VALUES (4081, 20101, 112, 'WFX', '70034');
INSERT INTO classes VALUES (4082, 20101, 123, 'WFU1', '14497');
INSERT INTO classes VALUES (4083, 20101, 87, 'WFW1', '47967');
INSERT INTO classes VALUES (4084, 20101, 7, 'HTRU', '54585');
INSERT INTO classes VALUES (4085, 20101, 113, 'THV1', '15631');
INSERT INTO classes VALUES (4086, 20101, 70, 'THW', '37504');
INSERT INTO classes VALUES (4087, 20101, 100, 'WFR1', '42472');
INSERT INTO classes VALUES (4088, 20101, 3, 'WFVW', '54567');
INSERT INTO classes VALUES (4089, 20101, 19, 'THR', '54573');
INSERT INTO classes VALUES (4090, 20101, 17, 'WFU', '54570');
INSERT INTO classes VALUES (4091, 20101, 19, 'WFW', '54575');
INSERT INTO classes VALUES (4092, 20101, 26, 'THX', '54596');
INSERT INTO classes VALUES (4093, 20101, 75, 'WFY', '55106');
INSERT INTO classes VALUES (4094, 20101, 8, 'THY', '54578');
INSERT INTO classes VALUES (4095, 20101, 113, 'THX2', '15636');
INSERT INTO classes VALUES (4096, 20101, 165, 'THU', '39268');
INSERT INTO classes VALUES (4097, 20101, 111, 'S4-A', '41382');
INSERT INTO classes VALUES (4098, 20101, 114, 'FBCS1', '52484');
INSERT INTO classes VALUES (4099, 20101, 20, 'MNDSG', '54617');
INSERT INTO classes VALUES (4100, 20101, 43, 'THW1', '14465');
INSERT INTO classes VALUES (4101, 20101, 111, 'S3-A', '41380');
INSERT INTO classes VALUES (4102, 20101, 95, 'THV1', '45796');
INSERT INTO classes VALUES (4103, 20101, 79, 'WFV1', '39705');
INSERT INTO classes VALUES (4104, 20101, 20, 'MSCL', '54618');
INSERT INTO classes VALUES (4105, 20101, 108, 'TWHFV1', '39249');
INSERT INTO classes VALUES (4106, 20101, 72, 'WFX', '52379');
INSERT INTO classes VALUES (4107, 20101, 3, 'WFRU', '54566');
INSERT INTO classes VALUES (4108, 20101, 35, 'WFV2', '15505');
INSERT INTO classes VALUES (4109, 20101, 109, 'THX', '39261');
INSERT INTO classes VALUES (4110, 20101, 100, 'THR3', '42519');
INSERT INTO classes VALUES (4111, 20101, 166, 'THU', '43030');
INSERT INTO classes VALUES (4112, 20101, 23, 'THW', '54604');
INSERT INTO classes VALUES (4113, 20101, 36, 'THY-1', '13862');
INSERT INTO classes VALUES (4114, 20101, 103, 'WFQ-2', '44665');
INSERT INTO classes VALUES (4115, 20101, 74, 'THX', '54001');
INSERT INTO classes VALUES (4116, 20101, 23, 'WFY', '54607');
INSERT INTO classes VALUES (4117, 20101, 127, 'THV1', '15554');
INSERT INTO classes VALUES (4118, 20101, 81, 'WFX', '42002');
INSERT INTO classes VALUES (4119, 20101, 82, 'THR', '42003');
INSERT INTO classes VALUES (4120, 20101, 107, 'TWHFY1', '39382');
INSERT INTO classes VALUES (4121, 20101, 110, 'S3-A', '41361');
INSERT INTO classes VALUES (4122, 20101, 1, 'FWVW', '54555');
INSERT INTO classes VALUES (4123, 20101, 45, 'WFV', '14519');
INSERT INTO classes VALUES (4124, 20101, 6, 'S', '54643');
INSERT INTO classes VALUES (4125, 20101, 137, 'THQ', '15024');
INSERT INTO classes VALUES (4126, 20101, 56, 'THX1', '15566');
INSERT INTO classes VALUES (4127, 20101, 6, 'FWVW', '54583');


--
-- Name: classes_classid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('classes_classid_seq', 4127, true);


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

INSERT INTO persons VALUES (955, 'ORENSE', 'ADRIAN', 'CORDOVA', '');
INSERT INTO persons VALUES (956, 'VILLARANTE', 'JAY RICKY', 'BARRAMEDA', '');
INSERT INTO persons VALUES (957, 'LUMONGSOD', 'PIO RYAN', 'SAGARINO', '');
INSERT INTO persons VALUES (958, 'TOBIAS', 'GEORGE HELAMAN', 'ASTURIAS', '');
INSERT INTO persons VALUES (959, 'CUNANAN', 'JENNIFER', 'DELA CRUZ', '');
INSERT INTO persons VALUES (960, 'RAGASA', 'ROGER JOHN', 'ESTEPA', '');
INSERT INTO persons VALUES (961, 'MARANAN', 'KERVIN', 'CATUNGAL', '');
INSERT INTO persons VALUES (962, 'DEINLA', 'REGINALD ELI', 'ATIENZA', '');
INSERT INTO persons VALUES (963, 'RAMIREZ', 'NORBERTO', 'ALLAREY', 'II');
INSERT INTO persons VALUES (964, 'PUGAL', 'EDGAR', 'STA BARBARA', 'JR');
INSERT INTO persons VALUES (965, 'JOVEN', 'KATHLEEN GRACE', 'GUERRERO', '');
INSERT INTO persons VALUES (966, 'ESCALANTE', 'ED ALBERT', 'BELARGO', '');
INSERT INTO persons VALUES (967, 'CONTRERAS', 'PAUL VINCENT', 'SALES', '');
INSERT INTO persons VALUES (968, 'DIRECTO', 'KAREIN JOY', 'TOLENTINO', '');
INSERT INTO persons VALUES (969, 'VALLO', 'LOVELIA', 'LAROCO', '');
INSERT INTO persons VALUES (970, 'DOMINGO', 'CYROD JOHN', 'FLORIDA', '');
INSERT INTO persons VALUES (971, 'SUBA', 'KEVIN RAINIER', 'SINOGAYA', '');
INSERT INTO persons VALUES (972, 'CATAJOY', 'VINCENT NICHOLAS', 'RANA', '');
INSERT INTO persons VALUES (973, 'BATANES', 'BRYAN MATTHEW', 'AVENDANO', '');
INSERT INTO persons VALUES (974, 'BALAGAPO', 'JOSHUA', 'KHO', '');
INSERT INTO persons VALUES (975, 'DOMANTAY', 'ERIC', 'AMPARO', 'JR');
INSERT INTO persons VALUES (976, 'JAVIER', 'JEWEL LEX', 'TONG', '');
INSERT INTO persons VALUES (977, 'JUAT', 'WESLEY', 'MENDOZA', '');
INSERT INTO persons VALUES (978, 'ISIDRO', 'HOMER IRIC', 'SANTOS', '');
INSERT INTO persons VALUES (979, 'VILLANUEVA', 'MARIANNE ANGELIE', 'OCAMPO', '');
INSERT INTO persons VALUES (980, 'MAMARIL', 'VIC ANGELO', 'DELOS SANTOS', '');
INSERT INTO persons VALUES (981, 'ARANA', 'RYAN KRISTOFER', 'IGMAT', '');
INSERT INTO persons VALUES (982, 'NICOLAS', 'DANA ELISA', 'GAGALAC', '');
INSERT INTO persons VALUES (983, 'VACALARES', 'ISAIAH JAMES', 'VALDES', '');
INSERT INTO persons VALUES (984, 'SANTILLAN', 'MA CECILIA', '', '');
INSERT INTO persons VALUES (985, 'PINEDA', 'JAKE ERICKSON', 'BOTEROS', '');
INSERT INTO persons VALUES (986, 'LOYOLA', 'ELIZABETH', 'CUETO', '');
INSERT INTO persons VALUES (987, 'BUGAOAN', 'FRANCIS KEVIN', 'ALIMORONG', '');
INSERT INTO persons VALUES (988, 'GALLARDO', 'FRANCIS JOMER', 'DE LEON', '');
INSERT INTO persons VALUES (989, 'ARGARIN', 'MICHAEL ERICK', 'STA TERESA', '');
INSERT INTO persons VALUES (990, 'VILLARUZ', 'JULIAN', 'CASTILLO', '');
INSERT INTO persons VALUES (991, 'FRANCISCO', 'ARMINA', 'EUGENIO', '');
INSERT INTO persons VALUES (992, 'AQUINO', 'JOSEPH ARMAN', 'BONGCO', '');
INSERT INTO persons VALUES (993, 'AME', 'MARTIN ROMAN LORENZO', 'ILAGAN', '');
INSERT INTO persons VALUES (994, 'CELEDONIO', 'MESSIAH JAN', 'LEBID', '');
INSERT INTO persons VALUES (995, 'SABIDONG', 'JEROME', 'RONCESVALLES', '');
INSERT INTO persons VALUES (996, 'FLORENCIO', 'JOHN CARLO', 'MAQUILAN', '');
INSERT INTO persons VALUES (997, 'EPISTOLA', 'SILVEN VICTOR', 'DUMALAG', '');
INSERT INTO persons VALUES (998, 'SANTOS', 'JOHN ISRAEL', 'LORENZO', '');
INSERT INTO persons VALUES (999, 'SANTOS', 'MARIE JUNNE', 'CABRAL', '');
INSERT INTO persons VALUES (1000, 'FABIC', 'JULIAN NICHOLAS', 'REYES', '');
INSERT INTO persons VALUES (1001, 'TORRES', 'ERIC', 'TUQUERO', '');
INSERT INTO persons VALUES (1002, 'CUETO', 'BENJAMIN', 'ANGELES', 'JR');
INSERT INTO persons VALUES (1003, 'PASCUAL', 'JEANELLA KLARYS', 'ESPIRITU', '');
INSERT INTO persons VALUES (1004, 'GAMBA', 'JOSE NOEL', 'CARDONES', '');
INSERT INTO persons VALUES (1005, 'REFAMONTE', 'JARED', 'MUMAR', '');
INSERT INTO persons VALUES (1006, 'BARITUA', 'KARESSA ALEXANDRA', 'ONG', '');
INSERT INTO persons VALUES (1007, 'SEMILLA', 'STANLEY', 'TINA', '');
INSERT INTO persons VALUES (1008, 'ANGELES', 'MARC ARTHUR', 'PAJE', '');
INSERT INTO persons VALUES (1009, 'SORIAO', 'HANS CHRISTIAN', 'BALTAZAR', '');
INSERT INTO persons VALUES (1010, 'DINO', 'ARVIN', 'PABINES', '');
INSERT INTO persons VALUES (1011, 'MORALES', 'NOELYN JOYCE', 'ROL', '');
INSERT INTO persons VALUES (1012, 'MANALAC', 'DAVID ROBIN', 'MANALAC', '');
INSERT INTO persons VALUES (1013, 'SAY', 'KOHLEN ANGELO', 'PEREZ', '');
INSERT INTO persons VALUES (1014, 'ADRIANO', 'JAMES PATRICK', 'DAVID', '');
INSERT INTO persons VALUES (1015, 'SERRANO', 'MICHAEL', 'DIONISIO', '');
INSERT INTO persons VALUES (1016, 'CHOAPECK', 'MARIE ANTOINETTE', 'R', '');
INSERT INTO persons VALUES (1017, 'TURLA', 'ISAIAH EDWARD', 'G', '');
INSERT INTO persons VALUES (1018, 'MONCADA', 'DEAN ALVIN', 'BAJAMONDE', '');
INSERT INTO persons VALUES (1019, 'EVANGELISTA', 'JOHN EROL', 'MILANO', '');
INSERT INTO persons VALUES (1020, 'ASIS', 'KRYSTIAN VIEL', 'CABUGAO', '');
INSERT INTO persons VALUES (1021, 'CLAVECILLA', 'VANESSA VIVIEN', 'FRANCISCO', '');
INSERT INTO persons VALUES (1022, 'RONDON', 'RYAN ODYLON', 'GAZMEN', '');
INSERT INTO persons VALUES (1023, 'ARANAS', 'CHRISTIAN JOY', 'MARQUEZ', '');
INSERT INTO persons VALUES (1024, 'AGUILAR', 'JENNIFER', 'RAMOS', '');
INSERT INTO persons VALUES (1025, 'CUEVAS', 'SARAH', 'BERNABE', '');
INSERT INTO persons VALUES (1026, 'PASCUAL', 'JAYVEE ELJOHN', 'ACABO', '');
INSERT INTO persons VALUES (1027, 'TORRES', 'DANAH VERONICA', 'PADILLA', '');
INSERT INTO persons VALUES (1028, 'BISAIS', 'APRYL ROSE', 'LABAYOG', '');
INSERT INTO persons VALUES (1029, 'CHUA', 'TED GUILLANO', 'SY', '');
INSERT INTO persons VALUES (1030, 'CRUZ', 'IVAN KRISTEL', 'POLICARPIO', '');
INSERT INTO persons VALUES (1031, 'AQUINO', 'CHLOEBELLE', 'RAMOS', '');
INSERT INTO persons VALUES (1032, 'YUTUC', 'DANIEL', 'LALAGUNA', '');
INSERT INTO persons VALUES (1033, 'DEL ROSARIO', 'BENJIE', 'REYES', '');
INSERT INTO persons VALUES (1034, 'RAMOS', 'ANNA CLARISSA', 'BEATO', '');
INSERT INTO persons VALUES (1035, 'REYES', 'CHARMAILENE', 'CAPILI', '');
INSERT INTO persons VALUES (1036, 'ABANTO', 'JEANELLE', 'ESGUERRA', '');
INSERT INTO persons VALUES (1037, 'BONDOC', 'ROD XANDER', 'RIVERA', '');
INSERT INTO persons VALUES (1038, 'TACATA', 'NERISSA MONICA', 'DE GUZMAN', '');
INSERT INTO persons VALUES (1039, 'RABE', 'REZELEE', 'AQUINO', '');
INSERT INTO persons VALUES (1040, 'DECENA', 'BERLYN ANNE', 'ARAGON', '');
INSERT INTO persons VALUES (1041, 'DIMLA', 'KARL LEN MAE', 'BALDOMERO', '');
INSERT INTO persons VALUES (1042, 'SANCHEZ', 'ZIV YVES', 'MONTOYA', '');
INSERT INTO persons VALUES (1043, 'LITIMCO', 'CZELINA ELLAINE', 'ONG', '');
INSERT INTO persons VALUES (1044, 'GUILLEN', 'NEIL DAVID', 'BALGOS', '');
INSERT INTO persons VALUES (1045, 'SOMOSON', 'LOU MERLENETTE', 'BAUTISTA', '');
INSERT INTO persons VALUES (1046, 'TALAVERA', 'RHIZA MAE', 'GO', '');
INSERT INTO persons VALUES (1047, 'CANOY', 'JOHN GABRIEL', 'ERUM', '');
INSERT INTO persons VALUES (1048, 'CHUA', 'RALPH JACOB', 'ANG', '');
INSERT INTO persons VALUES (1049, 'EALA', 'MARIA AZRIEL THERESE', 'DESTUA', '');
INSERT INTO persons VALUES (1050, 'AYAG', 'DANIELLE ANNE', 'FRANCISCO', '');
INSERT INTO persons VALUES (1051, 'DE VILLA', 'RACHEL', 'LUNA', '');
INSERT INTO persons VALUES (1052, 'JAYMALIN', 'JEAN DOMINIQUE', 'BERNAL', '');
INSERT INTO persons VALUES (1053, 'LEGASPI', 'CHARMAINE PAMELA', 'ABERCA', '');
INSERT INTO persons VALUES (1054, 'LIBUNAO', 'ARIANNE FRANCESCA', 'QUIJANO', '');
INSERT INTO persons VALUES (1055, 'REGENCIA', 'FELIX ARAM', 'JEREMIAS', '');
INSERT INTO persons VALUES (1056, 'SANTI', 'NATHAN LEMUEL', 'GO', '');
INSERT INTO persons VALUES (1057, 'LEONOR', 'WENDY GENEVA', 'SANTOS', '');
INSERT INTO persons VALUES (1058, 'LUNA', 'MARA ISSABEL', 'SUPLICO', '');
INSERT INTO persons VALUES (1059, 'SIRIBAN', 'MA LORENA JOY', 'ASCUTIA', '');
INSERT INTO persons VALUES (1060, 'LEGASPI', 'MISHAEL MAE', 'CRUZ', '');
INSERT INTO persons VALUES (1061, 'SUN', 'HANNAH ERIKA', 'YAP', '');
INSERT INTO persons VALUES (1062, 'PARRENO', 'NICOLE ANNE', 'KAHN', '');
INSERT INTO persons VALUES (1063, 'BULANHAGUI', 'KEVIN DAVID', 'BALANAY', '');
INSERT INTO persons VALUES (1064, 'MONCADA', 'JULIA NINA', 'SOMERA', '');
INSERT INTO persons VALUES (1065, 'IBANEZ', 'SEBASTIAN', 'CANLAS', '');
INSERT INTO persons VALUES (1066, 'COLA', 'VERNA KATRIN', 'BEDUYA', '');
INSERT INTO persons VALUES (1067, 'SANTOS', 'MARIA RUBYLISA', 'AREVALO', '');
INSERT INTO persons VALUES (1068, 'YECLA', 'NORVIN', 'GARCIA', '');
INSERT INTO persons VALUES (1069, 'CASTANEDA', 'ANNA MANNELLI', 'ESPIRITU', '');
INSERT INTO persons VALUES (1070, 'FOJAS', 'EDGAR ALLAN', 'GO', '');
INSERT INTO persons VALUES (1071, 'DELA CRUZ', 'EMERY', 'FABRO', '');
INSERT INTO persons VALUES (1072, 'SADORNAS', 'JON PERCIVAL', 'GARCIA', '');
INSERT INTO persons VALUES (1073, 'VILLANUEVA', 'MARY GRACE', 'AYENTO', '');
INSERT INTO persons VALUES (1074, 'ESGUERRA', 'JOSE MARI', 'MARCELO', '');
INSERT INTO persons VALUES (1075, 'SY', 'KYLE BENEDICT', 'GUERRERO', '');
INSERT INTO persons VALUES (1076, 'TORRES', 'LUIS ANTONIO', 'PEREZ', '');
INSERT INTO persons VALUES (1077, 'TONG', 'MAYNARD JEFFERSON', 'ZHUANG', '');
INSERT INTO persons VALUES (1078, 'DATU', 'PATRICH PAOLO', 'BONETE', '');
INSERT INTO persons VALUES (1079, 'PEREA', 'EMMANUEL', 'LOYOLA', '');
INSERT INTO persons VALUES (1080, 'BALOY', 'MICHAEL JOYSON', 'GERMAR', '');
INSERT INTO persons VALUES (1081, 'REAL', 'VICTORIA CASSANDRA', 'RUIVIVAR', '');
INSERT INTO persons VALUES (1082, 'MARTIJA', 'JASPER', 'ENRIQUEZ', '');
INSERT INTO persons VALUES (1083, 'OCHAVEZ', 'ARISA', 'CAAKBAY', '');
INSERT INTO persons VALUES (1084, 'AMORANTO', 'PAOLO', 'SISON', '');
INSERT INTO persons VALUES (1085, 'SAN ANTONIO', 'JAYVIC', 'PORTILLO', '');
INSERT INTO persons VALUES (1086, 'SARDONA', 'CATHERINE LORAINE', 'FESTIN', '');
INSERT INTO persons VALUES (1087, 'MENESES', 'ANGELO', 'CAL', '');
INSERT INTO persons VALUES (1088, 'AUSTRIA', 'DARRWIN DEAREST', 'CRISOSTOMO', '');
INSERT INTO persons VALUES (1089, 'BURGOS', 'ALVIN JOHN', 'MANLIGUEZ', '');
INSERT INTO persons VALUES (1090, 'MAGNO', 'JENNY', 'NARSOLIS', '');
INSERT INTO persons VALUES (1091, 'SAPASAP', 'RIC JANUS', 'OLIVER', '');
INSERT INTO persons VALUES (1092, 'QUILAB', 'FRANCIS MIGUEL', 'EVANGELISTA', '');
INSERT INTO persons VALUES (1093, 'PINEDA', 'RIZA RAE', 'ALDECOA', '');
INSERT INTO persons VALUES (1094, 'TAN', 'XYRIZ CZAR', 'PINEDA', '');
INSERT INTO persons VALUES (1095, 'DELAS PENAS', 'KRISTOFER', 'EMPUERTO', '');
INSERT INTO persons VALUES (1096, 'MANSOS', 'JOHN FRANCIS', 'LLAGAS', '');
INSERT INTO persons VALUES (1097, 'PANOPIO', 'GIRAH MAY', 'CHUA', '');
INSERT INTO persons VALUES (1098, 'LEGASPINA', 'CHRISLENE', 'BUGARIN', '');
INSERT INTO persons VALUES (1099, 'RIVERA', 'DON JOSEPH', 'TIANGCO', '');
INSERT INTO persons VALUES (1100, 'RUBIO', 'MARY GRACE', 'TALAN', '');
INSERT INTO persons VALUES (1101, 'LEONOR', 'CHARLES TIMOTHY', 'DEL ROSARIO', '');
INSERT INTO persons VALUES (1102, 'CABUHAT', 'JOHN JOEL', 'URBISTONDO', '');
INSERT INTO persons VALUES (1103, 'MARANAN', 'GENIE LINN', 'PADILLA', '');
INSERT INTO persons VALUES (1104, 'WANG', 'CASSANDRA LEIGH', 'LACASTA', '');
INSERT INTO persons VALUES (1105, 'YU', 'GLADYS JOYCE', 'OCAP', '');
INSERT INTO persons VALUES (1106, 'TOMACRUZ', 'ARVIN JOHN', 'CRUZ', '');
INSERT INTO persons VALUES (1107, 'BALDUEZA', 'GYZELLE', 'EVANGELISTA', '');
INSERT INTO persons VALUES (1108, 'BATAC', 'JOSE EMMANUEL', 'DE JESUS', '');
INSERT INTO persons VALUES (1109, 'CUETO', 'JAN COLIN', 'OJEDA', '');
INSERT INTO persons VALUES (1110, 'RUBI', 'SHIELA PAULINE JOY', 'VERGARA', '');
INSERT INTO persons VALUES (1111, 'ALCARAZ', 'KEN GERARD', 'TECSON', '');
INSERT INTO persons VALUES (1112, 'DE LOS SANTOS', 'PAOLO MIGUEL', 'MACALINDONG', '');
INSERT INTO persons VALUES (1113, 'CHAVEZ', 'JOE-MAR', 'ORINDAY', '');
INSERT INTO persons VALUES (1114, 'PERALTA', 'PAOLO THOMAS', 'REYES', '');
INSERT INTO persons VALUES (1115, 'SANTOS', 'ALEXANDREI', 'GONZALES', '');
INSERT INTO persons VALUES (1116, 'MACAPINLAC', 'VERONICA', 'ALCARAZ', '');
INSERT INTO persons VALUES (1117, 'PACAPAC', 'DIANA MAE', 'CANLAS', '');
INSERT INTO persons VALUES (1118, 'DUNGCA', 'JOHN ALPERT', 'ANCHO', '');
INSERT INTO persons VALUES (1119, 'ZACARIAS', 'ROEL JEREMIAH', 'ALCANTARA', '');
INSERT INTO persons VALUES (1120, 'RICIO', 'DUSTIN EDRIC', 'LEGARDA', '');
INSERT INTO persons VALUES (1121, 'ARBAS', 'HARVEY IAN', 'SOLAYAO', '');
INSERT INTO persons VALUES (1122, 'SALVADOR', 'RAMON JOSE NILO', 'DELA VEGA', '');
INSERT INTO persons VALUES (1123, 'DORADO', 'JOHN PHILIP', 'URRIZA', '');
INSERT INTO persons VALUES (1124, 'DEATRAS', 'SHEALTIEL PAUL ROSSNERR', 'CALUAG', '');
INSERT INTO persons VALUES (1125, 'CAPACILLO', 'JULES ALBERT', 'BERINGUELA', '');
INSERT INTO persons VALUES (1126, 'SALAMANCA', 'KYLA MARIE', 'G.', '');
INSERT INTO persons VALUES (1127, 'AVE', 'ARMOND', 'C.', '');
INSERT INTO persons VALUES (1128, 'CALARANAN', 'MICHAEL KEVIN', 'PONTE', '');
INSERT INTO persons VALUES (1129, 'DOCTOR', 'JET LAWRENCE', 'PARONE', '');
INSERT INTO persons VALUES (1130, 'ANG', 'RITZ DANIEL', 'CATAMPATAN', '');
INSERT INTO persons VALUES (1131, 'FORMES', 'RAFAEL GERARD', 'DELA CRUZ', '');


--
-- Name: persons_personid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('persons_personid_seq', 1131, true);


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

INSERT INTO studentclasses VALUES (17958, 3979, 2326, 6);
INSERT INTO studentclasses VALUES (17959, 3979, 2327, 7);
INSERT INTO studentclasses VALUES (17960, 3979, 2328, 7);
INSERT INTO studentclasses VALUES (17961, 3979, 2329, 6);
INSERT INTO studentclasses VALUES (17962, 3979, 2330, 4);
INSERT INTO studentclasses VALUES (17963, 3979, 2331, 3);
INSERT INTO studentclasses VALUES (17964, 3979, 2332, 1);
INSERT INTO studentclasses VALUES (17965, 3980, 2333, 4);
INSERT INTO studentclasses VALUES (17966, 3980, 2334, 5);
INSERT INTO studentclasses VALUES (17967, 3980, 2335, 6);
INSERT INTO studentclasses VALUES (17968, 3980, 2336, 4);
INSERT INTO studentclasses VALUES (17969, 3980, 2337, 3);
INSERT INTO studentclasses VALUES (17970, 3981, 2338, 10);
INSERT INTO studentclasses VALUES (17971, 3981, 2339, 11);
INSERT INTO studentclasses VALUES (17972, 3981, 2340, 9);
INSERT INTO studentclasses VALUES (17973, 3981, 2341, 8);
INSERT INTO studentclasses VALUES (17974, 3981, 2342, 11);
INSERT INTO studentclasses VALUES (17975, 3982, 2343, 3);
INSERT INTO studentclasses VALUES (17976, 3982, 2344, 9);
INSERT INTO studentclasses VALUES (17977, 3983, 2345, 7);
INSERT INTO studentclasses VALUES (17978, 3983, 2346, 9);
INSERT INTO studentclasses VALUES (17979, 3983, 2347, 13);
INSERT INTO studentclasses VALUES (17980, 3983, 2348, 10);
INSERT INTO studentclasses VALUES (17981, 3983, 2349, 6);
INSERT INTO studentclasses VALUES (17982, 3984, 2350, 13);
INSERT INTO studentclasses VALUES (17983, 3984, 2351, 9);
INSERT INTO studentclasses VALUES (17984, 3984, 2352, 11);
INSERT INTO studentclasses VALUES (17985, 3984, 2353, 11);
INSERT INTO studentclasses VALUES (17986, 3984, 2354, 9);
INSERT INTO studentclasses VALUES (17987, 3984, 2355, 11);
INSERT INTO studentclasses VALUES (17988, 3985, 2356, 6);
INSERT INTO studentclasses VALUES (17989, 3985, 2357, 5);
INSERT INTO studentclasses VALUES (17990, 3986, 2358, 9);
INSERT INTO studentclasses VALUES (17991, 3986, 2359, 6);
INSERT INTO studentclasses VALUES (17992, 3986, 2360, 11);
INSERT INTO studentclasses VALUES (17993, 3986, 2361, 9);
INSERT INTO studentclasses VALUES (17994, 3986, 2362, 5);
INSERT INTO studentclasses VALUES (17995, 3987, 2363, 6);
INSERT INTO studentclasses VALUES (17996, 3987, 2364, 9);
INSERT INTO studentclasses VALUES (17997, 3987, 2365, 6);
INSERT INTO studentclasses VALUES (17998, 3987, 2366, 8);
INSERT INTO studentclasses VALUES (17999, 3987, 2367, 3);
INSERT INTO studentclasses VALUES (18000, 3988, 2368, 7);
INSERT INTO studentclasses VALUES (18001, 3988, 2369, 6);
INSERT INTO studentclasses VALUES (18002, 3988, 2370, 5);
INSERT INTO studentclasses VALUES (18003, 3988, 2371, 6);
INSERT INTO studentclasses VALUES (18004, 3988, 2372, 6);
INSERT INTO studentclasses VALUES (18005, 3989, 2373, 9);
INSERT INTO studentclasses VALUES (18006, 3989, 2374, 8);
INSERT INTO studentclasses VALUES (18007, 3989, 2375, 10);
INSERT INTO studentclasses VALUES (18008, 3990, 2376, 5);
INSERT INTO studentclasses VALUES (18009, 3990, 2377, 9);
INSERT INTO studentclasses VALUES (18010, 3990, 2378, 7);
INSERT INTO studentclasses VALUES (18011, 3990, 2379, 7);
INSERT INTO studentclasses VALUES (18012, 3990, 2380, 11);
INSERT INTO studentclasses VALUES (18013, 3991, 2381, 7);
INSERT INTO studentclasses VALUES (18014, 3991, 2382, 9);
INSERT INTO studentclasses VALUES (18015, 3991, 2383, 3);
INSERT INTO studentclasses VALUES (18016, 3991, 2384, 6);
INSERT INTO studentclasses VALUES (18017, 3991, 2385, 9);
INSERT INTO studentclasses VALUES (18018, 3992, 2386, 14);
INSERT INTO studentclasses VALUES (18019, 3992, 2387, 9);
INSERT INTO studentclasses VALUES (18020, 3992, 2388, 10);
INSERT INTO studentclasses VALUES (18021, 3992, 2389, 5);
INSERT INTO studentclasses VALUES (18022, 3992, 2390, 14);
INSERT INTO studentclasses VALUES (18023, 3993, 2391, 7);
INSERT INTO studentclasses VALUES (18024, 3993, 2392, 14);
INSERT INTO studentclasses VALUES (18025, 3993, 2393, 9);
INSERT INTO studentclasses VALUES (18026, 3993, 2394, 14);
INSERT INTO studentclasses VALUES (18027, 3993, 2395, 5);
INSERT INTO studentclasses VALUES (18028, 3993, 2396, 5);
INSERT INTO studentclasses VALUES (18029, 3994, 2397, 9);
INSERT INTO studentclasses VALUES (18030, 3994, 2398, 8);
INSERT INTO studentclasses VALUES (18031, 3994, 2399, 9);
INSERT INTO studentclasses VALUES (18032, 3994, 2400, 4);
INSERT INTO studentclasses VALUES (18033, 3994, 2401, 7);
INSERT INTO studentclasses VALUES (18034, 3995, 2402, 12);
INSERT INTO studentclasses VALUES (18035, 3995, 2403, 7);
INSERT INTO studentclasses VALUES (18036, 3995, 2404, 5);
INSERT INTO studentclasses VALUES (18037, 3995, 2405, 9);
INSERT INTO studentclasses VALUES (18038, 3995, 2406, 14);
INSERT INTO studentclasses VALUES (18039, 3996, 2407, 14);
INSERT INTO studentclasses VALUES (18040, 3996, 2408, 9);
INSERT INTO studentclasses VALUES (18041, 3996, 2409, 6);
INSERT INTO studentclasses VALUES (18042, 3996, 2410, 6);
INSERT INTO studentclasses VALUES (18043, 3996, 2411, 12);
INSERT INTO studentclasses VALUES (18044, 3997, 2412, 12);
INSERT INTO studentclasses VALUES (18045, 3998, 2413, 5);
INSERT INTO studentclasses VALUES (18046, 3998, 2414, 4);
INSERT INTO studentclasses VALUES (18047, 3998, 2415, 13);
INSERT INTO studentclasses VALUES (18048, 3998, 2416, 4);
INSERT INTO studentclasses VALUES (18049, 3998, 2417, 9);
INSERT INTO studentclasses VALUES (18050, 3998, 2418, 9);
INSERT INTO studentclasses VALUES (18051, 3999, 2419, 11);
INSERT INTO studentclasses VALUES (18052, 3999, 2420, 9);
INSERT INTO studentclasses VALUES (18053, 3999, 2421, 11);
INSERT INTO studentclasses VALUES (18054, 3999, 2422, 11);
INSERT INTO studentclasses VALUES (18055, 3999, 2423, 11);
INSERT INTO studentclasses VALUES (18056, 4000, 2424, 13);
INSERT INTO studentclasses VALUES (18057, 4000, 2425, 9);
INSERT INTO studentclasses VALUES (18058, 4000, 2426, 9);
INSERT INTO studentclasses VALUES (18059, 4000, 2427, 9);
INSERT INTO studentclasses VALUES (18060, 4000, 2428, 5);
INSERT INTO studentclasses VALUES (18061, 4001, 2429, 9);
INSERT INTO studentclasses VALUES (18062, 4001, 2430, 6);
INSERT INTO studentclasses VALUES (18063, 4001, 2431, 4);
INSERT INTO studentclasses VALUES (18064, 4001, 2432, 2);
INSERT INTO studentclasses VALUES (18065, 4001, 2433, 2);
INSERT INTO studentclasses VALUES (18066, 4002, 2434, 6);
INSERT INTO studentclasses VALUES (18067, 4003, 2435, 8);
INSERT INTO studentclasses VALUES (18068, 4004, 2436, 5);
INSERT INTO studentclasses VALUES (18069, 4004, 2437, 5);
INSERT INTO studentclasses VALUES (18070, 4005, 2438, 10);
INSERT INTO studentclasses VALUES (18071, 4006, 2439, 4);
INSERT INTO studentclasses VALUES (18072, 4006, 2440, 9);
INSERT INTO studentclasses VALUES (18073, 4006, 2441, 8);
INSERT INTO studentclasses VALUES (18074, 4006, 2442, 11);
INSERT INTO studentclasses VALUES (18075, 4006, 2443, 8);
INSERT INTO studentclasses VALUES (18076, 4006, 2444, 9);
INSERT INTO studentclasses VALUES (18077, 4007, 2445, 9);
INSERT INTO studentclasses VALUES (18078, 4007, 2446, 4);
INSERT INTO studentclasses VALUES (18079, 4007, 2447, 9);
INSERT INTO studentclasses VALUES (18080, 4007, 2448, 11);
INSERT INTO studentclasses VALUES (18081, 4007, 2449, 9);
INSERT INTO studentclasses VALUES (18082, 4007, 2443, 11);
INSERT INTO studentclasses VALUES (18083, 4008, 2450, 12);
INSERT INTO studentclasses VALUES (18084, 4008, 2451, 7);
INSERT INTO studentclasses VALUES (18085, 4008, 2452, 11);
INSERT INTO studentclasses VALUES (18086, 4008, 2453, 13);
INSERT INTO studentclasses VALUES (18087, 4008, 2454, 6);
INSERT INTO studentclasses VALUES (18088, 4009, 2455, 12);
INSERT INTO studentclasses VALUES (18089, 4009, 2456, 6);
INSERT INTO studentclasses VALUES (18090, 4009, 2457, 7);
INSERT INTO studentclasses VALUES (18091, 4009, 2458, 7);
INSERT INTO studentclasses VALUES (18092, 4009, 2459, 7);
INSERT INTO studentclasses VALUES (18093, 4010, 2460, 4);
INSERT INTO studentclasses VALUES (18094, 4010, 2461, 7);
INSERT INTO studentclasses VALUES (18095, 4010, 2462, 1);
INSERT INTO studentclasses VALUES (18096, 4010, 2463, 4);
INSERT INTO studentclasses VALUES (18097, 4010, 2464, 1);
INSERT INTO studentclasses VALUES (18098, 4011, 2465, 7);
INSERT INTO studentclasses VALUES (18099, 4011, 2466, 4);
INSERT INTO studentclasses VALUES (18100, 4011, 2467, 8);
INSERT INTO studentclasses VALUES (18101, 4011, 2468, 1);
INSERT INTO studentclasses VALUES (18102, 4011, 2469, 7);
INSERT INTO studentclasses VALUES (18103, 4011, 2470, 9);
INSERT INTO studentclasses VALUES (18104, 4012, 2471, 12);
INSERT INTO studentclasses VALUES (18105, 4012, 2472, 4);
INSERT INTO studentclasses VALUES (18106, 4012, 2473, 5);
INSERT INTO studentclasses VALUES (18107, 4012, 2467, 11);
INSERT INTO studentclasses VALUES (18108, 4012, 2469, 8);
INSERT INTO studentclasses VALUES (18109, 4012, 2470, 9);
INSERT INTO studentclasses VALUES (18110, 4013, 2474, 11);
INSERT INTO studentclasses VALUES (18111, 4013, 2475, 11);
INSERT INTO studentclasses VALUES (18112, 4013, 2476, 11);
INSERT INTO studentclasses VALUES (18113, 4013, 2477, 11);
INSERT INTO studentclasses VALUES (18114, 4013, 2478, 9);
INSERT INTO studentclasses VALUES (18115, 4013, 2479, 11);
INSERT INTO studentclasses VALUES (18116, 4014, 2480, 5);
INSERT INTO studentclasses VALUES (18117, 4014, 2481, 11);
INSERT INTO studentclasses VALUES (18118, 4014, 2482, 11);
INSERT INTO studentclasses VALUES (18119, 4014, 2483, 9);
INSERT INTO studentclasses VALUES (18120, 4014, 2479, 11);
INSERT INTO studentclasses VALUES (18121, 4015, 2484, 9);
INSERT INTO studentclasses VALUES (18122, 4015, 2485, 6);
INSERT INTO studentclasses VALUES (18123, 4015, 2486, 13);
INSERT INTO studentclasses VALUES (18124, 4015, 2487, 5);
INSERT INTO studentclasses VALUES (18125, 4015, 2488, 2);
INSERT INTO studentclasses VALUES (18126, 4016, 2489, 4);
INSERT INTO studentclasses VALUES (18127, 4016, 2490, 7);
INSERT INTO studentclasses VALUES (18128, 4017, 2491, 2);
INSERT INTO studentclasses VALUES (18129, 4017, 2492, 4);
INSERT INTO studentclasses VALUES (18130, 4018, 2493, 14);
INSERT INTO studentclasses VALUES (18131, 4019, 2494, 6);
INSERT INTO studentclasses VALUES (18132, 4020, 2495, 13);
INSERT INTO studentclasses VALUES (18133, 4021, 2496, 6);
INSERT INTO studentclasses VALUES (18134, 4021, 2497, 9);
INSERT INTO studentclasses VALUES (18135, 4021, 2498, 9);
INSERT INTO studentclasses VALUES (18136, 4021, 2499, 6);
INSERT INTO studentclasses VALUES (18137, 4021, 2500, 2);
INSERT INTO studentclasses VALUES (18138, 4021, 2501, 5);
INSERT INTO studentclasses VALUES (18139, 4021, 2502, 6);
INSERT INTO studentclasses VALUES (18140, 4022, 2503, 11);
INSERT INTO studentclasses VALUES (18141, 4022, 2504, 5);
INSERT INTO studentclasses VALUES (18142, 4022, 2498, 5);
INSERT INTO studentclasses VALUES (18143, 4022, 2505, 6);
INSERT INTO studentclasses VALUES (18144, 4022, 2506, 6);
INSERT INTO studentclasses VALUES (18145, 4022, 2507, 9);
INSERT INTO studentclasses VALUES (18146, 4023, 2508, 6);
INSERT INTO studentclasses VALUES (18147, 4023, 2509, 5);
INSERT INTO studentclasses VALUES (18148, 4023, 2510, 11);
INSERT INTO studentclasses VALUES (18149, 4023, 2511, 11);
INSERT INTO studentclasses VALUES (18150, 4023, 2512, 3);
INSERT INTO studentclasses VALUES (18151, 4023, 2513, 9);
INSERT INTO studentclasses VALUES (18152, 4024, 2514, 8);
INSERT INTO studentclasses VALUES (18153, 4024, 2515, 11);
INSERT INTO studentclasses VALUES (18154, 4024, 2516, 6);
INSERT INTO studentclasses VALUES (18155, 4024, 2517, 12);
INSERT INTO studentclasses VALUES (18156, 4024, 2513, 9);
INSERT INTO studentclasses VALUES (18157, 4024, 2507, 7);
INSERT INTO studentclasses VALUES (18158, 4025, 2518, 4);
INSERT INTO studentclasses VALUES (18159, 4025, 2519, 8);
INSERT INTO studentclasses VALUES (18160, 4025, 2520, 7);
INSERT INTO studentclasses VALUES (18161, 4025, 2517, 1);
INSERT INTO studentclasses VALUES (18162, 4025, 2521, 7);
INSERT INTO studentclasses VALUES (18163, 4026, 2522, 7);
INSERT INTO studentclasses VALUES (18164, 4026, 2523, 5);
INSERT INTO studentclasses VALUES (18165, 4026, 2524, 4);
INSERT INTO studentclasses VALUES (18166, 4026, 2525, 3);
INSERT INTO studentclasses VALUES (18167, 4026, 2526, 4);
INSERT INTO studentclasses VALUES (18168, 4027, 2527, 6);
INSERT INTO studentclasses VALUES (18169, 4027, 2528, 4);
INSERT INTO studentclasses VALUES (18170, 4027, 2529, 4);
INSERT INTO studentclasses VALUES (18171, 4027, 2530, 8);
INSERT INTO studentclasses VALUES (18172, 4027, 2531, 2);
INSERT INTO studentclasses VALUES (18173, 4028, 2532, 3);
INSERT INTO studentclasses VALUES (18174, 4028, 2533, 14);
INSERT INTO studentclasses VALUES (18175, 4028, 2534, 9);
INSERT INTO studentclasses VALUES (18176, 4028, 2535, 9);
INSERT INTO studentclasses VALUES (18177, 4028, 2536, 12);
INSERT INTO studentclasses VALUES (18178, 4028, 2537, 7);
INSERT INTO studentclasses VALUES (18179, 4028, 2538, 2);
INSERT INTO studentclasses VALUES (18180, 4029, 2539, 8);
INSERT INTO studentclasses VALUES (18181, 4029, 2540, 5);
INSERT INTO studentclasses VALUES (18182, 4029, 2541, 9);
INSERT INTO studentclasses VALUES (18183, 4029, 2536, 6);
INSERT INTO studentclasses VALUES (18184, 4029, 2542, 6);
INSERT INTO studentclasses VALUES (18185, 4029, 2543, 2);
INSERT INTO studentclasses VALUES (18186, 4029, 2544, 3);
INSERT INTO studentclasses VALUES (18187, 4030, 2545, 6);
INSERT INTO studentclasses VALUES (18188, 4030, 2546, 5);
INSERT INTO studentclasses VALUES (18189, 4030, 2547, 5);
INSERT INTO studentclasses VALUES (18190, 4030, 2548, 10);
INSERT INTO studentclasses VALUES (18191, 4030, 2549, 8);
INSERT INTO studentclasses VALUES (18192, 4030, 2550, 7);
INSERT INTO studentclasses VALUES (18193, 4031, 2551, 12);
INSERT INTO studentclasses VALUES (18194, 4031, 2552, 10);
INSERT INTO studentclasses VALUES (18195, 4031, 2553, 4);
INSERT INTO studentclasses VALUES (18196, 4031, 2554, 9);
INSERT INTO studentclasses VALUES (18197, 4031, 2555, 6);
INSERT INTO studentclasses VALUES (18198, 4031, 2556, 5);
INSERT INTO studentclasses VALUES (18199, 4032, 2557, 13);
INSERT INTO studentclasses VALUES (18200, 4032, 2558, 11);
INSERT INTO studentclasses VALUES (18201, 4032, 2559, 9);
INSERT INTO studentclasses VALUES (18202, 4032, 2560, 6);
INSERT INTO studentclasses VALUES (18203, 4032, 2561, 4);
INSERT INTO studentclasses VALUES (18204, 4033, 2539, 8);
INSERT INTO studentclasses VALUES (18205, 4033, 2562, 7);
INSERT INTO studentclasses VALUES (18206, 4033, 2563, 5);
INSERT INTO studentclasses VALUES (18207, 4033, 2564, 4);
INSERT INTO studentclasses VALUES (18208, 4033, 2565, 1);
INSERT INTO studentclasses VALUES (18209, 4034, 2566, 1);
INSERT INTO studentclasses VALUES (18210, 4034, 2567, 2);
INSERT INTO studentclasses VALUES (18211, 4035, 2568, 5);
INSERT INTO studentclasses VALUES (18212, 4036, 2569, 6);
INSERT INTO studentclasses VALUES (18213, 4037, 2570, 3);
INSERT INTO studentclasses VALUES (18214, 4037, 2571, 6);
INSERT INTO studentclasses VALUES (18215, 4038, 2572, 14);
INSERT INTO studentclasses VALUES (18216, 4038, 2573, 8);
INSERT INTO studentclasses VALUES (18217, 4038, 2574, 10);
INSERT INTO studentclasses VALUES (18218, 4038, 2575, 6);
INSERT INTO studentclasses VALUES (18219, 4039, 2576, 2);
INSERT INTO studentclasses VALUES (18220, 4039, 2577, 3);
INSERT INTO studentclasses VALUES (18221, 4039, 2572, 5);
INSERT INTO studentclasses VALUES (18222, 4039, 2578, 5);
INSERT INTO studentclasses VALUES (18223, 4039, 2579, 5);
INSERT INTO studentclasses VALUES (18224, 4039, 2580, 6);
INSERT INTO studentclasses VALUES (18225, 4039, 2581, 1);
INSERT INTO studentclasses VALUES (18226, 4040, 2582, 11);
INSERT INTO studentclasses VALUES (18227, 4040, 2583, 11);
INSERT INTO studentclasses VALUES (18228, 4040, 2584, 8);
INSERT INTO studentclasses VALUES (18229, 4040, 2585, 13);
INSERT INTO studentclasses VALUES (18230, 4040, 2586, 9);
INSERT INTO studentclasses VALUES (18231, 4041, 2587, 4);
INSERT INTO studentclasses VALUES (18232, 4041, 2588, 8);
INSERT INTO studentclasses VALUES (18233, 4041, 2589, 6);
INSERT INTO studentclasses VALUES (18234, 4041, 2590, 9);
INSERT INTO studentclasses VALUES (18235, 4041, 2591, 3);
INSERT INTO studentclasses VALUES (18236, 4042, 2592, 5);
INSERT INTO studentclasses VALUES (18237, 4042, 2593, 5);
INSERT INTO studentclasses VALUES (18238, 4042, 2594, 9);
INSERT INTO studentclasses VALUES (18239, 4042, 2595, 2);
INSERT INTO studentclasses VALUES (18240, 4042, 2596, 5);
INSERT INTO studentclasses VALUES (18241, 4043, 2597, 3);
INSERT INTO studentclasses VALUES (18242, 4043, 2598, 11);
INSERT INTO studentclasses VALUES (18243, 4043, 2599, 2);
INSERT INTO studentclasses VALUES (18244, 4043, 2600, 3);
INSERT INTO studentclasses VALUES (18245, 4043, 2601, 5);
INSERT INTO studentclasses VALUES (18246, 4044, 2602, 2);
INSERT INTO studentclasses VALUES (18247, 4044, 2603, 8);
INSERT INTO studentclasses VALUES (18248, 4044, 2604, 1);
INSERT INTO studentclasses VALUES (18249, 4044, 2605, 3);
INSERT INTO studentclasses VALUES (18250, 4044, 2601, 6);
INSERT INTO studentclasses VALUES (18251, 4045, 2597, 4);
INSERT INTO studentclasses VALUES (18252, 4045, 2603, 9);
INSERT INTO studentclasses VALUES (18253, 4045, 2606, 1);
INSERT INTO studentclasses VALUES (18254, 4045, 2607, 7);
INSERT INTO studentclasses VALUES (18255, 4045, 2608, 7);
INSERT INTO studentclasses VALUES (18256, 4046, 2609, 5);
INSERT INTO studentclasses VALUES (18257, 4046, 2610, 10);
INSERT INTO studentclasses VALUES (18258, 4046, 2611, 5);
INSERT INTO studentclasses VALUES (18259, 4046, 2612, 5);
INSERT INTO studentclasses VALUES (18260, 4046, 2608, 1);
INSERT INTO studentclasses VALUES (18261, 4047, 2613, 7);
INSERT INTO studentclasses VALUES (18262, 4047, 2614, 9);
INSERT INTO studentclasses VALUES (18263, 4047, 2615, 6);
INSERT INTO studentclasses VALUES (18264, 4047, 2616, 3);
INSERT INTO studentclasses VALUES (18265, 4047, 2617, 2);
INSERT INTO studentclasses VALUES (18266, 4048, 2618, 14);
INSERT INTO studentclasses VALUES (18267, 4048, 2619, 14);
INSERT INTO studentclasses VALUES (18268, 4048, 2620, 9);
INSERT INTO studentclasses VALUES (18269, 4049, 2621, 4);
INSERT INTO studentclasses VALUES (18270, 4049, 2622, 7);
INSERT INTO studentclasses VALUES (18271, 4049, 2623, 8);
INSERT INTO studentclasses VALUES (18272, 4049, 2624, 4);
INSERT INTO studentclasses VALUES (18273, 4049, 2625, 12);
INSERT INTO studentclasses VALUES (18274, 4050, 2626, 2);
INSERT INTO studentclasses VALUES (18275, 4050, 2618, 14);
INSERT INTO studentclasses VALUES (18276, 4050, 2627, 8);
INSERT INTO studentclasses VALUES (18277, 4050, 2628, 1);
INSERT INTO studentclasses VALUES (18278, 4050, 2629, 2);
INSERT INTO studentclasses VALUES (18279, 4050, 2630, 4);
INSERT INTO studentclasses VALUES (18280, 4050, 2631, 1);
INSERT INTO studentclasses VALUES (18281, 4051, 2632, 13);
INSERT INTO studentclasses VALUES (18282, 4051, 2633, 9);
INSERT INTO studentclasses VALUES (18283, 4051, 2634, 11);
INSERT INTO studentclasses VALUES (18284, 4051, 2635, 9);
INSERT INTO studentclasses VALUES (18285, 4051, 2636, 9);
INSERT INTO studentclasses VALUES (18286, 4052, 2637, 8);
INSERT INTO studentclasses VALUES (18287, 4052, 2638, 6);
INSERT INTO studentclasses VALUES (18288, 4052, 2639, 9);
INSERT INTO studentclasses VALUES (18289, 4052, 2640, 3);
INSERT INTO studentclasses VALUES (18290, 4052, 2628, 6);
INSERT INTO studentclasses VALUES (18291, 4052, 2641, 5);
INSERT INTO studentclasses VALUES (18292, 4053, 2642, 6);
INSERT INTO studentclasses VALUES (18293, 4053, 2643, 11);
INSERT INTO studentclasses VALUES (18294, 4053, 2644, 4);
INSERT INTO studentclasses VALUES (18295, 4053, 2645, 4);
INSERT INTO studentclasses VALUES (18296, 4053, 2646, 6);
INSERT INTO studentclasses VALUES (18297, 4054, 2647, 8);
INSERT INTO studentclasses VALUES (18298, 4054, 2648, 4);
INSERT INTO studentclasses VALUES (18299, 4054, 2649, 8);
INSERT INTO studentclasses VALUES (18300, 4054, 2650, 5);
INSERT INTO studentclasses VALUES (18301, 4054, 2651, 8);
INSERT INTO studentclasses VALUES (18302, 4055, 2652, 5);
INSERT INTO studentclasses VALUES (18303, 4055, 2653, 3);
INSERT INTO studentclasses VALUES (18304, 4055, 2654, 3);
INSERT INTO studentclasses VALUES (18305, 4055, 2655, 9);
INSERT INTO studentclasses VALUES (18306, 4055, 2656, 4);
INSERT INTO studentclasses VALUES (18307, 4056, 2657, 3);
INSERT INTO studentclasses VALUES (18308, 4056, 2658, 9);
INSERT INTO studentclasses VALUES (18309, 4056, 2659, 6);
INSERT INTO studentclasses VALUES (18310, 4056, 2660, 4);
INSERT INTO studentclasses VALUES (18311, 4056, 2656, 5);
INSERT INTO studentclasses VALUES (18312, 4057, 2661, 5);
INSERT INTO studentclasses VALUES (18313, 4057, 2662, 5);
INSERT INTO studentclasses VALUES (18314, 4057, 2663, 4);
INSERT INTO studentclasses VALUES (18315, 4057, 2664, 7);
INSERT INTO studentclasses VALUES (18316, 4057, 2651, 2);
INSERT INTO studentclasses VALUES (18317, 4058, 2665, 9);
INSERT INTO studentclasses VALUES (18318, 4058, 2666, 3);
INSERT INTO studentclasses VALUES (18319, 4058, 2667, 2);
INSERT INTO studentclasses VALUES (18320, 4058, 2660, 4);
INSERT INTO studentclasses VALUES (18321, 4058, 2656, 3);
INSERT INTO studentclasses VALUES (18322, 4059, 2668, 14);
INSERT INTO studentclasses VALUES (18323, 4060, 2669, 9);
INSERT INTO studentclasses VALUES (18324, 4061, 2670, 4);
INSERT INTO studentclasses VALUES (18325, 4062, 2671, 9);
INSERT INTO studentclasses VALUES (18326, 4063, 2672, 8);
INSERT INTO studentclasses VALUES (18327, 4064, 2673, 7);
INSERT INTO studentclasses VALUES (18328, 4065, 2674, 8);
INSERT INTO studentclasses VALUES (18329, 4066, 2675, 2);
INSERT INTO studentclasses VALUES (18330, 4066, 2676, 4);
INSERT INTO studentclasses VALUES (18331, 4067, 2677, 14);
INSERT INTO studentclasses VALUES (18332, 4067, 2678, 4);
INSERT INTO studentclasses VALUES (18333, 4067, 2679, 7);
INSERT INTO studentclasses VALUES (18334, 4067, 2680, 11);
INSERT INTO studentclasses VALUES (18335, 4067, 2681, 8);
INSERT INTO studentclasses VALUES (18336, 4067, 2682, 12);
INSERT INTO studentclasses VALUES (18337, 4067, 2683, 11);
INSERT INTO studentclasses VALUES (18338, 4067, 2684, 1);
INSERT INTO studentclasses VALUES (18339, 4068, 2685, 8);
INSERT INTO studentclasses VALUES (18340, 4068, 2686, 11);
INSERT INTO studentclasses VALUES (18341, 4068, 2681, 8);
INSERT INTO studentclasses VALUES (18342, 4068, 2687, 12);
INSERT INTO studentclasses VALUES (18343, 4068, 2688, 2);
INSERT INTO studentclasses VALUES (18344, 4068, 2689, 5);
INSERT INTO studentclasses VALUES (18345, 4068, 2690, 14);
INSERT INTO studentclasses VALUES (18346, 4068, 2691, 4);
INSERT INTO studentclasses VALUES (18347, 4069, 2692, 9);
INSERT INTO studentclasses VALUES (18348, 4069, 2693, 9);
INSERT INTO studentclasses VALUES (18349, 4069, 2677, 14);
INSERT INTO studentclasses VALUES (18350, 4069, 2678, 5);
INSERT INTO studentclasses VALUES (18351, 4069, 2694, 9);
INSERT INTO studentclasses VALUES (18352, 4069, 2682, 8);
INSERT INTO studentclasses VALUES (18353, 4069, 2683, 7);
INSERT INTO studentclasses VALUES (18354, 4070, 2677, 14);
INSERT INTO studentclasses VALUES (18355, 4070, 2678, 3);
INSERT INTO studentclasses VALUES (18356, 4070, 2695, 2);
INSERT INTO studentclasses VALUES (18357, 4070, 2680, 9);
INSERT INTO studentclasses VALUES (18358, 4070, 2696, 9);
INSERT INTO studentclasses VALUES (18359, 4070, 2697, 9);
INSERT INTO studentclasses VALUES (18360, 4070, 2691, 8);
INSERT INTO studentclasses VALUES (18361, 4071, 2698, 3);
INSERT INTO studentclasses VALUES (18362, 4071, 2699, 7);
INSERT INTO studentclasses VALUES (18363, 4071, 2700, 11);
INSERT INTO studentclasses VALUES (18364, 4071, 2701, 7);
INSERT INTO studentclasses VALUES (18365, 4072, 2702, 7);
INSERT INTO studentclasses VALUES (18366, 4072, 2703, 7);
INSERT INTO studentclasses VALUES (18367, 4072, 2704, 1);
INSERT INTO studentclasses VALUES (18368, 4072, 2705, 2);
INSERT INTO studentclasses VALUES (18369, 4072, 2706, 7);
INSERT INTO studentclasses VALUES (18370, 4073, 2707, 5);
INSERT INTO studentclasses VALUES (18371, 4073, 2708, 9);
INSERT INTO studentclasses VALUES (18372, 4073, 2709, 2);
INSERT INTO studentclasses VALUES (18373, 4073, 2710, 4);
INSERT INTO studentclasses VALUES (18374, 4073, 2711, 5);
INSERT INTO studentclasses VALUES (18375, 4074, 2712, 4);
INSERT INTO studentclasses VALUES (18376, 4074, 2713, 8);
INSERT INTO studentclasses VALUES (18377, 4074, 2714, 1);
INSERT INTO studentclasses VALUES (18378, 4074, 2706, 8);
INSERT INTO studentclasses VALUES (18379, 4075, 2715, 6);
INSERT INTO studentclasses VALUES (18380, 4075, 2716, 8);
INSERT INTO studentclasses VALUES (18381, 4075, 2717, 2);
INSERT INTO studentclasses VALUES (18382, 4075, 2718, 9);
INSERT INTO studentclasses VALUES (18383, 4076, 2719, 4);
INSERT INTO studentclasses VALUES (18384, 4076, 2720, 4);
INSERT INTO studentclasses VALUES (18385, 4076, 2721, 9);
INSERT INTO studentclasses VALUES (18386, 4076, 2722, 13);
INSERT INTO studentclasses VALUES (18387, 4077, 2723, 6);
INSERT INTO studentclasses VALUES (18388, 4077, 2724, 9);
INSERT INTO studentclasses VALUES (18389, 4077, 2725, 6);
INSERT INTO studentclasses VALUES (18390, 4077, 2726, 6);
INSERT INTO studentclasses VALUES (18391, 4077, 2706, 4);
INSERT INTO studentclasses VALUES (18392, 4078, 2727, 3);
INSERT INTO studentclasses VALUES (18393, 4078, 2728, 8);
INSERT INTO studentclasses VALUES (18394, 4078, 2703, 9);
INSERT INTO studentclasses VALUES (18395, 4078, 2729, 2);
INSERT INTO studentclasses VALUES (18396, 4078, 2711, 8);
INSERT INTO studentclasses VALUES (18397, 4079, 2730, 5);
INSERT INTO studentclasses VALUES (18398, 4079, 2731, 7);
INSERT INTO studentclasses VALUES (18399, 4079, 2732, 1);
INSERT INTO studentclasses VALUES (18400, 4079, 2709, 2);
INSERT INTO studentclasses VALUES (18401, 4079, 2733, 2);
INSERT INTO studentclasses VALUES (18402, 4080, 2734, 1);
INSERT INTO studentclasses VALUES (18403, 4080, 2735, 5);
INSERT INTO studentclasses VALUES (18404, 4080, 2736, 3);
INSERT INTO studentclasses VALUES (18405, 4080, 2737, 11);
INSERT INTO studentclasses VALUES (18406, 4080, 2738, 2);
INSERT INTO studentclasses VALUES (18407, 4081, 2734, 1);
INSERT INTO studentclasses VALUES (18408, 4081, 2735, 5);
INSERT INTO studentclasses VALUES (18409, 4081, 2736, 3);
INSERT INTO studentclasses VALUES (18410, 4081, 2737, 11);
INSERT INTO studentclasses VALUES (18411, 4081, 2738, 2);
INSERT INTO studentclasses VALUES (18412, 4082, 2739, 4);
INSERT INTO studentclasses VALUES (18413, 4082, 2735, 7);
INSERT INTO studentclasses VALUES (18414, 4082, 2740, 11);
INSERT INTO studentclasses VALUES (18415, 4082, 2741, 10);
INSERT INTO studentclasses VALUES (18416, 4082, 2742, 5);
INSERT INTO studentclasses VALUES (18417, 4083, 2734, 1);
INSERT INTO studentclasses VALUES (18418, 4083, 2735, 5);
INSERT INTO studentclasses VALUES (18419, 4083, 2736, 9);
INSERT INTO studentclasses VALUES (18420, 4083, 2737, 8);
INSERT INTO studentclasses VALUES (18421, 4083, 2738, 4);
INSERT INTO studentclasses VALUES (18422, 4084, 2743, 12);
INSERT INTO studentclasses VALUES (18423, 4084, 2744, 7);
INSERT INTO studentclasses VALUES (18424, 4084, 2740, 7);
INSERT INTO studentclasses VALUES (18425, 4084, 2745, 11);
INSERT INTO studentclasses VALUES (18426, 4084, 2742, 2);
INSERT INTO studentclasses VALUES (18427, 4085, 2734, 1);
INSERT INTO studentclasses VALUES (18428, 4085, 2735, 4);
INSERT INTO studentclasses VALUES (18429, 4085, 2736, 8);
INSERT INTO studentclasses VALUES (18430, 4085, 2737, 6);
INSERT INTO studentclasses VALUES (18431, 4085, 2738, 3);
INSERT INTO studentclasses VALUES (18432, 4086, 2734, 2);
INSERT INTO studentclasses VALUES (18433, 4086, 2735, 7);
INSERT INTO studentclasses VALUES (18434, 4086, 2736, 1);
INSERT INTO studentclasses VALUES (18435, 4086, 2737, 5);
INSERT INTO studentclasses VALUES (18436, 4086, 2738, 1);
INSERT INTO studentclasses VALUES (18437, 4087, 2746, 7);
INSERT INTO studentclasses VALUES (18438, 4087, 2747, 9);
INSERT INTO studentclasses VALUES (18439, 4087, 2748, 3);
INSERT INTO studentclasses VALUES (18440, 4087, 2749, 3);
INSERT INTO studentclasses VALUES (18441, 4087, 2722, 5);
INSERT INTO studentclasses VALUES (18442, 4088, 2734, 1);
INSERT INTO studentclasses VALUES (18443, 4088, 2735, 6);
INSERT INTO studentclasses VALUES (18444, 4088, 2736, 3);
INSERT INTO studentclasses VALUES (18445, 4088, 2737, 8);
INSERT INTO studentclasses VALUES (18446, 4088, 2738, 3);
INSERT INTO studentclasses VALUES (18447, 4089, 2746, 4);
INSERT INTO studentclasses VALUES (18448, 4089, 2747, 6);
INSERT INTO studentclasses VALUES (18449, 4089, 2750, 6);
INSERT INTO studentclasses VALUES (18450, 4089, 2751, 1);
INSERT INTO studentclasses VALUES (18451, 4089, 2722, 1);
INSERT INTO studentclasses VALUES (18452, 4090, 2752, 9);
INSERT INTO studentclasses VALUES (18453, 4091, 2753, 11);
INSERT INTO studentclasses VALUES (18454, 4091, 2754, 6);
INSERT INTO studentclasses VALUES (18455, 4091, 2755, 5);
INSERT INTO studentclasses VALUES (18456, 4091, 2756, 2);
INSERT INTO studentclasses VALUES (18457, 4091, 2757, 12);
INSERT INTO studentclasses VALUES (18458, 4091, 2758, 6);
INSERT INTO studentclasses VALUES (18459, 4092, 2759, 4);
INSERT INTO studentclasses VALUES (18460, 4092, 2760, 3);
INSERT INTO studentclasses VALUES (18461, 4092, 2761, 4);
INSERT INTO studentclasses VALUES (18462, 4092, 2762, 8);
INSERT INTO studentclasses VALUES (18463, 4092, 2763, 5);
INSERT INTO studentclasses VALUES (18464, 4092, 2764, 12);
INSERT INTO studentclasses VALUES (18465, 4092, 2765, 12);
INSERT INTO studentclasses VALUES (18466, 4093, 2766, 11);
INSERT INTO studentclasses VALUES (18467, 4093, 2767, 5);
INSERT INTO studentclasses VALUES (18468, 4093, 2768, 10);
INSERT INTO studentclasses VALUES (18469, 4093, 2769, 11);
INSERT INTO studentclasses VALUES (18470, 4093, 2770, 9);
INSERT INTO studentclasses VALUES (18471, 4093, 2771, 12);
INSERT INTO studentclasses VALUES (18472, 4093, 2772, 11);
INSERT INTO studentclasses VALUES (18473, 4094, 2773, 13);
INSERT INTO studentclasses VALUES (18474, 4094, 2774, 6);
INSERT INTO studentclasses VALUES (18475, 4094, 2775, 5);
INSERT INTO studentclasses VALUES (18476, 4094, 2770, 2);
INSERT INTO studentclasses VALUES (18477, 4094, 2776, 2);
INSERT INTO studentclasses VALUES (18478, 4094, 2772, 5);
INSERT INTO studentclasses VALUES (18479, 4095, 2777, 9);
INSERT INTO studentclasses VALUES (18480, 4095, 2778, 13);
INSERT INTO studentclasses VALUES (18481, 4095, 2779, 5);
INSERT INTO studentclasses VALUES (18482, 4095, 2780, 13);
INSERT INTO studentclasses VALUES (18483, 4095, 2781, 7);
INSERT INTO studentclasses VALUES (18484, 4096, 2782, 13);
INSERT INTO studentclasses VALUES (18485, 4096, 2783, 3);
INSERT INTO studentclasses VALUES (18486, 4096, 2784, 7);
INSERT INTO studentclasses VALUES (18487, 4096, 2785, 7);
INSERT INTO studentclasses VALUES (18488, 4096, 2786, 3);
INSERT INTO studentclasses VALUES (18489, 4096, 2780, 8);
INSERT INTO studentclasses VALUES (18490, 4097, 2787, 9);
INSERT INTO studentclasses VALUES (18491, 4097, 2788, 11);
INSERT INTO studentclasses VALUES (18492, 4097, 2783, 8);
INSERT INTO studentclasses VALUES (18493, 4097, 2789, 9);
INSERT INTO studentclasses VALUES (18494, 4097, 2790, 11);
INSERT INTO studentclasses VALUES (18495, 4097, 2791, 2);
INSERT INTO studentclasses VALUES (18496, 4098, 2792, 4);
INSERT INTO studentclasses VALUES (18497, 4098, 2783, 6);
INSERT INTO studentclasses VALUES (18498, 4098, 2793, 11);
INSERT INTO studentclasses VALUES (18499, 4098, 2794, 9);
INSERT INTO studentclasses VALUES (18500, 4098, 2795, 5);
INSERT INTO studentclasses VALUES (18501, 4098, 2796, 11);
INSERT INTO studentclasses VALUES (18502, 4099, 2797, 9);
INSERT INTO studentclasses VALUES (18503, 4099, 2798, 8);
INSERT INTO studentclasses VALUES (18504, 4099, 2799, 11);
INSERT INTO studentclasses VALUES (18505, 4099, 2794, 10);
INSERT INTO studentclasses VALUES (18506, 4099, 2800, 11);
INSERT INTO studentclasses VALUES (18507, 4100, 2801, 12);
INSERT INTO studentclasses VALUES (18508, 4100, 2802, 6);
INSERT INTO studentclasses VALUES (18509, 4100, 2803, 8);
INSERT INTO studentclasses VALUES (18510, 4100, 2804, 10);
INSERT INTO studentclasses VALUES (18511, 4100, 2805, 7);
INSERT INTO studentclasses VALUES (18512, 4100, 2806, 6);
INSERT INTO studentclasses VALUES (18513, 4101, 2807, 6);
INSERT INTO studentclasses VALUES (18514, 4101, 2787, 8);
INSERT INTO studentclasses VALUES (18515, 4101, 2808, 9);
INSERT INTO studentclasses VALUES (18516, 4101, 2783, 4);
INSERT INTO studentclasses VALUES (18517, 4101, 2804, 13);
INSERT INTO studentclasses VALUES (18518, 4101, 2796, 8);
INSERT INTO studentclasses VALUES (18519, 4102, 2809, 2);
INSERT INTO studentclasses VALUES (18520, 4102, 2793, 11);
INSERT INTO studentclasses VALUES (18521, 4102, 2810, 9);
INSERT INTO studentclasses VALUES (18522, 4102, 2784, 11);
INSERT INTO studentclasses VALUES (18523, 4102, 2796, 11);
INSERT INTO studentclasses VALUES (18524, 4103, 2811, 5);
INSERT INTO studentclasses VALUES (18525, 4103, 2812, 11);
INSERT INTO studentclasses VALUES (18526, 4103, 2813, 2);
INSERT INTO studentclasses VALUES (18527, 4103, 2814, 3);
INSERT INTO studentclasses VALUES (18528, 4103, 2815, 4);
INSERT INTO studentclasses VALUES (18529, 4104, 2816, 7);
INSERT INTO studentclasses VALUES (18530, 4104, 2817, 9);
INSERT INTO studentclasses VALUES (18531, 4104, 2813, 4);
INSERT INTO studentclasses VALUES (18532, 4104, 2818, 5);
INSERT INTO studentclasses VALUES (18533, 4104, 2815, 3);
INSERT INTO studentclasses VALUES (18534, 4105, 2819, 8);
INSERT INTO studentclasses VALUES (18535, 4105, 2817, 9);
INSERT INTO studentclasses VALUES (18536, 4105, 2813, 5);
INSERT INTO studentclasses VALUES (18537, 4105, 2818, 6);
INSERT INTO studentclasses VALUES (18538, 4105, 2815, 7);
INSERT INTO studentclasses VALUES (18539, 4106, 2820, 4);
INSERT INTO studentclasses VALUES (18540, 4106, 2821, 8);
INSERT INTO studentclasses VALUES (18541, 4106, 2766, 8);
INSERT INTO studentclasses VALUES (18542, 4106, 2822, 7);
INSERT INTO studentclasses VALUES (18543, 4106, 2823, 6);
INSERT INTO studentclasses VALUES (18544, 4107, 2824, 4);
INSERT INTO studentclasses VALUES (18545, 4107, 2825, 9);
INSERT INTO studentclasses VALUES (18546, 4107, 2813, 6);
INSERT INTO studentclasses VALUES (18547, 4107, 2826, 1);
INSERT INTO studentclasses VALUES (18548, 4107, 2815, 9);
INSERT INTO studentclasses VALUES (18549, 4108, 2827, 13);
INSERT INTO studentclasses VALUES (18550, 4108, 2828, 11);
INSERT INTO studentclasses VALUES (18551, 4108, 2829, 5);
INSERT INTO studentclasses VALUES (18552, 4108, 2830, 6);
INSERT INTO studentclasses VALUES (18553, 4108, 2831, 3);
INSERT INTO studentclasses VALUES (18554, 4109, 2832, 4);
INSERT INTO studentclasses VALUES (18555, 4109, 2833, 11);
INSERT INTO studentclasses VALUES (18556, 4109, 2785, 8);
INSERT INTO studentclasses VALUES (18557, 4109, 2834, 5);
INSERT INTO studentclasses VALUES (18558, 4109, 2815, 5);
INSERT INTO studentclasses VALUES (18559, 4110, 2816, 5);
INSERT INTO studentclasses VALUES (18560, 4110, 2817, 5);
INSERT INTO studentclasses VALUES (18561, 4110, 2813, 5);
INSERT INTO studentclasses VALUES (18562, 4110, 2818, 6);
INSERT INTO studentclasses VALUES (18563, 4110, 2815, 2);
INSERT INTO studentclasses VALUES (18564, 4111, 2835, 4);
INSERT INTO studentclasses VALUES (18565, 4111, 2836, 4);
INSERT INTO studentclasses VALUES (18566, 4111, 2837, 7);
INSERT INTO studentclasses VALUES (18567, 4111, 2838, 2);
INSERT INTO studentclasses VALUES (18568, 4111, 2839, 1);
INSERT INTO studentclasses VALUES (18569, 4112, 2840, 3);
INSERT INTO studentclasses VALUES (18570, 4112, 2841, 3);
INSERT INTO studentclasses VALUES (18571, 4112, 2817, 7);
INSERT INTO studentclasses VALUES (18572, 4112, 2842, 3);
INSERT INTO studentclasses VALUES (18573, 4112, 2800, 3);
INSERT INTO studentclasses VALUES (18574, 4113, 2843, 1);
INSERT INTO studentclasses VALUES (18575, 4113, 2844, 7);
INSERT INTO studentclasses VALUES (18576, 4113, 2845, 4);
INSERT INTO studentclasses VALUES (18577, 4113, 2846, 2);
INSERT INTO studentclasses VALUES (18578, 4113, 2831, 2);
INSERT INTO studentclasses VALUES (18579, 4114, 2847, 3);
INSERT INTO studentclasses VALUES (18580, 4115, 2848, 12);
INSERT INTO studentclasses VALUES (18581, 4116, 2849, 3);
INSERT INTO studentclasses VALUES (18582, 4116, 2850, 9);
INSERT INTO studentclasses VALUES (18583, 4117, 2851, 4);
INSERT INTO studentclasses VALUES (18584, 4118, 2852, 5);
INSERT INTO studentclasses VALUES (18585, 4119, 2853, 6);
INSERT INTO studentclasses VALUES (18586, 4119, 2854, 5);
INSERT INTO studentclasses VALUES (18587, 4120, 2850, 11);
INSERT INTO studentclasses VALUES (18588, 4121, 2855, 4);
INSERT INTO studentclasses VALUES (18589, 4121, 2856, 6);
INSERT INTO studentclasses VALUES (18590, 4122, 2857, 4);
INSERT INTO studentclasses VALUES (18591, 4123, 2858, 3);
INSERT INTO studentclasses VALUES (18592, 4124, 2859, 9);
INSERT INTO studentclasses VALUES (18593, 4125, 2860, 3);
INSERT INTO studentclasses VALUES (18594, 4126, 2861, 5);
INSERT INTO studentclasses VALUES (18595, 4127, 2862, 6);
INSERT INTO studentclasses VALUES (18596, 4127, 2863, 11);
INSERT INTO studentclasses VALUES (18597, 4127, 2864, 7);
INSERT INTO studentclasses VALUES (18598, 4127, 2865, 8);
INSERT INTO studentclasses VALUES (18599, 4127, 2866, 2);
INSERT INTO studentclasses VALUES (18600, 4127, 2867, 9);
INSERT INTO studentclasses VALUES (18601, 4128, 2868, 13);
INSERT INTO studentclasses VALUES (18602, 4128, 2869, 14);
INSERT INTO studentclasses VALUES (18603, 4128, 2870, 13);
INSERT INTO studentclasses VALUES (18604, 4128, 2871, 14);
INSERT INTO studentclasses VALUES (18605, 4128, 2872, 9);
INSERT INTO studentclasses VALUES (18606, 4128, 2873, 9);
INSERT INTO studentclasses VALUES (18607, 4128, 2874, 11);
INSERT INTO studentclasses VALUES (18608, 4129, 2875, 4);
INSERT INTO studentclasses VALUES (18609, 4129, 2876, 6);
INSERT INTO studentclasses VALUES (18610, 4129, 2877, 1);
INSERT INTO studentclasses VALUES (18611, 4129, 2878, 4);
INSERT INTO studentclasses VALUES (18612, 4129, 2879, 1);
INSERT INTO studentclasses VALUES (18613, 4130, 2880, 6);
INSERT INTO studentclasses VALUES (18614, 4130, 2881, 3);
INSERT INTO studentclasses VALUES (18615, 4130, 2882, 11);
INSERT INTO studentclasses VALUES (18616, 4130, 2883, 6);
INSERT INTO studentclasses VALUES (18617, 4130, 2884, 7);
INSERT INTO studentclasses VALUES (18618, 4131, 2885, 5);
INSERT INTO studentclasses VALUES (18619, 4131, 2886, 7);
INSERT INTO studentclasses VALUES (18620, 4131, 2864, 6);
INSERT INTO studentclasses VALUES (18621, 4131, 2887, 3);
INSERT INTO studentclasses VALUES (18622, 4131, 2888, 3);
INSERT INTO studentclasses VALUES (18623, 4132, 2889, 2);
INSERT INTO studentclasses VALUES (18624, 4132, 2890, 9);
INSERT INTO studentclasses VALUES (18625, 4132, 2891, 11);
INSERT INTO studentclasses VALUES (18626, 4132, 2892, 5);
INSERT INTO studentclasses VALUES (18627, 4132, 2893, 6);
INSERT INTO studentclasses VALUES (18628, 4133, 2894, 7);
INSERT INTO studentclasses VALUES (18629, 4133, 2895, 11);
INSERT INTO studentclasses VALUES (18630, 4133, 2892, 3);
INSERT INTO studentclasses VALUES (18631, 4133, 2896, 2);
INSERT INTO studentclasses VALUES (18632, 4133, 2893, 8);
INSERT INTO studentclasses VALUES (18633, 4134, 2897, 8);
INSERT INTO studentclasses VALUES (18634, 4134, 2898, 7);
INSERT INTO studentclasses VALUES (18635, 4134, 2899, 5);
INSERT INTO studentclasses VALUES (18636, 4134, 2900, 2);
INSERT INTO studentclasses VALUES (18637, 4135, 2901, 5);
INSERT INTO studentclasses VALUES (18638, 4135, 2902, 4);
INSERT INTO studentclasses VALUES (18639, 4135, 2891, 8);
INSERT INTO studentclasses VALUES (18640, 4135, 2900, 4);
INSERT INTO studentclasses VALUES (18641, 4135, 2903, 11);
INSERT INTO studentclasses VALUES (18642, 4135, 2893, 6);
INSERT INTO studentclasses VALUES (18643, 4136, 2904, 7);
INSERT INTO studentclasses VALUES (18644, 4136, 2903, 11);
INSERT INTO studentclasses VALUES (18645, 4136, 2870, 7);
INSERT INTO studentclasses VALUES (18646, 4136, 2892, 7);
INSERT INTO studentclasses VALUES (18647, 4136, 2905, 7);
INSERT INTO studentclasses VALUES (18648, 4136, 2865, 6);
INSERT INTO studentclasses VALUES (18649, 4137, 2906, 3);
INSERT INTO studentclasses VALUES (18650, 4137, 2894, 8);
INSERT INTO studentclasses VALUES (18651, 4137, 2903, 8);
INSERT INTO studentclasses VALUES (18652, 4137, 2892, 4);
INSERT INTO studentclasses VALUES (18653, 4137, 2896, 2);
INSERT INTO studentclasses VALUES (18654, 4138, 2907, 12);
INSERT INTO studentclasses VALUES (18655, 4138, 2908, 9);
INSERT INTO studentclasses VALUES (18656, 4138, 2909, 7);
INSERT INTO studentclasses VALUES (18657, 4138, 2910, 6);
INSERT INTO studentclasses VALUES (18658, 4138, 2911, 2);
INSERT INTO studentclasses VALUES (18659, 4139, 2912, 2);
INSERT INTO studentclasses VALUES (18660, 4139, 2913, 4);
INSERT INTO studentclasses VALUES (18661, 4139, 2914, 7);
INSERT INTO studentclasses VALUES (18662, 4139, 2915, 2);
INSERT INTO studentclasses VALUES (18663, 4139, 2916, 7);
INSERT INTO studentclasses VALUES (18664, 4140, 2917, 8);
INSERT INTO studentclasses VALUES (18665, 4140, 2910, 5);
INSERT INTO studentclasses VALUES (18666, 4140, 2918, 4);
INSERT INTO studentclasses VALUES (18667, 4140, 2919, 4);
INSERT INTO studentclasses VALUES (18668, 4140, 2911, 3);
INSERT INTO studentclasses VALUES (18669, 4141, 2920, 9);
INSERT INTO studentclasses VALUES (18670, 4141, 2917, 9);
INSERT INTO studentclasses VALUES (18671, 4141, 2910, 6);
INSERT INTO studentclasses VALUES (18672, 4141, 2921, 8);
INSERT INTO studentclasses VALUES (18673, 4141, 2922, 13);
INSERT INTO studentclasses VALUES (18674, 4142, 2923, 6);
INSERT INTO studentclasses VALUES (18675, 4142, 2924, 9);
INSERT INTO studentclasses VALUES (18676, 4142, 2910, 9);
INSERT INTO studentclasses VALUES (18677, 4142, 2925, 4);
INSERT INTO studentclasses VALUES (18678, 4142, 2911, 7);
INSERT INTO studentclasses VALUES (18679, 4143, 2926, 4);
INSERT INTO studentclasses VALUES (18680, 4143, 2927, 9);
INSERT INTO studentclasses VALUES (18681, 4143, 2928, 9);
INSERT INTO studentclasses VALUES (18682, 4143, 2911, 8);
INSERT INTO studentclasses VALUES (18683, 4144, 2929, 6);
INSERT INTO studentclasses VALUES (18684, 4144, 2908, 10);
INSERT INTO studentclasses VALUES (18685, 4144, 2910, 11);
INSERT INTO studentclasses VALUES (18686, 4144, 2930, 6);
INSERT INTO studentclasses VALUES (18687, 4145, 2931, 3);
INSERT INTO studentclasses VALUES (18688, 4145, 2932, 2);
INSERT INTO studentclasses VALUES (18689, 4145, 2927, 9);
INSERT INTO studentclasses VALUES (18690, 4145, 2928, 7);
INSERT INTO studentclasses VALUES (18691, 4145, 2911, 6);
INSERT INTO studentclasses VALUES (18692, 4146, 2933, 5);
INSERT INTO studentclasses VALUES (18693, 4146, 2934, 7);
INSERT INTO studentclasses VALUES (18694, 4146, 2935, 7);
INSERT INTO studentclasses VALUES (18695, 4146, 2910, 6);
INSERT INTO studentclasses VALUES (18696, 4146, 2911, 7);
INSERT INTO studentclasses VALUES (18697, 4147, 2936, 5);
INSERT INTO studentclasses VALUES (18698, 4147, 2937, 11);
INSERT INTO studentclasses VALUES (18699, 4147, 2928, 9);
INSERT INTO studentclasses VALUES (18700, 4147, 2938, 6);
INSERT INTO studentclasses VALUES (18701, 4147, 2911, 1);
INSERT INTO studentclasses VALUES (18702, 4148, 2939, 8);
INSERT INTO studentclasses VALUES (18703, 4148, 2909, 6);
INSERT INTO studentclasses VALUES (18704, 4148, 2928, 6);
INSERT INTO studentclasses VALUES (18705, 4148, 2940, 9);
INSERT INTO studentclasses VALUES (18706, 4148, 2941, 8);
INSERT INTO studentclasses VALUES (18707, 4149, 2942, 3);
INSERT INTO studentclasses VALUES (18708, 4149, 2943, 7);
INSERT INTO studentclasses VALUES (18709, 4149, 2944, 7);
INSERT INTO studentclasses VALUES (18710, 4149, 2945, 6);
INSERT INTO studentclasses VALUES (18711, 4149, 2922, 2);
INSERT INTO studentclasses VALUES (18712, 4150, 2946, 3);
INSERT INTO studentclasses VALUES (18713, 4150, 2947, 6);
INSERT INTO studentclasses VALUES (18714, 4150, 2948, 9);
INSERT INTO studentclasses VALUES (18715, 4150, 2949, 2);
INSERT INTO studentclasses VALUES (18716, 4150, 2950, 3);
INSERT INTO studentclasses VALUES (18717, 4151, 2951, 4);
INSERT INTO studentclasses VALUES (18718, 4151, 2952, 7);
INSERT INTO studentclasses VALUES (18719, 4151, 2953, 2);
INSERT INTO studentclasses VALUES (18720, 4151, 2954, 5);
INSERT INTO studentclasses VALUES (18721, 4151, 2915, 1);
INSERT INTO studentclasses VALUES (18722, 4152, 2955, 4);
INSERT INTO studentclasses VALUES (18723, 4152, 2913, 6);
INSERT INTO studentclasses VALUES (18724, 4152, 2956, 6);
INSERT INTO studentclasses VALUES (18725, 4152, 2957, 7);
INSERT INTO studentclasses VALUES (18726, 4152, 2958, 6);
INSERT INTO studentclasses VALUES (18727, 4153, 2959, 2);
INSERT INTO studentclasses VALUES (18728, 4153, 2960, 9);
INSERT INTO studentclasses VALUES (18729, 4153, 2961, 3);
INSERT INTO studentclasses VALUES (18730, 4153, 2962, 3);
INSERT INTO studentclasses VALUES (18731, 4153, 2963, 6);
INSERT INTO studentclasses VALUES (18732, 4154, 2964, 7);
INSERT INTO studentclasses VALUES (18733, 4154, 2965, 6);
INSERT INTO studentclasses VALUES (18734, 4154, 2966, 8);
INSERT INTO studentclasses VALUES (18735, 4154, 2967, 11);
INSERT INTO studentclasses VALUES (18736, 4154, 2958, 6);
INSERT INTO studentclasses VALUES (18737, 4155, 2946, 3);
INSERT INTO studentclasses VALUES (18738, 4155, 2947, 9);
INSERT INTO studentclasses VALUES (18739, 4155, 2948, 5);
INSERT INTO studentclasses VALUES (18740, 4155, 2949, 9);
INSERT INTO studentclasses VALUES (18741, 4155, 2950, 8);
INSERT INTO studentclasses VALUES (18742, 4156, 2968, 6);
INSERT INTO studentclasses VALUES (18743, 4156, 2969, 6);
INSERT INTO studentclasses VALUES (18744, 4156, 2970, 4);
INSERT INTO studentclasses VALUES (18745, 4156, 2971, 2);
INSERT INTO studentclasses VALUES (18746, 4156, 2958, 6);
INSERT INTO studentclasses VALUES (18747, 4157, 2972, 7);
INSERT INTO studentclasses VALUES (18748, 4157, 2913, 5);
INSERT INTO studentclasses VALUES (18749, 4157, 2966, 5);
INSERT INTO studentclasses VALUES (18750, 4157, 2973, 9);
INSERT INTO studentclasses VALUES (18751, 4157, 2958, 1);
INSERT INTO studentclasses VALUES (18752, 4158, 2946, 3);
INSERT INTO studentclasses VALUES (18753, 4158, 2947, 7);
INSERT INTO studentclasses VALUES (18754, 4158, 2948, 6);
INSERT INTO studentclasses VALUES (18755, 4158, 2949, 3);
INSERT INTO studentclasses VALUES (18756, 4158, 2950, 6);
INSERT INTO studentclasses VALUES (18757, 4159, 2974, 8);
INSERT INTO studentclasses VALUES (18758, 4159, 2947, 8);
INSERT INTO studentclasses VALUES (18759, 4159, 2969, 8);
INSERT INTO studentclasses VALUES (18760, 4159, 2949, 9);
INSERT INTO studentclasses VALUES (18761, 4159, 2950, 9);
INSERT INTO studentclasses VALUES (18762, 4160, 2975, 4);
INSERT INTO studentclasses VALUES (18763, 4160, 2960, 6);
INSERT INTO studentclasses VALUES (18764, 4160, 2976, 5);
INSERT INTO studentclasses VALUES (18765, 4160, 2977, 4);
INSERT INTO studentclasses VALUES (18766, 4160, 2963, 5);
INSERT INTO studentclasses VALUES (18767, 4161, 2978, 8);
INSERT INTO studentclasses VALUES (18768, 4161, 2979, 11);
INSERT INTO studentclasses VALUES (18769, 4161, 2980, 3);
INSERT INTO studentclasses VALUES (18770, 4161, 2981, 8);
INSERT INTO studentclasses VALUES (18771, 4161, 2982, 7);
INSERT INTO studentclasses VALUES (18772, 4162, 2983, 6);
INSERT INTO studentclasses VALUES (18773, 4162, 2960, 9);
INSERT INTO studentclasses VALUES (18774, 4162, 2984, 5);
INSERT INTO studentclasses VALUES (18775, 4162, 2985, 10);
INSERT INTO studentclasses VALUES (18776, 4162, 2963, 7);
INSERT INTO studentclasses VALUES (18777, 4163, 2946, 4);
INSERT INTO studentclasses VALUES (18778, 4163, 2947, 6);
INSERT INTO studentclasses VALUES (18779, 4163, 2948, 8);
INSERT INTO studentclasses VALUES (18780, 4163, 2949, 3);
INSERT INTO studentclasses VALUES (18781, 4163, 2950, 6);
INSERT INTO studentclasses VALUES (18782, 4164, 2986, 6);
INSERT INTO studentclasses VALUES (18783, 4164, 2969, 5);
INSERT INTO studentclasses VALUES (18784, 4164, 2987, 5);
INSERT INTO studentclasses VALUES (18785, 4164, 2988, 4);
INSERT INTO studentclasses VALUES (18786, 4164, 2989, 1);
INSERT INTO studentclasses VALUES (18787, 4165, 2990, 4);
INSERT INTO studentclasses VALUES (18788, 4165, 2991, 6);
INSERT INTO studentclasses VALUES (18789, 4165, 2961, 4);
INSERT INTO studentclasses VALUES (18790, 4165, 2992, 2);
INSERT INTO studentclasses VALUES (18791, 4165, 2915, 1);
INSERT INTO studentclasses VALUES (18792, 4166, 2993, 6);
INSERT INTO studentclasses VALUES (18793, 4166, 2994, 7);
INSERT INTO studentclasses VALUES (18794, 4166, 2995, 6);
INSERT INTO studentclasses VALUES (18795, 4166, 2996, 2);
INSERT INTO studentclasses VALUES (18796, 4166, 2958, 6);
INSERT INTO studentclasses VALUES (18797, 4167, 2997, 5);
INSERT INTO studentclasses VALUES (18798, 4167, 2924, 4);
INSERT INTO studentclasses VALUES (18799, 4167, 2952, 7);
INSERT INTO studentclasses VALUES (18800, 4167, 2998, 7);
INSERT INTO studentclasses VALUES (18801, 4167, 2982, 1);
INSERT INTO studentclasses VALUES (18802, 4168, 2999, 3);
INSERT INTO studentclasses VALUES (18803, 4168, 3000, 9);
INSERT INTO studentclasses VALUES (18804, 4168, 3001, 8);
INSERT INTO studentclasses VALUES (18805, 4168, 3002, 4);
INSERT INTO studentclasses VALUES (18806, 4168, 2915, 1);
INSERT INTO studentclasses VALUES (18807, 4169, 3003, 6);
INSERT INTO studentclasses VALUES (18808, 4169, 3004, 5);
INSERT INTO studentclasses VALUES (18809, 4169, 3005, 4);
INSERT INTO studentclasses VALUES (18810, 4169, 3006, 6);
INSERT INTO studentclasses VALUES (18811, 4169, 2958, 5);
INSERT INTO studentclasses VALUES (18812, 4170, 3007, 5);
INSERT INTO studentclasses VALUES (18813, 4170, 3008, 11);
INSERT INTO studentclasses VALUES (18814, 4170, 3009, 4);
INSERT INTO studentclasses VALUES (18815, 4170, 3010, 12);
INSERT INTO studentclasses VALUES (18816, 4170, 2958, 5);
INSERT INTO studentclasses VALUES (18817, 4171, 2986, 7);
INSERT INTO studentclasses VALUES (18818, 4171, 2969, 8);
INSERT INTO studentclasses VALUES (18819, 4171, 2987, 7);
INSERT INTO studentclasses VALUES (18820, 4171, 2988, 3);
INSERT INTO studentclasses VALUES (18821, 4171, 2989, 4);
INSERT INTO studentclasses VALUES (18822, 4172, 3011, 6);
INSERT INTO studentclasses VALUES (18823, 4172, 3000, 10);
INSERT INTO studentclasses VALUES (18824, 4172, 3012, 8);
INSERT INTO studentclasses VALUES (18825, 4172, 3002, 3);
INSERT INTO studentclasses VALUES (18826, 4172, 2915, 11);
INSERT INTO studentclasses VALUES (18827, 4173, 2993, 5);
INSERT INTO studentclasses VALUES (18828, 4173, 2994, 8);
INSERT INTO studentclasses VALUES (18829, 4173, 2995, 5);
INSERT INTO studentclasses VALUES (18830, 4173, 2996, 1);
INSERT INTO studentclasses VALUES (18831, 4173, 2982, 5);
INSERT INTO studentclasses VALUES (18832, 4174, 2986, 6);
INSERT INTO studentclasses VALUES (18833, 4174, 2969, 4);
INSERT INTO studentclasses VALUES (18834, 4174, 2987, 8);
INSERT INTO studentclasses VALUES (18835, 4174, 2988, 4);
INSERT INTO studentclasses VALUES (18836, 4174, 2989, 1);
INSERT INTO studentclasses VALUES (18837, 4175, 3013, 4);
INSERT INTO studentclasses VALUES (18838, 4175, 2960, 7);
INSERT INTO studentclasses VALUES (18839, 4175, 2998, 4);
INSERT INTO studentclasses VALUES (18840, 4175, 3014, 8);
INSERT INTO studentclasses VALUES (18841, 4175, 2963, 6);
INSERT INTO studentclasses VALUES (18842, 4176, 3015, 7);
INSERT INTO studentclasses VALUES (18843, 4176, 3016, 9);
INSERT INTO studentclasses VALUES (18844, 4176, 2984, 5);
INSERT INTO studentclasses VALUES (18845, 4176, 2971, 2);
INSERT INTO studentclasses VALUES (18846, 4176, 2982, 6);
INSERT INTO studentclasses VALUES (18847, 4177, 3017, 4);
INSERT INTO studentclasses VALUES (18848, 4177, 2960, 8);
INSERT INTO studentclasses VALUES (18849, 4177, 2998, 5);
INSERT INTO studentclasses VALUES (18850, 4177, 3014, 9);
INSERT INTO studentclasses VALUES (18851, 4177, 2963, 8);
INSERT INTO studentclasses VALUES (18852, 4178, 3018, 3);
INSERT INTO studentclasses VALUES (18853, 4178, 2960, 4);
INSERT INTO studentclasses VALUES (18854, 4178, 3019, 9);
INSERT INTO studentclasses VALUES (18855, 4178, 3020, 4);
INSERT INTO studentclasses VALUES (18856, 4178, 2963, 3);
INSERT INTO studentclasses VALUES (18857, 4179, 3021, 12);
INSERT INTO studentclasses VALUES (18858, 4179, 2960, 1);
INSERT INTO studentclasses VALUES (18859, 4179, 3022, 8);
INSERT INTO studentclasses VALUES (18860, 4179, 3014, 7);
INSERT INTO studentclasses VALUES (18861, 4179, 2963, 5);
INSERT INTO studentclasses VALUES (18862, 4180, 2986, 4);
INSERT INTO studentclasses VALUES (18863, 4180, 2969, 9);
INSERT INTO studentclasses VALUES (18864, 4180, 2987, 9);
INSERT INTO studentclasses VALUES (18865, 4180, 2988, 4);
INSERT INTO studentclasses VALUES (18866, 4180, 2989, 5);
INSERT INTO studentclasses VALUES (18867, 4181, 3023, 1);
INSERT INTO studentclasses VALUES (18868, 4181, 3024, 3);
INSERT INTO studentclasses VALUES (18869, 4181, 3025, 8);
INSERT INTO studentclasses VALUES (18870, 4181, 3026, 3);
INSERT INTO studentclasses VALUES (18871, 4181, 3027, 4);
INSERT INTO studentclasses VALUES (18872, 4182, 3028, 5);
INSERT INTO studentclasses VALUES (18873, 4182, 3029, 5);
INSERT INTO studentclasses VALUES (18874, 4182, 3030, 2);
INSERT INTO studentclasses VALUES (18875, 4182, 3031, 7);
INSERT INTO studentclasses VALUES (18876, 4182, 3027, 5);
INSERT INTO studentclasses VALUES (18877, 4183, 3032, 1);
INSERT INTO studentclasses VALUES (18878, 4183, 3033, 2);
INSERT INTO studentclasses VALUES (18879, 4183, 3025, 11);
INSERT INTO studentclasses VALUES (18880, 4183, 3034, 1);
INSERT INTO studentclasses VALUES (18881, 4183, 3027, 11);
INSERT INTO studentclasses VALUES (18882, 4184, 3035, 8);
INSERT INTO studentclasses VALUES (18883, 4184, 3036, 12);
INSERT INTO studentclasses VALUES (18884, 4184, 3037, 8);
INSERT INTO studentclasses VALUES (18885, 4184, 3038, 10);
INSERT INTO studentclasses VALUES (18886, 4184, 3039, 7);
INSERT INTO studentclasses VALUES (18887, 4185, 3040, 5);
INSERT INTO studentclasses VALUES (18888, 4185, 3041, 6);
INSERT INTO studentclasses VALUES (18889, 4185, 3042, 12);
INSERT INTO studentclasses VALUES (18890, 4185, 3043, 3);
INSERT INTO studentclasses VALUES (18891, 4185, 3044, 12);
INSERT INTO studentclasses VALUES (18892, 4185, 3045, 3);
INSERT INTO studentclasses VALUES (18893, 4186, 3035, 6);
INSERT INTO studentclasses VALUES (18894, 4186, 3046, 14);
INSERT INTO studentclasses VALUES (18895, 4186, 3047, 4);
INSERT INTO studentclasses VALUES (18896, 4186, 3048, 7);
INSERT INTO studentclasses VALUES (18897, 4186, 3042, 9);
INSERT INTO studentclasses VALUES (18898, 4186, 3049, 12);
INSERT INTO studentclasses VALUES (18899, 4186, 3050, 11);
INSERT INTO studentclasses VALUES (18900, 4187, 3051, 7);
INSERT INTO studentclasses VALUES (18901, 4187, 3052, 5);
INSERT INTO studentclasses VALUES (18902, 4187, 3053, 2);
INSERT INTO studentclasses VALUES (18903, 4187, 3054, 2);
INSERT INTO studentclasses VALUES (18904, 4187, 3049, 3);
INSERT INTO studentclasses VALUES (18905, 4187, 3055, 12);
INSERT INTO studentclasses VALUES (18906, 4187, 3056, 7);
INSERT INTO studentclasses VALUES (18907, 4188, 3037, 7);
INSERT INTO studentclasses VALUES (18908, 4188, 3057, 8);
INSERT INTO studentclasses VALUES (18909, 4188, 3058, 5);
INSERT INTO studentclasses VALUES (18910, 4188, 3059, 8);
INSERT INTO studentclasses VALUES (18911, 4188, 3060, 6);
INSERT INTO studentclasses VALUES (18912, 4189, 3061, 2);
INSERT INTO studentclasses VALUES (18913, 4189, 3062, 11);
INSERT INTO studentclasses VALUES (18914, 4189, 3063, 6);
INSERT INTO studentclasses VALUES (18915, 4189, 3059, 8);
INSERT INTO studentclasses VALUES (18916, 4189, 3064, 6);
INSERT INTO studentclasses VALUES (18917, 4189, 3065, 2);
INSERT INTO studentclasses VALUES (18918, 4190, 3066, 7);
INSERT INTO studentclasses VALUES (18919, 4190, 3067, 8);
INSERT INTO studentclasses VALUES (18920, 4190, 3058, 7);
INSERT INTO studentclasses VALUES (18921, 4190, 3063, 7);
INSERT INTO studentclasses VALUES (18922, 4190, 3068, 9);
INSERT INTO studentclasses VALUES (18923, 4191, 3069, 6);
INSERT INTO studentclasses VALUES (18924, 4191, 3070, 6);
INSERT INTO studentclasses VALUES (18925, 4191, 3071, 11);
INSERT INTO studentclasses VALUES (18926, 4191, 3072, 8);
INSERT INTO studentclasses VALUES (18927, 4191, 3073, 12);
INSERT INTO studentclasses VALUES (18928, 4191, 3074, 5);
INSERT INTO studentclasses VALUES (18929, 4192, 3075, 9);
INSERT INTO studentclasses VALUES (18930, 4192, 3076, 13);
INSERT INTO studentclasses VALUES (18931, 4192, 3077, 7);
INSERT INTO studentclasses VALUES (18932, 4192, 3078, 7);
INSERT INTO studentclasses VALUES (18933, 4192, 3079, 3);
INSERT INTO studentclasses VALUES (18934, 4192, 3080, 6);
INSERT INTO studentclasses VALUES (18935, 4193, 3079, 5);
INSERT INTO studentclasses VALUES (18936, 4193, 3081, 11);
INSERT INTO studentclasses VALUES (18937, 4193, 3058, 1);
INSERT INTO studentclasses VALUES (18938, 4193, 3073, 7);
INSERT INTO studentclasses VALUES (18939, 4193, 3080, 5);
INSERT INTO studentclasses VALUES (18940, 4194, 3082, 4);
INSERT INTO studentclasses VALUES (18941, 4194, 3048, 12);
INSERT INTO studentclasses VALUES (18942, 4194, 3068, 5);
INSERT INTO studentclasses VALUES (18943, 4194, 3043, 6);
INSERT INTO studentclasses VALUES (18944, 4194, 3083, 3);
INSERT INTO studentclasses VALUES (18945, 4194, 3084, 12);
INSERT INTO studentclasses VALUES (18946, 4194, 3085, 11);
INSERT INTO studentclasses VALUES (18947, 4195, 3062, 11);
INSERT INTO studentclasses VALUES (18948, 4195, 3086, 8);
INSERT INTO studentclasses VALUES (18949, 4195, 3048, 5);
INSERT INTO studentclasses VALUES (18950, 4195, 3059, 9);
INSERT INTO studentclasses VALUES (18951, 4195, 3087, 5);
INSERT INTO studentclasses VALUES (18952, 4196, 3088, 12);
INSERT INTO studentclasses VALUES (18953, 4196, 3089, 11);
INSERT INTO studentclasses VALUES (18954, 4196, 3090, 8);
INSERT INTO studentclasses VALUES (18955, 4196, 3091, 1);
INSERT INTO studentclasses VALUES (18956, 4196, 3086, 7);
INSERT INTO studentclasses VALUES (18957, 4196, 3092, 5);
INSERT INTO studentclasses VALUES (18958, 4197, 3093, 8);
INSERT INTO studentclasses VALUES (18959, 4197, 3094, 7);
INSERT INTO studentclasses VALUES (18960, 4197, 3095, 9);
INSERT INTO studentclasses VALUES (18961, 4197, 3096, 6);
INSERT INTO studentclasses VALUES (18962, 4197, 3097, 7);
INSERT INTO studentclasses VALUES (18963, 4198, 3037, 7);
INSERT INTO studentclasses VALUES (18964, 4198, 3078, 8);
INSERT INTO studentclasses VALUES (18965, 4198, 3098, 6);
INSERT INTO studentclasses VALUES (18966, 4198, 3099, 3);
INSERT INTO studentclasses VALUES (18967, 4198, 3100, 6);
INSERT INTO studentclasses VALUES (18968, 4198, 3058, 8);
INSERT INTO studentclasses VALUES (18969, 4199, 3101, 10);
INSERT INTO studentclasses VALUES (18970, 4199, 3098, 8);
INSERT INTO studentclasses VALUES (18971, 4199, 3102, 5);
INSERT INTO studentclasses VALUES (18972, 4199, 3058, 11);
INSERT INTO studentclasses VALUES (18973, 4199, 3080, 9);
INSERT INTO studentclasses VALUES (18974, 4200, 3103, 8);
INSERT INTO studentclasses VALUES (18975, 4200, 3104, 13);
INSERT INTO studentclasses VALUES (18976, 4200, 3105, 13);
INSERT INTO studentclasses VALUES (18977, 4200, 3106, 6);
INSERT INTO studentclasses VALUES (18978, 4200, 3058, 9);
INSERT INTO studentclasses VALUES (18979, 4201, 3107, 2);
INSERT INTO studentclasses VALUES (18980, 4201, 3108, 9);
INSERT INTO studentclasses VALUES (18981, 4201, 3037, 8);
INSERT INTO studentclasses VALUES (18982, 4201, 3109, 9);
INSERT INTO studentclasses VALUES (18983, 4201, 3110, 6);
INSERT INTO studentclasses VALUES (18984, 4201, 3111, 13);
INSERT INTO studentclasses VALUES (18985, 4202, 3112, 6);
INSERT INTO studentclasses VALUES (18986, 4202, 3113, 4);
INSERT INTO studentclasses VALUES (18987, 4202, 3114, 7);
INSERT INTO studentclasses VALUES (18988, 4202, 3115, 5);
INSERT INTO studentclasses VALUES (18989, 4202, 3072, 3);
INSERT INTO studentclasses VALUES (18990, 4203, 3116, 4);
INSERT INTO studentclasses VALUES (18991, 4203, 3077, 9);
INSERT INTO studentclasses VALUES (18992, 4203, 3117, 11);
INSERT INTO studentclasses VALUES (18993, 4203, 3086, 13);
INSERT INTO studentclasses VALUES (18994, 4203, 3118, 12);
INSERT INTO studentclasses VALUES (18995, 4204, 3077, 6);
INSERT INTO studentclasses VALUES (18996, 4204, 3119, 11);
INSERT INTO studentclasses VALUES (18997, 4204, 3120, 9);
INSERT INTO studentclasses VALUES (18998, 4204, 3121, 5);
INSERT INTO studentclasses VALUES (18999, 4204, 3111, 7);
INSERT INTO studentclasses VALUES (19000, 4205, 3122, 5);
INSERT INTO studentclasses VALUES (19001, 4205, 3123, 9);
INSERT INTO studentclasses VALUES (19002, 4205, 3113, 11);
INSERT INTO studentclasses VALUES (19003, 4205, 3098, 11);
INSERT INTO studentclasses VALUES (19004, 4205, 3058, 5);
INSERT INTO studentclasses VALUES (19005, 4206, 3124, 4);
INSERT INTO studentclasses VALUES (19006, 4206, 3125, 5);
INSERT INTO studentclasses VALUES (19007, 4206, 3126, 9);
INSERT INTO studentclasses VALUES (19008, 4206, 3127, 1);
INSERT INTO studentclasses VALUES (19009, 4206, 3072, 13);
INSERT INTO studentclasses VALUES (19010, 4206, 3085, 8);
INSERT INTO studentclasses VALUES (19011, 4207, 3128, 3);
INSERT INTO studentclasses VALUES (19012, 4207, 3129, 9);
INSERT INTO studentclasses VALUES (19013, 4207, 3130, 5);
INSERT INTO studentclasses VALUES (19014, 4207, 3131, 5);
INSERT INTO studentclasses VALUES (19015, 4207, 3132, 6);
INSERT INTO studentclasses VALUES (19016, 4208, 3133, 2);
INSERT INTO studentclasses VALUES (19017, 4208, 3037, 6);
INSERT INTO studentclasses VALUES (19018, 4208, 3119, 8);
INSERT INTO studentclasses VALUES (19019, 4208, 3134, 6);
INSERT INTO studentclasses VALUES (19020, 4208, 3058, 9);
INSERT INTO studentclasses VALUES (19021, 4208, 3135, 3);
INSERT INTO studentclasses VALUES (19022, 4209, 3136, 4);
INSERT INTO studentclasses VALUES (19023, 4209, 3137, 5);
INSERT INTO studentclasses VALUES (19024, 4209, 3138, 6);
INSERT INTO studentclasses VALUES (19025, 4209, 3139, 7);
INSERT INTO studentclasses VALUES (19026, 4209, 3140, 3);
INSERT INTO studentclasses VALUES (19027, 4210, 3141, 4);
INSERT INTO studentclasses VALUES (19028, 4210, 3142, 5);
INSERT INTO studentclasses VALUES (19029, 4210, 3143, 2);
INSERT INTO studentclasses VALUES (19030, 4210, 3144, 3);
INSERT INTO studentclasses VALUES (19031, 4210, 3145, 2);
INSERT INTO studentclasses VALUES (19032, 4211, 3146, 6);
INSERT INTO studentclasses VALUES (19033, 4211, 3147, 9);
INSERT INTO studentclasses VALUES (19034, 4211, 3148, 6);
INSERT INTO studentclasses VALUES (19035, 4211, 3149, 9);
INSERT INTO studentclasses VALUES (19036, 4211, 3150, 6);
INSERT INTO studentclasses VALUES (19037, 4212, 3151, 2);
INSERT INTO studentclasses VALUES (19038, 4212, 3152, 11);
INSERT INTO studentclasses VALUES (19039, 4212, 3070, 8);
INSERT INTO studentclasses VALUES (19040, 4212, 3153, 1);
INSERT INTO studentclasses VALUES (19041, 4212, 3097, 5);
INSERT INTO studentclasses VALUES (19042, 4213, 3154, 5);
INSERT INTO studentclasses VALUES (19043, 4213, 3155, 7);
INSERT INTO studentclasses VALUES (19044, 4213, 3156, 8);
INSERT INTO studentclasses VALUES (19045, 4213, 3157, 4);
INSERT INTO studentclasses VALUES (19046, 4213, 3145, 7);
INSERT INTO studentclasses VALUES (19047, 4214, 3158, 7);
INSERT INTO studentclasses VALUES (19048, 4214, 3159, 5);
INSERT INTO studentclasses VALUES (19049, 4214, 3138, 10);
INSERT INTO studentclasses VALUES (19050, 4214, 3160, 2);
INSERT INTO studentclasses VALUES (19051, 4214, 3161, 9);
INSERT INTO studentclasses VALUES (19052, 4215, 3162, 12);
INSERT INTO studentclasses VALUES (19053, 4215, 3163, 9);
INSERT INTO studentclasses VALUES (19054, 4215, 3164, 2);
INSERT INTO studentclasses VALUES (19055, 4215, 3165, 3);
INSERT INTO studentclasses VALUES (19056, 4215, 3039, 3);
INSERT INTO studentclasses VALUES (19057, 4216, 3166, 5);
INSERT INTO studentclasses VALUES (19058, 4216, 3167, 6);
INSERT INTO studentclasses VALUES (19059, 4216, 3168, 7);
INSERT INTO studentclasses VALUES (19060, 4216, 3169, 5);
INSERT INTO studentclasses VALUES (19061, 4216, 3161, 1);
INSERT INTO studentclasses VALUES (19062, 4217, 3170, 5);
INSERT INTO studentclasses VALUES (19063, 4217, 3136, 4);
INSERT INTO studentclasses VALUES (19064, 4217, 3147, 8);
INSERT INTO studentclasses VALUES (19065, 4217, 3171, 2);
INSERT INTO studentclasses VALUES (19066, 4217, 3161, 7);
INSERT INTO studentclasses VALUES (19067, 4218, 3172, 9);
INSERT INTO studentclasses VALUES (19068, 4218, 3167, 7);
INSERT INTO studentclasses VALUES (19069, 4218, 3173, 8);
INSERT INTO studentclasses VALUES (19070, 4218, 3174, 13);
INSERT INTO studentclasses VALUES (19071, 4218, 3175, 9);
INSERT INTO studentclasses VALUES (19072, 4219, 3176, 4);
INSERT INTO studentclasses VALUES (19073, 4219, 3129, 6);
INSERT INTO studentclasses VALUES (19074, 4219, 3070, 7);
INSERT INTO studentclasses VALUES (19075, 4219, 3177, 8);
INSERT INTO studentclasses VALUES (19076, 4219, 3097, 5);
INSERT INTO studentclasses VALUES (19077, 4220, 3178, 3);
INSERT INTO studentclasses VALUES (19078, 4220, 3179, 8);
INSERT INTO studentclasses VALUES (19079, 4220, 3041, 6);
INSERT INTO studentclasses VALUES (19080, 4220, 3091, 2);
INSERT INTO studentclasses VALUES (19081, 4220, 3150, 10);
INSERT INTO studentclasses VALUES (19082, 4221, 3176, 5);
INSERT INTO studentclasses VALUES (19083, 4221, 3180, 10);
INSERT INTO studentclasses VALUES (19084, 4221, 3181, 11);
INSERT INTO studentclasses VALUES (19085, 4221, 3182, 8);
INSERT INTO studentclasses VALUES (19086, 4221, 3097, 5);
INSERT INTO studentclasses VALUES (19087, 4222, 3183, 6);
INSERT INTO studentclasses VALUES (19088, 4222, 3138, 7);
INSERT INTO studentclasses VALUES (19089, 4222, 3184, 2);
INSERT INTO studentclasses VALUES (19090, 4222, 3127, 3);
INSERT INTO studentclasses VALUES (19091, 4222, 3161, 6);
INSERT INTO studentclasses VALUES (19092, 4223, 3185, 8);
INSERT INTO studentclasses VALUES (19093, 4223, 3186, 3);
INSERT INTO studentclasses VALUES (19094, 4223, 3187, 8);
INSERT INTO studentclasses VALUES (19095, 4223, 3188, 5);
INSERT INTO studentclasses VALUES (19096, 4223, 3145, 1);
INSERT INTO studentclasses VALUES (19097, 4224, 3189, 2);
INSERT INTO studentclasses VALUES (19098, 4224, 3190, 6);
INSERT INTO studentclasses VALUES (19099, 4224, 3149, 4);
INSERT INTO studentclasses VALUES (19100, 4224, 3191, 4);
INSERT INTO studentclasses VALUES (19101, 4224, 3175, 6);
INSERT INTO studentclasses VALUES (19102, 4225, 3192, 5);
INSERT INTO studentclasses VALUES (19103, 4225, 3193, 8);
INSERT INTO studentclasses VALUES (19104, 4225, 3194, 7);
INSERT INTO studentclasses VALUES (19105, 4225, 3160, 2);
INSERT INTO studentclasses VALUES (19106, 4225, 3145, 3);
INSERT INTO studentclasses VALUES (19107, 4226, 3195, 8);
INSERT INTO studentclasses VALUES (19108, 4226, 3156, 9);
INSERT INTO studentclasses VALUES (19109, 4226, 3196, 5);
INSERT INTO studentclasses VALUES (19110, 4226, 3197, 2);
INSERT INTO studentclasses VALUES (19111, 4226, 3097, 4);
INSERT INTO studentclasses VALUES (19112, 4227, 3198, 7);
INSERT INTO studentclasses VALUES (19113, 4227, 3199, 11);
INSERT INTO studentclasses VALUES (19114, 4227, 3200, 6);
INSERT INTO studentclasses VALUES (19115, 4227, 3047, 6);
INSERT INTO studentclasses VALUES (19116, 4227, 3191, 8);
INSERT INTO studentclasses VALUES (19117, 4228, 3201, 8);
INSERT INTO studentclasses VALUES (19118, 4228, 3202, 10);
INSERT INTO studentclasses VALUES (19119, 4228, 3167, 3);
INSERT INTO studentclasses VALUES (19120, 4228, 3203, 2);
INSERT INTO studentclasses VALUES (19121, 4228, 3204, 6);
INSERT INTO studentclasses VALUES (19122, 4228, 3191, 8);
INSERT INTO studentclasses VALUES (19123, 4229, 3205, 2);
INSERT INTO studentclasses VALUES (19124, 4229, 3206, 7);
INSERT INTO studentclasses VALUES (19125, 4229, 3207, 5);
INSERT INTO studentclasses VALUES (19126, 4229, 3130, 4);
INSERT INTO studentclasses VALUES (19127, 4229, 3150, 3);
INSERT INTO studentclasses VALUES (19128, 4230, 3208, 5);
INSERT INTO studentclasses VALUES (19129, 4230, 3186, 3);
INSERT INTO studentclasses VALUES (19130, 4230, 3190, 8);
INSERT INTO studentclasses VALUES (19131, 4230, 3209, 6);
INSERT INTO studentclasses VALUES (19132, 4230, 3097, 7);
INSERT INTO studentclasses VALUES (19133, 4231, 3210, 4);
INSERT INTO studentclasses VALUES (19134, 4231, 3211, 13);
INSERT INTO studentclasses VALUES (19135, 4231, 3207, 4);
INSERT INTO studentclasses VALUES (19136, 4231, 3212, 1);
INSERT INTO studentclasses VALUES (19137, 4231, 3140, 2);
INSERT INTO studentclasses VALUES (19138, 4232, 3192, 5);
INSERT INTO studentclasses VALUES (19139, 4232, 3213, 9);
INSERT INTO studentclasses VALUES (19140, 4232, 3194, 7);
INSERT INTO studentclasses VALUES (19141, 4232, 3160, 2);
INSERT INTO studentclasses VALUES (19142, 4232, 3165, 9);
INSERT INTO studentclasses VALUES (19143, 4233, 3214, 4);
INSERT INTO studentclasses VALUES (19144, 4233, 3186, 4);
INSERT INTO studentclasses VALUES (19145, 4233, 3152, 9);
INSERT INTO studentclasses VALUES (19146, 4233, 3215, 5);
INSERT INTO studentclasses VALUES (19147, 4233, 3145, 1);
INSERT INTO studentclasses VALUES (19148, 4234, 3216, 2);
INSERT INTO studentclasses VALUES (19149, 4234, 3217, 6);
INSERT INTO studentclasses VALUES (19150, 4234, 3218, 4);
INSERT INTO studentclasses VALUES (19151, 4234, 3047, 6);
INSERT INTO studentclasses VALUES (19152, 4234, 3097, 5);
INSERT INTO studentclasses VALUES (19153, 4235, 3219, 3);
INSERT INTO studentclasses VALUES (19154, 4235, 3220, 9);
INSERT INTO studentclasses VALUES (19155, 4235, 3221, 4);
INSERT INTO studentclasses VALUES (19156, 4235, 3209, 4);
INSERT INTO studentclasses VALUES (19157, 4235, 3165, 6);
INSERT INTO studentclasses VALUES (19158, 4236, 3222, 5);
INSERT INTO studentclasses VALUES (19159, 4236, 3180, 9);
INSERT INTO studentclasses VALUES (19160, 4236, 3181, 8);
INSERT INTO studentclasses VALUES (19161, 4236, 3223, 7);
INSERT INTO studentclasses VALUES (19162, 4236, 3097, 7);
INSERT INTO studentclasses VALUES (19163, 4237, 3224, 4);
INSERT INTO studentclasses VALUES (19164, 4237, 3193, 3);
INSERT INTO studentclasses VALUES (19165, 4237, 3070, 8);
INSERT INTO studentclasses VALUES (19166, 4237, 3197, 5);
INSERT INTO studentclasses VALUES (19167, 4237, 3150, 3);
INSERT INTO studentclasses VALUES (19168, 4238, 3225, 7);
INSERT INTO studentclasses VALUES (19169, 4238, 3138, 6);
INSERT INTO studentclasses VALUES (19170, 4238, 3148, 7);
INSERT INTO studentclasses VALUES (19171, 4238, 3226, 12);
INSERT INTO studentclasses VALUES (19172, 4238, 3097, 9);
INSERT INTO studentclasses VALUES (19173, 4239, 3227, 3);
INSERT INTO studentclasses VALUES (19174, 4239, 3228, 4);
INSERT INTO studentclasses VALUES (19175, 4239, 3229, 11);
INSERT INTO studentclasses VALUES (19176, 4239, 3230, 7);
INSERT INTO studentclasses VALUES (19177, 4239, 3161, 8);
INSERT INTO studentclasses VALUES (19178, 4240, 3166, 5);
INSERT INTO studentclasses VALUES (19179, 4240, 3138, 7);
INSERT INTO studentclasses VALUES (19180, 4240, 3215, 7);
INSERT INTO studentclasses VALUES (19181, 4240, 3231, 5);
INSERT INTO studentclasses VALUES (19182, 4240, 3191, 8);
INSERT INTO studentclasses VALUES (19183, 4241, 3133, 3);
INSERT INTO studentclasses VALUES (19184, 4241, 3211, 7);
INSERT INTO studentclasses VALUES (19185, 4241, 3232, 11);
INSERT INTO studentclasses VALUES (19186, 4241, 3233, 2);
INSERT INTO studentclasses VALUES (19187, 4241, 3145, 4);
INSERT INTO studentclasses VALUES (19188, 4242, 3234, 2);
INSERT INTO studentclasses VALUES (19189, 4242, 3235, 8);
INSERT INTO studentclasses VALUES (19190, 4242, 3236, 4);
INSERT INTO studentclasses VALUES (19191, 4242, 3237, 5);
INSERT INTO studentclasses VALUES (19192, 4242, 3132, 8);
INSERT INTO studentclasses VALUES (19193, 4243, 3238, 8);
INSERT INTO studentclasses VALUES (19194, 4244, 3239, 4);
INSERT INTO studentclasses VALUES (19195, 4244, 3240, 6);
INSERT INTO studentclasses VALUES (19196, 4245, 3241, 2);
INSERT INTO studentclasses VALUES (19197, 4246, 3242, 2);
INSERT INTO studentclasses VALUES (19198, 4247, 3243, 4);
INSERT INTO studentclasses VALUES (19199, 4248, 3244, 3);
INSERT INTO studentclasses VALUES (19200, 4248, 3245, 5);
INSERT INTO studentclasses VALUES (19201, 4248, 3246, 9);
INSERT INTO studentclasses VALUES (19202, 4249, 3247, 3);
INSERT INTO studentclasses VALUES (19203, 4249, 3248, 6);
INSERT INTO studentclasses VALUES (19204, 4250, 3249, 6);
INSERT INTO studentclasses VALUES (19205, 4251, 3250, 8);
INSERT INTO studentclasses VALUES (19206, 4252, 3251, 8);
INSERT INTO studentclasses VALUES (19207, 4253, 3252, 1);
INSERT INTO studentclasses VALUES (19208, 4254, 3253, 9);
INSERT INTO studentclasses VALUES (19209, 4255, 3254, 11);
INSERT INTO studentclasses VALUES (19210, 4255, 3248, 7);
INSERT INTO studentclasses VALUES (19211, 4256, 3255, 6);
INSERT INTO studentclasses VALUES (19212, 4256, 3256, 8);
INSERT INTO studentclasses VALUES (19213, 4257, 3257, 9);
INSERT INTO studentclasses VALUES (19214, 4258, 3258, 8);
INSERT INTO studentclasses VALUES (19215, 4259, 3259, 4);
INSERT INTO studentclasses VALUES (19216, 4259, 3260, 2);
INSERT INTO studentclasses VALUES (19217, 4260, 3261, 9);
INSERT INTO studentclasses VALUES (19218, 4261, 3262, 9);
INSERT INTO studentclasses VALUES (19219, 4262, 3263, 8);
INSERT INTO studentclasses VALUES (19220, 4263, 3264, 2);
INSERT INTO studentclasses VALUES (19221, 4263, 3265, 1);
INSERT INTO studentclasses VALUES (19222, 4264, 3266, 3);
INSERT INTO studentclasses VALUES (19223, 4265, 3267, 6);
INSERT INTO studentclasses VALUES (19224, 4266, 3268, 11);
INSERT INTO studentclasses VALUES (19225, 4267, 3269, 9);
INSERT INTO studentclasses VALUES (19226, 4267, 3270, 6);
INSERT INTO studentclasses VALUES (19227, 4268, 3271, 9);
INSERT INTO studentclasses VALUES (19228, 4269, 3272, 3);
INSERT INTO studentclasses VALUES (19229, 4269, 3260, 3);
INSERT INTO studentclasses VALUES (19230, 4270, 3273, 3);
INSERT INTO studentclasses VALUES (19231, 4270, 3274, 4);
INSERT INTO studentclasses VALUES (19232, 4271, 3268, 11);
INSERT INTO studentclasses VALUES (19233, 4272, 3257, 5);
INSERT INTO studentclasses VALUES (19234, 4273, 3266, 9);
INSERT INTO studentclasses VALUES (19235, 4274, 3275, 6);
INSERT INTO studentclasses VALUES (19236, 4274, 3261, 7);
INSERT INTO studentclasses VALUES (19237, 4275, 3276, 1);
INSERT INTO studentclasses VALUES (19238, 4276, 3277, 8);
INSERT INTO studentclasses VALUES (19239, 4277, 3278, 4);
INSERT INTO studentclasses VALUES (19240, 4278, 3279, 12);
INSERT INTO studentclasses VALUES (19241, 4278, 3280, 9);
INSERT INTO studentclasses VALUES (19242, 4278, 3281, 11);
INSERT INTO studentclasses VALUES (19243, 4278, 3282, 11);
INSERT INTO studentclasses VALUES (19244, 4278, 3283, 11);
INSERT INTO studentclasses VALUES (19245, 4279, 3284, 7);
INSERT INTO studentclasses VALUES (19246, 4280, 3285, 13);
INSERT INTO studentclasses VALUES (19247, 4280, 3286, 4);
INSERT INTO studentclasses VALUES (19248, 4280, 3287, 11);
INSERT INTO studentclasses VALUES (19249, 4280, 3288, 9);
INSERT INTO studentclasses VALUES (19250, 4280, 3280, 5);
INSERT INTO studentclasses VALUES (19251, 4280, 3289, 5);
INSERT INTO studentclasses VALUES (19252, 4280, 3290, 2);
INSERT INTO studentclasses VALUES (19253, 4281, 3291, 6);
INSERT INTO studentclasses VALUES (19254, 4281, 3292, 4);
INSERT INTO studentclasses VALUES (19255, 4281, 3290, 12);
INSERT INTO studentclasses VALUES (19256, 4282, 3293, 5);
INSERT INTO studentclasses VALUES (19257, 4282, 3294, 5);
INSERT INTO studentclasses VALUES (19258, 4282, 3295, 14);
INSERT INTO studentclasses VALUES (19259, 4282, 3280, 5);
INSERT INTO studentclasses VALUES (19260, 4282, 3296, 4);
INSERT INTO studentclasses VALUES (19261, 4282, 3297, 4);
INSERT INTO studentclasses VALUES (19262, 4282, 3298, 13);
INSERT INTO studentclasses VALUES (19263, 4283, 3299, 11);
INSERT INTO studentclasses VALUES (19264, 4283, 3300, 9);
INSERT INTO studentclasses VALUES (19265, 4283, 3289, 11);
INSERT INTO studentclasses VALUES (19266, 4283, 3301, 2);
INSERT INTO studentclasses VALUES (19267, 4283, 3302, 12);
INSERT INTO studentclasses VALUES (19268, 4284, 3286, 2);
INSERT INTO studentclasses VALUES (19269, 4284, 3303, 4);
INSERT INTO studentclasses VALUES (19270, 4284, 3304, 13);
INSERT INTO studentclasses VALUES (19271, 4284, 3305, 11);
INSERT INTO studentclasses VALUES (19272, 4284, 3306, 5);
INSERT INTO studentclasses VALUES (19273, 4284, 3307, 8);
INSERT INTO studentclasses VALUES (19274, 4285, 3308, 7);
INSERT INTO studentclasses VALUES (19275, 4285, 3309, 13);
INSERT INTO studentclasses VALUES (19276, 4285, 3305, 9);
INSERT INTO studentclasses VALUES (19277, 4285, 3280, 8);
INSERT INTO studentclasses VALUES (19278, 4285, 3306, 5);
INSERT INTO studentclasses VALUES (19279, 4285, 3310, 6);
INSERT INTO studentclasses VALUES (19280, 4286, 3311, 5);
INSERT INTO studentclasses VALUES (19281, 4286, 3312, 2);
INSERT INTO studentclasses VALUES (19282, 4286, 3313, 2);
INSERT INTO studentclasses VALUES (19283, 4286, 3314, 2);
INSERT INTO studentclasses VALUES (19284, 4286, 3315, 8);
INSERT INTO studentclasses VALUES (19285, 4287, 3316, 6);
INSERT INTO studentclasses VALUES (19286, 4287, 3317, 5);
INSERT INTO studentclasses VALUES (19287, 4287, 3294, 13);
INSERT INTO studentclasses VALUES (19288, 4287, 3318, 14);
INSERT INTO studentclasses VALUES (19289, 4287, 3319, 9);
INSERT INTO studentclasses VALUES (19290, 4287, 3320, 8);
INSERT INTO studentclasses VALUES (19291, 4287, 3298, 10);
INSERT INTO studentclasses VALUES (19292, 4288, 3321, 4);
INSERT INTO studentclasses VALUES (19293, 4288, 3322, 13);
INSERT INTO studentclasses VALUES (19294, 4288, 3280, 8);
INSERT INTO studentclasses VALUES (19295, 4288, 3281, 9);
INSERT INTO studentclasses VALUES (19296, 4288, 3296, 4);
INSERT INTO studentclasses VALUES (19297, 4289, 3323, 3);
INSERT INTO studentclasses VALUES (19298, 4289, 3294, 11);
INSERT INTO studentclasses VALUES (19299, 4289, 3324, 14);
INSERT INTO studentclasses VALUES (19300, 4289, 3325, 8);
INSERT INTO studentclasses VALUES (19301, 4289, 3305, 9);
INSERT INTO studentclasses VALUES (19302, 4289, 3310, 4);
INSERT INTO studentclasses VALUES (19303, 4289, 3302, 7);
INSERT INTO studentclasses VALUES (19304, 4289, 3283, 8);
INSERT INTO studentclasses VALUES (19305, 4290, 3299, 9);
INSERT INTO studentclasses VALUES (19306, 4290, 3326, 3);
INSERT INTO studentclasses VALUES (19307, 4290, 3296, 5);
INSERT INTO studentclasses VALUES (19308, 4290, 3289, 6);
INSERT INTO studentclasses VALUES (19309, 4290, 3297, 5);
INSERT INTO studentclasses VALUES (19310, 4290, 3298, 11);
INSERT INTO studentclasses VALUES (19311, 4291, 3327, 7);
INSERT INTO studentclasses VALUES (19312, 4291, 3294, 11);
INSERT INTO studentclasses VALUES (19313, 4291, 3318, 14);
INSERT INTO studentclasses VALUES (19314, 4291, 3280, 5);
INSERT INTO studentclasses VALUES (19315, 4291, 3328, 5);
INSERT INTO studentclasses VALUES (19316, 4291, 3306, 12);
INSERT INTO studentclasses VALUES (19317, 4291, 3329, 11);
INSERT INTO studentclasses VALUES (19318, 4292, 3330, 6);
INSERT INTO studentclasses VALUES (19319, 4292, 3331, 11);
INSERT INTO studentclasses VALUES (19320, 4292, 3332, 10);
INSERT INTO studentclasses VALUES (19321, 4292, 3294, 8);
INSERT INTO studentclasses VALUES (19322, 4292, 3324, 14);
INSERT INTO studentclasses VALUES (19323, 4292, 3333, 4);
INSERT INTO studentclasses VALUES (19324, 4293, 3334, 4);
INSERT INTO studentclasses VALUES (19325, 4293, 3332, 6);
INSERT INTO studentclasses VALUES (19326, 4293, 3294, 7);
INSERT INTO studentclasses VALUES (19327, 4293, 3335, 14);
INSERT INTO studentclasses VALUES (19328, 4293, 3336, 5);
INSERT INTO studentclasses VALUES (19329, 4293, 3337, 4);
INSERT INTO studentclasses VALUES (19330, 4294, 3338, 4);
INSERT INTO studentclasses VALUES (19331, 4294, 3294, 2);
INSERT INTO studentclasses VALUES (19332, 4294, 3324, 14);
INSERT INTO studentclasses VALUES (19333, 4294, 3339, 9);
INSERT INTO studentclasses VALUES (19334, 4294, 3328, 5);
INSERT INTO studentclasses VALUES (19335, 4294, 3306, 7);
INSERT INTO studentclasses VALUES (19336, 4294, 3340, 11);
INSERT INTO studentclasses VALUES (19337, 4294, 3298, 9);
INSERT INTO studentclasses VALUES (19338, 4295, 3341, 5);
INSERT INTO studentclasses VALUES (19339, 4295, 3293, 6);
INSERT INTO studentclasses VALUES (19340, 4295, 3294, 11);
INSERT INTO studentclasses VALUES (19341, 4295, 3324, 14);
INSERT INTO studentclasses VALUES (19342, 4295, 3319, 9);
INSERT INTO studentclasses VALUES (19343, 4295, 3320, 9);
INSERT INTO studentclasses VALUES (19344, 4295, 3329, 9);
INSERT INTO studentclasses VALUES (19345, 4296, 3331, 13);
INSERT INTO studentclasses VALUES (19346, 4296, 3332, 11);
INSERT INTO studentclasses VALUES (19347, 4296, 3342, 10);
INSERT INTO studentclasses VALUES (19348, 4296, 3343, 9);
INSERT INTO studentclasses VALUES (19349, 4296, 3344, 9);
INSERT INTO studentclasses VALUES (19350, 4297, 3345, 3);
INSERT INTO studentclasses VALUES (19351, 4297, 3328, 4);
INSERT INTO studentclasses VALUES (19352, 4297, 3301, 4);
INSERT INTO studentclasses VALUES (19353, 4297, 3346, 7);
INSERT INTO studentclasses VALUES (19354, 4297, 3298, 11);
INSERT INTO studentclasses VALUES (19355, 4298, 3347, 11);
INSERT INTO studentclasses VALUES (19356, 4298, 3348, 11);
INSERT INTO studentclasses VALUES (19357, 4298, 3349, 2);
INSERT INTO studentclasses VALUES (19358, 4298, 3350, 6);
INSERT INTO studentclasses VALUES (19359, 4298, 3282, 12);
INSERT INTO studentclasses VALUES (19360, 4299, 3351, 8);
INSERT INTO studentclasses VALUES (19361, 4299, 3319, 6);
INSERT INTO studentclasses VALUES (19362, 4299, 3320, 9);
INSERT INTO studentclasses VALUES (19363, 4299, 3301, 4);
INSERT INTO studentclasses VALUES (19364, 4299, 3352, 4);
INSERT INTO studentclasses VALUES (19365, 4299, 3298, 11);
INSERT INTO studentclasses VALUES (19366, 4300, 3353, 13);
INSERT INTO studentclasses VALUES (19367, 4300, 3294, 11);
INSERT INTO studentclasses VALUES (19368, 4300, 3318, 14);
INSERT INTO studentclasses VALUES (19369, 4300, 3280, 8);
INSERT INTO studentclasses VALUES (19370, 4300, 3328, 3);
INSERT INTO studentclasses VALUES (19371, 4300, 3306, 5);
INSERT INTO studentclasses VALUES (19372, 4300, 3329, 8);
INSERT INTO studentclasses VALUES (19373, 4301, 3332, 10);
INSERT INTO studentclasses VALUES (19374, 4301, 3294, 11);
INSERT INTO studentclasses VALUES (19375, 4301, 3335, 14);
INSERT INTO studentclasses VALUES (19376, 4301, 3280, 6);
INSERT INTO studentclasses VALUES (19377, 4301, 3281, 6);
INSERT INTO studentclasses VALUES (19378, 4301, 3296, 5);
INSERT INTO studentclasses VALUES (19379, 4301, 3329, 11);
INSERT INTO studentclasses VALUES (19380, 4302, 3354, 6);
INSERT INTO studentclasses VALUES (19381, 4302, 3355, 8);
INSERT INTO studentclasses VALUES (19382, 4302, 3294, 5);
INSERT INTO studentclasses VALUES (19383, 4302, 3324, 14);
INSERT INTO studentclasses VALUES (19384, 4302, 3319, 3);
INSERT INTO studentclasses VALUES (19385, 4302, 3281, 4);
INSERT INTO studentclasses VALUES (19386, 4303, 3356, 2);
INSERT INTO studentclasses VALUES (19387, 4303, 3357, 5);
INSERT INTO studentclasses VALUES (19388, 4303, 3358, 11);
INSERT INTO studentclasses VALUES (19389, 4303, 3359, 8);
INSERT INTO studentclasses VALUES (19390, 4303, 3314, 4);
INSERT INTO studentclasses VALUES (19391, 4304, 3360, 5);
INSERT INTO studentclasses VALUES (19392, 4304, 3294, 6);
INSERT INTO studentclasses VALUES (19393, 4304, 3295, 14);
INSERT INTO studentclasses VALUES (19394, 4304, 3280, 3);
INSERT INTO studentclasses VALUES (19395, 4304, 3343, 2);
INSERT INTO studentclasses VALUES (19396, 4304, 3306, 6);
INSERT INTO studentclasses VALUES (19397, 4304, 3329, 8);
INSERT INTO studentclasses VALUES (19398, 4305, 3361, 4);
INSERT INTO studentclasses VALUES (19399, 4305, 3362, 4);
INSERT INTO studentclasses VALUES (19400, 4305, 3363, 11);
INSERT INTO studentclasses VALUES (19401, 4305, 3364, 9);
INSERT INTO studentclasses VALUES (19402, 4305, 3365, 4);
INSERT INTO studentclasses VALUES (19403, 4306, 3366, 4);
INSERT INTO studentclasses VALUES (19404, 4306, 3367, 3);
INSERT INTO studentclasses VALUES (19405, 4306, 3368, 9);
INSERT INTO studentclasses VALUES (19406, 4306, 3369, 9);
INSERT INTO studentclasses VALUES (19407, 4306, 3365, 8);
INSERT INTO studentclasses VALUES (19408, 4307, 3370, 3);
INSERT INTO studentclasses VALUES (19409, 4307, 3371, 7);
INSERT INTO studentclasses VALUES (19410, 4307, 3372, 8);
INSERT INTO studentclasses VALUES (19411, 4307, 3314, 2);
INSERT INTO studentclasses VALUES (19412, 4308, 3373, 2);
INSERT INTO studentclasses VALUES (19413, 4308, 3374, 9);
INSERT INTO studentclasses VALUES (19414, 4308, 3375, 3);
INSERT INTO studentclasses VALUES (19415, 4308, 3376, 11);
INSERT INTO studentclasses VALUES (19416, 4309, 3377, 5);
INSERT INTO studentclasses VALUES (19417, 4309, 3378, 5);
INSERT INTO studentclasses VALUES (19418, 4309, 3379, 5);
INSERT INTO studentclasses VALUES (19419, 4309, 3380, 5);
INSERT INTO studentclasses VALUES (19420, 4309, 3333, 2);
INSERT INTO studentclasses VALUES (19421, 4310, 3381, 2);
INSERT INTO studentclasses VALUES (19422, 4310, 3382, 9);
INSERT INTO studentclasses VALUES (19423, 4310, 3375, 7);
INSERT INTO studentclasses VALUES (19424, 4310, 3383, 7);
INSERT INTO studentclasses VALUES (19425, 4310, 3384, 7);
INSERT INTO studentclasses VALUES (19426, 4311, 3385, 3);
INSERT INTO studentclasses VALUES (19427, 4311, 3386, 2);
INSERT INTO studentclasses VALUES (19428, 4311, 3363, 7);
INSERT INTO studentclasses VALUES (19429, 4311, 3387, 7);
INSERT INTO studentclasses VALUES (19430, 4311, 3365, 5);
INSERT INTO studentclasses VALUES (19431, 4312, 3388, 1);
INSERT INTO studentclasses VALUES (19432, 4312, 3389, 9);
INSERT INTO studentclasses VALUES (19433, 4312, 3390, 7);
INSERT INTO studentclasses VALUES (19434, 4312, 3391, 3);
INSERT INTO studentclasses VALUES (19435, 4312, 3384, 5);
INSERT INTO studentclasses VALUES (19436, 4313, 3392, 11);
INSERT INTO studentclasses VALUES (19437, 4313, 3393, 8);
INSERT INTO studentclasses VALUES (19438, 4313, 3394, 2);
INSERT INTO studentclasses VALUES (19439, 4313, 3395, 6);
INSERT INTO studentclasses VALUES (19440, 4314, 3396, 5);
INSERT INTO studentclasses VALUES (19441, 4314, 3397, 9);
INSERT INTO studentclasses VALUES (19442, 4314, 3398, 11);
INSERT INTO studentclasses VALUES (19443, 4314, 3383, 9);
INSERT INTO studentclasses VALUES (19444, 4315, 3399, 3);
INSERT INTO studentclasses VALUES (19445, 4315, 3400, 9);
INSERT INTO studentclasses VALUES (19446, 4315, 3401, 7);
INSERT INTO studentclasses VALUES (19447, 4315, 3402, 3);
INSERT INTO studentclasses VALUES (19448, 4315, 3333, 7);
INSERT INTO studentclasses VALUES (19449, 4316, 3386, 3);
INSERT INTO studentclasses VALUES (19450, 4316, 3403, 3);
INSERT INTO studentclasses VALUES (19451, 4316, 3363, 7);
INSERT INTO studentclasses VALUES (19452, 4316, 3404, 8);
INSERT INTO studentclasses VALUES (19453, 4316, 3405, 13);
INSERT INTO studentclasses VALUES (19454, 4317, 3386, 3);
INSERT INTO studentclasses VALUES (19455, 4317, 3406, 3);
INSERT INTO studentclasses VALUES (19456, 4317, 3379, 7);
INSERT INTO studentclasses VALUES (19457, 4317, 3407, 1);
INSERT INTO studentclasses VALUES (19458, 4317, 3405, 9);
INSERT INTO studentclasses VALUES (19459, 4318, 3408, 4);
INSERT INTO studentclasses VALUES (19460, 4318, 3371, 7);
INSERT INTO studentclasses VALUES (19461, 4318, 3409, 7);
INSERT INTO studentclasses VALUES (19462, 4318, 3333, 1);
INSERT INTO studentclasses VALUES (19463, 4319, 3410, 8);
INSERT INTO studentclasses VALUES (19464, 4319, 3411, 9);
INSERT INTO studentclasses VALUES (19465, 4319, 3412, 7);
INSERT INTO studentclasses VALUES (19466, 4319, 3413, 3);
INSERT INTO studentclasses VALUES (19467, 4319, 3365, 6);
INSERT INTO studentclasses VALUES (19468, 4320, 3414, 11);
INSERT INTO studentclasses VALUES (19469, 4320, 3415, 9);
INSERT INTO studentclasses VALUES (19470, 4320, 3416, 8);
INSERT INTO studentclasses VALUES (19471, 4320, 3417, 7);
INSERT INTO studentclasses VALUES (19472, 4320, 3395, 3);
INSERT INTO studentclasses VALUES (19473, 4321, 3418, 2);
INSERT INTO studentclasses VALUES (19474, 4321, 3419, 7);
INSERT INTO studentclasses VALUES (19475, 4321, 3420, 11);
INSERT INTO studentclasses VALUES (19476, 4321, 3421, 3);
INSERT INTO studentclasses VALUES (19477, 4321, 3314, 5);
INSERT INTO studentclasses VALUES (19478, 4322, 3422, 12);
INSERT INTO studentclasses VALUES (19479, 4322, 3363, 8);
INSERT INTO studentclasses VALUES (19480, 4322, 3404, 9);
INSERT INTO studentclasses VALUES (19481, 4322, 3405, 6);
INSERT INTO studentclasses VALUES (19482, 4323, 3423, 2);
INSERT INTO studentclasses VALUES (19483, 4323, 3424, 1);
INSERT INTO studentclasses VALUES (19484, 4323, 3374, 13);
INSERT INTO studentclasses VALUES (19485, 4323, 3425, 7);
INSERT INTO studentclasses VALUES (19486, 4323, 3314, 3);
INSERT INTO studentclasses VALUES (19487, 4324, 3426, 1);
INSERT INTO studentclasses VALUES (19488, 4324, 3427, 7);
INSERT INTO studentclasses VALUES (19489, 4324, 3390, 6);
INSERT INTO studentclasses VALUES (19490, 4324, 3428, 5);
INSERT INTO studentclasses VALUES (19491, 4324, 3384, 7);
INSERT INTO studentclasses VALUES (19492, 4325, 3429, 5);
INSERT INTO studentclasses VALUES (19493, 4325, 3430, 5);
INSERT INTO studentclasses VALUES (19494, 4325, 3431, 9);
INSERT INTO studentclasses VALUES (19495, 4325, 3372, 9);
INSERT INTO studentclasses VALUES (19496, 4325, 3314, 2);
INSERT INTO studentclasses VALUES (19497, 4326, 3432, 7);
INSERT INTO studentclasses VALUES (19498, 4326, 3433, 9);
INSERT INTO studentclasses VALUES (19499, 4326, 3393, 5);
INSERT INTO studentclasses VALUES (19500, 4326, 3395, 9);
INSERT INTO studentclasses VALUES (19501, 4327, 3378, 5);
INSERT INTO studentclasses VALUES (19502, 4327, 3434, 9);
INSERT INTO studentclasses VALUES (19503, 4327, 3435, 1);
INSERT INTO studentclasses VALUES (19504, 4327, 3436, 5);
INSERT INTO studentclasses VALUES (19505, 4327, 3349, 4);
INSERT INTO studentclasses VALUES (19506, 4328, 3437, 2);
INSERT INTO studentclasses VALUES (19507, 4328, 3438, 3);
INSERT INTO studentclasses VALUES (19508, 4328, 3439, 3);
INSERT INTO studentclasses VALUES (19509, 4328, 3349, 2);
INSERT INTO studentclasses VALUES (19510, 4328, 3319, 4);
INSERT INTO studentclasses VALUES (19511, 4329, 3440, 2);
INSERT INTO studentclasses VALUES (19512, 4329, 3441, 5);
INSERT INTO studentclasses VALUES (19513, 4329, 3442, 5);
INSERT INTO studentclasses VALUES (19514, 4329, 3333, 4);
INSERT INTO studentclasses VALUES (19515, 4329, 3443, 3);
INSERT INTO studentclasses VALUES (19516, 4330, 3444, 3);
INSERT INTO studentclasses VALUES (19517, 4330, 3445, 3);
INSERT INTO studentclasses VALUES (19518, 4330, 3446, 8);
INSERT INTO studentclasses VALUES (19519, 4330, 3393, 7);
INSERT INTO studentclasses VALUES (19520, 4330, 3384, 9);
INSERT INTO studentclasses VALUES (19521, 4331, 3445, 4);
INSERT INTO studentclasses VALUES (19522, 4331, 3447, 9);
INSERT INTO studentclasses VALUES (19523, 4331, 3375, 7);
INSERT INTO studentclasses VALUES (19524, 4331, 3448, 8);
INSERT INTO studentclasses VALUES (19525, 4331, 3395, 7);
INSERT INTO studentclasses VALUES (19526, 4332, 3449, 4);
INSERT INTO studentclasses VALUES (19527, 4332, 3450, 8);
INSERT INTO studentclasses VALUES (19528, 4332, 3451, 9);
INSERT INTO studentclasses VALUES (19529, 4332, 3395, 5);
INSERT INTO studentclasses VALUES (19530, 4333, 3378, 11);
INSERT INTO studentclasses VALUES (19531, 4333, 3415, 11);
INSERT INTO studentclasses VALUES (19532, 4333, 3452, 12);
INSERT INTO studentclasses VALUES (19533, 4333, 3395, 12);
INSERT INTO studentclasses VALUES (19534, 4333, 3319, 11);
INSERT INTO studentclasses VALUES (19535, 4334, 3453, 3);
INSERT INTO studentclasses VALUES (19536, 4334, 3441, 7);
INSERT INTO studentclasses VALUES (19537, 4334, 3387, 9);
INSERT INTO studentclasses VALUES (19538, 4334, 3454, 5);
INSERT INTO studentclasses VALUES (19539, 4334, 3349, 3);
INSERT INTO studentclasses VALUES (19540, 4335, 3455, 4);
INSERT INTO studentclasses VALUES (19541, 4335, 3374, 9);
INSERT INTO studentclasses VALUES (19542, 4335, 3375, 5);
INSERT INTO studentclasses VALUES (19543, 4335, 3336, 3);
INSERT INTO studentclasses VALUES (19544, 4336, 3456, 3);
INSERT INTO studentclasses VALUES (19545, 4336, 3389, 9);
INSERT INTO studentclasses VALUES (19546, 4336, 3457, 6);
INSERT INTO studentclasses VALUES (19547, 4336, 3333, 7);
INSERT INTO studentclasses VALUES (19548, 4337, 3458, 2);
INSERT INTO studentclasses VALUES (19549, 4337, 3455, 4);
INSERT INTO studentclasses VALUES (19550, 4337, 3374, 8);
INSERT INTO studentclasses VALUES (19551, 4337, 3375, 6);
INSERT INTO studentclasses VALUES (19552, 4337, 3336, 4);
INSERT INTO studentclasses VALUES (19553, 4338, 3459, 4);
INSERT INTO studentclasses VALUES (19554, 4338, 3446, 9);
INSERT INTO studentclasses VALUES (19555, 4338, 3390, 6);
INSERT INTO studentclasses VALUES (19556, 4338, 3454, 2);
INSERT INTO studentclasses VALUES (19557, 4338, 3314, 6);
INSERT INTO studentclasses VALUES (19558, 4339, 3444, 3);
INSERT INTO studentclasses VALUES (19559, 4339, 3427, 9);
INSERT INTO studentclasses VALUES (19560, 4339, 3375, 9);
INSERT INTO studentclasses VALUES (19561, 4339, 3460, 4);
INSERT INTO studentclasses VALUES (19562, 4339, 3384, 8);
INSERT INTO studentclasses VALUES (19563, 4340, 3461, 3);
INSERT INTO studentclasses VALUES (19564, 4340, 3462, 9);
INSERT INTO studentclasses VALUES (19565, 4340, 3393, 7);
INSERT INTO studentclasses VALUES (19566, 4340, 3463, 1);
INSERT INTO studentclasses VALUES (19567, 4340, 3333, 5);
INSERT INTO studentclasses VALUES (19568, 4340, 3319, 6);
INSERT INTO studentclasses VALUES (19569, 4341, 3426, 1);
INSERT INTO studentclasses VALUES (19570, 4341, 3427, 9);
INSERT INTO studentclasses VALUES (19571, 4341, 3390, 6);
INSERT INTO studentclasses VALUES (19572, 4341, 3428, 6);
INSERT INTO studentclasses VALUES (19573, 4341, 3384, 8);
INSERT INTO studentclasses VALUES (19574, 4342, 3464, 6);
INSERT INTO studentclasses VALUES (19575, 4342, 3378, 8);
INSERT INTO studentclasses VALUES (19576, 4342, 3465, 7);
INSERT INTO studentclasses VALUES (19577, 4342, 3466, 5);
INSERT INTO studentclasses VALUES (19578, 4342, 3349, 2);
INSERT INTO studentclasses VALUES (19579, 4343, 3467, 5);
INSERT INTO studentclasses VALUES (19580, 4343, 3468, 11);
INSERT INTO studentclasses VALUES (19581, 4343, 3469, 8);
INSERT INTO studentclasses VALUES (19582, 4343, 3470, 4);
INSERT INTO studentclasses VALUES (19583, 4343, 3384, 9);
INSERT INTO studentclasses VALUES (19584, 4344, 3386, 2);
INSERT INTO studentclasses VALUES (19585, 4344, 3471, 2);
INSERT INTO studentclasses VALUES (19586, 4344, 3472, 6);
INSERT INTO studentclasses VALUES (19587, 4344, 3434, 7);
INSERT INTO studentclasses VALUES (19588, 4344, 3314, 3);
INSERT INTO studentclasses VALUES (19589, 4345, 3473, 4);
INSERT INTO studentclasses VALUES (19590, 4345, 3474, 4);
INSERT INTO studentclasses VALUES (19591, 4345, 3331, 11);
INSERT INTO studentclasses VALUES (19592, 4345, 3475, 8);
INSERT INTO studentclasses VALUES (19593, 4345, 3349, 6);
INSERT INTO studentclasses VALUES (19594, 4346, 3476, 7);
INSERT INTO studentclasses VALUES (19595, 4346, 3477, 10);
INSERT INTO studentclasses VALUES (19596, 4346, 3425, 8);
INSERT INTO studentclasses VALUES (19597, 4346, 3478, 7);
INSERT INTO studentclasses VALUES (19598, 4346, 3333, 7);
INSERT INTO studentclasses VALUES (19599, 4347, 3479, 3);
INSERT INTO studentclasses VALUES (19600, 4347, 3446, 13);
INSERT INTO studentclasses VALUES (19601, 4347, 3434, 9);
INSERT INTO studentclasses VALUES (19602, 4347, 3421, 3);
INSERT INTO studentclasses VALUES (19603, 4347, 3333, 8);
INSERT INTO studentclasses VALUES (19604, 4348, 3480, 4);
INSERT INTO studentclasses VALUES (19605, 4348, 3481, 3);
INSERT INTO studentclasses VALUES (19606, 4348, 3468, 7);
INSERT INTO studentclasses VALUES (19607, 4348, 3482, 9);
INSERT INTO studentclasses VALUES (19608, 4348, 3416, 8);
INSERT INTO studentclasses VALUES (19609, 4348, 3333, 8);
INSERT INTO studentclasses VALUES (19610, 4349, 3483, 7);
INSERT INTO studentclasses VALUES (19611, 4349, 3484, 9);
INSERT INTO studentclasses VALUES (19612, 4349, 3485, 12);
INSERT INTO studentclasses VALUES (19613, 4349, 3333, 7);
INSERT INTO studentclasses VALUES (19614, 4349, 3486, 4);
INSERT INTO studentclasses VALUES (19615, 4350, 3397, 9);
INSERT INTO studentclasses VALUES (19616, 4350, 3393, 9);
INSERT INTO studentclasses VALUES (19617, 4350, 3487, 5);
INSERT INTO studentclasses VALUES (19618, 4350, 3314, 9);
INSERT INTO studentclasses VALUES (19619, 4351, 3488, 5);
INSERT INTO studentclasses VALUES (19620, 4351, 3489, 1);
INSERT INTO studentclasses VALUES (19621, 4351, 3416, 4);
INSERT INTO studentclasses VALUES (19622, 4351, 3490, 7);
INSERT INTO studentclasses VALUES (19623, 4351, 3491, 1);
INSERT INTO studentclasses VALUES (19624, 4352, 3492, 5);
INSERT INTO studentclasses VALUES (19625, 4352, 3489, 2);
INSERT INTO studentclasses VALUES (19626, 4352, 3493, 3);
INSERT INTO studentclasses VALUES (19627, 4352, 3448, 6);
INSERT INTO studentclasses VALUES (19628, 4352, 3491, 3);
INSERT INTO studentclasses VALUES (19629, 4353, 3494, 4);
INSERT INTO studentclasses VALUES (19630, 4353, 3495, 8);
INSERT INTO studentclasses VALUES (19631, 4353, 3496, 6);
INSERT INTO studentclasses VALUES (19632, 4353, 3497, 1);
INSERT INTO studentclasses VALUES (19633, 4353, 3498, 3);
INSERT INTO studentclasses VALUES (19634, 4354, 3499, 5);
INSERT INTO studentclasses VALUES (19635, 4354, 3500, 7);
INSERT INTO studentclasses VALUES (19636, 4354, 3501, 5);
INSERT INTO studentclasses VALUES (19637, 4354, 3466, 3);
INSERT INTO studentclasses VALUES (19638, 4354, 3502, 9);
INSERT INTO studentclasses VALUES (19639, 4355, 3503, 5);
INSERT INTO studentclasses VALUES (19640, 4355, 3504, 4);
INSERT INTO studentclasses VALUES (19641, 4355, 3505, 1);
INSERT INTO studentclasses VALUES (19642, 4355, 3506, 1);
INSERT INTO studentclasses VALUES (19643, 4355, 3507, 4);
INSERT INTO studentclasses VALUES (19644, 4356, 3508, 4);
INSERT INTO studentclasses VALUES (19645, 4356, 3509, 6);
INSERT INTO studentclasses VALUES (19646, 4356, 3510, 7);
INSERT INTO studentclasses VALUES (19647, 4356, 3511, 2);
INSERT INTO studentclasses VALUES (19648, 4356, 3502, 3);
INSERT INTO studentclasses VALUES (19649, 4357, 3512, 6);
INSERT INTO studentclasses VALUES (19650, 4357, 3513, 8);
INSERT INTO studentclasses VALUES (19651, 4357, 3510, 6);
INSERT INTO studentclasses VALUES (19652, 4357, 3514, 3);
INSERT INTO studentclasses VALUES (19653, 4357, 3515, 11);
INSERT INTO studentclasses VALUES (19654, 4358, 3354, 5);
INSERT INTO studentclasses VALUES (19655, 4358, 3516, 5);
INSERT INTO studentclasses VALUES (19656, 4358, 3517, 5);
INSERT INTO studentclasses VALUES (19657, 4358, 3518, 8);
INSERT INTO studentclasses VALUES (19658, 4358, 3502, 8);
INSERT INTO studentclasses VALUES (19659, 4359, 3519, 3);
INSERT INTO studentclasses VALUES (19660, 4359, 3520, 6);
INSERT INTO studentclasses VALUES (19661, 4359, 3521, 2);
INSERT INTO studentclasses VALUES (19662, 4359, 3522, 1);
INSERT INTO studentclasses VALUES (19663, 4359, 3523, 8);
INSERT INTO studentclasses VALUES (19664, 4360, 3494, 3);
INSERT INTO studentclasses VALUES (19665, 4360, 3495, 4);
INSERT INTO studentclasses VALUES (19666, 4360, 3496, 4);
INSERT INTO studentclasses VALUES (19667, 4360, 3497, 1);
INSERT INTO studentclasses VALUES (19668, 4360, 3498, 2);
INSERT INTO studentclasses VALUES (19669, 4361, 3354, 4);
INSERT INTO studentclasses VALUES (19670, 4361, 3524, 2);
INSERT INTO studentclasses VALUES (19671, 4361, 3500, 8);
INSERT INTO studentclasses VALUES (19672, 4361, 3525, 1);
INSERT INTO studentclasses VALUES (19673, 4361, 3502, 1);
INSERT INTO studentclasses VALUES (19674, 4362, 3526, 3);
INSERT INTO studentclasses VALUES (19675, 4362, 3527, 6);
INSERT INTO studentclasses VALUES (19676, 4362, 3504, 8);
INSERT INTO studentclasses VALUES (19677, 4362, 3528, 1);
INSERT INTO studentclasses VALUES (19678, 4362, 3507, 7);
INSERT INTO studentclasses VALUES (19679, 4363, 3494, 3);
INSERT INTO studentclasses VALUES (19680, 4363, 3495, 5);
INSERT INTO studentclasses VALUES (19681, 4363, 3496, 11);
INSERT INTO studentclasses VALUES (19682, 4363, 3497, 6);
INSERT INTO studentclasses VALUES (19683, 4363, 3498, 8);
INSERT INTO studentclasses VALUES (19684, 4364, 3512, 5);
INSERT INTO studentclasses VALUES (19685, 4364, 3513, 7);
INSERT INTO studentclasses VALUES (19686, 4364, 3510, 7);
INSERT INTO studentclasses VALUES (19687, 4364, 3514, 2);
INSERT INTO studentclasses VALUES (19688, 4364, 3515, 7);
INSERT INTO studentclasses VALUES (19689, 4365, 3494, 3);
INSERT INTO studentclasses VALUES (19690, 4365, 3495, 6);
INSERT INTO studentclasses VALUES (19691, 4365, 3496, 6);
INSERT INTO studentclasses VALUES (19692, 4365, 3497, 1);
INSERT INTO studentclasses VALUES (19693, 4365, 3498, 1);
INSERT INTO studentclasses VALUES (19694, 4366, 3512, 5);
INSERT INTO studentclasses VALUES (19695, 4366, 3513, 1);
INSERT INTO studentclasses VALUES (19696, 4366, 3510, 4);
INSERT INTO studentclasses VALUES (19697, 4366, 3514, 3);
INSERT INTO studentclasses VALUES (19698, 4366, 3515, 1);
INSERT INTO studentclasses VALUES (19699, 4367, 3519, 4);
INSERT INTO studentclasses VALUES (19700, 4367, 3520, 3);
INSERT INTO studentclasses VALUES (19701, 4367, 3521, 3);
INSERT INTO studentclasses VALUES (19702, 4367, 3522, 3);
INSERT INTO studentclasses VALUES (19703, 4367, 3523, 1);
INSERT INTO studentclasses VALUES (19704, 4368, 3529, 4);
INSERT INTO studentclasses VALUES (19705, 4368, 3504, 11);
INSERT INTO studentclasses VALUES (19706, 4368, 3505, 6);
INSERT INTO studentclasses VALUES (19707, 4368, 3530, 5);
INSERT INTO studentclasses VALUES (19708, 4368, 3507, 8);
INSERT INTO studentclasses VALUES (19709, 4369, 3531, 2);
INSERT INTO studentclasses VALUES (19710, 4369, 3532, 5);
INSERT INTO studentclasses VALUES (19711, 4369, 3504, 7);
INSERT INTO studentclasses VALUES (19712, 4369, 3507, 5);
INSERT INTO studentclasses VALUES (19713, 4369, 3533, 3);
INSERT INTO studentclasses VALUES (19714, 4370, 3461, 1);
INSERT INTO studentclasses VALUES (19715, 4370, 3534, 5);
INSERT INTO studentclasses VALUES (19716, 4370, 3535, 1);
INSERT INTO studentclasses VALUES (19717, 4370, 3536, 8);
INSERT INTO studentclasses VALUES (19718, 4370, 3336, 4);
INSERT INTO studentclasses VALUES (19719, 4371, 3537, 5);
INSERT INTO studentclasses VALUES (19720, 4371, 3538, 6);
INSERT INTO studentclasses VALUES (19721, 4371, 3510, 6);
INSERT INTO studentclasses VALUES (19722, 4371, 3539, 2);
INSERT INTO studentclasses VALUES (19723, 4371, 3336, 4);
INSERT INTO studentclasses VALUES (19724, 4372, 3540, 6);
INSERT INTO studentclasses VALUES (19725, 4372, 3541, 1);
INSERT INTO studentclasses VALUES (19726, 4372, 3542, 2);
INSERT INTO studentclasses VALUES (19727, 4372, 3336, 3);
INSERT INTO studentclasses VALUES (19728, 4372, 3543, 3);
INSERT INTO studentclasses VALUES (19729, 4373, 3512, 6);
INSERT INTO studentclasses VALUES (19730, 4373, 3513, 8);
INSERT INTO studentclasses VALUES (19731, 4373, 3510, 7);
INSERT INTO studentclasses VALUES (19732, 4373, 3514, 3);
INSERT INTO studentclasses VALUES (19733, 4373, 3515, 11);
INSERT INTO studentclasses VALUES (19734, 4374, 3512, 6);
INSERT INTO studentclasses VALUES (19735, 4374, 3513, 5);
INSERT INTO studentclasses VALUES (19736, 4374, 3510, 7);
INSERT INTO studentclasses VALUES (19737, 4374, 3514, 5);
INSERT INTO studentclasses VALUES (19738, 4374, 3515, 7);
INSERT INTO studentclasses VALUES (19739, 4375, 3544, 3);
INSERT INTO studentclasses VALUES (19740, 4375, 3489, 2);
INSERT INTO studentclasses VALUES (19741, 4375, 3493, 2);
INSERT INTO studentclasses VALUES (19742, 4375, 3545, 5);
INSERT INTO studentclasses VALUES (19743, 4375, 3491, 3);
INSERT INTO studentclasses VALUES (19744, 4376, 3519, 4);
INSERT INTO studentclasses VALUES (19745, 4376, 3520, 4);
INSERT INTO studentclasses VALUES (19746, 4376, 3521, 1);
INSERT INTO studentclasses VALUES (19747, 4376, 3522, 1);
INSERT INTO studentclasses VALUES (19748, 4376, 3523, 7);
INSERT INTO studentclasses VALUES (19749, 4377, 3519, 3);
INSERT INTO studentclasses VALUES (19750, 4377, 3520, 5);
INSERT INTO studentclasses VALUES (19751, 4377, 3521, 3);
INSERT INTO studentclasses VALUES (19752, 4377, 3522, 2);
INSERT INTO studentclasses VALUES (19753, 4377, 3523, 4);
INSERT INTO studentclasses VALUES (19754, 4378, 3546, 7);
INSERT INTO studentclasses VALUES (19755, 4378, 3547, 8);
INSERT INTO studentclasses VALUES (19756, 4378, 3501, 4);
INSERT INTO studentclasses VALUES (19757, 4378, 3548, 4);
INSERT INTO studentclasses VALUES (19758, 4378, 3502, 8);
INSERT INTO studentclasses VALUES (19759, 4379, 3549, 4);
INSERT INTO studentclasses VALUES (19760, 4379, 3489, 3);
INSERT INTO studentclasses VALUES (19761, 4379, 3542, 3);
INSERT INTO studentclasses VALUES (19762, 4379, 3550, 8);
INSERT INTO studentclasses VALUES (19763, 4379, 3491, 5);
INSERT INTO studentclasses VALUES (19764, 4380, 3512, 5);
INSERT INTO studentclasses VALUES (19765, 4380, 3513, 8);
INSERT INTO studentclasses VALUES (19766, 4380, 3510, 4);
INSERT INTO studentclasses VALUES (19767, 4380, 3514, 4);
INSERT INTO studentclasses VALUES (19768, 4380, 3515, 9);
INSERT INTO studentclasses VALUES (19769, 4381, 3551, 3);
INSERT INTO studentclasses VALUES (19770, 4381, 3532, 5);
INSERT INTO studentclasses VALUES (19771, 4381, 3504, 11);
INSERT INTO studentclasses VALUES (19772, 4381, 3552, 6);
INSERT INTO studentclasses VALUES (19773, 4381, 3507, 8);
INSERT INTO studentclasses VALUES (19774, 4382, 3553, 5);
INSERT INTO studentclasses VALUES (19775, 4382, 3504, 4);
INSERT INTO studentclasses VALUES (19776, 4382, 3416, 7);
INSERT INTO studentclasses VALUES (19777, 4382, 3554, 1);
INSERT INTO studentclasses VALUES (19778, 4382, 3507, 4);
INSERT INTO studentclasses VALUES (19779, 4383, 3488, 5);
INSERT INTO studentclasses VALUES (19780, 4383, 3489, 1);
INSERT INTO studentclasses VALUES (19781, 4383, 3383, 4);
INSERT INTO studentclasses VALUES (19782, 4383, 3555, 1);
INSERT INTO studentclasses VALUES (19783, 4383, 3491, 2);
INSERT INTO studentclasses VALUES (19784, 4384, 3556, 5);
INSERT INTO studentclasses VALUES (19785, 4384, 3504, 5);
INSERT INTO studentclasses VALUES (19786, 4384, 3505, 2);
INSERT INTO studentclasses VALUES (19787, 4384, 3536, 6);
INSERT INTO studentclasses VALUES (19788, 4384, 3507, 5);
INSERT INTO studentclasses VALUES (19789, 4385, 3488, 4);
INSERT INTO studentclasses VALUES (19790, 4385, 3489, 4);
INSERT INTO studentclasses VALUES (19791, 4385, 3557, 2);
INSERT INTO studentclasses VALUES (19792, 4385, 3558, 2);
INSERT INTO studentclasses VALUES (19793, 4385, 3491, 3);
INSERT INTO studentclasses VALUES (19794, 4386, 3559, 3);
INSERT INTO studentclasses VALUES (19795, 4386, 3489, 6);
INSERT INTO studentclasses VALUES (19796, 4386, 3535, 7);
INSERT INTO studentclasses VALUES (19797, 4386, 3560, 1);
INSERT INTO studentclasses VALUES (19798, 4386, 3491, 3);
INSERT INTO studentclasses VALUES (19799, 4387, 3561, 4);
INSERT INTO studentclasses VALUES (19800, 4387, 3504, 11);
INSERT INTO studentclasses VALUES (19801, 4387, 3557, 2);
INSERT INTO studentclasses VALUES (19802, 4387, 3562, 5);
INSERT INTO studentclasses VALUES (19803, 4387, 3507, 5);
INSERT INTO studentclasses VALUES (19804, 4388, 3563, 6);
INSERT INTO studentclasses VALUES (19805, 4388, 3524, 6);
INSERT INTO studentclasses VALUES (19806, 4388, 3564, 9);
INSERT INTO studentclasses VALUES (19807, 4388, 3565, 5);
INSERT INTO studentclasses VALUES (19808, 4388, 3502, 9);
INSERT INTO studentclasses VALUES (19809, 4389, 3512, 6);
INSERT INTO studentclasses VALUES (19810, 4389, 3513, 8);
INSERT INTO studentclasses VALUES (19811, 4389, 3510, 6);
INSERT INTO studentclasses VALUES (19812, 4389, 3514, 5);
INSERT INTO studentclasses VALUES (19813, 4389, 3515, 2);
INSERT INTO studentclasses VALUES (19814, 4390, 3512, 6);
INSERT INTO studentclasses VALUES (19815, 4390, 3513, 6);
INSERT INTO studentclasses VALUES (19816, 4390, 3510, 4);
INSERT INTO studentclasses VALUES (19817, 4390, 3514, 7);
INSERT INTO studentclasses VALUES (19818, 4390, 3515, 1);
INSERT INTO studentclasses VALUES (19819, 4391, 3503, 5);
INSERT INTO studentclasses VALUES (19820, 4391, 3504, 7);
INSERT INTO studentclasses VALUES (19821, 4391, 3383, 7);
INSERT INTO studentclasses VALUES (19822, 4391, 3552, 5);
INSERT INTO studentclasses VALUES (19823, 4391, 3507, 4);
INSERT INTO studentclasses VALUES (19824, 4392, 3546, 7);
INSERT INTO studentclasses VALUES (19825, 4392, 3566, 1);
INSERT INTO studentclasses VALUES (19826, 4392, 3517, 4);
INSERT INTO studentclasses VALUES (19827, 4392, 3567, 3);
INSERT INTO studentclasses VALUES (19828, 4392, 3507, 5);
INSERT INTO studentclasses VALUES (19829, 4393, 3494, 3);
INSERT INTO studentclasses VALUES (19830, 4393, 3495, 4);
INSERT INTO studentclasses VALUES (19831, 4393, 3496, 5);
INSERT INTO studentclasses VALUES (19832, 4393, 3497, 1);
INSERT INTO studentclasses VALUES (19833, 4393, 3498, 1);
INSERT INTO studentclasses VALUES (19834, 4394, 3512, 5);
INSERT INTO studentclasses VALUES (19835, 4394, 3513, 8);
INSERT INTO studentclasses VALUES (19836, 4394, 3510, 8);
INSERT INTO studentclasses VALUES (19837, 4394, 3514, 6);
INSERT INTO studentclasses VALUES (19838, 4394, 3515, 5);
INSERT INTO studentclasses VALUES (19839, 4395, 3568, 3);
INSERT INTO studentclasses VALUES (19840, 4395, 3569, 3);
INSERT INTO studentclasses VALUES (19841, 4395, 3489, 4);
INSERT INTO studentclasses VALUES (19842, 4395, 3535, 2);
INSERT INTO studentclasses VALUES (19843, 4395, 3491, 2);
INSERT INTO studentclasses VALUES (19844, 4396, 3519, 4);
INSERT INTO studentclasses VALUES (19845, 4396, 3520, 6);
INSERT INTO studentclasses VALUES (19846, 4396, 3521, 3);
INSERT INTO studentclasses VALUES (19847, 4396, 3522, 1);
INSERT INTO studentclasses VALUES (19848, 4396, 3523, 1);
INSERT INTO studentclasses VALUES (19849, 4397, 3570, 5);
INSERT INTO studentclasses VALUES (19850, 4397, 3571, 7);
INSERT INTO studentclasses VALUES (19851, 4397, 3521, 1);
INSERT INTO studentclasses VALUES (19852, 4397, 3572, 5);
INSERT INTO studentclasses VALUES (19853, 4397, 3502, 9);
INSERT INTO studentclasses VALUES (19854, 4398, 3494, 4);
INSERT INTO studentclasses VALUES (19855, 4398, 3495, 5);
INSERT INTO studentclasses VALUES (19856, 4398, 3496, 2);
INSERT INTO studentclasses VALUES (19857, 4398, 3497, 2);
INSERT INTO studentclasses VALUES (19858, 4398, 3498, 3);
INSERT INTO studentclasses VALUES (19859, 4399, 3519, 2);
INSERT INTO studentclasses VALUES (19860, 4399, 3520, 4);
INSERT INTO studentclasses VALUES (19861, 4399, 3521, 1);
INSERT INTO studentclasses VALUES (19862, 4399, 3522, 1);
INSERT INTO studentclasses VALUES (19863, 4399, 3523, 1);
INSERT INTO studentclasses VALUES (19864, 4400, 3499, 5);
INSERT INTO studentclasses VALUES (19865, 4400, 3524, 4);
INSERT INTO studentclasses VALUES (19866, 4400, 3500, 9);
INSERT INTO studentclasses VALUES (19867, 4400, 3573, 6);
INSERT INTO studentclasses VALUES (19868, 4400, 3502, 5);
INSERT INTO studentclasses VALUES (19869, 4401, 3574, 3);
INSERT INTO studentclasses VALUES (19870, 4401, 3524, 7);
INSERT INTO studentclasses VALUES (19871, 4401, 3575, 8);
INSERT INTO studentclasses VALUES (19872, 4401, 3454, 2);
INSERT INTO studentclasses VALUES (19873, 4401, 3502, 7);
INSERT INTO studentclasses VALUES (19874, 4402, 3494, 2);
INSERT INTO studentclasses VALUES (19875, 4402, 3495, 4);
INSERT INTO studentclasses VALUES (19876, 4402, 3496, 5);
INSERT INTO studentclasses VALUES (19877, 4402, 3497, 1);
INSERT INTO studentclasses VALUES (19878, 4402, 3498, 1);
INSERT INTO studentclasses VALUES (19879, 4403, 3494, 4);
INSERT INTO studentclasses VALUES (19880, 4403, 3495, 5);
INSERT INTO studentclasses VALUES (19881, 4403, 3496, 9);
INSERT INTO studentclasses VALUES (19882, 4403, 3497, 2);
INSERT INTO studentclasses VALUES (19883, 4403, 3498, 2);
INSERT INTO studentclasses VALUES (19884, 4404, 3494, 3);
INSERT INTO studentclasses VALUES (19885, 4404, 3495, 5);
INSERT INTO studentclasses VALUES (19886, 4404, 3496, 6);
INSERT INTO studentclasses VALUES (19887, 4404, 3497, 2);
INSERT INTO studentclasses VALUES (19888, 4404, 3498, 3);
INSERT INTO studentclasses VALUES (19889, 4405, 3576, 3);
INSERT INTO studentclasses VALUES (19890, 4405, 3489, 2);
INSERT INTO studentclasses VALUES (19891, 4405, 3542, 5);
INSERT INTO studentclasses VALUES (19892, 4405, 3577, 1);
INSERT INTO studentclasses VALUES (19893, 4405, 3491, 3);
INSERT INTO studentclasses VALUES (19894, 4406, 3512, 7);
INSERT INTO studentclasses VALUES (19895, 4406, 3513, 6);
INSERT INTO studentclasses VALUES (19896, 4406, 3510, 7);
INSERT INTO studentclasses VALUES (19897, 4406, 3514, 6);
INSERT INTO studentclasses VALUES (19898, 4406, 3515, 6);
INSERT INTO studentclasses VALUES (19899, 4407, 3551, 9);
INSERT INTO studentclasses VALUES (19900, 4407, 3504, 6);
INSERT INTO studentclasses VALUES (19901, 4407, 3416, 3);
INSERT INTO studentclasses VALUES (19902, 4407, 3550, 9);
INSERT INTO studentclasses VALUES (19903, 4407, 3507, 1);
INSERT INTO studentclasses VALUES (19904, 4408, 3540, 5);
INSERT INTO studentclasses VALUES (19905, 4408, 3566, 1);
INSERT INTO studentclasses VALUES (19906, 4408, 3510, 1);
INSERT INTO studentclasses VALUES (19907, 4408, 3550, 1);
INSERT INTO studentclasses VALUES (19908, 4408, 3507, 1);
INSERT INTO studentclasses VALUES (19909, 4409, 3578, 4);
INSERT INTO studentclasses VALUES (19910, 4409, 3504, 1);
INSERT INTO studentclasses VALUES (19911, 4409, 3487, 2);
INSERT INTO studentclasses VALUES (19912, 4409, 3579, 1);
INSERT INTO studentclasses VALUES (19913, 4409, 3507, 3);
INSERT INTO studentclasses VALUES (19914, 4410, 3531, 3);
INSERT INTO studentclasses VALUES (19915, 4410, 3504, 1);
INSERT INTO studentclasses VALUES (19916, 4410, 3505, 4);
INSERT INTO studentclasses VALUES (19917, 4410, 3579, 2);
INSERT INTO studentclasses VALUES (19918, 4410, 3507, 1);
INSERT INTO studentclasses VALUES (19919, 4411, 3549, 4);
INSERT INTO studentclasses VALUES (19920, 4411, 3580, 4);
INSERT INTO studentclasses VALUES (19921, 4411, 3504, 6);
INSERT INTO studentclasses VALUES (19922, 4411, 3487, 3);
INSERT INTO studentclasses VALUES (19923, 4411, 3507, 1);
INSERT INTO studentclasses VALUES (19924, 4412, 3578, 4);
INSERT INTO studentclasses VALUES (19925, 4412, 3581, 5);
INSERT INTO studentclasses VALUES (19926, 4412, 3489, 4);
INSERT INTO studentclasses VALUES (19927, 4412, 3582, 4);
INSERT INTO studentclasses VALUES (19928, 4412, 3491, 5);
INSERT INTO studentclasses VALUES (19929, 4413, 3583, 4);
INSERT INTO studentclasses VALUES (19930, 4413, 3534, 9);
INSERT INTO studentclasses VALUES (19931, 4413, 3487, 4);
INSERT INTO studentclasses VALUES (19932, 4413, 3584, 5);
INSERT INTO studentclasses VALUES (19933, 4413, 3502, 1);
INSERT INTO studentclasses VALUES (19934, 4414, 3585, 5);
INSERT INTO studentclasses VALUES (19935, 4414, 3489, 1);
INSERT INTO studentclasses VALUES (19936, 4414, 3416, 2);
INSERT INTO studentclasses VALUES (19937, 4414, 3586, 2);
INSERT INTO studentclasses VALUES (19938, 4414, 3491, 3);
INSERT INTO studentclasses VALUES (19939, 4415, 3316, 5);
INSERT INTO studentclasses VALUES (19940, 4415, 3587, 6);
INSERT INTO studentclasses VALUES (19941, 4415, 3416, 6);
INSERT INTO studentclasses VALUES (19942, 4415, 3588, 5);
INSERT INTO studentclasses VALUES (19943, 4415, 3502, 8);
INSERT INTO studentclasses VALUES (19944, 4416, 3519, 3);
INSERT INTO studentclasses VALUES (19945, 4416, 3520, 3);
INSERT INTO studentclasses VALUES (19946, 4416, 3521, 1);
INSERT INTO studentclasses VALUES (19947, 4416, 3522, 1);
INSERT INTO studentclasses VALUES (19948, 4416, 3523, 1);
INSERT INTO studentclasses VALUES (19949, 4417, 3512, 6);
INSERT INTO studentclasses VALUES (19950, 4417, 3513, 6);
INSERT INTO studentclasses VALUES (19951, 4417, 3510, 5);
INSERT INTO studentclasses VALUES (19952, 4417, 3514, 3);
INSERT INTO studentclasses VALUES (19953, 4417, 3515, 6);
INSERT INTO studentclasses VALUES (19954, 4418, 3589, 8);
INSERT INTO studentclasses VALUES (19955, 4418, 3504, 5);
INSERT INTO studentclasses VALUES (19956, 4418, 3505, 2);
INSERT INTO studentclasses VALUES (19957, 4418, 3550, 10);
INSERT INTO studentclasses VALUES (19958, 4418, 3507, 6);
INSERT INTO studentclasses VALUES (19959, 4419, 3512, 6);
INSERT INTO studentclasses VALUES (19960, 4419, 3513, 9);
INSERT INTO studentclasses VALUES (19961, 4419, 3510, 7);
INSERT INTO studentclasses VALUES (19962, 4419, 3514, 2);
INSERT INTO studentclasses VALUES (19963, 4419, 3515, 7);
INSERT INTO studentclasses VALUES (19964, 4420, 3512, 6);
INSERT INTO studentclasses VALUES (19965, 4420, 3513, 11);
INSERT INTO studentclasses VALUES (19966, 4420, 3510, 8);
INSERT INTO studentclasses VALUES (19967, 4420, 3514, 6);
INSERT INTO studentclasses VALUES (19968, 4420, 3515, 7);
INSERT INTO studentclasses VALUES (19969, 4421, 3590, 5);
INSERT INTO studentclasses VALUES (19970, 4421, 3495, 3);
INSERT INTO studentclasses VALUES (19971, 4421, 3591, 2);
INSERT INTO studentclasses VALUES (19972, 4421, 3592, 1);
INSERT INTO studentclasses VALUES (19973, 4421, 3502, 1);
INSERT INTO studentclasses VALUES (19974, 4422, 3494, 3);
INSERT INTO studentclasses VALUES (19975, 4422, 3495, 7);
INSERT INTO studentclasses VALUES (19976, 4422, 3496, 9);
INSERT INTO studentclasses VALUES (19977, 4422, 3497, 1);
INSERT INTO studentclasses VALUES (19978, 4422, 3498, 4);
INSERT INTO studentclasses VALUES (19979, 4423, 3540, 5);
INSERT INTO studentclasses VALUES (19980, 4423, 3489, 3);
INSERT INTO studentclasses VALUES (19981, 4423, 3593, 2);
INSERT INTO studentclasses VALUES (19982, 4423, 3491, 4);
INSERT INTO studentclasses VALUES (19983, 4423, 3594, 3);
INSERT INTO studentclasses VALUES (19984, 4424, 3595, 3);
INSERT INTO studentclasses VALUES (19985, 4424, 3495, 6);
INSERT INTO studentclasses VALUES (19986, 4424, 3496, 3);
INSERT INTO studentclasses VALUES (19987, 4424, 3497, 2);
INSERT INTO studentclasses VALUES (19988, 4424, 3498, 2);
INSERT INTO studentclasses VALUES (19989, 4425, 3494, 5);
INSERT INTO studentclasses VALUES (19990, 4425, 3495, 4);
INSERT INTO studentclasses VALUES (19991, 4425, 3496, 2);
INSERT INTO studentclasses VALUES (19992, 4425, 3497, 1);
INSERT INTO studentclasses VALUES (19993, 4425, 3498, 1);
INSERT INTO studentclasses VALUES (19994, 4426, 3494, 4);
INSERT INTO studentclasses VALUES (19995, 4426, 3495, 6);
INSERT INTO studentclasses VALUES (19996, 4426, 3496, 8);
INSERT INTO studentclasses VALUES (19997, 4426, 3497, 2);
INSERT INTO studentclasses VALUES (19998, 4426, 3498, 4);
INSERT INTO studentclasses VALUES (19999, 4427, 3494, 4);
INSERT INTO studentclasses VALUES (20000, 4427, 3495, 7);
INSERT INTO studentclasses VALUES (20001, 4427, 3496, 8);
INSERT INTO studentclasses VALUES (20002, 4427, 3497, 2);
INSERT INTO studentclasses VALUES (20003, 4427, 3498, 5);
INSERT INTO studentclasses VALUES (20004, 4428, 3551, 5);
INSERT INTO studentclasses VALUES (20005, 4428, 3504, 6);
INSERT INTO studentclasses VALUES (20006, 4428, 3521, 1);
INSERT INTO studentclasses VALUES (20007, 4428, 3596, 1);
INSERT INTO studentclasses VALUES (20008, 4428, 3507, 5);
INSERT INTO studentclasses VALUES (20009, 4429, 3519, 3);
INSERT INTO studentclasses VALUES (20010, 4429, 3520, 9);
INSERT INTO studentclasses VALUES (20011, 4429, 3521, 2);
INSERT INTO studentclasses VALUES (20012, 4429, 3522, 1);
INSERT INTO studentclasses VALUES (20013, 4429, 3523, 5);
INSERT INTO studentclasses VALUES (20014, 4430, 3569, 6);
INSERT INTO studentclasses VALUES (20015, 4430, 3504, 6);
INSERT INTO studentclasses VALUES (20016, 4430, 3597, 6);
INSERT INTO studentclasses VALUES (20017, 4430, 3507, 6);
INSERT INTO studentclasses VALUES (20018, 4430, 3346, 8);
INSERT INTO studentclasses VALUES (20019, 4431, 3519, 4);
INSERT INTO studentclasses VALUES (20020, 4431, 3520, 6);
INSERT INTO studentclasses VALUES (20021, 4431, 3521, 2);
INSERT INTO studentclasses VALUES (20022, 4431, 3522, 2);
INSERT INTO studentclasses VALUES (20023, 4431, 3523, 8);
INSERT INTO studentclasses VALUES (20024, 4432, 3494, 5);
INSERT INTO studentclasses VALUES (20025, 4432, 3495, 8);
INSERT INTO studentclasses VALUES (20026, 4432, 3496, 8);
INSERT INTO studentclasses VALUES (20027, 4432, 3497, 4);
INSERT INTO studentclasses VALUES (20028, 4432, 3498, 1);
INSERT INTO studentclasses VALUES (20029, 4433, 3494, 4);
INSERT INTO studentclasses VALUES (20030, 4433, 3495, 8);
INSERT INTO studentclasses VALUES (20031, 4433, 3496, 9);
INSERT INTO studentclasses VALUES (20032, 4433, 3497, 3);
INSERT INTO studentclasses VALUES (20033, 4433, 3498, 8);
INSERT INTO studentclasses VALUES (20034, 4434, 3519, 3);
INSERT INTO studentclasses VALUES (20035, 4434, 3520, 7);
INSERT INTO studentclasses VALUES (20036, 4434, 3521, 3);
INSERT INTO studentclasses VALUES (20037, 4434, 3522, 1);
INSERT INTO studentclasses VALUES (20038, 4434, 3523, 3);
INSERT INTO studentclasses VALUES (20039, 4435, 3512, 6);
INSERT INTO studentclasses VALUES (20040, 4435, 3513, 7);
INSERT INTO studentclasses VALUES (20041, 4435, 3510, 6);
INSERT INTO studentclasses VALUES (20042, 4435, 3514, 3);
INSERT INTO studentclasses VALUES (20043, 4435, 3515, 2);
INSERT INTO studentclasses VALUES (20044, 4436, 3499, 4);
INSERT INTO studentclasses VALUES (20045, 4436, 3598, 11);
INSERT INTO studentclasses VALUES (20046, 4436, 3510, 6);
INSERT INTO studentclasses VALUES (20047, 4436, 3567, 4);
INSERT INTO studentclasses VALUES (20048, 4436, 3502, 1);
INSERT INTO studentclasses VALUES (20049, 4437, 3512, 4);
INSERT INTO studentclasses VALUES (20050, 4437, 3513, 9);
INSERT INTO studentclasses VALUES (20051, 4437, 3510, 7);
INSERT INTO studentclasses VALUES (20052, 4437, 3514, 6);
INSERT INTO studentclasses VALUES (20053, 4437, 3515, 4);
INSERT INTO studentclasses VALUES (20054, 4438, 3519, 5);
INSERT INTO studentclasses VALUES (20055, 4438, 3520, 9);
INSERT INTO studentclasses VALUES (20056, 4438, 3521, 4);
INSERT INTO studentclasses VALUES (20057, 4438, 3522, 1);
INSERT INTO studentclasses VALUES (20058, 4438, 3523, 9);
INSERT INTO studentclasses VALUES (20059, 4439, 3599, 4);
INSERT INTO studentclasses VALUES (20060, 4439, 3600, 5);
INSERT INTO studentclasses VALUES (20061, 4439, 3504, 6);
INSERT INTO studentclasses VALUES (20062, 4439, 3601, 1);
INSERT INTO studentclasses VALUES (20063, 4439, 3507, 4);
INSERT INTO studentclasses VALUES (20064, 4440, 3526, 4);
INSERT INTO studentclasses VALUES (20065, 4440, 3504, 8);
INSERT INTO studentclasses VALUES (20066, 4440, 3521, 3);
INSERT INTO studentclasses VALUES (20067, 4440, 3602, 9);
INSERT INTO studentclasses VALUES (20068, 4440, 3507, 6);
INSERT INTO studentclasses VALUES (20069, 4441, 3519, 3);
INSERT INTO studentclasses VALUES (20070, 4441, 3520, 9);
INSERT INTO studentclasses VALUES (20071, 4441, 3521, 1);
INSERT INTO studentclasses VALUES (20072, 4441, 3522, 3);
INSERT INTO studentclasses VALUES (20073, 4441, 3523, 4);
INSERT INTO studentclasses VALUES (20074, 4442, 3494, 3);
INSERT INTO studentclasses VALUES (20075, 4442, 3495, 6);
INSERT INTO studentclasses VALUES (20076, 4442, 3496, 7);
INSERT INTO studentclasses VALUES (20077, 4442, 3497, 4);
INSERT INTO studentclasses VALUES (20078, 4442, 3498, 5);
INSERT INTO studentclasses VALUES (20079, 4443, 3512, 7);
INSERT INTO studentclasses VALUES (20080, 4443, 3513, 9);
INSERT INTO studentclasses VALUES (20081, 4443, 3510, 7);
INSERT INTO studentclasses VALUES (20082, 4443, 3514, 6);
INSERT INTO studentclasses VALUES (20083, 4443, 3515, 10);
INSERT INTO studentclasses VALUES (20084, 4444, 3603, 5);
INSERT INTO studentclasses VALUES (20085, 4444, 3509, 4);
INSERT INTO studentclasses VALUES (20086, 4444, 3548, 2);
INSERT INTO studentclasses VALUES (20087, 4444, 3365, 4);
INSERT INTO studentclasses VALUES (20088, 4444, 3352, 2);
INSERT INTO studentclasses VALUES (20089, 4445, 3361, 3);
INSERT INTO studentclasses VALUES (20090, 4445, 3357, 6);
INSERT INTO studentclasses VALUES (20091, 4445, 3604, 7);
INSERT INTO studentclasses VALUES (20092, 4445, 3365, 5);
INSERT INTO studentclasses VALUES (20093, 4445, 3346, 6);
INSERT INTO studentclasses VALUES (20094, 4446, 3385, 1);
INSERT INTO studentclasses VALUES (20095, 4446, 3587, 5);
INSERT INTO studentclasses VALUES (20096, 4446, 3517, 5);
INSERT INTO studentclasses VALUES (20097, 4446, 3301, 2);
INSERT INTO studentclasses VALUES (20098, 4446, 3365, 1);
INSERT INTO studentclasses VALUES (20099, 4447, 3605, 11);
INSERT INTO studentclasses VALUES (20100, 4447, 3606, 10);
INSERT INTO studentclasses VALUES (20101, 4447, 3607, 7);
INSERT INTO studentclasses VALUES (20102, 4447, 3608, 11);
INSERT INTO studentclasses VALUES (20103, 4447, 3609, 9);
INSERT INTO studentclasses VALUES (20104, 4447, 3610, 1);
INSERT INTO studentclasses VALUES (20105, 4448, 3611, 6);
INSERT INTO studentclasses VALUES (20106, 4448, 3612, 4);
INSERT INTO studentclasses VALUES (20107, 4448, 3613, 3);
INSERT INTO studentclasses VALUES (20108, 4448, 3614, 2);
INSERT INTO studentclasses VALUES (20109, 4448, 3615, 3);
INSERT INTO studentclasses VALUES (20110, 4448, 3616, 14);
INSERT INTO studentclasses VALUES (20111, 4448, 3617, 1);
INSERT INTO studentclasses VALUES (20112, 4448, 3618, 11);
INSERT INTO studentclasses VALUES (20113, 4449, 3619, 6);
INSERT INTO studentclasses VALUES (20114, 4449, 3615, 3);
INSERT INTO studentclasses VALUES (20115, 4449, 3616, 14);
INSERT INTO studentclasses VALUES (20116, 4449, 3607, 5);
INSERT INTO studentclasses VALUES (20117, 4449, 3620, 4);
INSERT INTO studentclasses VALUES (20118, 4449, 3608, 2);
INSERT INTO studentclasses VALUES (20119, 4449, 3621, 4);
INSERT INTO studentclasses VALUES (20120, 4450, 3622, 4);
INSERT INTO studentclasses VALUES (20121, 4450, 3623, 3);
INSERT INTO studentclasses VALUES (20122, 4450, 3615, 4);
INSERT INTO studentclasses VALUES (20123, 4450, 3624, 14);
INSERT INTO studentclasses VALUES (20124, 4450, 3625, 9);
INSERT INTO studentclasses VALUES (20125, 4451, 3626, 3);
INSERT INTO studentclasses VALUES (20126, 4451, 3627, 5);
INSERT INTO studentclasses VALUES (20127, 4451, 3628, 2);
INSERT INTO studentclasses VALUES (20128, 4451, 3629, 7);
INSERT INTO studentclasses VALUES (20129, 4451, 3630, 10);
INSERT INTO studentclasses VALUES (20130, 4452, 3631, 7);
INSERT INTO studentclasses VALUES (20131, 4452, 3617, 5);
INSERT INTO studentclasses VALUES (20132, 4452, 3632, 7);
INSERT INTO studentclasses VALUES (20133, 4452, 3629, 7);
INSERT INTO studentclasses VALUES (20134, 4452, 3633, 9);
INSERT INTO studentclasses VALUES (20135, 4453, 3634, 13);
INSERT INTO studentclasses VALUES (20136, 4453, 3635, 4);
INSERT INTO studentclasses VALUES (20137, 4453, 3636, 4);
INSERT INTO studentclasses VALUES (20138, 4453, 3637, 7);
INSERT INTO studentclasses VALUES (20139, 4453, 3638, 9);
INSERT INTO studentclasses VALUES (20140, 4453, 3639, 3);
INSERT INTO studentclasses VALUES (20141, 4454, 3640, 2);
INSERT INTO studentclasses VALUES (20142, 4454, 3641, 7);
INSERT INTO studentclasses VALUES (20143, 4454, 3632, 13);
INSERT INTO studentclasses VALUES (20144, 4454, 3642, 7);
INSERT INTO studentclasses VALUES (20145, 4454, 3643, 3);
INSERT INTO studentclasses VALUES (20146, 4455, 3644, 8);
INSERT INTO studentclasses VALUES (20147, 4455, 3615, 3);
INSERT INTO studentclasses VALUES (20148, 4455, 3616, 14);
INSERT INTO studentclasses VALUES (20149, 4455, 3641, 7);
INSERT INTO studentclasses VALUES (20150, 4455, 3620, 1);
INSERT INTO studentclasses VALUES (20151, 4455, 3608, 1);
INSERT INTO studentclasses VALUES (20152, 4455, 3621, 7);
INSERT INTO studentclasses VALUES (20153, 4456, 3645, 13);
INSERT INTO studentclasses VALUES (20154, 4456, 3646, 8);
INSERT INTO studentclasses VALUES (20155, 4456, 3647, 5);
INSERT INTO studentclasses VALUES (20156, 4456, 3632, 13);
INSERT INTO studentclasses VALUES (20157, 4456, 3648, 5);
INSERT INTO studentclasses VALUES (20158, 4456, 3649, 2);
INSERT INTO studentclasses VALUES (20159, 4456, 3650, 12);
INSERT INTO studentclasses VALUES (20160, 4457, 3651, 9);
INSERT INTO studentclasses VALUES (20161, 4457, 3615, 11);
INSERT INTO studentclasses VALUES (20162, 4457, 3652, 14);
INSERT INTO studentclasses VALUES (20163, 4457, 3617, 5);
INSERT INTO studentclasses VALUES (20164, 4457, 3629, 8);
INSERT INTO studentclasses VALUES (20165, 4458, 3653, 10);
INSERT INTO studentclasses VALUES (20166, 4458, 3654, 6);
INSERT INTO studentclasses VALUES (20167, 4458, 3641, 6);
INSERT INTO studentclasses VALUES (20168, 4458, 3617, 6);
INSERT INTO studentclasses VALUES (20169, 4458, 3649, 2);
INSERT INTO studentclasses VALUES (20170, 4458, 3620, 7);
INSERT INTO studentclasses VALUES (20171, 4458, 3633, 13);
INSERT INTO studentclasses VALUES (20172, 4459, 3655, 7);
INSERT INTO studentclasses VALUES (20173, 4459, 3656, 7);
INSERT INTO studentclasses VALUES (20174, 4459, 3615, 4);
INSERT INTO studentclasses VALUES (20175, 4459, 3616, 14);
INSERT INTO studentclasses VALUES (20176, 4459, 3607, 6);
INSERT INTO studentclasses VALUES (20177, 4459, 3638, 9);
INSERT INTO studentclasses VALUES (20178, 4459, 3657, 8);
INSERT INTO studentclasses VALUES (20179, 4460, 3658, 3);
INSERT INTO studentclasses VALUES (20180, 4460, 3659, 4);
INSERT INTO studentclasses VALUES (20181, 4460, 3660, 3);
INSERT INTO studentclasses VALUES (20182, 4460, 3615, 11);
INSERT INTO studentclasses VALUES (20183, 4460, 3652, 14);
INSERT INTO studentclasses VALUES (20184, 4460, 3636, 7);
INSERT INTO studentclasses VALUES (20185, 4460, 3661, 9);
INSERT INTO studentclasses VALUES (20186, 4461, 3662, 4);
INSERT INTO studentclasses VALUES (20187, 4461, 3615, 5);
INSERT INTO studentclasses VALUES (20188, 4461, 3624, 14);
INSERT INTO studentclasses VALUES (20189, 4461, 3607, 6);
INSERT INTO studentclasses VALUES (20190, 4461, 3663, 4);
INSERT INTO studentclasses VALUES (20191, 4461, 3664, 3);
INSERT INTO studentclasses VALUES (20192, 4461, 3637, 4);
INSERT INTO studentclasses VALUES (20193, 4462, 3665, 9);
INSERT INTO studentclasses VALUES (20194, 4462, 3666, 5);
INSERT INTO studentclasses VALUES (20195, 4462, 3636, 7);
INSERT INTO studentclasses VALUES (20196, 4462, 3667, 7);
INSERT INTO studentclasses VALUES (20197, 4462, 3632, 4);
INSERT INTO studentclasses VALUES (20198, 4462, 3668, 4);
INSERT INTO studentclasses VALUES (20199, 4463, 3669, 12);
INSERT INTO studentclasses VALUES (20200, 4463, 3670, 11);
INSERT INTO studentclasses VALUES (20201, 4463, 3671, 8);
INSERT INTO studentclasses VALUES (20202, 4463, 3672, 9);
INSERT INTO studentclasses VALUES (20203, 4463, 3673, 12);
INSERT INTO studentclasses VALUES (20204, 4463, 3657, 5);
INSERT INTO studentclasses VALUES (20205, 4464, 3674, 2);
INSERT INTO studentclasses VALUES (20206, 4464, 3675, 2);
INSERT INTO studentclasses VALUES (20207, 4464, 3633, 9);
INSERT INTO studentclasses VALUES (20208, 4464, 3676, 6);
INSERT INTO studentclasses VALUES (20209, 4464, 3677, 4);
INSERT INTO studentclasses VALUES (20210, 4464, 3678, 2);
INSERT INTO studentclasses VALUES (20211, 4465, 3679, 7);
INSERT INTO studentclasses VALUES (20212, 4465, 3680, 11);
INSERT INTO studentclasses VALUES (20213, 4465, 3632, 13);
INSERT INTO studentclasses VALUES (20214, 4465, 3664, 13);
INSERT INTO studentclasses VALUES (20215, 4465, 3673, 13);
INSERT INTO studentclasses VALUES (20216, 4466, 3681, 1);
INSERT INTO studentclasses VALUES (20217, 4466, 3682, 2);
INSERT INTO studentclasses VALUES (20218, 4466, 3683, 5);
INSERT INTO studentclasses VALUES (20219, 4466, 3633, 8);
INSERT INTO studentclasses VALUES (20220, 4466, 3677, 3);
INSERT INTO studentclasses VALUES (20221, 4467, 3644, 13);
INSERT INTO studentclasses VALUES (20222, 4467, 3684, 4);
INSERT INTO studentclasses VALUES (20223, 4467, 3607, 5);
INSERT INTO studentclasses VALUES (20224, 4467, 3685, 5);
INSERT INTO studentclasses VALUES (20225, 4467, 3663, 2);
INSERT INTO studentclasses VALUES (20226, 4467, 3664, 7);
INSERT INTO studentclasses VALUES (20227, 4468, 3686, 9);
INSERT INTO studentclasses VALUES (20228, 4468, 3687, 7);
INSERT INTO studentclasses VALUES (20229, 4468, 3617, 3);
INSERT INTO studentclasses VALUES (20230, 4468, 3620, 4);
INSERT INTO studentclasses VALUES (20231, 4468, 3642, 8);
INSERT INTO studentclasses VALUES (20232, 4468, 3621, 7);
INSERT INTO studentclasses VALUES (20233, 4469, 3688, 4);
INSERT INTO studentclasses VALUES (20234, 4469, 3636, 3);
INSERT INTO studentclasses VALUES (20235, 4469, 3667, 9);
INSERT INTO studentclasses VALUES (20236, 4469, 3632, 6);
INSERT INTO studentclasses VALUES (20237, 4470, 3689, 6);
INSERT INTO studentclasses VALUES (20238, 4470, 3690, 9);
INSERT INTO studentclasses VALUES (20239, 4470, 3691, 5);
INSERT INTO studentclasses VALUES (20240, 4470, 3635, 7);
INSERT INTO studentclasses VALUES (20241, 4470, 3676, 11);
INSERT INTO studentclasses VALUES (20242, 4471, 3692, 8);
INSERT INTO studentclasses VALUES (20243, 4471, 3615, 5);
INSERT INTO studentclasses VALUES (20244, 4471, 3693, 14);
INSERT INTO studentclasses VALUES (20245, 4471, 3667, 7);
INSERT INTO studentclasses VALUES (20246, 4471, 3620, 5);
INSERT INTO studentclasses VALUES (20247, 4471, 3642, 6);
INSERT INTO studentclasses VALUES (20248, 4471, 3694, 8);
INSERT INTO studentclasses VALUES (20249, 4472, 3695, 8);
INSERT INTO studentclasses VALUES (20250, 4472, 3696, 7);
INSERT INTO studentclasses VALUES (20251, 4472, 3671, 7);
INSERT INTO studentclasses VALUES (20252, 4472, 3697, 9);
INSERT INTO studentclasses VALUES (20253, 4472, 3698, 9);
INSERT INTO studentclasses VALUES (20254, 4473, 3699, 11);
INSERT INTO studentclasses VALUES (20255, 4473, 3700, 9);
INSERT INTO studentclasses VALUES (20256, 4473, 3701, 3);
INSERT INTO studentclasses VALUES (20257, 4473, 3702, 2);
INSERT INTO studentclasses VALUES (20258, 4473, 3661, 9);
INSERT INTO studentclasses VALUES (20259, 4474, 3703, 8);
INSERT INTO studentclasses VALUES (20260, 4474, 3704, 6);
INSERT INTO studentclasses VALUES (20261, 4474, 3619, 11);
INSERT INTO studentclasses VALUES (20262, 4474, 3635, 8);
INSERT INTO studentclasses VALUES (20263, 4474, 3705, 11);
INSERT INTO studentclasses VALUES (20264, 4475, 3706, 3);
INSERT INTO studentclasses VALUES (20265, 4475, 3703, 9);
INSERT INTO studentclasses VALUES (20266, 4475, 3707, 6);
INSERT INTO studentclasses VALUES (20267, 4475, 3708, 7);
INSERT INTO studentclasses VALUES (20268, 4475, 3709, 3);
INSERT INTO studentclasses VALUES (20269, 4475, 3710, 1);
INSERT INTO studentclasses VALUES (20270, 4476, 3711, 4);
INSERT INTO studentclasses VALUES (20271, 4476, 3655, 8);
INSERT INTO studentclasses VALUES (20272, 4476, 3712, 3);
INSERT INTO studentclasses VALUES (20273, 4476, 3713, 4);
INSERT INTO studentclasses VALUES (20274, 4476, 3676, 5);
INSERT INTO studentclasses VALUES (20275, 4476, 3668, 6);
INSERT INTO studentclasses VALUES (20276, 4477, 3714, 3);
INSERT INTO studentclasses VALUES (20277, 4477, 3715, 8);
INSERT INTO studentclasses VALUES (20278, 4477, 3716, 11);
INSERT INTO studentclasses VALUES (20279, 4477, 3717, 9);
INSERT INTO studentclasses VALUES (20280, 4477, 3676, 7);
INSERT INTO studentclasses VALUES (20281, 4477, 3705, 3);
INSERT INTO studentclasses VALUES (20282, 4478, 3718, 9);
INSERT INTO studentclasses VALUES (20283, 4478, 3719, 9);
INSERT INTO studentclasses VALUES (20284, 4478, 3720, 6);
INSERT INTO studentclasses VALUES (20285, 4478, 3721, 5);
INSERT INTO studentclasses VALUES (20286, 4478, 3668, 11);
INSERT INTO studentclasses VALUES (20287, 4479, 3690, 10);
INSERT INTO studentclasses VALUES (20288, 4479, 3722, 11);
INSERT INTO studentclasses VALUES (20289, 4479, 3707, 8);
INSERT INTO studentclasses VALUES (20290, 4479, 3723, 4);
INSERT INTO studentclasses VALUES (20291, 4479, 3724, 4);
INSERT INTO studentclasses VALUES (20292, 4479, 3725, 11);
INSERT INTO studentclasses VALUES (20293, 4480, 3726, 5);
INSERT INTO studentclasses VALUES (20294, 4480, 3700, 7);
INSERT INTO studentclasses VALUES (20295, 4480, 3727, 5);
INSERT INTO studentclasses VALUES (20296, 4480, 3725, 9);
INSERT INTO studentclasses VALUES (20297, 4480, 3705, 11);
INSERT INTO studentclasses VALUES (20298, 4481, 3728, 10);
INSERT INTO studentclasses VALUES (20299, 4481, 3729, 5);
INSERT INTO studentclasses VALUES (20300, 4481, 3635, 8);
INSERT INTO studentclasses VALUES (20301, 4481, 3638, 11);
INSERT INTO studentclasses VALUES (20302, 4481, 3657, 8);
INSERT INTO studentclasses VALUES (20303, 4482, 3730, 5);
INSERT INTO studentclasses VALUES (20304, 4482, 3731, 11);
INSERT INTO studentclasses VALUES (20305, 4482, 3712, 8);
INSERT INTO studentclasses VALUES (20306, 4482, 3638, 7);
INSERT INTO studentclasses VALUES (20307, 4482, 3657, 6);
INSERT INTO studentclasses VALUES (20308, 4483, 3718, 9);
INSERT INTO studentclasses VALUES (20309, 4483, 3732, 4);
INSERT INTO studentclasses VALUES (20310, 4483, 3733, 2);
INSERT INTO studentclasses VALUES (20311, 4483, 3721, 5);
INSERT INTO studentclasses VALUES (20312, 4483, 3668, 9);
INSERT INTO studentclasses VALUES (20313, 4484, 3734, 8);
INSERT INTO studentclasses VALUES (20314, 4484, 3735, 6);
INSERT INTO studentclasses VALUES (20315, 4484, 3736, 7);
INSERT INTO studentclasses VALUES (20316, 4484, 3635, 5);
INSERT INTO studentclasses VALUES (20317, 4484, 3737, 7);
INSERT INTO studentclasses VALUES (20318, 4484, 3668, 8);
INSERT INTO studentclasses VALUES (20319, 4485, 3738, 8);
INSERT INTO studentclasses VALUES (20320, 4485, 3739, 9);
INSERT INTO studentclasses VALUES (20321, 4485, 3740, 7);
INSERT INTO studentclasses VALUES (20322, 4485, 3741, 7);
INSERT INTO studentclasses VALUES (20323, 4485, 3638, 1);
INSERT INTO studentclasses VALUES (20324, 4485, 3668, 4);
INSERT INTO studentclasses VALUES (20325, 4486, 3742, 5);
INSERT INTO studentclasses VALUES (20326, 4486, 3743, 3);
INSERT INTO studentclasses VALUES (20327, 4486, 3744, 6);
INSERT INTO studentclasses VALUES (20328, 4486, 3719, 8);
INSERT INTO studentclasses VALUES (20329, 4486, 3745, 8);
INSERT INTO studentclasses VALUES (20330, 4486, 3705, 8);
INSERT INTO studentclasses VALUES (20331, 4487, 3746, 13);
INSERT INTO studentclasses VALUES (20332, 4487, 3747, 9);
INSERT INTO studentclasses VALUES (20333, 4487, 3712, 11);
INSERT INTO studentclasses VALUES (20334, 4487, 3638, 7);
INSERT INTO studentclasses VALUES (20335, 4487, 3657, 8);
INSERT INTO studentclasses VALUES (20336, 4488, 3748, 7);
INSERT INTO studentclasses VALUES (20337, 4488, 3749, 9);
INSERT INTO studentclasses VALUES (20338, 4488, 3690, 9);
INSERT INTO studentclasses VALUES (20339, 4488, 3750, 13);
INSERT INTO studentclasses VALUES (20340, 4488, 3751, 8);
INSERT INTO studentclasses VALUES (20341, 4488, 3752, 10);
INSERT INTO studentclasses VALUES (20342, 4489, 3753, 3);
INSERT INTO studentclasses VALUES (20343, 4489, 3754, 8);
INSERT INTO studentclasses VALUES (20344, 4489, 3755, 8);
INSERT INTO studentclasses VALUES (20345, 4489, 3635, 6);
INSERT INTO studentclasses VALUES (20346, 4489, 3676, 7);
INSERT INTO studentclasses VALUES (20347, 4489, 3668, 7);
INSERT INTO studentclasses VALUES (20348, 4490, 3756, 7);
INSERT INTO studentclasses VALUES (20349, 4490, 3757, 9);
INSERT INTO studentclasses VALUES (20350, 4490, 3635, 7);
INSERT INTO studentclasses VALUES (20351, 4490, 3737, 6);
INSERT INTO studentclasses VALUES (20352, 4490, 3668, 11);
INSERT INTO studentclasses VALUES (20353, 4491, 3758, 4);
INSERT INTO studentclasses VALUES (20354, 4491, 3759, 9);
INSERT INTO studentclasses VALUES (20355, 4491, 3719, 10);
INSERT INTO studentclasses VALUES (20356, 4491, 3760, 5);
INSERT INTO studentclasses VALUES (20357, 4491, 3676, 8);
INSERT INTO studentclasses VALUES (20358, 4491, 3657, 6);
INSERT INTO studentclasses VALUES (20359, 4492, 3761, 9);
INSERT INTO studentclasses VALUES (20360, 4492, 3762, 11);
INSERT INTO studentclasses VALUES (20361, 4492, 3763, 6);
INSERT INTO studentclasses VALUES (20362, 4492, 3643, 4);
INSERT INTO studentclasses VALUES (20363, 4493, 3690, 9);
INSERT INTO studentclasses VALUES (20364, 4493, 3764, 11);
INSERT INTO studentclasses VALUES (20365, 4493, 3712, 9);
INSERT INTO studentclasses VALUES (20366, 4493, 3765, 4);
INSERT INTO studentclasses VALUES (20367, 4493, 3635, 9);
INSERT INTO studentclasses VALUES (20368, 4493, 3676, 7);
INSERT INTO studentclasses VALUES (20369, 4494, 3766, 6);
INSERT INTO studentclasses VALUES (20370, 4494, 3718, 10);
INSERT INTO studentclasses VALUES (20371, 4494, 3767, 5);
INSERT INTO studentclasses VALUES (20372, 4494, 3760, 6);
INSERT INTO studentclasses VALUES (20373, 4494, 3638, 9);
INSERT INTO studentclasses VALUES (20374, 4495, 3690, 10);
INSERT INTO studentclasses VALUES (20375, 4495, 3744, 6);
INSERT INTO studentclasses VALUES (20376, 4495, 3700, 11);
INSERT INTO studentclasses VALUES (20377, 4495, 3686, 6);
INSERT INTO studentclasses VALUES (20378, 4495, 3757, 10);
INSERT INTO studentclasses VALUES (20379, 4495, 3737, 8);
INSERT INTO studentclasses VALUES (20380, 4496, 3768, 8);
INSERT INTO studentclasses VALUES (20381, 4496, 3691, 2);
INSERT INTO studentclasses VALUES (20382, 4496, 3769, 4);
INSERT INTO studentclasses VALUES (20383, 4496, 3770, 6);
INSERT INTO studentclasses VALUES (20384, 4496, 3657, 5);
INSERT INTO studentclasses VALUES (20385, 4497, 3771, 2);
INSERT INTO studentclasses VALUES (20386, 4497, 3772, 4);
INSERT INTO studentclasses VALUES (20387, 4497, 3773, 9);
INSERT INTO studentclasses VALUES (20388, 4497, 3774, 7);
INSERT INTO studentclasses VALUES (20389, 4498, 3775, 3);
INSERT INTO studentclasses VALUES (20390, 4498, 3776, 9);
INSERT INTO studentclasses VALUES (20391, 4498, 3777, 1);
INSERT INTO studentclasses VALUES (20392, 4498, 3725, 11);
INSERT INTO studentclasses VALUES (20393, 4498, 3705, 11);
INSERT INTO studentclasses VALUES (20394, 4499, 3778, 5);
INSERT INTO studentclasses VALUES (20395, 4499, 3703, 13);
INSERT INTO studentclasses VALUES (20396, 4499, 3704, 8);
INSERT INTO studentclasses VALUES (20397, 4499, 3779, 3);
INSERT INTO studentclasses VALUES (20398, 4499, 3737, 9);
INSERT INTO studentclasses VALUES (20399, 4499, 3705, 11);
INSERT INTO studentclasses VALUES (20400, 4500, 3690, 9);
INSERT INTO studentclasses VALUES (20401, 4500, 3780, 9);
INSERT INTO studentclasses VALUES (20402, 4500, 3781, 8);
INSERT INTO studentclasses VALUES (20403, 4500, 3782, 6);
INSERT INTO studentclasses VALUES (20404, 4500, 3725, 11);
INSERT INTO studentclasses VALUES (20405, 4501, 3783, 3);
INSERT INTO studentclasses VALUES (20406, 4501, 3784, 5);
INSERT INTO studentclasses VALUES (20407, 4501, 3756, 9);
INSERT INTO studentclasses VALUES (20408, 4501, 3785, 9);
INSERT INTO studentclasses VALUES (20409, 4501, 3737, 11);
INSERT INTO studentclasses VALUES (20410, 4501, 3705, 11);
INSERT INTO studentclasses VALUES (20411, 4502, 3786, 6);
INSERT INTO studentclasses VALUES (20412, 4502, 3747, 9);
INSERT INTO studentclasses VALUES (20413, 4502, 3787, 6);
INSERT INTO studentclasses VALUES (20414, 4502, 3686, 11);
INSERT INTO studentclasses VALUES (20415, 4502, 3737, 9);
INSERT INTO studentclasses VALUES (20416, 4503, 3788, 2);
INSERT INTO studentclasses VALUES (20417, 4503, 3789, 4);
INSERT INTO studentclasses VALUES (20418, 4503, 3716, 13);
INSERT INTO studentclasses VALUES (20419, 4503, 3790, 9);
INSERT INTO studentclasses VALUES (20420, 4503, 3638, 9);
INSERT INTO studentclasses VALUES (20421, 4503, 3657, 6);
INSERT INTO studentclasses VALUES (20422, 4504, 3776, 8);
INSERT INTO studentclasses VALUES (20423, 4504, 3717, 6);
INSERT INTO studentclasses VALUES (20424, 4504, 3708, 4);
INSERT INTO studentclasses VALUES (20425, 4504, 3791, 2);
INSERT INTO studentclasses VALUES (20426, 4504, 3698, 7);
INSERT INTO studentclasses VALUES (20427, 4504, 3668, 6);
INSERT INTO studentclasses VALUES (20428, 4505, 3792, 5);
INSERT INTO studentclasses VALUES (20429, 4505, 3793, 10);
INSERT INTO studentclasses VALUES (20430, 4505, 3794, 11);
INSERT INTO studentclasses VALUES (20431, 4505, 3795, 7);
INSERT INTO studentclasses VALUES (20432, 4505, 3676, 9);
INSERT INTO studentclasses VALUES (20433, 4505, 3657, 7);
INSERT INTO studentclasses VALUES (20434, 4506, 3796, 3);
INSERT INTO studentclasses VALUES (20435, 4506, 3797, 7);
INSERT INTO studentclasses VALUES (20436, 4506, 3795, 5);
INSERT INTO studentclasses VALUES (20437, 4506, 3721, 4);
INSERT INTO studentclasses VALUES (20438, 4506, 3668, 8);
INSERT INTO studentclasses VALUES (20439, 4507, 3759, 9);
INSERT INTO studentclasses VALUES (20440, 4507, 3795, 9);
INSERT INTO studentclasses VALUES (20441, 4507, 3798, 3);
INSERT INTO studentclasses VALUES (20442, 4507, 3635, 8);
INSERT INTO studentclasses VALUES (20443, 4507, 3737, 9);
INSERT INTO studentclasses VALUES (20444, 4507, 3668, 11);
INSERT INTO studentclasses VALUES (20445, 4508, 3799, 4);
INSERT INTO studentclasses VALUES (20446, 4508, 3764, 9);
INSERT INTO studentclasses VALUES (20447, 4508, 3741, 7);
INSERT INTO studentclasses VALUES (20448, 4508, 3656, 6);
INSERT INTO studentclasses VALUES (20449, 4508, 3737, 9);
INSERT INTO studentclasses VALUES (20450, 4508, 3705, 11);
INSERT INTO studentclasses VALUES (20451, 4509, 3800, 8);
INSERT INTO studentclasses VALUES (20452, 4509, 3632, 3);
INSERT INTO studentclasses VALUES (20453, 4509, 3637, 9);
INSERT INTO studentclasses VALUES (20454, 4509, 3642, 9);
INSERT INTO studentclasses VALUES (20455, 4509, 3639, 2);
INSERT INTO studentclasses VALUES (20456, 4509, 3705, 11);
INSERT INTO studentclasses VALUES (20457, 4510, 3801, 6);
INSERT INTO studentclasses VALUES (20458, 4510, 3802, 6);
INSERT INTO studentclasses VALUES (20459, 4510, 3803, 9);
INSERT INTO studentclasses VALUES (20460, 4510, 3804, 4);
INSERT INTO studentclasses VALUES (20461, 4510, 3725, 6);
INSERT INTO studentclasses VALUES (20462, 4510, 3657, 6);
INSERT INTO studentclasses VALUES (20463, 4511, 3805, 5);
INSERT INTO studentclasses VALUES (20464, 4511, 3806, 9);
INSERT INTO studentclasses VALUES (20465, 4511, 3800, 8);
INSERT INTO studentclasses VALUES (20466, 4511, 3807, 4);
INSERT INTO studentclasses VALUES (20467, 4511, 3676, 8);
INSERT INTO studentclasses VALUES (20468, 4511, 3705, 11);
INSERT INTO studentclasses VALUES (20469, 4512, 3802, 6);
INSERT INTO studentclasses VALUES (20470, 4512, 3700, 11);
INSERT INTO studentclasses VALUES (20471, 4512, 3808, 10);
INSERT INTO studentclasses VALUES (20472, 4512, 3804, 4);
INSERT INTO studentclasses VALUES (20473, 4512, 3737, 11);
INSERT INTO studentclasses VALUES (20474, 4512, 3657, 6);
INSERT INTO studentclasses VALUES (20475, 4513, 3809, 4);
INSERT INTO studentclasses VALUES (20476, 4513, 3810, 3);
INSERT INTO studentclasses VALUES (20477, 4513, 3670, 8);
INSERT INTO studentclasses VALUES (20478, 4513, 3811, 7);
INSERT INTO studentclasses VALUES (20479, 4513, 3774, 5);
INSERT INTO studentclasses VALUES (20480, 4513, 3705, 7);
INSERT INTO studentclasses VALUES (20481, 4514, 3756, 2);
INSERT INTO studentclasses VALUES (20482, 4514, 3680, 4);
INSERT INTO studentclasses VALUES (20483, 4514, 3635, 1);
INSERT INTO studentclasses VALUES (20484, 4514, 3676, 2);
INSERT INTO studentclasses VALUES (20485, 4514, 3812, 3);
INSERT INTO studentclasses VALUES (20486, 4515, 3813, 6);
INSERT INTO studentclasses VALUES (20487, 4515, 3655, 7);
INSERT INTO studentclasses VALUES (20488, 4515, 3720, 8);
INSERT INTO studentclasses VALUES (20489, 4515, 3814, 11);
INSERT INTO studentclasses VALUES (20490, 4515, 3638, 11);
INSERT INTO studentclasses VALUES (20491, 4515, 3657, 14);
INSERT INTO studentclasses VALUES (20492, 4516, 3767, 8);
INSERT INTO studentclasses VALUES (20493, 4516, 3815, 1);
INSERT INTO studentclasses VALUES (20494, 4516, 3816, 3);
INSERT INTO studentclasses VALUES (20495, 4516, 3737, 7);
INSERT INTO studentclasses VALUES (20496, 4516, 3657, 7);
INSERT INTO studentclasses VALUES (20497, 4517, 3817, 6);
INSERT INTO studentclasses VALUES (20498, 4517, 3818, 4);
INSERT INTO studentclasses VALUES (20499, 4517, 3728, 6);
INSERT INTO studentclasses VALUES (20500, 4517, 3819, 5);
INSERT INTO studentclasses VALUES (20501, 4517, 3820, 7);
INSERT INTO studentclasses VALUES (20502, 4517, 3821, 5);
INSERT INTO studentclasses VALUES (20503, 4518, 3822, 9);
INSERT INTO studentclasses VALUES (20504, 4518, 3823, 7);
INSERT INTO studentclasses VALUES (20505, 4518, 3824, 7);
INSERT INTO studentclasses VALUES (20506, 4518, 3725, 9);
INSERT INTO studentclasses VALUES (20507, 4518, 3668, 8);
INSERT INTO studentclasses VALUES (20508, 4519, 3748, 9);
INSERT INTO studentclasses VALUES (20509, 4519, 3764, 4);
INSERT INTO studentclasses VALUES (20510, 4519, 3741, 11);
INSERT INTO studentclasses VALUES (20511, 4519, 3725, 9);
INSERT INTO studentclasses VALUES (20512, 4519, 3705, 8);
INSERT INTO studentclasses VALUES (20513, 4520, 3825, 2);
INSERT INTO studentclasses VALUES (20514, 4520, 3748, 2);
INSERT INTO studentclasses VALUES (20515, 4520, 3671, 6);
INSERT INTO studentclasses VALUES (20516, 4520, 3737, 11);
INSERT INTO studentclasses VALUES (20517, 4520, 3657, 6);
INSERT INTO studentclasses VALUES (20518, 4521, 3826, 4);
INSERT INTO studentclasses VALUES (20519, 4521, 3827, 4);
INSERT INTO studentclasses VALUES (20520, 4521, 3828, 5);
INSERT INTO studentclasses VALUES (20521, 4521, 3829, 1);
INSERT INTO studentclasses VALUES (20522, 4521, 3830, 1);
INSERT INTO studentclasses VALUES (20523, 4522, 3831, 3);
INSERT INTO studentclasses VALUES (20524, 4522, 3832, 5);
INSERT INTO studentclasses VALUES (20525, 4522, 3656, 8);
INSERT INTO studentclasses VALUES (20526, 4522, 3833, 1);
INSERT INTO studentclasses VALUES (20527, 4522, 3834, 7);
INSERT INTO studentclasses VALUES (20528, 4523, 3835, 3);
INSERT INTO studentclasses VALUES (20529, 4523, 3836, 5);
INSERT INTO studentclasses VALUES (20530, 4523, 3837, 7);
INSERT INTO studentclasses VALUES (20531, 4523, 3838, 1);
INSERT INTO studentclasses VALUES (20532, 4523, 3721, 6);
INSERT INTO studentclasses VALUES (20533, 4524, 3839, 6);
INSERT INTO studentclasses VALUES (20534, 4524, 3840, 7);
INSERT INTO studentclasses VALUES (20535, 4524, 3841, 4);
INSERT INTO studentclasses VALUES (20536, 4524, 3661, 8);
INSERT INTO studentclasses VALUES (20537, 4524, 3812, 4);
INSERT INTO studentclasses VALUES (20538, 4525, 3662, 4);
INSERT INTO studentclasses VALUES (20539, 4525, 3842, 9);
INSERT INTO studentclasses VALUES (20540, 4525, 3843, 5);
INSERT INTO studentclasses VALUES (20541, 4525, 3844, 1);
INSERT INTO studentclasses VALUES (20542, 4525, 3661, 12);
INSERT INTO studentclasses VALUES (20543, 4526, 3826, 5);
INSERT INTO studentclasses VALUES (20544, 4526, 3845, 4);
INSERT INTO studentclasses VALUES (20545, 4526, 3846, 3);
INSERT INTO studentclasses VALUES (20546, 4526, 3832, 7);
INSERT INTO studentclasses VALUES (20547, 4526, 3847, 4);
INSERT INTO studentclasses VALUES (20548, 4526, 3661, 3);
INSERT INTO studentclasses VALUES (20549, 4527, 3848, 4);
INSERT INTO studentclasses VALUES (20550, 4527, 3840, 5);
INSERT INTO studentclasses VALUES (20551, 4527, 3849, 3);
INSERT INTO studentclasses VALUES (20552, 4527, 3850, 4);
INSERT INTO studentclasses VALUES (20553, 4527, 3851, 6);
INSERT INTO studentclasses VALUES (20554, 4528, 3852, 6);
INSERT INTO studentclasses VALUES (20555, 4528, 3853, 5);
INSERT INTO studentclasses VALUES (20556, 4528, 3840, 8);
INSERT INTO studentclasses VALUES (20557, 4528, 3798, 2);
INSERT INTO studentclasses VALUES (20558, 4528, 3661, 7);
INSERT INTO studentclasses VALUES (20559, 4529, 3854, 3);
INSERT INTO studentclasses VALUES (20560, 4529, 3842, 9);
INSERT INTO studentclasses VALUES (20561, 4529, 3855, 6);
INSERT INTO studentclasses VALUES (20562, 4529, 3856, 2);
INSERT INTO studentclasses VALUES (20563, 4529, 3745, 7);
INSERT INTO studentclasses VALUES (20564, 4530, 3857, 3);
INSERT INTO studentclasses VALUES (20565, 4530, 3792, 3);
INSERT INTO studentclasses VALUES (20566, 4530, 3837, 5);
INSERT INTO studentclasses VALUES (20567, 4530, 3838, 1);
INSERT INTO studentclasses VALUES (20568, 4530, 3830, 2);
INSERT INTO studentclasses VALUES (20569, 4531, 3858, 3);
INSERT INTO studentclasses VALUES (20570, 4531, 3859, 3);
INSERT INTO studentclasses VALUES (20571, 4531, 3832, 9);
INSERT INTO studentclasses VALUES (20572, 4531, 3860, 3);
INSERT INTO studentclasses VALUES (20573, 4531, 3661, 2);
INSERT INTO studentclasses VALUES (20574, 4532, 3612, 2);
INSERT INTO studentclasses VALUES (20575, 4532, 3861, 9);
INSERT INTO studentclasses VALUES (20576, 4532, 3656, 5);
INSERT INTO studentclasses VALUES (20577, 4532, 3862, 4);
INSERT INTO studentclasses VALUES (20578, 4532, 3745, 5);
INSERT INTO studentclasses VALUES (20579, 4533, 3863, 7);
INSERT INTO studentclasses VALUES (20580, 4533, 3864, 4);
INSERT INTO studentclasses VALUES (20581, 4533, 3865, 8);
INSERT INTO studentclasses VALUES (20582, 4533, 3791, 3);
INSERT INTO studentclasses VALUES (20583, 4533, 3830, 13);
INSERT INTO studentclasses VALUES (20584, 4534, 3848, 3);
INSERT INTO studentclasses VALUES (20585, 4534, 3866, 7);
INSERT INTO studentclasses VALUES (20586, 4534, 3849, 4);
INSERT INTO studentclasses VALUES (20587, 4534, 3867, 1);
INSERT INTO studentclasses VALUES (20588, 4534, 3710, 4);
INSERT INTO studentclasses VALUES (20589, 4535, 3868, 4);
INSERT INTO studentclasses VALUES (20590, 4535, 3837, 7);
INSERT INTO studentclasses VALUES (20591, 4535, 3869, 6);
INSERT INTO studentclasses VALUES (20592, 4535, 3838, 1);
INSERT INTO studentclasses VALUES (20593, 4535, 3830, 3);
INSERT INTO studentclasses VALUES (20594, 4536, 3870, 2);
INSERT INTO studentclasses VALUES (20595, 4536, 3871, 4);
INSERT INTO studentclasses VALUES (20596, 4536, 3866, 4);
INSERT INTO studentclasses VALUES (20597, 4536, 3844, 1);
INSERT INTO studentclasses VALUES (20598, 4536, 3710, 2);
INSERT INTO studentclasses VALUES (20599, 4537, 3813, 1);
INSERT INTO studentclasses VALUES (20600, 4537, 3872, 7);
INSERT INTO studentclasses VALUES (20601, 4537, 3686, 7);
INSERT INTO studentclasses VALUES (20602, 4537, 3816, 3);
INSERT INTO studentclasses VALUES (20603, 4537, 3745, 1);
INSERT INTO studentclasses VALUES (20604, 4538, 3873, 4);
INSERT INTO studentclasses VALUES (20605, 4538, 3874, 8);
INSERT INTO studentclasses VALUES (20606, 4538, 3855, 11);
INSERT INTO studentclasses VALUES (20607, 4538, 3875, 4);
INSERT INTO studentclasses VALUES (20608, 4538, 3834, 8);
INSERT INTO studentclasses VALUES (20609, 4539, 3825, 2);
INSERT INTO studentclasses VALUES (20610, 4539, 3876, 3);
INSERT INTO studentclasses VALUES (20611, 4539, 3877, 11);
INSERT INTO studentclasses VALUES (20612, 4539, 3878, 1);
INSERT INTO studentclasses VALUES (20613, 4539, 3879, 2);
INSERT INTO studentclasses VALUES (20614, 4539, 3721, 6);
INSERT INTO studentclasses VALUES (20615, 4540, 3880, 3);
INSERT INTO studentclasses VALUES (20616, 4540, 3881, 4);
INSERT INTO studentclasses VALUES (20617, 4540, 3619, 4);
INSERT INTO studentclasses VALUES (20618, 4540, 3882, 2);
INSERT INTO studentclasses VALUES (20619, 4540, 3834, 6);
INSERT INTO studentclasses VALUES (20620, 4541, 3883, 3);
INSERT INTO studentclasses VALUES (20621, 4541, 3884, 6);
INSERT INTO studentclasses VALUES (20622, 4541, 3885, 9);
INSERT INTO studentclasses VALUES (20623, 4541, 3886, 1);
INSERT INTO studentclasses VALUES (20624, 4541, 3710, 1);
INSERT INTO studentclasses VALUES (20625, 4542, 3854, 2);
INSERT INTO studentclasses VALUES (20626, 4542, 3887, 2);
INSERT INTO studentclasses VALUES (20627, 4542, 3832, 5);
INSERT INTO studentclasses VALUES (20628, 4542, 3830, 1);
INSERT INTO studentclasses VALUES (20629, 4542, 3888, 2);
INSERT INTO studentclasses VALUES (20630, 4543, 3889, 5);
INSERT INTO studentclasses VALUES (20631, 4543, 3818, 7);
INSERT INTO studentclasses VALUES (20632, 4543, 3890, 9);
INSERT INTO studentclasses VALUES (20633, 4543, 3891, 3);
INSERT INTO studentclasses VALUES (20634, 4543, 3851, 2);
INSERT INTO studentclasses VALUES (20635, 4544, 3892, 3);
INSERT INTO studentclasses VALUES (20636, 4544, 3871, 6);
INSERT INTO studentclasses VALUES (20637, 4544, 3893, 8);
INSERT INTO studentclasses VALUES (20638, 4544, 3829, 3);
INSERT INTO studentclasses VALUES (20639, 4544, 3698, 5);
INSERT INTO studentclasses VALUES (20640, 4545, 3894, 4);
INSERT INTO studentclasses VALUES (20641, 4545, 3895, 3);
INSERT INTO studentclasses VALUES (20642, 4545, 3855, 6);
INSERT INTO studentclasses VALUES (20643, 4545, 3896, 5);
INSERT INTO studentclasses VALUES (20644, 4545, 3721, 3);
INSERT INTO studentclasses VALUES (20645, 4546, 3897, 4);
INSERT INTO studentclasses VALUES (20646, 4546, 3898, 3);
INSERT INTO studentclasses VALUES (20647, 4546, 3773, 7);
INSERT INTO studentclasses VALUES (20648, 4546, 3856, 2);
INSERT INTO studentclasses VALUES (20649, 4546, 3745, 11);
INSERT INTO studentclasses VALUES (20650, 4547, 3898, 3);
INSERT INTO studentclasses VALUES (20651, 4547, 3899, 4);
INSERT INTO studentclasses VALUES (20652, 4547, 3855, 5);
INSERT INTO studentclasses VALUES (20653, 4547, 3686, 7);
INSERT INTO studentclasses VALUES (20654, 4547, 3745, 4);
INSERT INTO studentclasses VALUES (20655, 4548, 3900, 5);
INSERT INTO studentclasses VALUES (20656, 4548, 3846, 6);
INSERT INTO studentclasses VALUES (20657, 4548, 3893, 8);
INSERT INTO studentclasses VALUES (20658, 4548, 3901, 2);
INSERT INTO studentclasses VALUES (20659, 4548, 3745, 7);
INSERT INTO studentclasses VALUES (20660, 4549, 3848, 3);
INSERT INTO studentclasses VALUES (20661, 4549, 3902, 7);
INSERT INTO studentclasses VALUES (20662, 4549, 3832, 9);
INSERT INTO studentclasses VALUES (20663, 4549, 3875, 2);
INSERT INTO studentclasses VALUES (20664, 4549, 3834, 3);
INSERT INTO studentclasses VALUES (20665, 4550, 3848, 3);
INSERT INTO studentclasses VALUES (20666, 4550, 3866, 6);
INSERT INTO studentclasses VALUES (20667, 4550, 3849, 4);
INSERT INTO studentclasses VALUES (20668, 4550, 3862, 4);
INSERT INTO studentclasses VALUES (20669, 4550, 3710, 3);
INSERT INTO studentclasses VALUES (20670, 4551, 3825, 2);
INSERT INTO studentclasses VALUES (20671, 4551, 3903, 3);
INSERT INTO studentclasses VALUES (20672, 4551, 3904, 9);
INSERT INTO studentclasses VALUES (20673, 4551, 3905, 4);
INSERT INTO studentclasses VALUES (20674, 4551, 3721, 8);
INSERT INTO studentclasses VALUES (20675, 4552, 3906, 3);
INSERT INTO studentclasses VALUES (20676, 4552, 3761, 9);
INSERT INTO studentclasses VALUES (20677, 4552, 3907, 4);
INSERT INTO studentclasses VALUES (20678, 4552, 3816, 4);
INSERT INTO studentclasses VALUES (20679, 4552, 3745, 9);
INSERT INTO studentclasses VALUES (20680, 4553, 3866, 6);
INSERT INTO studentclasses VALUES (20681, 4553, 3908, 4);
INSERT INTO studentclasses VALUES (20682, 4553, 3909, 2);
INSERT INTO studentclasses VALUES (20683, 4553, 3829, 6);
INSERT INTO studentclasses VALUES (20684, 4553, 3745, 3);
INSERT INTO studentclasses VALUES (20685, 4554, 3734, 4);
INSERT INTO studentclasses VALUES (20686, 4554, 3842, 8);
INSERT INTO studentclasses VALUES (20687, 4554, 3869, 3);
INSERT INTO studentclasses VALUES (20688, 4554, 3910, 3);
INSERT INTO studentclasses VALUES (20689, 4554, 3830, 1);
INSERT INTO studentclasses VALUES (20690, 4555, 3911, 3);
INSERT INTO studentclasses VALUES (20691, 4555, 3828, 6);
INSERT INTO studentclasses VALUES (20692, 4555, 3909, 1);
INSERT INTO studentclasses VALUES (20693, 4555, 3912, 4);
INSERT INTO studentclasses VALUES (20694, 4555, 3834, 4);
INSERT INTO studentclasses VALUES (20695, 4556, 3913, 12);
INSERT INTO studentclasses VALUES (20696, 4556, 3828, 10);
INSERT INTO studentclasses VALUES (20697, 4556, 3869, 8);
INSERT INTO studentclasses VALUES (20698, 4556, 3914, 6);
INSERT INTO studentclasses VALUES (20699, 4556, 3834, 8);
INSERT INTO studentclasses VALUES (20700, 4557, 3887, 4);
INSERT INTO studentclasses VALUES (20701, 4557, 3874, 7);
INSERT INTO studentclasses VALUES (20702, 4557, 3915, 1);
INSERT INTO studentclasses VALUES (20703, 4557, 3916, 3);
INSERT INTO studentclasses VALUES (20704, 4557, 3834, 7);
INSERT INTO studentclasses VALUES (20705, 4558, 3848, 4);
INSERT INTO studentclasses VALUES (20706, 4558, 3917, 9);
INSERT INTO studentclasses VALUES (20707, 4558, 3918, 2);
INSERT INTO studentclasses VALUES (20708, 4558, 3844, 1);
INSERT INTO studentclasses VALUES (20709, 4558, 3661, 8);
INSERT INTO studentclasses VALUES (20710, 4559, 3892, 4);
INSERT INTO studentclasses VALUES (20711, 4559, 3871, 6);
INSERT INTO studentclasses VALUES (20712, 4559, 3893, 9);
INSERT INTO studentclasses VALUES (20713, 4559, 3829, 1);
INSERT INTO studentclasses VALUES (20714, 4559, 3698, 2);
INSERT INTO studentclasses VALUES (20715, 4560, 3848, 3);
INSERT INTO studentclasses VALUES (20716, 4560, 3736, 8);
INSERT INTO studentclasses VALUES (20717, 4560, 3849, 3);
INSERT INTO studentclasses VALUES (20718, 4560, 3867, 1);
INSERT INTO studentclasses VALUES (20719, 4560, 3710, 1);
INSERT INTO studentclasses VALUES (20720, 4561, 3662, 3);
INSERT INTO studentclasses VALUES (20721, 4561, 3919, 4);
INSERT INTO studentclasses VALUES (20722, 4561, 3842, 10);
INSERT INTO studentclasses VALUES (20723, 4561, 3920, 4);
INSERT INTO studentclasses VALUES (20724, 4561, 3661, 5);
INSERT INTO studentclasses VALUES (20725, 4562, 3817, 5);
INSERT INTO studentclasses VALUES (20726, 4562, 3899, 3);
INSERT INTO studentclasses VALUES (20727, 4562, 3619, 3);
INSERT INTO studentclasses VALUES (20728, 4562, 3921, 4);
INSERT INTO studentclasses VALUES (20729, 4562, 3710, 3);
INSERT INTO studentclasses VALUES (20730, 4563, 3857, 3);
INSERT INTO studentclasses VALUES (20731, 4563, 3837, 9);
INSERT INTO studentclasses VALUES (20732, 4563, 3869, 3);
INSERT INTO studentclasses VALUES (20733, 4563, 3838, 1);
INSERT INTO studentclasses VALUES (20734, 4563, 3830, 2);
INSERT INTO studentclasses VALUES (20735, 4564, 3892, 3);
INSERT INTO studentclasses VALUES (20736, 4564, 3822, 6);
INSERT INTO studentclasses VALUES (20737, 4564, 3866, 8);
INSERT INTO studentclasses VALUES (20738, 4564, 3804, 4);
INSERT INTO studentclasses VALUES (20739, 4564, 3698, 5);
INSERT INTO studentclasses VALUES (20740, 4565, 3922, 4);
INSERT INTO studentclasses VALUES (20741, 4565, 3923, 7);
INSERT INTO studentclasses VALUES (20742, 4565, 3924, 9);
INSERT INTO studentclasses VALUES (20743, 4565, 3925, 4);
INSERT INTO studentclasses VALUES (20744, 4565, 3745, 4);
INSERT INTO studentclasses VALUES (20745, 4566, 3926, 4);
INSERT INTO studentclasses VALUES (20746, 4566, 3842, 8);
INSERT INTO studentclasses VALUES (20747, 4566, 3686, 6);
INSERT INTO studentclasses VALUES (20748, 4566, 3829, 1);
INSERT INTO studentclasses VALUES (20749, 4566, 3745, 1);
INSERT INTO studentclasses VALUES (20750, 4567, 3842, 9);
INSERT INTO studentclasses VALUES (20751, 4567, 3909, 3);
INSERT INTO studentclasses VALUES (20752, 4567, 3921, 2);
INSERT INTO studentclasses VALUES (20753, 4567, 3838, 4);
INSERT INTO studentclasses VALUES (20754, 4567, 3661, 6);
INSERT INTO studentclasses VALUES (20755, 4568, 3845, 3);
INSERT INTO studentclasses VALUES (20756, 4568, 3837, 8);
INSERT INTO studentclasses VALUES (20757, 4568, 3927, 1);
INSERT INTO studentclasses VALUES (20758, 4568, 3684, 3);
INSERT INTO studentclasses VALUES (20759, 4568, 3830, 8);
INSERT INTO studentclasses VALUES (20760, 4569, 3743, 2);
INSERT INTO studentclasses VALUES (20761, 4569, 3773, 6);
INSERT INTO studentclasses VALUES (20762, 4569, 3928, 1);
INSERT INTO studentclasses VALUES (20763, 4569, 3921, 9);
INSERT INTO studentclasses VALUES (20764, 4569, 3698, 1);
INSERT INTO studentclasses VALUES (20765, 4570, 3852, 6);
INSERT INTO studentclasses VALUES (20766, 4570, 3689, 2);
INSERT INTO studentclasses VALUES (20767, 4570, 3840, 8);
INSERT INTO studentclasses VALUES (20768, 4570, 3869, 6);
INSERT INTO studentclasses VALUES (20769, 4570, 3929, 3);
INSERT INTO studentclasses VALUES (20770, 4570, 3661, 5);
INSERT INTO studentclasses VALUES (20771, 4571, 3852, 5);
INSERT INTO studentclasses VALUES (20772, 4571, 3840, 7);
INSERT INTO studentclasses VALUES (20773, 4571, 3869, 9);
INSERT INTO studentclasses VALUES (20774, 4571, 3841, 6);
INSERT INTO studentclasses VALUES (20775, 4571, 3661, 8);
INSERT INTO studentclasses VALUES (20776, 4572, 3930, 2);
INSERT INTO studentclasses VALUES (20777, 4572, 3917, 5);
INSERT INTO studentclasses VALUES (20778, 4572, 3844, 1);
INSERT INTO studentclasses VALUES (20779, 4572, 3834, 1);
INSERT INTO studentclasses VALUES (20780, 4572, 3931, 6);
INSERT INTO studentclasses VALUES (20781, 4573, 3857, 4);
INSERT INTO studentclasses VALUES (20782, 4573, 3837, 11);
INSERT INTO studentclasses VALUES (20783, 4573, 3869, 8);
INSERT INTO studentclasses VALUES (20784, 4573, 3882, 1);
INSERT INTO studentclasses VALUES (20785, 4573, 3830, 7);
INSERT INTO studentclasses VALUES (20786, 4574, 3868, 3);
INSERT INTO studentclasses VALUES (20787, 4574, 3792, 2);
INSERT INTO studentclasses VALUES (20788, 4574, 3837, 11);
INSERT INTO studentclasses VALUES (20789, 4574, 3838, 1);
INSERT INTO studentclasses VALUES (20790, 4574, 3830, 4);
INSERT INTO studentclasses VALUES (20791, 4575, 3932, 1);
INSERT INTO studentclasses VALUES (20792, 4575, 3902, 3);
INSERT INTO studentclasses VALUES (20793, 4575, 3933, 9);
INSERT INTO studentclasses VALUES (20794, 4575, 3920, 1);
INSERT INTO studentclasses VALUES (20795, 4575, 3834, 7);
INSERT INTO studentclasses VALUES (20796, 4576, 3932, 4);
INSERT INTO studentclasses VALUES (20797, 4576, 3902, 4);
INSERT INTO studentclasses VALUES (20798, 4576, 3933, 8);
INSERT INTO studentclasses VALUES (20799, 4576, 3934, 3);
INSERT INTO studentclasses VALUES (20800, 4576, 3830, 9);
INSERT INTO studentclasses VALUES (20801, 4577, 3935, 2);
INSERT INTO studentclasses VALUES (20802, 4577, 3810, 9);
INSERT INTO studentclasses VALUES (20803, 4577, 3893, 8);
INSERT INTO studentclasses VALUES (20804, 4577, 3886, 2);
INSERT INTO studentclasses VALUES (20805, 4577, 3661, 5);
INSERT INTO studentclasses VALUES (20806, 4578, 3936, 3);
INSERT INTO studentclasses VALUES (20807, 4578, 3832, 2);
INSERT INTO studentclasses VALUES (20808, 4578, 3698, 1);
INSERT INTO studentclasses VALUES (20809, 4578, 3931, 4);
INSERT INTO studentclasses VALUES (20810, 4578, 3678, 1);
INSERT INTO studentclasses VALUES (20811, 4579, 3926, 2);
INSERT INTO studentclasses VALUES (20812, 4579, 3887, 3);
INSERT INTO studentclasses VALUES (20813, 4579, 3842, 4);
INSERT INTO studentclasses VALUES (20814, 4579, 3937, 1);
INSERT INTO studentclasses VALUES (20815, 4579, 3834, 1);
INSERT INTO studentclasses VALUES (20816, 4580, 3938, 5);
INSERT INTO studentclasses VALUES (20817, 4580, 3842, 2);
INSERT INTO studentclasses VALUES (20818, 4580, 3939, 9);
INSERT INTO studentclasses VALUES (20819, 4580, 3830, 1);
INSERT INTO studentclasses VALUES (20820, 4580, 3639, 1);
INSERT INTO studentclasses VALUES (20821, 4581, 3940, 4);
INSERT INTO studentclasses VALUES (20822, 4581, 3941, 7);
INSERT INTO studentclasses VALUES (20823, 4581, 3810, 8);
INSERT INTO studentclasses VALUES (20824, 4581, 3842, 9);
INSERT INTO studentclasses VALUES (20825, 4581, 3834, 5);
INSERT INTO studentclasses VALUES (20826, 4582, 3911, 3);
INSERT INTO studentclasses VALUES (20827, 4582, 3933, 9);
INSERT INTO studentclasses VALUES (20828, 4582, 3720, 6);
INSERT INTO studentclasses VALUES (20829, 4582, 3914, 4);
INSERT INTO studentclasses VALUES (20830, 4582, 3834, 6);
INSERT INTO studentclasses VALUES (20831, 4583, 3942, 5);
INSERT INTO studentclasses VALUES (20832, 4583, 3754, 5);
INSERT INTO studentclasses VALUES (20833, 4583, 3832, 7);
INSERT INTO studentclasses VALUES (20834, 4583, 3829, 2);
INSERT INTO studentclasses VALUES (20835, 4583, 3661, 2);
INSERT INTO studentclasses VALUES (20836, 4584, 3903, 3);
INSERT INTO studentclasses VALUES (20837, 4584, 3943, 2);
INSERT INTO studentclasses VALUES (20838, 4584, 3944, 4);
INSERT INTO studentclasses VALUES (20839, 4584, 3945, 2);
INSERT INTO studentclasses VALUES (20840, 4584, 3834, 2);
INSERT INTO studentclasses VALUES (20841, 4585, 3946, 5);
INSERT INTO studentclasses VALUES (20842, 4585, 3840, 7);
INSERT INTO studentclasses VALUES (20843, 4585, 3720, 6);
INSERT INTO studentclasses VALUES (20844, 4585, 3862, 7);
INSERT INTO studentclasses VALUES (20845, 4585, 3661, 12);
INSERT INTO studentclasses VALUES (20846, 4586, 3947, 5);
INSERT INTO studentclasses VALUES (20847, 4586, 3773, 4);
INSERT INTO studentclasses VALUES (20848, 4586, 3686, 6);
INSERT INTO studentclasses VALUES (20849, 4586, 3829, 1);
INSERT INTO studentclasses VALUES (20850, 4586, 3745, 1);
INSERT INTO studentclasses VALUES (20851, 4587, 3848, 4);
INSERT INTO studentclasses VALUES (20852, 4587, 3866, 6);
INSERT INTO studentclasses VALUES (20853, 4587, 3849, 3);
INSERT INTO studentclasses VALUES (20854, 4587, 3867, 1);
INSERT INTO studentclasses VALUES (20855, 4587, 3710, 5);
INSERT INTO studentclasses VALUES (20856, 4588, 3948, 4);
INSERT INTO studentclasses VALUES (20857, 4588, 3842, 8);
INSERT INTO studentclasses VALUES (20858, 4588, 3879, 2);
INSERT INTO studentclasses VALUES (20859, 4588, 3804, 1);
INSERT INTO studentclasses VALUES (20860, 4588, 3834, 7);
INSERT INTO studentclasses VALUES (20861, 4589, 3949, 3);
INSERT INTO studentclasses VALUES (20862, 4589, 3848, 3);
INSERT INTO studentclasses VALUES (20863, 4589, 3866, 7);
INSERT INTO studentclasses VALUES (20864, 4589, 3867, 1);
INSERT INTO studentclasses VALUES (20865, 4589, 3710, 3);
INSERT INTO studentclasses VALUES (20866, 4590, 3892, 5);
INSERT INTO studentclasses VALUES (20867, 4590, 3871, 6);
INSERT INTO studentclasses VALUES (20868, 4590, 3950, 9);
INSERT INTO studentclasses VALUES (20869, 4590, 3829, 1);
INSERT INTO studentclasses VALUES (20870, 4590, 3698, 6);
INSERT INTO studentclasses VALUES (20871, 4591, 3859, 4);
INSERT INTO studentclasses VALUES (20872, 4591, 3832, 2);
INSERT INTO studentclasses VALUES (20873, 4591, 3656, 2);
INSERT INTO studentclasses VALUES (20874, 4591, 3661, 1);
INSERT INTO studentclasses VALUES (20875, 4591, 3951, 2);
INSERT INTO studentclasses VALUES (20876, 4592, 3952, 4);
INSERT INTO studentclasses VALUES (20877, 4592, 3953, 3);
INSERT INTO studentclasses VALUES (20878, 4592, 3837, 11);
INSERT INTO studentclasses VALUES (20879, 4592, 3838, 1);
INSERT INTO studentclasses VALUES (20880, 4592, 3721, 6);
INSERT INTO studentclasses VALUES (20881, 4593, 3954, 5);
INSERT INTO studentclasses VALUES (20882, 4593, 3832, 8);
INSERT INTO studentclasses VALUES (20883, 4593, 3656, 6);
INSERT INTO studentclasses VALUES (20884, 4593, 3708, 5);
INSERT INTO studentclasses VALUES (20885, 4593, 3745, 5);
INSERT INTO studentclasses VALUES (20886, 4594, 3857, 5);
INSERT INTO studentclasses VALUES (20887, 4594, 3837, 11);
INSERT INTO studentclasses VALUES (20888, 4594, 3882, 1);
INSERT INTO studentclasses VALUES (20889, 4594, 3830, 4);
INSERT INTO studentclasses VALUES (20890, 4594, 3643, 2);
INSERT INTO studentclasses VALUES (20891, 4595, 3857, 5);
INSERT INTO studentclasses VALUES (20892, 4595, 3837, 2);
INSERT INTO studentclasses VALUES (20893, 4595, 3869, 4);
INSERT INTO studentclasses VALUES (20894, 4595, 3882, 1);
INSERT INTO studentclasses VALUES (20895, 4595, 3830, 1);
INSERT INTO studentclasses VALUES (20896, 4596, 3857, 4);
INSERT INTO studentclasses VALUES (20897, 4596, 3837, 8);
INSERT INTO studentclasses VALUES (20898, 4596, 3869, 6);
INSERT INTO studentclasses VALUES (20899, 4596, 3838, 2);
INSERT INTO studentclasses VALUES (20900, 4596, 3830, 6);
INSERT INTO studentclasses VALUES (20901, 4597, 3868, 4);
INSERT INTO studentclasses VALUES (20902, 4597, 3837, 11);
INSERT INTO studentclasses VALUES (20903, 4597, 3869, 7);
INSERT INTO studentclasses VALUES (20904, 4597, 3882, 2);
INSERT INTO studentclasses VALUES (20905, 4597, 3830, 4);
INSERT INTO studentclasses VALUES (20906, 4598, 3955, 3);
INSERT INTO studentclasses VALUES (20907, 4598, 3956, 2);
INSERT INTO studentclasses VALUES (20908, 4598, 3842, 7);
INSERT INTO studentclasses VALUES (20909, 4598, 3957, 4);
INSERT INTO studentclasses VALUES (20910, 4598, 3958, 4);
INSERT INTO studentclasses VALUES (20911, 4598, 3834, 2);
INSERT INTO studentclasses VALUES (20912, 4599, 3947, 7);
INSERT INTO studentclasses VALUES (20913, 4599, 3793, 8);
INSERT INTO studentclasses VALUES (20914, 4599, 3736, 9);
INSERT INTO studentclasses VALUES (20915, 4599, 3829, 4);
INSERT INTO studentclasses VALUES (20916, 4599, 3745, 3);
INSERT INTO studentclasses VALUES (20917, 4600, 3946, 5);
INSERT INTO studentclasses VALUES (20918, 4600, 3959, 8);
INSERT INTO studentclasses VALUES (20919, 4600, 3656, 6);
INSERT INTO studentclasses VALUES (20920, 4600, 3862, 5);
INSERT INTO studentclasses VALUES (20921, 4600, 3745, 8);
INSERT INTO studentclasses VALUES (20922, 4601, 3813, 1);
INSERT INTO studentclasses VALUES (20923, 4601, 3773, 11);
INSERT INTO studentclasses VALUES (20924, 4601, 3686, 8);
INSERT INTO studentclasses VALUES (20925, 4601, 3960, 9);
INSERT INTO studentclasses VALUES (20926, 4601, 3698, 9);
INSERT INTO studentclasses VALUES (20927, 4602, 3857, 6);
INSERT INTO studentclasses VALUES (20928, 4602, 3837, 11);
INSERT INTO studentclasses VALUES (20929, 4602, 3882, 2);
INSERT INTO studentclasses VALUES (20930, 4602, 3830, 3);
INSERT INTO studentclasses VALUES (20931, 4602, 3643, 4);
INSERT INTO studentclasses VALUES (20932, 4603, 3961, 6);
INSERT INTO studentclasses VALUES (20933, 4603, 3837, 13);
INSERT INTO studentclasses VALUES (20934, 4603, 3729, 4);
INSERT INTO studentclasses VALUES (20935, 4603, 3962, 5);
INSERT INTO studentclasses VALUES (20936, 4603, 3698, 9);
INSERT INTO studentclasses VALUES (20937, 4604, 3813, 1);
INSERT INTO studentclasses VALUES (20938, 4604, 3736, 7);
INSERT INTO studentclasses VALUES (20939, 4604, 3686, 8);
INSERT INTO studentclasses VALUES (20940, 4604, 3963, 2);
INSERT INTO studentclasses VALUES (20941, 4604, 3745, 5);
INSERT INTO studentclasses VALUES (20942, 4605, 3964, 5);
INSERT INTO studentclasses VALUES (20943, 4605, 3866, 6);
INSERT INTO studentclasses VALUES (20944, 4605, 3849, 6);
INSERT INTO studentclasses VALUES (20945, 4605, 3862, 4);
INSERT INTO studentclasses VALUES (20946, 4605, 3710, 1);
INSERT INTO studentclasses VALUES (20947, 4606, 3930, 2);
INSERT INTO studentclasses VALUES (20948, 4606, 3965, 7);
INSERT INTO studentclasses VALUES (20949, 4606, 3966, 2);
INSERT INTO studentclasses VALUES (20950, 4606, 3920, 2);
INSERT INTO studentclasses VALUES (20951, 4606, 3661, 3);
INSERT INTO studentclasses VALUES (20952, 4607, 3825, 4);
INSERT INTO studentclasses VALUES (20953, 4607, 3871, 5);
INSERT INTO studentclasses VALUES (20954, 4607, 3866, 8);
INSERT INTO studentclasses VALUES (20955, 4607, 3829, 3);
INSERT INTO studentclasses VALUES (20956, 4607, 3710, 2);
INSERT INTO studentclasses VALUES (20957, 4608, 3813, 3);
INSERT INTO studentclasses VALUES (20958, 4608, 3773, 13);
INSERT INTO studentclasses VALUES (20959, 4608, 3960, 8);
INSERT INTO studentclasses VALUES (20960, 4608, 3752, 7);
INSERT INTO studentclasses VALUES (20961, 4608, 3745, 7);
INSERT INTO studentclasses VALUES (20962, 4609, 3967, 2);
INSERT INTO studentclasses VALUES (20963, 4609, 3842, 8);
INSERT INTO studentclasses VALUES (20964, 4609, 3968, 3);
INSERT INTO studentclasses VALUES (20965, 4609, 3834, 2);
INSERT INTO studentclasses VALUES (20966, 4609, 3678, 1);
INSERT INTO studentclasses VALUES (20967, 4610, 3969, 5);
INSERT INTO studentclasses VALUES (20968, 4610, 3970, 3);
INSERT INTO studentclasses VALUES (20969, 4610, 3893, 11);
INSERT INTO studentclasses VALUES (20970, 4610, 3829, 4);
INSERT INTO studentclasses VALUES (20971, 4610, 3834, 11);
INSERT INTO studentclasses VALUES (20972, 4611, 3892, 3);
INSERT INTO studentclasses VALUES (20973, 4611, 3899, 8);
INSERT INTO studentclasses VALUES (20974, 4611, 3869, 7);
INSERT INTO studentclasses VALUES (20975, 4611, 3971, 4);
INSERT INTO studentclasses VALUES (20976, 4611, 3745, 6);
INSERT INTO studentclasses VALUES (20977, 4612, 3835, 3);
INSERT INTO studentclasses VALUES (20978, 4612, 3857, 4);
INSERT INTO studentclasses VALUES (20979, 4612, 3837, 11);
INSERT INTO studentclasses VALUES (20980, 4612, 3838, 1);
INSERT INTO studentclasses VALUES (20981, 4612, 3830, 5);
INSERT INTO studentclasses VALUES (20982, 4613, 3870, 3);
INSERT INTO studentclasses VALUES (20983, 4613, 3871, 6);
INSERT INTO studentclasses VALUES (20984, 4613, 3866, 9);
INSERT INTO studentclasses VALUES (20985, 4613, 3844, 1);
INSERT INTO studentclasses VALUES (20986, 4613, 3851, 5);
INSERT INTO studentclasses VALUES (20987, 4614, 3887, 5);
INSERT INTO studentclasses VALUES (20988, 4614, 3837, 9);
INSERT INTO studentclasses VALUES (20989, 4614, 3972, 3);
INSERT INTO studentclasses VALUES (20990, 4614, 3683, 5);
INSERT INTO studentclasses VALUES (20991, 4614, 3698, 4);
INSERT INTO studentclasses VALUES (20992, 4615, 3887, 8);
INSERT INTO studentclasses VALUES (20993, 4615, 3917, 8);
INSERT INTO studentclasses VALUES (20994, 4615, 3972, 11);
INSERT INTO studentclasses VALUES (20995, 4615, 3973, 4);
INSERT INTO studentclasses VALUES (20996, 4615, 3698, 6);
INSERT INTO studentclasses VALUES (20997, 4616, 3974, 1);
INSERT INTO studentclasses VALUES (20998, 4616, 3917, 7);
INSERT INTO studentclasses VALUES (20999, 4616, 3760, 1);
INSERT INTO studentclasses VALUES (21000, 4616, 3698, 1);
INSERT INTO studentclasses VALUES (21001, 4616, 3639, 1);
INSERT INTO studentclasses VALUES (21002, 4617, 3975, 6);
INSERT INTO studentclasses VALUES (21003, 4617, 3976, 5);
INSERT INTO studentclasses VALUES (21004, 4617, 3977, 3);
INSERT INTO studentclasses VALUES (21005, 4618, 3978, 5);
INSERT INTO studentclasses VALUES (21006, 4619, 3979, 3);
INSERT INTO studentclasses VALUES (21007, 4620, 3980, 4);
INSERT INTO studentclasses VALUES (21008, 4620, 3981, 5);
INSERT INTO studentclasses VALUES (21009, 4621, 3979, 11);
INSERT INTO studentclasses VALUES (21010, 4622, 3982, 13);
INSERT INTO studentclasses VALUES (21011, 4622, 3983, 4);
INSERT INTO studentclasses VALUES (21012, 4623, 3979, 3);
INSERT INTO studentclasses VALUES (21013, 4624, 3979, 1);
INSERT INTO studentclasses VALUES (21014, 4625, 3979, 3);
INSERT INTO studentclasses VALUES (21015, 4626, 3984, 3);
INSERT INTO studentclasses VALUES (21016, 4626, 3985, 11);
INSERT INTO studentclasses VALUES (21017, 4627, 3975, 4);
INSERT INTO studentclasses VALUES (21018, 4627, 3986, 7);
INSERT INTO studentclasses VALUES (21019, 4628, 3987, 7);
INSERT INTO studentclasses VALUES (21020, 4628, 3988, 8);
INSERT INTO studentclasses VALUES (21021, 4629, 3989, 4);
INSERT INTO studentclasses VALUES (21022, 4630, 3990, 3);
INSERT INTO studentclasses VALUES (21023, 4630, 3991, 11);
INSERT INTO studentclasses VALUES (21024, 4631, 3992, 7);
INSERT INTO studentclasses VALUES (21025, 4631, 3977, 3);
INSERT INTO studentclasses VALUES (21026, 4632, 3977, 2);
INSERT INTO studentclasses VALUES (21027, 4632, 3993, 13);
INSERT INTO studentclasses VALUES (21028, 4633, 3994, 8);
INSERT INTO studentclasses VALUES (21029, 4634, 3995, 2);
INSERT INTO studentclasses VALUES (21030, 4634, 3996, 4);
INSERT INTO studentclasses VALUES (21031, 4635, 3997, 5);
INSERT INTO studentclasses VALUES (21032, 4635, 3993, 5);
INSERT INTO studentclasses VALUES (21033, 4636, 3998, 11);
INSERT INTO studentclasses VALUES (21034, 4636, 3999, 10);
INSERT INTO studentclasses VALUES (21035, 4637, 4000, 7);
INSERT INTO studentclasses VALUES (21036, 4637, 3991, 9);
INSERT INTO studentclasses VALUES (21037, 4638, 3993, 11);
INSERT INTO studentclasses VALUES (21038, 4639, 4001, 7);
INSERT INTO studentclasses VALUES (21039, 4640, 3993, 4);
INSERT INTO studentclasses VALUES (21040, 4641, 3998, 2);
INSERT INTO studentclasses VALUES (21041, 4641, 3991, 9);
INSERT INTO studentclasses VALUES (21042, 4642, 4002, 8);
INSERT INTO studentclasses VALUES (21043, 4643, 4003, 8);
INSERT INTO studentclasses VALUES (21044, 4644, 4004, 6);
INSERT INTO studentclasses VALUES (21045, 4644, 3989, 4);
INSERT INTO studentclasses VALUES (21046, 4645, 3988, 3);
INSERT INTO studentclasses VALUES (21047, 4646, 4005, 5);
INSERT INTO studentclasses VALUES (21048, 4646, 4006, 1);
INSERT INTO studentclasses VALUES (21049, 4647, 4007, 11);
INSERT INTO studentclasses VALUES (21050, 4647, 3993, 2);
INSERT INTO studentclasses VALUES (21051, 4648, 4007, 3);
INSERT INTO studentclasses VALUES (21052, 4649, 3995, 5);
INSERT INTO studentclasses VALUES (21053, 4649, 4007, 3);
INSERT INTO studentclasses VALUES (21054, 4650, 4008, 9);
INSERT INTO studentclasses VALUES (21055, 4650, 3981, 5);
INSERT INTO studentclasses VALUES (21056, 4651, 4005, 7);
INSERT INTO studentclasses VALUES (21057, 4651, 4003, 8);
INSERT INTO studentclasses VALUES (21058, 4652, 4009, 4);
INSERT INTO studentclasses VALUES (21059, 4652, 4007, 5);
INSERT INTO studentclasses VALUES (21060, 4653, 4010, 3);
INSERT INTO studentclasses VALUES (21061, 4653, 3996, 3);
INSERT INTO studentclasses VALUES (21062, 4654, 3991, 8);
INSERT INTO studentclasses VALUES (21063, 4655, 4003, 4);
INSERT INTO studentclasses VALUES (21064, 4655, 4007, 11);
INSERT INTO studentclasses VALUES (21065, 4656, 3993, 11);
INSERT INTO studentclasses VALUES (21066, 4657, 4011, 4);
INSERT INTO studentclasses VALUES (21067, 4658, 4007, 11);
INSERT INTO studentclasses VALUES (21068, 4658, 3993, 5);
INSERT INTO studentclasses VALUES (21069, 4659, 3989, 2);
INSERT INTO studentclasses VALUES (21070, 4659, 4001, 4);
INSERT INTO studentclasses VALUES (21071, 4660, 3989, 5);
INSERT INTO studentclasses VALUES (21072, 4660, 3994, 1);
INSERT INTO studentclasses VALUES (21073, 4661, 4012, 5);
INSERT INTO studentclasses VALUES (21074, 4662, 4013, 8);
INSERT INTO studentclasses VALUES (21075, 4663, 4014, 8);
INSERT INTO studentclasses VALUES (21076, 4663, 4015, 4);
INSERT INTO studentclasses VALUES (21077, 4664, 4016, 7);
INSERT INTO studentclasses VALUES (21078, 4665, 4017, 2);
INSERT INTO studentclasses VALUES (21079, 4666, 3994, 6);
INSERT INTO studentclasses VALUES (21080, 4667, 4018, 6);
INSERT INTO studentclasses VALUES (21081, 4668, 4019, 5);
INSERT INTO studentclasses VALUES (21082, 4669, 4020, 4);
INSERT INTO studentclasses VALUES (21083, 4669, 4021, 2);
INSERT INTO studentclasses VALUES (21084, 4670, 4000, 1);
INSERT INTO studentclasses VALUES (21085, 4671, 4022, 4);
INSERT INTO studentclasses VALUES (21086, 4672, 4022, 7);
INSERT INTO studentclasses VALUES (21087, 4673, 4023, 3);
INSERT INTO studentclasses VALUES (21088, 4673, 4024, 5);
INSERT INTO studentclasses VALUES (21089, 4674, 4025, 1);
INSERT INTO studentclasses VALUES (21090, 4674, 3981, 3);
INSERT INTO studentclasses VALUES (21091, 4675, 4026, 1);
INSERT INTO studentclasses VALUES (21092, 4676, 4027, 11);
INSERT INTO studentclasses VALUES (21093, 4677, 4007, 11);
INSERT INTO studentclasses VALUES (21094, 4677, 3993, 4);
INSERT INTO studentclasses VALUES (21095, 4678, 4028, 5);
INSERT INTO studentclasses VALUES (21096, 4679, 4016, 3);
INSERT INTO studentclasses VALUES (21097, 4680, 4029, 2);
INSERT INTO studentclasses VALUES (21098, 4681, 4018, 5);
INSERT INTO studentclasses VALUES (21099, 4682, 4007, 2);
INSERT INTO studentclasses VALUES (21100, 4682, 3993, 1);
INSERT INTO studentclasses VALUES (21101, 4683, 4030, 8);
INSERT INTO studentclasses VALUES (21102, 4684, 4031, 1);
INSERT INTO studentclasses VALUES (21103, 4685, 4029, 1);
INSERT INTO studentclasses VALUES (21104, 4686, 4032, 1);
INSERT INTO studentclasses VALUES (21105, 4687, 4001, 9);
INSERT INTO studentclasses VALUES (21106, 4688, 4033, 1);
INSERT INTO studentclasses VALUES (21107, 4688, 4034, 3);
INSERT INTO studentclasses VALUES (21108, 4689, 4019, 3);
INSERT INTO studentclasses VALUES (21109, 4690, 3994, 8);
INSERT INTO studentclasses VALUES (21110, 4691, 4000, 5);
INSERT INTO studentclasses VALUES (21111, 4692, 4032, 2);
INSERT INTO studentclasses VALUES (21112, 4693, 4028, 5);
INSERT INTO studentclasses VALUES (21113, 4694, 4035, 5);
INSERT INTO studentclasses VALUES (21114, 4695, 4007, 1);
INSERT INTO studentclasses VALUES (21115, 4695, 3993, 1);
INSERT INTO studentclasses VALUES (21116, 4696, 4036, 6);
INSERT INTO studentclasses VALUES (21117, 4697, 4035, 1);
INSERT INTO studentclasses VALUES (21118, 4698, 4030, 7);
INSERT INTO studentclasses VALUES (21119, 4699, 4019, 4);
INSERT INTO studentclasses VALUES (21120, 4700, 4029, 7);
INSERT INTO studentclasses VALUES (21121, 4700, 4037, 2);
INSERT INTO studentclasses VALUES (21122, 4701, 4027, 5);
INSERT INTO studentclasses VALUES (21123, 4702, 4036, 5);
INSERT INTO studentclasses VALUES (21124, 4703, 4038, 2);
INSERT INTO studentclasses VALUES (21125, 4703, 4039, 3);
INSERT INTO studentclasses VALUES (21126, 4704, 4040, 2);
INSERT INTO studentclasses VALUES (21127, 4705, 4000, 5);
INSERT INTO studentclasses VALUES (21128, 4706, 4027, 11);
INSERT INTO studentclasses VALUES (21129, 4707, 3994, 9);
INSERT INTO studentclasses VALUES (21130, 4708, 4041, 11);
INSERT INTO studentclasses VALUES (21131, 4709, 4022, 4);
INSERT INTO studentclasses VALUES (21132, 4710, 4031, 3);
INSERT INTO studentclasses VALUES (21133, 4711, 4042, 9);
INSERT INTO studentclasses VALUES (21134, 4712, 4022, 1);
INSERT INTO studentclasses VALUES (21135, 4713, 4043, 6);
INSERT INTO studentclasses VALUES (21136, 4714, 4044, 11);
INSERT INTO studentclasses VALUES (21137, 4714, 4045, 5);
INSERT INTO studentclasses VALUES (21138, 4714, 4046, 11);
INSERT INTO studentclasses VALUES (21139, 4714, 4047, 6);
INSERT INTO studentclasses VALUES (21140, 4714, 4048, 11);
INSERT INTO studentclasses VALUES (21141, 4715, 4049, 14);
INSERT INTO studentclasses VALUES (21142, 4715, 4050, 14);
INSERT INTO studentclasses VALUES (21143, 4715, 4051, 7);
INSERT INTO studentclasses VALUES (21144, 4715, 4052, 4);
INSERT INTO studentclasses VALUES (21145, 4715, 4048, 10);
INSERT INTO studentclasses VALUES (21146, 4716, 4053, 3);
INSERT INTO studentclasses VALUES (21147, 4717, 4051, 6);
INSERT INTO studentclasses VALUES (21148, 4717, 4054, 11);
INSERT INTO studentclasses VALUES (21149, 4717, 4055, 5);
INSERT INTO studentclasses VALUES (21150, 4717, 4056, 4);
INSERT INTO studentclasses VALUES (21151, 4717, 4057, 13);
INSERT INTO studentclasses VALUES (21152, 4718, 4055, 4);
INSERT INTO studentclasses VALUES (21153, 4718, 4053, 3);
INSERT INTO studentclasses VALUES (21154, 4718, 4058, 14);
INSERT INTO studentclasses VALUES (21155, 4718, 4059, 6);
INSERT INTO studentclasses VALUES (21156, 4718, 4048, 9);
INSERT INTO studentclasses VALUES (21157, 4719, 4060, 4);
INSERT INTO studentclasses VALUES (21158, 4719, 4061, 2);
INSERT INTO studentclasses VALUES (21159, 4719, 4044, 11);
INSERT INTO studentclasses VALUES (21160, 4719, 4062, 5);
INSERT INTO studentclasses VALUES (21161, 4719, 4063, 4);
INSERT INTO studentclasses VALUES (21162, 4719, 4056, 3);
INSERT INTO studentclasses VALUES (21163, 4720, 4064, 11);
INSERT INTO studentclasses VALUES (21164, 4720, 4065, 14);
INSERT INTO studentclasses VALUES (21165, 4720, 4066, 9);
INSERT INTO studentclasses VALUES (21166, 4720, 4067, 8);
INSERT INTO studentclasses VALUES (21167, 4720, 4068, 8);
INSERT INTO studentclasses VALUES (21168, 4720, 4062, 11);
INSERT INTO studentclasses VALUES (21169, 4720, 4069, 9);
INSERT INTO studentclasses VALUES (21170, 4721, 4064, 5);
INSERT INTO studentclasses VALUES (21171, 4721, 4070, 14);
INSERT INTO studentclasses VALUES (21172, 4721, 4054, 11);
INSERT INTO studentclasses VALUES (21173, 4721, 4071, 8);
INSERT INTO studentclasses VALUES (21174, 4721, 4072, 7);
INSERT INTO studentclasses VALUES (21175, 4722, 4051, 6);
INSERT INTO studentclasses VALUES (21176, 4722, 4054, 11);
INSERT INTO studentclasses VALUES (21177, 4722, 4055, 6);
INSERT INTO studentclasses VALUES (21178, 4722, 4052, 3);
INSERT INTO studentclasses VALUES (21179, 4722, 4073, 9);
INSERT INTO studentclasses VALUES (21180, 4722, 4056, 4);
INSERT INTO studentclasses VALUES (21181, 4723, 4074, 14);
INSERT INTO studentclasses VALUES (21182, 4723, 4075, 11);
INSERT INTO studentclasses VALUES (21183, 4724, 4076, 7);
INSERT INTO studentclasses VALUES (21184, 4724, 4077, 8);
INSERT INTO studentclasses VALUES (21185, 4724, 4056, 3);
INSERT INTO studentclasses VALUES (21186, 4724, 4048, 11);
INSERT INTO studentclasses VALUES (21187, 4725, 4074, 14);
INSERT INTO studentclasses VALUES (21188, 4725, 4075, 11);
INSERT INTO studentclasses VALUES (21189, 4725, 4078, 11);
INSERT INTO studentclasses VALUES (21190, 4725, 4079, 3);
INSERT INTO studentclasses VALUES (21191, 4725, 4063, 6);
INSERT INTO studentclasses VALUES (21192, 4725, 4080, 1);
INSERT INTO studentclasses VALUES (21193, 4725, 4081, 9);
INSERT INTO studentclasses VALUES (21194, 4726, 4082, 2);
INSERT INTO studentclasses VALUES (21195, 4726, 4083, 7);
INSERT INTO studentclasses VALUES (21196, 4726, 4051, 8);
INSERT INTO studentclasses VALUES (21197, 4726, 4071, 8);
INSERT INTO studentclasses VALUES (21198, 4726, 4068, 2);
INSERT INTO studentclasses VALUES (21199, 4726, 4084, 7);
INSERT INTO studentclasses VALUES (21200, 4727, 4085, 5);
INSERT INTO studentclasses VALUES (21201, 4727, 4086, 2);
INSERT INTO studentclasses VALUES (21202, 4727, 4087, 10);
INSERT INTO studentclasses VALUES (21203, 4727, 4088, 3);
INSERT INTO studentclasses VALUES (21204, 4727, 4089, 13);
INSERT INTO studentclasses VALUES (21205, 4727, 4057, 8);
INSERT INTO studentclasses VALUES (21206, 4728, 4090, 9);
INSERT INTO studentclasses VALUES (21207, 4728, 4091, 6);
INSERT INTO studentclasses VALUES (21208, 4728, 4062, 6);
INSERT INTO studentclasses VALUES (21209, 4728, 4092, 5);
INSERT INTO studentclasses VALUES (21210, 4728, 4053, 7);
INSERT INTO studentclasses VALUES (21211, 4728, 4093, 11);
INSERT INTO studentclasses VALUES (21212, 4729, 4066, 3);
INSERT INTO studentclasses VALUES (21213, 4729, 4054, 8);
INSERT INTO studentclasses VALUES (21214, 4729, 4094, 6);
INSERT INTO studentclasses VALUES (21215, 4729, 4045, 4);
INSERT INTO studentclasses VALUES (21216, 4729, 4055, 8);
INSERT INTO studentclasses VALUES (21217, 4729, 4052, 1);
INSERT INTO studentclasses VALUES (21218, 4730, 4095, 3);
INSERT INTO studentclasses VALUES (21219, 4730, 4064, 11);
INSERT INTO studentclasses VALUES (21220, 4730, 4065, 14);
INSERT INTO studentclasses VALUES (21221, 4730, 4067, 8);
INSERT INTO studentclasses VALUES (21222, 4730, 4046, 11);
INSERT INTO studentclasses VALUES (21223, 4730, 4057, 11);
INSERT INTO studentclasses VALUES (21224, 4731, 4066, 7);
INSERT INTO studentclasses VALUES (21225, 4731, 4067, 9);
INSERT INTO studentclasses VALUES (21226, 4731, 4084, 6);
INSERT INTO studentclasses VALUES (21227, 4731, 4092, 4);
INSERT INTO studentclasses VALUES (21228, 4731, 4048, 9);
INSERT INTO studentclasses VALUES (21229, 4732, 4096, 11);
INSERT INTO studentclasses VALUES (21230, 4732, 4097, 2);
INSERT INTO studentclasses VALUES (21231, 4732, 4074, 14);
INSERT INTO studentclasses VALUES (21232, 4732, 4075, 11);
INSERT INTO studentclasses VALUES (21233, 4732, 4089, 6);
INSERT INTO studentclasses VALUES (21234, 4732, 4047, 12);
INSERT INTO studentclasses VALUES (21235, 4732, 4057, 8);
INSERT INTO studentclasses VALUES (21236, 4733, 4066, 6);
INSERT INTO studentclasses VALUES (21237, 4733, 4071, 11);
INSERT INTO studentclasses VALUES (21238, 4733, 4084, 6);
INSERT INTO studentclasses VALUES (21239, 4733, 4092, 6);
INSERT INTO studentclasses VALUES (21240, 4733, 4057, 9);
INSERT INTO studentclasses VALUES (21241, 4734, 4098, 14);
INSERT INTO studentclasses VALUES (21242, 4734, 4075, 5);
INSERT INTO studentclasses VALUES (21243, 4734, 4066, 5);
INSERT INTO studentclasses VALUES (21244, 4734, 4054, 2);
INSERT INTO studentclasses VALUES (21245, 4734, 4055, 6);
INSERT INTO studentclasses VALUES (21246, 4734, 4092, 13);
INSERT INTO studentclasses VALUES (21247, 4734, 4053, 7);
INSERT INTO studentclasses VALUES (21248, 4735, 4064, 11);
INSERT INTO studentclasses VALUES (21249, 4735, 4070, 14);
INSERT INTO studentclasses VALUES (21250, 4735, 4051, 9);
INSERT INTO studentclasses VALUES (21251, 4735, 4078, 11);
INSERT INTO studentclasses VALUES (21252, 4735, 4055, 8);
INSERT INTO studentclasses VALUES (21253, 4735, 4092, 4);
INSERT INTO studentclasses VALUES (21254, 4735, 4099, 2);
INSERT INTO studentclasses VALUES (21255, 4735, 4081, 6);
INSERT INTO studentclasses VALUES (21256, 4736, 4066, 5);
INSERT INTO studentclasses VALUES (21257, 4736, 4054, 3);
INSERT INTO studentclasses VALUES (21258, 4736, 4094, 6);
INSERT INTO studentclasses VALUES (21259, 4736, 4045, 4);
INSERT INTO studentclasses VALUES (21260, 4736, 4055, 2);
INSERT INTO studentclasses VALUES (21261, 4736, 4052, 5);
INSERT INTO studentclasses VALUES (21262, 4736, 4092, 5);
INSERT INTO studentclasses VALUES (21263, 4737, 4100, 5);
INSERT INTO studentclasses VALUES (21264, 4737, 4101, 11);
INSERT INTO studentclasses VALUES (21265, 4737, 4102, 8);
INSERT INTO studentclasses VALUES (21266, 4737, 4092, 13);
INSERT INTO studentclasses VALUES (21267, 4737, 4047, 5);
INSERT INTO studentclasses VALUES (21268, 4737, 4048, 11);
INSERT INTO studentclasses VALUES (21269, 4738, 4103, 6);
INSERT INTO studentclasses VALUES (21270, 4738, 4090, 11);
INSERT INTO studentclasses VALUES (21271, 4738, 4089, 9);
INSERT INTO studentclasses VALUES (21272, 4738, 4046, 8);
INSERT INTO studentclasses VALUES (21273, 4738, 4073, 9);
INSERT INTO studentclasses VALUES (21274, 4738, 4104, 3);
INSERT INTO studentclasses VALUES (21275, 4739, 4105, 9);
INSERT INTO studentclasses VALUES (21276, 4739, 4106, 3);
INSERT INTO studentclasses VALUES (21277, 4739, 4107, 2);
INSERT INTO studentclasses VALUES (21278, 4739, 4063, 2);
INSERT INTO studentclasses VALUES (21279, 4740, 4108, 4);
INSERT INTO studentclasses VALUES (21280, 4740, 4109, 9);
INSERT INTO studentclasses VALUES (21281, 4740, 4110, 8);
INSERT INTO studentclasses VALUES (21282, 4740, 4111, 4);
INSERT INTO studentclasses VALUES (21283, 4740, 4107, 7);
INSERT INTO studentclasses VALUES (21284, 4740, 4112, 9);
INSERT INTO studentclasses VALUES (21285, 4741, 4113, 4);
INSERT INTO studentclasses VALUES (21286, 4741, 4114, 9);
INSERT INTO studentclasses VALUES (21287, 4741, 4115, 7);
INSERT INTO studentclasses VALUES (21288, 4741, 4112, 12);
INSERT INTO studentclasses VALUES (21289, 4741, 4116, 5);
INSERT INTO studentclasses VALUES (21290, 4741, 4048, 8);
INSERT INTO studentclasses VALUES (21291, 4742, 4117, 6);
INSERT INTO studentclasses VALUES (21292, 4742, 4118, 5);
INSERT INTO studentclasses VALUES (21293, 4742, 4119, 3);
INSERT INTO studentclasses VALUES (21294, 4742, 4088, 5);
INSERT INTO studentclasses VALUES (21295, 4742, 4112, 6);
INSERT INTO studentclasses VALUES (21296, 4742, 4057, 8);
INSERT INTO studentclasses VALUES (21297, 4743, 4120, 8);
INSERT INTO studentclasses VALUES (21298, 4743, 4121, 9);
INSERT INTO studentclasses VALUES (21299, 4743, 4122, 9);
INSERT INTO studentclasses VALUES (21300, 4743, 4112, 9);
INSERT INTO studentclasses VALUES (21301, 4744, 4123, 4);
INSERT INTO studentclasses VALUES (21302, 4744, 4067, 2);
INSERT INTO studentclasses VALUES (21303, 4744, 4084, 2);
INSERT INTO studentclasses VALUES (21304, 4744, 4046, 5);
INSERT INTO studentclasses VALUES (21305, 4744, 4092, 3);
INSERT INTO studentclasses VALUES (21306, 4744, 4124, 2);
INSERT INTO studentclasses VALUES (21307, 4745, 4125, 4);
INSERT INTO studentclasses VALUES (21308, 4745, 4126, 5);
INSERT INTO studentclasses VALUES (21309, 4745, 4067, 11);
INSERT INTO studentclasses VALUES (21310, 4745, 4127, 8);


--
-- Name: studentclasses_studentclassid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 21310, true);


--
-- Data for Name: studentineligibilities; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO students VALUES (945, 955, '199938944', 1);
INSERT INTO students VALUES (946, 956, '200258957', 1);
INSERT INTO students VALUES (947, 957, '200261631', 1);
INSERT INTO students VALUES (948, 958, '200302684', 1);
INSERT INTO students VALUES (949, 959, '200306538', 1);
INSERT INTO students VALUES (950, 960, '200427046', 1);
INSERT INTO students VALUES (951, 961, '200505277', 1);
INSERT INTO students VALUES (952, 962, '200571597', 1);
INSERT INTO students VALUES (953, 963, '200604764', 1);
INSERT INTO students VALUES (954, 964, '200611321', 1);
INSERT INTO students VALUES (955, 965, '200618693', 1);
INSERT INTO students VALUES (956, 966, '200645172', 1);
INSERT INTO students VALUES (957, 967, '200678578', 1);
INSERT INTO students VALUES (958, 968, '200678652', 1);
INSERT INTO students VALUES (959, 969, '200660742', 1);
INSERT INTO students VALUES (960, 970, '200660849', 1);
INSERT INTO students VALUES (961, 971, '200702110', 1);
INSERT INTO students VALUES (962, 972, '200716081', 1);
INSERT INTO students VALUES (963, 973, '200722129', 1);
INSERT INTO students VALUES (964, 974, '200727064', 1);
INSERT INTO students VALUES (965, 975, '200729866', 1);
INSERT INTO students VALUES (966, 976, '200737513', 1);
INSERT INTO students VALUES (967, 977, '200742060', 1);
INSERT INTO students VALUES (968, 978, '200746440', 1);
INSERT INTO students VALUES (969, 979, '200746691', 1);
INSERT INTO students VALUES (970, 980, '200750610', 1);
INSERT INTO students VALUES (971, 981, '200776104', 1);
INSERT INTO students VALUES (972, 982, '200703789', 1);
INSERT INTO students VALUES (973, 983, '200801494', 1);
INSERT INTO students VALUES (974, 984, '200804269', 1);
INSERT INTO students VALUES (975, 985, '200805213', 1);
INSERT INTO students VALUES (976, 986, '200806725', 1);
INSERT INTO students VALUES (977, 987, '200807619', 1);
INSERT INTO students VALUES (978, 988, '200810012', 1);
INSERT INTO students VALUES (979, 989, '200810449', 1);
INSERT INTO students VALUES (980, 990, '200812434', 1);
INSERT INTO students VALUES (981, 991, '200816057', 1);
INSERT INTO students VALUES (982, 992, '200816182', 1);
INSERT INTO students VALUES (983, 993, '200818798', 1);
INSERT INTO students VALUES (984, 994, '200820492', 1);
INSERT INTO students VALUES (985, 995, '200820845', 1);
INSERT INTO students VALUES (986, 996, '200822195', 1);
INSERT INTO students VALUES (987, 997, '200824411', 1);
INSERT INTO students VALUES (988, 998, '200826125', 1);
INSERT INTO students VALUES (989, 999, '200826132', 1);
INSERT INTO students VALUES (990, 1000, '200829462', 1);
INSERT INTO students VALUES (991, 1001, '200831088', 1);
INSERT INTO students VALUES (992, 1002, '200835065', 1);
INSERT INTO students VALUES (993, 1003, '200838847', 1);
INSERT INTO students VALUES (994, 1004, '200850304', 1);
INSERT INTO students VALUES (995, 1005, '200854833', 1);
INSERT INTO students VALUES (996, 1006, '200859513', 1);
INSERT INTO students VALUES (997, 1007, '200861979', 1);
INSERT INTO students VALUES (998, 1008, '200863141', 1);
INSERT INTO students VALUES (999, 1009, '200863910', 1);
INSERT INTO students VALUES (1000, 1010, '200863943', 1);
INSERT INTO students VALUES (1001, 1011, '200867820', 1);
INSERT INTO students VALUES (1002, 1012, '200867969', 1);
INSERT INTO students VALUES (1003, 1013, '200869234', 1);
INSERT INTO students VALUES (1004, 1014, '200878505', 1);
INSERT INTO students VALUES (1005, 1015, '200878522', 1);
INSERT INTO students VALUES (1006, 1016, '200879055', 1);
INSERT INTO students VALUES (1007, 1017, '200751702', 1);
INSERT INTO students VALUES (1008, 1018, '200649333', 1);
INSERT INTO students VALUES (1009, 1019, '200704149', 1);
INSERT INTO students VALUES (1010, 1020, '200800722', 1);
INSERT INTO students VALUES (1011, 1021, '200800992', 1);
INSERT INTO students VALUES (1012, 1022, '200802019', 1);
INSERT INTO students VALUES (1013, 1023, '200805994', 1);
INSERT INTO students VALUES (1014, 1024, '200810511', 1);
INSERT INTO students VALUES (1015, 1025, '200810842', 1);
INSERT INTO students VALUES (1016, 1026, '200815563', 1);
INSERT INTO students VALUES (1017, 1027, '200816422', 1);
INSERT INTO students VALUES (1018, 1028, '200817653', 1);
INSERT INTO students VALUES (1019, 1029, '200850077', 1);
INSERT INTO students VALUES (1020, 1030, '200852284', 1);
INSERT INTO students VALUES (1021, 1031, '200865811', 1);
INSERT INTO students VALUES (1022, 1032, '200900039', 1);
INSERT INTO students VALUES (1023, 1033, '200900138', 1);
INSERT INTO students VALUES (1024, 1034, '200900163', 1);
INSERT INTO students VALUES (1025, 1035, '200900184', 1);
INSERT INTO students VALUES (1026, 1036, '200900407', 1);
INSERT INTO students VALUES (1027, 1037, '200900495', 1);
INSERT INTO students VALUES (1028, 1038, '200900643', 1);
INSERT INTO students VALUES (1029, 1039, '200900790', 1);
INSERT INTO students VALUES (1030, 1040, '200901056', 1);
INSERT INTO students VALUES (1031, 1041, '200903933', 1);
INSERT INTO students VALUES (1032, 1042, '200904996', 1);
INSERT INTO students VALUES (1033, 1043, '200905558', 1);
INSERT INTO students VALUES (1034, 1044, '200906611', 1);
INSERT INTO students VALUES (1035, 1045, '200906984', 1);
INSERT INTO students VALUES (1036, 1046, '200907623', 1);
INSERT INTO students VALUES (1037, 1047, '200909509', 1);
INSERT INTO students VALUES (1038, 1048, '200910151', 1);
INSERT INTO students VALUES (1039, 1049, '200910605', 1);
INSERT INTO students VALUES (1040, 1050, '200911631', 1);
INSERT INTO students VALUES (1041, 1051, '200911675', 1);
INSERT INTO students VALUES (1042, 1052, '200911724', 1);
INSERT INTO students VALUES (1043, 1053, '200911734', 1);
INSERT INTO students VALUES (1044, 1054, '200911738', 1);
INSERT INTO students VALUES (1045, 1055, '200911827', 1);
INSERT INTO students VALUES (1046, 1056, '200912221', 1);
INSERT INTO students VALUES (1047, 1057, '200912581', 1);
INSERT INTO students VALUES (1048, 1058, '200912820', 1);
INSERT INTO students VALUES (1049, 1059, '200912874', 1);
INSERT INTO students VALUES (1050, 1060, '200912972', 1);
INSERT INTO students VALUES (1051, 1061, '200913084', 1);
INSERT INTO students VALUES (1052, 1062, '200913146', 1);
INSERT INTO students VALUES (1053, 1063, '200913757', 1);
INSERT INTO students VALUES (1054, 1064, '200913846', 1);
INSERT INTO students VALUES (1055, 1065, '200913901', 1);
INSERT INTO students VALUES (1056, 1066, '200914214', 1);
INSERT INTO students VALUES (1057, 1067, '200914369', 1);
INSERT INTO students VALUES (1058, 1068, '200914550', 1);
INSERT INTO students VALUES (1059, 1069, '200915033', 1);
INSERT INTO students VALUES (1060, 1070, '200920483', 1);
INSERT INTO students VALUES (1061, 1071, '200920633', 1);
INSERT INTO students VALUES (1062, 1072, '200921105', 1);
INSERT INTO students VALUES (1063, 1073, '200921634', 1);
INSERT INTO students VALUES (1064, 1074, '200922056', 1);
INSERT INTO students VALUES (1065, 1075, '200922763', 1);
INSERT INTO students VALUES (1066, 1076, '200922784', 1);
INSERT INTO students VALUES (1067, 1077, '200922882', 1);
INSERT INTO students VALUES (1068, 1078, '200924554', 1);
INSERT INTO students VALUES (1069, 1079, '200925215', 1);
INSERT INTO students VALUES (1070, 1080, '200925241', 1);
INSERT INTO students VALUES (1071, 1081, '200925249', 1);
INSERT INTO students VALUES (1072, 1082, '200925556', 1);
INSERT INTO students VALUES (1073, 1083, '200925562', 1);
INSERT INTO students VALUES (1074, 1084, '200926277', 1);
INSERT INTO students VALUES (1075, 1085, '200926328', 1);
INSERT INTO students VALUES (1076, 1086, '200926380', 1);
INSERT INTO students VALUES (1077, 1087, '200926385', 1);
INSERT INTO students VALUES (1078, 1088, '200929259', 1);
INSERT INTO students VALUES (1079, 1089, '200929277', 1);
INSERT INTO students VALUES (1080, 1090, '200929367', 1);
INSERT INTO students VALUES (1081, 1091, '200929381', 1);
INSERT INTO students VALUES (1082, 1092, '200929428', 1);
INSERT INTO students VALUES (1083, 1093, '200929656', 1);
INSERT INTO students VALUES (1084, 1094, '200930017', 1);
INSERT INTO students VALUES (1085, 1095, '200932205', 1);
INSERT INTO students VALUES (1086, 1096, '200933686', 1);
INSERT INTO students VALUES (1087, 1097, '200935632', 1);
INSERT INTO students VALUES (1088, 1098, '200936633', 1);
INSERT INTO students VALUES (1089, 1099, '200937320', 1);
INSERT INTO students VALUES (1090, 1100, '200939122', 1);
INSERT INTO students VALUES (1091, 1101, '200940273', 1);
INSERT INTO students VALUES (1092, 1102, '200942368', 1);
INSERT INTO students VALUES (1093, 1103, '200942606', 1);
INSERT INTO students VALUES (1094, 1104, '200945214', 1);
INSERT INTO students VALUES (1095, 1105, '200945219', 1);
INSERT INTO students VALUES (1096, 1106, '200950378', 1);
INSERT INTO students VALUES (1097, 1107, '200950655', 1);
INSERT INTO students VALUES (1098, 1108, '200950663', 1);
INSERT INTO students VALUES (1099, 1109, '200951345', 1);
INSERT INTO students VALUES (1100, 1110, '200951383', 1);
INSERT INTO students VALUES (1101, 1111, '200952820', 1);
INSERT INTO students VALUES (1102, 1112, '200952936', 1);
INSERT INTO students VALUES (1103, 1113, '200953322', 1);
INSERT INTO students VALUES (1104, 1114, '200953427', 1);
INSERT INTO students VALUES (1105, 1115, '200953449', 1);
INSERT INTO students VALUES (1106, 1116, '200953589', 1);
INSERT INTO students VALUES (1107, 1117, '200953593', 1);
INSERT INTO students VALUES (1108, 1118, '200953879', 1);
INSERT INTO students VALUES (1109, 1119, '200953979', 1);
INSERT INTO students VALUES (1110, 1120, '200954553', 1);
INSERT INTO students VALUES (1111, 1121, '200955605', 1);
INSERT INTO students VALUES (1112, 1122, '200957922', 1);
INSERT INTO students VALUES (1113, 1123, '200960039', 1);
INSERT INTO students VALUES (1114, 1124, '200962443', 1);
INSERT INTO students VALUES (1115, 1125, '200978170', 1);
INSERT INTO students VALUES (1116, 1126, '200978810', 1);
INSERT INTO students VALUES (1117, 1127, '200978939', 1);
INSERT INTO students VALUES (1118, 1128, '200819985', 1);
INSERT INTO students VALUES (1119, 1129, '200824759', 1);
INSERT INTO students VALUES (1120, 1130, '200865810', 1);
INSERT INTO students VALUES (1121, 1131, '200804221', 1);


--
-- Name: students_studentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('students_studentid_seq', 1121, true);


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO studentterms VALUES (3979, 945, 19991, 'N/A', true);
INSERT INTO studentterms VALUES (3980, 945, 20001, 'N/A', true);
INSERT INTO studentterms VALUES (3981, 945, 20002, 'N/A', true);
INSERT INTO studentterms VALUES (3982, 945, 20003, 'N/A', true);
INSERT INTO studentterms VALUES (3983, 945, 20011, 'N/A', true);
INSERT INTO studentterms VALUES (3984, 945, 20012, 'N/A', true);
INSERT INTO studentterms VALUES (3985, 945, 20013, 'N/A', true);
INSERT INTO studentterms VALUES (3986, 945, 20021, 'N/A', true);
INSERT INTO studentterms VALUES (3987, 946, 20021, 'N/A', true);
INSERT INTO studentterms VALUES (3988, 947, 20021, 'N/A', true);
INSERT INTO studentterms VALUES (3989, 945, 20022, 'N/A', true);
INSERT INTO studentterms VALUES (3990, 946, 20022, 'N/A', true);
INSERT INTO studentterms VALUES (3991, 947, 20022, 'N/A', true);
INSERT INTO studentterms VALUES (3992, 945, 20031, 'N/A', true);
INSERT INTO studentterms VALUES (3993, 946, 20031, 'N/A', true);
INSERT INTO studentterms VALUES (3994, 947, 20031, 'N/A', true);
INSERT INTO studentterms VALUES (3995, 948, 20031, 'N/A', true);
INSERT INTO studentterms VALUES (3996, 949, 20031, 'N/A', true);
INSERT INTO studentterms VALUES (3997, 945, 20032, 'N/A', true);
INSERT INTO studentterms VALUES (3998, 946, 20032, 'N/A', true);
INSERT INTO studentterms VALUES (3999, 947, 20032, 'N/A', true);
INSERT INTO studentterms VALUES (4000, 948, 20032, 'N/A', true);
INSERT INTO studentterms VALUES (4001, 949, 20032, 'N/A', true);
INSERT INTO studentterms VALUES (4002, 946, 20033, 'N/A', true);
INSERT INTO studentterms VALUES (4003, 947, 20033, 'N/A', true);
INSERT INTO studentterms VALUES (4004, 948, 20033, 'N/A', true);
INSERT INTO studentterms VALUES (4005, 949, 20033, 'N/A', true);
INSERT INTO studentterms VALUES (4006, 946, 20041, 'N/A', true);
INSERT INTO studentterms VALUES (4007, 947, 20041, 'N/A', true);
INSERT INTO studentterms VALUES (4008, 948, 20041, 'N/A', true);
INSERT INTO studentterms VALUES (4009, 949, 20041, 'N/A', true);
INSERT INTO studentterms VALUES (4010, 950, 20041, 'N/A', true);
INSERT INTO studentterms VALUES (4011, 946, 20042, 'N/A', true);
INSERT INTO studentterms VALUES (4012, 947, 20042, 'N/A', true);
INSERT INTO studentterms VALUES (4013, 948, 20042, 'N/A', true);
INSERT INTO studentterms VALUES (4014, 949, 20042, 'N/A', true);
INSERT INTO studentterms VALUES (4015, 950, 20042, 'N/A', true);
INSERT INTO studentterms VALUES (4016, 946, 20043, 'N/A', true);
INSERT INTO studentterms VALUES (4017, 947, 20043, 'N/A', true);
INSERT INTO studentterms VALUES (4018, 948, 20043, 'N/A', true);
INSERT INTO studentterms VALUES (4019, 949, 20043, 'N/A', true);
INSERT INTO studentterms VALUES (4020, 950, 20043, 'N/A', true);
INSERT INTO studentterms VALUES (4021, 946, 20051, 'N/A', true);
INSERT INTO studentterms VALUES (4022, 947, 20051, 'N/A', true);
INSERT INTO studentterms VALUES (4023, 948, 20051, 'N/A', true);
INSERT INTO studentterms VALUES (4024, 949, 20051, 'N/A', true);
INSERT INTO studentterms VALUES (4025, 950, 20051, 'N/A', true);
INSERT INTO studentterms VALUES (4026, 951, 20051, 'N/A', true);
INSERT INTO studentterms VALUES (4027, 952, 20051, 'N/A', true);
INSERT INTO studentterms VALUES (4028, 946, 20052, 'N/A', true);
INSERT INTO studentterms VALUES (4029, 947, 20052, 'N/A', true);
INSERT INTO studentterms VALUES (4030, 948, 20052, 'N/A', true);
INSERT INTO studentterms VALUES (4031, 950, 20052, 'N/A', true);
INSERT INTO studentterms VALUES (4032, 951, 20052, 'N/A', true);
INSERT INTO studentterms VALUES (4033, 952, 20052, 'N/A', true);
INSERT INTO studentterms VALUES (4034, 947, 20053, 'N/A', true);
INSERT INTO studentterms VALUES (4035, 948, 20053, 'N/A', true);
INSERT INTO studentterms VALUES (4036, 951, 20053, 'N/A', true);
INSERT INTO studentterms VALUES (4037, 952, 20053, 'N/A', true);
INSERT INTO studentterms VALUES (4038, 947, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4039, 950, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4040, 951, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4041, 952, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4042, 953, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4043, 954, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4044, 955, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4045, 956, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4046, 957, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4047, 958, 20061, 'N/A', true);
INSERT INTO studentterms VALUES (4048, 947, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4049, 949, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4050, 950, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4051, 951, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4052, 952, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4053, 953, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4054, 954, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4055, 955, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4056, 956, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4057, 957, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4058, 958, 20062, 'N/A', true);
INSERT INTO studentterms VALUES (4059, 950, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4060, 951, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4061, 952, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4062, 954, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4063, 955, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4064, 956, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4065, 957, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4066, 958, 20063, 'N/A', true);
INSERT INTO studentterms VALUES (4067, 949, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4068, 950, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4069, 951, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4070, 952, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4071, 953, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4072, 954, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4073, 955, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4074, 956, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4075, 959, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4076, 960, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4077, 957, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4078, 958, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4079, 961, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4080, 962, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4081, 963, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4082, 964, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4083, 965, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4084, 966, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4085, 967, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4086, 968, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4087, 969, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4088, 970, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4089, 971, 20071, 'N/A', true);
INSERT INTO studentterms VALUES (4090, 947, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4091, 949, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4092, 950, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4093, 951, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4094, 952, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4095, 953, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4096, 954, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4097, 955, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4098, 956, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4099, 959, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4100, 960, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4101, 957, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4102, 958, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4103, 961, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4104, 962, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4105, 963, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4106, 964, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4107, 965, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4108, 966, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4109, 967, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4110, 968, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4111, 969, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4112, 970, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4113, 971, 20072, 'N/A', true);
INSERT INTO studentterms VALUES (4114, 950, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4115, 952, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4116, 953, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4117, 954, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4118, 956, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4119, 959, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4120, 957, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4121, 958, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4122, 961, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4123, 963, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4124, 964, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4125, 966, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4126, 967, 20073, 'N/A', true);
INSERT INTO studentterms VALUES (4127, 949, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4128, 951, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4129, 952, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4130, 953, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4131, 954, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4132, 955, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4133, 956, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4134, 959, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4135, 960, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4136, 957, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4137, 958, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4138, 961, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4139, 972, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4140, 962, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4141, 963, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4142, 964, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4143, 965, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4144, 966, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4145, 967, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4146, 968, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4147, 969, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4148, 970, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4149, 971, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4150, 973, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4151, 974, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4152, 975, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4153, 976, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4154, 977, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4155, 978, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4156, 979, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4157, 980, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4158, 981, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4159, 982, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4160, 983, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4161, 984, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4162, 985, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4163, 986, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4164, 987, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4165, 988, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4166, 989, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4167, 990, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4168, 991, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4169, 992, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4170, 993, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4171, 994, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4172, 995, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4173, 996, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4174, 997, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4175, 998, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4176, 999, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4177, 1000, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4178, 1001, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4179, 1002, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4180, 1003, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4181, 1004, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4182, 1005, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4183, 1006, 20081, 'N/A', true);
INSERT INTO studentterms VALUES (4184, 948, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4185, 949, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4186, 951, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4187, 952, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4188, 953, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4189, 954, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4190, 955, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4191, 956, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4192, 959, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4193, 960, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4194, 957, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4195, 958, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4196, 961, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4197, 972, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4198, 962, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4199, 963, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4200, 964, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4201, 965, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4202, 966, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4203, 967, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4204, 968, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4205, 969, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4206, 970, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4207, 1007, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4208, 971, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4209, 973, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4210, 974, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4211, 975, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4212, 976, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4213, 977, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4214, 978, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4215, 979, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4216, 980, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4217, 981, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4218, 982, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4219, 983, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4220, 984, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4221, 985, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4222, 986, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4223, 987, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4224, 988, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4225, 989, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4226, 990, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4227, 991, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4228, 992, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4229, 993, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4230, 994, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4231, 995, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4232, 996, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4233, 997, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4234, 998, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4235, 999, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4236, 1000, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4237, 1001, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4238, 1002, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4239, 1003, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4240, 1004, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4241, 1005, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4242, 1006, 20082, 'N/A', true);
INSERT INTO studentterms VALUES (4243, 948, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4244, 949, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4245, 954, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4246, 956, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4247, 959, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4248, 957, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4249, 961, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4250, 972, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4251, 963, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4252, 964, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4253, 966, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4254, 967, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4255, 968, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4256, 969, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4257, 1007, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4258, 976, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4259, 977, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4260, 978, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4261, 982, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4262, 984, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4263, 985, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4264, 987, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4265, 988, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4266, 989, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4267, 992, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4268, 993, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4269, 994, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4270, 995, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4271, 996, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4272, 997, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4273, 1000, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4274, 1001, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4275, 1002, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4276, 1003, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4277, 1004, 20083, 'N/A', true);
INSERT INTO studentterms VALUES (4278, 948, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4279, 949, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4280, 951, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4281, 952, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4282, 953, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4283, 954, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4284, 955, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4285, 956, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4286, 1008, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4287, 959, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4288, 960, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4289, 957, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4290, 958, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4291, 961, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4292, 972, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4293, 1009, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4294, 962, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4295, 963, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4296, 964, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4297, 965, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4298, 966, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4299, 967, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4300, 968, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4301, 969, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4302, 970, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4303, 1007, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4304, 971, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4305, 1010, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4306, 1011, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4307, 973, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4308, 1012, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4309, 974, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4310, 975, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4311, 1013, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4312, 976, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4313, 977, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4314, 978, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4315, 979, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4316, 1014, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4317, 1015, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4318, 980, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4319, 1016, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4320, 981, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4321, 982, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4322, 1017, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4323, 1018, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4324, 983, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4325, 984, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4326, 985, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4327, 986, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4328, 987, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4329, 988, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4330, 989, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4331, 990, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4332, 991, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4333, 992, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4334, 993, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4335, 1019, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4336, 994, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4337, 1020, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4338, 995, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4339, 996, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4340, 997, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4341, 998, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4342, 999, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4343, 1000, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4344, 1021, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4345, 1001, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4346, 1002, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4347, 1003, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4348, 1004, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4349, 1005, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4350, 1006, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4351, 1022, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4352, 1023, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4353, 1024, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4354, 1025, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4355, 1026, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4356, 1027, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4357, 1028, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4358, 1029, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4359, 1030, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4360, 1031, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4361, 1032, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4362, 1033, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4363, 1034, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4364, 1035, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4365, 1036, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4366, 1037, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4367, 1038, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4368, 1039, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4369, 1040, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4370, 1041, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4371, 1042, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4372, 1043, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4373, 1044, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4374, 1045, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4375, 1046, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4376, 1047, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4377, 1048, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4378, 1049, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4379, 1050, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4380, 1051, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4381, 1052, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4382, 1053, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4383, 1054, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4384, 1055, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4385, 1056, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4386, 1057, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4387, 1058, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4388, 1059, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4389, 1060, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4390, 1061, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4391, 1062, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4392, 1063, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4393, 1064, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4394, 1065, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4395, 1066, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4396, 1067, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4397, 1068, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4398, 1069, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4399, 1070, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4400, 1071, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4401, 1072, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4402, 1073, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4403, 1074, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4404, 1075, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4405, 1076, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4406, 1077, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4407, 1078, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4408, 1079, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4409, 1080, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4410, 1081, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4411, 1082, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4412, 1083, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4413, 1084, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4414, 1085, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4415, 1086, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4416, 1087, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4417, 1088, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4418, 1089, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4419, 1090, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4420, 1091, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4421, 1092, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4422, 1093, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4423, 1094, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4424, 1095, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4425, 1096, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4426, 1097, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4427, 1098, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4428, 1099, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4429, 1100, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4430, 1101, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4431, 1102, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4432, 1103, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4433, 1104, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4434, 1105, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4435, 1106, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4436, 1107, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4437, 1108, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4438, 1109, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4439, 1110, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4440, 1111, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4441, 1112, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4442, 1113, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4443, 1114, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4444, 1115, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4445, 1116, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4446, 1117, 20091, 'N/A', true);
INSERT INTO studentterms VALUES (4447, 948, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4448, 951, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4449, 953, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4450, 954, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4451, 955, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4452, 956, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4453, 1008, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4454, 959, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4455, 960, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4456, 957, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4457, 958, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4458, 961, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4459, 972, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4460, 1009, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4461, 962, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4462, 963, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4463, 964, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4464, 965, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4465, 966, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4466, 967, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4467, 968, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4468, 969, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4469, 970, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4470, 1007, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4471, 971, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4472, 1010, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4473, 1011, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4474, 973, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4475, 1012, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4476, 974, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4477, 975, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4478, 1013, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4479, 976, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4480, 977, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4481, 978, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4482, 979, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4483, 1014, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4484, 1015, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4485, 980, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4486, 1016, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4487, 981, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4488, 982, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4489, 1017, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4490, 1018, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4491, 983, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4492, 1118, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4493, 984, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4494, 985, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4495, 986, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4496, 987, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4497, 1119, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4498, 988, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4499, 989, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4500, 990, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4501, 991, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4502, 992, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4503, 993, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4504, 1019, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4505, 994, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4506, 1020, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4507, 995, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4508, 996, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4509, 997, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4510, 998, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4511, 999, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4512, 1000, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4513, 1120, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4514, 1021, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4515, 1001, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4516, 1002, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4517, 1003, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4518, 1004, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4519, 1005, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4520, 1006, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4521, 1022, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4522, 1023, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4523, 1024, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4524, 1025, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4525, 1026, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4526, 1027, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4527, 1028, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4528, 1029, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4529, 1030, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4530, 1031, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4531, 1032, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4532, 1033, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4533, 1034, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4534, 1035, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4535, 1036, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4536, 1037, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4537, 1038, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4538, 1039, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4539, 1040, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4540, 1041, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4541, 1042, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4542, 1043, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4543, 1044, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4544, 1045, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4545, 1046, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4546, 1047, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4547, 1048, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4548, 1049, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4549, 1050, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4550, 1051, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4551, 1052, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4552, 1053, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4553, 1054, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4554, 1055, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4555, 1056, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4556, 1057, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4557, 1058, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4558, 1059, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4559, 1060, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4560, 1061, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4561, 1062, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4562, 1063, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4563, 1064, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4564, 1065, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4565, 1066, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4566, 1067, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4567, 1068, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4568, 1069, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4569, 1070, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4570, 1071, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4571, 1072, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4572, 1073, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4573, 1074, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4574, 1075, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4575, 1076, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4576, 1077, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4577, 1078, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4578, 1079, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4579, 1080, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4580, 1081, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4581, 1082, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4582, 1083, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4583, 1084, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4584, 1085, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4585, 1086, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4586, 1087, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4587, 1088, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4588, 1089, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4589, 1090, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4590, 1091, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4591, 1092, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4592, 1093, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4593, 1094, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4594, 1095, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4595, 1096, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4596, 1097, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4597, 1098, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4598, 1099, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4599, 1100, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4600, 1101, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4601, 1102, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4602, 1103, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4603, 1104, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4604, 1105, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4605, 1106, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4606, 1107, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4607, 1108, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4608, 1109, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4609, 1110, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4610, 1111, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4611, 1112, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4612, 1113, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4613, 1114, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4614, 1115, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4615, 1116, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4616, 1117, 20092, 'N/A', true);
INSERT INTO studentterms VALUES (4617, 948, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4618, 951, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4619, 953, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4620, 954, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4621, 956, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4622, 1008, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4623, 960, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4624, 957, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4625, 958, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4626, 961, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4627, 962, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4628, 964, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4629, 965, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4630, 966, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4631, 969, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4632, 1007, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4633, 1011, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4634, 975, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4635, 1013, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4636, 977, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4637, 978, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4638, 1014, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4639, 1015, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4640, 1016, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4641, 981, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4642, 1017, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4643, 1018, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4644, 984, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4645, 985, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4646, 987, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4647, 988, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4648, 989, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4649, 991, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4650, 993, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4651, 994, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4652, 996, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4653, 998, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4654, 1000, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4655, 1021, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4656, 1001, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4657, 1002, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4658, 1003, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4659, 1022, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4660, 1027, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4661, 1028, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4662, 1032, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4663, 1034, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4664, 1039, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4665, 1041, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4666, 1042, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4667, 1044, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4668, 1045, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4669, 1046, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4670, 1047, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4671, 1048, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4672, 1051, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4673, 1054, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4674, 1055, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4675, 1057, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4676, 1058, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4677, 1059, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4678, 1060, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4679, 1062, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4680, 1063, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4681, 1072, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4682, 1073, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4683, 1074, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4684, 1075, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4685, 1079, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4686, 1080, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4687, 1082, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4688, 1083, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4689, 1084, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4690, 1086, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4691, 1088, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4692, 1089, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4693, 1090, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4694, 1091, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4695, 1092, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4696, 1093, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4697, 1095, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4698, 1098, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4699, 1099, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4700, 1101, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4701, 1102, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4702, 1103, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4703, 1104, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4704, 1105, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4705, 1106, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4706, 1107, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4707, 1108, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4708, 1109, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4709, 1110, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4710, 1113, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4711, 1114, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4712, 1115, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4713, 1116, 20093, 'N/A', true);
INSERT INTO studentterms VALUES (4714, 948, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4715, 951, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4716, 952, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4717, 953, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4718, 954, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4719, 956, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4720, 1008, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4721, 959, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4722, 960, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4723, 957, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4724, 958, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4725, 961, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4726, 972, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4727, 1009, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4728, 962, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4729, 963, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4730, 964, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4731, 965, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4732, 966, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4733, 967, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4734, 968, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4735, 969, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4736, 970, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4737, 1007, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4738, 971, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4739, 1010, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4740, 1011, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4741, 973, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4742, 1012, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4743, 1121, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4744, 974, 20101, 'N/A', true);
INSERT INTO studentterms VALUES (4745, 975, 20101, 'N/A', true);


--
-- Name: studentterms_studenttermid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 4745, true);


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
-- PostgreSQL database dump complete
--

