-- 1. View - List of all student grades
use szkola;
DELIMITER $
create procedure all_students(IN user_id int)
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
-- call all_students(1);

-- 2. View - List of class grades in a given subject (journal)
use szkola;
DELIMITER $
create procedure all_grades_for_class_and_subject(IN class_id int, IN subject_id int)
	begin
        SELECT
            GradeID,
            Student.UserID,
            GV.NumericValue,
            GV.SymbolicValue,
            GV.Name,
            GV.ShortName
        FROM
            Grade
            INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
            INNER JOIN Student ON Student.UserID = Grade.Owner_UserID
        WHERE
            Student.ClassID = class_id AND Grade.SubjectID = subject_id;
    END $
DELIMITER ;

-- FOR TESTING
-- call all_grades_for_class_and_subject(1,1);

-- 3. View - Lesson plan for a given user
use szkola;
DELIMITER $
create procedure lesson_plan_for_user(IN user_id int)
	begin
        SELECT
            T1.TimetableID,
            T1.TimeStart,
            T1.TimeEnd,
            T1.DayNumber,
            Subject.Name,
            Subject.ShortName,
            YEAR(CURRENT_DATE()) - Class.StartYear AS ClassYear,
            P.ShortName,
            P.FullName,
            User.Name,
            User.Surname,
            T1.Teacher_UserID,
            T1.ReplacementTeacher_UserID
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
        ORDER BY
            DayNumber ASC,
            TimeStart ASC;
    END $
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
        INNER JOIN Student S on U.UserID = S.UserID
        INNER JOIN Class C on S.ClassID = C.ClassID
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
        Student.ClassID,
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
        INNER JOIN Student ON Grade.Owner_UserID = Student.UserID
        INNER JOIN GradeValue GV on Grade.GradeValueID = GV.GradeValueID
        INNER JOIN Class C on Student.ClassID = C.ClassID
        INNER JOIN Profile P on C.ProfileID = P.ProfileID
        INNER JOIN User U on C.Preceptor_UserID = U.UserID
    GROUP BY Student.ClassID
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