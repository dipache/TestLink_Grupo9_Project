# Etapa 1: Construir la imagen con PHP y Apache para TestLink
FROM php:7.4-apache AS testlink-builder

# Configuración de PHP para ignorar advertencias de deprecated
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" >> /usr/local/etc/php/php.ini

# Instalar extensiones de PHP necesarias y dependencias
RUN apt-get update && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
        unzip \
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



# Etapa 3: Imagen final
FROM php:7.4-apache

# Copiar solo lo necesario desde la etapa de TestLink
COPY --from=testlink-builder /var/www/html/ /var/www/html/
COPY --from=testlink-builder /var/testlink/ /var/testlink/

# Copiar solo lo necesario desde la etapa de MariaDB
COPY --from=mariadb-builder /var/lib/mysql /var/lib/mysql

# Exponer el puerto 80
EXPOSE 80
