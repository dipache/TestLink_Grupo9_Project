# Etapa 1: Construir la imagen con PHP y Apache para TestLink
FROM php:7.4-apache AS testlink-builder

# Configuración de PHP para ignorar advertencias de deprecated
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" >> /usr/local/etc/php/php.ini

# Actualizar la lista de paquetes e instalar extensiones de PHP necesarias y dependencias
RUN apt-get update && \
    apt-get install -y \
        libldap2-dev \
        libpq-dev \
        libxml2-dev \
        unzip \
        libfreetype6 \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
        && docker-php-ext-install mysqli pdo_mysql pdo_pgsql

# Ajustar la configuración de PHP
RUN echo "max_execution_time = 120" >> /usr/local/etc/php/php.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/php.ini \
    && echo "session.gc_maxlifetime = 1440" >> /usr/local/etc/php/php.ini \
    && echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini \
    && echo "error_reporting = E_ALL & ~E_NOTICE & ~E_DEPRECATED" >> /usr/local/etc/php/php.ini

# Descargar la última versión de TestLink
ADD https://github.com/TestLinkOpenSourceTRMS/testlink-code/archive/refs/heads/master.zip /var/www/html/testlink.zip

# Instalar unzip y descomprimir TestLink
RUN unzip /var/www/html/testlink.zip -d /var/www/html/ && \
    mv /var/www/html/testlink-code-master/* /var/www/html/ && \
    rm /var/www/html/testlink.zip

# Asignar permisos adecuados
RUN chown -R www-data:www-data /var/www/html/ && \
    mkdir -p /var/testlink/logs/ /var/testlink/upload_area/ && \
    chown -R www-data:www-data /var/testlink/logs/ /var/testlink/upload_area/

# Etapa 2: Construir la imagen de MariaDB
FROM mariadb:latest AS mariadb-builder

# Configuraciones específicas de MariaDB, si es necesario
# ENV MYSQL_ROOT_PASSWORD=root_password
# ENV MYSQL_DATABASE=bitnami_testlink
# ENV MYSQL_USER=testlink_user
# ENV MYSQL_PASSWORD=testlink_password

# Puedes añadir configuraciones específicas de MariaDB si es necesario

# Etapa 3: Imagen final
FROM gcr.io/stacksmith-images/ubuntu:14.04-r07

MAINTAINER Bitnami <containers@bitnami.com>

ENV BITNAMI_APP_NAME=testlink \
    BITNAMI_IMAGE_VERSION=1.9.14-r0 \
    PATH=/opt/bitnami/php/bin:/opt/bitnami/mysql/bin/:$PATH

# Additional modules required
RUN bitnami-pkg install php-5.6.23-0 --checksum 21f1d65e6f0721cbbad452ace681c5b1a41dec8aabe568140313dce045a0d537
RUN bitnami-pkg unpack apache-2.4.20-0 --checksum ec415b0938e6df70327055c5be50f80b1307b785fa5bbd04c94a4077519e5dba
RUN bitnami-pkg install libphp-5.6.21-0 --checksum 8c1f994108eb17c69b00ac38617997b8ffad7a145a83848f38361b9571aeb73e
RUN bitnami-pkg install mysql-client-10.1.13-1 --checksum e16c0ace5cb779b486e52af83a56367f26af16a25b4ab92d8f4293f1bf307107

# Install testlink
RUN bitnami-pkg unpack testlink-1.9.14-0 --checksum be3736e4ac44d3145fe13ad1225666a0f69d0babd88483d7db069220a00daab2

COPY rootfs /

VOLUME ["/bitnami/apache", "/bitnami/testlink"]

EXPOSE 80 443

ENTRYPOINT ["/app-entrypoint.sh"]

CMD ["harpoon", "start", "--foreground", "apache"]
