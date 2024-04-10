ARG initalize_with_test_data=0
FROM mysql:latest

COPY ./import/*.sql /docker-entrypoint-initdb.d
RUN mkdir /test-data
COPY ./*.sql /test-data

RUN if [ "$initalize_with_test_data" = "1" ]; then cat /test-data/*.sql > /docker-entrypoint-initdb.d/4_test_data.sql; fi
RUN rm -rf /test-data
