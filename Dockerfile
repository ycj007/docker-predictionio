FROM ubuntu
MAINTAINER Steven Yan

ENV PIO_VERSION 0.12.1

ENV PIO_HOME /PredictionIO-${PIO_VERSION}
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HOME /home/pio

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl libgfortran3 python-pip wget openjdk-8-jdk sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#RUN useradd -G sudo -c 'Predictionio user' -m -d ${HOME} -s /bin/bash pio \
#    && echo "pio ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/pio \
#    && chmod 0440 /etc/sudoers.d/pio

# Switch to a none root user.
#USER root

WORKDIR /app
## Install Predictionio.
RUN
    curl -O http://mirrors.tuna.tsinghua.edu.cn/apache/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}-bin.tar.gz \
    && mkdir apache-predictionio-${PIO_VERSION}\
    && tar -xvzf apache-predictionio-${PIO_VERSION}-bin.tar.gz -C ./apache-predictionio-${PIO_VERSION} \
    && rm apache-predictionio-${PIO_VERSION}-bin.tar.gz \
    && && mkdir /${PIO_HOME}/vendors
RUN sudo tar zxvf ${HOME}/apache-predictionio-${PIO_VERSION}-incubating/PredictionIO-${PIO_VERSION}-incubating.tar.gz -C / \
    && rm -r ${HOME}/apache-predictionio-${PIO_VERSION}-incubating \
    && mkdir /${PIO_HOME}/vendors




