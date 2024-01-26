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
RUN git clone --depth 1 --branch ${UPSTREAM_VERSION?upstream version not provided} https://github.com/jagrosh/MusicBot.git
WORKDIR /MusicBot
RUN sed -i -e s/Snapshot/${UPSTREAM_VERSION?upstream version not provided}/g ./pom.xml
RUN mvn verify

FROM ubuntu:jammy as release
RUN apt-get update
RUN apt-get install -y --no-install-recommends default-jre
ARG UPSTREAM_VERSION
RUN mkdir /config
RUN mkdir /app
WORKDIR /app
COPY --from=builder "/MusicBot/target/JMusicBot-${UPSTREAM_VERSION?upstream version not provided}-All.jar" ./JMusicBot.jar
RUN useradd -s nonroot
USER nonroot
ENTRYPOINT java -Dnogui=true -jar JMusicBot.jar