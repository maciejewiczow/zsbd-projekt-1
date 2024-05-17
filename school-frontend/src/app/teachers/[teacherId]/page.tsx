import { Card } from 'antd';
import { notFound } from 'next/navigation';
import { Content, Layout } from '~/components/antd';
import { db } from '~/lib/db';
import classes from './page.module.css';
import { Suspense } from 'react';
import { UserTimetable } from '~/components/UserTimetable';
import { SupervisedClasses } from './SupervisedClasses';
import { TeacherSubjects } from './TeacherSubjects';
import { Header } from '~/components/Header';
import { GiTeacher } from 'react-icons/gi';

export default async function TeacherPage({
    params: { teacherId },
}: {
    params: { teacherId: string };
}) {
    const teacherData = await db
        .select('*')
        .from('teachers')
        .where('UserID', teacherId)
        .first();

    if (!teacherData) return notFound();

    const { Name, Surname, Email, Address, PESEL } = teacherData;

    return (
        <Layout className={classes.layout}>
            <Header className={classes.header}>
                <h1>
                    <GiTeacher /> {Name} {Surname}
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
                    title="Perceptor of"
                    className={classes.className}
                >
                    <Suspense fallback="Loading...">
                        <SupervisedClasses teacherId={+teacherId} />
                    </Suspense>
                </Card>
                <Card
                    title="Taught subjects"
                    className={classes.gpa}
                >
                    <Suspense fallback="Loading...">
                        <TeacherSubjects teacherId={+teacherId} />
                    </Suspense>
                </Card>
                <Card
                    title="Timetable"
                    className={classes.timetable}
                >
                    <Suspense fallback="Loading timetable...">
                        <UserTimetable
                            version="teacher"
                            userId={+teacherId}
                        />
                    </Suspense>
                </Card>
            </Content>
        </Layout>
    );
}
