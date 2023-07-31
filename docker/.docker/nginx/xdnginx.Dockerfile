FROM nginx:latest

WORKDIR /var/www

RUN apt-get update && apt-get install --quiet --yes --no-install-recommends \
    sudo vim libzip-dev libxml2-dev unzip less git curl

RUN echo 'alias ll="ls -alhG"' >> ~/.bashrc && echo -e "set nu\nsyntax on\nset mouse=c" >> ~/.vimrc 

# ### script add openssl ###
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/selfsigned/dockersite.test.key -out /etc/nginx/ssl/selfsigned/dockersite.test.crt -subj '/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=dockersite.test'
