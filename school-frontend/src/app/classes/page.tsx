import { Metadata } from 'next';
import { Content, Layout } from '~/components/antd';
import { db } from '~/lib/db';
import { ClassTable } from './ClassTable';
import { Header } from '~/components/Header';

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

    const totalResult = await db.count('ClassID').from('all_classes');

    const total = +totalResult[0]['count(`ClassID`)'];

    const classes = await db
        .select('*')
        .from('all_classes')
        .offset((page - 1) * pageSize)
        .limit(pageSize);

    return (
        <Layout>
            <Header>
                <h1>Classes</h1>
            </Header>
            <Content>
                <ClassTable
                    currentPage={page}
                    data={classes.map(
                        ({
                            ClassYear,
                            ShortName,
                            PerceptorName,
                            PerceptorSurname,
                            ClassID,
                            PerceptorID,
                        }) => ({
                            classname: `${ClassYear}${ShortName}`,
                            perceptor: `${PerceptorName} ${PerceptorSurname}`,
                            classId: ClassID,
                            perceptorId: PerceptorID,
                        }),
                    )}
                    pageSize={pageSize}
                    total={total}
                />
            </Content>
        </Layout>
    );
}
