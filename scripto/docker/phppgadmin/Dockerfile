FROM dockage/phppgadmin:latest

MAINTAINER Remigiusz Boguszewicz <remigiusz.boguszewicz@unit9.com>

ARG UNIT9_PASS

# Install apache utils that provide htpasswd
RUN apk update && \
    apk add apache2-utils && \
    echo "${UNIT9_PASS}" | htpasswd -i -c /etc/nginx/.htpasswd unit9 && \
    cp /etc/dockage/runtime/configs/nginx/default.conf /tmp/default.conf.before_http_auth && \
    sed -i "s|index.php?\$args;|index.php?\$args;\n\tauth_basic\ \"Private\ Property\";\n\tauth_basic_user_file /etc/nginx/.htpasswd;|" /etc/dockage/runtime/configs/nginx/default.conf

