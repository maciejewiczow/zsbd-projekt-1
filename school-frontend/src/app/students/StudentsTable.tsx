'use client';

import { Table } from 'antd';
import Link from 'next/link';
import React from 'react';

interface Data {
    name: string;
    userId: number;
    email: string;
    classId: number;
    className: string;
}

interface StudentsTableProps {
    data: Data[];
    pageSize: number;
    currentPage: number;
    total: number;
}

export const StudentsTable: React.FC<StudentsTableProps> = ({
    data,
    pageSize,
    currentPage,
    total,
}) => (
    <Table
        columns={[
            {
                title: 'Name',
                dataIndex: 'name',
                render: (value, { userId }) => (
                    <Link href={`/students/${userId}`}>{value}</Link>
                ),
            },
            {
                title: 'Email',
                dataIndex: 'email',
            },
            {
                title: 'Class',
                dataIndex: 'className',
                render: (value, { classId }) => (
                    <Link href={`/classes/${classId}`}>{value}</Link>
                ),
            },
        ]}
        rowKey={({ userId }) => userId}
        pagination={{
            pageSize,
            current: currentPage,
            total,
            itemRender: (page, _, element) => (
                <Link
                    href={`?page=${page}`}
                    legacyBehavior
                >
                    {element}
                </Link>
            ),
            position: ['bottomCenter'],
        }}
        dataSource={data}
    />
);
