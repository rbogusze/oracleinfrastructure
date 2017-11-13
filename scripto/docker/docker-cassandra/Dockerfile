FROM oberthur/docker-ubuntu-java:jdk8_8.121.13_V2

# grab gosu for easy step-down from root
ENV GOSU_VERSION=1.9 \
    CASSANDRA_VERSION=3.9 \
    CASSANDRA_CONFIG=/etc/cassandra

COPY docker-entrypoint.sh /docker-entrypoint.sh

# explicitly set user/group IDs
RUN        groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra \
        && chmod +x /docker-entrypoint.sh \
        && set -x \
        && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
        && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
        && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
        && export GNUPGHOME="$(mktemp -d)" \
        && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
        && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
        && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
        && chmod +x /usr/local/bin/gosu \
        && gosu nobody true \
        && apt-get purge -y --auto-remove ca-certificates wget \
        && apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 514A2AD631A57A16DD0047EC749D6EEC0353B12C \
        && curl -L http://www.apache.org/dist/cassandra/KEYS | apt-key add - \
        && echo "deb http://pl.archive.ubuntu.com/ubuntu/ wily main universe" | tee -a /etc/apt/sources.list.d/python-support.list \
        && echo "deb http://www.apache.org/dist/cassandra/debian 39x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list \
        && curl -L http://debian.datastax.com/debian/repo_key | apt-key add - \
        && apt-get update \
        && apt-get install --assume-yes \
              cassandra=${CASSANDRA_VERSION} \
              cassandra-tools=${CASSANDRA_VERSION} \
        && service cassandra stop && rm -rf /var/lib/cassandra/data && rm -rf /var/lib/cassandra/commit_log \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean \
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
