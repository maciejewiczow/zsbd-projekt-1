'use client';

import { Table } from 'antd';
import { round } from 'lodash';
import Link from 'next/link';
import React from 'react';

interface Data {
    studentId: number;
    studentName: string;
    average: number;
}

interface ScholarshipTableProps {
    data: Data[];
}

export const ScholarshipTable: React.FC<ScholarshipTableProps> = ({ data }) => (
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
                title: 'GPA',
                dataIndex: 'average',
                render: val => round(val, 2).toFixed(2),
            },
        ]}
        rowKey="studentId"
        dataSource={data}
    />
);
