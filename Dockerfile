FROM scratch
MAINTAINER master-hax
ARG UPSTREAM_VERSION

FROM ubuntu:jammy as base
RUN apt-get update

FROM base as builder
RUN apt-get install -y --no-install-recommends \
git \
curl \
ca-certificates \
maven
ARG UPSTREAM_VERSION
RUN git clone --depth 1 --branch ${UPSTREAM_VERSION?upstream version not provided} https://github.com/jagrosh/MusicBot.git
WORKDIR /MusicBot
RUN sed -i -e s/Snapshot/${UPSTREAM_VERSION?upstream version not provided}/g ./pom.xml
RUN mvn verify
RUN mv /MusicBot/target/JMusicBot-${UPSTREAM_VERSION?upstream version not provided}-All.jar /MusicBot/target/JMusicBot.jar

FROM base as release
RUN apt-get install -y --no-install-recommends default-jre
ARG UPSTREAM_VERSION
RUN mkdir /app
WORKDIR /app
COPY --from=builder /MusicBot/target/JMusicBot.jar ./JMusicBot.jar
RUN useradd nonroot
USER nonroot
ENTRYPOINT [ "/bin/sh", "-c",  "java -jar -Dnogui=true -Dconfig.file=${CONFIG_FILE:-config.txt} JMusicBot.jar" ]
