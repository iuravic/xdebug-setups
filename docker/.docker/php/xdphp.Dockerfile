FROM php:8.0-fpm

WORKDIR /var/www

# COPY command spins up a cached container built from the specified image and copies the specified files into the container being created.

# This takes the compiled composer application and places a copy in my PHP container. 
COPY --from=composer /usr/bin/composer /usr/bin/composer

# This installs WP CLI within the container.
COPY --from=wordpress:cli /usr/local/bin/wp /usr/local/bin/wp

RUN apt-get update && apt-get install --quiet --yes --no-install-recommends \
    sudo vim libzip-dev libxml2-dev unzip less git curl subversion subversion-tools
RUN docker-php-ext-install pdo pdo_mysql zip mysqli
RUN pecl install -o -f pcov && docker-php-ext-enable pcov
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Installs MySQL and Starts the MySQL daemon service
RUN apt-get install --quiet --yes --no-install-recommends default-mysql-server \
 && service mariadb start

# Create nonroot user with blank password
RUN useradd -m -p $(perl -e 'print crypt($ARGV[0], "password")' '') -u 1221 nonroot \
 && usermod -aG sudo nonroot \
 && usermod -aG sudo www-data

# .bashrc
RUN echo 'alias ll="ls -alhG"' >> /root/.bashrc \
 && echo 'alias ll="ls -alhG"' >> /home/nonroot/.bashrc

# ### script add xd aliases ###
RUN echo 'alias xddockersite.test="XDEBUG_CONFIG=\"start_with_request=yes\" PHP_IDE_CONFIG=\"serverName=dockersite.test\""' >> /home/nonroot/.bashrc

# .vim
RUN echo "set nu\nsyntax on\nset mouse=c" >> /root/.vimrc && echo "set nu\nsyntax on\nset mouse=c" >> /home/nonroot/.vimrc

# Switch the container to run using this user
USER nonroot

# wp site installation script
#RUN chown www-data:www-data /var/www/wp_cli_install_site.sh
#RUN chmod +x /var/www/wp_cli_install_site.sh
