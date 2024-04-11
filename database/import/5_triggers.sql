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
