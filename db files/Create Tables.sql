DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

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
termid		SERIAL	PRIMARY KEY,
name		varchar(45),
year		varchar(9),
sem		varchar(3)
);

CREATE TABLE grades (
gradeid		SERIAL		PRIMARY KEY,
gradename	varchar(4),
gradevalue	real
);

CREATE TABLE courses (
courseid	SERIAL		PRIMARY KEY,
coursename	varchar(45),
credits		real,
domain		varchar(6),
commtype	varchar(2)
);

CREATE TABLE classes (
classid		SERIAL	PRIMARY KEY,
termid		integer	REFERENCES terms(termid),
courseid	integer		REFERENCES courses(courseid),
section		varchar(12),
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