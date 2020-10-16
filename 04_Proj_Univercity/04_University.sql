
CREATE DATABASE University

USE University;

create table Students
(
student_id int IDENTITY (1,1) Primary key not null,
student_name varchar(255) not null,
registration_date date NOT NULL,
region varchar(20) not null unique,
counselor varchar(255) not null,
grade DECIMAL (5,2)  not null,
)
---INSERT VALUES

SET IDENTITY_INSERT Students ON
INSERT INTO Students (student_id, student_name, registration_date, region,counselor, grade)
VALUES (1, 'Joe Black', '01-09-2017','England','Matt Brown', 85.78);

SET IDENTITY_INSERT Students OFF;

--select * from [dbo].[Students]

go
create table Courses
(
course_id int IDENTITY (1,1) Primary key not null,
course_title varchar(50) not null,
credit int CHECK (Credit in (15,30)) NOT NULL,
tutor varchar(30) not null,
region varchar(20) not null,
)
SET IDENTITY_INSERT Courses ON
INSERT INTO Courses (course_id, course_title, credit, tutor, region)
VALUES (1, 'Chemistry',30,'Jason Black', 'Scotland'),
		(2, 'Art',15,'Jack Bloom', 'Wales');
SET IDENTITY_INSERT Courses OFF;

create table Staff
(
staff_id int IDENTITY (1,1) Primary key  not null,
staff_name varchar(50) not null,
counselor varchar(50) not null,
tutor varchar(50) not null,
region varchar(20) not null,
)
SET IDENTITY_INSERT Staff ON
INSERT INTO Staff (staff_id, staff_name, counselor, tutor,region)
VALUES (1,'Tim Clark', 'Tony Star','Leanny Johnson','Northern Ireland')
SET IDENTITY_INSERT Staff OFF;

--select * from[dbo].[Staff]

create table Assignments
(
assignment_id int IDENTITY (1,1) Primary key not null,
student_id int not null,
course_id int not null,
note INT Check(note <=100) NOT NULL,
CONSTRAINT FK1_student_id FOREIGN KEY (student_id) REFERENCES Students (student_id),
CONSTRAINT FK2_course_id FOREIGN KEY (course_id) REFERENCES Courses (course_id),
)
SET IDENTITY_INSERT Assignments ON
INSERT INTO Assignments (assignment_id, student_id, course_id, note)
VALUES (1,1,2,95);
      
SET IDENTITY_INSERT Assignments OFF;

--select * from [dbo].[Assignments]

create table Student_Assignments
(
student_id int not null,
assignment_id int not null,
PRIMARY KEY (student_id, assignment_id),
)

create table Student_Courses
(
student_id int not null,
course_id int not null,
PRIMARY KEY (student_id, course_id),
)


CREATE FUNCTION check_1()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT sc.student_id, sum(credit) 
FROM Courses c JOIN Student_Course sc ON c.course_id=sc.course_id
GROUP BY sc.student_id
HAVING SUM(credit) > 180) 
SELECT @ret = 1 ELSE SELECT @ret = 0;
RETURN @ret;
END;

ALTER TABLE Student_Course
ADD CONSTRAINT chk_credit CHECK(dbo.check_1() = 0);

CREATE FUNCTION check_2()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT avg(c.quota) - count(c.course_id)
FROM Course c JOIN Student_Course sc ON c.course_id=sc.course_id
GROUP BY c.course_id   
HAVING avg(c.quota) -count(c.course_id) < 0)
SELECT @ret = 1 ELSE SELECT @ret = 0;
RETURN @ret;
END;

ALTER TABLE Student_Course
ADD CONSTRAINT chk_quato CHECK(dbo.check_2() = 0);

CREATE FUNCTION check_3()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT count(a.assignment_id)
FROM Assignments a JOIN Student_Course sc ON a.course_id=sc.course_id and a.student_id = sc.student_id
JOIN Courses c ON a.course_id = c.course_id 
WHERE c.credit = 30 
GROUP BY sc.student_id, c.course_id 
HAVING count(a.assignment_id) > 5)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;

ALTER TABLE Assignments
ADD CONSTRAINT chk_assgn CHECK (dbo.check_3() = 0);

CREATE FUNCTION check_4()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT count(a.assignment_id)
FROM Assignments a JOIN Student_Course sc ON a.course_id=sc.course_id and a.student_id = sc.student_id
JOIN Course c ON a.course_id = c.course_id 
WHERE c.credit = 15 
GROUP BY sc.student_id, c.course_id 
HAVING count(a.assignment_id) > 3)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE Assignments
ADD CONSTRAINT chk_assgn_3 CHECK(dbo.check_4() = 0);


-- Update the credit for a course.
SELECT * FROM Course

UPDATE Courses
SET credit = 15 -- old value was 30
WHERE course_id = 21

--Swap the responsible staff of two students with each other in the student table.
SELECT * FROM Staff

UPDATE Staff
SET staff_id = 32-- old value was 30
WHERE student_id = 10 and staff_id = 30 

UPDATE Staff
SET staff_id = 30-- old value was 32
WHERE student_id = 11 and staff_id = 32 

--Remove a staff member who is not assigned to any student from the staff table.

SELECT * FROM Staff


DELETE FROM Staff WHERE staff_id = (SELECT TOP 1 st.counselor FROM Students s JOIN Staff ss ON s.counselor = st.counselor RIGHT JOIN Staff st ON st.counselor = s.counselor
WHERE s.student_id IS NULL ORDER BY st.staff_id desc);

--Add a student to the student table and enroll the student you added to any course.

INSERT INTO Students (student_name, region)
VALUES('Zack Acke', 'Scotland');


--SELECT * FROM Students


INSERT INTO Student_Courses (student_id, course_id)
VALUES(17, 24);
