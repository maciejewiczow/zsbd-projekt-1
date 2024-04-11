# 1. add student if class not graduated
#DROP procedure add_student_to_not_graduated_class;

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

# For testing ....
#insert into szkola.Class (StartYear, GraduationYear, Preceptor_UserID, ProfileID) values (2010, 2022, 791, 1);
#select ClassID from szkola.Class where StartYear like '2010';
#SELECT * FROM szkola.User where Email like 'kacperbielak123@o2.pl';
#DELETE FROM szkola.User where Email like 'kacperbielak123@o2.pl';
#CALL add_student_to_not_graduated_class('Kacper', 'Bielak', 'kacperbielak123@o2.pl', '$2b$04$iQu6MkQgzjJTGd6YnCKfDuW/ag.Ewrr3XQE8c5hU14Io68E5UyEQ.', 'Dzwola 215', '12345678911', 27);
