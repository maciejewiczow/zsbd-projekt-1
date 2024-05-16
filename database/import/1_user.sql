CREATE DATABASE if not exists szkola CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

create user if not exists 'application' identified with mysql_native_password by '7966e4d8-cb1b-548a-859b-b8e336f9fcae';
GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON szkola.* TO application;
