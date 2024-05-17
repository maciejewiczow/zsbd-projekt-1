'use client';

import { Table } from 'antd';
import { round } from 'lodash';
import Link from 'next/link';
import React from 'react';

interface Data {
    studentId: number;
    studentName: string;
    average: number;
    subjectName: string;
}

interface FailingStudentsTableProps {
    data: Data[];
}

export const FailingStudentsTable: React.FC<FailingStudentsTableProps> = ({
    data,
}) => (
    <Table
        columns={[
            {
                title: 'Student',
                dataIndex: 'studentName',
                render: (value, { studentId }) => (
                    <Link href={`/students/${studentId}`}>{value}</Link>
                ),
            },
            {
                title: 'Subject',
                dataIndex: 'subjectName',
            },
            {
                title: 'GPA',
                dataIndex: 'average',
                render: val => round(val, 2).toFixed(2),
            },
        ]}
        rowKey="studentId"
        dataSource={data}
    />
);
