#This is a sample Image 
FROM ubuntu:latest
MAINTAINER gregory.lagasse@aleph-beth.net

RUN apt-get update 


RUN apt-get install -y python3-dev python3-numpy-dev python3-numpy python3-yaml
RUN apt-get install -y python3-pip
# airflow needs a home, ~/airflow is the default,
# but you can lay foundation somewhere else if you prefer
# (optional)
RUN export AIRFLOW_HOME=~/airflow

RUN adduser --home /home/airflow  airflow
WORKDIR /home/airflow
VOLUME /mnt/volume
USER airflow

# install from pypi using pip
RUN pip install apache-airflow

EXPOSE 8080

# initialize the database
CMD airflow initdb

# start the web server, default port is 8080
CMD airflow webserver -p 8080

# start the scheduler
CMD airflow scheduler

# visit localhost:8080 in the browser and enable the example dag in the home page
