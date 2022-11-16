FROM ubuntu:focal

ARG PHP_VERSION
ENV INSTALLED_PHP_VERSION=$PHP_VERSION \
  TZ=$TIMEZONE \
  YUM_y='-y'
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY scripts/*.sh /usr/local/bin/
RUN ["prepare-build-env.sh"]

ENTRYPOINT ["/usr/local/bin/build-extension.sh"]
