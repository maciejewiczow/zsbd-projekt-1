import { Card } from 'antd';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { Header } from '~/components/Header';
import { Content } from '~/components/antd';
import { db } from '~/lib/db';
import classes from './page.module.css';
import { round } from '~/utils/round';
import { UsersTable } from './UsersTable';
import { Layout } from '~/components/antd';
import { Timetable } from '~/components/Timetable';

export default async function ClassPage({
    params: { classId },
}: {
    params: { classId: string };
}) {
    const classData = await db
        .select('*')
        .from('all_classes')
        .where('ClassID', classId)
        .first();

    if (!classData) return notFound();

    const [students, [[[{ GPA }]]], [[timetableData]]] = await Promise.all([
        db
            .select('Name', 'Surname', 'UserID', 'Email')
            .from('User')
            .where('ClassID', classId),
        db.raw('call calculate_class_gpa(?)', [classId]),
        db.raw('call lesson_plan_for_class(?)', [classId]),
    ]);

    const {
        ClassYear,
        ShortName,
        PerceptorID,
        PerceptorName,
        PerceptorSurname,
    } = classData;

    return (
        <Layout className={classes.layout}>
            <Header>
                <h1>
                    Class {ClassYear}
                    {ShortName}
                </h1>
            </Header>
            <Content className={classes.content}>
                <Card
                    title="Perceptor"
                    className={classes.perceptor}
                >
                    <Link href={`/teachers/${PerceptorID}`}>
                        {PerceptorName} {PerceptorSurname}
                    </Link>
                </Card>
                <Card
                    title="Class GPA"
                    className={classes.average}
                >
                    {round(GPA, 2)}
                </Card>
                <Card
                    title="Class size"
                    className={classes.count}
                >
                    {students.length}
                </Card>
                <Card
                    title="Students"
                    className={classes.students}
                >
                    <UsersTable
                        data={students.map(
                            ({ Name, Surname, Email, UserID }) => ({
                                name: `${Name} ${Surname}`,
                                email: Email,
                                userId: UserID,
                            }),
                        )}
                    />
                </Card>
                <Card
                    title="Timetable"
                    className={classes.timetable}
                >
                    <Timetable
                        version="student"
                        data={(timetableData as any[]).map(
                            ({
                                TimeStart,
                                TimeEnd,
                                DayNumber,
                                SubjectName,
                                Teacher_UserID,
                                TeacherName,
                                TeacherSurname,
                                ReplacementTeacher_UserID,
                                ReplacementTeacherName,
                                ReplacementTeacherSurname,
                            }) => ({
                                dayNumber: DayNumber,
                                timeStart: TimeStart,
                                timeEnd: TimeEnd,
                                subject: SubjectName,
                                teacherId: Teacher_UserID,
                                teacher: `${TeacherName} ${TeacherSurname}`,
                                classId: +classId,
                                className: `${ClassYear}${ShortName}`,
                                replacementTeacherId: ReplacementTeacher_UserID,
                                replacementTeacher:
                                    ReplacementTeacher_UserID !== null
                                        ? `${ReplacementTeacherName} ${ReplacementTeacherSurname}`
                                        : null,
                            }),
                        )}
                    />
                </Card>
            </Content>
        </Layout>
    );
}
