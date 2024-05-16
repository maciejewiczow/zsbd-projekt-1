import React from 'react';
import { db } from '~/lib/db';
import { GradesTableClient } from './GradesTableClient';

interface GradesTableProps {
    studentId: number;
}

export const GradesTable: React.FC<GradesTableProps> = async ({
    studentId,
}) => {
    const [[[averages]], grades] = await Promise.all([
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
            )
            .from('gade_values_with_issuer')
            .where('OwnerUserID', studentId),
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
                }) => ({
                    id: GradeID,
                    issuedAt: IssuedAt,
                    issuerId: Issuer_UserID,
                    subjectId: SubjectID,
                    weight: Weight,
                    name: Name,
                    symbolicValue: SymbolicValue,
                    issuerName: `${IssuerName} ${IssuerSurname}`,
                }),
            )}
        />
    );
};
