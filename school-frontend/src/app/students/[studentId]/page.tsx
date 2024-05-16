import { Card } from 'antd';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { Header } from '~/components/Header';
import { Content } from '~/components/antd';
import { db } from '~/lib/db';
import classes from './page.module.css';
import { round } from '~/utils/round';
import { Layout } from '~/components/antd';
import { Suspense } from 'react';
import { UserTimetable } from '~/components/UserTimetable';
import { GradesTable } from './GradesTable';

export default async function ClassPage({
    params: { studentId },
}: {
    params: { studentId: string };
}) {
    const userData = await db
        .select('*')
        .from('students')
        .where('UserID', studentId)
        .first();

    if (!userData) return notFound();

    const [[[{ Average }]]] = await db.raw('call student_overall_gpa(?)', [
        studentId,
    ]);

    const {
        Name,
        Surname,
        Email,
        Address,
        PESEL,
        ClassID,
        ClassYear,
        ClassShortName,
    } = userData;

    return (
        <Layout className={classes.layout}>
            <Header>
                <h1>
                    {Name} {Surname}
                </h1>
            </Header>
            <Content className={classes.content}>
                <Card
                    title="Personal data"
                    className={classes.data}
                >
                    Email: <a href={`mailto:${Email}`}>{Email}</a>
                    <br />
                    Address: {Address}
                    <br />
                    PESEL: {PESEL}
                    <br />
                </Card>
                <Card
                    title="Class"
                    className={classes.className}
                >
                    <Link href={`/classes/${ClassID}`}>
                        {ClassYear}
                        {ClassShortName}
                    </Link>
                </Card>
                <Card
                    title="Overall GPA"
                    className={classes.gpa}
                >
                    {round(Average, 2)}
                </Card>
                <Card
                    title="Grades"
                    className={classes.grades}
                >
                    <Suspense fallback="Loading grades...">
                        <GradesTable studentId={+studentId} />
                    </Suspense>
                </Card>
                <Card
                    title="Timetable"
                    className={classes.timetable}
                >
                    <Suspense fallback="Loading timetable...">
                        <UserTimetable userId={+studentId} />
                    </Suspense>
                </Card>
            </Content>
        </Layout>
    );
}
