FROM scratch
MAINTAINER master-hax

ARG UPSTREAM_VERSION

FROM ubuntu:jammy as builder
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
git \
curl \
ca-certificates \
maven
ARG UPSTREAM_VERSION
RUN git clone --depth 1 --branch ${UPSTREAM_VERSION} https://github.com/jagrosh/MusicBot.git
WORKDIR /MusicBot
RUN sed -i -e s/Snapshot/${UPSTREAM_VERSION}/g ./pom.xml
RUN mvn verify

FROM ubuntu:jammy as release
RUN apt-get update
RUN apt-get install -y --no-install-recommends default-jre
ARG UPSTREAM_VERSION
RUN mkdir /app
WORKDIR /app
COPY --from=builder /MusicBot/target/JMusicBot-${UPSTREAM_VERSION}-All.jar ./JMusicBot.jar
RUN useradd nonroot
USER nonroot
ENV CONFIG_FILE_PATH="config.txt"
ENTRYPOINT java -Dnogui=true -Dconfig=${CONFIG_FILE_PATH} -jar JMusicBot.jar