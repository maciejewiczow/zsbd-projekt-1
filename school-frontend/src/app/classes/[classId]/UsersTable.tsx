'use client';

import { Table } from 'antd';
import Link from 'next/link';
import React from 'react';

interface UserData {
    name: string;
    email: string;
    userId: number;
}

interface UsersTableProps {
    data: UserData[];
}

export const UsersTable: React.FC<UsersTableProps> = ({ data }) => (
    <Table<UserData>
        columns={[
            {
                title: 'Name',
                dataIndex: 'name',
                render: (val, { userId }) => (
                    <Link href={`/students/${userId}`}>{val}</Link>
                ),
            },
            {
                title: 'Email',
                dataIndex: 'email',
            },
        ]}
        rowKey={({ userId }) => userId}
        dataSource={data}
        pagination={{
            pageSize: 8,
        }}
    />
);
