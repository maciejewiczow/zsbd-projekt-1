-- 1. Trigger - before add student to class - checking that class is graduate - procedure 1
DELIMITER $
CREATE TRIGGER before_student_adding BEFORE insert on szkola.Student for each row
	BEGIN
		CALL add_student_to_not_graduated_class(NEW.ClassID);
	END $
DELIMITER ;

-- FOR TESTING
-- insert into szkola.Class (StartYear, GraduationYear, Preceptor_UserID, ProfileID) values (2010, 2022, 791, 1);
-- select ClassID from szkola.Class where StartYear like '2016';
-- SELECT * FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- DELETE FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- insert into szkola.User (Name, Surname, Email, PasswordHash, Address, UserRoleID, PESEL) values ('kacper', 'bielak',
--     	'kacperbielak123@o2.pl', '$2b$04$iQu6MkQgzjJTGd6YnCKfDuW/ag.Ewrr3XQE8c5hU14Io68E5UyEQ.', 'Dzwola 21', 1, '12345678911');
-- insert into szkola.Student (UserID, ClassID) values (805, 9);

-- 2. Trigger - before insterting new lesson to the timetable - checks whether there is a free spot in the timetable of a given class
delimiter $$
create trigger check_timeslots before insert on szkola.Timetable
	for each row
    begin
		CALL verify_if_time_slot_is_available_for_class(NEW.ClassID, NEW.TimeStart, NEW.TimeEnd, NEW.DayNumber);
	end$$
delimiter ;

-- 3. Trigger - after added a new class - update graduation year - procedure 3
DROP TRIGGER before_class_added;
use szkola;
DELIMITER $
CREATE TRIGGER before_class_added before insert on szkola.Class for each row
	BEGIN
		SET NEW.GraduationYear=NEW.StartYear+5;
    END $
DELIMITER ;

-- FOR TESTING
-- insert into szkola.Class (StartYear, Preceptor_UserID, ProfileID) values (1998, 791, 1);
-- select * from szkola.Class where StartYear=1998;

-- 5. Trigger - before update student to class - checking that class is graduate - procedure 1

-- DROP TRIGGER before_student_update;
DELIMITER $
CREATE TRIGGER before_student_update BEFORE update on szkola.Student for each row
	BEGIN
		IF NEW.ClassID != OLD.ClassID THEN
			CALL add_student_to_not_graduated_class(NEW.ClassID);
		END IF;
	END $
DELIMITER ;

-- FOR TESTING
-- insert into szkola.Class (StartYear, GraduationYear, Preceptor_UserID, ProfileID) values (2007, 2020, 791, 1);
-- select ClassID from szkola.Class where StartYear=2007;
-- SELECT * FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- DELETE FROM szkola.User where Email like 'kacperbielak123@o2.pl';
-- insert into szkola.User (Name, Surname, Email, PasswordHash, Address, UserRoleID, PESEL) values ('kacper', 'bielak',
--      	'kacperbielak123@o2.pl', '$2b$04$iQu6MkQgzjJTGd6YnCKfDuW/ag.Ewrr3XQE8c5hU14Io68E5UyEQ.', 'Dzwola 21', 1, '12345678911');
-- update szkola.Student set ClassID=37 where UserID=808;