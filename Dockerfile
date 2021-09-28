FROM debian:10-slim AS builder

RUN apt update && apt install -y wget unzip;

# Download and unpack Java
ARG JDK11_PATH=11.0.12+7
ARG JDK11_FILE=11.0.12_7

RUN wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-${JDK11_PATH}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK11_FILE}.tar.gz -nv -O jdk.tar.gz \
  && mkdir -p /jdk \
  && tar -xzf jdk.tar.gz -C /jdk --strip-components=1 \
  && rm jdk.tar.gz

# Download and unpack Maven
ARG MAVEN_VERSION=3.8.2
ARG MAVEN_SHA=b0bf39460348b2d8eae1c861ced6c3e8a077b6e761fb3d4669be5de09490521a74db294cf031b0775b2dfcd57bd82246e42ce10904063ef8e3806222e686f222

RUN wget http://ftp.fau.de/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -nv -O maven.tar.gz\
  && echo "${MAVEN_SHA} maven.tar.gz" | sha512sum -c - \
  && mkdir /maven \
  && tar -xzf maven.tar.gz -C /maven --strip-components=1 \
  && rm maven.tar.gz


FROM tcardonne/github-runner:v1.8.0

# Install Java
COPY --from=builder /jdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

# Install Maven
COPY --from=builder /maven /usr/share/maven/
RUN ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven

# Install Node.js 14.x LTS
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install -y nodejs
