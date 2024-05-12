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