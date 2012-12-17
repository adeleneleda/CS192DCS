CREATE TABLE requirements (
requirementid		SERIAL		PRIMARY KEY,
requirementname	varchar(50),
functionname		varchar(50)
);

CREATE TABLE persons (
personid		SERIAL		PRIMARY KEY,
lastname		varchar(45),
firstname		varchar(45),
middlename		varchar(45),
pedigree		varchar(45)
);

CREATE TABLE instructors (
instructorid		SERIAL	PRIMARY KEY,
personid		integer		REFERENCES persons(personid)
);

CREATE TABLE curricula (
curriculumid		SERIAL	PRIMARY KEY,
curriculumname	varchar(45)	
);

CREATE TABLE students (
studentid		SERIAL	PRIMARY KEY,
personid		integer		REFERENCES persons(personid),
studentno		varchar(9),
curriculumid		integer		REFERENCES curricula(curriculumid)
);

CREATE TABLE terms (
termid		integer		PRIMARY KEY,
name		varchar(45),
year		varchar(9),
sem		varchar(3)
);

CREATE TABLE grades (
gradeid		SERIAL		PRIMARY KEY,
gradename	varchar(4),
gradevalue	numeric(3,2)
);

CREATE TABLE courses (
courseid	SERIAL		PRIMARY KEY,
coursename	varchar(45),
credits		integer,
domain		varchar(4),
commtype	varchar(2)
);

CREATE TABLE classes (
classid		SERIAL	PRIMARY KEY,
termid		integer	REFERENCES terms(termid),
courseid	integer		REFERENCES courses(courseid),
section		varchar(5),
classcode	varchar(5)
);

CREATE TABLE instructorclasses (
instructorclassid	SERIAL	PRIMARY KEY,
classid			integer		REFERENCES classes(classid),
instructorid		integer		REFERENCES instructors(instructorid)
);

CREATE TABLE studentterms (
studenttermid	SERIAL	PRIMARY KEY,
studentid	integer		REFERENCES students(studentid),
termid		integer	REFERENCES terms(termid),
ineligibilities varchar,
issettled boolean
);

CREATE TABLE studentclasses (
studentclassid		SERIAL	PRIMARY KEY,
studenttermid		integer		REFERENCES studentterms(studenttermid),
classid			integer		REFERENCES classes(classid),
gradeid			integer		REFERENCES grades(gradeid)
);