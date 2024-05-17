import React from 'react';
import { db } from '~/lib/db';
import { GradesTableClient } from './GradesTableClient';
import { revalidatePath } from 'next/cache';

interface GradesTableProps {
    studentId: number;
}

export const GradesTable: React.FC<GradesTableProps> = async ({
    studentId,
}) => {
    const [[[averages]], grades, gradeValues, teachers] = await Promise.all([
        db.raw('call student_subjects_gpas(?)', [studentId]),
        db
            .select(
                'GradeID',
                'SubjectID',
                'Issuer_UserID',
                'Weight',
                'IssuedAt',
                'Name',
                'SymbolicValue',
                'IssuerName',
                'IssuerSurname',
                'GradeValueID',
            )
            .from('gade_values_with_issuer')
            .where('OwnerUserID', studentId),
        db
            .select('GradeValueID', 'SymbolicValue')
            .from('GradeValue')
            .orderBy('NumericValue'),
        db
            .distinct('Name', 'Surname', 'UserID', 'SubjectID')
            .from('teachers')
            .innerJoin('ClassSubjectTeacher', {
                'ClassSubjectTeacher.Teacher_UserID': 'teachers.UserID',
            }),
    ]);

    return (
        <GradesTableClient
            averages={(averages as any[]).map(({ GPA, Name, SubjectID }) => ({
                subjectId: SubjectID,
                subjectName: Name,
                value: GPA,
            }))}
            grades={grades.map(
                ({
                    GradeID,
                    SubjectID,
                    Issuer_UserID,
                    Weight,
                    IssuedAt,
                    Name,
                    SymbolicValue,
                    IssuerName,
                    IssuerSurname,
                    GradeValueID,
                }) => ({
                    id: GradeID,
                    issuedAt: IssuedAt,
                    issuerId: Issuer_UserID,
                    subjectId: SubjectID,
                    weight: Weight,
                    name: Name,
                    symbolicValue: SymbolicValue,
                    gradeValueId: GradeValueID,
                    issuerName: `${IssuerName} ${IssuerSurname}`,
                }),
            )}
            teachers={teachers}
            gradeValues={gradeValues}
            onGradeSubmit={async (
                subjectId: number,
                { gradeValueId, issuerId, weight }: any,
            ) => {
                'use server';

                await db
                    .insert({
                        SubjectID: subjectId,
                        GradeValueID: gradeValueId,
                        Issuer_UserID: issuerId,
                        Owner_UserID: studentId,
                        IssuedAT: undefined,
                        Weight: weight,
                    })
                    .into('Grade');

                revalidatePath('/students');
            }}
            onGradeDelete={async gradeId => {
                'use server';
                await db.delete().from('Grade').where('GradeID', gradeId);
                revalidatePath('/students');
            }}
            onGradeUpdate={async (
                gradeId: number,
                { gradeValueId, issuerId, weight }: any,
            ) => {
                'use server';

                await db('Grade')
                    .update({
                        GradeValueID: gradeValueId,
                        Issuer_UserID: issuerId,
                        Weight: weight,
                    })
                    .where('GradeID', gradeId);
                revalidatePath('/students');
            }}
        />
    );
};
