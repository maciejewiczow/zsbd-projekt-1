import { Empty } from 'antd';
import Link from 'next/link';
import React from 'react';
import { db } from '~/lib/db';

interface SupervisedClassesProps {
    teacherId: number;
}

export const SupervisedClasses: React.FC<SupervisedClassesProps> = async ({
    teacherId,
}) => {
    const supervisedClasses = await db
        .select('ClassID', 'ShortName', 'ClassYear')
        .from('all_classes')
        .where('PerceptorID', teacherId);

    if (supervisedClasses.length === 0) {
        return <Empty description="None" />;
    }

    return (
        <>
            {supervisedClasses.map(({ ClassID, ShortName, ClassYear }) => (
                <>
                    <Link
                        href={`/classes/${ClassID}`}
                        key={ClassID}
                    >
                        {ClassYear}
                        {ShortName}
                    </Link>{' '}
                </>
            ))}
        </>
    );
};
