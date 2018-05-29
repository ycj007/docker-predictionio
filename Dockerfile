FROM ubuntu
MAINTAINER chongjie.yuan

ENV PIO_VERSION 0.12.1
ENV SPARK_VERSION 2.1.1
ENV HADOOP_VERSION 2.7
ENV ELASTICSEARCH_VERSION 5.5.2
ENV HBASE_VERSION 1.2.6

ENV PIO_HOME /PredictionIO-${PIO_VERSION}
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HOME /home/pio

ARG pio-url=https://www.apache.org/dyn/closer.cgi/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}.tar.gz
ARG pio-tar-name=apache-predictionio-${PIO_VERSION}.tar.gz
ARG pio-dir=apache-predictionio-${PIO_VERSION}
ARG spark-url=http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
ARG spark-tar-name=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
ARG elastic-url=https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
ARG elastic-tar-name=elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
ARG elastic-dir=elasticsearch-${ELASTICSEARCH_VERSION}
ARG hbase-url=http://apache.mirrors.hoobly.com/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz
ARG hbase-tar-name=hbase-${HBASE_VERSION}-bin.tar.gz
ARG hbase-dir=hbase-${HBASE_VERSION}

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl libgfortran3 python-pip wget openjdk-8-jdk sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -G sudo -c 'Predictionio user' -m -d ${HOME} -s /bin/bash pio \
    && echo "pio ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/pio \
    && chmod 0440 /etc/sudoers.d/pio

# Switch to a none root user.
USER pio

## Install Predictionio.
RUN cd ${HOME} \
    && curl -O ${pio-url} \
    && mkdir ${pio-dir}\
    && tar -xvzf ${pio-tar-name} -C ./${pio-dir} \
    && rm ${pio-tar-name}z \
    && cd ${pio-dir} \
    && ./make-distribution.sh

RUN sudo tar zxvf ${HOME}/${pio-dir}/${PIO_HOME} -C / \
    && rm -r ${HOME}/${pio-dir} \
    && mkdir /${PIO_HOME}/vendors

COPY files/pio-env.sh ${PIO_HOME}/conf/pio-env.sh

# Install Spark.
RUN cd ${HOME} \
    && wget ${spark-url} \
    && tar zxvfC ${spark-tar-name} ${PIO_HOME}/vendors \
    && rm ${spark-tar-name}

USER root

RUN sudo echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 \
    && apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends sbt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER pio

# Install elastic search.
RUN cd ${HOME} \
    && wget ${elastic-url} \
    && tar -xvzf ${elastic-tar-name} -C ${PIO_HOME}/vendors \
    && rm ${elastic-tar-name} \
    && echo 'cluster.name: predictionio' >> ${PIO_HOME}/vendors/${elastic-dir}/config/elasticsearch.yml \
    && echo 'network.host: _local_' >> ${PIO_HOME}/vendors/${elastic-dir}/config/elasticsearch.yml

# Install Hbase
RUN cd ${HOME} \
    && curl -O ${hbase-url} \
    && tar -xvzf ${hbase-tar-name} -C ${PIO_HOME}/vendors \
    && rm ${hbase-tar-name}
COPY files/hbase-site.xml ${PIO_HOME}/vendors/${hbase-dir}/conf/hbase-site.xml

RUN sed -i "s|VAR_PIO_HOME|${PIO_HOME}|" ${PIO_HOME}/vendors/${hbase-dir}/conf/hbase-site.xml \
    && sed -i "s|VAR_HBASE_VERSION|${HBASE_VERSION}|" ${PIO_HOME}/vendors/${hbase-dir}/conf/hbase-site.xml
