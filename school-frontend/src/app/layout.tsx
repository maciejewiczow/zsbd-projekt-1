import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { PropsWithChildren } from 'react';
import { AntdRegistry } from '@ant-design/nextjs-registry';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
    title: 'School',
    description: 'School management app',
};

export default function RootLayout({ children }: PropsWithChildren) {
    return (
        <html lang="en">
            <AntdRegistry>
                <body className={inter.className}>{children}</body>
            </AntdRegistry>
        </html>
    );
}
