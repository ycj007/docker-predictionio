FROM steveny/predictionio:0.12.0
MAINTAINER  chongjie.yuan

USER pio
RUN sudo apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends git  sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cd ${HOME} \
    && sudo  git clone  https://github.com/haricharan123/PredictionIo-lingpipe-MultiLabelClassification.git

CMD ["/bin/bash","pio-start-all"]

