'use client';

import { Collapse, Empty, Table } from 'antd';
import Link from 'next/link';
import React, { useMemo } from 'react';
import { groupBy, times } from 'lodash';
import { ascendingBy } from '~/utils/arrayUtils';
import classes from './Timetable.module.css';
import dayjs from 'dayjs';

interface TimetableData {
    timeStart: string;
    timeEnd: string;
    dayNumber: number;
    teacher: string;
    teacherId: number;
    replacementTeacher: string | null;
    replacementTeacherId: number | null;
    subject: string;
    className: string;
    classId: number;
}

interface TimetableProps {
    version: 'teacher' | 'student';
    data: TimetableData[];
}

export const Timetable: React.FC<TimetableProps> = ({
    data: rawData,
    version,
}) => {
    const data = useMemo(
        () =>
            Object.entries(groupBy(rawData, ({ dayNumber }) => dayNumber))
                .toSorted(ascendingBy(([dayNr]) => +dayNr))
                .map(
                    ([dayNumber, data]) =>
                        [dayjs().day(+dayNumber).format('dddd'), data] as const,
                ),
        [rawData],
    );

    if (data.length === 0) {
        return <Empty description="No classes" />;
    }

    return (
        <Collapse
            accordion
            items={data.map(([dayName, dayTimetable], index) => ({
                key: index,
                label: dayName,
                children: (
                    <Table
                        columns={[
                            {
                                title: 'Start time',
                                dataIndex: 'timeStart',
                                render: val =>
                                    dayjs(val, 'HH:mm:ss').format('H:mm'),
                            },
                            {
                                title: 'End time',
                                dataIndex: 'timeEnd',
                                render: val =>
                                    dayjs(val, 'HH:mm:ss').format('H:mm'),
                            },
                            {
                                title: 'Subject',
                                dataIndex: 'subject',
                            },
                            version === 'student'
                                ? {
                                      title: 'Teacher',
                                      dataIndex: 'teacher',
                                      render: (
                                          val,
                                          {
                                              teacherId,
                                              replacementTeacher,
                                              replacementTeacherId,
                                          },
                                      ) =>
                                          !replacementTeacherId ? (
                                              <Link
                                                  href={`/teachers/${teacherId}`}
                                              >
                                                  {val}
                                              </Link>
                                          ) : (
                                              <>
                                                  <span
                                                      className={
                                                          classes.oldTeacher
                                                      }
                                                  >
                                                      {val}
                                                  </span>{' '}
                                                  <Link
                                                      href={`/teachers/${replacementTeacherId}`}
                                                  >
                                                      {replacementTeacher}
                                                  </Link>
                                              </>
                                          ),
                                  }
                                : {
                                      title: 'Class',
                                      dataIndex: 'className',
                                      render: (name, { classId }) => (
                                          <Link href={`/classes/${classId}`}>
                                              {name}
                                          </Link>
                                      ),
                                  },
                        ]}
                        dataSource={dayTimetable}
                        rowKey={({ timeStart, timeEnd }) => timeStart + timeEnd}
                        pagination={false}
                    />
                ),
            }))}
            defaultActiveKey={0}
        />
    );
};
