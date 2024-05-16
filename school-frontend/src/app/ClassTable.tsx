'use client';

import { Table } from 'antd';
import Link from 'next/link';
import React from 'react';

interface Data {
    classname: string;
    perceptor: string;
    classId: number;
    perceptorId: number;
}

interface ClassTableProps {
    data: Data[];
    pageSize: number;
    currentPage: number;
    total: number;
}

export const ClassTable: React.FC<ClassTableProps> = ({
    data,
    currentPage,
    pageSize,
    total,
}) => (
    <Table
        columns={[
            {
                title: 'Class',
                dataIndex: 'classname',
                render: (value, { classId }) => (
                    <Link href={`/classes/${classId}`}>{value}</Link>
                ),
            },
            {
                title: 'Perceptor',
                dataIndex: 'perceptor',
                render: (value, { perceptorId }) => (
                    <Link href={`/teachers/${perceptorId}`}>{value}</Link>
                ),
            },
        ]}
        rowKey={({ classId }) => classId}
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
