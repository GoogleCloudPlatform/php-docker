FROM alpine

RUN mkdir -p /opt/bin
ENV PATH=${PATH}:/opt/bin

# Install PHP and tools
RUN apk add php5 php5-openssl php5-json php5-phar php5-dom php5-bcmath wget \
    ca-certificates coreutils --update \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --filename=composer --install-dir=/opt/bin \
    && php -r "unlink('composer-setup.php');" \
    && wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /opt/bin/phpunit \
    && apk del wget \
    && rm -rf /var/cache/apk/*

COPY run_tests.sh /run_tests.sh
ENTRYPOINT ["/run_tests.sh"]
