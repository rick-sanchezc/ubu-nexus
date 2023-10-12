FROM ubuntu:latest 
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk-headless curl tar \
    && apt clean

ENV RUN_USER            nexus
ENV RUN_GROUP           nexus
ENV RUN_UID             5003
ENV RUN_GID             5003
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus 
ENV NEXUS_DATA=/nexus-data 
ENV NEXUS_CONTEXT='' 
ENV SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work

WORKDIR ${SONATYPE_DIR}

EXPOSE 8081

ARG NEXUS_VERSION=3.61.0-02
ARG NEXUS_PKG=nexus-${NEXUS_VERSION}-unix.tar.gz
ARG NEXUS_URL=https://download.sonatype.com/nexus/3/${NEXUS_PKG}

RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${NEXUS_HOME} --shell /bin/bash ${RUN_USER} \
    && mkdir -p ${NEXUS_HOME} \
    && curl -L ${NEXUS_URL} --output /opt/${NEXUS_PKG} \
    && tar -xf /opt/${NEXUS_PKG} --strip-components 1 -C ${NEXUS_HOME} \
    && rm -rf /opt/${NEXUS_PKG} \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${SONATYPE_DIR} \
    && mv ${NEXUS_HOME}/nexus3 ${NEXUS_DATA} \
    && mkdir ${SONATYPE_WORK} \
    && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3

RUN sed -i '/^-Xms/d;/^-Xmx/d;/^-XX:MaxDirectMemorySize/d' $NEXUS_HOME/bin/nexus.vmoptions \
   && echo "-Dcom.redhat.fips=false" >> $NEXUS_HOME/bin/nexus.vmoptions

RUN echo "#!/bin/bash" >> ${SONATYPE_DIR}/start-nexus-repository-manager.sh \
   && echo "cd /opt/sonatype/nexus" >> ${SONATYPE_DIR}/start-nexus-repository-manager.sh \
   && echo "exec ./bin/nexus run" >> ${SONATYPE_DIR}/start-nexus-repository-manager.sh \
   && chmod a+x ${SONATYPE_DIR}/start-nexus-repository-manager.sh \
   && sed -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' -i ${NEXUS_HOME}/etc/nexus-default.properties

VOLUME ${NEXUS_DATA}

USER ${RUN_USER} 
ENV INSTALL4J_ADD_VM_PARAMS="-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Djava.util.prefs.userRoot=${NEXUS_DATA}/javaprefs"
CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
