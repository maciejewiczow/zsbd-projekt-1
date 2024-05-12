import knex from 'knex';

if (
    !process.env.DB_HOST ||
    !process.env.DB_PORT ||
    !process.env.DB_USER ||
    !process.env.DB_PASSWORD ||
    !process.env.DB_NAME
)
    throw new Error('Invalid env config');

export const db = knex({
    client: 'mysql2',
    connection: {
        host: process.env.DB_HOST,
        port: +process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    },
    pool: {
        min: 0,
        max: 10,
    },
});
