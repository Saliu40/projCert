FROM php:7.4-apache
COPY . /var/www/html/
EXPOSE 80
CMD ["apache2-foreground"]