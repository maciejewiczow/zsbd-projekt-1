'use client';

import { Inter } from 'next/font/google';
import './globals.css';
import { PropsWithChildren, useState } from 'react';
import { AntdRegistry } from '@ant-design/nextjs-registry';
import { Layout, Menu } from 'antd';
import Image from 'next/image';
import logoSrc from '~/assets/logo.png';
import classes from './layout.module.css';
import { HiMiniUserGroup } from 'react-icons/hi2';
import { PiStudentBold } from 'react-icons/pi';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { GiTeacher } from 'react-icons/gi';

import '~/utils/dayjs';

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({ children }: PropsWithChildren) {
    const [isSiderCollapsed, setIsSiderCollapsed] = useState(true);
    const pathname = usePathname();

    return (
        <html lang="en">
            <body className={inter.className}>
                <AntdRegistry>
                    <Layout>
                        <Layout.Sider
                            theme="light"
                            collapsible
                            collapsed={isSiderCollapsed}
                            onCollapse={setIsSiderCollapsed}
                            className={classes.sider}
                        >
                            <Image
                                src={logoSrc}
                                className={classes.logo}
                                alt="Example school logo"
                                priority
                            />
                            <Menu
                                activeKey={pathname}
                                items={[
                                    {
                                        label: <Link href="/">Classes</Link>,
                                        key: '/',
                                        icon: <HiMiniUserGroup />,
                                    },
                                    {
                                        label: (
                                            <Link href="/students">
                                                Students
                                            </Link>
                                        ),
                                        key: '/students',
                                        icon: <PiStudentBold />,
                                    },
                                    {
                                        label: (
                                            <Link href="/teachers">
                                                Teachers
                                            </Link>
                                        ),
                                        key: '/teachers',
                                        icon: <GiTeacher />,
                                    },
                                ]}
                            />
                        </Layout.Sider>
                        <Layout.Content className={classes.content}>
                            {children}
                        </Layout.Content>
                    </Layout>
                </AntdRegistry>
            </body>
        </html>
    );
}
