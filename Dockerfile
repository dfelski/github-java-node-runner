FROM debian:10-slim AS builder

RUN apt update && apt install -y wget unzip;

# Download and unpack Java
ARG JDK17_PATH=17+35
ARG JDK17_FILE=17_35

RUN wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK17_PATH}/OpenJDK17-jdk_x64_linux_hotspot_${JDK17_FILE}.tar.gz -nv -O jdk.tar.gz \
  && mkdir -p /jdk \
  && tar -xzf jdk.tar.gz -C /jdk --strip-components=1 \
  && rm jdk.tar.gz

# Download and unpack Maven
ARG MAVEN_VERSION=3.8.3
ARG MAVEN_SHA=1c12a5df43421795054874fd54bb8b37d242949133b5bf6052a063a13a93f13a20e6e9dae2b3d85b9c7034ec977bbc2b6e7f66832182b9c863711d78bfe60faa

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
