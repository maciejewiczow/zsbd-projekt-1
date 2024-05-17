import { db } from '~/lib/db';
import { TeachersTable } from './TeachersTable';

export default async function TeachersList() {
    const teachers = await db
        .select('Name', 'Surname', 'UserID')
        .from('teachers');

    return (
        <TeachersTable
            data={teachers.map(({ UserID, Name, Surname }) => ({
                id: UserID,
                name: `${Name} ${Surname}`,
            }))}
        />
    );
}
