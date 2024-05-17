import React from 'react';
import { db } from '~/lib/db';

interface TeacherSubjectsProps {
    teacherId: number;
}

export const TeacherSubjects: React.FC<TeacherSubjectsProps> = async ({
    teacherId,
}) => {
    const subjects = await db
        .select('Name')
        .from('ClassSubjectTeacher')
        .innerJoin('Subject', {
            'ClassSubjectTeacher.SubjectID': 'Subject.SubjectID',
        })
        .where('ClassSubjectTeacher.Teacher_UserID', teacherId)
        .groupBy('Subject.SubjectID');

    return subjects.map(({ Name }) => Name).join(', ');
};
