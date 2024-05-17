'use client';

import { Table } from 'antd';
import Link from 'next/link';
import React from 'react';

interface TeacherData {
    name: string;
    id: number;
}

interface TeachersTableProps {
    data: TeacherData[];
}

export const TeachersTable: React.FC<TeachersTableProps> = ({ data }) => (
    <Table
        columns={[
            {
                title: 'Name',
                dataIndex: 'name',
                render: (val, { id }) => (
                    <Link href={`/teachers/${id}`}>{val}</Link>
                ),
            },
        ]}
        dataSource={data}
        rowKey="id"
    />
);
