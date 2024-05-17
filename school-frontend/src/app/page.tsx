import { Header } from '~/components/Header';
import { Content, Layout } from '~/components/antd';
import classes from './page.module.css';

export default async function HomeView() {
    return (
        <Layout>
            <Header>
                <h1>Overview</h1>
            </Header>
            <Content className={classes.content}>Content</Content>
        </Layout>
    );
}
