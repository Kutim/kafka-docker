FROM kutim/openjdk

ARG kafka_version=2.4.0
ARG scala_version=2.12
ARG build_date=unspecified

LABEL org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.version="${scala_version}_${kafka_version}" \
      maintainer="Kutim <1252900197@qq.com>"

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka 

ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh versions.sh /tmp/

RUN apt update -y \
  && apt install -y jq docker \
  && chmod a+x /tmp/*.sh \
  && mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /tmp/versions.sh /usr/bin \
  && sync && /tmp/download-kafka.sh \
  && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
  && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
  && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
  && rm /tmp/* \
  && rm -rf /var/lib/apt/lists/*
COPY overrides /opt/overrides

VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
