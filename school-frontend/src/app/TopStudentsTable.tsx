'use client';

import { Table } from 'antd';
import Link from 'next/link';
import React from 'react';
import { round } from '~/utils/round';

interface Data {
    average: number;
    gradeCount: number;
    classId: number;
    className: string;
    studentName: string;
    studentId: number;
}

interface TopStudentsTableProps {
    data: Data[];
}

export const TopStudentsTable: React.FC<TopStudentsTableProps> = ({ data }) => (
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
                render: (val, { gradeCount }) => (
                    <>
                        {round(val, 2).toFixed(2)} (from {gradeCount} grades)
                    </>
                ),
            },
            {
                title: 'Class',
                dataIndex: 'className',
                render: (value, { classId }) => (
                    <Link href={`/classes/${classId}`}>{value}</Link>
                ),
            },
        ]}
        rowKey="studentId"
        pagination={false}
        dataSource={data}
    />
);
