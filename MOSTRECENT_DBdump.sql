--
-- PostgreSQL database dump
--

SET client_encoding = 'WIN1252';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: csgwa(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION csgwa(p_studentid integer) RETURNS numeric
    AS $_$SELECT SUM(grades.gradevalue * courses.credits) / SUM(courses.credits)

FROM students JOIN persons USING (personid)
JOIN studentterms USING (studentid)
JOIN terms USING (termid)
JOIN studentclasses USING (studenttermid)
JOIN grades USING (gradeid)
JOIN classes USING (classid)
JOIN courses USING (courseid)
WHERE students.studentid = $1 AND courses.coursename ILIKE 'cs%'
GROUP BY students.studentid$_$
    LANGUAGE sql;


ALTER FUNCTION public.csgwa(p_studentid integer) OWNER TO postgres;

--
-- Name: cwaproto3(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cwaproto3(p_studentid integer) RETURNS numeric
    AS $_$DECLARE 
ah INTEGER;
mst INTEGER;
ssp INTEGER;
ahcredits numeric DEFAULT 0;
mstcredits numeric DEFAULT 0;
sspcredits numeric DEFAULT 0;
majcredits numeric DEFAULT 0;
elecredits numeric DEFAULT 0;
ahd numeric DEFAULT 0;
mstd numeric DEFAULT 0;
sspd numeric DEFAULT 0;
majd numeric DEFAULT 0;
eled numeric DEFAULT 0;
cwa numeric DEFAULT 0;

BEGIN
	
	SELECT SUM(x * y) into ahcredits
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'AH' 
	ORDER BY v.termid ASC
	LIMIT 5 ) as z;	

	SELECT SUM(y) into ahd
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'AH' 
	ORDER BY v.termid ASC
	LIMIT 5 ) as z;	

	-- start: checks for the 2/3 rules of natsci 1 and 2
-- 	IF (SELECT COUNT(*)
-- 		FROM viewclasses v 
-- 		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename != 'math 1' AND v.coursename IN ('nat sci 1, chem 1, physics 10')
-- 			) > 3
-- 	THEN RETURN 7;
-- 	END IF;
-- 
-- 	IF (SELECT COUNT(*)
-- 		FROM viewclasses v 
-- 		WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename != 'math 1' AND v.coursename IN ('nat sci 2, bio 1, geol 1')
-- 			) > 3
-- 	THEN RETURN 7;
-- 	END IF;
	-- end: checks for the 2/3 rules of natsci 1 and 2
	
	SELECT SUM(x * y) into mstcredits
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename != 'math 1'
	ORDER BY v.termid ASC
	LIMIT 4 ) as z;		

	SELECT SUM(y) into mstd
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'MST' AND v.coursename != 'math 1'
	ORDER BY v.termid ASC
	LIMIT 4 ) as z;	

	SELECT SUM(x * y) into sspcredits
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'SSP' 
	ORDER BY v.termid ASC
	LIMIT 5 ) as z;	

	SELECT SUM(y) into sspd
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'SSP' 
	ORDER BY v.termid ASC
	LIMIT 5 ) as z;	


	SELECT SUM(x * y) into majcredits
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'MAJ') as z;
	
	SELECT SUM(y) into majd
	FROM (
	SELECT v.gradevalue as x, v.credits as y
	FROM viewclasses v 
	WHERE v.studentid = $1 AND v.domain = 'MAJ') as z;

-- 	SELECT SUM(x * y) into elecredits
-- 	FROM (
-- 	SELECT v.gradevalue as x, v.credits as y
-- 	FROM viewclasses v 
-- 	WHERE v.studentid = $1 AND v.domain = 'ELE') as z;
-- 	
-- 	SELECT SUM(y) into eled
-- 	FROM (
-- 	SELECT v.gradevalue as x, v.credits as y
-- 	FROM viewclasses v 
-- 	WHERE v.studentid = $1 AND v.domain = 'ELE') as z;


	--start: correcting measures if a domain does not have a subject yet
	IF (SELECT COUNT(*) FROM (SELECT * from viewclasses v WHERE v.studentid = $1 AND v.domain = 'AH') as z) = 0
	THEN ahd = 0; ahcredits = 0;
	END IF;
	IF (SELECT COUNT(*) FROM (SELECT * from viewclasses v WHERE v.studentid = $1 AND v.domain = 'MST') as z) = 0
	THEN mstd = 0; mstcredits = 0;
	END IF;
	IF (SELECT COUNT(*) FROM (SELECT * from viewclasses v WHERE v.studentid = $1 AND v.domain = 'SSP') as z) = 0
	THEN sspd = 0; sspcredits = 0;
	END IF;
	IF (SELECT COUNT(*) FROM (SELECT * from viewclasses v WHERE v.studentid = $1 AND v.domain = 'MAJ') as z) = 0
	THEN majd = 0; majcredits = 0;
	END IF;
	--end: correcting measures if a domain does not have a subject yet
	
	cwa = (ahcredits + mstcredits + sspcredits + majcredits + elecredits) / (ahd + mstd + sspd + majd + eled);
	RETURN cwa;

END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION public.cwaproto3(p_studentid integer) OWNER TO postgres;

--
-- Name: gwa(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gwa(p_studentid integer, p_termid integer) RETURNS numeric
    AS $_$SELECT SUM(grades.gradevalue * courses.credits) / SUM(courses.credits) AS x

FROM students JOIN persons USING (personid)
JOIN studentterms USING (studentid)
JOIN terms USING (termid)
JOIN studentclasses USING (studenttermid)
JOIN grades USING (gradeid)
JOIN classes USING (classid)
JOIN courses USING (courseid)
WHERE students.studentid = $1 AND terms.termid = $2
GROUP BY students.studentid$_$
    LANGUAGE sql;


ALTER FUNCTION public.gwa(p_studentid integer, p_termid integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE classes (
    classid integer NOT NULL,
    termid integer,
    courseid integer,
    section character varying(5),
    classcode character varying(5)
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: classes_classid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE classes_classid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.classes_classid_seq OWNER TO postgres;

--
-- Name: classes_classid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE classes_classid_seq OWNED BY classes.classid;


--
-- Name: classes_classid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('classes_classid_seq', 36, true);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE courses (
    courseid integer NOT NULL,
    coursename character varying(45),
    credits integer,
    domain character varying(4),
    commtype character varying(2)
);


ALTER TABLE public.courses OWNER TO postgres;

--
-- Name: courses_courseid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE courses_courseid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.courses_courseid_seq OWNER TO postgres;

--
-- Name: courses_courseid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE courses_courseid_seq OWNED BY courses.courseid;


--
-- Name: courses_courseid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('courses_courseid_seq', 107, true);


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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.curricula_curriculumid_seq OWNER TO postgres;

--
-- Name: curricula_curriculumid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE curricula_curriculumid_seq OWNED BY curricula.curriculumid;


--
-- Name: curricula_curriculumid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('curricula_curriculumid_seq', 2, true);


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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.grades_gradeid_seq OWNER TO postgres;

--
-- Name: grades_gradeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE grades_gradeid_seq OWNED BY grades.gradeid;


--
-- Name: grades_gradeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('grades_gradeid_seq', 13, true);


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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.instructorclasses_instructorclassid_seq OWNER TO postgres;

--
-- Name: instructorclasses_instructorclassid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE instructorclasses_instructorclassid_seq OWNED BY instructorclasses.instructorclassid;


--
-- Name: instructorclasses_instructorclassid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('instructorclasses_instructorclassid_seq', 9, true);


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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.instructors_instructorid_seq OWNER TO postgres;

--
-- Name: instructors_instructorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE instructors_instructorid_seq OWNED BY instructors.instructorid;


--
-- Name: instructors_instructorid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('instructors_instructorid_seq', 3, true);


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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.persons_personid_seq OWNER TO postgres;

--
-- Name: persons_personid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE persons_personid_seq OWNED BY persons.personid;


--
-- Name: persons_personid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('persons_personid_seq', 15, true);


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
    NO MAXVALUE
    NO MINVALUE
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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.studentclasses_studentclassid_seq OWNER TO postgres;

--
-- Name: studentclasses_studentclassid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE studentclasses_studentclassid_seq OWNED BY studentclasses.studentclassid;


--
-- Name: studentclasses_studentclassid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentclasses_studentclassid_seq', 138, true);


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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.students_studentid_seq OWNER TO postgres;

--
-- Name: students_studentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE students_studentid_seq OWNED BY students.studentid;


--
-- Name: students_studentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('students_studentid_seq', 12, true);


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
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.studentterms_studenttermid_seq OWNER TO postgres;

--
-- Name: studentterms_studenttermid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE studentterms_studenttermid_seq OWNED BY studentterms.studenttermid;


--
-- Name: studentterms_studenttermid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('studentterms_studenttermid_seq', 46, true);


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
-- Name: viewclasses; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW viewclasses AS
    SELECT courses.coursename, grades.gradevalue, courses.credits, students.studentid, terms.termid, courses.domain, persons.lastname, persons.firstname, persons.middlename FROM (((((((students JOIN persons USING (personid)) JOIN studentterms USING (studentid)) JOIN terms USING (termid)) JOIN studentclasses USING (studenttermid)) JOIN grades USING (gradeid)) JOIN classes USING (classid)) JOIN courses USING (courseid));


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
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY classes (classid, termid, courseid, section, classcode) FROM stdin;
1	20091	1	FWXY	3456
2	20091	39	THU	236
3	20091	70	WFV	1235
4	20092	45	THV	2312
5	20092	81	THU-1	3783
6	20092	93	WFW	3467
7	20101	40	THV	5592
8	20101	59	WFX	3846
9	20101	84	THY	32145
10	20102	96	THY	4235
11	20102	3	WFW	3456
12	20102	4	WFX	45673
13	20111	6	THU	1234
14	20111	5	WFW	3456
15	20111	8	THY	3467
16	20112	48	Z	2345
17	20112	86	THY	2345
18	20112	102	WFY	3403
19	20121	9	THU	234
20	20121	41	WFW	111
21	20121	78	THX	5678
22	20122	11	WFX	3456
23	20122	12	THXY	341
24	20122	17	WFX	457
25	20121	1	WFUV	2000
26	20121	1	THR	2001
27	20121	1	THUV	2001
28	20121	2	WFUV	2000
29	20121	2	THR	2001
30	20121	2	THUV	2001
31	20121	3	WFUV	2000
32	20121	3	THR	2001
33	20121	3	THUV	2001
34	20121	3	WFUV	2000
35	20121	3	THR	2001
36	20121	3	THUV	2001
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
23	CS 197	3	MAJ	\N
24	CS 120	3	MAJ	\N
25	CS 173	3	MAJ	\N
26	CS 174	3	MAJ	\N
27	CS 175	3	MAJ	\N
28	CS 176	3	MAJ	\N
29	CS 171	3	MAJ	\N
30	CS 172	3	MAJ	\N
31	Math 17	5	MAJ	\N
32	Math 53	5	MAJ	\N
33	Math 54	5	MAJ	\N
34	Math 55	3	MAJ	\N
35	comm 1	3	AH	E
36	comm 2	3	AH	E
37	hum 1	3	AH	\N
38	hum 2	3	AH	\N
39	aral pil 12	3	AH	P
40	art stud 1	3	AH	\N
41	art stud 2	3	AH	\N
42	bc 10	3	AH	\N
43	comm 3	3	AH	E
44	cw 10	3	AH	E
45	eng 1	3	AH	E
46	eng 10	3	AH	E
47	eng 11	3	AH	E
48	l arch 1	3	AH	\N
49	eng 30	3	AH	E
50	el 50	3	AH	\N
51	fa 28	3	AH	P
52	fa 30	3	AH	\N
53	fil 25	3	AH	\N
54	fil 40	3	AH	P
55	film 10	3	AH	\N
56	film 12	3	AH	P
57	humad 1	3	AH	P
58	j 18	3	AH	\N
59	kom 1	3	AH	E
60	kom 2	3	AH	E
61	mps 10	3	AH	P
62	mud 1	3	AH	\N
63	mul 9	3	AH	P
64	mul 13	3	AH	\N
65	pan pil 12	3	AH	P
66	pan pil 17	3	AH	P
67	pan pil 19	3	AH	P
68	pan pil 40	3	AH	P
69	pan pil 50	3	AH	P
70	sea 30	3	AH	\N
71	theatre 10	3	AH	\N
72	theatre 11	3	AH	P
73	theatre 12	3	AH	\N
74	bio 1	3	MST	\N
75	chem 1	3	MST	\N
76	eee 10	3	MST	\N
77	env sci 1	3	MST	\N
78	es 10	3	MST	\N
79	ge 1	3	MST	\N
80	geol 1	3	MST	\N
81	l arch 1	3	MST	\N
82	math 2	3	MST	\N
83	mbb 1	3	MST	\N
84	ms 1	3	MST	\N
85	nat sci 1	3	MST	\N
86	nat sci 2	3	MST	\N
87	physiCS 10	3	MST	\N
88	sts	3	MST	\N
89	fn 1	3	MST	\N
90	anthro 10	3	SSP	\N
91	archaeo 2	3	SSP	\N
92	arkiyoloji 1	3	SSP	P
93	econ 11	3	SSP	\N
94	econ 31	3	SSP	\N
95	geog 1	3	SSP	\N
96	kas 1	3	SSP	P
97	kas 2	3	SSP	\N
98	l arch 1	3	SSP	\N
99	lingg 1	3	SSP	\N
100	philo 1	3	SSP	\N
101	philo 10	3	SSP	\N
102	philo 11	3	SSP	\N
103	sea 30	3	SSP	P
104	soc sci 1	3	SSP	\N
105	soc sci 2	3	SSP	\N
106	soc sci 3	3	SSP	\N
107	socio 10	3	SSP	P
\.


--
-- Data for Name: curricula; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY curricula (curriculumid, curriculumname) FROM stdin;
1	Old
2	New
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
12	INC	\N
13	DRP	\N
\.


--
-- Data for Name: instructorclasses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY instructorclasses (instructorclassid, classid, instructorid) FROM stdin;
1	25	1
2	26	1
3	27	1
4	28	2
5	29	2
6	30	2
7	31	3
8	32	3
9	33	3
\.


--
-- Data for Name: instructors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY instructors (instructorid, personid) FROM stdin;
1	13
2	14
3	15
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
10	Balandra	Gomburza Carlos	Matalino	
11	Reyes	Ernesto Miguel	Contreras	Jr.
12	Torrente	Raymundo Jun-jun	Santos	III
13	Meren	Gil Troy	Mercado	
14	Cortez	Marie Janelle	Sy	
15	Tenor	Karol Kyle	Perez	
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
1	1	19	1
2	1	20	5
3	1	21	1
4	2	19	2
5	2	20	5
6	2	21	1
7	3	19	2
8	3	20	8
9	3	21	1
10	4	19	3
11	4	20	9
12	4	21	1
13	5	19	1
14	5	20	2
15	5	21	3
16	6	19	4
17	6	20	5
18	6	21	3
19	7	19	1
20	7	20	2
21	7	21	1
22	8	19	6
23	8	20	5
24	8	21	1
25	9	19	1
26	9	20	1
27	9	21	1
28	10	19	1
29	10	20	1
30	10	21	1
31	11	19	8
32	11	20	8
33	11	21	8
34	12	19	2
35	12	20	3
36	12	21	1
37	13	16	1
38	13	17	2
39	13	18	3
40	14	16	5
41	14	17	6
42	14	18	7
43	15	16	1
44	15	17	1
45	15	18	1
46	16	16	2
47	16	17	3
48	16	18	3
49	17	16	4
50	17	17	1
51	17	18	3
52	18	16	1
53	18	17	7
54	18	18	6
55	19	16	1
56	19	17	2
57	19	18	3
58	20	16	4
59	20	17	3
60	20	18	2
61	21	13	1
62	21	14	1
63	21	15	1
64	22	13	1
65	22	14	2
66	22	15	1
67	23	13	3
68	23	14	6
69	23	15	4
70	24	13	1
71	24	14	1
72	24	15	1
73	25	13	1
74	25	14	2
75	25	15	3
76	26	13	3
77	26	14	5
78	26	15	3
79	27	13	2
80	27	14	2
81	27	15	3
82	28	13	4
83	28	14	6
84	28	15	6
85	29	10	1
86	29	11	2
87	29	12	2
88	30	10	1
89	30	11	3
90	30	12	4
91	31	10	1
92	31	11	6
93	31	12	6
94	32	10	3
95	32	11	3
96	32	12	3
97	33	10	3
98	33	11	4
99	33	12	3
100	34	10	7
101	34	11	6
102	34	12	8
103	35	7	3
104	35	8	4
105	35	9	2
106	36	7	4
107	36	8	3
108	36	9	4
109	37	7	3
110	37	8	7
111	37	9	5
112	38	7	1
113	38	8	5
114	38	9	3
115	39	7	3
116	39	8	6
117	39	9	7
118	40	7	2
119	40	8	1
120	40	9	1
121	41	4	1
122	41	5	3
123	41	6	5
124	42	4	7
125	42	5	6
126	42	6	7
127	43	4	2
128	43	5	1
129	43	6	3
130	44	1	1
131	44	2	2
132	44	3	3
133	45	1	1
134	45	2	2
135	45	3	1
136	46	1	1
137	46	2	4
138	46	3	5
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY students (studentid, personid, studentno, curriculumid) FROM stdin;
1	1	201228374	1
2	2	201247583	1
3	3	201237561	1
4	4	201175639	2
5	5	201109570	2
6	6	201183647	2
7	7	201017263	2
8	8	201012341	2
9	9	201034567	2
10	10	200912651	2
11	11	200912341	2
12	12	200909876	2
\.


--
-- Data for Name: studentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY studentterms (studenttermid, studentid, termid, ineligibilities, issettled) FROM stdin;
1	1	20121	N/A	t
2	2	20121	N/A	t
3	3	20121	N/A	t
4	4	20121	N/A	t
5	5	20121	NO F137	t
6	6	20121	NO F137	t
7	7	20121	N/A	t
8	8	20121	NO F137	t
9	9	20121	NO F137	t
10	10	20121	N/A	t
11	11	20121	N/A	t
12	12	20121	N/A	t
13	5	20112	N/A	t
14	6	20112	N/A	t
15	7	20112	N/A	t
16	8	20112	N/A	t
17	9	20112	N/A	t
18	10	20112	LIBRARY ACCOUNTABILITY	t
19	11	20112	N/A	t
20	12	20112	N/A	t
21	5	20111	N/A	t
22	6	20111	N/A	t
23	7	20111	LIBRARY ACCOUNTABILITY	t
24	8	20111	N/A	t
25	9	20111	N/A	t
26	10	20111	N/A	t
27	11	20111	N/A	t
28	12	20111	N/A	t
29	7	20102	N/A	t
30	8	20102	N/A	t
31	9	20102	N/A	t
32	10	20102	N/A	t
33	11	20102	LIBRARY ACCOUNTABILITY	t
34	12	20102	N/A	t
35	7	20101	N/A	t
36	8	20101	N/A	t
37	9	20101	N/A	t
38	10	20101	N/A	t
39	11	20101	N/A	t
40	12	20101	N/A	t
41	10	20092	N/A	t
42	11	20092	N/A	t
43	12	20092	N/A	t
44	10	20091	ZERO PASSING	t
45	11	20091	ZERO PASSING	t
46	12	20091	ZERO PASSING	t
\.


--
-- Data for Name: terms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY terms (termid, name, year, sem) FROM stdin;
20091	1st Semester 2009-2010	2009-2010	1st
20092	2nd Semester 2009-2010	2009-2010	2nd
20101	1st Semester 2010-2011	2010-2011	1st
20102	2nd Semester 2010-2011	2010-2011	2nd
20111	1st Semester 2011-2012	2011-2012	1st
20112	2nd Semester 2011-2012	2011-2012	2nd
20121	1st Semester 2012-2013	2012-2013	1st
20122	2nd Semester 2012-2013	2012-2013	2nd
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

