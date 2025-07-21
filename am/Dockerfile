FROM tomcat:10-jdk21 AS base
USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_OPTS="--no-install-recommends --yes"
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y binutils wget unzip vim curl && \
    apt-get clean

ENV FORGEROCK_HOME=/home/forgerock

ARG AM_FILE_NAME

# The openam context directory
ENV AM_HOME=$FORGEROCK_HOME/openam

ENV CATALINA_OPTS="-server \
    -Dcom.sun.services.debug.mergeall=on \
    -Dcom.sun.identity.configuration.directory=$AM_HOME \
    -Dorg.forgerock.donotupgrade=true \
    -DtomcatAccessLogDir=/proc/self/fd \
    -DtomcatAccessLogFile=1 \
    --add-opens java.xml/com.sun.org.apache.xerces.internal.dom=ALL-UNNAMED \
    --add-exports java.xml/com.sun.org.apache.xerces.internal.jaxp=ALL-UNNAMED \
    --add-exports java.xml/com.sun.org.apache.xerces.internal.util=ALL-UNNAMED"

ENV AM_CONTAINER_JVM_ARGS="-XX:MaxRAMPercentage=75 \
    -XX:InitialRAMPercentage=75 \
    -XX:MaxTenuringThreshold=1 \
    -Djava.security.egd=file:/dev/urandom"

RUN groupadd -g 11111 forgerock && \
    useradd -c "ForgeRock user" -m -d $FORGEROCK_HOME -u 11111 -g 11111 -G root forgerock
	

RUN chown -R forgerock:root "$CATALINA_HOME"
RUN chown -R forgerock:root "/usr/local/tomcat"
COPY --chown=forgerock:root server.xml /usr/local/tomcat/conf
RUN chmod u+w $JAVA_HOME/lib/security/cacerts

USER forgerock
RUN mkdir -p $AM_HOME
RUN chmod -R g+wx $AM_HOME

RUN rm -rf "$CATALINA_HOME"/webapps/*

ADD /build/"$AM_FILE_NAME" "$CATALINA_HOME"/webapps/
RUN unzip -q "$CATALINA_HOME"/webapps/"$AM_FILE_NAME" -d "$CATALINA_HOME"/webapps/am && \
    rm "$CATALINA_HOME"/webapps/"$AM_FILE_NAME"

# IAM-434: Preserves the native XUI code in a new location specifically for OAuth 2-related UI needs.
RUN cp -R /usr/local/tomcat/webapps/am/XUI /usr/local/tomcat/webapps/am/OAuth2_XUI
ENV CATALINA_USER_OPTS=-Dorg.forgerock.am.oauth2.consent.xui_path=/OAuth2_XUI

# Use a custom logback. Comment out if you want to use the default json logger.
COPY --chown=forgerock:root logback.xml /usr/local/tomcat/webapps/am/WEB-INF/classes

COPY --chown=forgerock:root *.sh /home/forgerock/

WORKDIR /usr/local/tomcat

CMD "$FORGEROCK_HOME/docker-entrypoint.sh"