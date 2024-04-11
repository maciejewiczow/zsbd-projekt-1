-- 1. Trigger - before add student to class - checking that class is graduate - procedure 1
use szkola;
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

-- 3. Trigger - after added a new class - update graduation year
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

-- 3. Trigger - before update student - checking that class is graduate - procedure 1

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

-- 4. Trigger - before update class - update graduation year
-- DROP TRIGGER before_class_update;
DELIMITER $
CREATE TRIGGER before_class_update BEFORE update on szkola.Class for each row
	BEGIN
		IF NEW.StartYear != OLD.StartYear THEN
			SET NEW.GraduationYear=NEW.StartYear+5;
		ELSEIF NEW.GraduationYear != OLD.GraduationYear THEN
			SET NEW.GraduationYear=OLD.StartYear+5;
		END IF;
	END $
DELIMITER ;

-- FOR TESTING
-- insert into szkola.Class (StartYear, Preceptor_UserID, ProfileID) values (1995, 791, 1);
-- select * from szkola.Class where StartYear=1996;
-- update szkola.Class SET StartYear=1996 where StartYear=1995 and Preceptor_UserID=791;


-- 5. Trigger - verifies if grade issuer is not a student before inserting

delimiter $$
create trigger check_if_grade_issuer_is_not_a_student before insert on szkola.Grade
	for each row
    begin
		declare is_student bool;
        select check_user_is_student(NEW.Issuer_UserID) into is_student;

		if is_student = true then
			signal sqlstate '45000'
				set MESSAGE_TEXT = 'Students cannot issue grades';
        end if;
	end$$
delimiter ;

-- TESTING
-- INSERT INTO Grade (GradeValueID, SubjectID, Issuer_UserID, Owner_UserID, Weight, IssuedAt) Values (13, 1, 3, 5, 1, CURRENT_TIMESTAMP());
-- should fail
--
-- INSERT INTO Grade (GradeValueID, SubjectID, Issuer_UserID, Owner_UserID, Weight, IssuedAt) Values (13, 1, 709, 8, 1, CURRENT_TIMESTAMP());
-- should pass

delimiter $$
create trigger check_if_grade_issuer_is_not_a_student_on_update before update on szkola.Grade
	for each row
    begin
		declare is_student bool;
        select check_user_is_student(NEW.Issuer_UserID) into is_student;

		if is_student = true then
			signal sqlstate '45000'
				set MESSAGE_TEXT = 'Students cannot issue grades';
        end if;
	end$$
delimiter ;

-- 6. Trigger - verifies if grade owner is a student before inserting it

delimiter $$
create trigger check_if_grade_owner_is_a_student before insert on szkola.Grade
	for each row
    begin
		declare is_student bool;
        select check_user_is_student(NEW.Owner_UserID) into is_student;
		if not is_student then
			signal sqlstate '45000'
				set MESSAGE_TEXT = 'Only students can recieve grades';
        end if;
	end$$
delimiter ;

-- TESTING
-- INSERT INTO Grade (GradeValueID, SubjectID, Issuer_UserID, Owner_UserID, Weight, IssuedAt) Values (13, 1, 709, 708, 1, CURRENT_TIMESTAMP());
-- should fail
--
-- INSERT INTO Grade (GradeValueID, SubjectID, Issuer_UserID, Owner_UserID, Weight, IssuedAt) Values (13, 1, 709, 8, 1, CURRENT_TIMESTAMP());
-- should pass

delimiter $$
create trigger check_if_grade_owner_is_a_student_on_update before update on szkola.Grade
	for each row
    begin
		declare is_student bool;
        select check_user_is_student(NEW.Owner_UserID) into is_student;
		if not is_student then
			signal sqlstate '45000'
				set MESSAGE_TEXT = 'Only students can recieve grades';
        end if;
	end$$
delimiter ;

-- 7. Trigger - verifies that the grade issuer is a teacher of the grade subject for the grade owner

delimiter $$
create trigger check_if_issuer_is_a_teacher_for_the_owner before insert on szkola.Grade
	for each row
    begin
		declare row_count int;

        select COUNT(*)
			from ClassSubjectTeacher CST
            inner join
				Student
			on Student.ClassID = CST.ClassID
            WHERE Student.UserID = NEW.Owner_UserID AND CST.Teacher_UserID = NEW.Issuer_UserID
            into row_count;

		if row_count = 0 then
			signal sqlstate '45000'
				set MESSAGE_TEXT = 'This teacher does not theach the supplied subject to this student';
        end if;
	end$$
delimiter ;

-- TESTING
--
-- INSERT INTO Grade (GradeValueID, SubjectID, Issuer_UserID, Owner_UserID, Weight, IssuedAt) Values (13, 1, 709, 4, 1, CURRENT_TIMESTAMP());
-- should fail
--
-- INSERT INTO Grade (GradeValueID, SubjectID, Issuer_UserID, Owner_UserID, Weight, IssuedAt) Values (13,  3, 732, 7, 1, CURRENT_TIMESTAMP());
-- should pass

delimiter $$
create trigger check_if_issuer_is_a_teacher_for_the_owner_on_update before update on szkola.Grade
	for each row
    begin
		declare row_count int;

        select COUNT(*)
			from ClassSubjectTeacher CST
            inner join
				Student
			on Student.ClassID = CST.ClassID
            WHERE Student.UserID = NEW.Owner_UserID AND CST.Teacher_UserID = NEW.Issuer_UserID
            into row_count;

		if row_count = 0 then
			signal sqlstate '45000'
				set MESSAGE_TEXT = 'This teacher does not theach the supplied subject to this student';
        end if;
	end$$
delimiter ;
