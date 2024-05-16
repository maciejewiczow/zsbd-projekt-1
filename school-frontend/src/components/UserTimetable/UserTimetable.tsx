import React from 'react';
import { Timetable } from '../Timetable';
import { db } from '~/lib/db';

interface UserTimetableProps {
    userId: number;
}

export const UserTimetable: React.FC<UserTimetableProps> = async ({
    userId,
}) => {
    const [[timetableData]] = await db.raw('call lesson_plan_for_user(?)', [
        userId,
    ]);

    return (
        <Timetable
            data={(timetableData as any[]).map(
                ({
                    TimeStart,
                    TimeEnd,
                    DayNumber,
                    SubjectName,
                    Teacher_UserID,
                    TeacherName,
                    TeacherSurname,
                    ReplacementTeacher_UserID,
                    ReplacementTeacherName,
                    ReplacementTeacherSurname,
                }) => ({
                    dayNumber: DayNumber,
                    timeStart: TimeStart,
                    timeEnd: TimeEnd,
                    subject: SubjectName,
                    teacherId: Teacher_UserID,
                    teacher: `${TeacherName} ${TeacherSurname}`,
                    replacementTeacherId: ReplacementTeacher_UserID,
                    replacementTeacher:
                        ReplacementTeacher_UserID !== null
                            ? `${ReplacementTeacherName} ${ReplacementTeacherSurname}`
                            : null,
                }),
            )}
        />
    );
};
