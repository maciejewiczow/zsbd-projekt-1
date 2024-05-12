CREATE DATABASE if not exists szkola character set UTF8MB4 collate utf8mb4_bin;

create user if not exists 'application' identified with mysql_native_password by '7966e4d8-cb1b-548a-859b-b8e336f9fcae';
GRANT SELECT, UPDATE, INSERT, DELETE ON szkola.* TO application;
