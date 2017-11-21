FROM oberthur/docker-ubuntu-java:openjdk-8u131b11_V2

# grab gosu for easy step-down from root
ENV GOSU_VERSION=1.10 \
    JOLOKIA_VERSION=1.3.7 \
    CASSANDRA_VERSION=2.1.19 \
    CASSANDRA_CONFIG=/etc/cassandra

COPY docker-entrypoint.sh /docker-entrypoint.sh

# explicitly set user/group IDs
RUN        groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra \
        && chmod +x /docker-entrypoint.sh \
        && set -x \
        && apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && rm -rf /var/lib/apt/lists/* \
        && curl -L "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" > /usr/local/bin/gosu \
        && curl -L "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" > /usr/local/bin/gosu.asc \
        && export GNUPGHOME="$(mktemp -d)" \
        && gpg --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
        && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
        && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
        && chmod +x /usr/local/bin/gosu \
        && gosu nobody true \
        && apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 514A2AD631A57A16DD0047EC749D6EEC0353B12C \
        && curl -L "http://www.apache.org/dist/cassandra/KEYS" | apt-key add - \
        && echo "deb http://www.apache.org/dist/cassandra/debian 21x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list \
        && apt-get update \
        && apt-get install --assume-yes \
              cassandra=${CASSANDRA_VERSION} \
              cassandra-tools=${CASSANDRA_VERSION} \
        && service cassandra stop && rm -rf /var/lib/cassandra/data && rm -rf /var/lib/cassandra/commit_log \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean \
        && mkdir /usr/local/jolokia \
        && curl -L "http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/$JOLOKIA_VERSION/jolokia-jvm-$JOLOKIA_VERSION-agent.jar" > /usr/local/jolokia/jolokia.jar \
        && chmod 755 /usr/local/jolokia \
        && curl -L "https://github.com/oberthur/cassandra-ext/releases/download/20170323/cassandra-ext-2.1-20170123.jar" > /usr/share/cassandra/lib/cassandra-ext-2.0-20170123.jar \
        && apt-get purge -y --auto-remove curl \
        && mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
        && chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
        && chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG" \
        && echo 'JVM_OPTS="$JVM_OPTS $CUSTOM_JVM_OPTS"' >> "$CASSANDRA_CONFIG"/cassandra-env.sh

ENTRYPOINT ["/docker-entrypoint.sh", "cassandra", "-f"]

VOLUME ["/etc/cassandra", "/var/lib/cassandra/data", "/var/lib/cassandra/commitlog", "/var/log/cassandra"]

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160
