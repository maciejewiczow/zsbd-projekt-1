--  1. add student if class not graduated
-- DROP procedure add_student_to_not_graduated_class;

use szkola;
DELIMITER $
create procedure add_student_to_not_graduated_class(IN user_name varchar(120), IN user_surname varchar(120),
						    IN user_email varchar(100), IN user_passwordhash binary(60), IN user_address varchar(200), IN user_pesel char(11), IN class_id int)
	begin
		DECLARE graduated BOOL;
		DECLARE current_year int;
		DECLARE start_year int;
		DECLARE graduated_year int;
		DECLARE user_id int;

		select StartYear into start_year from szkola.Class where ClassID=class_id;
		select GraduationYear into graduated_year from szkola.Class where ClassID=class_id;
		SET current_year = YEAR(CURDATE());

		IF current_year > graduated_year THEN
    			SIGNAL SQLSTATE '45000'
    			SET MESSAGE_TEXT = 'The class has been graduated!';
		ELSE
    			insert into szkola.User (Name, Surname, Email, PasswordHash, Address, UserRoleID, PESEL) values (user_name, user_surname,
    						user_email, user_passwordhash, user_address, 1, user_pesel);
    			SELECT UserID into user_id FROM szkola.User WHERE PESEL LIKE user_pesel;
    			insert into szkola.Student (UserID, ClassID) values (user_id, class_id);
		END IF;
	END $
DELIMITER ;

--  For testing ....
-- insert into szkola.Class (StartYear, GraduationYear, Preceptor_UserID, ProfileID) values (2010, 2022, 791, 1);
-- select ClassID from szkola.Class where StartYear like '2010';
-- SELECT * FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- DELETE FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- CALL add_student_to_not_graduated_class('Kacper', 'Bielak', 'kacperbielak123@o2.pl', '$2b$04$iQu6MkQgzjJTGd6YnCKfDuW/ag.Ewrr3XQE8c5hU14Io68E5UyEQ.', 'Dzwola 215', '12345678911', 27);

USE `szkola`;
DROP procedure IF EXISTS `verify_if_time_slot_is_available_for_user`;

USE `szkola`;
DROP procedure IF EXISTS `szkola`.`verify_if_time_slot_is_available_for_user`;

DELIMITER $$
USE `szkola`$$
CREATE PROCEDURE `verify_if_time_slot_is_available_for_user`(IN user_id INT, IN start_time time, IN end_time time, IN day_nr smallint unsigned)
BEGIN
	declare overlapping_rows_count int;
	SELECT
		COUNT(*)
	FROM
	(
			SELECT
				Timetable.*,
				CST.Teacher_UserID
			FROM
				Timetable
			INNER JOIN Student S on Timetable.ClassID = S.ClassID
			INNER JOIN ClassSubjectTeacher CST on Timetable.SubjectID = CST.SubjectID and Timetable.ClassID = CST.ClassID
			WHERE S.UserID = user_id
		UNION
			SELECT
				Timetable.*,
				CST.Teacher_UserID
			FROM
				Timetable
			INNER JOIN ClassSubjectTeacher CST on Timetable.SubjectID = CST.SubjectID and Timetable.ClassID = CST.ClassID
			WHERE
				(CST.Teacher_UserID = user_id AND ReplacementTeacher_UserID IS NULL)
			OR
				ReplacementTeacher_UserID = user_id
	) as T1
		INNER JOIN Subject ON T1.SubjectID = Subject.SubjectID
		INNER JOIN Class ON T1.ClassID = Class.ClassID
		INNER JOIN Profile P on Class.ProfileID = P.ProfileID
		INNER JOIN User ON User.UserID = T1.Teacher_UserID
	WHERE
		T1.DayNumber = day_nr AND
        T1.TimeStart <= end_time AND
        T1.TimeEnd >= start_time
	INTO overlapping_rows_count;

	if overlapping_rows_count > 0 then
		SIGNAL SQLSTATE '40000'
		SET MESSAGE_TEXT = 'This lesson overlaps other things in the user timetable';
	end if;
END$$

DELIMITER ;

--  3. Procedure - update graduation year after class added
DROP IF EXISTS procedure update_graduation_year_after_insert;
use szkola;
DELIMITER $
create procedure update_graduation_year_after_insert(IN class_id int)
	begin
		DECLARE start_year int;
		DECLARE graduation_year int;

		SELECT StartYear into start_year FROM szkola.Class where ClassID=class_id;
		SET graduation_year = start_year+5;

		UPDATE szkola.Class SET GraduationYear=graduation_year WHERE ClassID=class_id;
	END $
DELIMITER ;

-- FOR TESTING
-- ALTER TABLE szkola.Class MODIFY GraduationYear int;
-- insert into szkola.Class (StartYear, Preceptor_UserID, ProfileID) values (2004, 791, 1);
-- select ClassID from szkola.Class where StartYear=2004;
-- select * from szkola.Class where StartYear=2004;
-- CALL update_graduation_year_after_insert(28);
