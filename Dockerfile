#This is a sample Image 
FROM ubuntu:latest
MAINTAINER gregory.lagasse@aleph-beth.net

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update 
RUN apt-get install -y tzdata
RUN apt-get install -y build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        freetds-bin \
        krb5-user \
        ldap-utils \
        libsasl2-2 \
        libsasl2-modules \
        libssl1.1 \
        locales  \
        lsb-release \
        sasl2-bin \
        sqlite3 \
        unixodbc

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib
RUN apt-get install -y python3-dev python3-numpy-dev python3-numpy python3-yaml
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-venv

# airflow needs a home, ~/airflow is the default,
# but you can lay foundation somewhere else if you prefer
# (optional)
ENV AIRFLOW_HOME=/home/airflow
ENV PATH=$PATH:~/.local/bin

RUN mkdir -vp $AIRFLOW_HOME
RUN adduser --home $AIRFLOW_HOME  airflow
RUN chown -R airflow:airflow $AIRFLOW_HOME
WORKDIR $AIRFLOW_HOME
VOLUME /mnt/volume


# install from pypi using pip
USER airflow
RUN cd $AIRFLOW_HOME
RUN python3 -m venv venv-airflow
RUN chmod ug+x $AIRFLOW_HOME/venv-airflow/bin/activate
RUN $AIRFLOW_HOME/venv-airflow/bin/activate
RUN pip3 install apache-airflow['postgres','aws']

EXPOSE 8080


COPY airflow.cfg $AIRFLOW_HOME

# initialize the database
USER postgres
CMD  /etc/init.d/postgresql start
CMD psql  -c "CREATE USER airflow PASSWORD 'airflow';"
CMD psql  -c "CREATE DATABASE airflow;"
CMD psql  -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO newt;"
CMD psql  -c "ALTER ROLE username SET search_path = airflow, foobar;"

CMD airflow initdb

# start the web server, default port is 8080
CMD airflow webserver -p 8080

# start the scheduler
CMD airflow scheduler