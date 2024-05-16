'use client';

import { Collapse, Table } from 'antd';
import dayjs from 'dayjs';
import { round } from 'lodash';
import React, { useMemo } from 'react';
import { descendingBy } from '~/utils/arrayUtils';

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
}

export const GradesTableClient: React.FC<GradesTableClientProps> = ({
    grades,
    averages,
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
                    .toSorted(
                        descendingBy(({ issuedAt }) => issuedAt.getDate()),
                    ),
            })),
        [grades, averages],
    );

    return (
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
            ]}
            rowKey="subjectId"
            dataSource={gradeData}
            pagination={false}
        />
    );
};
