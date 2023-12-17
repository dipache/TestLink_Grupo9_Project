# Utilizar una imagen base con PHP y Apache
FROM php:7.4-apache

# Instalar extensiones de PHP necesarias y dependencias
RUN apt-get update && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql gd ldap

# Ajustar la configuración de PHP
RUN echo "max_execution_time = 120" >> /usr/local/etc/php/php.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/php.ini

# Descargar la última versión de TestLink
ADD https://github.com/TestLinkOpenSourceTRMS/testlink-code/archive/refs/heads/master.zip /var/www/html/

# Instalar unzip y descomprimir TestLink
RUN apt-get update && \
    apt-get install -y unzip && \
    unzip /var/www/html/master.zip -d /var/www/html/ && \
    mv /var/www/html/testlink-code-master/* /var/www/html/ && \
    rm /var/www/html/master.zip

# Asignar permisos adecuados
RUN chown -R www-data:www-data /var/www/html/

# Crear directorios faltantes
RUN mkdir -p /var/testlink/logs/ /var/testlink/upload_area/

# Asignar permisos a los directorios faltantes
RUN chown -R www-data:www-data /var/testlink/logs/ /var/testlink/upload_area/

# Exponer el puerto 80
EXPOSE 80
