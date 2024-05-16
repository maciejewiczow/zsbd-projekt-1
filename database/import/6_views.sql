-- 1. View - List of all student grades
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

-- FOR TESTING
-- call all_students_grades(1);

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

-- 3. View - Lesson plan for a given user
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
    END
DELIMITER ;

-- FOR TESTING
-- call lesson_plan_for_user(1);

-- 4. View - top 10 students
create view top_10_students as
    SELECT
        Grade.Owner_UserID,
        SUM(GV.NumericValue)/SUM(Grade.Weight) AverageGrade,
        COUNT(Grade.GradeID) GradeCount,
        U.Email, U.Name, U.Surname, U.Address, U.PESEL,
        YEAR(CURRENT_DATE()) - C.StartYear Year,
        P.ShortName,
        P.FullName
    FROM
        Grade
        INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
        INNER JOIN User U on Grade.Owner_UserID = U.UserID
        INNER JOIN Class C on U.ClassID = C.ClassID
        INNER JOIN Profile P on C.ProfileID = P.ProfileID
    GROUP BY Grade.Owner_UserID
    ORDER BY
        AverageGrade DESC,
        GradeCount DESC
    LIMIT 10;

-- FOR TESTING
-- select * from top_10_students;

-- 5. View - top 10 classes
create view top_10_classes as
    SELECT
        User.ClassID,
        SUM(GV.NumericValue)/SUM(Grade.Weight) Average,
        YEAR(CURRENT_DATE()) - C.StartYear Year,
        P.ShortName Profile_ShortName,
        P.FullName Profile_FullName,
        U.Name Preceptor_Name,
        U.Surname Preceptor_Surname,
        U.Email Preceptor_Email,
        C.Preceptor_UserID
    FROM
        Grade
        INNER JOIN User ON Grade.Owner_UserID = User.UserID
        INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
        INNER JOIN Class C on User.ClassID = C.ClassID
        INNER JOIN Profile P on C.ProfileID = P.ProfileID
        INNER JOIN User U on C.Preceptor_UserID = U.UserID
    GROUP BY User.ClassID
    Order BY Average DESC
    LIMIT 10;

-- FOR TESTING
-- select * from top_10_classes;

-- 6. View - risk students with subject
create view risk_students_with_subject as
    SELECT
        Owner_UserID,
        SUM(GV.NumericValue)/SUM(Grade.Weight) Average,
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

-- 7. View - students eligible for the scholarship
create view students_eligible_scholarship as
    SELECT
        U.UserID, U.Email, U.Name, U.Surname, U.Address, U.PESEL,
        SUM(GV.NumericValue)/SUM(Grade.Weight) Average
    FROM
        Grade
        INNER JOIN User U on Grade.Owner_UserID = U.UserID
        INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
    GROUP BY Grade.Owner_UserID
    HAVING Average >= 4.75;

-- FOR TESTING
-- select * from students_eligible_scholarship;

-- 7. View - subjects for the teacher
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

USE `szkola`;
CREATE `students` AS
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
    ORDER BY `U`.`Surname` , `U`.`Name`

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
        ((`Grade` `G`
        JOIN `GradeValue` `GV` ON ((`GV`.`GradeValueID` = `G`.`GradeValueID`)))
        JOIN `User` `U` ON ((`U`.`UserID` = `G`.`Issuer_UserID`)))
