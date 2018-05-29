FROM ycj/pio-0.12.1
MAINTAINER  chongjie.yuan

ARG ENGINE_NAME=template-scala-topic-model-LDA.tar.gz

WORKDIR /engine
ADD ${ENGINE_NAME}  ${WORKDIR}

