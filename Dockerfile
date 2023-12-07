

# Usar una imagen base con PHP y Apache
FROM php:7.4-apache

# Instalar extensiones de PHP necesarias
RUN docker-php-ext-install mysqli pdo pdo_mysql

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

# Configurar el volumen para la persistencia de datos
VOLUME ["/var/www/html"]

# Exponer el puerto 80
EXPOSE 80
