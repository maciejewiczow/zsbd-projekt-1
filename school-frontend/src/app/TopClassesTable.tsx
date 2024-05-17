'use client';

import { Table } from 'antd';
import Link from 'next/link';
import React from 'react';
import { round } from '~/utils/round';

interface Data {
    average: number;
    classId: number;
    className: string;
    preceptorName: string;
    preceptorId: number;
}

interface TopClassesTableProps {
    data: Data[];
}

export const TopClassesTable: React.FC<TopClassesTableProps> = ({ data }) => (
    <Table
        columns={[
            {
                title: 'Class',
                dataIndex: 'className',
                render: (value, { classId }) => (
                    <Link href={`/classes/${classId}`}>{value}</Link>
                ),
            },
            {
                title: 'Class GPA',
                dataIndex: 'average',
                render: val => round(val, 2).toFixed(2),
            },
            {
                title: 'Preceptor',
                dataIndex: 'preceptorName',
                render: (value, { preceptorId }) => (
                    <Link href={`/teachers/${preceptorId}`}>{value}</Link>
                ),
            },
        ]}
        rowKey="classId"
        pagination={false}
        dataSource={data}
    />
);
