FROM spark:4.0.1

USER root

RUN mkdir -p /opt/spark/external-jars

COPY target/jars/* /opt/spark/external-jars/

COPY target/jars/*.jar /opt/spark/jars/

ENV SPARK_EXTRA_CLASSPATH=/opt/spark/external-jars/*

USER spark
