-- Lookup Tables
CREATE TABLE eligtwicefail (
    studentid integer,
    classid integer,
    courseid integer,
	section varchar(7),
	coursename varchar(45),
    termid integer
);

CREATE TABLE eligpasshalf (
	studentid integer,
    studenttermid integer,
	termid integer,
	failpercentage real
);

CREATE TABLE eligpasshalfmathcs (
	studentid integer,
    studenttermid integer,
	termid integer,
	failpercentage real
);

CREATE TABLE elig24unitspassing (
	studentid integer,
	yearid integer,
	unitspassed real
);

------------------ Insertions ------------------

----- Twice Fail -----
CREATE OR REPLACE FUNCTION f_getall_eligtwicefail() 
RETURNS SETOF t_elig_twicefailsubjects AS 
$$
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
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION f_getall_eligtwicefail() 
RETURNS SETOF t_elig_twicefailsubjects AS 
$$
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
$$
LANGUAGE plpgsql;

--SELECT DISTINCT * FROM f_getall_eligtwicefail() ORDER BY studentid, courseid, termid;

DELETE FROM eligtwicefail;
INSERT INTO eligtwicefail
SELECT DISTINCT * FROM f_getall_eligtwicefail() ORDER BY studentid, courseid, termid;


----- Pass Half -----
DROP FUNCTION f_getall_eligpasshalf() CASCADE;
CREATE OR REPLACE FUNCTION f_getall_eligpasshalf() 
RETURNS SETOF t_elig_passhalfpersem AS 
$$
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
$$
LANGUAGE plpgsql;

--SELECT DISTINCT * FROM f_getall_eligpasshalf() ORDER BY studentid, studenttermid, termid, failpercentage;

DELETE FROM eligpasshalf;
INSERT INTO eligpasshalf
SELECT DISTINCT * FROM f_getall_eligpasshalf() ORDER BY studentid, studenttermid, termid, failpercentage;


----- Pass Half Math CS -----
DROP FUNCTION f_getall_eligpasshalfmathcs() CASCADE;
CREATE OR REPLACE FUNCTION f_getall_eligpasshalfmathcs() 
RETURNS SETOF t_elig_passhalf_mathcs_persem AS 
$$
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
$$
LANGUAGE plpgsql;

--SELECT DISTINCT * FROM f_getall_eligpasshalfmathcs() ORDER BY studentid, studenttermid, termid, failpercentage;

INSERT INTO eligpasshalfmathcs
SELECT DISTINCT * FROM f_getall_eligpasshalfmathcs() ORDER BY studentid, studenttermid, termid, failpercentage;


----- 24 Unit Rule -----
DROP FUNCTION f_getall_24unitspassed() CASCADE;
CREATE OR REPLACE FUNCTION f_getall_24unitspassed() 
RETURNS SETOF t_elig_24unitspassed AS 
$$
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
$$
LANGUAGE plpgsql;

--SELECT DISTINCT * FROM f_getall_24unitspassed() ORDER BY studentid, yearid, unitspassed;

INSERT INTO elig24unitspassing
SELECT DISTINCT * FROM f_getall_24unitspassed() ORDER BY studentid, yearid, unitspassed;



DELETE FROM eligtwicefail;
INSERT INTO eligtwicefail
SELECT DISTINCT * FROM f_getall_eligtwicefail() ORDER BY studentid, courseid, termid;

DELETE FROM eligpasshalf;
INSERT INTO eligpasshalf
SELECT DISTINCT * FROM f_getall_eligpasshalf() ORDER BY studentid, studenttermid, termid, failpercentage;

INSERT INTO eligpasshalfmathcs
SELECT DISTINCT * FROM f_getall_eligpasshalfmathcs() ORDER BY studentid, studenttermid, termid, failpercentage;

INSERT INTO elig24unitspassing
SELECT DISTINCT * FROM f_getall_24unitspassed() ORDER BY studentid, yearid, unitspassed;
