FROM mysql:latest

COPY ./import/*.sql /docker-entrypoint-initdb.d
RUN mkdir /test-data
COPY ./*.sql /test-data

RUN cat /test-data/*.sql > /docker-entrypoint-initdb.d/4_test_data.sql
RUN rm -rf /test-data
