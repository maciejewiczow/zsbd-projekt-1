-- 1. View - List of all grades for a given student
use szkola;
DELIMITER $
create procedure all_students_grades(IN user_id int)
	begin
		SELECT
            Grade.GradeID,
            S.Name,
            S.ShortName,
            U.UserID,
            U.Name,
            U.Surname,
            U.Email,
            GV.NumericValue,
            GV.SymbolicValue,
            GV.Name,
            GV.ShortName,
            Grade.Weight,
            Grade.IssuedAt
        FROM Grade
        INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
        INNER JOIN Subject S on Grade.SubjectID = S.SubjectID
        INNER JOIN User U on Grade.Issuer_UserID = U.UserID
        WHERE Grade.Owner_UserID = user_id;
END $
DELIMITER ;

USE `szkola`;
-- Selects all teachers from the users table. Is used as a base for other views
CREATE OR REPLACE VIEW `teachers` AS select * from User where UserRoleID = 2;

USE `szkola`;
-- Selects all students of currently active classes from the users table. Is used as a base for other views
CREATE VIEW `students` AS
    SELECT
        `U`.`UserID` AS `UserID`,
        `U`.`Name` AS `Name`,
        `U`.`Surname` AS `Surname`,
        `U`.`Email` AS `Email`,
        `U`.`Address` AS `Address`,
        `U`.`PESEL` AS `PESEL`,
        `C`.`ClassID` AS `ClassID`,
        (YEAR(CURDATE()) - `C`.`StartYear`) AS `ClassYear`,
        `P`.`ShortName` AS `ClassShortName`
    FROM
        ((`User` `U`
        JOIN `Class` `C` ON ((`C`.`ClassID` = `U`.`ClassID`)))
        JOIN `Profile` `P` ON ((`P`.`ProfileID` = `C`.`ProfileID`)))
    WHERE
        ((`U`.`UserRoleID` = 1)
            AND ((YEAR(CURDATE()) - `C`.`StartYear`) <= 9))
    ORDER BY `U`.`Surname` , `U`.`Name`;


-- 2. View - List of class grades in a given subject (journal)
use szkola;
DELIMITER $
create procedure all_grades_for_class_and_subject(IN class_id int, IN subject_id int)
	begin
        SELECT
            GradeID,
            User.UserID,
            GV.NumericValue,
            GV.SymbolicValue,
            GV.Name,
            GV.ShortName
        FROM
            Grade
            INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
            INNER JOIN User ON User.UserID = Grade.Owner_UserID
        WHERE
            User.ClassID = class_id AND Grade.SubjectID = subject_id;
    END $
DELIMITER ;

-- FOR TESTING
-- call all_grades_for_class_and_subject(1,1);

-- 3. View - Lesson plan for a given user - either a teacher or a student. Also selects replacement teacher data if there is any
use szkola;
DELIMITER $
CREATE PROCEDURE `lesson_plan_for_user`(IN param_user_id int)
begin
        	Select TInner.*, U.Name as ReplacementTeacherName, U.Surname as ReplacementTeacherSurname from (
        SELECT
            T1.TimetableID,
            T1.TimeStart,
            T1.TimeEnd,
            T1.DayNumber,
            Class.ClassID,
            Subject.Name as SubjectName,
            YEAR(CURRENT_DATE()) - Class.StartYear AS ClassYear,
            P.ShortName as ClassShortName,
            User.Name as TeacherName,
            User.Surname as TeacherSurname,
            T1.Teacher_UserID,
            T1.ReplacementTeacher_UserID
        FROM
        (
                SELECT
                    Timetable.*,
                    CST.Teacher_UserID
                FROM
                    Timetable
                INNER JOIN User U on Timetable.ClassID = U.ClassID
                INNER JOIN ClassSubjectTeacher CST on Timetable.SubjectID = CST.SubjectID and Timetable.ClassID = CST.ClassID
                WHERE U.UserID = param_user_id
            UNION
                SELECT
                    Timetable.*,
                    CST.Teacher_UserID
                FROM
                    Timetable
                INNER JOIN ClassSubjectTeacher CST on Timetable.SubjectID = CST.SubjectID and Timetable.ClassID = CST.ClassID
                WHERE
                    (CST.Teacher_UserID = param_user_id AND ReplacementTeacher_UserID IS NULL)
                OR
                    ReplacementTeacher_UserID = param_user_id
        ) as T1
            INNER JOIN Subject ON T1.SubjectID = Subject.SubjectID
            INNER JOIN Class ON T1.ClassID = Class.ClassID
            INNER JOIN Profile P on Class.ProfileID = P.ProfileID
            INNER JOIN User ON User.UserID = T1.Teacher_UserID
            ) as TInner left join User U on TInner.ReplacementTeacher_UserID = U.UserID
            ORDER BY
            TInner.DayNumber ASC,
            TInner.TimeStart ASC;
    END$
DELIMITER ;

-- FOR TESTING
-- call lesson_plan_for_user(1);

-- 6. View - selects all students that are at risk of failing some subjects, with the subject names in question
create view risk_students_with_subject as
    SELECT
        Owner_UserID,
        SUM(GV.NumericValue * Grade.Weight)/SUM(Grade.Weight) Average,
        S.Name,
        S.ShortName
    FROM
        Grade
        Inner join GradeValue GV on Grade.GradeValueID = GV.GradeValueID
        INNER JOIN Subject S on Grade.SubjectID = S.SubjectID
    GROUP BY Owner_UserID, S.SubjectID
    HAVING Average < 2;

-- FOR TESTING
-- select * from risk_students_with_subject;

-- 7. View - selects a;; students eligible for a scholarship
create view students_eligible_scholarship as
    SELECT
        U.UserID, U.Email, U.Name, U.Surname, U.Address, U.PESEL,
        SUM(GV.NumericValue * Grade.Weight)/SUM(Grade.Weight) Average
    FROM
        Grade
        INNER JOIN students U on Grade.Owner_UserID = U.UserID
        INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
    GROUP BY Grade.Owner_UserID
    HAVING Average >= 4.75;

-- FOR TESTING
-- select * from students_eligible_scholarship;

-- 8. View - Selects all subjects taught by a given teacher
use szkola;
DELIMITER $
create procedure subjects_for_teacher(IN user_id int)
	begin
        SELECT
            Class.ClassID,
            Class.StartYear,
            YEAR(current_timestamp) - Class.StartYear Year,
            Profile.ShortName,
            Profile.FullName,
            GROUP_CONCAT(Subject.Name) Subjects
        FROM
            ClassSubjectTeacher
            INNER JOIN Class ON ClassSubjectTeacher.ClassID = Class.ClassID
            INNER JOIN Profile on Class.ProfileID = Profile.ProfileID
            INNER JOIN Subject on ClassSubjectTeacher.SubjectID = Subject.SubjectID
        WHERE ClassSubjectTeacher.Teacher_UserID = user_id
        GROUP BY Class.ClassID;
END $
DELIMITER ;

-- FOR TESTING
-- call subjects_for_teacher(701);

-- 9. View - selects all classes with their preceptor and class year

CREATE VIEW `all_classes` AS
    SELECT
        `C`.`ClassID` AS `ClassID`,
        (YEAR(CURDATE()) - `C`.`StartYear`) AS `ClassYear`,
        `P`.`ShortName` AS `ShortName`,
        `U`.`UserID` AS `PerceptorID`,
        `U`.`Name` AS `PerceptorName`,
        `U`.`Surname` AS `PerceptorSurname`
    FROM
        ((`Class` `C`
        JOIN `Profile` `P` ON ((`P`.`ProfileID` = `C`.`ProfileID`)))
        JOIN `User` `U` ON ((`U`.`UserID` = `C`.`Preceptor_UserID`)))
    WHERE
        ((YEAR(CURDATE()) - `C`.`StartYear`) <= 9)
    ORDER BY (YEAR(CURDATE()) - `C`.`StartYear`) , `P`.`ShortName`;


-- 5. View - selects top 10 classes in the school in terms of GPA
CREATE
    ALGORITHM = UNDEFINED
    DEFINER = `root`@`localhost`
    SQL SECURITY DEFINER
VIEW `top_10_classes` AS
    SELECT
        `User`.`ClassID` AS `ClassID`,
        (SUM(`GV`.`NumericValue`*Grade.Weight) / SUM(`Grade`.`Weight`)) AS `Average`,
        `C`.`ClassYear` AS `Year`,
        `C`.`ShortName` AS `Profile_ShortName`,
        `U`.`Name` AS `Preceptor_Name`,
        `U`.`Surname` AS `Preceptor_Surname`,
        `U`.`Email` AS `Preceptor_Email`,
        `C`.`PerceptorID` AS `Preceptor_UserID`
    FROM
        ((((`Grade`
        JOIN `User` ON ((`Grade`.`Owner_UserID` = `User`.`UserID`)))
        JOIN `GradeValue` `GV` ON ((`Grade`.`GradeValueID` = `GV`.`GradeValueID`)))
        JOIN `all_classes` `C` ON ((`User`.`ClassID` = `C`.`ClassID`)))
        JOIN `User` `U` ON ((`C`.`PerceptorID` = `U`.`UserID`)))
    GROUP BY `User`.`ClassID`
    ORDER BY `Average` DESC
    LIMIT 10;

-- FOR TESTING
-- select * from top_10_classes

-- 4. View - top 10 students - selects top 10 students in terms of overall student GPA
CREATE VIEW `top_10_students` AS
    SELECT
        `Grade`.`Owner_UserID` AS `Owner_UserID`,
        (SUM((`GV`.`NumericValue` * `Grade`.`Weight`)) / SUM(`Grade`.`Weight`)) AS `AverageGrade`,
        COUNT(`Grade`.`GradeID`) AS `GradeCount`,
        `U`.`Email` AS `Email`,
        `U`.`Name` AS `Name`,
        `U`.`Surname` AS `Surname`,
        `U`.`Address` AS `Address`,
        `U`.`PESEL` AS `PESEL`,
        (YEAR(CURDATE()) - `C`.`StartYear`) AS `Year`,
        `C`.`ClassID` as `ClassID`,
        `P`.`ShortName` AS `ShortName`,
        `P`.`FullName` AS `FullName`
    FROM
        ((((`Grade`
        JOIN `GradeValue` `GV` ON ((`Grade`.`GradeValueID` = `GV`.`GradeValueID`)))
        JOIN `students` `U` ON ((`Grade`.`Owner_UserID` = `U`.`UserID`)))
        JOIN `Class` `C` ON ((`U`.`ClassID` = `C`.`ClassID`)))
        JOIN `Profile` `P` ON ((`C`.`ProfileID` = `P`.`ProfileID`)))
    GROUP BY `Grade`.`Owner_UserID`
    ORDER BY `AverageGrade` DESC , `GradeCount` DESC
    LIMIT 10;

-- FOR TESTING
-- select * from top_10_students;

-- 10. View - selects all grades with their value and issuer data

CREATE VIEW `gade_values_with_issuer` AS
    SELECT
        `G`.`GradeID` AS `GradeID`,
        `G`.`SubjectID` AS `SubjectID`,
        `G`.`Issuer_UserID` AS `Issuer_UserID`,
        `G`.`Owner_UserID` AS `OwnerUserID`,
        `G`.`Weight` AS `Weight`,
        `G`.`IssuedAt` AS `IssuedAt`,
        `GV`.`GradeValueID` AS `GradeValueID`,
        `GV`.`NumericValue` AS `NumericValue`,
        `GV`.`SymbolicValue` AS `SymbolicValue`,
        `GV`.`Name` AS `Name`,
        `GV`.`ShortName` AS `ShortName`,
        `U`.`Name` AS `IssuerName`,
        `U`.`Surname` AS `IssuerSurname`
    FROM
        `Grade` `G`
        JOIN `GradeValue` `GV` ON `GV`.`GradeValueID` = `G`.`GradeValueID`
        JOIN `User` `U` ON `U`.`UserID` = `G`.`Issuer_UserID`;

-- example usage: select * from gade_values_with_issuer where OwnerUserID = 2
