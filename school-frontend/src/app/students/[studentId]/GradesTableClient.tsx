'use client';

import { Button, Table } from 'antd';
import dayjs from 'dayjs';
import { round } from 'lodash';
import React, { useMemo } from 'react';
import { descendingBy } from '~/utils/arrayUtils';
import Link from 'next/link';
import { AddOrModifyGradeModal } from './AddOrModifyGradeModal';
import { FaTrashAlt } from 'react-icons/fa';
import classes from './page.module.css';

interface GradeData {
    name: string;
    symbolicValue: string;
    id: number;
    subjectId: number;
    issuerId: number;
    issuerName: string;
    issuedAt: Date;
    weight: number;
    gradeValueId: number;
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
    onGradeUpdate: (gradeId: number, formData: any) => Promise<void>;
}

export const GradesTableClient: React.FC<GradesTableClientProps> = ({
    grades,
    averages,
    gradeValues: gradeValuesProp,
    teachers,
    onGradeSubmit,
    onGradeDelete,
    onGradeUpdate,
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

    const gradeValues = gradeValuesProp.map(
        ({ GradeValueID, SymbolicValue }) => ({
            id: GradeValueID,
            name: SymbolicValue,
        }),
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
                                    render: (
                                        _,
                                        {
                                            id,
                                            subjectId,
                                            gradeValueId,
                                            issuerId,
                                            weight,
                                        },
                                    ) => (
                                        <div
                                            className={classes.gradeActionsRow}
                                        >
                                            <AddOrModifyGradeModal
                                                teachers={teachers
                                                    .filter(
                                                        ({ SubjectID }) =>
                                                            SubjectID ===
                                                            subjectId,
                                                    )
                                                    .map(
                                                        ({
                                                            Name,
                                                            Surname,
                                                            UserID,
                                                        }) => ({
                                                            id: UserID,
                                                            name: `${Name} ${Surname}`,
                                                        }),
                                                    )}
                                                gradeValues={gradeValues}
                                                onSubmit={onGradeUpdate.bind(
                                                    null,
                                                    id,
                                                )}
                                                grade={{
                                                    gradeValueId,
                                                    issuerId,
                                                    weight,
                                                }}
                                            />
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
                                        </div>
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
                            <AddOrModifyGradeModal
                                gradeValues={gradeValues}
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
