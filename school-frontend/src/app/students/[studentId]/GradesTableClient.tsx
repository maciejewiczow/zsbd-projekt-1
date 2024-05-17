'use client';

import { Button, Table } from 'antd';
import dayjs from 'dayjs';
import { round } from 'lodash';
import React, { useMemo } from 'react';
import { descendingBy } from '~/utils/arrayUtils';
import Link from 'next/link';
import { AddGradeModal } from './AddGradeModal';
import { FaTrashAlt } from 'react-icons/fa';

interface GradeData {
    name: string;
    symbolicValue: string;
    id: number;
    subjectId: number;
    issuerId: number;
    issuerName: string;
    issuedAt: Date;
    weight: number;
}

interface Average {
    subjectId: number;
    subjectName: string;
    value: number;
}

interface SubjectGrades extends Average {
    grades: GradeData[];
}

interface GradesTableClientProps {
    grades: GradeData[];
    averages: Average[];
    gradeValues: any[];
    teachers: any[];
    onGradeSubmit: (subjectId: number, formData: any) => Promise<void>;
    onGradeDelete: (gradeId: number) => Promise<void>;
}

export const GradesTableClient: React.FC<GradesTableClientProps> = ({
    grades,
    averages,
    gradeValues,
    onGradeSubmit,
    teachers,
    onGradeDelete,
}) => {
    const gradeData = useMemo(
        () =>
            averages.map<SubjectGrades>(({ subjectId, ...rest }) => ({
                ...rest,
                subjectId,
                grades: grades
                    .filter(
                        ({ subjectId: gradeSubjectId }) =>
                            gradeSubjectId === subjectId,
                    )
                    .toSorted(descendingBy(({ issuedAt }) => +issuedAt)),
            })),
        [grades, averages],
    );

    return (
        <>
            <Table
                expandable={{
                    expandedRowRender: ({ grades }) => (
                        <Table
                            rowKey="id"
                            dataSource={grades}
                            columns={[
                                {
                                    title: 'Grade',
                                    dataIndex: 'symbolicValue',
                                    render: (value, { name }) => (
                                        <span title={name}>{value}</span>
                                    ),
                                },
                                {
                                    title: 'Weight',
                                    dataIndex: 'weight',
                                    render: value => round(value, 2),
                                },
                                {
                                    title: 'Date of issue',
                                    dataIndex: 'issuedAt',
                                    render: date => (
                                        <span
                                            title={dayjs(date).format(
                                                'DD-MM-YYYY, HH:mm:ss',
                                            )}
                                        >
                                            {dayjs(date).calendar(undefined, {
                                                sameElse: 'DD-MM-YYYY',
                                            })}
                                        </span>
                                    ),
                                },
                                {
                                    title: 'Issued by',
                                    dataIndex: 'issuerName',
                                    render: (value, { issuerId }) => (
                                        <Link href={`/teachers/${issuerId}`}>
                                            {value}
                                        </Link>
                                    ),
                                },
                                {
                                    title: 'Actions',
                                    render: (_, { id }) => (
                                        <form
                                            action={onGradeDelete.bind(
                                                null,
                                                id,
                                            )}
                                        >
                                            <Button
                                                icon={<FaTrashAlt />}
                                                htmlType="submit"
                                                danger
                                            />
                                        </form>
                                    ),
                                },
                            ]}
                        />
                    ),
                }}
                columns={[
                    {
                        title: 'Subject',
                        dataIndex: 'subjectName',
                    },
                    {
                        title: 'GPA',
                        dataIndex: 'value',
                        render: value => round(value, 2),
                    },
                    {
                        title: 'Actions',
                        render: (_, { subjectId, subjectName }) => (
                            <AddGradeModal
                                gradeValues={gradeValues.map(
                                    ({ GradeValueID, SymbolicValue }) => ({
                                        id: GradeValueID,
                                        name: SymbolicValue,
                                    }),
                                )}
                                teachers={teachers
                                    .filter(
                                        ({ SubjectID }) =>
                                            SubjectID === subjectId,
                                    )
                                    .map(({ Name, Surname, UserID }) => ({
                                        id: UserID,
                                        name: `${Name} ${Surname}`,
                                    }))}
                                onSubmit={onGradeSubmit.bind(null, subjectId)}
                                subjectName={subjectName}
                            />
                        ),
                    },
                ]}
                rowKey="subjectId"
                dataSource={gradeData}
                pagination={false}
            />
        </>
    );
};
