ALTER TABLE szkola.Class MODIFY GraduationYear int;

--  1. add student if class not graduated
-- DROP procedure add_student_to_not_graduated_class;

use szkola;
DELIMITER $
create procedure add_student_to_not_graduated_class(IN class_id int)
	begin
		DECLARE current_year int;
		DECLARE start_year int;
		DECLARE graduated_year int;

		select StartYear into start_year from szkola.Class where ClassID=class_id;
		select GraduationYear into graduated_year from szkola.Class where ClassID=class_id;
		SET current_year = YEAR(CURDATE());

		IF current_year > graduated_year THEN
   			SIGNAL SQLSTATE '45000'
    		SET MESSAGE_TEXT = 'The class has been graduated!';
		END IF;
	END $
DELIMITER ;

--  For testing ....
-- insert into szkola.Class (StartYear, GraduationYear, Preceptor_UserID, ProfileID) values (2010, 2022, 791, 1);
-- select ClassID from szkola.Class where StartYear like '2010';
-- SELECT * FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- DELETE FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- CALL add_student_to_not_graduated_class('Kacper', 'Bielak', 'kacperbielak123@o2.pl', '$2b$04$iQu6MkQgzjJTGd6YnCKfDuW/ag.Ewrr3XQE8c5hU14Io68E5UyEQ.', 'Dzwola 215', '12345678911', 27);

-- Procedure 2 - check if specified time slot is available in a user's timetable
USE `szkola`;
DROP procedure IF EXISTS `verify_if_time_slot_is_available_for_user`;

USE `szkola`;
DROP procedure IF EXISTS `szkola`.`verify_if_time_slot_is_available_for_user`;

DELIMITER $$
USE `szkola`$$
CREATE PROCEDURE `verify_if_time_slot_is_available_for_class`(IN class_id INT, IN start_time time, IN end_time time, IN day_nr smallint unsigned)
BEGIN
	declare overlapping_rows_count int;
	SELECT
		COUNT(*)
	FROM
		Timetable
	WHERE
		ClassID = class_id AND
		DayNumber = day_nr AND
        TimeStart <= end_time AND
        TimeEnd >= start_time
	INTO overlapping_rows_count;

	if overlapping_rows_count > 0 then
		SIGNAL SQLSTATE '40000'
		SET MESSAGE_TEXT = 'This lesson overlaps other things in the user timetable';
	end if;
END$$

DELIMITER ;

--  1. Function - check that user is student
use szkola;
DELIMITER $
create function check_user_is_student(user_id int) RETURNS bool deterministic
	begin
		DECLARE students_number int;

		SELECT COUNT(UserID) into students_number FROM szkola.User where ClassID is not null and UserID=user_id;
		IF students_number > 0 THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;
END $
DELIMITER ;

-- FOR TESTING
-- set @var_function1 = check_user_is_student(2);
-- select @var_function1;

--  2. Function - check that user is teacher and not already supervising teacher
use szkola;
DELIMITER $
create function check_user_is_teacher_and_not_supervising(user_id int) RETURNS bool deterministic
	begin
		DECLARE teacher_number int;
		DECLARE supervising_number int;

		SELECT COUNT(UserID) into teacher_number FROM szkola.User where UserRoleID=2 and UserID=user_id;
		SELECT COUNT(ClassID) into supervising_number FROM szkola.Class where Preceptor_UserID=user_id;
		IF teacher_number > 0 AND supervising_number=0  THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;
END $
DELIMITER ;

--  3. Function - check users count in the class by class_id
-- DROP function IF EXISTS `class_user_count`;

DELIMITER $$
USE `szkola`$$
CREATE FUNCTION `class_user_count` (class_id int)
RETURNS INTEGER
DETERMINISTIC
BEGIN
	declare result int;

    select COUNT(ClassID) from User where ClassID is not null GROUP BY ClassID HAVING ClassID = class_id into result;

	RETURN result;
END$$

DELIMITER ;

--  3. Procedure - calculate overall class GPA

DROP procedure IF EXISTS `calculate_class_gpa`;

DELIMITER $$
USE `szkola`$$
CREATE PROCEDURE `calculate_class_gpa` (IN classId int)
BEGIN
	SELECT SUM(GV.NumericValue*G.Weight)/SUM(G.Weight) as GPA FROM Grade G inner join User U on G.Owner_UserID = U.UserID inner join GradeValue GV on GV.GradeValueID = G.GradeValueID WHERE U.ClassID = classId group by ClassID;
END$$

DELIMITER ;

--  4. Procedure - selects lesson plan for class with teachers and replacement teachers

USE `szkola`;
DROP procedure IF EXISTS `lesson_plan_for_class`;

USE `szkola`;
DROP procedure IF EXISTS `szkola`.`lesson_plan_for_class`;

DELIMITER $$
USE `szkola`$$
CREATE DEFINER=`root`@`%` PROCEDURE `lesson_plan_for_class`(IN classIdParam int)
BEGIN
	SELECT TInner.*, U.Name as ReplacementTeacherName, U.Surname as ReplacementTeacherSurname from ( SELECT
		T.TimetableID,
		T.TimeStart,
		T.TimeEnd,
		T.DayNumber,
		S.Name as SubjectName,
        CST.Teacher_UserID,
		U.Name as TeacherName,
		U.Surname as TeacherSurname,
        T.ReplacementTeacher_UserID
	from (
		select * from Timetable WHERE ClassID = classIdParam
	) as T
	inner join ClassSubjectTeacher CST on CST.SubjectID = T.SubjectID and CST.ClassID = classIdParam
	inner join Subject S on S.SubjectID = T.SubjectID
	inner join User U on U.UserID = CST.Teacher_UserID
    ) as TInner left join User U on U.UserID = TInner.ReplacementTeacher_UserID ORDER BY TInner.DayNumber ASC, TInner.TimeStart ASC;
END$$

DELIMITER ;

--  5. Procedure - calculates student overall GPA from all subjects that he is learning

DELIMITER $$
USE `szkola`$$
CREATE PROCEDURE `student_overall_gpa` (IN studentId int)
BEGIN
	select (SUM(G.Weight*GV.NumericValue)/SUM(G.Weight)) as Average from Grade G inner join GradeValue GV on GV.GradeValueID = G.GradeValueID WHERE G.Owner_UserID = studentId;
END$$

DELIMITER ;

--  6. Procedure - calculates GPA for each subject that the student is learning

USE `szkola`;
DROP procedure IF EXISTS `student_subjects_gpas`;

DELIMITER $$
USE `szkola`$$
CREATE PROCEDURE `student_subjects_gpas` (in userIdParam int)
BEGIN
	select (SUM(G.Weight*GV.NumericValue)/SUM(G.Weight)) as GPA, S.Name, S.SubjectID from Grade G inner join GradeValue GV on GV.GradeValueID = G.GradeValueID inner join Subject S on S.SubjectID = G.SubjectID WHERE G.Owner_UserID = userIdParam GROUP BY S.SubjectID;
END$$

DELIMITER ;


