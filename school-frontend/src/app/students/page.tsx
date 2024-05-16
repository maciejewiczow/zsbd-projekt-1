import { Metadata } from 'next';
import { Content, Layout } from '~/components/antd';
import { db } from '~/lib/db';
import { Header } from '~/components/Header';
import { StudentsTable } from './StudentsTable';

export const metadata: Metadata = {
    title: 'School - classes',
};

const pageSize = 12;

export default async function ClassesPage({
    searchParams,
}: {
    searchParams: {
        page?: string;
    };
}) {
    const page = +(searchParams.page ?? 1);

    const totalResult = await db.count('UserID').from('students');

    const total = +totalResult[0]['count(`UserID`)'];

    const students = await db
        .select(
            'UserID',
            'Name',
            'Surname',
            'Email',
            'ClassID',
            'ClassYear',
            'ClassShortName',
        )
        .from('students')
        .offset((page - 1) * pageSize)
        .limit(pageSize);

    return (
        <Layout>
            <Header>
                <h1>Students</h1>
            </Header>
            <Content>
                <StudentsTable
                    currentPage={page}
                    data={students.map(
                        ({
                            UserID,
                            Name,
                            Surname,
                            Email,
                            ClassID,
                            ClassYear,
                            ClassShortName,
                        }) => ({
                            classId: ClassID,
                            name: `${Name} ${Surname}`,
                            email: Email,
                            userId: UserID,
                            className: ClassYear + ClassShortName,
                        }),
                    )}
                    pageSize={pageSize}
                    total={total}
                />
            </Content>
        </Layout>
    );
}
