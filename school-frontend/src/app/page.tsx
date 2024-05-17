import { Header } from '~/components/Header';
import { Content, Layout } from '~/components/antd';
import classes from './page.module.css';
import { Card } from 'antd';
import { db } from '~/lib/db';
import { TopStudentsTable } from './TopStudentsTable';
import { TopClassesTable } from './TopClassesTable';
import { ScholarshipTable } from './ScholarshipTable';
import { FailingStudentsTable } from './FailingStudents';

export default async function HomeView() {
    const [topClasses, topStudents, studentsForScholarship, riskStudents] =
        await Promise.all([
            await db
                .select(
                    'ClassID',
                    'Year',
                    'Profile_ShortName',
                    'Preceptor_Name',
                    'Preceptor_Surname',
                    'Preceptor_UserID',
                    'Average',
                )
                .from('top_10_classes'),
            await db
                .select(
                    'AverageGrade',
                    'GradeCount',
                    'Name',
                    'Surname',
                    'Year',
                    'ShortName',
                    'ClassID',
                    'Owner_UserID',
                )
                .from('top_10_students'),
            await db
                .select('Name', 'Surname', 'UserID', 'Average')
                .from('students_eligible_scholarship')
                .orderBy('Average', 'desc')
                .orderBy('Surname', 'asc')
                .orderBy('Name', 'asc'),
            await db
                .select(
                    'User.UserID',
                    'risk_students_with_subject.Average',
                    db.ref('risk_students_with_subject.Name').as('SubjectName'),
                    'User.Name',
                    'User.Surname',
                )
                .from('risk_students_with_subject')
                .innerJoin('User', {
                    'User.UserId': 'risk_students_with_subject.Owner_UserID',
                }),
        ]);

    return (
        <Layout>
            <Header>
                <h1>Overview</h1>
            </Header>
            <Content className={classes.content}>
                <Card title="Top 10 students">
                    <TopStudentsTable
                        data={topStudents.map(
                            ({
                                AverageGrade,
                                GradeCount,
                                Name,
                                Surname,
                                Year,
                                ShortName,
                                Owner_UserID,
                                ClassID,
                            }) => ({
                                average: AverageGrade,
                                gradeCount: GradeCount,
                                classId: ClassID,
                                className: Year + ShortName,
                                studentId: Owner_UserID,
                                studentName: `${Name} ${Surname}`,
                            }),
                        )}
                    />
                </Card>
                <Card title="Top 10 classes">
                    <TopClassesTable
                        data={topClasses.map(
                            ({
                                ClassID,
                                Year,
                                Profile_ShortName,
                                Preceptor_Name,
                                Preceptor_Surname,
                                Preceptor_UserID,
                                Average,
                            }) => ({
                                average: Average,
                                classId: ClassID,
                                className: Year + Profile_ShortName,
                                preceptorId: Preceptor_UserID,
                                preceptorName: `${Preceptor_Name} ${Preceptor_Surname}`,
                            }),
                        )}
                    />
                </Card>
                <Card title="Failing students">
                    <FailingStudentsTable
                        data={riskStudents.map(
                            ({
                                Surname,
                                Name,
                                SubjectName,
                                Average,
                                UserID,
                            }) => ({
                                average: Average,
                                studentId: UserID,
                                studentName: `${Name} ${Surname}`,
                                subjectName: SubjectName,
                            }),
                        )}
                    />
                </Card>
                <Card title="Studenst eligible for scholarship">
                    <ScholarshipTable
                        data={studentsForScholarship.map(
                            ({ Name, Surname, UserID, Average }) => ({
                                studentId: UserID,
                                average: Average,
                                studentName: `${Name} ${Surname}`,
                            }),
                        )}
                    />
                </Card>
            </Content>
        </Layout>
    );
}
